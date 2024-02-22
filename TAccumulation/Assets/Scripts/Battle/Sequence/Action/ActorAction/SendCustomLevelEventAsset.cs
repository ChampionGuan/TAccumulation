using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/向关卡发送自定义事件")]
    [Serializable]
    public class SendCustomLevelEventAsset : BSActionAsset<ActionSendCustomLevelEvent>
    {
        public string eventName;
    }

    public class ActionSendCustomLevelEvent : BSAction<SendCustomLevelEventAsset>
    {
        protected override void _OnEnter()
        {
            if (string.IsNullOrWhiteSpace(clip.eventName) || string.IsNullOrEmpty(clip.eventName))
            {
                PapeGames.X3.LogProxy.LogError("请联系策划【五当】,【动作模组】【向关卡发送自定义事件 SendCustomLevelEvent】节点 【EventName】参数配置不合法, 不能为空.");
                return;
            }

            var eventData = context.battle.eventMgr.GetEvent<EventLevelEvent>();
            eventData.Init(clip.eventName, context.actor);
            context.battle.eventMgr.Dispatch(EventType.OnLevelEvent, eventData);
        }   
    }
}