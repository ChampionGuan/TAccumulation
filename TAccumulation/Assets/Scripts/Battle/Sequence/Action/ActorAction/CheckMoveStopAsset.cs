using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色运动/检测跑停")]
    [Serializable]
    public class CheckMoveStopAsset : BSActionAsset<ActionCheckMoveStop>
    {
        [LabelText("Animator跑停变量名")] public string animatorParam;
    }

    public class ActionCheckMoveStop : BSAction<CheckMoveStopAsset>
    {
        protected override void _OnUpdate()
        {
            if (!context.actor.locomotion.HasDestDir)
            {
                context.actor.animator.SetBool(clip.animatorParam, true);
            }
        }

        protected override void _OnExit()
        {
            context.actor.animator?.SetBool(clip.animatorParam, false);
        }   
    }
}