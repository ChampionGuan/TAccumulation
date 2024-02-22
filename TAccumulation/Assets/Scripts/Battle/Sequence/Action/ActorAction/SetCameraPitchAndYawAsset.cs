using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置相机朝向怪物")]
    [Serializable]
    public class SetCameraPitchAndYawAsset: BSActionAsset<ActionSetBsCameraPitchAndYaw>
    {

    }

    public class ActionSetBsCameraPitchAndYaw : BSAction<SetCameraPitchAndYawAsset>
    {
        protected override void _OnEnter()
        {
            context.battle.cameraTrace.SetPitchAndYawToTarget(context.actor);
        }
    }

}
