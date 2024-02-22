using System;
using System.Collections.Generic;
using PapeGames;
using PapeGames.X3;
using Unity.Profiling;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.Timeline;
using X3;
using X3.Character;
using X3Sequence;
using Action = System.Action;

namespace X3Battle
{
    public class BattleSequencer
    {
        private readonly List<BSCBase> _features = new List<BSCBase>(8);  // feature列表用于遍历
        private readonly Dictionary<Type, BSCBase> _featureDict = new Dictionary<Type, BSCBase>();  // feature列表用于查询
        public BSState bsState { get; private set; } // timeline状态
        private BSContext _context;  // 环境
        private BSMgr _mgr;  // 所有者
        private int _suspendFrameCount;  // 悬停帧
        private VisiblePoolItem _poolItem; 
        public string name { get; set; } // asset资源名字
        private ComplexPlayableInstance _complexPlayableIns;  // 额外的playableInstance
        public bool isPlayIndividually { get; set; } // 是否独立结束
        public float? logicDuration { get; set; } // 逻辑timeline时长
        public float artDuration { get; set; } // 总时长，总是会大于等于tiemline时长
        public Action onStopCall { set; get; } // 逻辑播放完成回调
        private bool isTimeEnd { get; set; } // 是否已经播放完毕
        private float _cacheTime = -1;  // 播放时辅助计算字段
        public UnityEngine.Timeline.TimelinePlayable artTimelinePlayable { get; private set; }

        private ProfilerMarker _evaluateDebugName;
        private ProfilerMarker _updateDebugName;
        private ProfilerMarker _lateUpdateDebugName;
        private ProfilerMarker _playDebugName;
        private ProfilerMarker _stopDebugName;
        private ProfilerMarker _interruptDebugName;
        private ProfilerMarker _logicEndDebugName;
        public X3Sequence.Sequencer logicSequencer { get; private set; }  // 逻辑timeline的Sequencer
        public X3Sequence.Sequencer artSequencer { get; private set; }  // 美术timeline的Sequencer
        public BSCreateData bsCreateData { get; private set; }  // 创建参数
        private bool _isPaused;  // 是否处于暂停状态
        private bool _finishHold;  // 播完自动处于hold状态
        public BSType bsType { get; private set; }

        private void _Reset()
        {
            _features.Clear();
            _featureDict.Clear();
            artTimelinePlayable = null;
            bsState = BSState.Destroy;
            _context = null;
            _mgr = null;
            name = null;
            _complexPlayableIns = null;
            isPlayIndividually = false;
            logicDuration = null;
            artDuration = 0;
            onStopCall = null;
            isTimeEnd = false;
            _cacheTime = -1;
            _suspendFrameCount = 0;
            _poolItem = null;
            logicSequencer = null;
            artSequencer = null;
            _finishHold = false;
        }

        public T GetComponent<T>() where T: BSCBase
        {
            var type = typeof(T);
            _featureDict.TryGetValue(type, out var baseCom);
            var com = baseCom as T;
            return com;
        }

        public void Init(BSMgr owner, BSType bsType, BSContext context, BSCreateData data)
        {
            this._mgr = owner;
            this._context = context;
            this.bsCreateData = data;
            this.bsState = BSState.Created;
            this.bsType = bsType;

            var featureTypes = BSTypeUtil.BSType2Features[bsType];
            for (int i = 0; i < featureTypes.Length; i++)
            {
                var featureType = featureTypes[i];
                var feature = BSTypeUtil.CreateFeature(featureType);
                _features.Add(feature);
                _featureDict.Add(feature.GetType(), feature);

                // 需要在其他组件Init之前设置该变量.
                if (feature is BSCTrackBind trackBindCom)
                {
                    trackBindCom.notBindCreator = this.bsCreateData.notBindCreator;
                }
            }
            
            // 初始化
            for (int i = 0; i < _features.Count; i++)
            {
                var com = _features[i];
                com.Init(this, context);
            }

            SetTimeScale(bsCreateData.timesScale);
            SetManual(bsCreateData.isManual);

            // 构建逻辑
            _Build();
            // 构建Unity Playable
            SetTime(-BattleConst.FrameTime);
            _BuildUnityPlayable();
            Stop();
        }
        
