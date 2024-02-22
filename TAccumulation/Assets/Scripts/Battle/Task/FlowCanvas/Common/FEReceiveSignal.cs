using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("收到信号事件(被动)\nReceiveSignal")]
    public class FEReceiveSignal : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventReceiveSignal _eventReceiveSignal;

        private Action<EventReceiveSignal> _actionOnReceiveSignal;

        public FEReceiveSignal()
        {
            _actionOnReceiveSignal = _OnReceiveSignal;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<string>("SignalKey", () => _eventReceiveSignal?.signalKey);
            AddValueOutput<string>("SignalValue", () => _eventReceiveSignal?.signalValue);
            AddValueOutput<Actor>("SignalWriter", () => _eventReceiveSignal?.writer);
            AddValueOutput<Actor>("SignalReceiver", () => _eventReceiveSignal?.reciever);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventReceiveSignal>(EventType.OnReceiveSignal, _actionOnReceiveSignal, "FEReceiveSignal._OnReceiveSignal");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventReceiveSignal>(EventType.OnReceiveSignal, _actionOnReceiveSignal);
        }

        private void _OnReceiveSignal(EventReceiveSignal arg)
        {
            if (_isTriggering || arg == null || arg.reciever == null)
                return;
            if (!_IsMainObject(EventTarget.GetValue(), arg.reciever))
                return;
            _eventReceiveSignal = arg;
            _Trigger();
            _eventReceiveSignal = null;
        }
    }
}
