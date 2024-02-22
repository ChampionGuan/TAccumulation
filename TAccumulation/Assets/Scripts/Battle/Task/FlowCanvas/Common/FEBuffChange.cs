using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("Buff变化\nBuffChange")]
    public class FEBuffChange : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventBuffChange _eventBuffChange;

        private Action<EventBuffChange> _actionOnBuffChange;

        public FEBuffChange()
        {
            _actionOnBuffChange = _OnBuffChange;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventBuffChange>(nameof(EventBuffChange), () => _eventBuffChange);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange, "FEBuffChange._OnBuffChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange);
        }

        protected void _OnBuffChange(EventBuffChange arg)
        {
            if (_isTriggering || arg == null)
                return;
            if (arg.buff == null)
                return;
            // DONE: 判断主体
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.buff.owner))
                return;
            // DONE: 设置参数.
            _eventBuffChange = arg;
            _Trigger();
            _eventBuffChange = null;
        }
    }
}
