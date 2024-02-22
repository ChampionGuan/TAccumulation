using System;
using System.Runtime.InteropServices;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("破盾虚弱结束\nWeakEnd")]
    public class FEWeakEnd : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventWeakEnd _eventWeakEnd;
        private Action<EventWeakEnd> _actionOnWeakEnd;

        public FEWeakEnd()
        {
            _actionOnWeakEnd = _WeakEnd; 
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("Actor", () => _eventWeakEnd?.actor);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventWeakEnd>(EventType.WeakEnd, _actionOnWeakEnd, "FEWeakEnd._WeakEnd");    
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventWeakEnd>(EventType.WeakEnd, _actionOnWeakEnd);
        }

        private void _WeakEnd(EventWeakEnd arg)
        {
            if (_isTriggering || arg == null)
                return;
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.actor))
                return;
            _eventWeakEnd = arg;
            _Trigger();
            _eventWeakEnd = null;
        }
    }
}
