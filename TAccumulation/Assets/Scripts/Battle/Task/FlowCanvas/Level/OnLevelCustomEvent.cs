using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("关卡收到自定义事件监听器\nListener:LevelReceiveCustomSignal")]
    public class OnLevelCustomEvent : FlowListener
    {
        public BBParameter<string> eventName = new BBParameter<string>();

        private Action<EventLevelEvent> _actionOnLevelEvent;

        public OnLevelCustomEvent()
        {
            _actionOnLevelEvent = _OnLevelEvent;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventLevelEvent>(EventType.OnLevelEvent, _actionOnLevelEvent, "OnLevelCustomEvent._OnLevelEvent");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventLevelEvent>(EventType.OnLevelEvent, _actionOnLevelEvent);
        }

        private void _OnLevelEvent(EventLevelEvent eventLevelEvent)
        {
            if (eventName == null)
                return;
            if (IsReachMaxCount())
            {
                return;
            }
            
            // DONE: 关卡收到自定义事件名相同才会triggered
            var eventStr = eventName.GetValue();
            if (eventLevelEvent.eventName != eventStr)
                return;
            _Trigger();
        }
    }
}
