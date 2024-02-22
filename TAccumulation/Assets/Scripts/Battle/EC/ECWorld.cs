using System.Collections.Generic;

namespace X3Battle
{
    public class ECWorld : ECObject
    {
        private List<IECEntity> _entities;
        private int _iterationIndex;

        public ECEventMgr eventMgr { get; private set; }
        public float deltaTime { get; private set; }
        public float realTime { get; private set; }
        public int frameCount { get; private set; }

        public ECMultiLayerEvent onPostUpdate { get; protected set; }
        public ECMultiLayerEvent onPostAnimationJobRunning { get; protected set; }
        public ECMultiLayerEvent onPostLateUpdate { get; protected set; }
        public ECMultiLayerEvent onPostPhysicalJobRunning { get; protected set; }
        public ECMultiLayerEvent onPostFixedUpdate { get; protected set; }

        public IECEntity postUpdateEntity { get; protected set; }
        public IECEntity postLateUpdateEntity { get; protected set; }
        public IECEntity postFixedUpdateEntity { get; protected set; }

        public ECWorld(string name) : base(name)
        {
            _entities = new List<IECEntity>();
            eventMgr = new ECEventMgr();
        }

        public IECEntity GetEntity(int insID)
        {
            for (var i = 0; i < _entities.Count; i++)
            {
                if (_entities[i].insID == insID)
                {
                    return _entities[i];
                }
            }

            return null;
        }

        public T AddEntity<T>(T entity) where T : IECEntity
        {
            if (null == entity || null != GetEntity(entity.insID))
            {
                return entity;
            }

            _entities.Add(entity);
            return entity;
        }

        public void RemoveEntity(IECEntity entity)
        {
            if (null == entity)
            {
                return;
            }

            RemoveEntity(entity.insID);
        }

        public void RemoveEntity(int insID)
        {
            for (var i = 0; i < _entities.Count; i++)
            {
                if (_entities[i].insID != insID)
                {
                    continue;
                }

                if (i <= _iterationIndex)
                {
                    _iterationIndex--;
                }

                _entities.RemoveAt(i);
                break;
            }
        }

        public new void Update()
        {
        }

        public void Update(float deltaTime)
        {
            if (!enabled || !isStarted || isDestroyed)
            {
                return;
            }

            frameCount++;
            this.deltaTime = deltaTime;
            realTime += deltaTime;
            OnUpdate();
        }

        protected override void OnAwake()
        {
            for (var i = 0; i < _entities.Count; i++)
            {
                _entities[i].Awake();
            }
        }

        protected override void OnStart()
        {
            for (var i = 0; i < _entities.Count; i++)
            {
                _entities[i].Start();
            }
        }

        protected override void OnUpdate()
        {
            for (_iterationIndex = 0; _iterationIndex < _entities.Count; _iterationIndex++)
            {
                _entities[_iterationIndex].Update();
            }

            postUpdateEntity?.Update();
            onPostUpdate?.Invoke();
        }

        protected override void OnAnimationJobRunning()
        {
            for (_iterationIndex = 0; _iterationIndex < _entities.Count; _iterationIndex++)
            {
                _entities[_iterationIndex].AnimationJobRunning();
            }

            onPostAnimationJobRunning?.Invoke();
        }

        protected override void OnLateUpdate()
        {
            for (_iterationIndex = 0; _iterationIndex < _entities.Count; _iterationIndex++)
            {
                _entities[_iterationIndex].LateUpdate();
            }

            postLateUpdateEntity?.LateUpdate();
            onPostLateUpdate?.Invoke();
        }

        protected override void OnPhysicalJobRunning()
        {
            for (_iterationIndex = 0; _iterationIndex < _entities.Count; _iterationIndex++)
            {
                _entities[_iterationIndex].PhysicalJobRunning();
            }

            onPostPhysicalJobRunning?.Invoke();
        }

        protected override void OnFixedUpdate()
        {
            for (_iterationIndex = 0; _iterationIndex < _entities.Count; _iterationIndex++)
            {
                _entities[_iterationIndex].FixedUpdate();
            }

            postFixedUpdateEntity?.FixedUpdate();
            onPostFixedUpdate?.Invoke();
        }

        protected override void OnDestroy()
        {
            for (var i = _entities.Count - 1; i >= 0; i--)
            {
                _entities[i]?.Destroy();
            }

            _entities.Clear();

            postUpdateEntity?.Destroy();
            postLateUpdateEntity?.Destroy();
            postFixedUpdateEntity?.Destroy();

            onPostUpdate?.Clear();
            onPostLateUpdate?.Clear();
            onPostFixedUpdate?.Clear();
            onPostAnimationJobRunning?.Clear();
            onPostPhysicalJobRunning?.Clear();
            eventMgr.Clear();
            realTime = 0;
            frameCount = 0;
        }
    }
}