        public void AddPlayableIns(IPlayableInsInterface playableIns)
        {
            {
                if (this._complexPlayableIns == null)
                {
                    this._complexPlayableIns = ObjectPoolUtility.ComplexPlayableInstance.Get();
                }

                this._complexPlayableIns.AddPlayableIns(playableIns);
            }
        }

        public void EnableLogicSquenceTrack(bool enable, List<int> tags)
        {
            if (logicSequencer == null)
            {
                return;
            }
            
            foreach (var track in logicSequencer.tracks)
            {
                if (track is BattleActionTrack battleActionTrack)
                {
                    battleActionTrack.EnableTrack(enable, tags);
                }
            }
        }
        
        // 设置时间缩放
        //-@param scale float 缩放比例
        //-@param duration float 持续时间，null一直持续
        public void SetTimeScale(float scale, float? duration = null)
        {
            GetComponent<BSCClock>()?.SetScale(scale, duration);
        }

        //设置时间
        //-@param time float 当前时间
        public void SetTime(float time)
        {
            GetComponent<BSCClock>()?.SetPlayTime(time);
        }
        
        // 当前帧悬停，不影响Update
        private void _SuspendCurFrame()
        {
            _suspendFrameCount = Time.frameCount;
        }
        
        // 设置手动模式
        public void SetManual(bool isManual)
        {
            GetComponent<BSCClock>()?.SetManual(isManual);
        }

        // 获取时间
        //-@param float
        public float GetTime()
        {
            return GetComponent<BSCClock>().GetPlayTime();
        }

        // 设置循环播放
        //-@param isRepeat boolean 是否循环播放
        public void SetRepeat(bool isRepeat)
        {
            GetComponent<BSCClock>()?.SetRepeat(isRepeat);
        }

        // 外部接口
        // 构建
        private void _Build()
        {
            if (this.bsState != BSState.Created)
            {
                return;
            }
            this.bsState = BSState.Builded;
            var sharedVariables = new BSSharedVariables(bsCreateData);

            var logicAssetName = GetComponent<BSCRes>().logicAsset?.name;
            logicSequencer = new X3Sequence.Sequencer(logicAssetName ?? name, sharedVariables);
            artSequencer = new X3Sequence.Sequencer(name);

            // 检查基本资源是否正确，顺便设置一些属性
            var result = this.__SetAndCheckAssetValid();
            if (!result)
            {
                LogProxy.LogError("timeline 资源有问题构建失败，详细情况看前面日志！");
                this.Destroy();
                return;
            }

            _InitRecorderRes();

            // 主要是绑定轨道逻辑
            for (int i = 0; i < _features.Count; i++)
            {
                var feature = _features[i];
                feature.Build();
            }
        }

        // 初始化recorder资源
        private void _InitRecorderRes()
        {
            var resCom = GetComponent<BSCRes>();
            if (resCom.artTimelineExtInfo == null)
            {
                return;
            }

            var recorder = resCom.artTimelineExtInfo.resRecorder;
            for (int i = 0; i < recorder.trackRes.Count; i++)
            {
                var key = recorder.keys[i];
                var resItem = recorder.trackRes[i];
                if (resItem.resType == TrackResItem.TrackResType.Avatar)
                {
                    var avatarData = resItem.avatarData;
                    var ins = _context.LoadSuitObject(avatarData.suit);
                    if (ins)
                    {
                        ins.name = key;
                        avatarData.instance = ins;
                        var com = ins.GetComponent<X3Character>();
                        if (com != null && avatarData.material)
                        {
                            com.SetToClone(avatarData.material); 
                        }
                    }
                }
            }
        }

