using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置相机朝向怪物")]
    [Serializable]
    public class SetBattleCameraPitchAndYawAsset: BSActionAsset<ActionSetBattleCameraPitchAndYaw>
    {

    }

    public class ActionSetBattleCameraPitchAndYaw : BSAction<SetBattleCameraPitchAndYawAsset>
    {
        protected override void _OnEnter()
        {
            context.battle.cameraTrace.SetPitchAndYawToTarget(context.actor);
        }
    }

}
