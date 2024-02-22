using System;
using System.Collections.Generic;

namespace X3.CustomEvent
{
    /// <summary>
    /// 事件监听器的管理器
    /// 注意：目前只支持单参的事件注册
    /// </summary>
    public class EventMgr<TKey>
    {
        public static readonly Type BaseListenerType = typeof(IEventListener);

        private CustomEvent<TKey, IEventData> m_AnyEventListener = new CustomEvent<TKey, IEventData>();
        private Dictionary<TKey, IEventListener> m_EventListeners = new Dictionary<TKey, IEventListener>();
        private Dictionary<Type, Stack<IEventData>> m_EventDataCache = new Dictionary<Type, Stack<IEventData>>();

        public void Preload(TKey key, Type listenerType)
        {
            if (!BaseListenerType.IsAssignableFrom(listenerType))
            {
                return;
            }

            _GetListener(key, listenerType);
            var arguments = listenerType.GetGenericArguments();
            if (arguments.Length <= 0) return;

            var eventDataType = arguments[0];
            var data = GetEvent(eventDataType);
            ReleaseEvent(data);
        }

        public void Clear()
        {
            foreach (var list in m_EventDataCache.Values)
            {
                list.Clear();
            }

            foreach (var listener in m_EventListeners.Values)
            {
                listener.Clear();
            }

            m_AnyEventListener.Clear();
        }

        public T GetEvent<T>() where T : class, IEventData, new()
        {
            return GetEvent(typeof(T)) as T;
        }

        public IEventData GetEvent(Type eventType)
        {
            if (!m_EventDataCache.TryGetValue(eventType, out var stack) || stack.Count < 1)
            {
                return Activator.CreateInstance(eventType) as IEventData;
            }

            return stack.Pop();
        }

        public void ReleaseEvent(IEventData eventData)
        {
            if (null == eventData)
            {
                return;
            }

            var type = eventData.GetType();
            if (!m_EventDataCache.ContainsKey(type))
            {
                m_EventDataCache.Add(type, new Stack<IEventData>());
            }
            else if (m_EventDataCache[type].Contains(eventData))
            {
                return;
            }

            m_EventDataCache[type].Push(eventData);
            eventData.OnRecycle();
        }

        public void AddListener<T>(TKey key, Action<T> func, string profilerTag) where T : IEventData
        {
            if (null == func) return;
            _GetListener(key, typeof(EventListener<T>))?.AddListener(func, profilerTag);
        }

        public void RemoveListener<T>(TKey key, Action<T> func) where T : IEventData
        {
            _GetListener(key, typeof(EventListener<T>))?.RemoveListener(func);
        }

        public void AddListener(Action<TKey, IEventData> func, string profilerMarker)
        {
            if (null == func) return;
            m_AnyEventListener.AddListener(func, profilerMarker);
        }

        public void RemoveListener(Action<TKey, IEventData> func)
        {
            m_AnyEventListener.RemoveListener(func);
        }

        public void Dispatch(TKey key, IEventData arg, bool autoRecycle = true)
        {
            using (Utils.EventMgrDispatchPMarker.Auto())
            {
                if (m_EventListeners.TryGetValue(key, out var listener)) listener.Dispatch(arg);
                m_AnyEventListener.Dispatch(key, arg);
            }

            if (autoRecycle) ReleaseEvent(arg);
        }

        private IEventListener _GetListener(TKey key, Type listenerType)
        {
            if (m_EventListeners.TryGetValue(key, out var listener))
            {
                if (listener.GetType() == listenerType)
                {
                    return listener;
                }

                Utils.LogFatal($"【事件系统】有相同EventKey：{key}，注册了不同类型的事件监听：{listenerType}，当前已注册类型：{listener.GetType()}，请留意检查！！");
                return null;
            }

            listener = Activator.CreateInstance(listenerType) as IEventListener;
            m_EventListeners[key] = listener;
            return listener;
        }
    }

    public interface IEventData
    {
        void OnRecycle();
    }

    public interface IEventListener
    {
        void AddListener(Delegate func, string profilerTag);
        void RemoveListener(Delegate func);
        void Dispatch(IEventData arg);
        void Clear();
    }

    public class EventListener<T> : CustomEvent<T>, IEventListener where T : IEventData
    {
        public void AddListener(Delegate func, string profilerTag)
        {
            base.AddListener((Action<T>)func, profilerTag);
        }

        public void RemoveListener(Delegate func)
        {
            base.RemoveListener((Action<T>)func);
        }

        public void Dispatch(IEventData arg)
        {
            base.Dispatch((T)arg);
        }
    }
}