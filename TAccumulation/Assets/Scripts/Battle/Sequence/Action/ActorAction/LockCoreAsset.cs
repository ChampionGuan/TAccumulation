using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/芯核锁定")]
    [Serializable]
    public class LockCoreAsset : BSActionAsset<ActionLockCore>
    {
        [LabelText("true：上锁 false：解锁")]
        public bool isLock;
        [LabelText("是否结束时复原")]
        public bool recover;
    }

    public class ActionLockCore : BSAction<LockCoreAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.actorWeak?.LockCore(clip.isLock);
        }

        protected override void _OnExit()
        {
            if(clip.recover)
            {
                context.actor.actorWeak?.LockCore(!clip.isLock);
            }
        }
    }
}
