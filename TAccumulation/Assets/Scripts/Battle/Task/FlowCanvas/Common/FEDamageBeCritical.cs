using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("被暴击时\nDamageBeCritical")]
    public class FEDamageBeCritical : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        
        private Action<EventDamageCritical> _actionDamageCritical;
        private EventDamageCritical _eventDamageCritical;
        
        public FEDamageBeCritical()
        {
            _actionDamageCritical = _OnDamageCritical;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("HitCaster", () => _eventDamageCritical?.damageExporter?.GetCaster());
            AddValueOutput<Actor>("HitTarget", () => _eventDamageCritical?.target);
            AddValueOutput<HitInfo>("HitInfo", () => _eventDamageCritical?.hitInfo);
            AddValueOutput<DynamicHitInfo>("DynamicHitInfo", () => _eventDamageCritical?.dynamicHitInfo);
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnDamageCritical, _actionDamageCritical, "FEDamageBeCritical._OnDamageCritical");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnDamageCritical, _actionDamageCritical);
        }

        private void _OnDamageCritical(EventDamageCritical arg)
        {
            if (_isTriggering || arg == null)
                return;
            // DONE: 判断主体
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.target))
                return;
            // DONE: 设置参数.
            _eventDamageCritical = arg;
            _Trigger();
            _eventDamageCritical = null;
        }
    }
}
