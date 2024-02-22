using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/检测进入眩晕,退出受击")]
    [Serializable]
    public class CheckVertigoExitHurt : BSActionAsset<ActionCheckEnterWeak>
    {
    }

    public class ActionCheckEnterWeak : BSAction<CheckVertigoExitHurt>
    {
        //一般只在HurtEnd做这样的事情 希望早点进眩晕
        protected override void _OnUpdate()
        {
            if (context.actor.mainState.HasAbnormalType(ActorAbnormalType.Vertigo))
                context.actor.hurt.StopHurt();
        }
    }
}