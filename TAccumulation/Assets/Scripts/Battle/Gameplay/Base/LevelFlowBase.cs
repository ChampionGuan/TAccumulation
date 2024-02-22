using System;
using System.Collections.Generic;
using FlowCanvas;
using PapeGames.X3;
using Unity.Mathematics;

namespace X3Battle
{
    public enum StageState
    {
        None,
        /// <summary> 关卡前流程 </summary>
        Before,
        /// <summary> 关卡中流程 </summary>
        Mid,
        /// <summary> 关卡结束流程 </summary>
        End,
    }
    public class TagData
    {
        public int id;
        public string icon;
        public bool matched;
    }
        
    public class AffixData
    {
        public int id;
        public int level;
        public string icon;
    }
    
    public abstract class LevelFlowBase
    {
        public Battle battle => Battle.Instance;
        
        private List<NotionGraph<FlowScriptController>> _talks;

        private Action _settlementCallback;
        private Action<ECEventDataBase> _actionLevelEndProcessStart;
        
        private float? _curLevelFailDelay = null; // 关卡失败结束流程时的倒计时逻辑.
        
        /// <summary> 是否暂停关卡计时 </summary>
        private bool _paused;

        /// <summary> 当前关卡状态 </summary>
        private StageState _state = StageState.None;

        /// <summary> 关卡状态枚举 </summary>
        public StageState state
        {
            get => _state;
            set
            {
                if (value == _state)
                {
                    return;
                }
                
                var fromState = _state;
                var toState = value;
                _state = toState;
                _ChangeStageState(fromState, toState);
            }
        }
        
        /// <summary> 关卡时间(关卡正计时) </summary>
        public float levelTime { get; private set; }
        
        /// <summary> 关卡存活时间(策划配置的时长.) </summary>
        public float lifeTime { get; private set; }
        
        /// <summary> 关卡警告时间 </summary>
        public float levelWarningTime { get; private set; }

        /// <summary> 剩余时间 </summary>
        public float remainTime
        {
            get
            {
                if (lifeTime < 0)
                {
                    return float.MaxValue;
                }

                return math.max(lifeTime - levelTime, 0);
            }
        }
        
        /// <summary>
        /// 返回关卡当前时间，若正计时则是已经过的时间，若倒计时则显示剩余的时间
        /// </summary>
        /// <returns></returns>
        public float GetCurTime()
        {
            if (battle.config.TimeLimitType == (int)TimeLimitType.Positive)
            {
                // 正计时
                return levelTime;
            }
            else
            {
                // 倒计时
                return lifeTime - levelTime;
            }
        }

        public float aggressiveStrategyCDR { get; private set; }
        public int aggressiveStrategyExtraToken { get; private set; }
        public float aggressiveStrategyTokenExitSpeedup { get; private set; }

        /// <summary> 关卡Tag数据 </summary>
        public List<TagData> tagDatas { get; private set; }
        
        /// <summary> 关卡词缀数据 </summary>
        public List<AffixData> affixDatas { get; private set; }

        public LevelFlowBase()
        {
            _settlementCallback = _OnSettlementCallback;
            _actionLevelEndProcessStart = _OnLevelEndProcessStart;
        }