        // 卸载recorder资源
        private void _UnInitRecorderRes()
        {
            var resCom = GetComponent<BSCRes>();
            if (resCom.artTimelineExtInfo == null)
            {
                return;
            }
            var recorder = resCom.artTimelineExtInfo.resRecorder;
            for (int i = 0; i < recorder.trackRes.Count; i++)
            {
                var resItem = recorder.trackRes[i];
                if (resItem.resType == TrackResItem.TrackResType.Avatar)
                {
                    var avatarData = resItem.avatarData;
                    if (avatarData.instance)
                    {
                        _context.UnLoadSuitObject(avatarData.instance);
                        avatarData.instance = null;
                    }
                }
            }
        }
        
        // 获取recorder资源
        public GameObject GetRecordObject(string key)
        {
            var resCom = GetComponent<BSCRes>();
            var obj =  resCom.artTimelineExtInfo.resRecorder.GetResObject(key);
            return obj;
        }

        // 设置并检测timeline基本资源是否ok
        private bool __SetAndCheckAssetValid()
        {
            var resCom = GetComponent<BSCRes>();
            var logicAsset = resCom.logicAsset;
            var artObject = resCom.artObject;
            var artAsset = resCom.artAsset;

            if (logicAsset == null && artObject == null)
            {
                LogProxy.LogError($"错误：Timeline {bsCreateData.logicAssetPath} 没有加载出对应的Asset资源！并且 {bsCreateData.artResPath} 也没有加载出对应的GameObject!"); 
                return false;
            }
            
            if (artObject != null)
            {
                _poolItem = artObject.GetComponent<VisiblePoolItem>();
            }

            // 当没有逻辑资源时，或者有美术资源时，需要检测美术资源的正确性
            if (logicAsset==null || artObject != null)
            {
                if (artObject == null)
                {
                    LogProxy.LogError($"错误：Timeline {bsCreateData.artResPath} 没有加载出对应的GameObject！"); 
                    return false;
                }
                
                if (resCom.artDirector == null)
                {
                    LogProxy.LogError($"错误：Timeline {name} 上没有PlayableDirector组件！");
                    return false;
                }
                
                if (resCom.artTimelineExtInfo == null)
                {
                    LogProxy.LogError($"错误：Timeline {name} 上没有artTimelineExtInfo组件！");
                    return false;
                }  
                
                if (artAsset == null)
                {
                    LogProxy.LogError($"错误：Timeline {name} 的PlayableDirector上没有指定playableAsset！");
                    return false;
                }
            }
            _evaluateDebugName = new ProfilerMarker($"BattleSequencer.Evaluate {name}");
            _updateDebugName = new ProfilerMarker($"BattleSequencer.Update {name}");
            _lateUpdateDebugName = new ProfilerMarker($"BattleSequencer.LateUpdate {name}");
            _playDebugName = new ProfilerMarker($"BattleSequencer.Play {name}");
            _stopDebugName = new ProfilerMarker($"BattleSequencer.Stop {name}");
            _interruptDebugName = new ProfilerMarker($"BattleSequencer.Interrupt {name}");
            _logicEndDebugName = new ProfilerMarker($"BattleSequencer.LogicEnd {name}");
            return true;
        }
        
        private void _BuildUnityPlayable()
        {
            if (this.bsState != BSState.Builded)
            {
                return;
            }

            this.bsState = BSState.Playing;
            
            var bindCom = GetComponent<BSCTrackBind>();
            bindCom?.RegisterControlCreator();
            _SuspendCurFrame();
            
            var clockCom = GetComponent<BSCClock>();
            var playTime = clockCom.GetPlayTime();
            var resCom = GetComponent<BSCRes>();
            var artAsset = resCom.artAsset;
            if (artAsset != null)
            {
                // 新增逻辑，解析timelineAsset，创建一些SequenceAction到Sequencer上
                BSCreateUtil.TryBuildTrackActions(artSequencer, resCom.artDirector, resCom.artAsset, bsCreateData.bsActionContext, this);
                
                // artAsset.OnCreatePlayable += _OnTimelinePlayableCreate;
                //resCom.artDirector.time = playTime;
                //resCom.artDirector.timeUpdateMode = DirectorUpdateMode.Manual;
                //resCom.artDirector.Play();
                //var timeScale = clockCom.GetScale();
                //X3TimelineUtility.SetSimpleAudioSpeed(artAsset, timeScale);
                //X3TimelineUtility.SetDirectorManualTime(resCom.artDirector, playTime, this._complexPlayableIns); 
                GetComponent<BSCControlCamera>()?.RecordInfo();
            }
            this._mgr.__OnBSPlay(this);
            bindCom?.UnRegisterControlCreator();
            
            logicSequencer.Start(playTime);
            artSequencer.Start(playTime);
        }

