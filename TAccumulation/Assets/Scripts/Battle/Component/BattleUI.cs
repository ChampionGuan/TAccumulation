using System;
using System.Collections.Generic;
using PapeGames.Rendering;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Battle
{
    public class BattleUI : BattleComponent
    {
        private bool _isArtEdit;
        private bool _isMonsterGuide;

        private Dictionary<int, HudData> _huds;
        
        private Dictionary<int, WindowData> _windows;
        private bool _globalControlWindowHide;
        private Action<RectTransform> _hideWindowFun;
        private bool _tempNoPPEnable = false;
        private Dictionary<int, Sprite> _buffIconsDict = new Dictionary<int, Sprite>(10);
        
        /// <summary>
        /// 怪物最大共存数量
        /// </summary>
        public int monsterCoexistNumLimit = 5;

        public BattleUI() : base(BattleComponentType.BattleUI)
        {
            requiredPhysicalJobRunning = true;
        }

        protected override void OnAwake()
        {
            _isArtEdit = false;
            _isMonsterGuide = true;
            
            _huds = new Dictionary<int, HudData>(10);
            
            _windows = new Dictionary<int, WindowData>(5);
            _globalControlWindowHide = false;
            _hideWindowFun = _HideWindowVisible;
            _tempNoPPEnable = PapeGraphicsManager.GetInstance().NoPPEnable;
        }

        public void Preload()
        {
            BattleEnv.LuaBridge?.PreLoadUIs();
            _buffIconsDict.Clear();
            //预加载动态buffIcon
            using (ProfilerDefine.BattleUIPreLoadUIIcons.Auto())
            {
                foreach (var buffConfigsItem in TbUtil.buffCfgs)
                {
                    if (!string.IsNullOrEmpty(buffConfigsItem.Value.BuffIcon))
                    {
                        var sprite = UISystem.LocaleDelegate?.OnGetSprite(buffConfigsItem.Value.BuffIcon, BattleClient.Instance.gameObject);
                        if (sprite != null)
                        {
                            _buffIconsDict.Add(buffConfigsItem.Key, sprite);
                        }
                    }
                    else
                    {
                        _buffIconsDict.Add(buffConfigsItem.Key, null);
                    }
                }
            }
        }

        /// <summary>
        /// 分发Fps操作改变数据
        /// </summary>
        /// <param name="fpsOperateType"></param>
        /// <param name="times"></param>
        public void DispatchFpsOperateChange(FpsOperateType fpsOperateType, int times)
        {
            EventFpsOperateChange fpsOperateChange = battle.eventMgr.GetEvent<EventFpsOperateChange>();
            fpsOperateChange.Init(fpsOperateType, times);
            battle.eventMgr.Dispatch(EventType.OnFpsOperateChange, fpsOperateChange);
        }
        
        /// <summary>
        /// lua调用
        /// </summary>
        /// <param name="isArtEdit"></param>
        public void SetIsArtEdit(bool isArtEdit)
        {
            _isArtEdit = isArtEdit;
        }
        
        /// <summary>
        /// lua调用
        /// </summary>
        /// <param name="isMonsterGuide"></param>
        public void SetIsMonsterGuide(bool isMonsterGuide)
        {
            _isMonsterGuide = isMonsterGuide;
        }
        
        /// <param name="insId"></param>
        /// <param name="requiredVisible"></param>
        public void SetRequiredVisible(int insId, bool requiredVisible)
        {
            foreach (var hudItem in _huds)
            {
                HudData hudData = hudItem.Value;
                if (hudData.insId == insId)
                {
                    hudData.SetRequiredVisible(requiredVisible);
                    return;
                }
            }
        }

        public void AddHud(RectTransform hudTrans, RectTransform hudScaleTrans, Actor role)
        {
            _huds.TryGetValue(hudTrans.GetHashCode(), out HudData hudData);
            if (hudData != null)
            {
                return;
            }
            hudData = ObjectPoolUtility.HudData.Get();
            hudData.Init(hudTrans, hudScaleTrans, role);
            _huds.Add(hudTrans.GetHashCode(), hudData);
        }

        public void RemoveHud(Transform hudTrans)
        {
            //LuaClient销毁时，BattleUI已经销毁
            if (_huds == null)
            {
                return;
            }
            _huds.TryGetValue(hudTrans.GetHashCode(), out HudData hudData);
            if (hudData == null)
            {
                return;
            }
            _huds.Remove(hudTrans.GetHashCode());
            ObjectPoolUtility.HudData.Release(hudData);
        }

        protected override void OnPhysicalJobRunning()
        {
            if (_isArtEdit)
            {
                return;
            }
            using (ProfilerDefine.BattleUIOnLateUpdateHudData.Auto())
            {
                foreach (var hudDataItem in _huds)
                {
                    HudData hudData = hudDataItem.Value;
                    hudData.Update(_isMonsterGuide);
                }
            }

            using (ProfilerDefine.BattleUIOnLateUpdateUiPlayableGraphListUpdate.Auto())
            {
                foreach (var playable in _playables)
                {
                    playable.Value.OnUpdate(battle.unscaledDeltaTime);
                }
            }

        }

        /// <summary>
        /// 打开黑白屏
        /// </summary>
        /// <param name="onCompleteAction"></param>
        /// <param name="isIn"></param>
        /// <param name="isWhite"></param>
        public void ScreenFabe(Action onCompleteAction, bool isIn = true,  bool isWhite = true)
        {
            using (ProfilerDefine.BattleUIScreenFabe.Auto())
            {
                BattleEnv.LuaBridge?.ScreenFabe(isWhite, isIn, onCompleteAction);
            }
        }

        /// <summary>
        /// 关闭黑白屏
        /// </summary>
        public void CloseScreenFabe()
        {
            BattleEnv.LuaBridge?.CloseScreenFabe();
        }
        
        /// <summary>
        /// 节点显隐----Lua层调用
        /// </summary>
        /// <param name="node"></param>
        /// <param name="visible"></param>
        public void SetNodeVisible(RectTransform node, bool visible)
        {
            if (node == null || _NodeIsVisible(node) == visible)
            {
                return;
            }
            _SetNodeVisible(node, visible);
            BattleEnv.ClientBridge.NodePlayMotion(node, visible);
        }
        
        /// <summary>
        /// 界面显隐----Lua层调用
        /// </summary>
        /// <param name="window"></param>
        /// <param name="visible"></param>
        public void SetWindowVisible(RectTransform window, bool visible)
        {
            if (window == null)
            {
                return;
            }
            _windows.TryGetValue(window.GetHashCode(), out WindowData windowData);
            if (windowData == null)
            {
                windowData = _AddWindowData(window, false);
            }
            windowData.visible = visible;
            _SetWindowVisible(windowData, visible);
        }

        /// <summary>
        /// 设置所有受管理的界面显隐
        /// </summary>
        /// <param name="visible"></param>
        public void SetAllWindowsVisible(bool visible)
        {
            if (_globalControlWindowHide != visible || _windows == null)
            {
                return;
            }
            _globalControlWindowHide = !visible;
            foreach (var windowDataItem in _windows)
            {
                WindowData windowData = windowDataItem.Value;
                if (!windowData.isControl)
                {
                    continue;
                }
                _SetWindowVisible(windowData, !_globalControlWindowHide && windowData.visible);
            }
            // 临时优化
            if (visible == false)
            {
                PapeGraphicsManager.GetInstance().NoPPEnable = false;
            }
            else
            {

                PapeGraphicsManager.GetInstance().NoPPEnable = _tempNoPPEnable;
            }
        }
        
        /// <summary>
        /// 加入界面管理----Lua层调用
        /// </summary>
        /// <param name="window"></param>
        public void AddWindow(RectTransform window)
        {
            if (window == null)
            {
                return;
            }
            WindowData windowData = _AddWindowData(window, true);
            if (_globalControlWindowHide)
            {
                _SetWindowVisible(windowData, false);
            }
        }
        
        /// <summary>
        /// 移出界面管理----Lua层调用
        /// </summary>
        /// <param name="window"></param>
        public void RemoveWindow(RectTransform window)
        {
            if (window == null)
            {
                return;
            }
            // LuaClient销毁时，BattleUI已经销毁
            if (_windows == null)
            {
                return;
            }
            _windows.TryGetValue(window.GetHashCode(), out WindowData windowData);
            if (windowData == null)
            {
                return;
            }
            if (_globalControlWindowHide)
            {
                _SetWindowVisible(windowData, windowData.visible);
            }
            _windows.Remove(windowData.window.GetHashCode());
            ObjectPoolUtility.WindowData.Release(windowData);
        }
        
        private void _SetWindowVisible(WindowData windowData, bool visible)
        {
            if (_NodeIsVisible(windowData.window) == visible)
            {
                return;
            }
            _SetNodeVisible(windowData.window, visible);
            //临时处理方案，Todo：系统组提供统一接口，新增战斗用隐藏显示回调函数
            if (visible)
            {
                if (windowData.soundFXHandler != null)
                {
                    //默认第一个音频
                    windowData.soundFXHandler.InternalPlay(0);
                }
            }
            
            /*if (visible)
            {
                _SetNodeVisible(windowData.window, true);
            }
            BattleEnv.CallExtern.WindowPlayMotion(windowData, visible, visible ? null : _hideWindowFun);*/
        }
        //优化3D血条遮挡模型问题,有血条就true,无血条显示就false
        public void SetNoPPEnable(bool enable)
        {
            if (_tempNoPPEnable != enable)
            {
                _tempNoPPEnable = enable;
                PapeGraphicsManager.GetInstance().NoPPEnable = enable;
            }
        }
        private WindowData _AddWindowData(RectTransform window, bool isControl)
        { 
            _windows.TryGetValue(window.GetHashCode(), out WindowData windowData);
            if (windowData == null)
            {
                windowData = ObjectPoolUtility.WindowData.Get();
                windowData.Init(window, true, false);
                _windows.Add(windowData.window.GetHashCode(), windowData);
            }
            windowData.isControl = isControl;
            return windowData;
        }
        
        private void _SetNodeVisible(RectTransform node, bool visible)
        {
            //BattleUtil.SetScale(node, visible ? 1 : 0);
            node.gameObject.SetVisible(visible);
            //node.isCull = !visible;
        }

        private bool _NodeIsVisible(RectTransform node)
        {
            //return node.localScale.x > 0.5f;
            return node.gameObject.visibleSelf;
            //return !node.isCull;
        }

        private void _HideWindowVisible(RectTransform window)
        {
            _SetNodeVisible(window, false);
        }

        protected override void OnDestroy()
        {
            foreach (var windowDataItem in _windows)
            {
                ObjectPoolUtility.WindowData.Release(windowDataItem.Value);
            }
            _windows.Clear();
            _windows = null;

            foreach (var hudDataItem in _huds)
            {
                ObjectPoolUtility.HudData.Release(hudDataItem.Value);
            }
            _huds.Clear();
            _huds = null;
            
            foreach (var playable in _playables)
            {
                ObjectPoolUtility.BattleUIPlayablePool.Release(playable.Value);
            }
            _playables.Clear();
            _playables = null;
            foreach (var mixer in _objectMixerPlayables)
            {
                mixer.Value.GetGraph().Destroy();
            }
            _objectMixerPlayables.Clear();
            _objectMixerPlayables = null;

            //动态加载的buff图标
            _buffIconsDict.Clear();
            _buffIconsDict = null;
        }
        

        public void SetBuffIcon(X3Image image,int buffID)
        {
            if (image == null)
            {
                return;
            }
            if (_buffIconsDict.TryGetValue(buffID, out var icon))
            {
                if (icon != null)
                {
                    image.sprite = icon;
                }
            }
            else
            {
                LogProxy.LogError($"SetBuffIcon,存在未分析到的图标,如果是GM指令或调试器可以忽略， buffID={buffID}");
                var buffCfg = TbUtil.GetCfg<BuffCfg>(buffID);
                if (buffCfg != null&&!string.IsNullOrEmpty(buffCfg.BuffIcon))
                {
                    var sprite = UISystem.LocaleDelegate?.OnGetSprite(buffCfg.BuffIcon,BattleClient.Instance.gameObject);
                    if (sprite != null)
                    {
                        _buffIconsDict.Add(buffID,sprite);
                        image.sprite = sprite;
                    }
                }
            }
        }
        
        public class WindowData:IReset
        {
            public RectTransform window { get; private set; }
            public UIView view { get; private set; }
            public bool toucheEnabled;
            public bool visible;
            //全局控制
            public bool isControl;
            public SoundFXHandler soundFXHandler;

            public void Init(RectTransform window, bool visible, bool isControl)
            {
                this.window = window;
                view = window.GetComponent<UIView>();
                soundFXHandler = window.GetComponent<SoundFXHandler>();
                this.toucheEnabled = true;
                this.visible = visible;
                this.isControl = isControl;
            }

            public void Reset()
            {
                window = null;
                view = null;
                soundFXHandler = null;
            }
        }
        
        public class HudData : IReset
        {
            private RectTransform _trans;
            private RectTransform _scaleTrans;
            private Actor _role;
            private ActorModel _model;
            private Transform _pointTop;
            private CanvasGroup _canvasGroup;
            
            private const float _minCameraDistance = 1f;
            private const float _maxCameraDistance = 20f;
            private const float _scaleMin = 0.5f;
            private const float _scaleMax = 2f;
            private float _standardCameraDistance;

            private bool _requiredVisible;

            private bool enabled => !_role.isDead && _model.actor.transform.visibleSelf && BattleUtil.GetPositionIsInView(_pointTop);

            public int insId => _role.insID;

            public void Init(RectTransform hudTrans, RectTransform hudScaleTrans, Actor role)
            {
                _trans = hudTrans;
                _scaleTrans = hudScaleTrans;
                _role = role;
                _model = role.model;
                _pointTop = BattleUtil.GetActorDummy(role, DummyType.PointTop);
                _scaleTrans.position = _pointTop.position;
                _canvasGroup = _trans.GetComponent<CanvasGroup>();
                _standardCameraDistance = _minCameraDistance + (_scaleMax - 1) / (_scaleMax - _scaleMin) * (_maxCameraDistance - _minCameraDistance);
                _requiredVisible = true;
            }

            public void SetRequiredVisible(bool requiredVisible)
            {
                _requiredVisible = requiredVisible;
            }

            public void Update(bool isGuide)
            { 
                bool visible = isGuide && _requiredVisible && enabled;
                if (visible)
                {
                    _scaleTrans.position = _pointTop.position;
                    //_scaleTrans.localPosition = _GetViewPos(_pointTop.position);
                    //使血条始终朝向相机
                    Quaternion q = Quaternion.identity;
                    var cameraTransform = BattleUtil.MainCamera.transform;
                    q.SetLookRotation(cameraTransform.forward,cameraTransform.up);
                    _scaleTrans.rotation = q;
                    //使用距离的反比来做缩放
                    float distance = (cameraTransform.position - _scaleTrans.position).magnitude;
                    //相机视觉大小的倒数
                    float cameraScaleReciprocal = distance / _standardCameraDistance;
                    //策划要求的大小
                    float tempScale;
                    if (distance <= _minCameraDistance)
                    {
                        tempScale = _scaleMax;
                    }
                    else if (distance >= _maxCameraDistance)
                    {
                        tempScale = _scaleMin;
                    }
                    else
                    {
                        tempScale = Mathf.Lerp(_scaleMax, _scaleMin, (distance - _minCameraDistance) / (_maxCameraDistance - _minCameraDistance));
                    }
                    float currentScale = tempScale * cameraScaleReciprocal;
                    BattleUtil.SetScale(_scaleTrans, currentScale);
                    //BattleUtil.SetScale(_scaleTrans, 1);
                    _canvasGroup.alpha = _model.dissolveAlpha;
                }
                Battle.Instance.ui.SetNodeVisible(_trans, visible);
            }
            
            private static Vector2 _GetViewPos(Vector3 worldPosition)
            {
                RectTransform uiParent = BattleUtil.UIRoot;
                Vector3 screenPos = BattleUtil.MainCamera.WorldToScreenPoint(worldPosition);
                bool isBack = screenPos.z < 0;
                if (isBack) // 物体在相机背面
                {
                    screenPos.x = Screen.width - screenPos.x;
                    screenPos.y = Screen.height - screenPos.y;
                }
                RectTransformUtility.ScreenPointToLocalPointInRectangle(uiParent, screenPos, RTUtility.GetCachedUICamera(uiParent), out Vector2 retPos);
                return retPos;
            }
            
            public void Reset()
            {
                _trans = null;
                _scaleTrans = null;
                _role = null;
                _model = null;
                _pointTop = null;
				_canvasGroup = null;
            }
        }

        #region 战斗使用的简单UI动画相关
        
        //兼容motianhandler，给lua层用motianinfo进行播放停止
        private Dictionary<MotionHandler.MotionInfo, BattleUIPlayable> _playables = new Dictionary<MotionHandler.MotionInfo, BattleUIPlayable>(90);
        //直接用播放单位做索引，使用AnimationMixerPlayable完成所有需要的操作，用于处理不同的motionInfo可能在同一个单位上播放
        private Dictionary<UnityEngine.Object, AnimationMixerPlayable> _objectMixerPlayables = new Dictionary<UnityEngine.Object, AnimationMixerPlayable>(80);

        //预先创建好Playable和PlayableOutput,避免动态添加导致额外耗时
        public void PreCreateUIPlayable()
        {
            foreach (var window in _windows)
            {
                //提前创建战斗UI动画playbale
                var handlerList = window.Value.window.GetComponentsInChildren<MotionHandler>();
                foreach (var comp in handlerList)
                {
                    foreach (var info in comp.ItemList)
                    {
                        if (_playables.ContainsKey(info))
                        {
                            continue;
                        }
                        GameObject gameObject = comp.gameObject;
                        _CreateUIPlayable(info,gameObject.GetOrAddComponent<Animator>(),gameObject);
                    }
                }
            }
        }
        
        /// <summary>
        /// 创建clip对应的战斗动画结构
        /// </summary>
        /// <param name="motionInfo">动画片段绑定的motionInfo</param>
        /// <param name="animator">动画播放单位的animator组件</param>
        /// <param name="obj">动画播放单位的索引，用于兼容motionhandler</param>
        /// <returns></returns>
        private BattleUIPlayable _CreateUIPlayable(MotionHandler.MotionInfo motionInfo,Animator animator,UnityEngine.Object obj)
        {
            if (motionInfo == null || obj == null || animator == null || motionInfo.Clip == null)
            {
                LogProxy.LogError("InitPlayable,obj or motionInfo is null!");
                return null;
            }
            using (ProfilerDefine.BattleUIPlayableCreateUIPlayable.Auto())
            {
                if (!animator.enabled)
                {
                    animator.enabled = true;
                }
                if (!_objectMixerPlayables.TryGetValue(obj, out var mixerPlayable))
                {
                    PlayableGraph graph = PlayableGraph.Create(obj.name);
                    AnimationPlayableOutput output = AnimationPlayableOutput.Create(graph, "Mixer", animator);
                    mixerPlayable = AnimationMixerPlayable.Create(graph);
                    output.SetSourcePlayable(mixerPlayable);
                    graph.SetTimeUpdateMode(DirectorUpdateMode.Manual);
                    _objectMixerPlayables.Add(obj, mixerPlayable);
                }
                AnimationClipPlayable clipPlayable = AnimationClipPlayable.Create(mixerPlayable.GetGraph(), motionInfo.Clip);
                clipPlayable.SetDuration(motionInfo.Clip.length);
                mixerPlayable.AddInput(clipPlayable, 0);
                var playable = ObjectPoolUtility.BattleUIPlayablePool.Get();
                playable.ClipPlayable = clipPlayable;
                playable.Mixer = mixerPlayable;
                playable.WrapMode = motionInfo.WrapMode;
                _playables.Add(motionInfo, playable);

                return playable;
            }
        }
        
        public void Play(MotionHandler.MotionInfo motionInfo,Animator animator, System.Action onComplete,UnityEngine.Object obj)
        {
            if (motionInfo == null || motionInfo.Clip == null)
            {
                return;
            }

            if (_playables.TryGetValue(motionInfo, out var playable))
            {
                if(!playable.IsValid())
                {
                    LogProxy.LogError($"Playable is Invalid,motionInfo = {motionInfo.AssetName}");
                    return;
                }
                playable.OnAnimationCompleted = onComplete;
            }
            else
            {
                playable = _CreateUIPlayable(motionInfo,animator,obj);
            }
            playable?.Play(true);
            //音效
            if (!string.IsNullOrEmpty(motionInfo.SoundFX))
                UISystem.SoundFXDelegate?.PlaySoundFX(motionInfo.SoundFX);
        }
        
        public void Pause(MotionHandler.MotionInfo motionInfo)
        {
            if (_playables.TryGetValue(motionInfo, out BattleUIPlayable playable))
            {
                playable.Pause();
            }
            else
            {
                LogProxy.LogError($"暂停失败，未找到正在播放的动画 motionInfo = {motionInfo.AssetName}");
            }
        }

        public void Resume(MotionHandler.MotionInfo motionInfo)
        {
            if (_playables.TryGetValue(motionInfo, out BattleUIPlayable playable))
            {
                playable.Play(false);
            }
            else
            {
                LogProxy.LogError($"恢复播放失败，未找到正在播放的动画 motionInfo = {motionInfo.AssetName}");
            }
        }
        
        public void Stop(MotionHandler.MotionInfo motionInfo)
        {
            if (_playables.TryGetValue(motionInfo, out BattleUIPlayable playable))
            {
                playable.Stop();
                if (!string.IsNullOrEmpty(motionInfo.SoundFX))
                    UISystem.SoundFXDelegate?.PlaySoundFX(motionInfo.SoundFX);
            }
            else
            {
                LogProxy.LogError($"停止失败，未找到正在播放的动画，motionInfo = {motionInfo.AssetName}");
            }

        }
        
        public void StopAll(UnityEngine.Object obj)
        {
            if (_objectMixerPlayables.TryGetValue(obj, out var mixer))
            {
                // for (int i = 0; i < mixer.GetInputCount(); i++)
                // {
                //     mixer.GetInput(i).Pause();
                // }
                mixer.GetGraph().Stop();
            }
            else
            {
                LogProxy.Log($"StopAll，未找到正在播放的动画，UObject = {obj}");
            }
        }

        //处理回调函数
        public class BattleUIPlayable : IReset
        {
            private static AnimationClipPlayable _emptyPlayable = new AnimationClipPlayable();
            private bool _completed = true;
            private float _duration = 0;
            public Action OnAnimationCompleted;
            public AnimationClipPlayable ClipPlayable;
            public AnimationMixerPlayable Mixer;
            public DirectorWrapMode WrapMode = DirectorWrapMode.None;

            public void Play(bool resetTime)
            {
                _completed = false;

                //其他的设置成0
                for (int i = 0; i < Mixer.GetInputCount(); i++)
                {
                    Mixer.SetInputWeight(Mixer.GetInput(i),0);
                }
                Mixer.SetInputWeight(ClipPlayable,1);
                if (resetTime)
                {
                    _duration = 0;
                    ClipPlayable.SetTime(0);
                    ClipPlayable.SetLeadTime(0);
                }
                if (ClipPlayable.IsValid())
                {
                    ClipPlayable.Play();
                    var graph = ClipPlayable.GetGraph();
                    if (!graph.IsPlaying())
                    {
                        graph.Play();
                        //战斗UI动画播放时立刻生效
                        graph.Evaluate();
                    }
                }
                else
                {
                    PapeGames.X3.LogProxy.Log($"clipPlayable is InValid ,playable = {ClipPlayable}");
                }
            }
            
            public void Pause()
            {
                if (ClipPlayable.IsValid())
                {
                    ClipPlayable.Pause();
                }
                else
                {
                    PapeGames.X3.LogProxy.Log($"clipPlayable is InValid ,playable = {ClipPlayable}");
                }
            }
            //目前战斗UI动画同时只能播一个动画
            public void Stop()
            {
                if (_completed)
                {
                    return;
                }
                _completed = true;
                if (ClipPlayable.IsValid())
                {
                    ClipPlayable.SetTime(ClipPlayable.GetDuration());
                    Mixer.SetInputWeight(ClipPlayable,0);
                    Mixer.GetGraph().Stop();
                }
                else
                {
                    PapeGames.X3.LogProxy.Log($"clipPlayable is InValid ,playable = {ClipPlayable}");
                }
            }

            public void OnUpdate(float deltaTime)
            {
                if (_completed||!IsValid())
                {
                    return;
                }

                if (ClipPlayable.GetPlayState() == PlayState.Paused)
                {
                    return;
                }
                _duration += deltaTime;
                ClipPlayable.SetTime(_duration);
                Mixer.GetGraph().Evaluate();

                var time = ClipPlayable.GetDuration();
                if (_duration >= time)
                {
                    OnAnimationCompleted?.Invoke();
                    switch (WrapMode)
                    {
                        case DirectorWrapMode.Hold:
                            _completed = true;
                            break;
                        case DirectorWrapMode.Loop:
                            Play(true);
                            break;
                        case DirectorWrapMode.None:
                            Stop();
                            break;
                        default:
                            return;
                    }
                }
            }

            public bool IsValid()
            {
                return ClipPlayable.IsValid();
            }

            public void Reset()
            {
                _duration = 0;
                _completed = true;
                OnAnimationCompleted = null;
                WrapMode = DirectorWrapMode.None;
            }
        }
        #endregion

        public void PreloadFinished()
        {
            // DONE: 隐藏所有UI & 触摸响应禁用 & 是否隐藏锁定特效 & 隐藏3D血条.
            BattleUtil.SetLevelBeforeUIActive(false);
            BattleEnv.LuaBridge?.HideAllMonsterHuds();
        }
    }
}