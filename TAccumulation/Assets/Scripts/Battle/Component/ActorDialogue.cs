using System;
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using Random = UnityEngine.Random;

namespace X3Battle
{
    
    public class ActorDialogue : BattleComponent
    {
        /// <summary>
        /// 是否忽略战斗暂停逻辑
        /// </summary>
        public bool ignoreBattlePaused{ get; private set; }

        /// <summary>
        /// 是否暂停
        /// </summary>
        private bool _paused;

        /// <summary>
        /// 当前沟通
        /// </summary>
        public DialogueNode currDialogue { get; private set; }

        /// <summary>
        /// 等待触发列表
        /// </summary>
        private List<DialogueNode> _dialogueWaitingList = new List<DialogueNode>(10);
        
        /// <summary>
        /// 播放过的key
        /// </summary>
        private Dictionary<string, float> _dialoguePlayTimeDic = new Dictionary<string, float>(10);
        /// <summary>
        /// 全配置
        /// </summary>
        private Dictionary<string, List<DialogueConfig>> _dialogueConfigDic = new Dictionary<string, List<DialogueConfig>>();
        /// <summary>
        /// 缓存的配置
        /// </summary>
        private static Dictionary<int, DialogueConfig> _cachedDialogueDic = new Dictionary<int, DialogueConfig>(10);
        /// <summary>
        /// 图鉴类型的配置ID
        /// </summary>
        private List<int> _galleryDialogIds = new List<int>(20);
        /// <summary>
        /// 男主scoreID
        /// </summary>
        private int _boyScoreID;

        private EBattleState _battleState;
        
        private enum EBattleState
        {
            EBattle = 1,//战斗状态
            EIdle,//非战斗状态
        }

        public ActorDialogue() : base(BattleComponentType.Dialogue)
        {
            BattleClient.Instance.onPrePhysicalJobRunning.AddListener(_DoUpdate);
        }

        protected override void OnAwake()
        {
            _battleState = EBattleState.EIdle;
            _Reset();
            battle.eventMgr.AddListener<OnEventEnterHurt>(EventType.EnterHurt, _EnterHurt, "ActorDialogue._EnterHurt");
        }
        
        /// <summary>
        /// 关卡开始
        /// </summary>
        public void OnLevelStart()
        {
            _battleState = EBattleState.EBattle;
        }
        
        /// <summary>
        /// 外部设置是否忽略战斗暂停
        /// </summary>
        /// <param name="ignoreBattlePaused"></param>
        public void SetIgnoreBattlePaused(bool ignoreBattlePaused)
        {
            this.ignoreBattlePaused = ignoreBattlePaused;
        }
        
        /// <summary>
        /// 停止当前战斗沟通
        /// </summary>
        public void StopCurNode()
        {
            if (currDialogue != null)
            {
                currDialogue.StopSound();
                currDialogue.Destroy();
                currDialogue = null;
            }
        }

        public void Pause(bool paused)
        {
            _paused = paused;
            if (_paused)
            {
                _dialogueWaitingList.Clear();
                StopCurNode();
            }
        }
        
