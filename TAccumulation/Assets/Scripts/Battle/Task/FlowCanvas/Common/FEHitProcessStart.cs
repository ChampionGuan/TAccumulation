using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("总命中流程开始\nHitProcessStart")]
    public class FEHitProcessStart : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public BBParameter<DamageBoxType> DamageBoxType = new BBParameter<DamageBoxType>(X3Battle.DamageBoxType.Attack);
        
        private Action<EventHitProcessStart> _actionHitProcessStart;
        private EventHitProcessStart _eventHitProcessStart;

        public FEHitProcessStart()
        {
            _actionHitProcessStart = _OnHitProcessStart;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<DamageExporter>(nameof(DamageExporter), () => _eventHitProcessStart?.damageExporter);
            AddValueOutput<DamageBoxCfg>(nameof(DamageBoxCfg), () => _eventHitProcessStart?.damageBoxCfg);
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnHitProcessStart, _actionHitProcessStart, "FEHitProcessStart._OnHitProcessStart");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnHitProcessStart, _actionHitProcessStart);
        }

        private void _OnHitProcessStart(EventHitProcessStart args)
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
            
            _eventHitProcessStart = args;
            _Trigger();
            _eventHitProcessStart = null;
        }
    }
}