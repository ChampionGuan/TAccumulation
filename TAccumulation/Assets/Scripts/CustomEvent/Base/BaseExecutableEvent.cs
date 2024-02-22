using System;
using System.Collections.Generic;
using Unity.Profiling;

namespace X3.CustomEvent
{
    public abstract class BaseExecutableEvent
    {
        private LinkedList<DelegateInfo> m_CallList = new LinkedList<DelegateInfo>();

        public void Reset()
        {
            while (m_CallList.Count > 0)
            {
                var node = m_CallList.First;
                m_CallList.Remove(node);
                Pool.Recycle(node);
            }

            m_CallList.Clear();
            OnReset();
        }

        public void Remove(Delegate call)
        {
            if (m_CallList.Count <= 0)
            {
                return;
            }

            var node = m_CallList.First;
            while (true)
            {
                var next = node.Next;
                if (node.Value.call == call)
                {
                    m_CallList.Remove(node);
                    Pool.Recycle(node);
                }

                node = next;
                if (ReferenceEquals(node, null))
                {
                    break;
                }
            }
        }

        public void SetCalls(LinkedList<DelegateInfo> calls)
        {
            if (ReferenceEquals(calls, null))
            {
                return;
            }

            if (m_CallList.Count > 0)
            {
                m_CallList.Clear();
                Utils.LogFatal("Event.SetCalls()内部执行异常，请联系程序进行检查！！");
            }

            var node = calls.Last;
            while (true)
            {
                m_CallList.AddFirst(Pool.Get(node.Value.call, node.Value.profilerTag));
                node = node.Previous;
                if (ReferenceEquals(node, null))
                {
                    break;
                }
            }
        }

        public void InvokeCalls()
        {
            while (m_CallList.Count > 0)
            {
                var node = m_CallList.First;
                try
                {
                    m_CallList.Remove(node);

#if ENABLE_PROFILER
                    ProfilerMarker pMarker;
                    if (!string.IsNullOrEmpty(node.Value.profilerTag))
                    {
                        pMarker = new ProfilerMarker(node.Value.profilerTag);
                    }
                    else
                    {
                        pMarker = Utils.getProfilerMarkerFunc?.Invoke(node.Value.call) ?? Utils.CallInvokePMarker;
                    }

                    using (pMarker.Auto())
                    {
                        Invoke(node.Value.call);
                    }
#else
                    Invoke(node.Value.call);
#endif
                }
                catch (Exception e)
                {
                    Utils.LogFatal($"Event.Invoke()执行异常，请检查！ ErrorMsg:{e}");
                }

                Pool.Recycle(node);
            }
        }

        protected abstract void Invoke(Delegate call);

        protected abstract void OnReset();
    }
}