using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Sequence;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/冲刺向某个点 (路程时间插值)")]
    [Serializable]
    public class ApproachPos_LTAsset : BSActionAsset<ActionApproachPosLT>
    {
        [LabelText("位移Tween曲线")]
        public TweenEaseType tweenType;
        
        [LabelText("转向速度(每秒绕Y轴欧拉角)")]
        public float turnSpeed;
        
        [DrawCoorPoint("取目标点参数")]
        public CoorPoint pointData;
    }

    public class ActionApproachPosLT : BSAction<ApproachPos_LTAsset>
    {
        private Vector3 _startPos;
        private Vector3 _targetPos;
        private Vector3 _destDir;
        private float _moveDistance;
        private float _totalDistance;

        protected override void _OnEnter()
        {
            Vector3 targetPos1 = CoorHelper.GetCoordinatePoint(clip.pointData, context.actor, true, transInfoCache: bsSharedVariables.transInfoCache);
            _targetPos = targetPos1;
            _targetPos.y = 0;
            
            _startPos = context.actor.transform.position;
            _startPos.y = 0;

            var dir = _targetPos - _startPos;
            dir.y = 0;
            _destDir = dir.normalized;

            _moveDistance = 0;
            _totalDistance = (_targetPos - _startPos).magnitude;
            
            if (startOffsetTime > 0)
            {
                EvalRotate(startOffsetTime);   
            } 
        }

        protected override void _OnUpdate()
        {
            var proportion = curOffsetTime / duration;
            EvalMove(proportion);
            EvalRotate(deltaTime);
        }

        protected override void _OnExit()
        {
            if (exitType == ExitType.Normal)
            {
                EvalMove(1.0f);
            }
        }

        // 计算旋转
        private void EvalRotate(float delta)
        {
            context.actor.RotateToTargetXZ(_destDir, clip.turnSpeed, delta);
        }
        
        // 计算位移
        private void EvalMove(float proportion)
        {
            var progress = BattleUtil.CalculateTweenValue(proportion, clip.tweenType);
            var newLength = progress * _totalDistance;
            var offset = newLength - _moveDistance;
            _moveDistance = newLength;

            var curPos = context.actor.transform.position + offset * _destDir;
            context.actor.transform.SetPosition(curPos);
        }   
    }
}