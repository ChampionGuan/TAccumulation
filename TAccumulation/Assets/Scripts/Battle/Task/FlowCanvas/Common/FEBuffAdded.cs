using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("Buff被添加（被动）\nBuffAdded")]
    public class FEBuffAdded : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventBuffChange _eventBuffChange;

        private Action<EventBuffChange> _actionOnBuffChange;

        public FEBuffAdded()
        {
            _actionOnBuffChange = _OnBuffChange;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("BuffCaster", () => _eventBuffChange?.caster);
            AddValueOutput<Actor>("BuffTarget", () => _eventBuffChange?.target);
            AddValueOutput<IBuff>("IBuff", () => _eventBuffChange?.buff);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange,"FEBuffAdded._OnBuffChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange);
        }

        private void _OnBuffChange(EventBuffChange eventBuffChange)
        {
            if (_isTriggering || eventBuffChange == null || eventBuffChange.buff == null)
                return;

            if (eventBuffChange.type != BuffChangeType.Add)
                return;

            if (!_IsMainObject(EventTarget.GetValue(), eventBuffChange.target))
                return;

            _eventBuffChange = eventBuffChange;
            _Trigger();
            _eventBuffChange = null;
        }
    }
}
