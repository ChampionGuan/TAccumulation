using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色运动/Update移速改变")]
    [Serializable]
    public class SwitchRootMotionMultiplyAsset : BSActionAsset<ActionSwitchRootMotionMultiply>
    {
    }

    public class ActionSwitchRootMotionMultiply : BSAction<SwitchRootMotionMultiplyAsset>
    {
        protected override void _OnUpdate()
        {
            context.actor.locomotion.UpdateDeltaRM();           
        }

        protected override void _OnExit()
        {
            // TODO 临时判空解决, 待长空考虑设计.
            if (context?.actor?.locomotion == null)
            {
                return;
            }
            context.actor.locomotion.moveCtrlSpeedMultiplier = 1;
        }    
    }
}