        public void Awake()
        {
            lifeTime = battle.config.TimeLimit;
            levelWarningTime = TbUtil.battleConsts.LevelWarningTime;
            levelTime = 0f;
            _curLevelFailDelay = null;
            _paused = true;
            _talks = new List<NotionGraph<FlowScriptController>>();
            
            int aggressiveStrategy = battle.config.AggressiveStrategy;
            aggressiveStrategyCDR = aggressiveStrategy >= TbUtil.battleConsts.LevelAggressiveStrategy_CDR.Length ? TbUtil.battleConsts.LevelAggressiveStrategy_CDR[0] : TbUtil.battleConsts.LevelAggressiveStrategy_CDR[aggressiveStrategy];
            aggressiveStrategyCDR = 1 / (1 + aggressiveStrategyCDR);
            aggressiveStrategyExtraToken = aggressiveStrategy >= TbUtil.battleConsts.LevelAggressiveStrategy_ExtraToken.Length ? TbUtil.battleConsts.LevelAggressiveStrategy_ExtraToken[0] : TbUtil.battleConsts.LevelAggressiveStrategy_ExtraToken[aggressiveStrategy];
            aggressiveStrategyTokenExitSpeedup = aggressiveStrategy >= TbUtil.battleConsts.LevelAggressiveStrategy_TokenExitSpeedup.Length ? TbUtil.battleConsts.LevelAggressiveStrategy_TokenExitSpeedup[0] : TbUtil.battleConsts.LevelAggressiveStrategy_TokenExitSpeedup[aggressiveStrategy];
            aggressiveStrategyTokenExitSpeedup = 1 / (1 + aggressiveStrategyTokenExitSpeedup);

            // DONE: 关卡前流程数据初始化.
            tagDatas = new List<TagData>();
            affixDatas = new List<AffixData>();

            var tempScoreTags = new List<int>();
            foreach (int scoreTag in battle.arg.scoreTags)
            {
                tempScoreTags.Add(scoreTag);
            }
            
            //Tag 匹配
            foreach (var levelTag in battle.arg.levelTags)
            {
                if (!TbUtil.TryGetCfg(levelTag, out BattleTag battleTag))
                {
                    continue;
                }

                TagData tagData = ObjectPoolUtility.TagData.Get();
                tagData.id = levelTag;
                tagData.icon = battleTag.TagIcon;
                tagData.matched = false;
                foreach (int scoreTag in tempScoreTags)
                {
                    if (scoreTag == levelTag)
                    {
                        tempScoreTags.Remove(scoreTag);
                        tagData.matched = true;
                        break;
                    }
                }
                tagDatas.Add(tagData);
            }
            
            //词缀 处理
            foreach (SkillSlotConfig skillSlotConfig in battle.arg.affixesSkillSlotConfigs)
            {
                SkillLevelCfg skillLevelCfg = TbUtil.GetSkillLevelCfg(skillSlotConfig.SkillID, skillSlotConfig.SkillLevel);
                if (skillLevelCfg == null)
                {
                    continue;
                }
                AffixData affixData = ObjectPoolUtility.AffixData.Get();
                affixData.id = skillSlotConfig.SkillID;
                affixData.level = skillSlotConfig.SkillLevel;
                affixData.icon = skillLevelCfg.SkillIcon;
                affixDatas.Add(affixData);
            }
            
            // DONE: 监听关卡失败流程开始
            battle.eventMgr.AddListener<ECEventDataBase>(EventType.OnLevelEndFlowStart, _actionLevelEndProcessStart, "LevelFlow._OnLevelEndProcessStart");
            
            OnAwake();
        }
        
        public void Destroy()
        {
            battle.eventMgr.RemoveListener<ECEventDataBase>(EventType.OnLevelEndFlowStart, _actionLevelEndProcessStart);
            if (_talks != null)
            {
                for (var i = 0; i < _talks.Count; i++)
                {
                    _talks[i]?.OnDestroy();
                }                
            }

            OnDestroy();
        }

        public void Preload()
        {
            // DONE: 创建关卡Actor.
            battle.actorMgr.CreateStage();
            
            // DONE: 预热关卡沟通蓝图
            _talks.Clear();
            foreach (var talkFlowPath in battle.config.Graphs)
            {
                if (!BattleResMgr.Instance.IsExists(talkFlowPath, BattleResType.Flow))
                {
                    continue;
                }
            
                var notionGraph = new NotionGraph<FlowScriptController>();
                notionGraph.Init(new ActorContext(battle.actorMgr.stage), talkFlowPath, BattleResType.Flow, battle.root, true);
                notionGraph.Disable(true);
                _talks.Add(notionGraph);
            }
            
            // DONE: 预热关卡流图资源.
            OnPreload();
        }

        public void StartupFinished()
        {
            state = StageState.Before;
            
            // DONE: 创建关卡Actor.
            battle.actorMgr.CreateStage();

            // DONE: 启动关卡流
            OnStartBefore();
        }

        public void BattleBegin()
        {
            battle.eventMgr.AddListener<EventActorBase>(EventType.ActorBorn, _OnActorBorn, "LevelFlow._OnActorBorn");
            battle.eventMgr.AddListener<EventActorBase>(EventType.ActorDead, _OnActorDead, "LevelFlow._OnActorDead");
            
            OnBattleBegin();
        }
        
