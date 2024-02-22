using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置IdleState")]
    [Serializable]
    public class SetIdleStateAsset : BSActionAsset<ActionSetIdleState>
    {
        [LabelText("是否战斗Idle")]
        public bool isBattleIdle = true;
    }

    public class ActionSetIdleState : BSAction<SetIdleStateAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.idle.SetIdleState(clip.isBattleIdle);
        }
        protected override void _OnExit()
        {
            context.actor.idle.SetIdleState(null);
        }
    }
}