using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/冲向目标当前坐标 (加速度))")]
    [Serializable]
    public class ApproachTargetPos2Asset : BSActionAsset<ActionApproachTargetPos2>
    {
        [LabelText("目标类型")]
        public TargetType targetType;

        [LabelText("转向速度(每秒绕Y轴欧拉角)")]
        public float turnSpeed;

        [LabelText("位移初速度")]
        public float originMoveSpeed;  // 初始移动速度
        
        [LabelText("位移加速度")]
        public float moveAccelerate;  // 加速度
        
        [LabelText("速度限制(-1不限制)")]
        public float limitSpeed = -1;
    }

    public class ActionApproachTargetPos2 : BSAction<ApproachTargetPos2Asset>
    {

        private Vector3 _targetPos;
        private Vector3 _curPos;
        private Vector3 _destDir;
        private float _curSpeed;
        private bool _isComplete;
        private X3Battle.Actor _target;
        
        protected override void _OnEnter()
        {
            var target = context.actor.GetTarget(clip.targetType);
            _target = target;
            if (_target == null)
            {
                return;
            }
            
            var startPos = context.actor.transform.position;
            startPos.y = 0;
            _targetPos = target.transform.position;
            _targetPos.y = 0;

            var dir = _targetPos - startPos;
            dir.y = 0;
            _destDir = dir.normalized;

            _curSpeed = clip.originMoveSpeed;
            _curPos = context.actor.transform.position;
            _isComplete = false;

            if (startOffsetTime > 0)
            {
                EvalMove(startOffsetTime);
                EvalRotate(startOffsetTime);
            }
        }

        protected override void _OnUpdate()
        {
            if (_target == null)
            {
                return;
            }
            
            if (_isComplete)
            {
                return;     
            }
            EvalMove(deltaTime);
            EvalRotate(deltaTime);
        }

        // 计算旋转
        private void EvalRotate(float delta)
        {
            context.actor.RotateToTargetXZ(_destDir, clip.turnSpeed, delta);
        }
        
        // 计算位移
        private void EvalMove(float delta)
        {
            _curSpeed = _curSpeed + delta * clip.moveAccelerate;
            if (clip.limitSpeed > 0)
            {
                if (clip.moveAccelerate > 0 && _curSpeed > clip.limitSpeed)
                {
                    _curSpeed = clip.limitSpeed;   
                }
                else if (clip.moveAccelerate < 0 && _curSpeed < clip.limitSpeed)
                {
                    _curSpeed = clip.limitSpeed;    
                }
            }
            
            var offsetLen = _curSpeed * delta;
            
            var distance = (_curPos - _targetPos).magnitude;
            if (distance > offsetLen)
            {
                _curPos = _curPos + offsetLen * _destDir;
                context.actor.transform.SetPosition(_curPos);
            }
            else
            {
                _isComplete = true;
                _curPos = _targetPos;
                context.actor.transform.SetPosition(_targetPos);
            }
        }    
    }
}