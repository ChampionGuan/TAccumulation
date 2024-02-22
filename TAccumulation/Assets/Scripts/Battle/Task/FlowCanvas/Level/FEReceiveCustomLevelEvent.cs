using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Event")]
    [Name("关卡收到信号事件\nEvent:LevelReceiveActorSignal")]
    public class FEReceiveCustomLevelEvent : FlowEvent
    {
        public BBParameter<string> signalKey = new BBParameter<string>();
        private EventReceiveSignal _eventLevelSignal;

        private Action<EventReceiveSignal> _actionOnLevelSignal;

        public FEReceiveCustomLevelEvent()
        {
            _actionOnLevelSignal = _OnLevelEvent;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput("SignalKey", () => _eventLevelSignal?.signalKey);
            AddValueOutput("SignalValue", () => _eventLevelSignal?.signalValue);
            AddValueOutput("SignalWriter", () => _eventLevelSignal?.writer);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.actorMgr.stage.eventMgr.AddListener<EventReceiveSignal>(EventType.OnReceiveSignal, _actionOnLevelSignal, "FEReceiveCustomLevelEvent._OnLevelEvent");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.actorMgr.stage.eventMgr.RemoveListener<EventReceiveSignal>(EventType.OnReceiveSignal, _actionOnLevelSignal);
        }

        private void _OnLevelEvent(EventReceiveSignal arg)
        {
            if (_isTriggering)
            {
                return;
            }

            var key = signalKey?.GetValue();
            if (string.IsNullOrWhiteSpace(key) || string.IsNullOrEmpty(key))
            {
                _LogError("请联系策划【五当】, 【关卡收到信号事件 Event:LevelReceiveActorSignal】节点 【SignalKey】参数配置不合法");
                return;
            }
            
            // DONE: 判断是关注的关卡信号.
            if (key != arg.signalKey)
                return;

            _eventLevelSignal = arg;
            _Trigger();
            _eventLevelSignal = null;
        }
    }
}
