using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
#if UNITY_EDITOR
    using System.Reflection;
#endif

namespace X3Battle.Timeline.Extension
{
    // 直接RunTime+ClipAsset合一了
    // 子类public字段都会被序列化，定义的时候需要注意，不需要需列化的定义为非public，或者加上[NonSerialized]标识
    [Serializable]
    public abstract class PreviewActionAsset : InterruptClip, IAction
    {
        // debug信息
        [NonSerialized]
        public TrackAsset mDebugTrack;
        
        [NonSerialized]
        public TimelineAsset mDebugTimeline;

        // 创建可打断的轨道behaviour
        protected sealed override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            // 运行时
            var playable = ScriptPlayable<PreviewActionBehaviour>.Create(graph);
            PreviewActionBehaviour behaviour = playable.GetBehaviour();
            behaviour.SetStartImmediately(true);
            behaviour.SetRunTimeAction(this);
            behaviour.SetContext(_clipPreviewActionIContext);
            var param = _CreateParam();
            behaviour.SetParam(param);
            behaviour.SetBattleTimeline(_clipBattleBattleSequencer);
            interruptBehaviourParam = behaviour;
            // 初始化clip
            ((IAction)this).Init(behaviour);
            return playable;
        }
        

        // 环境包, 每当实例化Graph时会被设置一次
        private PreviewActionIContext _clipPreviewActionIContext;

        public void SetClipContext(PreviewActionIContext previewActionIContext)
        {
            _clipPreviewActionIContext = previewActionIContext;
        }
        
        // Clip所属的逻辑Timeline，每当实例化Graph时会被设置一次
        private BattleSequencer _clipBattleBattleSequencer;

        public void SetClipBattleTimeline(BattleSequencer logicBattleSequencer)
        {
            _clipBattleBattleSequencer = logicBattleSequencer;
        }
        
        // 创建Behaviour时创建变量包
        private ActionParam _CreateParam()
        {
            return OnCreateParam();
        }
        
        // 当前Behaviour
        private PreviewActionBehaviour _curBehaviour;
        
        // 获取当前的BattleTimeline
        protected BattleSequencer battleBattleSequencer 
        {
            get
            {
                return _curBehaviour.battleBattleSequencer;
            }
        }

        // 获取当前的 context
        protected PreviewActionIContext previewActionIContext
        {
            get
            {
                return _curBehaviour.previewActionIContext;
            }
        }
        
        // 获取当前的 param
        protected ActionParam _param
        {
            get
            {
                return _curBehaviour.param;
            }
        }
        
        protected T GetParam<T>() where T: ActionParam
        {
            return _param as T;
        }

        // 获取开始时间
        protected float _startTime
        {
            get 
            {
                return _curBehaviour.startTime;
            }
        }
        
        /// <summary>
        /// _startTime
        /// </summary>
        /// <returns></returns>
        public float startTime
        {
            get { return _startTime; }
        }
        
        public float curTime
        {
            get { return _curTime; }
        }
        // 获取当前时间
        protected float _curTime
        {
            get 
            {
                return _curBehaviour.curTime;
            }
        }
        
        // 获取剩余时间 (持续时长-当前时间)
        public float remainTime
        {
            get 
            {
                return _duration - _curTime;
            }
        }

        // 获取帧间隔时间
        protected float _deltaTime
        {
            get 
            {
                return _curBehaviour.deltaTime;
            }
        }

        void IAction.Init(PreviewActionBehaviour behaviour)
        {
            _curBehaviour = behaviour;
            if (Application.isPlaying)
            {
                // OnInit();
            }
            else
            {
                OnEditorInit();   
            }
        }

        void IAction.Enter(PreviewActionBehaviour behaviour)
        {
            _curBehaviour = behaviour;
            if (_startTime >= GetDuration())
            {
               PapeGames.X3.LogProxy.LogErrorFormat("timeline错误，出现了从end开始播的clip！{0} {1} {2}", mDebugTimeline.name, mDebugTrack.name, name); 
            }
            if (Application.isPlaying)
            {
                // OnEnter(); 
            }
            else
            {
                OnEditorEnter();
            }
        }

        void IAction.Update(PreviewActionBehaviour behaviour)
        {
            _curBehaviour = behaviour;
            if (Application.isPlaying)
            {
                // OnUpdate();
            }
            else
            {
                OnEditorUpdate(_deltaTime);
            }
        }

        void IAction.Exit(PreviewActionBehaviour behaviour)
        {
            _curBehaviour = behaviour;
            if (Application.isPlaying)
            {
                // OnExit();
            }
            else
            {
                OnEditorExit();   
            }
        }

        void IAction.Destroy(PreviewActionBehaviour behaviour)
        {
            _curBehaviour = behaviour;
            if (Application.isPlaying)
            {
                // OnExit();
            }
            else
            {
                OnEditorDestroy();   
            }
        }

        #region 避免子类误操作
        
        public sealed override double duration => base.duration;
        public sealed override IEnumerable<PlayableBinding> outputs => base.outputs;
        protected sealed override ClipCaps OnGetClipCaps() 
        {
            return base.OnGetClipCaps();
        }
        
        #endregion

        // 获取持续时长
        private float _duration;
        
        public float GetDuration()
        {
            return _duration;
        }
        
        public void SetDuration(float value)
        {
            _duration = value;
        }

        // protected virtual void OnInit()
        // {}
        //
        // protected virtual void OnEnter()
        // {}
        //
        // protected virtual void OnUpdate()
        // {}
        //
        // protected virtual void OnExit()
        // {}

        protected virtual ActionParam OnCreateParam()
        {
            return null;
        }
        
// ----------------↓↓↓↓↓↓↓----------- 预览代码 ----------------↓↓↓↓↓↓↓--------------------        
#if UNITY_EDITOR
        private List<PreviewActionBase> _previewActionBases;
#endif
        
        // 非运行时初始化
        private void OnEditorInit()
        {
#if UNITY_EDITOR
            _previewActionBases = null;
            var creators = this.GetType().GetCustomAttributes<PreviewActionCreator>();
            foreach (var creator in creators)
            {
                if (_previewActionBases == null)
                {
                    _previewActionBases = new List<PreviewActionBase>();   
                }   
                var previewAction = creator.CreatePreviewAction(this);
                _previewActionBases.Add(previewAction);
            }
#endif
        }
        
        // 非运行时进入
        private void OnEditorEnter()
        {
#if UNITY_EDITOR
            if (_previewActionBases != null)
            {
                foreach (var item in _previewActionBases)
                {
                    item.Enter();
                }
            }
#endif         
        }

        // 非运行时更新
        private void OnEditorUpdate(float deltaTime)
        {
#if UNITY_EDITOR
            if (_previewActionBases != null)
            {
                foreach (var item in _previewActionBases)
                {
                    item.Update(deltaTime);
                }
            }
#endif
        }

        // 非运行时退出
        private void OnEditorExit()
        {
#if UNITY_EDITOR      
            if (_previewActionBases != null)
            {
                foreach (var item in _previewActionBases)
                {
                    item.Exit();
                }
            }
#endif
        } 
        
        // 非运行时销毁
        private void OnEditorDestroy()
        {
#if UNITY_EDITOR      
            if (_previewActionBases != null)
            {
                foreach (var item in _previewActionBases)
                {
                    item.Destroy();
                }
            }
#endif
        } 
        // -----------------↑↑↑↑↑↑↑--------------- 预览代码 -----------↑↑↑↑↑↑↑----------------- 
    }
}