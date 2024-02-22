using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/角色程序转身")]
    [Serializable]
    public class RotateToTargetAsset : BSActionAsset<ActionRotateToTarget>
    {
        [LabelText("目标类型")]
        public TargetType targetType;

        [LabelText("速度(每秒绕Y轴欧拉角)")]
        public float turnSpeed;
    }

    public class ActionRotateToTarget : BSAction<RotateToTargetAsset>
    {
        private Actor _target;
        private Vector3 _destDir;
        
        protected override void _OnEnter()
        {
            _target = context.actor.GetTarget(clip.targetType);
            if (_target == null)
            {
                _destDir = context.actor.GetDestDir();
                _destDir.y = 0;
            }

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
            // 不断追踪target，但是不追踪GetDestDir获取到的方向
            if (_target != null)
            {
                var targetPosition = _target.transform.position;
                var actorPosition = context.actor.transform.position;
                _destDir = targetPosition - actorPosition;
                _destDir.y = 0;
            }
            context.actor.RotateToTargetXZ(_destDir, clip.turnSpeed, delta);   
        }

        protected override void _OnExit()
        {
            _target = null;
        }
    }
}