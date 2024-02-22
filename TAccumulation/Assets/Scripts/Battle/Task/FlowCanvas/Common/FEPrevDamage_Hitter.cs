using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("伤害前（攻击方）\nPrevDamage_Hitter")]
    public class FEPrevDamage_Hitter : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventPrevDamage _eventPrevDamage;
        private Action<EventPrevDamage> _actionPrevDamage;

        public FEPrevDamage_Hitter()
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
            Battle.Instance.eventMgr.AddListener<EventPrevDamage>(EventType.OnPrevDamage, _actionPrevDamage, "FEPrevDamage_Hitter._OnPrevDamage");
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
            if (!_IsMainObject(EventTarget.GetValue(), arg.damageExporter.GetCaster()))
                return;
            _eventPrevDamage = arg;
            _Trigger();
            _eventPrevDamage = null;
        }
    }
}
