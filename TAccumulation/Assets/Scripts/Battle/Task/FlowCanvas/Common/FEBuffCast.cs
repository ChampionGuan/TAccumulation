using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("Buff施加（主动）\nBuffCast")]
    public class FEBuffCast : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventBuffChange _eventBuffChange;
        private Action<EventBuffChange> _actionOnBuffChange;

        public FEBuffCast()
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
            Battle.Instance.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange, "FEBuffCast._OnBuffChange");
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

            if (!_IsMainObject(EventTarget.GetValue(), eventBuffChange.caster))
                return;

            _eventBuffChange = eventBuffChange;
            _Trigger();
            _eventBuffChange = null;
        }
    }
}
