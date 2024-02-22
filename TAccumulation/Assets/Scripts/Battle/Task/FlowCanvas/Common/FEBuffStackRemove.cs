using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("Buff层数减少\nBuffStackRemove")]
    public class FEBuffStackRemove : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventBuffLayerChange _eventBuffLayerChange;

        private Action<EventBuffLayerChange> _actionOnBuffLayerChange;

        public FEBuffStackRemove()
        {
            _actionOnBuffLayerChange = _OnBuffLayerChange;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("BuffCaster", () => _eventBuffLayerChange?.caster);
            AddValueOutput<Actor>("BuffTarget", () => _eventBuffLayerChange?.target);
            AddValueOutput<IBuff>("IBuff", () => _eventBuffLayerChange?.buff);
            AddValueOutput<int>("StackCount", () => _eventBuffLayerChange?.layer ?? 0);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBuffLayerChange>(EventType.BuffLayerChange, _actionOnBuffLayerChange, "FEBuffStackRemove._OnBuffLayerChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBuffLayerChange>(EventType.BuffLayerChange, _actionOnBuffLayerChange);
        }

        private void _OnBuffLayerChange(EventBuffLayerChange eventBuffLayerChange)
        {
            if (_isTriggering || eventBuffLayerChange == null || eventBuffLayerChange.buff == null)
                return;

            if (eventBuffLayerChange.type != BuffChangeType.ReduceLayer)
                return;

            if (!_IsMainObject(EventTarget.GetValue(), eventBuffLayerChange.target))
                return;

            _eventBuffLayerChange = eventBuffLayerChange;
            _Trigger();
            _eventBuffLayerChange = null;
        }
    }
}
