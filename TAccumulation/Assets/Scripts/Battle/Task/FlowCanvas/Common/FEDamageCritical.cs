﻿using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("暴击时\nDamageCritical")]
    public class FEDamageCritical : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        
        private Action<EventDamageCritical> _actionDamageCritical;
        private EventDamageCritical _eventDamageCritical;
        
        public FEDamageCritical()
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
            Battle.Instance.eventMgr.AddListener(EventType.OnDamageCritical, _actionDamageCritical,"FEDamageCritical._OnDamageCritical");
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
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.damageExporter.GetCaster()))
                return;
            // DONE: 设置参数.
            _eventDamageCritical = arg;
            _Trigger();
            _eventDamageCritical = null;
        }
    }
}
