using System;

namespace X3Battle
{
    public interface IECEntity : IECObject
    {
        int insID { get; }
        IECComponent[] comps { get; }
        T AddComponent<T>(T comp) where T : class, IECComponent;
        T GetComponent<T>(int type) where T : class, IECComponent;
        void RemoveComponent(int type);
    }

    public class ECEntity : ECObject, IECEntity
    {
        private static int _nextInsID = 1;

        public int insID { get; }
        public IECComponent[] comps { get; }

        public ECEntity(int compsCount, string name = null) : base(name)
        {
            insID = _nextInsID++;
            if (compsCount > 0)
            {
                comps = new IECComponent[compsCount];
            }
        }

        protected override void OnAwake()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = 0; i < comps.Length; i++)
            {
                comps[i]?.Awake();
            }
        }

        protected override void OnStart()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = 0; i < comps.Length; i++)
            {
                comps[i]?.Start();
            }
        }

        protected override void OnDestroy()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = comps.Length - 1; i >= 0; i--)
            {
                comps[i]?.Destroy();
            }
        }

        protected override void OnUpdate()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = 0; i < comps.Length; i++)
            {
                var behavior = comps[i];
                if (enabled && null != behavior && behavior.enabled && behavior.requiredUpdate)
                {
                    comps[i].Update();
                }
            }
        }

        protected override void OnAnimationJobRunning()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = 0; i < comps.Length; i++)
            {
                var behavior = comps[i];
                if (enabled && null != behavior && behavior.enabled && behavior.requiredAnimationJobRunning)
                {
                    comps[i].AnimationJobRunning();
                }
            }
        }

        protected override void OnLateUpdate()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = 0; i < comps.Length; i++)
            {
                var behavior = comps[i];
                if (enabled && null != behavior && behavior.enabled && behavior.requiredLateUpdate)
                {
                    comps[i].LateUpdate();
                }
            }
        }

        protected override void OnPhysicalJobRunning()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = 0; i < comps.Length; i++)
            {
                var behavior = comps[i];
                if (enabled && null != behavior && behavior.enabled && behavior.requiredPhysicalJobRunning)
                {
                    comps[i].PhysicalJobRunning();
                }
            }
        }

        protected override void OnFixedUpdate()
        {
            if (null == comps)
            {
                return;
            }

            for (var i = 0; i < comps.Length; i++)
            {
                var behavior = comps[i];
                if (enabled && null != behavior && behavior.enabled && behavior.requiredFixedUpdate)
                {
                    comps[i].FixedUpdate();
                }
            }
        }

        public T AddComponent<T>(params object[] args) where T : class, IECComponent
        {
            return AddComponent(typeof(T), args) as T;
        }

        public IECComponent AddComponent(Type type, params object[] args)
        {
            return null == args ? AddComponent((IECComponent)Activator.CreateInstance(type)) : AddComponent((IECComponent)Activator.CreateInstance(type, args));
        }

        public IECComponent GetComponent(Type type)
        {
            for (var i = 0; comps != null && i < comps.Length; i++)
            {
                var behavior = comps[i];
                if (null == behavior)
                {
                    continue;
                }

                var baseType = behavior.GetType();
                while (null != baseType)
                {
                    if (type == baseType)
                    {
                        return behavior;
                    }

                    baseType = baseType.BaseType;
                }
            }

            return null;
        }

        public T GetComponent<T>(int type) where T : class, IECComponent
        {
            return comps[type] as T;
        }

        public T GetComponent<T>() where T : class, IECComponent
        {
            return GetComponent(typeof(T)) as T;
        }

        public T AddComponent<T>(T comp) where T : class, IECComponent
        {
            if (comp.entity != null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("Entity(type={0} already has parent!", comp.type);
                return null;
            }

            if (comps[comp.type] != null)
            {
                PapeGames.X3.LogProxy.LogWarningFormat("Entity(type={0}) already exits!", comp.type);
                return comps[comp.type] as T;
            }

            comps[comp.type] = comp;
            comp.entity = this;

            if (isAwakened)
            {
                comp.Awake();
            }

            if (isStarted)
            {
                comp.Start();
            }

            return comp;
        }

        public void RemoveComponent(IECComponent comp)
        {
            if (comps[comp.type] != comp)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("comp(type={0}) not belong to this, can't be removed!", comp.type);
                return;
            }

            comp.Destroy();
            comps[comp.type] = null;
        }

        public void RemoveComponent(int type)
        {
            var comp = comps[type];
            if (null == comp)
            {
                return;
            }

            comp.Destroy();
            comps[comp.type] = null;
        }
    }
}