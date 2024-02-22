using System;
using System.Collections.Generic;
using PapeGames;
using PapeGames.X3;
using X3Battle.Timeline;

namespace X3Battle
{
    public class SkillTimeline:SkillActive
    {
        private BSActionContext _bsActionContext;
        
        private Dictionary<int, List<BattleSequencer>> _timelineDict;
        //由词条库新增的动作模组 创建的时机在人物出生后
        private List<BattleSequencer> _addSequencers;
        private BattleSequencer _curBattleSequencer;
        public BattleSequencer curBattleSequencer => _curBattleSequencer;
        private bool _isComplete;
        private Action _timelineStopCall;
        private const int DEFAULT_COUNT = 1;  // 默认创建的数量
        private const int MULTIPLE_COUNT = 2;  // 释放段数大于0，或者没有CD创建的数量

        public SkillTimeline(Actor _actor, DamageExporter _damageExporter, SkillCfg _skillConfig, SkillLevelCfg _levelConfig, int level, SkillSlotType skillSlotType) : base(_actor, _damageExporter, _skillConfig, _levelConfig, level, skillSlotType)
        {
            _addSequencers = new List<BattleSequencer>();
            _bsActionContext = new BSActionContext(this);
            _timelineStopCall = _OnTimelineStop;
            _CreateTimelines(ActionModuleType.Default);
            actor.battle.eventMgr.AddListener<EventActorChangeParts>(EventType.ActorChangeParts, _OnActorChangeParts, "SkillTimeline._OnActorChangeParts");
        }

        public override void Destroy()
        {
            // 注意销毁顺序
            _DeleteTimelines();
            actor.battle.eventMgr.RemoveListener<EventActorChangeParts>(EventType.ActorChangeParts, _OnActorChangeParts);
            base.Destroy();
        }

        // 释放技能
        protected override void OnCast()
        {
            // 注意基类函数顺序
            base.OnCast();
            _isComplete = false;
            var moduleIdx = _GetCastModuleIndex();
            SwitchActionModule(moduleIdx);
            PlayAddModule();
        }
        
        /// <summary>
        /// 爆衣援护切换技能
        /// </summary>
        private void _OnActorChangeParts(EventActorChangeParts arg)
        {
            if (!arg.isBrokenSuit)
            {
                return;
            }
            
            //判断如果不是自身不触发切换技能
            if (actor != arg.actor)
            {
                return;
            }
            
            if (config.BrokenShirtActionModuleIDs == null || config.BrokenShirtActionModuleIDs.Length <= 0)
            {
                return;
            }
            
            //当前正在播放的timelin 不切换
            if (_curBattleSequencer != null && _curBattleSequencer.bsState == BSState.Playing)
            {
                if (GetSkillType() == SkillType.Support)
                {
                    return;
                }
                
                var skillid = this.GetCfgID();
                string modules = "";
                foreach (var module in config.ActionModuleIDs)
                {
                    modules += module + "+";
                }
                LogProxy.LogError("爆衣切换技能出错： 当前正在播放的技能不能切换(请找卡宝宝) actor name = " + actor.name + " _curBattleSequencer.name = " + _curBattleSequencer.name +  " cur module iD = " + modules
                + " skillid = " + skillid);
                return;
            }

            //清除当前timeline
            _DeleteTimelines();

            // 爆衣后的动作模组如果有配置，则卸载爆衣前的动作模组
            bool isHaveBroken = config.BrokenShirtActionModuleIDs != null &&
                                config.BrokenShirtActionModuleIDs.Length > 0;
            if (config.ActionModuleIDs != null && isHaveBroken)
            {
                BattleResMgr.Instance.UnloadUnusedTagRes(BattleResTag.BeforeBrokenShirt, true, true);
            }
            
            //创建爆衣援护切换动作模组 有GC 但是此刻处于白屏阶段 所以可以不管
            _CreateTimelines(ActionModuleType.BrokenShirt);
        }
        // 获取释放时取哪个timeline
        private int _GetCastModuleIndex()
        {
            // 闪避技能，并且是主控，并且没有输入，尝试使用第二个动作模组
            if (config.Type == SkillType.Dodge)
            {
                LogProxy.Log("此技能是闪避类型");
                if (actor.IsPlayer())
                {
                    LogProxy.Log("此技能释放者是主角");
                    if (!actor.HasDirInput())
                    {
                        LogProxy.Log("此技能主角没有方向输入");
                        if (_timelineDict.Count > 1)
                        {
                            LogProxy.Log("此技能将使用第2个动作模组");
                            return 1;
                        } 
                    }
                    else
                    {
                        LogProxy.Log("此技能主角有方向输入");
                    }
                }
            }
            
            // 普通情况都播放的都是第一个
            LogProxy.Log("此技能将使用第1个动作模组");
            return 0;
        }

