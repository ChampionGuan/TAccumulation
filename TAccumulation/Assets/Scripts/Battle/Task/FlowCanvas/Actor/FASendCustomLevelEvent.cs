using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("向关卡发送自定义事件\nSendCustomLevelEvent")]
    public class FASendCustomLevelEvent : FlowAction
    {
        private ValueInput<string> _viEventName;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viEventName = AddValueInput<string>("EventName");
        }

        protected override void _Invoke()
        {
            var eventName = _viEventName.GetValue();
            if (string.IsNullOrWhiteSpace(eventName) || string.IsNullOrEmpty(eventName))
            {
                _LogError("请联系策划【五当】,【FC】【向关卡发送自定义事件 SendCustomLevelEvent】节点 【EventName】参数配置不合法, 不能为空.");
                return;
            }

            var eventData = Battle.Instance.eventMgr.GetEvent<EventLevelEvent>();
            eventData.Init(eventName, _actor);
            Battle.Instance.eventMgr.Dispatch(EventType.OnLevelEvent, eventData);
        }
    }
}
