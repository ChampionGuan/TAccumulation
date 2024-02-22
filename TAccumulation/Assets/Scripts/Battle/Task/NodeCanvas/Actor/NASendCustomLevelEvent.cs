using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Action/Actor")]
    [Name(("SendCustomLevelEvent"))]
    [Description("向关卡发送自定义事件")]
    public class NASendCustomLevelEvent : BattleAction
    {
        public BBParameter<string> eventName = new BBParameter<string>();
        
        protected override void OnExecute()
        {
            var eventStr = this.eventName.GetValue();
            if (string.IsNullOrWhiteSpace(eventStr) || string.IsNullOrEmpty(eventStr))
            {
                PapeGames.X3.LogProxy.LogError("请联系策划【五当】,【NC】【向关卡发送自定义事件 SendCustomLevelEvent】节点 【EventName】参数配置不合法, 不能为空.");
                EndAction(false);
                return;
            }

            var eventData = Battle.Instance.eventMgr.GetEvent<EventLevelEvent>();
            eventData.Init(eventStr, _actor);
            Battle.Instance.eventMgr.Dispatch(EventType.OnLevelEvent, eventData);
            EndAction(true);
        }
    }
}
