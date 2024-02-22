using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("添加buff流程第二步事件（已过敌人免疫检测）\nFEBuffTryAdd")]
    public class FEBuffTryAdd : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventBuffChange _eventBuffChange;

        private Action<EventBuffChange> _actionOnBuffTryAdd;

        public FEBuffTryAdd()
        {
            _actionOnBuffTryAdd = _OnBuffTryAdd;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("BuffCaster", () => _eventBuffChange?.caster);
            AddValueOutput<Actor>("BuffTarget", () => _eventBuffChange?.target);
            AddValueOutput<IBuff>("IBuff", () => _eventBuffChange?.buff);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBuffChange>(EventType.BuffAdd, _actionOnBuffTryAdd,
                "FEBuffTryAdd._BuffAdd");
            Battle.Instance.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffTryAdd,
                "FEBuffTryAdd._BuffAdd");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffAdd, _actionOnBuffTryAdd);
            Battle.Instance.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffTryAdd);
        }

        private void _OnBuffTryAdd(EventBuffChange eventBuffChange)
        {
            if (_isTriggering || eventBuffChange == null || eventBuffChange.buff == null ||
                eventBuffChange.type != BuffChangeType.Add)
                return;
            
            if (!_IsMainObject(EventTarget.GetValue(), eventBuffChange.target))
                return;

            _eventBuffChange = eventBuffChange;
            _Trigger();
            _eventBuffChange = null;
        }
    }
}