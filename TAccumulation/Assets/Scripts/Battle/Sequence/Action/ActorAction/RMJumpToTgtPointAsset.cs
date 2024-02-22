using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [TimelineMenu("角色动作/跳跃到目标位置")]
    [TrackClipYellowColor]
    [Serializable]
    public class RMJumpToTgtPointAsset : BSActionAsset<ActionRmJumpToTgtPoint>
    {
        [LabelText("目标类型")] public TargetType targetType;
        [LabelText("动画中Y轴向的偏移量")] public float distanceY = 1;
        [LabelText("动画中Z轴向的偏移值")] public float distanceZ = 1;
    }

    public class ActionRmJumpToTgtPoint : BSAction<RMJumpToTgtPointAsset>
    {
        protected override void _OnEnter()
        {
            var actor = context.actor;
            var target = actor.GetTarget(clip.targetType);
            if (null == target)
            {
                return;
            }

            var currPos = actor.transform.position;
            var targetPoint = target.transform.position;
            var curPosXZ = new Vector2(currPos.x, currPos.z);
            var tgtPosXZ = new Vector2(targetPoint.x, targetPoint.z);
            var multiY = clip.distanceY > 0 ? Mathf.Abs(currPos.y - targetPoint.y) / clip.distanceY : actor.animator.rmMultiplierY;
            var multiXZ = clip.distanceZ > 0 ? Vector2.Distance(tgtPosXZ, curPosXZ) / clip.distanceZ : actor.animator.rmMultiplierX;
            actor.animator.SetRootMotionMultiplier(multiXZ, multiY, multiXZ, true, RMMultiplierType.Dominate);
        }

        protected override void _OnExit()
        {
            // TODO 临时判空解决, 待长空考虑设计.
            if (context?.actor?.animator == null)
            {
                return;
            }

            context.actor.animator.SetRootMotionMultiplier(null, null, null, false, RMMultiplierType.Dominate);
        }
    }
}