        /// <summary>
        /// 播放新增动作模组
        /// </summary>
        public void PlayAddModule()
        {
            foreach (var addSequencer in _addSequencers)
            {
                addSequencer.Play();
            }
        }
        // 清除动作模组中残留的特效
        public override void ClearRemainFX()
        {
            base.ClearRemainFX();
            if (_timelineDict != null && _timelineDict.Count > 0)
            {
                foreach (var iter in _timelineDict)
                {
                    var list = iter.Value;
                    for (int i = 0; i < list.Count; i++)
                    {
                        var timeline = list[i];    
                        if (timeline != _curBattleSequencer && timeline.bsState == BSState.Playing)
                        {
                            timeline.Stop();   
                        }
                    }
                }
            }

            foreach (var addSequencer in _addSequencers)
            {
                if (addSequencer != _curBattleSequencer && addSequencer.bsState == BSState.Playing)
                {
                    addSequencer.Stop();   
                }
            }
        }

        // 停止技能
        protected override void OnStop(SkillEndType skillEndType)
        {
            // 注意基类函数顺序
            if (_isComplete)
            {
                // 如果timeline逻辑部分已经完整播完，尝试停止timeline（不一定停止，看是否独立播放）
                _DetachCurTimeline();
            }
            else
            {
                // 如果timeline逻辑部分没有完整播完，直接打断timeline
                _InterruptCurTimeline();
            }
            
            // TODO 策划定的临时方案：策划君儒渐渐为了解决强设位置出墙bug，让程序临时obt解决，后面策划单独出设计
            // 男主共鸣技结束如果在墙外，强行拉到女主位置
            if (config.Type == SkillType.Coop && actor.IsBoy())
            {
                var girl = actor.battle.actorMgr.girl;
                if (girl != null)
                {
                    var girlPos = girl.transform.position;
                    // 在寻路范围内，并且没有碰到空气墙
                    var notCollideAirWall = BattleUtil.IsRightPoint(actor.transform.position, girlPos);
                    if (!notCollideAirWall)
                    {
                        actor.transform.SetPosition(girlPos, true);
                    }
                }
            }
            
            //停止新增的动作模组
            foreach (var addSequencer in _addSequencers)
            {
                addSequencer.Stop();
            }
            
            base.OnStop(skillEndType);
        }

        // 切换动作模组
        public void SwitchActionModule(int idx)
        {
            // 安全性检查
            if (_timelineDict == null || _timelineDict.Count <= idx)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("联系【卡宝】，技能 {0} 动作模组下标，对应的动作模组不存在！技能异常直接结束。", config.Name);
                _OnTimelineStop();
            }
            else
            {
                // 打断当前动作模组
                _InterruptCurTimeline();
                // 播放新动作模组
                BattleSequencer newBattleSequencer = null;  // 默认取第一个
                var timelines = _timelineDict[idx];
                for (int i = 0; i < timelines.Count; i++)
                {
                    var timeline = timelines[i];
                    if (timeline.bsState != BSState.Playing)
                    {
                        newBattleSequencer = timeline;  // 优先取没有处于播放中的
                        break;
                    }
                }

                if (newBattleSequencer == null)
                {
                    // 没取到，保底第一个
                    newBattleSequencer = timelines[0];
                }
                
                _curBattleSequencer = newBattleSequencer;
                if (_curBattleSequencer.bsState == BSState.Playing)
                {
                    // 如果目标动作模组还在播放中，先拉回去再从0开始播
                   //  _curBattleSequencer.SetTime(-BattleConst.FrameTime);   
                   // _curBattleSequencer.Evaluate(true);  // 因为PlayerDirector的机制，playable过来的这次可能不会触发TimelinePlayable.prepareFrame
                    _curBattleSequencer.Stop();
                }
                _curBattleSequencer.onStopCall = _timelineStopCall;
                var speed = GetPlaySpeed();
                _curBattleSequencer.SetTimeScale(speed);
                
                // 处理相机逻辑
                bool? enableBornCamera = null;
                if (slotType == SkillSlotType.Born)
                {
                    enableBornCamera = this.actor.bornCfg.ControlBornPerform;
                }
                if (enableBornCamera != null)
                {
                    _curBattleSequencer.GetComponent<BSCControlCamera>().SetCameraGroupEnable(enableBornCamera.Value);        
                }
                // 播放
                _curBattleSequencer.Play();
            }
        }

