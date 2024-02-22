using System;

namespace X3.CustomEvent
{
    public class ExecutableEvent<T0, T1, T2, T3, T4> : BaseExecutableEvent
    {
        private T0 m_Param0;
        private T1 m_Param1;
        private T2 m_Param2;
        private T3 m_Param3;
        private T4 m_Param4;

        public void SetParams(T0 param0, T1 param1, T2 param2, T3 param3, T4 param4)
        {
            m_Param0 = param0;
            m_Param1 = param1;
            m_Param2 = param2;
            m_Param3 = param3;
            m_Param4 = param4;
        }

        protected override void Invoke(Delegate call)
        {
            ((Action<T0, T1, T2, T3, T4>)call)?.Invoke(m_Param0, m_Param1, m_Param2, m_Param3, m_Param4);
        }

        protected override void OnReset()
        {
            m_Param0 = default;
            m_Param1 = default;
            m_Param2 = default;
            m_Param3 = default;
            m_Param4 = default;
        }
    }

    public class CustomEvent<T0, T1, T2, T3, T4> : BaseCustomEvent<Action<T0, T1, T2, T3, T4>, ExecutableEvent<T0, T1, T2, T3, T4>>
    {
        public void Dispatch(T0 param0, T1 param1, T2 param2, T3 param3, T4 param4)
        {
            if (!TryGetCallList(out var listNode, out var nodeValue))
            {
                return;
            }

            nodeValue.SetParams(param0, param1, param2, param3, param4);
            InvokeCallList(listNode);
        }
    }
}