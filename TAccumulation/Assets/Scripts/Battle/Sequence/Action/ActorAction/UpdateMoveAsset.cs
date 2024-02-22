using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色运动/移动Update检测折返")]
    [Serializable]
    public class UpdateMoveAsset : BSActionAsset<ActionUpdateMove>
    {
        [LabelText("最小触发折返角度")]
        public float minTurnBackAngle;
        [LabelText("最小触发折返RootMotion Multiplier")]
        public float minTurnBackRmMultiplier = 0.9f;
        [LabelText("折返Animator条件变量名")]
        public string turnBackParam;
        [LabelText("折返是否暂停旋转")]
        public bool isPauseCharacterCtrl = true;
    }

    public class ActionUpdateMove : BSAction<UpdateMoveAsset>
    {
        protected override void _OnUpdate()
        {
            context.actor.locomotion.GetMoveDeltaAngleY(out var includeAngleY, out var sign);
            if (includeAngleY >= clip.minTurnBackAngle &&
                context.actor.locomotion.moveCtrlSpeedMultiplier >= clip.minTurnBackRmMultiplier)
            {
                //折返
                //为了防止不断旋转时触发折返 正常折返移动速度是很高的 而不断旋转时 移动速度较低
                context.actor.locomotion.SetPause(clip.isPauseCharacterCtrl);
                context.actor.animator.SetFloat(AnimParams.MoveDirection, includeAngleY * sign);
                context.actor.animator.SetBool(clip.turnBackParam, true);
            }
        }   
    }
}
