using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色运动/原地旋转速度")]
    [Serializable]
    public class SetSpotTurnAsset : BSActionAsset<ActionSetSpotTurn>
    {
        [LabelText("是否旋转")]
        public bool isRotate = true;
        [LabelText("旋转到目标后是否Stop")]
        public bool isRotateToStop = true;
    }

    public class ActionSetSpotTurn : BSAction<SetSpotTurnAsset>
    {
        LocomotionCtrl _locomotionCtrl;

        protected override void _OnEnter()
        {
            base._OnEnter();
            _locomotionCtrl = context.actor.locomotion;
            _locomotionCtrl.isSpotTurnArrivedStop = clip.isRotateToStop;
            _locomotionCtrl.isSpotTurnExtCtrlSpeed = true;
        }

        protected override void _OnUpdate()
        {
            base._OnUpdate();
            if (_locomotionCtrl == null)
                return;
            if (_locomotionCtrl.spotTurnMode != SpotTurnMode.RealTimeSpeed && _locomotionCtrl.spotTurnMode != SpotTurnMode.RealTimeDirSpeed)
                return;

            if(clip.isRotate)
            {
                _locomotionCtrl.GetMoveDeltaAngleY(out var angleY, out var sign);
                if (sign != _locomotionCtrl.setSpotTurnSign)
                {
                    angleY = 360 - angleY;
                }
                var speed = angleY / (duration - curOffsetTime);
                speed = Mathf.Clamp(speed, _locomotionCtrl.spotTurnMinSpeed, _locomotionCtrl.spotTurnMaxSpeed);
                _locomotionCtrl.turnCurSpeed = speed;
            }
            else
            {
                _locomotionCtrl.turnCurSpeed = 0;
            }
        }

        protected override void _OnExit()
        {
            base._OnExit();
            _locomotionCtrl.turnCurSpeed = 0;
            _locomotionCtrl.isSpotTurnExtCtrlSpeed = false;
        }
    }
}
