using PapeGames.X3;
using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色运动/看向")]
    [Serializable]
    public class LookAtAsset : BSActionAsset<ActionLookAt>
    {
        [LabelText("是否看向目标")]
        public bool isLookAt = true;
        [LabelText("旋转时间")]
        public float rotateTime = 0.2f;
        //[LabelText("目标类型")]
        //public TargetType targetType = TargetType.Lock;
    }

    public class ActionLookAt : BSAction<LookAtAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.lookAtOwner.UseLookAtStrategy(clip.isLookAt, clip.rotateTime);
        }  
    }
}