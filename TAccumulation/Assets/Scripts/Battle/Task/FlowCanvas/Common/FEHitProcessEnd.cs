using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("总命中流程结束\nHitProcessEnd")]
    public class FEHitProcessEnd : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public BBParameter<DamageBoxType> DamageBoxType = new BBParameter<DamageBoxType>(X3Battle.DamageBoxType.Attack);

        private Action<EventHitProcessEnd> _actionHitProcessEnd;
        private EventHitProcessEnd _eventHitProcessEnd;

        public FEHitProcessEnd()
        {
            _actionHitProcessEnd = _OnHitProcessEnd;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("HitCaster", () => _eventHitProcessEnd?.damageExporter.GetCaster());
            AddValueOutput<bool>("HasExportedDamage", () => _eventHitProcessEnd?.hasExportedDamage ?? false);
            AddValueOutput<DamageExporter>(nameof(DamageExporter), () => _eventHitProcessEnd?.damageExporter);
            AddValueOutput<DamageBoxCfg>(nameof(DamageBoxCfg), () => _eventHitProcessEnd?.damageBoxCfg);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnHitProcessEnd, _actionHitProcessEnd, "FEHitProcessEnd._OnHitProcessEnd");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnHitProcessEnd, _actionHitProcessEnd);
        }

        private void _OnHitProcessEnd(EventHitProcessEnd args)
        {
            if (_isTriggering || args == null)
            {
                return;
            }

            if (!_IsMainObject(EventTarget.GetValue(), args.damageExporter.GetCaster()))
                return;

            if (DamageBoxType.GetValue() != args.damageBoxCfg.DamageBoxType)
            {
                return;
            }
            
            _eventHitProcessEnd = args;
            _Trigger();
            _eventHitProcessEnd = null;
        }
    }
}
