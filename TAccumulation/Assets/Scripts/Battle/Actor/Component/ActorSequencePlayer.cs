using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class ActorSequencePlayer : ActorComponent
    {
        private BSMgr _bsMgr;
        private Dictionary<object, HashSet<BattleSequencer>> _timelineDict;
        private BSActionContext _actorContext;

        private Dictionary<int, BattleSequencer> _cacheFlowTimelines;
        private Dictionary<string, BattleSequencer> _cacheBornTimelines;
        private Dictionary<int, BattleSequencer> _cacheBornFlowTimelines;
        private Dictionary<string, BattleSequencer> _cachePPVSequencers;

        public ActorSequencePlayer() : base(ActorComponentType.SequencePlayer)
        {
            _bsMgr = new BSMgr();
            _timelineDict = new Dictionary<object, HashSet<BattleSequencer>>();
            _cacheFlowTimelines = new Dictionary<int, BattleSequencer>();
            _cacheBornTimelines = new Dictionary<string, BattleSequencer>();
            _cacheBornFlowTimelines = new Dictionary<int, BattleSequencer>();
            _cachePPVSequencers = new Dictionary<string, BattleSequencer>();
            _bsMgr.OnBSDestroy += OnBsDestroy;
            requiredPhysicalJobRunning = true;
        }

        // 给编辑器提供的接口，刷一下蓝图和Anim
        public void RefreshFlowActionModule(int actionModuleID)
        {
            _cacheFlowTimelines.TryGetValue(actionModuleID, out var timeline);
            if (timeline != null)
            {
                timeline.Destroy();
                _cacheFlowTimelines.Remove(actionModuleID);
            }
            CreateFlowCanvasModule(actionModuleID);
        }
        
        public override void OnRecycle()
        {
            foreach (var iter in _timelineDict)
            {
                foreach (var timeline in iter.Value)
                {
                    if (timeline.bsState == BSState.Playing)
                    {
                        timeline.Stop();
                    }
                }
            }   
        }

        protected override void OnDestroy()
        {
            _bsMgr.Destroy();
        }

        private void _EnsureActorContext()
        {
            if (_actorContext == null)
            {
                _actorContext = new BSActionContext(this.actor);
            }
        }

        private void OnBsDestroy(BattleSequencer battleSequencer)
        {
            foreach (var iter in _timelineDict)
            {
                if (iter.Value.Contains(battleSequencer))
                {
                    iter.Value.Remove(battleSequencer);
                    return;
                }
            }
        }

        // 创建PPV效果
        // TODO 后面所有接口都需要统一成这种GetOrCreate的形式
        public BattleSequencer EnsurePPVSequencer(string artPath)
        {
            _cachePPVSequencers.TryGetValue(artPath, out var sequencer);
            if (sequencer == null)
            {
                sequencer = _Create(artPath, bsType: BSType.BattlePPV, isManual: true);
                _cachePPVSequencers[artPath] = sequencer;
            }
            return sequencer;
        }

        // 播放AnimatorTimeline（由外部持有手动驱动）
        public BattleSequencer PlayAnimatorTimeline(int actionModuleID, TimelineMotion motion)
        {
            PapeGames.X3.LogProxy.LogFormat("动画模块播放动作模组：{0}", actionModuleID);
            var moduleCfg = TbUtil.GetCfg<ActionModuleCfg>(actionModuleID);
            if (!_CheckActionModuleCfgVaild(moduleCfg))
            {
                PapeGames.X3.LogProxy.LogWarningFormat("联系【卡宝宝】，技能动作模组播放失败，ID={0}，配置不存在或数据异常！", actionModuleID);
                return null;
            }

            var timeline = _Create(moduleCfg.ArtTimeline, owner: motion, bsType: BSType.BattleAnimator, logicAssetPath: moduleCfg.LogicTimelineAsset, isManual: true, _defaultDuration:moduleCfg.defaultDuration, blackboardData:moduleCfg.blackboardData);
            timeline.SetRepeat(true);
            return timeline;
        }

        // 播放技能timeline
        public BattleSequencer CreateSkillTimeline(SkillActive skill, BSActionContext context, int actionModuleID, float speed)
        {
            PapeGames.X3.LogProxy.LogFormat("技能模块播放动作模组：{0}", actionModuleID);
            var moduleCfg = TbUtil.GetCfg<ActionModuleCfg>(actionModuleID);
            if (!_CheckActionModuleCfgVaild(moduleCfg))
            {
                PapeGames.X3.LogProxy.LogErrorFormat("联系【卡宝宝】，{0} 技能 {1}动作模组播放失败，ID={2}，配置不存在或数据异常！", actor.name, skill.config.ID, actionModuleID);
                return null;
            }
            else
            {
                PapeGames.X3.LogProxy.LogFormat("{0} 技能 {1} 播放动作模组 {2}！", actor.name, skill.config.ID, actionModuleID);
            }

            var timeline = _Create(moduleCfg.ArtTimeline, null, speed, skill, context, logicAssetPath: moduleCfg.LogicTimelineAsset, bsType: BSType.BattleSkill, _defaultDuration:moduleCfg.defaultDuration, blackboardData:moduleCfg.blackboardData);
            return timeline;
        }

        // 检测一下ActionModuleCfg是否正确
        private bool _CheckActionModuleCfgVaild(ActionModuleCfg moduleCfg)
        {
            if (moduleCfg == null)
            {
                return false;
            }

            if (string.IsNullOrEmpty(moduleCfg.ArtTimeline) && string.IsNullOrEmpty(moduleCfg.LogicTimelineAsset))
            {
                return false;
            }

            return true;
        }

        // 播放怪物出生timeline
        public void CreateBornTimeline(string relativePath)
        {
            _cacheBornTimelines.TryGetValue(relativePath, out var timeline);
            if (timeline == null)
            {
                timeline = _Create(relativePath);
                // timeline.StopPlay();
                _cacheBornTimelines.Add(relativePath, timeline);
            }
        }

        public void PlayBornTimeline(string relativePath, System.Action onStop = null)
        {
            PapeGames.X3.LogProxy.LogFormat("人物状态机模块播放动作模组：{0}", relativePath);
            _cacheBornTimelines.TryGetValue(relativePath, out var timeline);
            if (timeline != null)
            {
                timeline.onStopCall = onStop;
                timeline.Play();
            }
            else
            {
                LogProxy.LogError("没有提前创建，播放失败！");
                onStop?.Invoke();
            }
        }

        // 蓝图播放timeline
        public void CreateFlowCanvasModule(int actionModuleID, bool notBindCreator = false)
        {
            _cacheFlowTimelines.TryGetValue(actionModuleID, out var timeline);
            if (timeline == null)
            {
                var moduleCfg = TbUtil.GetCfg<ActionModuleCfg>(actionModuleID);
                if (!_CheckActionModuleCfgVaild(moduleCfg))
                {
                    LogProxy.LogErrorFormat("联系【清心】，{0} 蓝图动作模组播放失败，ID={1}，配置不存在或数据异常！", actor.name, actionModuleID);
                    return;
                }
                else
                {
                    LogProxy.LogFormat("{0} 蓝图播放动作模组 {1}！", actor.name, actionModuleID);
                }
                timeline = _Create(moduleCfg.ArtTimeline, null, logicAssetPath: moduleCfg.LogicTimelineAsset, notBindCreator: notBindCreator, _defaultDuration:moduleCfg.defaultDuration, blackboardData:moduleCfg.blackboardData);
                _cacheFlowTimelines.Add(actionModuleID, timeline);
            }
        }

        public void PlayFlowCanvasModule(int actionModuleID, Action onStop = null)
        {
            LogProxy.LogFormat("人物蓝图模块播放动作模组：{0}", actionModuleID);
            _cacheFlowTimelines.TryGetValue(actionModuleID, out var timeline);
            if (timeline != null)
            {
                timeline.onStopCall = onStop;
                timeline.Play();
            }
            else
            {
                LogProxy.LogError("没有提前创建，播放失败！");
                onStop?.Invoke();
            }
        }

        // 暂停/恢复蓝图动作模组
        public void PauseFlowCanvasModule(int actionModuleID, bool isPausing)
        {
            LogProxy.LogFormat("人物蓝图模块播放动作模组：{0} {1}", actionModuleID, isPausing);
            _cacheFlowTimelines.TryGetValue(actionModuleID, out var timeline);
            if (timeline != null)
            {
                if (isPausing)
                {
                    timeline.Pause();
                }
                else
                {
                    timeline.Resume();
                }
            }
        }


        // 用于FSM人物出生时播放动作模组
        public void CreateBornFlowCanvasModule(int actionModuleID, bool bIsPreload = false)
        {
            _cacheBornFlowTimelines.TryGetValue(actionModuleID, out var timeline);
            if (timeline == null)
            {
                var moduleCfg = TbUtil.GetCfg<ActionModuleCfg>(actionModuleID);
                if (!_CheckActionModuleCfgVaild(moduleCfg))
                {
                    LogProxy.LogErrorFormat("联系【五当】，{0} 出生动作模组播放失败，ID={1}，配置不存在或数据异常！", actor.name, actionModuleID);
                    return;
                }
                else
                {
                    LogProxy.LogFormat("{0} 出生播放动作模组 {1}！", actor.name, actionModuleID);
                }

                float startTime = bIsPreload ? -1f : 0f;
                timeline = _Create(moduleCfg.ArtTimeline, null, logicAssetPath: moduleCfg.LogicTimelineAsset, bsType: BSType.BattleBornPerformCamera, _defaultDuration:moduleCfg.defaultDuration, blackboardData:moduleCfg.blackboardData);
                _cacheBornFlowTimelines.Add(actionModuleID, timeline);
            }
        }

        public void PlayBornFlowCanvasModule(int actionModuleID, bool enableCamera, Action onStop = null)
        {
            LogProxy.LogFormat("人物状态机模块播放动作模组：{0}", actionModuleID);
            _cacheBornFlowTimelines.TryGetValue(actionModuleID, out var timeline);
            if (timeline != null)
            {
                timeline.onStopCall = onStop;
                timeline.GetComponent<BSCControlCamera>()?.SetCameraGroupEnable(enableCamera);
                timeline.Play();
            }
            else
            {
                LogProxy.LogError("没有提前创建，播放失败！");
                onStop?.Invoke();
            }
        }

        public void StopBornFlowCanvasModule(int actionModuleID)
        {
            LogProxy.LogFormat("人物状态机模块暂停动作模组：{0}", actionModuleID);
            _cacheBornFlowTimelines.TryGetValue(actionModuleID, out var timeline);
            if (timeline == null)
                return;
            timeline.onStopCall = null;
            timeline.Stop();
        }

        /// <summary>
        /// 让角色播放timeline
        /// </summary>
        /// <param name="relativePath">资源路径</param>
        /// <param name="onStop">结束回调</param>
        /// <param name="timesScale">基于Actor的时间缩放</param>
        /// <param name="owner">不填则是属于self的timeline</param>
        /// <param name="bsActionPreviewActionIContexton依赖的context，比如skill或者buff对象, 如果不传，则默认为Actor</param>
        private BattleSequencer _Create(string relativePath, System.Action onStop = null, float timesScale = 1f, object owner = null, BSActionContext bsActionContext = null, BSType bsType = BSType.BattleActor, string logicAssetPath = null, bool isManual = false, bool notBindCreator = false, float _defaultDuration = 0, string blackboardData = null)
        {
            using (ProfilerDefine.ActorSequencePlayerCreatePMarker.Auto())
            {
                _EnsureActorContext();
                // 如果没有逻辑的时长，尝试取default
                float? defaultDuration = null;
                if (string.IsNullOrEmpty(logicAssetPath) && _defaultDuration > 0)
                {
                    defaultDuration = _defaultDuration;
                }

                var createData = new BSCreateData()
                {
                    artResPath = relativePath,
                    logicAssetPath = logicAssetPath,
                    blackboardData = blackboardData,
                    creatorActor = actor,
                    creatorModel = actor.GetDummy(ActorDummyType.Model).gameObject,
                    timesScale = timesScale,
                    bsActionContext = bsActionContext ?? _actorContext,
                    isManual = isManual,
                    notBindCreator = notBindCreator,
                    defaultDuration = defaultDuration,
                };

                // DONE: 替换timeline路径
                if (actor.bornCfg != null)
                {
                    int skinID = actor.bornCfg.SkinID;
                    if (bsActionContext?.skill != null)
                    {
                        int skillCfgID = bsActionContext.skill.GetCfgID();
                        int? slotID = BattleUtil.GetSlotIDBySkillID(actor, skillCfgID);
                        if (slotID != null)
                        {
                            skinID = BattleUtil.GetSkinIDBySlotID(actor, slotID.Value);
                        }
                    }

                    relativePath = BattleUtil.GetPathBySkinID(skinID, BattleResType.Timeline, relativePath);
                    createData.artResPath = relativePath;
                }

                var timeline = this._bsMgr.CreateBS(bsType, createData);
                var timelines = _GetOwnerTimelines(owner ?? this);
                timelines.Add(timeline);
                timeline.onStopCall = onStop;

                return timeline;
            }
        }

        // 通过owner获取timeline列表
        private HashSet<BattleSequencer> _GetOwnerTimelines(object owner)
        {
            _timelineDict.TryGetValue(owner, out var list);
            if (list == null)
            {
                list = new HashSet<BattleSequencer>();
                _timelineDict[owner] = list;
            }

            return list;
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            var deltaTime = actor.deltaTime;
            _bsMgr.Update(deltaTime);
        }

        protected override void OnPhysicalJobRunning()
        {
            _bsMgr.LateUpdate();
        }
    }
}
