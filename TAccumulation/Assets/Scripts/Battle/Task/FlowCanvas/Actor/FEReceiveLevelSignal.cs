using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Event")]
    [Name("Actor接收关卡信号事件\nEvent:ActorReceiveLevelSignal")]
    public class FEReceiveLevelSignal : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public BBParameter<string> signalKey = new BBParameter<string>();
        private EventReceiveSignal _eventReceiveSignal;
        private Action<EventReceiveSignal> _actionOnReceiveSignal;

        public FEReceiveLevelSignal()
        {
            _actionOnReceiveSignal = _OnReceiveSignal;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventReceiveSignal>(nameof(EventReceiveSignal), () => _eventReceiveSignal);
            AddValueOutput<string>("SignalKey", () => _eventReceiveSignal?.signalKey);
            AddValueOutput<string>("SignalValue", () => _eventReceiveSignal?.signalValue);
            AddValueOutput<Actor>("SignalReceiver", () => _eventReceiveSignal?.reciever);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventReceiveSignal>(EventType.OnReceiveSignal, _actionOnReceiveSignal, "FEReceiveLevelSignal._OnReceiveSignal");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventReceiveSignal>(EventType.OnReceiveSignal, _actionOnReceiveSignal);
        }

        private void _OnReceiveSignal(EventReceiveSignal arg)
        {
            if (_isTriggering || arg == null || arg.reciever == null)
                return;
            // DONE: Writer==null便是关卡发送的事件.
            if (arg.writer != null)
                return;
            // DONE: 判断谁接收关卡信号事件.
            if (!_IsMainObject(EventTarget.GetValue(), arg.reciever))
                return;
            // DONE: 判断监听的是不是这个信号.
            if (signalKey != null)
            {
                var key = signalKey.GetValue();
                if (string.IsNullOrWhiteSpace(key) || string.IsNullOrEmpty(key))
                {
                    _LogError("请联系策划【五当】, 【Actor接收关卡信号事件 Event:ActorReceiveLevelSignal】节点 【SignalKey】参数配置不合法");
                    return;
                }
            
                // DONE: 判断是关注的信号.
                if (key != arg.signalKey)
                    return;
            }
            _eventReceiveSignal = arg;
            _Trigger();
            _eventReceiveSignal = null;
        }
    }
}