        private void _OnTimelinePlayableCreate(UnityEngine.Timeline.TimelinePlayable playable)
        {
            artTimelinePlayable = playable;
            var resCom = GetComponent<BSCRes>();
            var artAsset = resCom.artAsset;
            if (artAsset != null)
            {
                artAsset.OnCreatePlayable -= _OnTimelinePlayableCreate;
            }
        }
        
        // 更新
        public void Update(float deltaTime, bool force = false)
        {
            if (this.bsState != BSState.Playing || _isPaused)
            {
                return;
            }

            // 悬停帧判断
            if (_suspendFrameCount == Time.frameCount)
            {
                return;   
            }

            using (_updateDebugName.Auto())
            {
                // 自动模式这里给Evaluate，手动模式需要外部调用Evaluate
                // 如果强行更新则忽略是否手动，强行更
                var clockCom = GetComponent<BSCClock>();
                if (!clockCom.isManual || force)
                {
                    if (!this.isTimeEnd)
                    {
                        for (int i = 0; i < _features.Count; i++)
                        {
                            var feature = _features[i];
                            feature.Tick(deltaTime);
                        }

                        var isValid = true;
                        var playTime = clockCom.GetPlayTime();
                        if (_cacheTime != playTime)
                        {
                            // 自动模式下自动tick todo 长空 runID封装到内部
                            var oldRunID = logicSequencer.runID;
                            logicSequencer.SetTime(playTime, true);
                            if (oldRunID != logicSequencer.runID)
                            {
                                isValid = false;
                            }

                            if (isValid)
                            {
                                artSequencer.SetTime(playTime, true);
                            }
                        }

                        if (isValid)
                        {
                            Evaluate();
                        }
                    }
                }
            }
        }

        public void LateUpdate()
        {
            // 暂停判断
            if (bsState != BSState.Playing || _isPaused)
            {
                return;
            }

            using (_lateUpdateDebugName.Auto())
            {
                var isValid = true;

                if (logicSequencer != null)
                {
                    var cacheID = logicSequencer.runID;
                    logicSequencer.LateUpdate();
                    if (cacheID != logicSequencer.runID)
                    {
                        isValid = false;
                    }
                }

                if (isValid)
                {
                    artSequencer?.LateUpdate();
                }
            }
        }

        public void Evaluate(bool evaluateSequencer = false)
        {
            using (_evaluateDebugName.Auto())
            {
                var clockCom = GetComponent<BSCClock>();
                var playTime = clockCom.GetPlayTime();
                if (this._cacheTime != playTime)
                {
                    if (evaluateSequencer)
                    {
                        if (clockCom.isWholeRepeat && playTime < clockCom.oldPlayTime)
                        {
                            // 循环模式循环了一轮 
                            // 目前循环模式只有动画在用，
                            logicSequencer.Stop();
                            artSequencer.Stop();
                            logicSequencer.Start(playTime);
                            artSequencer.Start(playTime);
                        }
                        else
                        {
                            // 手动模式直接设置时间
                            logicSequencer.SetTime(playTime);
                            artSequencer.SetTime(playTime);
                            logicSequencer.Update(0);
                            artSequencer.Update(0);
                        }
                    }
                    // 每帧需要设置C#相关属性，集中调用
                    //var resCom = GetComponent<BSCRes>();
                    //if (resCom.artDirector != null)
                    //{
                        //X3TimelineUtility.SetDirectorManualTime(resCom.artDirector, playTime, this._complexPlayableIns);
                    //}
                }

                this._cacheTime = playTime;
                var newTimeEnd = playTime >= this.artDuration;
                if (newTimeEnd && !isTimeEnd)
                {
                    if (_finishHold)
                    {
                        // 结束自动hold，设一下状态，外部主动调用Stop
                        bsState = BSState.FinishHold;
                    }
                    else
                    {
                        // 结束不自动hold，自行stop
                        Stop();
                    }
                }
                this.isTimeEnd = newTimeEnd;
                if (this.isTimeEnd)
                {
                    this._TryInvokeStopCall();
                }
                else
                {
                    // 判断一下如果大于逻辑时间，直接回调出去
                    if (logicDuration != null && playTime >= logicDuration)
                    {
                        _TryInvokeStopCall();
                    }
                }   
            }
        }

