using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/AI后摇标记")]
    [Serializable]
    public class AIBackSwingAsset : BSActionAsset<ActionAIBackSwing>
    {
    }

    public class ActionAIBackSwing : BSAction<AIBackSwingAsset>
    {
        protected override void _OnEnter()
        {
            if (null == context.actor?.eventMgr)
            {
                return;
            }
            
            //抛出事件
            var eventData = context.actor.eventMgr.GetEvent<ECEventDataBase>();
            context.actor.eventMgr.Dispatch(EventType.AIBackSwing, eventData);
        }
    }
}
