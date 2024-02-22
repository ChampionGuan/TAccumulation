using System;

namespace X3.CustomEvent
{
    public class ExecutableEvent<T0, T1, T2> : BaseExecutableEvent
    {
        private T0 m_Param0;
        private T1 m_Param1;
        private T2 m_Param2;

        public void SetParams(T0 param0, T1 param1, T2 param2)
        {
            m_Param0 = param0;
            m_Param1 = param1;
            m_Param2 = param2;
        }

        protected override void Invoke(Delegate call)
        {
            ((Action<T0, T1, T2>)call)?.Invoke(m_Param0, m_Param1, m_Param2);
        }

        protected override void OnReset()
        {
            m_Param0 = default;
            m_Param1 = default;
            m_Param2 = default;
        }
    }

    public class CustomEvent<T0, T1, T2> : BaseCustomEvent<Action<T0, T1, T2>, ExecutableEvent<T0, T1, T2>>
    {
        public void Dispatch(T0 param0, T1 param1, T2 param2)
        {
            if (!TryGetCallList(out var listNode, out var nodeValue))
            {
                return;
            }

            nodeValue.SetParams(param0, param1, param2);
            InvokeCallList(listNode);
        }
    }
}