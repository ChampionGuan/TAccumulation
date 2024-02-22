using System;
using System.Collections.Generic;

namespace X3.CustomEvent
{
    public class DelegateInfo
    {
        public string profilerTag;
        public Delegate call;

        public void Clear()
        {
            profilerTag = null;
            call = null;
        }
    }

    public abstract class BaseCustomEvent<T1, T2> where T1 : Delegate where T2 : BaseExecutableEvent, new()
    {
        private LinkedList<BaseExecutableEvent> m_ExecutableCallCache;
        private LinkedList<BaseExecutableEvent> m_ExecutableCallList;
        private LinkedList<DelegateInfo> m_RuntimeCallList;

        public BaseCustomEvent()
        {
            m_RuntimeCallList = new LinkedList<DelegateInfo>();
            m_ExecutableCallList = new LinkedList<BaseExecutableEvent>();
            m_ExecutableCallCache = Pool.EnsureExecutableCallCache<T2>();
        }

        public void Clear()
        {
            while (m_RuntimeCallList.Count > 0)
            {
                var first = m_RuntimeCallList.First;
                m_RuntimeCallList.Remove(first);
                Pool.Recycle(first);
            }

            while (m_ExecutableCallList.Count > 0)
            {
                var first = m_ExecutableCallList.First;
                first.Value.Reset();
                m_ExecutableCallList.Remove(first);
                m_ExecutableCallCache.AddLast(first);
            }
        }

        public void RemoveListener(T1 call)
        {
            if (null == call)
            {
                return;
            }

            if (m_RuntimeCallList.Count > 0)
            {
                var node = m_RuntimeCallList.First;
                while (true)
                {
                    var next = node.Next;
                    if (node.Value.call == call)
                    {
                        m_RuntimeCallList.Remove(node);
                        Pool.Recycle(node);
                    }

                    node = next;
                    if (ReferenceEquals(node, null))
                    {
                        break;
                    }
                }
            }

            if (m_ExecutableCallList.Count > 0)
            {
                var node = m_ExecutableCallList.First;
                while (true)
                {
                    var next = node.Next;
                    node.Value.Remove(call);
                    node = next;
                    if (ReferenceEquals(node, null))
                    {
                        break;
                    }
                }
            }
        }

        public void AddListener(T1 call, string profilerTag = null)
        {
            if (ReferenceEquals(call, null))
            {
                return;
            }

            foreach (var node in m_RuntimeCallList)
            {
                if (node.call == call)
                {
                    return;
                }
            }

            m_RuntimeCallList.AddLast(Pool.Get(call, profilerTag));
        }

        internal bool TryGetCallList(out LinkedListNode<BaseExecutableEvent> listNode, out T2 nodeValue)
        {
            using (Utils.GetPMarker.Auto())
            {
                listNode = null;
                nodeValue = null;
                var listCount = m_RuntimeCallList.Count;
                if (listCount <= 0)
                {
                    return false;
                }

                if (m_ExecutableCallCache.Count > 0)
                {
                    listNode = m_ExecutableCallCache.First;
                    m_ExecutableCallCache.RemoveFirst();
                }
                else
                {
                    listNode = new LinkedListNode<BaseExecutableEvent>(new T2());
                }

                nodeValue = listNode.Value as T2;
                listNode.Value.SetCalls(m_RuntimeCallList);
                return true;
            }
        }

        internal void InvokeCallList(LinkedListNode<BaseExecutableEvent> listNode)
        {
            using (Utils.CallListInvokePMarker.Auto())
            {
                if (m_ExecutableCallList.Count >= Utils.MAX_STACK_DEPTH)
                {
                    Utils.LogFatal($"Event.Invoke()执行异常，当前调用堆栈深度已达{Utils.MAX_STACK_DEPTH}层，请确认调用逻辑是否进入死循环！！");
                }
                else
                {
                    m_ExecutableCallList.AddLast(listNode);
                    listNode.Value.InvokeCalls();
                    m_ExecutableCallList.Remove(listNode);
                }

                listNode.Value.Reset();
                m_ExecutableCallCache.AddLast(listNode);
            }
        }
    }
}