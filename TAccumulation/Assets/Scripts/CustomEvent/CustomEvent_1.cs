using System;

namespace X3.CustomEvent
{
    public class ExecutableEvent<T> : BaseExecutableEvent
    {
        private T m_Param;

        public void SetParams(T param)
        {
            m_Param = param;
        }

        protected override void Invoke(Delegate call)
        {
            ((Action<T>)call)?.Invoke(m_Param);
        }

        protected override void OnReset()
        {
            m_Param = default;
        }
    }

    public class CustomEvent<T> : BaseCustomEvent<Action<T>, ExecutableEvent<T>>
    {
        public void Dispatch(T param)
        {
            if (!TryGetCallList(out var listNode, out var nodeValue))
            {
                return;
            }

            nodeValue.SetParams(param);
            InvokeCallList(listNode);
        }
    }
}