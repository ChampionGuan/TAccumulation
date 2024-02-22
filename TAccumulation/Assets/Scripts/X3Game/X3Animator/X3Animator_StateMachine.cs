using System.Collections.Generic;
using Framework;
using PapeGames.CutScene;
using UnityEngine;
using PapeGames.X3;
using UnityEngine.Playables;
using PapeAnimation;
using X3.Character;
using static X3Game.X3RuntimeStateController;

namespace X3Game
{
    public partial class X3Animator : ILayerEventReceiver
    {
        #region Play / Stop / Pause / Resume / FastForward
        
        static IX3AnimatorEventDelegate s_IX3AnimatorEventDelegate;

        public static void SetEventDelegate(IX3AnimatorEventDelegate eventDelegate)
        {
            s_IX3AnimatorEventDelegate = eventDelegate;
        }

        /// <summary>
        /// 播放动画（无融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <returns></returns>
        public bool Play(string stateName)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, -1, 0, null);
            if (ret)
            {
                PhysicsSmoothBlendCurrentPose();
                Evaluate(Time.deltaTime * Speed);
            }
            s_IX3AnimatorEventDelegate?.OnPlay(this, stateName, -1, 0, default);

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Play: {2}, success: {3}", Tag, name, stateName, ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（无融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="wrapMode">循环模式</param>
        /// <returns></returns>
        public bool Play(string stateName, DirectorWrapMode wrapMode)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, 0, 0, wrapMode);
            if (ret)
            {
                PhysicsSmoothBlendCurrentPose();
                Evaluate(Time.deltaTime * Speed);
            }
            s_IX3AnimatorEventDelegate?.OnPlay(this, stateName, 0, 0, (int)wrapMode);

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Play: {2}, {3}, success: {4}", Tag, name, stateName, wrapMode,
                    ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（无融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="initialTime">起始时间，-1为继续上次播放</param>
        /// <returns></returns>
        public bool Play(string stateName, float initialTime)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, initialTime, 0, null);
            if (ret)
            {
                PhysicsSmoothBlendCurrentPose();
                Evaluate(Time.deltaTime * Speed);
            }
            s_IX3AnimatorEventDelegate?.OnPlay(this, stateName, initialTime, 0, default);

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Play: {2}, {3}, success: {4}", Tag, name, stateName,
                    initialTime, ret);
            return ret;
        }
        
        /// <summary>
        /// 播放动画（无融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="wrapMode">循环模式</param>
        /// <param name="initialTime">起始时间，-1为继续上次播放</param>
        /// <returns></returns>
        public bool Play(string stateName, DirectorWrapMode wrapMode, float initialTime)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, initialTime, 0, wrapMode);
            if (ret)
            {
                PhysicsSmoothBlendCurrentPose();
                Evaluate(Time.deltaTime * Speed);
            }
            s_IX3AnimatorEventDelegate?.OnPlay(this, stateName, initialTime, 0, (int)wrapMode);

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Play: {2}, {3}, {4}, success: {5}", Tag, name, stateName,
                    initialTime, wrapMode, ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（无融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="wrapMode">循环模式</param>
        /// <param name="initialTime">起始时间，-1为继续上次播放</param>
        /// <returns></returns>
        public bool Play(string stateName, float initialTime, DirectorWrapMode wrapMode)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, initialTime, 0, wrapMode);
            if (ret)
            {
                PhysicsSmoothBlendCurrentPose();
                Evaluate(Time.deltaTime * Speed);
            }
            s_IX3AnimatorEventDelegate?.OnPlay(this, stateName, initialTime, 0, (int)wrapMode);

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Play: {2}, {3}, {4}, success: {5}", Tag, name, stateName,
                    initialTime, wrapMode, ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <returns></returns>
        public bool Crossfade(string stateName)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, -1, -1, null);
            if (ret)
            {
                Evaluate(Time.deltaTime * Speed);
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Crossfade: {2}, success: {3}", Tag, name, stateName, ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="transitionDuration">融合时间</param>
        /// <returns></returns>
        public bool Crossfade(string stateName, float transitionDuration)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, -1, transitionDuration, null);
            if (ret)
            {
                Evaluate(Time.deltaTime * Speed);
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Crossfade: {2}, {3}, success: {4}", Tag, name, stateName,
                    transitionDuration, ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="wrapMode">循环模式</param>
        /// <returns></returns>
        public bool Crossfade(string stateName, DirectorWrapMode wrapMode)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, -1, -1, wrapMode);
            if (ret)
            {
                Evaluate(Time.deltaTime * Speed);
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Crossfade: {2}, {3}, success: {4}", Tag, name, stateName,
                    wrapMode, ret);
            return ret;
        }
        
        /// <summary>
        /// 播放动画（融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="initialTime">起始时间，-1为继续上次播放</param>
        /// <param name="transitionDuration">融合时间</param>
        /// <returns></returns>
        public bool Crossfade(string stateName, float initialTime, float transitionDuration)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, initialTime, transitionDuration,
                null);
            if (ret)
            {
                Evaluate(Time.deltaTime * Speed);
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Crossfade: {2}, {3}, {4}, success: {5}", Tag, name, stateName,
                    initialTime, transitionDuration, ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="transitionDuration">融合时间</param>
        /// <param name="wrapMode">循环模式</param>
        /// <returns></returns>
        public bool Crossfade(string stateName, float transitionDuration, DirectorWrapMode wrapMode)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, -1, transitionDuration, wrapMode);
            if (ret)
            {
                Evaluate(Time.deltaTime * Speed);
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Crossfade: {2}, {3}, {4}, success: {5}", Tag, name, stateName,
                    transitionDuration, wrapMode, ret);
            return ret;
        }

        /// <summary>
        /// 播放动画（融合）
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="initialTime">起始时间，-1为继续上次播放</param>
        /// <param name="transitionDuration">融合时间</param>
        /// <param name="wrapMode">循环模式</param>
        /// <returns></returns>
        public bool Crossfade(string stateName, float initialTime, float transitionDuration, DirectorWrapMode wrapMode)
        {
            var ret = RuntimeStateController.DefaultLayer.PlayInFixedTime(stateName, initialTime, transitionDuration,
                wrapMode);
            if (ret)
            {
                Evaluate(Time.deltaTime * Speed);
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Crossfade: {2}, {3}, {4}, {5}, success: {6}", Tag, name,
                    stateName, initialTime, transitionDuration, wrapMode, ret);
            return ret;
        }
        
        /// <summary>
        /// 快速播放到指定时间并暂停
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="normalizedTime">指定时间（normalized）</param>
        /// <returns></returns>
        public bool FastForward(string stateName, float normalizedTime)
        {
            var ret = RuntimeStateController.DefaultLayer.Play(stateName, normalizedTime, 0, DirectorWrapMode.Hold);
            if (ret)
            {
                m_Controller.Update(0);
                var curState = RuntimeStateController.DefaultLayer.CurState;
                bool isCts = curState != null &&
                             curState is CutsceneState;
                PlayableAnimationManager.Instance().FindPlayGraph(gameObject)?.Update();
                if (isCts)
                {
                    CutSceneManager.Evaluate();
                    CutSceneManager.FireEvents();
                }

                RuntimeStateController.DefaultLayer.Pause();
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, FastForward: {2}, {3}, success: {4}", Tag, name, stateName,
                    normalizedTime, ret);
            return ret;
        }

        /// <summary>
        /// 从指定时间播放并强制更新graph，该接口没有调用X3Character物理的融合接口
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="normalizedTime">指定时间（normalized）</param>
        /// <returns></returns>
        public void ManualEvaluate(string stateName, float normalizedTime)
        {
            var ret = RuntimeStateController.DefaultLayer.Play(stateName, normalizedTime, 0, DirectorWrapMode.Hold);
            m_Controller.Update(0);
            var curState = RuntimeStateController.DefaultLayer.CurState;
            bool isCts = curState != null &&
                         curState is CutsceneState;
            PlayableAnimationManager.Instance().FindPlayGraph(gameObject)?.Update();
            if (isCts)
            {
                CutSceneManager.Evaluate();
                CutSceneManager.FireEvents();
            }
        }

        /// <summary>
        /// 播放默认状态
        /// </summary>
        /// <returns></returns>
        public bool PlayDefault()
        {
            var ret = RuntimeStateController.DefaultLayer.PlayDefault();
            if (ret)
            {
                Evaluate(Time.deltaTime * Speed);
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, PlayDefualt success: {2}", Tag, name, ret);
            return ret;
        }

        /// <summary>
        /// 暂停
        /// </summary>
        public void Pause()
        {
            RuntimeStateController.DefaultLayer?.Pause();
            s_IX3AnimatorEventDelegate?.OnPause(this);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Pause", Tag, name);
        }

        /// <summary>
        /// 恢复
        /// </summary>
        public void Resume()
        {
            RuntimeStateController.DefaultLayer?.Resume();
            s_IX3AnimatorEventDelegate?.OnResume(this);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Resume", Tag, name);
        }

        /// <summary>
        /// 停止播放
        /// </summary>
        /// <param name="autoComplete">是否自动完成，为true时快播到最后再结束播放</param>
        public void Stop(bool autoComplete = false)
        {
            if (autoComplete)
            {
                FastForward(this.CurStateName, 1);
            }

            m_Controller?.DefaultLayer?.Stop();
            s_IX3AnimatorEventDelegate?.OnStop(this, autoComplete);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, Stop", Tag, name);
        }

        public bool IsPlaying
        {
            get => RuntimeStateController.DefaultLayer.IsPlaying;
        }

        public bool IsPaused
        {
            get => RuntimeStateController.DefaultLayer.IsPaused;
        }

        [SerializeField] private float m_DefaultTransitionDuration = 0.6f;

        public float DefaultTransitionDuration
        {
            get => m_DefaultTransitionDuration;
            set
            {
                m_DefaultTransitionDuration = value;
                RuntimeStateController.DefaultTransitionDuration = m_DefaultTransitionDuration;
                if (LogEnabled)
                    X3Debug.LogFormat("X3Animator: {0},{1}, SetDefaultTransitionDuration: {2}", Tag, name,
                        m_DefaultTransitionDuration);
            }
        }

        #endregion

        #region States

        /// <summary>
        /// 添加CutScene状态
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="ctsName">Cutscene名</param>
        /// <param name="inheritTransform">播放Cts时是否同步位置信息</param>
        /// <param name="defaultWrapMode">默认循环模式，可在播放时覆写</param>
        /// <param name="defaultTransitionDuration">默认融合时长</param>
        /// <param name="kfList">关键帧列表</param>
        /// <returns>成功时返回状态名哈希，失败返回0</returns>
        public int AddState(string stateName, string ctsName, bool inheritTransform = false,
            DirectorWrapMode defaultWrapMode = DirectorWrapMode.None, float defaultTransitionDuration = -1,
            IList<KeyFrame> kfList = null)
        {
            if (string.IsNullOrEmpty(stateName))
            {
                X3Debug.LogErrorFormat("X3Animator: {0},{1}, empty stateName", Tag, name);
                return 0;
            }

            bool hasOverride = false;
            bool setDefault = false;

            if (RetrieveExternalData(stateName))
            {
                ctsName = s_ExternalStateData.AssetPathOrName;
                defaultWrapMode = (DirectorWrapMode)s_ExternalStateData.WrapMode;
                defaultTransitionDuration = s_ExternalStateData.TransitionDuration;
                inheritTransform = s_ExternalStateData.InheritTransform;
                if (!inheritTransform)
                {
                    this.InheritTransform = false;
                    X3Debug.LogFormat("X3Animator: Change InheritTransform to false caz DataProvider");
                }

                setDefault = s_ExternalStateData.SetDefault;
                hasOverride = true;
            }

            var existedState = RuntimeStateController.DefaultLayer.GetState(stateName);
            if (existedState != null)
            {
                if (hasOverride && existedState is CutsceneState)
                    (existedState as CutsceneState).UpdateInfo(ctsName,
                        inheritTransform,
                        defaultTransitionDuration,
                        defaultWrapMode
                    );
                if (setDefault)
                    RuntimeStateController.DefaultLayer.SetDefault(stateName);
                if (LogEnabled)
                    X3Debug.LogFormat("X3Animator: {0},{1}, UpdateState: {2}, {3}, {4}, {5}, {6} success: {7}", Tag,
                        name, stateName, ctsName, inheritTransform, defaultWrapMode, defaultTransitionDuration, true);
                return existedState.NameHash;
            }

            var state = CutsceneState.Create(stateName, ctsName, defaultWrapMode, inheritTransform,
                defaultTransitionDuration, kfList);
            state.Context = AnimatorContext;
            state.OnWillEnterAction += OnCutsceneStateWillEnter;
            state.IsExternalState = hasOverride;
            var stateNameHash = InternalAddState(state, setDefault);
            if (stateNameHash == 0)
                ClearableObjectPool<CutsceneState>.Release(state);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, AddState: {2}, {3}, {4}, {5}, {6} success: {7}", Tag, name,
                    stateName, ctsName, inheritTransform, defaultWrapMode, defaultTransitionDuration,
                    stateNameHash != 0);
            return stateNameHash;
        }

        /// <summary>
        /// 添加AnimationClip状态
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="clip">AnimationClip资产</param>
        /// <param name="defaultWrapMode">默认循环模式，可在播放时覆写</param>
        /// <param name="exitTime">状态退出时间（normalized）</param>
        /// <param name="kfList">关键帧列表</param>
        /// <returns>成功时返回状态名哈希，失败返回0</returns>
        public int AddState(string stateName, AnimationClip clip,
            DirectorWrapMode defaultWrapMode = DirectorWrapMode.None, float exitTime = 0.9f,
            IList<KeyFrame> kfList = null)
        {
            if (string.IsNullOrEmpty(stateName))
            {
                X3Debug.LogErrorFormat("X3Animator: {0},{1}, empty stateName", Tag, name);
                return 0;
            }

            var state = AnimationClipState.Create(stateName, clip, defaultWrapMode, exitTime, kfList);
            state.Context = AnimatorContext;
            var stateNameHash = InternalAddState(state);
            if (stateNameHash == 0)
                ClearableObjectPool<AnimationClipState>.Release(state);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, AddState: {2}, {3}, {4}, success: {5}", Tag, name, stateName,
                    clip != null ? clip.name : "null", defaultWrapMode, stateNameHash != 0);
            return stateNameHash;
        }

        /// <summary>
        /// 添加ProceduralAnimationClip状态
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <param name="clip">ProceduralAnimationClip资产</param>
        /// <param name="defaultWrapMode">默认循环模式，可在播放时覆写</param>
        /// <param name="exitTime">状态退出时间（normalized）</param>
        /// <param name="kfList">关键帧列表</param>
        /// <returns></returns>
        public int AddState(string stateName, ProceduralAnimation.ProceduralAnimationClip clip,
            DirectorWrapMode defaultWrapMode = DirectorWrapMode.None, float exitTime = 0.9f,
            IList<KeyFrame> kfList = null)
        {
            if (string.IsNullOrEmpty(stateName))
            {
                X3Debug.LogErrorFormat("X3Animator: {0},{1}, empty stateName", Tag, name);
                return 0;
            }

            var state = ProceduralClipState.Create(stateName, clip, defaultWrapMode, exitTime, kfList);
            state.Context = AnimatorContext;
            var stateNameHash = InternalAddState(state);
            if (stateNameHash == 0)
                ClearableObjectPool<ProceduralClipState>.Release(state);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, AddState: {2}, {3}, {4} success: {5}", Tag, name, stateName,
                    clip != null ? clip.name : "null", defaultWrapMode, stateNameHash != 0);
            return stateNameHash;
        }

        /// <summary>
        /// 从X3AnimatorAsset资产中加载状态列表
        /// </summary>
        /// <param name="asset">X3AnimatorAsset资产</param>
        /// <returns>是否成功</returns>
        public bool LoadFromAsset(X3AnimatorAsset asset)
        {
            if (asset == null) return false;

            m_RootBone = CommonUtility.FindChildRecursively(transform, asset.RootBoneName);
            if (asset.AssetId > 0)
                m_AssetId = asset.AssetId;
            //todo:...
            if (asset.DefaultTransitionDuration > 0)
                DefaultTransitionDuration = Mathf.Max(asset.DefaultTransitionDuration, 0.6f);
            AddStatesFromEmbededList(asset.EmbeddedStateList as IList<State>);
            if (!string.IsNullOrEmpty(asset.DefaultStateName))
                SetDefaultState(asset.DefaultStateName);

            controlRigAsset = asset.ControlRigAsset;
            controlRigTarget = CommonUtility.FindChildRecursively(transform, asset.ControlRigTargetBoneName);
            return true;
        }

        /// <summary>
        /// 设置默认状态，当循环模式为none的动画播放结束后自动回到默认状态
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <returns>是否成功</returns>
        public bool SetDefaultState(string stateName)
        {
            var ret = RuntimeStateController.DefaultLayer.SetDefault(stateName);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, SetDefaultState: {2}, success: {3}", Tag, name, stateName, ret);
            return ret;
        }

        /// <summary>
        /// 清除默认状态
        /// </summary>
        public void ClearDefaultState()
        {
            RuntimeStateController.DefaultLayer.ClearDefault();
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, ClearDefaultState", Tag, name);
        }

        /// <summary>
        /// 删除状态
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <returns>是否成功</returns>
        public bool RemoveState(string stateName)
        {
            bool ret = RuntimeStateController.DefaultLayer.RemoveState(stateName);
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, RemoveState: {2}, success: {3}", Tag, name, stateName, ret);
            return ret;
        }

        /// <summary>
        /// 清除所有状态
        /// </summary>
        public void ClearStates()
        {
            RuntimeStateController.DefaultLayer.ClearStates();
            if (IsCharacter)
            {
                var playGraph = PlayableAnimationManager.Instance().FindPlayGraph(gameObject);
                if (playGraph != null)
                {
                    playGraph.SetWeight(EStaticSlot.Gameplay, 1);
                    playGraph.SetWeight(EStaticSlot.Timeline, 1);
                }
            }

            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, ClearStates", Tag, name);
        }

        /// <summary>
        /// 重置CTS状态
        /// </summary>
        public void ResetCtsStates(bool restartState = true)
        {
            string curStateName = CurStateName;
            if (restartState)
            {
                Stop();
            }
            TraverseStates(state =>
            {
                if (state is CutsceneState)
                {
                    CutsceneState ctsState = state as CutsceneState;
                    var dataProviderEnabled = DataProviderEnabled;
                    DataProviderEnabled = true;
                    if (ctsState.IsExternalState)
                    {
                        AddState(state.Name, (state as CutsceneState).CutsceneName);
                    }
                    DataProviderEnabled = dataProviderEnabled;
                }
            });

            if (restartState)
            {
                Play(curStateName);
            }
            if (LogEnabled)
                X3Debug.LogFormat("X3Animator: {0},{1}, ResetStates", Tag, name);
        }

        /// <summary>
        /// 查询是否有名字为stateName的状态
        /// </summary>
        /// <param name="stateName">查询状态名</param>
        /// <returns>是否包含</returns>
        public bool HasState(string stateName)
        {
            return RuntimeStateController.DefaultLayer.StateExists(stateName);
        }

        /// <summary>
        /// 查询状态总时长
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <returns>状态总时长</returns>
        public float GetStateLength(string stateName)
        {
            var state = RuntimeStateController.DefaultLayer.GetState(stateName);
            if (state == null)
                return 0;
            return state.Length;
        }

        
        /// <summary>
        /// 查询状态剩余播放时长
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <returns>剩余播放时长</returns>
        public float GetStateRemainingTime(string stateName)
        {
            var state = RuntimeStateController.DefaultLayer.GetState(stateName);
            if (state == null)
                return 0;
            return state.RemainingTime;
        }

        
        /// <summary>
        /// 查询状态当前处于的时间
        /// </summary>
        /// <param name="stateName">状态名</param>
        /// <returns>状态当前处于的时间</returns>
        public float GetStateTime(string stateName)
        {
            var state = RuntimeStateController.DefaultLayer.GetState(stateName);
            if (state == null)
                return 0;
            return state.WrapTime;
        }

        public string DefaultStateName
        {
            get { return RuntimeStateController.DefaultLayer.DefaultStateName; }
        }

        public string CurStateName
        {
            get
            {
                var state = RuntimeStateController.DefaultLayer.CurState;
                if (state == null)
                    return null;
                return state.Name;
            }
        }

        public string PrevStateName
        {
            get
            {
                var state = RuntimeStateController.DefaultLayer.PrevState;
                if (state == null)
                    return null;
                return state.Name;
            }
        }

        public float CurStateTime
        {
            get
            {
                var state = RuntimeStateController.DefaultLayer.CurState;
                if (state == null)
                    return 0;
                return state.WrapTime;
            }
        }

        public float CurStateLength
        {
            get
            {
                var state = RuntimeStateController.DefaultLayer.CurState;
                if (state == null)
                    return 0;
                return state.Length;
            }
        }

        public float CurStateProgress
        {
            get
            {
                var state = RuntimeStateController.DefaultLayer.CurState;
                if (state == null)
                    return 0;
                return Mathf.Clamp01(state.WrapTime / state.Length);
            }
        }

        public int StateCount
        {
            get => RuntimeStateController.DefaultLayer.StateCount;
        }

        public string[] StateNames
        {
            get => RuntimeStateController.DefaultLayer.StateNames;
        }

        public void TraverseStates(System.Action<X3Game.X3RuntimeStateController.State> func, int layerIdx = -1)
        {
            RuntimeStateController.DefaultLayer.TraverseStates(func);
        }

        public X3Game.X3RuntimeStateController.State GetState(string stateName)
        {
            if (string.IsNullOrEmpty(stateName))
                return null;
            var state = RuntimeStateController.DefaultLayer.GetState(stateName);
            return state;
        }

        private int InternalAddState(X3Game.X3RuntimeStateController.State state, bool setDefault = false)
        {
            if (state == null)
                return 0;
            var ret = RuntimeStateController.DefaultLayer.AddState(state, setDefault);
            if (ret)
            {
                return state.NameHash;
            }

            return 0;
        }

        #endregion

        #region RuntimeController

        private void Evaluate(float dt)
        {
            LastUpdateFrameCount = Time.frameCount;
            m_Controller.Update(dt);

            if (FrameworkMainEntry.LastUpdateFrameCount == Time.frameCount)
            {
                PlayableAnimationManager.Instance().FindPlayGraph(gameObject)?.Update();
                var curState = RuntimeStateController.DefaultLayer.CurState;
                if (curState is CutsceneState)
                {
                    CutSceneManager.Evaluate();
                    CutSceneManager.FireEvents();
                }
            }
        }

        private X3Game.X3RuntimeStateController m_Controller = null;

        #endregion

        #region External Data

        public void ClearExternalStateCache()
        {
            TraverseStates(state =>
            {
                var ctsState = state as CutsceneState;
                if (ctsState != null)
                    ctsState.UpdatedFromExternal = false;
            });
        }

        private bool RetrieveExternalData(string stateName)
        {
            if (string.IsNullOrEmpty(stateName))
                return false;
            if (!DataProviderEnabled || s_DataProvider == null)
                return false;
            if (s_ExternalStateData == null)
                s_ExternalStateData = new ExternalX3AnimatorStateData();
            var ret = s_DataProvider.OnLoadStateData(this, stateName, s_ExternalStateData);
            return ret;
        }

        private void OnCutsceneStateWillEnter(CutsceneState state)
        {
            if (state == null)
                return;
            if (RetrieveExternalData(state.Name))
            {
                state.UpdateInfo(s_ExternalStateData.AssetPathOrName,
                    s_ExternalStateData.InheritTransform,
                    s_ExternalStateData.TransitionDuration,
                    (DirectorWrapMode)s_ExternalStateData.WrapMode
                );
                if (s_ExternalStateData.SetDefault)
                    RuntimeStateController.DefaultLayer.SetDefault(state.Name);
            }
        }

        #endregion

        #region Animation Tree

        public GenericAnimationTree m_AnimationTree;

        public GenericAnimationTree AnimationTree
        {
            get
            {
                if (m_AnimationTree == null)
                {
                    m_AnimationTree = s_AnimationTreePool.Get(GenerateAnimationTree);
                    m_AnimationTree.ParentIndex = 0;
                }
                return m_AnimationTree;
            }
        }

        private static ExternalGenerateObjectPool<GenericAnimationTree> s_AnimationTreePool =
            new ExternalGenerateObjectPool<GenericAnimationTree>(null, null);

        private static GenericAnimationTree GenerateAnimationTree()
        {
            return GenericAnimationTree.Create(MixerType.Mixer, default(DummyJob));
        }

        #endregion

        #region Add / Remove Listeners

        public event System.Action<string> OnStateEntered;
        public event System.Action<string> OnStateCompleted;
        public event System.Action<string> OnStateFinished;

        /// <summary>
        /// 注册状态开始监听
        /// </summary>
        /// <param name="onEnter"></param>
        public void AddStateEnterListener(System.Action<string> onEnter)
        {
            if (onEnter != null)
            {
                OnStateEntered -= onEnter;
                OnStateEntered += onEnter;
            }
        }

        /// <summary>
        /// 反注册状态开始监听
        /// </summary>
        /// <param name="onEnter"></param>
        public void RemoveStateEnterListener(System.Action<string> onEnter)
        {
            if (onEnter != null)
            {
                OnStateEntered -= onEnter;
            }
        }

        /// <summary>
        /// 注册状态播放结束监听
        /// </summary>
        /// <param name="onComplete"></param>
        public void AddStateCompleteListener(System.Action<string> onComplete)
        {
            if (onComplete != null)
            {
                OnStateCompleted -= onComplete;
                OnStateCompleted += onComplete;
            }
        }

        /// <summary>
        /// 反注册状态播放结束监听
        /// </summary>
        /// <param name="onComplete"></param>
        public void RemoveStateCompleteListener(System.Action<string> onComplete)
        {
            if (onComplete != null)
            {
                OnStateCompleted -= onComplete;
            }
        }
        
        /// <summary>
        /// 注册状态结束监听
        /// </summary>
        /// <param name="onFinish"></param>
        public void AddStateFinishListener(System.Action<string> onFinish)
        {
            if (onFinish != null)
            {
                OnStateFinished -= onFinish;
                OnStateFinished += onFinish;
            }
        }

        /// <summary>
        /// 反注册状态结束监听
        /// </summary>
        /// <param name="onFinish"></param>
        public void RemoveStateFinishListener(System.Action<string> onFinish)
        {
            if (onFinish != null)
            {
                OnStateFinished -= onFinish;
            }
        }

        /// <summary>
        /// 清除所有监听
        /// </summary>
        public void RemoveAllListener()
        {
            OnStateEntered = null;
            OnStateCompleted = null;
            OnStateFinished = null;
        }

        public void OnStateBegin(Layer layer, string stateName)
        {
            X3Debug.LogFormat("OnStateBegin: {0}", stateName);
            OnStateEntered?.Invoke(stateName);
            OnStateEnterForSequence(stateName);
        }

        public void OnStateEnd(Layer layer, string stateName)
        {
            X3Debug.LogFormat("OnStateEnd: {0}", stateName);
            OnStateCompleted?.Invoke(stateName);
        }

        public void OnStateChanged(Layer layer, string prevStateName, string nextStateName)
        {
            X3Debug.LogFormat("OnStateChanged: {0} -> {1}", prevStateName, nextStateName);
            if (!string.IsNullOrEmpty(prevStateName))
                OnStateFinished?.Invoke(prevStateName);
        }

        #endregion

        #region Animator Context

        private Context m_AnimatorContext;

        private Context AnimatorContext
        {
            get
            {
                if (m_AnimatorContext == null)
                {
                    m_AnimatorContext = new Context();
                    m_AnimatorContext.Animator = Animator;
                    m_AnimatorContext.Tag = Tag;
                    m_AnimatorContext.AnimationTree = this.AnimationTree;
                    m_AnimatorContext.RootBone = RootBone;
                    m_AnimatorContext.InheritTransform = InheritTransform;
                    m_AnimatorContext.RegisterCtsPlayIdAction = (playId) => { RegisterCtsPlayID(playId, null); };
                    m_AnimatorContext.X3Animator = this;
                }

                return m_AnimatorContext;
            }
        }

        public class Context
        {
            public Animator Animator { set; get; }
            public Transform RootBone { set; get; }
            public int Tag { set; get; }
            public GenericAnimationTree AnimationTree { set; get; }
            public bool InheritTransform { set; get; }
            public System.Action<int> RegisterCtsPlayIdAction { set; get; }
            public X3Animator X3Animator { set; get; }
        }

        #endregion

        #region For Debug Purpose

        public static bool LogEnabled { set; get; } = false;

        #endregion

        #region Others

        public void PhysicsSmoothBlendCurrentPose(bool force = false)
        {
            if (!force && AssetId == 0)
                return;
            var comp = GetComponent<X3Character>();
            if (comp != null)
                comp.PhysicsSmoothBlendCurrentPose();
        }

        #endregion
    }
}