        // timeline播放到stop阶段的回调
        protected virtual void _OnTimelineStop()
        {
            _isComplete = true;
            actor.skillOwner.TryEndSkill(SkillEndType.Complete);
        }

        /// <summary>
        /// 是否已经创建了增加的动作模组
        /// </summary>
        public bool IsCreateAddSequence()
        {
            if (_addSequencers != null && _addSequencers.Count > 0)
            {
                return true;
            }

            return false;
        }
        
        //创建增加的动作模组
        public void CreateAddSequences(int id)
        {
            var timeline = actor.sequencePlayer.CreateSkillTimeline(this, _bsActionContext, id, GetPlaySpeed());
            _addSequencers.Add(timeline);
        }
            
        // 初始化时创建timeline
        private void _CreateTimelines(ActionModuleType type)
        {
            int[] ids = null;
            switch (type)
            {
                case ActionModuleType.Default:
                    ids = config.ActionModuleIDs;
                    break;
                case ActionModuleType.BrokenShirt:
                    ids = config.BrokenShirtActionModuleIDs;
                    break;
            }

            if (ids == null || ids.Length <= 0)
            {
                return;
            }
            
            // 和策划沟通后暂定规则：女主的闪避技创建2份，用于连续释放出残留效果，别的技能创建1份节省内存
            var needMultipleCount = actor.IsGirl() && config.Type == SkillType.Dodge;
            var timelineNum = DEFAULT_COUNT;
            if (needMultipleCount)
            {
                timelineNum = MULTIPLE_COUNT;
            }
            
            _timelineDict = new Dictionary<int, List<BattleSequencer>>();
            for (int i = 0; i < ids.Length; i++)
            {
                var actionModuleID = ids[i];
                var timelineList = new List<BattleSequencer>();
                for (int j = 0; j < timelineNum; j++)
                {
                    var timeline = actor.sequencePlayer.CreateSkillTimeline(this, _bsActionContext, actionModuleID, GetPlaySpeed());
                    timelineList.Add(timeline);
                }
                
                _timelineDict.Add(i, timelineList);
            }
        }

        
        // 技能销毁时删除所有的timeline
        private void _DeleteTimelines()
        {
            if (_timelineDict != null)
            {
                foreach (var iter in _timelineDict)
                {
                    var list = iter.Value;
                    if (list != null)
                    {
                        for (int i = 0; i < list.Count; i++)
                        {
                            var item = list[i];
                            item?.Destroy();   
                        }   
                    }
                }
                _timelineDict = null;
            }
            _curBattleSequencer = null;

            if (_addSequencers != null)
            {
                foreach (var iter in _addSequencers)
                {
                    iter?.Destroy();
                }
                _addSequencers = null;
            }
        }
        
        // 如果完整播放，与当前正在播的timeline分离
        private void _DetachCurTimeline()
        {
            // 暂停当前的
            if (_curBattleSequencer != null)
            {
                _curBattleSequencer.onStopCall = null;
                _curBattleSequencer.SpecialEnd();
                _curBattleSequencer = null;
            }   
        }
        
        // 如果没有完整播放，就走打断逻辑，打断当前timeline (不一定结束，取决于内部是否有独立轨道)
        private void _InterruptCurTimeline()
        {
            if (_curBattleSequencer != null)
            {
                _curBattleSequencer.onStopCall = null;
                _curBattleSequencer.Interrupt();
                _curBattleSequencer = null;
            }
        }
    }
}