using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("受到芯核伤害时事件\nCoreShieldDamage")]
    public class FECoreShieldDamage : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventCoreChange _eventCoreChange;
        private Action<EventCoreChange> _actionCoreChange;

        public FECoreShieldDamage()
        {
            _actionCoreChange = _CoreShieldChange;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("Actor", () => _eventCoreChange?.actor);
            AddValueOutput<HitInfo>("HitInfo", () => _eventCoreChange?.hitInfo);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventCoreChange>(EventType.CoreChange, _actionCoreChange, "FECoreShieldDamage._CoreShieldChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventCoreChange>(EventType.CoreChange, _actionCoreChange);
        }

        private void _CoreShieldChange(EventCoreChange arg)
        {
            if (_isTriggering || arg == null)
                return;
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.actor))
                return;
            if (!arg.isCoreDamage)
                return;
            _eventCoreChange = arg;
            _Trigger();
            _eventCoreChange = null;
        }
    }
}
