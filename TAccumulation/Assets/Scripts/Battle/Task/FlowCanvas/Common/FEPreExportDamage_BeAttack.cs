using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("即将收到伤害\nPreExportDamage_BeAttack")]
    public class FEPreExportDamage_BeAttack : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventPreExportDamage _eventPreExportDamage;
        private Action<EventPreExportDamage> _actionOnBeforeHit;

        public FEPreExportDamage_BeAttack()
        {
            _actionOnBeforeHit = _OnBeforeHit;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput(nameof(EventPreExportDamage), () => _eventPreExportDamage);
            AddValueOutput<Actor>("DamageCaster", () => _eventPreExportDamage?.exporter?.GetCaster());
            AddValueOutput<Actor>("DamageTarget", () => _eventPreExportDamage?.target);
            AddValueOutput<DamageInfo>(nameof(DamageInfo), () => _eventPreExportDamage?.damageInfo);
            AddValueOutput<HitInfo>(nameof(HitInfo), () => _eventPreExportDamage?.hitInfo);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventPreExportDamage>(EventType.OnPreExportDamage, _actionOnBeforeHit, "FEPreExportDamage_BeAttack._OnBeforeHit");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventPreExportDamage>(EventType.OnPreExportDamage, _actionOnBeforeHit);
        }

        private void _OnBeforeHit(EventPreExportDamage arg)
        {
            if (_isTriggering || arg == null)
                return;
            // DONE: 判断必须是造成伤害
            if (arg.damageType != DamageType.Sub)
                return;
            // DONE: 主体判断
            bool b = _IsMainObject(this.EventTarget.GetValue(), arg.target);
            if (b == false)
                return;

            // DONE: 设置参数.
            _eventPreExportDamage = arg;
            _Trigger();
            _eventPreExportDamage = null;
        }
    }
}
