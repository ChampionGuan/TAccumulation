using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/冲向目标当前坐标 (插值)")]
    [Serializable]
    public class ApproachTargetPos1Asset : BSActionAsset<ActionApproachTargetPos1>
    {
        [LabelText("目标类型")]
        public TargetType targetType;

        [LabelText("位移Tween曲线")]
        public TweenEaseType tweenType;
        
        [LabelText("转向速度(每秒绕Y轴欧拉角)")]
        public float turnSpeed;
    }

    public class ActionApproachTargetPos1 : BSAction<ApproachTargetPos1Asset>
    {
        private Vector3 _startPos;
        private Vector3 _targetPos;
        private Vector3 _destDir;
        private bool _emptyTarget;

        protected override void _OnEnter()
        {
            var target = context.actor.GetTarget(clip.targetType);
            _emptyTarget = target == null;
            if (_emptyTarget)
            {
                return;
            }
            
            _startPos = context.actor.transform.position;
            _startPos.y = 0;
            _targetPos = target.transform.position;
            _targetPos.y = 0;

            var dir = _targetPos - _startPos;
            dir.y = 0;
            _destDir = dir.normalized;
            
            if (startOffsetTime > 0)
            {
                EvalMove();
                EvalRotate(startOffsetTime);
            }
        }

        protected override void _OnUpdate()
        {
            if (_emptyTarget)
            {
                return;
            }
            
            EvalMove();
            EvalRotate(deltaTime);
        }

        // 计算旋转
        private void EvalRotate(float delta)
        {
            context.actor.RotateToTargetXZ(_destDir, clip.turnSpeed, delta);
        }
        
        // 计算位移
        private void EvalMove()
        {
            var proportion = curOffsetTime / duration;
            var progress = BattleUtil.CalculateTweenValue(proportion, clip.tweenType);
            var curPos = (_targetPos - _startPos) * progress + _startPos;
            context.actor.transform.SetPosition(curPos);
        }   
    }
}