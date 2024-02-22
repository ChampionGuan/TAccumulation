using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/转向某个点")]
    [Serializable]
    public class RotateToPosAsset : BSActionAsset<ActionRotateToPos>
    {
        [LabelText("速度(每秒绕Y轴欧拉角)")]
        public float turnSpeed;
        
        [DrawCoorPoint("取目标点参数")]
        public CoorPoint pointData;
    }

    public class ActionRotateToPos : BSAction<RotateToPosAsset>
    {
        private Vector3 _destDir;

        protected override void _OnEnter()
        {
            Vector3 _targetPos = CoorHelper.GetCoordinatePoint(clip.pointData, context.actor, true, transInfoCache: bsSharedVariables.transInfoCache);
            var dir = _targetPos - context.actor.transform.position;
            dir.y = 0;
            _destDir = dir.normalized;
            if (startOffsetTime > 0)
            {
                _Evaluate(startOffsetTime);
            }
        }

        protected override void _OnUpdate()
        {
            _Evaluate(deltaTime);
        }

        private void _Evaluate(float delta)
        {
            context.actor.RotateToTargetXZ(_destDir, clip.turnSpeed, delta);    
        }   
    }
}