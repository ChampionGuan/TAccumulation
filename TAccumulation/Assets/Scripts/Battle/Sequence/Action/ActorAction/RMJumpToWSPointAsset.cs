using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [TimelineMenu("角色动作/跳跃到世界位置点")]
    [TrackClipYellowColor]
    [Serializable]
    public class RMJumpToWSPointAsset : BSActionAsset<ActionRmJumpToWsPoint>
    {
        [LabelText("目标点（世界坐标）")] public Vector3 targetPoint;
        [LabelText("动画中Y轴向的偏移量")] public float distanceY = 1;
        [LabelText("动画中Z轴向的偏移值")] public float distanceZ = 1;
    }

    public class ActionRmJumpToWsPoint : BSAction<RMJumpToWSPointAsset>
    {
        protected override void _OnEnter()
        {
            var actor = context.actor;
            var currPos = actor.transform.position;
            var curPosXZ = new Vector2(currPos.x, currPos.z);
            var tgtPosXZ = new Vector2(clip.targetPoint.x, clip.targetPoint.z);
            var multiY = clip.distanceY > 0 ? Mathf.Abs(currPos.y - clip.targetPoint.y) / clip.distanceY : actor.animator.rmMultiplierY;
            var multiXZ = clip.distanceZ > 0 ? Vector2.Distance(tgtPosXZ, curPosXZ) / clip.distanceZ : actor.animator.rmMultiplierX;
            actor.animator.SetRootMotionMultiplier(multiXZ, multiY, multiXZ, true, RMMultiplierType.Dominate);
        }

        protected override void _OnExit()
        {
            context.actor.animator.SetRootMotionMultiplier(null, null, null, false, RMMultiplierType.Dominate);
        }   
    }
}