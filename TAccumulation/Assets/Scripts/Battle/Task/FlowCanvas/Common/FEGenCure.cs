using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("造成治疗\nGenCure")]
    public class FEGenCure : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventExportDamage _eventExportDamage;

        private Action<EventExportDamage> _actionOnEventExportDamage;

        public FEGenCure()
        {
            _actionOnEventExportDamage = _OnEventExportDamage;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventExportDamage>(nameof(EventExportDamage), () => _eventExportDamage);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, _actionOnEventExportDamage, "FEGenCure._OnEventExportDamage");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, _actionOnEventExportDamage);
        }

        private void _OnEventExportDamage(EventExportDamage arg)
        {
            if (_isTriggering || arg == null)
                return;
            // DONE: 该次伤害是否是治疗
            if (arg.damageType != DamageType.Add)
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
