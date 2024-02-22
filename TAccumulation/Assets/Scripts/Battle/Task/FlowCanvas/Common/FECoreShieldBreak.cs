using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System.Collections.Generic;
using X3Battle;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("芯核护盾破盾事件\nCoreShieldBreak")]
    public class FECoreShieldBreak : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        [Name("是否首次")]public BBParameter<bool> FirstEnter = new BBParameter<bool>(false);

        private EventWeakFull _eventShieldBreak;
        private Action<EventWeakFull> _actionCoreShieldBreak;
        
        public FECoreShieldBreak()
        {
            _actionCoreShieldBreak = _ShieldBreak;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>(nameof(Actor), () => _eventShieldBreak?.actor);
            AddValueOutput<HitInfo>(nameof(HitInfo), () => _eventShieldBreak?.hitInfo);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventWeakFull>(EventType.WeakFull, _actionCoreShieldBreak, "FECoreShieldBreak._ShieldBreak");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventWeakFull>(EventType.WeakFull, _actionCoreShieldBreak);
        }

        private void _ShieldBreak(EventWeakFull arg)
        {
            if (_isTriggering || arg == null)
                return;
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.actor))
                return;
            if (FirstEnter.GetValue() && arg.actor.actorWeak.weakCount > 1)
                return;
            _eventShieldBreak = arg;
            _Trigger();
            _eventShieldBreak = null;
        }
    }
}