        /// <summary>
        /// 播放战斗沟通
        /// </summary>
        /// <param name="key"></param>
        public DialogueNode Play(string key)
        {
            if (_paused)
                return null;
            LogProxy.Log("战斗沟通：发送key:" + key + " time=" + battle.time);
            
            //男主或者女主没有不能播放语音沟通
            if (battle.actorMgr.boy == null || battle.actorMgr.girl == null)
            {
                return null;
            }
            
            _boyScoreID = battle.actorMgr.boy.boyCfg.ScoreID;
            
            //选择对应的Key
            DialogueConfig dialogueConfig = _GetDialogueConfig(key, battle.actorMgr.boy.boyCfg.ScoreID, BattleConst.GirlScoreID);
            if (dialogueConfig == null)
            {
                return null;
            }
            
            //获取key配置            
            DialogueKeyConfig dialogueKeyConfig = _GetDialogueKeyConfig(key, _boyScoreID, BattleConst.GirlScoreID);
            if (dialogueKeyConfig == null)
            {
                return null;
            }
            
            //入场时间判断
            if (dialogueKeyConfig.StartCD > battle.time)
            {
                return null;
            }
            
            //先计算Key的整体概率
            var range = Random.Range(0, 101);
            if (range > dialogueKeyConfig.KeyRate)
            {
                return null;
            }
                
            //再次播放CD保护
            if (!_IsCanAgainPlay(dialogueKeyConfig.Key, dialogueKeyConfig.TalkCD))
            {
                return null;
            }

            //播放的主体是否存在
            var useActor = BattleUtil.GeDialogueActor(dialogueConfig.ActorType1);
            if (useActor == null)
            {
                return null;
            }
                
            //受击是否能播放
            if (useActor.hurt.isHurt && dialogueKeyConfig.HitInterrupt == 1)
            {
                return null;
            }
                
            DialogueNode node = ObjectPoolUtility.DialogueNodePool.Get();
            node.Init(dialogueConfig, dialogueKeyConfig, this);
            LogProxy.Log("战斗沟通：增加key:" + key + " time=" + battle.time);
            _dialogueWaitingList.Add(node);
            return node;
        }
        /// <summary>
        /// 播放战斗沟通
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="keys"></param>
        public DialogueNode Play(List<string> keys)
        {
            if (_paused)
                return null;
            var lenIds = keys.Count;
            if (lenIds < 1)
            {
                return null;
            }

            DialogueNode node = null;
            foreach (var key in keys)
            {
                var tempNode = Play(key);
                if (tempNode != null)
                {
                    node = tempNode;
                }
            }

            return node;
        }

        protected override void OnDestroy()
        {
            BattleClient.Instance.onPrePhysicalJobRunning.RemoveListener(_DoUpdate);
            battle.eventMgr.RemoveListener<OnEventEnterHurt>(EventType.EnterHurt, _EnterHurt);
            if (_galleryDialogIds.Count > 0)
            {
                BattleEnv.LuaBridge.ActiveScoreVoices(_galleryDialogIds, _boyScoreID);
            }
            _Reset();
        }

        private void _Reset()
        {
            currDialogue = null;
            _dialogueWaitingList.Clear();
            _dialoguePlayTimeDic.Clear();
            _cachedDialogueDic.Clear();
            _galleryDialogIds.Clear();
            _galleryDialogIds.Clear();
            ignoreBattlePaused = false;
        }

        protected override void OnStart()
        {
            _StorageConfigDic();
        }
        
        //创建数据缓存 减少开销
        private void _StorageConfigDic()
        {
            foreach (var configItem in TbUtil.dialogueConfigs)
            {
                DialogueConfig dialogueConfig = configItem.Value;
                _dialogueConfigDic.TryGetValue(dialogueConfig.Key, out List<DialogueConfig> dialogueConfigs);
                if (dialogueConfigs == null)
                {
                    dialogueConfigs = new List<DialogueConfig>();
                    _dialogueConfigDic.Add(dialogueConfig.Key, dialogueConfigs);
                }
                dialogueConfigs.Add(dialogueConfig);
            }
        }

