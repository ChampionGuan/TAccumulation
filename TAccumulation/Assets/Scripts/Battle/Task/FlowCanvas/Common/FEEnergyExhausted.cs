using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("能量耗尽\nEnergyExhausted")]
    public class FEEnergyExhausted : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public BBParameter<EnergyType> energyType = new BBParameter<EnergyType>(EnergyType.Ultra);
        private EventEnergyExhausted _eventEnergyExhausted;

        private Action<EventEnergyExhausted> _actionOnEnergyExhausted;

        public FEEnergyExhausted()
        {
            _actionOnEnergyExhausted = _OnEnergyExhausted;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("Target", () => _eventEnergyExhausted?.actor);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventEnergyExhausted>(EventType.EnergyExhausted, _actionOnEnergyExhausted, "FEEnergyExhausted._OnEnergyExhausted");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventEnergyExhausted>(EventType.EnergyExhausted, _actionOnEnergyExhausted);
        }

        protected void _OnEnergyExhausted(EventEnergyExhausted arg)
        {
            bool res = false;
            if (_isTriggering || arg == null)
                return;

            if (!_IsMainObject(this.EventTarget.GetValue(), arg.actor))
                return;
            if (arg.type == AttrUtil.ConvertEnergyToAttr(energyType.GetValue()))
                res = true;

            if (!res)
                return;
            _eventEnergyExhausted = arg;
            _Trigger();
            _eventEnergyExhausted = null;
        }
    }
}
