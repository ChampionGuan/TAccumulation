using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Event")]
    [Name("锁血触发事件\nLockHp")]
    public class FELockHp : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventLockHp _eventLockHp;
        private Action<EventLockHp> _actionOnLockHp;

        public FELockHp()
        {
            _actionOnLockHp = _OnLockHp;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventLockHp>(nameof(EventLockHp), () => _eventLockHp);
            AddValueOutput<Actor>("SourceActor", () => _eventLockHp?.actor);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventLockHp>(EventType.OnLockHp, _actionOnLockHp, "FELockHp._OnLockHp");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventLockHp>(EventType.OnLockHp, _actionOnLockHp);
        }

        private void _OnLockHp(EventLockHp arg)
        {
            if (_isTriggering || arg == null)
                return;
            if (arg.actor == null)
                return;
            // DONE: 过滤主体
            if (!_IsMainObject(EventTarget.GetValue(), arg.actor))
                return;
            _eventLockHp = arg;
            _Trigger();
            _eventLockHp = null;
        }
    }
}