        public void BattleEnd()
        {
            OnBattleEnd();
            
            battle.eventMgr.RemoveListener<EventActorBase>(EventType.ActorBorn, _OnActorBorn);
            battle.eventMgr.RemoveListener<EventActorBase>(EventType.ActorDead, _OnActorDead);
            
            // DONE: 暂停关卡倒计时
            Pause(true);
            
            // DONE: 保底移除新手引导事件
            BattleEnv.LuaBridge.TryUnregisterGuideEvent();
            
            // DONE: 全局伤害流程开关置为false
            battle.damageProcess.EnableDamage = false;
            
            // DONE: 清除Battle层输入指令
            battle.input.ClearPlayerCache();
            
            // DONE: 清除男女主的输入指令
            battle.actorMgr.girl?.input.ClearCache();
            battle.actorMgr.boy?.input.ClearCache();
            
            // DONE: 停止关卡Stage的所有技能.
            battle.actorMgr.stage?.skillOwner?.StopAllSkill();
            
            // DONE: 隐藏技能UI.
            BattleUtil.SetUINodeVisible(UIComponentType.Slot, false);
            BattleUtil.SetUINodeVisible(UIComponentType.Timer, false);
            BattleUtil.SetUINodeVisible(UIComponentType.BoyActive, false);

            // DONE: 禁用所有Actor的AI.
            foreach (Actor actor in battle.actorMgr.actors)
            {
                actor.aiOwner?.DisableAll(true);
            }

            // DONE: 开始战斗结算流程, 等待结算回调.
            var eventData = new EventBattleEnd();
            eventData.Init(battle.config.ID, battle.status == BattleRunStatus.Success, battle.endReason);
            BattleEnv.LuaBridge.StartSettlementProcess(eventData, _settlementCallback);
        }
        
        public void StartMidFlow()
        {
			state = StageState.Mid;
			
			// DONE: 启动关卡沟通图.
            CriticalLog.Log("[战斗][关卡流][LevelFlow.StartLevel()] 开始关卡流程!");
            OnStartMid();

            // DONE: 如果关卡已经结束了, 就没有必要在处理关卡开始逻辑了.
            if (battle.isEnd)
            {
                return;
            }
            
            _beLockedMonsterCount = 0;
            _enableBossCameraCount = 0;

            // DONE: 启动关卡中倒计时
            Pause(false);

            if (_talks != null)
            {
                foreach (var talk in _talks)
                {
                    talk.Restart();
                }
            }
            
            // TODO 触发关卡开始, 需要与策划一同梳理节点.
            battle.eventMgr.Dispatch(EventType.OnLevelStart, null);
            
            //离线战斗处理
            if (battle.arg.startupType != BattleStartupType.Online)
            {
                bool isFullMatch = true;
                foreach (var tagData in tagDatas)
                {
                    if (!tagData.matched)
                    {
                        isFullMatch = false;
                        break;
                    }
                }
                
                if (isFullMatch)
                {
                    var cachedIsDynamicLoadErring = BattleResMgr.isDynamicLoadErring;
                    BattleResMgr.isDynamicLoadErring = false;
                    battle.player?.buffOwner.Add(14, 1, -1, 1, null);
                    battle.actorMgr.boy?.buffOwner.Add(14, 1, -1, 1, null);
                    BattleResMgr.isDynamicLoadErring = cachedIsDynamicLoadErring;
                }
            }
        }
        
        /// <summary>
        /// 关卡结束流完成
        /// </summary>
        public void EndFlowFinished()
        {
            OnFlowEnd();
        }

        //暂停/恢复
        public void Pause(bool paused)
        {
            _paused = paused;
        }

        public void Update()
        {
            _UpdateLevelTime();
            OnUpdate();
        }

        private void _OnSettlementCallback()
        {
            state = StageState.End;
            OnStartEnd();
            
            // 派发关卡结束流程开始事件.
            battle.eventMgr.Dispatch(EventType.OnLevelEndFlowStart, null);
        }

        private void _OnLevelEndProcessStart(ECEventDataBase data)
        {
            if (battle.status != BattleRunStatus.Fail)
            {
                return;
            }
            
            _curLevelFailDelay = TbUtil.battleConsts.LevelFailDelay;
        }

        private void _ChangeStageState(StageState fromState, StageState toState)
        {

        }

        protected virtual void OnAwake()
        {
        }

        protected virtual void OnDestroy()
        {
        }

        protected virtual void OnPreload()
        {
        }

        protected virtual void OnBattleBegin()
        {
        }

        protected virtual void OnBattleEnd()
        {
        }

        protected virtual void OnStartBefore()
        {
        }

        protected virtual void OnStartMid()
        {
        }

        protected virtual void OnStartEnd()
        {
        }

        protected virtual void OnFlowEnd()
        {
        }

        protected virtual void OnUpdate()
        {
            
        }
        
        #region 关卡结束/计时