        private void _DoUpdate()
        {
            if (currDialogue != null)
            {
                currDialogue.Update();
                if (currDialogue.action == DialogueNode.EDialogueNode.End)
                {
                    var tempDialogue = currDialogue;
                    currDialogue = null;
                    //战斗沟通播放完成事件
                    var eventData = Battle.Instance.eventMgr.GetEvent<EventDialoguePlayEnd>();
                    eventData.Init(tempDialogue);
                    Battle.Instance.eventMgr.Dispatch(EventType.DialoguePlayEnd, eventData);
                    
                    LogProxy.Log("战斗沟通：播放完成key:" + tempDialogue.keyConfig.Key + " time=" + battle.time);
                    tempDialogue.Destroy();
                }
            }
            
            if (_dialogueWaitingList.Count < 1)
            {
                return;
            }
            
            //同帧战斗沟通只播放优先级最高的那个 
            var node = _GetMaxWeightNode(_dialogueWaitingList);
            
            if (_IsCanPlay(node))
            {
                _PlayNode(node);
                _dialogueWaitingList.Remove(node);
            }

            foreach (var info in _dialogueWaitingList)
            {
                //战斗沟通播放失败事件
                var eventData = Battle.Instance.eventMgr.GetEvent<EventDialoguePlayError>();
                eventData.Init(info);
                Battle.Instance.eventMgr.Dispatch(EventType.DialoguePlayError, eventData);
                info.Destroy();
            }
            
            _dialogueWaitingList.Clear();
        }

        private void _EnterHurt(OnEventEnterHurt arg)
        {
            if (arg == null || currDialogue == null)
                return;
            if (currDialogue.keyConfig.HitInterrupt == 1)
            {
                var actorFirst = BattleUtil.GeDialogueActor(currDialogue.config.ActorType1);
                var actorTwo = BattleUtil.GeDialogueActor(currDialogue.config.ActorType2);
                var actorThree = BattleUtil.GeDialogueActor(currDialogue.config.ActorType3);
                var actorFour = BattleUtil.GeDialogueActor(currDialogue.config.ActorType4);
                if (actorFirst != null && actorFirst == arg.target ||
                    actorTwo != null && actorTwo == arg.target ||
                    actorThree != null && actorThree == arg.target ||
                    actorFour != null && actorFour == arg.target)
                {
                    StopCurNode();
                }
            }
        }
        
        /// <summary>
        /// 能否播放当前的沟通
        /// </summary>
        /// <param name="node"></param>
        private bool _IsCanPlay(DialogueNode node)
        {
            if (currDialogue == null)
            {
                return true;
            }

            if (currDialogue.action == DialogueNode.EDialogueNode.End)
            {
                return true;
            }
            
            //预沟通不能打算其他沟通
            if (node.keyConfig.CanInterrupt != 1)
            {
                return false;
            }
            
            //判断当前节点是否无视保护时间
            if (node.keyConfig.IgnoreProtect != 1 && currDialogue.IsProtectTime())
            {
                return false;
            }

            if (node.keyConfig.TalkWeight > currDialogue.keyConfig.TalkWeight)
            {
                //战斗沟通打断事件
                var eventData = Battle.Instance.eventMgr.GetEvent<EventDialogueInterrupt>();
                eventData.Init(currDialogue,node);
                Battle.Instance.eventMgr.Dispatch(EventType.DialogueInterrupt, eventData);
                
                LogProxy.Log("战斗沟通：被打断key:" + currDialogue.keyConfig.Key + "打断的key= + " + node.keyConfig.Key + " time=" + battle.time);
                StopCurNode();
                return true;
            }

            return false;
        }
        
        /// <summary>
        /// 播放一个沟通
        /// </summary>
        /// <param name="node"></param>
        private void _PlayNode(DialogueNode node)
        {
            currDialogue = node;
            node.Update();
            DialogueKeyConfig dialogueKeyConfig = node.keyConfig;
            DialogueConfig dialogueConfig = node.config;
            LogProxy.Log("战斗沟通：播放key:" + dialogueKeyConfig.Key + " time=" + battle.time);
            //加入播放过的列表
            if (_dialoguePlayTimeDic.TryGetValue(dialogueKeyConfig.Key, out _))
            {
                _dialoguePlayTimeDic[dialogueKeyConfig.Key] = battle.time;
            }
            else
            {
                _dialoguePlayTimeDic.Add(dialogueKeyConfig.Key, battle.time);
            }
            //加入图鉴
            if (dialogueConfig.IsGallery && !_galleryDialogIds.Contains(dialogueConfig.DialogueID))
            {
                _galleryDialogIds.Add(dialogueConfig.DialogueID);
            }
        }

