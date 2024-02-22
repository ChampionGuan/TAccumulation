using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("伤害前（受击方）\nPrevDamage_BeHitter")]
    public class FEPrevDamage_BeHitter : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventPrevDamage _eventPrevDamage;
        private Action<EventPrevDamage> _actionPrevDamage;

        public FEPrevDamage_BeHitter()
        {
            _actionPrevDamage = _OnPrevDamage;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventPrevDamage>(nameof(EventPrevDamage), () => _eventPrevDamage);
            AddValueOutput<Actor>("HitCaster", () => _eventPrevDamage?.damageExporter?.GetCaster());
            AddValueOutput<Actor>("HitTarget", () => _eventPrevDamage?.target);
            AddValueOutput<HitInfo>("HitInfo", () => _eventPrevDamage?.hitInfo);
            AddValueOutput<DynamicHitInfo>("DynamicHitInfo", () => _eventPrevDamage?.dynamicHitInfo);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventPrevDamage>(EventType.OnPrevDamage, _actionPrevDamage, "FEPrevDamage_BeHitter._OnPrevDamage");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventPrevDamage>(EventType.OnPrevDamage, _actionPrevDamage);
        }

        private void _OnPrevDamage(EventPrevDamage arg)
        {
            if (_isTriggering || arg == null)
                return;
            // DONE: 主体判断
            if (!_IsMainObject(EventTarget.GetValue(), arg.target))
                return;
            _eventPrevDamage = arg;
            _Trigger();
            _eventPrevDamage = null;
        }
    }
}
