using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/冲刺向某个坐标点 (速度时间)")]
    [Serializable]
    public class ApproachPos_VTAsset : BSActionAsset<ActionApproachPosVT>
    {
        [LabelText("转向速度(每秒绕Y轴欧拉角)")]
        public float turnSpeed;

        [LabelText("位移初速度")]
        public float originMoveSpeed;  // 初始移动速度
        
        [LabelText("位移加速度")]
        public float moveAccelerate;  // 加速度

        [DrawCoorPoint("取目标点参数")]
        public CoorPoint pointData;

        [LabelText("速度限制(-1不限制)")]
        public float limitSpeed = -1;
    }

    public class ActionApproachPosVT : BSAction<ApproachPos_VTAsset>
    {
        private Vector3 _targetPos;
        private Vector3 _curPos;
        private Vector3 _destDir;
        private float _curSpeed;
        private bool _isComplete;

        protected override void _OnEnter()
        {
            Vector3 targetPos1 = CoorHelper.GetCoordinatePoint(clip.pointData, context.actor, true, transInfoCache: bsSharedVariables.transInfoCache);
            _targetPos = targetPos1;
            _targetPos.y = 0;
            
            var startPos = context.actor.transform.position;
            startPos.y = 0;

            var dir = _targetPos - startPos;
            dir.y = 0;
            _destDir = dir.normalized;

            _curSpeed = clip.originMoveSpeed;
            _curPos = context.actor.transform.position;
            _isComplete = false;
            if (startOffsetTime > 0)
            {
                EvalRotate(startOffsetTime);
                EvalMove(startOffsetTime);
            }
        }

        protected override void _OnUpdate()
        {
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

            var frameMoveDis = _curSpeed * delta;
            var curPos = context.actor.transform.position;
            var offsetPos = _targetPos - curPos;
            offsetPos.y = 0;
            
            if (offsetPos.sqrMagnitude <= frameMoveDis * frameMoveDis)
            {
                context.actor.transform.SetPosition(_targetPos);
                _isComplete = true;
            }
            else
            {
                var newPos = curPos + offsetPos.normalized * frameMoveDis;
                context.actor.transform.SetPosition(newPos);
            }

            // float distance = dir.magnitude;
            // if (distance > offsetLen)
            // {
            //     _curPos = _curPos + offsetLen * _destDir;
            //     context.actor.transform.SetPosition(_curPos);
            // }
            // else
            // {
            //     _isComplete = true;
            //     _curPos = _targetPos;
            //     context.actor.transform.SetPosition(_targetPos);
            // }
        }    
    }
}