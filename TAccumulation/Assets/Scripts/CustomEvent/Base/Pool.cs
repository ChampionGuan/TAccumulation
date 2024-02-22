using System;
using System.Collections.Generic;

namespace X3.CustomEvent
{
    public static class Pool
    {
        private static Dictionary<Type, LinkedList<BaseExecutableEvent>> ExecutableCallNodeCache = new Dictionary<Type, LinkedList<BaseExecutableEvent>>();
        private static LinkedList<DelegateInfo> CallNodeCache = new LinkedList<DelegateInfo>();

        public static void Clear()
        {
            foreach (var list in ExecutableCallNodeCache.Values)
            {
                list.Clear();
            }

            CallNodeCache.Clear();
        }

        public static void Preload(int count)
        {
            count -= CallNodeCache.Count;
            while (count-- > 0)
            {
                Recycle(new LinkedListNode<DelegateInfo>(new DelegateInfo()));
            }
        }

        internal static LinkedListNode<DelegateInfo> Get(Delegate call, string profilerTag)
        {
            LinkedListNode<DelegateInfo> node;
            if (CallNodeCache.Count > 0)
            {
                node = CallNodeCache.First;
                CallNodeCache.RemoveFirst();
            }
            else
            {
                node = new LinkedListNode<DelegateInfo>(new DelegateInfo());
            }

            node.Value.call = call;
#if ENABLE_PROFILER
            node.Value.profilerTag = profilerTag;
#endif
            return node;
        }

        internal static void Recycle(LinkedListNode<DelegateInfo> node)
        {
            node.Value.Clear();
            CallNodeCache.AddLast(node);
        }

        internal static LinkedList<BaseExecutableEvent> EnsureExecutableCallCache<T>(int count = 1) where T : BaseExecutableEvent, new()
        {
            var type = typeof(T);
            if (!ExecutableCallNodeCache.TryGetValue(type, out var list))
            {
                list = new LinkedList<BaseExecutableEvent>();
                ExecutableCallNodeCache.Add(type, list);
            }
            else
            {
                count -= list.Count;
            }

            while (count-- > 0)
            {
                list.AddLast(new T());
            }

            return list;
        }
    }
}