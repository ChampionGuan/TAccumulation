using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/死亡移除Collider")]
    [Serializable]
    public class DeadRemoveColliderAsset : BSActionAsset<ActionDeadRemoveCollider>
    {
    }

    public class ActionDeadRemoveCollider : BSAction<DeadRemoveColliderAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.collider.isColliderActive = false;
        }
    }
}