        // 播放
        public void Play(bool finishHold = false)
        {
            using (_playDebugName.Auto())
            {
                _finishHold = finishHold;
                bsState = BSState.Playing;
                _isPaused = false;
                isTimeEnd = false;
                var resCom = GetComponent<BSCRes>();
                var artAsset = resCom?.artAsset;
                var logicAsset = resCom?.logicAsset;
                
                if (artAsset == null && logicAsset == null)
                {
                    LogProxy.LogErrorFormat("Timeline因为没有加载出资源{0}，播不出来，请对应策划检查配置！", bsCreateData.artResPath);
                    this.bsState = BSState.Stop;
                    _TryInvokeStopCall();
                    return;
                }
                if (_complexPlayableIns != null)
                {
                    _complexPlayableIns.SetPlayableWeight(1);   
                }

                VisiblePoolTool.EnablePoolItemBehavioursByItem(_poolItem, true);

                var skillCom = GetComponent<BSCSkill>();
                if (skillCom != null)
                {
                    skillCom.Replay();
                }

                var sceneEffectCom = GetComponent<BSCSceneEffect>();
                if (sceneEffectCom != null)
                {
                    sceneEffectCom.Replay();
                }
                
                var controlCameraCom = GetComponent<BSCControlCamera>();
                if (controlCameraCom != null)
                {
                    controlCameraCom.Replay();
                }
                
                artTimelinePlayable?.ResetInterruptInfo();

                // 先跑策划逻辑
                if (logicSequencer != null)
                {
                    logicSequencer.Stop(ExitType.Abnormal);
                    logicSequencer.Start(0, _finishHold);
                }

                if (logicSequencer != null && !logicSequencer.isRunning)
                {
                    return;
                }

                // 策划跑完第0帧，同步技能释放位置
                var contextSkill = bsCreateData?.bsActionContext?.skill;
                if (contextSkill != null)
                {
                    contextSkill.RefreshCastPosForward();
                }

                // 再同步timeline位置
                var trackBindCom = GetComponent<BSCTrackBind>();
                if (trackBindCom != null)
                {
                    trackBindCom.SetPPVVisible(true);
                    trackBindCom.SyncPosAndRotation();   
                }
                
                // 打断一下三段式cache
                var clockComp = GetComponent<BSCClock>();
                clockComp?.ClearThreeStateCache();
                
                SetTime(0);
                isTimeEnd = false;
                _SuspendCurFrame();
                if (artSequencer != null)
                {
                    artSequencer.Stop();
                    artSequencer.Start(0, _finishHold);
                }
                
                Evaluate(); 
            }
        }

        public void Pause()
        {
            _isPaused = true;
        }

        public void Resume()
        {
            _isPaused = false;
        }
        
        // 尝试用三段式结束
        // 如果含有三段式，则跳转到LoopEnd时间点，并播完
        // 如果没有三段式，则直接Stop
        public void StopLoopState()
        {
            if (bsState != BSState.Playing)
            {
                return;
            }
            
            var clock = GetComponent<BSCClock>();
            if (clock.isThreeState)
            {
                clock.BreakLoopState();    
            }
            else
            {
                Stop();    
            }
        }
        
