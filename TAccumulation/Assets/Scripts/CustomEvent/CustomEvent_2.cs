using System;

namespace X3.CustomEvent
{
    public class ExecutableEvent<T0, T1> : BaseExecutableEvent
    {
        private T0 m_Param0;
        private T1 m_Param1;

        public void SetParams(T0 param0, T1 param1)
        {
            m_Param0 = param0;
            m_Param1 = param1;
        }

        protected override void Invoke(Delegate call)
        {
            ((Action<T0, T1>)call)?.Invoke(m_Param0, m_Param1);
        }

        protected override void OnReset()
        {
            m_Param0 = default;
            m_Param1 = default;
        }
    }

    public class CustomEvent<T0, T1> : BaseCustomEvent<Action<T0, T1>, ExecutableEvent<T0, T1>>
    {
        public void Dispatch(T0 param0, T1 param1)
        {
            if (!TryGetCallList(out var listNode, out var nodeValue))
            {
                return;
            }

            nodeValue.SetParams(param0, param1);
            InvokeCallList(listNode);
        }
    }
}