        /// <summary>
        /// 只留下优先级最高的
        /// </summary>
        /// <param name="nodes"></param>
        /// <returns></returns>
        private DialogueNode _GetMaxWeightNode(List<DialogueNode> nodes)
        {
            int maxWeight = Int32.MinValue;
            DialogueNode dialogueNode = null;
            foreach (var node in nodes)
            {
                if (node.keyConfig.TalkWeight > maxWeight)
                {
                    dialogueNode = node;
                    maxWeight = node.keyConfig.TalkWeight;
                }
            }
            return dialogueNode;
        }
        
        /// <summary>
        /// 判断一个key是否达到重复播放的时间
        /// </summary>
        /// <param name="key"></param>
        /// <param name="time"></param>
        /// <returns></returns>
        private bool _IsCanAgainPlay(string key, float time)
        {
            if (_dialoguePlayTimeDic.TryGetValue(key, out float nodeTime))
            {
                return battle.time - nodeTime >= time;
            }
            return true;
        }

        /// <summary>
        /// 根据key通过概率选择一个沟通配置
        /// </summary>
        /// <param name="key"></param>
        /// <param name="scoreIdBoy"></param>
        /// <returns></returns>
        private DialogueConfig _GetDialogueConfig(string key,int scoreIdBoy,int scoredIdGirl)
        {
            int maxRandom = 0;
            using (ProfilerDefine.GetDialogueByKey.Auto())
            {
                _cachedDialogueDic.Clear();
                var girl = battle.actorMgr.girl;
                if (_dialogueConfigDic.TryGetValue(key, out var dialogueConfigs))
                {
                    foreach (var config in dialogueConfigs)
                    {
                        if (config.RandomRate <= 0)
                        {
                            continue;
                        }
                        //优先判断状态
                        if (config.BattleState != 0 && config.BattleState != (int)_battleState)
                        {
                            continue;
                        }
                        //女主武器判断
                        if (girl?.weapon != null)
                        {
                            if (config.WeaponType == 1 && girl.weapon.weaponLogicCfg.LockRangeType != (int)LockRangeType.Melee
                                || config.WeaponType == 2 && girl.weapon.weaponLogicCfg.LockRangeType != (int)LockRangeType.Remote)
                            {
                                continue;
                            }
                        }
                        foreach (var scoreId in config.ScoreIDs)
                        {
                            if (scoreId == scoreIdBoy || scoreId == scoredIdGirl)
                            {
                                maxRandom += config.RandomRate;
                                _cachedDialogueDic.Add(maxRandom, config);
                            }
                        }
                    }
                }
            }
            if (_cachedDialogueDic.Count <= 0)
            {
                return null;
            }
            using (ProfilerDefine.GetDialogueByKeyRange.Auto())
            {
                int range = Random.Range(0, maxRandom);

                foreach (var info in _cachedDialogueDic)
                {
                    if (range <= info.Key)
                    {
                        return info.Value;
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// 获取keyconfig
        /// </summary>
        /// <param name="key"></param>
        /// <param name="scoreIdBoy"></param>
        /// <param name="scoredIdGirl"></param>
        /// <returns></returns>
        private DialogueKeyConfig _GetDialogueKeyConfig(string key,int scoreIdBoy,int scoredIdGirl)
        {
            using (ProfilerDefine.GetDialogueByKeyConfig.Auto())
            {
                foreach (var configItem in TbUtil.dialogueKeyConfigs)
                {
                    DialogueKeyConfig dialogueKeyConfig = configItem.Value;
                    if (dialogueKeyConfig.Key != key)
                    {
                        continue;
                    }
                    foreach (var scoreID in dialogueKeyConfig.ScoreIDs)
                    {
                        if (scoreID == scoreIdBoy || scoreID == scoredIdGirl)
                        {
                            return dialogueKeyConfig;
                        }
                    }
                }
            }
            
            return null;
        }
    }
}