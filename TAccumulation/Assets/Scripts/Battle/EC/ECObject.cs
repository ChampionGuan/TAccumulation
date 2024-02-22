using System;
using Unity.Profiling;

namespace X3Battle
{
    public interface IECObject
    {
        string name { get; set; }
        bool enabled { get; set; }
        void Awake();
        void Start();
        void Destroy();
        void Update();
        void AnimationJobRunning();
        void LateUpdate();
        void PhysicalJobRunning();
        void FixedUpdate();
    }

    public class ECObject : IECObject
    {
        public string name { get; set; }
        public bool enabled { get; set; } = true;

        private InternalStateType _stateType = InternalStateType.None;
        public bool isAwakened => _stateType == InternalStateType.Awakened || _stateType == InternalStateType.Started;
        public bool isStarted => _stateType == InternalStateType.Started;
        public bool isDestroyed => _stateType == InternalStateType.Destroyed;

        public ProfilerMarker namePMarker { get; }
        private ProfilerMarker _awakePMarker;
        private ProfilerMarker _startPMarker;
        private ProfilerMarker _updatePMarker;
        private ProfilerMarker _animationJobRunningPMarker;
        private ProfilerMarker _lateUpdatePMarker;
        private ProfilerMarker _physicalJobRunningPMarker;
        private ProfilerMarker _fixedUpdatePMarker;

        public ECObject(string name = null)
        {
            this.name = name ?? GetType().Name;
            namePMarker = new ProfilerMarker(this.name);
            _awakePMarker = new ProfilerMarker($"{this.name}.OnAwake()");
            _startPMarker = new ProfilerMarker($"{this.name}.OnStart()");
            _updatePMarker = new ProfilerMarker($"{this.name}.OnUpdate()");
            _animationJobRunningPMarker = new ProfilerMarker($"{this.name}.OnAnimationJobRunning()");
            _lateUpdatePMarker = new ProfilerMarker($"{this.name}.OnLateUpdate()");
            _physicalJobRunningPMarker = new ProfilerMarker($"{this.name}.OnPhysicalJobRunning()");
            _fixedUpdatePMarker = new ProfilerMarker($"{this.name}.OnFixedUpdate()");
        }

        public void Awake()
        {
            if (isAwakened)
            {
                return;
            }

            _stateType = InternalStateType.Awakened;
            enabled = true;

            using (_awakePMarker.Auto())
            {
                try
                {
                    OnAwake();
                }
                catch (Exception e)
                {
                    PapeGames.X3.LogProxy.LogFatal(e);
                }
            }
        }

        public void Start()
        {
            if (isStarted || !isAwakened)
            {
                return;
            }

            using (_startPMarker.Auto())
            {
                try
                {
                    OnStart();
                }
                catch (Exception e)
                {
                    PapeGames.X3.LogProxy.LogFatal(e);
                }
            }

            _stateType = InternalStateType.Started;
        }

        public void Destroy()
        {
            if (isDestroyed)
            {
                return;
            }

            enabled = false;
            _stateType = InternalStateType.Destroyed;
            try
            {
                OnDestroy();
            }
            catch (Exception e)
            {
                PapeGames.X3.LogProxy.LogFatal(e);
            }
        }

        public void Update()
        {
            if (!enabled || !isStarted || isDestroyed)
            {
                return;
            }

            using (_updatePMarker.Auto())
            {
                OnUpdate();
            }
        }

        public void AnimationJobRunning()
        {
            if (!enabled || !isStarted || isDestroyed)
            {
                return;
            }

            using (_animationJobRunningPMarker.Auto())
            {
                OnAnimationJobRunning();
            }
        }

        public void LateUpdate()
        {
            if (!enabled || !isStarted || isDestroyed)
            {
                return;
            }

            using (_lateUpdatePMarker.Auto())
            {
                OnLateUpdate();
            }
        }

        public void PhysicalJobRunning()
        {
            if (!enabled || !isStarted || isDestroyed)
            {
                return;
            }

            using (_physicalJobRunningPMarker.Auto())
            {
                OnPhysicalJobRunning();
            }
        }

        public void FixedUpdate()
        {
            if (!enabled || !isStarted || isDestroyed)
            {
                return;
            }

            using (_fixedUpdatePMarker.Auto())
            {
                OnFixedUpdate();
            }
        }

        protected virtual void OnAwake()
        {
        }

        protected virtual void OnStart()
        {
        }

        protected virtual void OnDestroy()
        {
        }

        protected virtual void OnUpdate()
        {
        }

        protected virtual void OnAnimationJobRunning()
        {
        }

        protected virtual void OnLateUpdate()
        {
        }

        protected virtual void OnPhysicalJobRunning()
        {
        }

        protected virtual void OnFixedUpdate()
        {
        }

        private enum InternalStateType
        {
            None,
            Awakened,
            Started,
            Destroyed,
        }
    }
}