using System;

namespace X3.CustomEvent
{
    public class ExecutableEvent : BaseExecutableEvent
    {
        protected override void Invoke(Delegate call)
        {
            ((Action)call)?.Invoke();
        }

        protected override void OnReset()
        {
        }
    }

    public class CustomEvent : BaseCustomEvent<Action, ExecutableEvent>
    {
        public void Dispatch()
        {
            if (!TryGetCallList(out var listNode, out _))
            {
                return;
            }

            InvokeCallList(listNode);
        }
    }
}