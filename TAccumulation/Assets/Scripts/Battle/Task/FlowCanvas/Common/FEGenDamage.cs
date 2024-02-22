using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("造成伤害\nGenDamage")]
    public class FEGenDamage : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventExportDamage _eventExportDamage;

        private Action<EventExportDamage> _actionExportDamage;
        
        public FEGenDamage()
        {
            _actionExportDamage = _ExportDamage;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<EventExportDamage>(nameof(EventExportDamage), () => _eventExportDamage);
            AddValueOutput<Actor>("DamageCaster", () => _eventExportDamage?.exporter?.GetCaster());
            AddValueOutput<Actor>("DamageTarget", () => _eventExportDamage?.damageInfo?.actor);
            AddValueOutput<DamageInfo>("DamageInfo", () => _eventExportDamage?.damageInfo);
            AddValueOutput<HitInfo>("HitInfo", () => _eventExportDamage?.hitInfo);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, _actionExportDamage, "FEGenDamage._ExportDamage");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, _actionExportDamage);
        }

        private void _ExportDamage(EventExportDamage arg)
        {
            if (_isTriggering || arg == null)
                return;
            // DONE: 判断必须是造成伤害
            if (arg.damageType != DamageType.Sub)
                return;
            if (arg.exporter == null)
                return;
            // DONE: 主体判断
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.exporter.GetCaster()))
                return;
            // DONE: 设置参数.
            _eventExportDamage = arg;
            _Trigger();
            _eventExportDamage = null;
        }
    }
}
