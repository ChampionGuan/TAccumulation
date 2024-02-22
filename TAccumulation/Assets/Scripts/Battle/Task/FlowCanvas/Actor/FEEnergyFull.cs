using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Event")]
    [Name("能量充满\nEnergyFullCharge")]
    public class FEEnergyFull : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public BBParameter<EnergyType> energyType = new BBParameter<EnergyType>(EnergyType.Ultra);
        private EventEnergyFull _eventEnergyFull;

        private Action<EventEnergyFull> _actionOnEnergyFull;
        
        public FEEnergyFull()
        {
            _actionOnEnergyFull = _OnEnergyFull;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<EventEnergyFull>(nameof(EventEnergyFull), () => _eventEnergyFull);
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventEnergyFull>(EventType.EnergyFull, _actionOnEnergyFull, "FEEnergyFull._OnEnergyFull");
        }
        
        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventEnergyFull>(EventType.EnergyFull, _actionOnEnergyFull);
        }
        
        protected void _OnEnergyFull(EventEnergyFull arg)
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
            _eventEnergyFull = arg;
            _Trigger();
            _eventEnergyFull = null;
        }
    }
}