        /// <summary>
        /// 更新关卡计时
        /// </summary>
        private void _UpdateLevelTime()
        {
            if (_paused)
                return;
            levelTime += battle.deltaTime;
            
            if (lifeTime < 0)
            {
                return;
            }
            
            if (levelTime >= lifeTime)
            {
                // DONE: 关卡玩法倒计时结束时是否判定为胜利.
                if (battle.config.IsArrivalTimeToWin && battle.config.TimeLimitType == (int)TimeLimitType.Reverse)
                {
                    battle.End(true);
                }
                else
                {
                    battle.End(false, BattleEndReason.TimeOut);
                }
            }
        }

        private void _OnActorBorn(EventActorBase arg)
        {
            var actor = arg.actor;
            // DONE: 不是怪物不关注.
            // DONE: 只关注出生配置可被锁定的怪物.
            if (levelBattleState != LevelBattleState.None && actor.IsMonster() && actor.bornCfg.EnableBeLocked)
            {
                ++_beLockedMonsterCount;
                if (actor.IsEnableBossCamera())
                {
                    ++_enableBossCameraCount;
                }

                _ChangeLevelState(_CanEnterBossLevelState() ? LevelBattleState.Boss : LevelBattleState.Normal);
            }
        }

        private void _OnActorDead(EventActorBase arg)
        {
            if (!battle.isBegin)
            {
                return;
            }
            
            var actor = arg.actor;
            // DONE: 不是怪物不关注.
            // DONE: 只关注出生配置可被锁定的怪物.
            if (levelBattleState != LevelBattleState.None && actor.IsMonster() && actor.bornCfg.EnableBeLocked)
            {
                --_beLockedMonsterCount;
                if (actor.IsEnableBossCamera())
                {
                    --_enableBossCameraCount;
                }

                _ChangeLevelState(_CanEnterBossLevelState() ? LevelBattleState.Boss : LevelBattleState.Normal);
            }
            
            // 检测战斗结束
            if (!actor.IsGirl() && !actor.IsBoy())
            {
                return;
            }

            if (battle.arg.startupType == BattleStartupType.OfflineCustom || battle.isEnd)
            {
                return;
            }

            if (battle.player.isDead)
            {
                battle.End(false, endReason: BattleEndReason.GirlDead);
            }
            else if (battle.actorMgr.boy.isDead)
            {
                battle.End(false, endReason: BattleEndReason.BoyDead);
            }
        }

        protected void _CheckLevelEndByFail()
        {
            if (_curLevelFailDelay == null)
            {
                return;
            }
            
            _curLevelFailDelay -= battle.deltaTime;
            if (_curLevelFailDelay <= 0)
            {
                _curLevelFailDelay = null;
                EndFlowFinished();
            }
        }
        #endregion

        #region 关卡战斗状态
        public LevelBattleState levelBattleState { get; private set; } = LevelBattleState.None;
        private int _beLockedMonsterCount;
        private int _enableBossCameraCount;
        
        /// <summary>
        /// 进入战斗状态
        /// </summary>
        public void EnterLevelState()
        {
            if (!_CanEnterBossLevelState())
            {
                _ChangeLevelState(LevelBattleState.Normal);
            }
            else
            {
                _ChangeLevelState(LevelBattleState.Boss);
            }
        }
        
        /// <summary>
        /// 离开战斗状态
        /// </summary>
        public void LeaveLevelState()
        {
            _ChangeLevelState(LevelBattleState.None);
        }
        
        private void _ChangeLevelState(LevelBattleState levelBattleState)
        {
            if (this.levelBattleState == levelBattleState)
            {
                return;
            }

            var lastLevelState = this.levelBattleState;
            this.levelBattleState = levelBattleState;

            LogProxy.LogFormat("触发 【关卡战斗状态切换事件】 上一个关卡战斗状态: {0}, 当前关卡战斗状态：{1}", lastLevelState, this.levelBattleState);
            
            var eventData = battle.eventMgr.GetEvent<EventChangeLevelState>();
            eventData.Init(lastLevelState, levelBattleState);
            battle.eventMgr.Dispatch(EventType.ChangeLevelState, eventData);
        }

        /// <summary>
        /// 是否能进入Boss关卡战斗状态
        /// </summary>
        /// <returns></returns>
        private bool _CanEnterBossLevelState()
        {
            // DONE: 超过多个可被锁定的怪不能进入.
            if (_beLockedMonsterCount > 1)
            {
                return false;
            }
            
            // DONE: 没有Boss不能进入.
            bool enableBossCamera = _enableBossCameraCount > 0;
            if (!enableBossCamera)
            {
                return false;
            }

            return true;
        }
        #endregion
    }
}