        // 结束播放
        public void Stop()
        {
            var resCom = GetComponent<BSCRes>();
            if (resCom == null)
            {
                // 没有resCom说明timeline没资源，没创建成功
                return;
            }
            var artAsset = resCom.artAsset;
            var logicAsset = resCom.logicAsset;
            
            if (artAsset == null && logicAsset == null)
            {
                this.bsState = BSState.Stop;
                return;
            }

            using (_stopDebugName.Auto())
            {
                // 时间已经结束，并且非repeat模式，时间拨到未开始
                var clockCom = GetComponent<BSCClock>();
                if ((bsState == BSState.Playing || bsState == BSState.FinishHold) && clockCom != null && !clockCom.isWholeRepeat)
                {
                    this.bsState = BSState.Stop;
                    if (_complexPlayableIns != null)
                    {
                        _complexPlayableIns.SetPlayableWeight(0);   
                    }
                    VisiblePoolTool.EnablePoolItemBehavioursByItem(_poolItem, false);
                    SetTime(-BattleConst.FrameTime);
                    if (logicSequencer != null)
                    {
                        logicSequencer.Stop();
                    }
                    if (artSequencer != null)
                    {
                        artSequencer.Stop();
                    }
                    Evaluate();
                }   
            }
        }

        // 外部调用，打断timeline，标记可以结束（不一定真的结束，受到isStopIndividual影响） 
        // 成功结束了会触发回调，但是不一定自动销毁。（受到isAutoDestroy影响）
        public void Interrupt()
        {
            if (this.bsState != BSState.Playing)
            {
                return;
            }

            using (_interruptDebugName.Auto())
            {
                if (!this.isTimeEnd)
                {
                    if (this.isPlayIndividually)
                    {
                        // 时间还没结束，独立播放，打断不随时间结束的轨道
                        logicSequencer.Stop(ExitType.Abnormal);
                        artSequencer.TryInterrupt();
                        artTimelinePlayable?.TryInterrupt();   
                    }
                    else
                    {
                        // 时间没结束，非独立播放，直接结束播放
                        Stop();
                    }
                }
            }
        }

        // 处理强打断逻辑, 当逻辑层Timeline结束时调用.
        public void SpecialEnd()
        {
            if (this.bsState != BSState.Playing)
            {
                return;
            }

            using (_logicEndDebugName.Auto())
            {
                if (this.isPlayIndividually)
                {
                    logicSequencer.Stop();
                    artSequencer.TrySpecialEnd();
                    artTimelinePlayable?.TrySpecialEnd();
                    var trackBindCom = GetComponent<BSCTrackBind>();
                    if (trackBindCom != null)
                    {
                        trackBindCom.SetPPVVisible(false);
                    }
                }
                else
                {
                    // 非独立播放, 直接结束播放
                    Stop();
                }
            }
        }

        // 真正的销毁
        public void Destroy()
        {
            if (this.bsState == BSState.Destroy)
            {
                return;
            }

            bsState = BSState.Destroy;
            var resCom = GetComponent<BSCRes>();

            // if (resCom.artDirector)
            // {
                // resCom.artDirector.Stop();
            // }

            if (logicSequencer != null)
            {
                logicSequencer.Destroy();
                logicSequencer = null;
            }

            if (artSequencer != null)
            {
                artSequencer.Destroy();
                artSequencer = null;
            }

            if (_complexPlayableIns != null)
            {
                _complexPlayableIns.Destory();
                ObjectPoolUtility.ComplexPlayableInstance.Release(_complexPlayableIns);
            }
            
            var artAsset = resCom.artAsset;
            if (artAsset != null)
            {
                artAsset.OnCreatePlayable -= _OnTimelinePlayableCreate;   
            }

            for (int i = 0; i < _features.Count; i++)
            {
                var feature = _features[i];
                BSTypeUtil.DestroyFeature(feature);
            }
            _UnInitRecorderRes();
            _TryInvokeStopCall();
            _Reset();
        }

        public bool IsDestroyed()
        {
            return this.bsState == BSState.Destroy;
        }

        private void _TryInvokeStopCall()
        {
            if (this.onStopCall != null)
            {
                var call = this.onStopCall;
                this.onStopCall = null;
                call();
            }
        }
    }
}