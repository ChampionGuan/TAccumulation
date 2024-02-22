using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using Unity.Mathematics;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("血量变化事件\nFEHPchange")]
    public class FEHpChange : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public HpChangeTypeFlag hpChangeTypeflag;

        private Action<EventActorHealthChange> _actionHpChange;

        private float _changeHp;
        private Actor _actor;

        public FEHpChange()
        {
            _actionHpChange = _OnHpChange;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventActorHealthChange>(EventType.ActorHealthChange, _actionHpChange, "FEHPchange._actionHpChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventActorHealthChange>(EventType.ActorHealthChange, _actionHpChange);
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<float>("changeValue", () => _changeHp);
            AddValueOutput<Actor>("actor", () => _actor);
        }
        private void _OnHpChange(EventActorHealthChange eventHpChange)
        {
            if (_isTriggering || eventHpChange == null)
                return;

            if (!_IsMainObject(EventTarget.GetValue(), eventHpChange.actor))
                return;
            
            if (((HpChangeTypeFlag)(1 << (int)eventHpChange.changeType) & hpChangeTypeflag) != 0)
            {
                _changeHp = eventHpChange.changeValue;
                _actor = eventHpChange.actor;
                _Trigger();
                _actor = null;
            }
        }
    }
}
