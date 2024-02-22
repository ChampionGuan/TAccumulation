using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置援护技结束时镜头朝向与男主朝向的偏差")]
    [Serializable]
    public class SetArtCameraOffsetAsset : BSActionAsset<ActionSetArtCameraOffset>
    {
        [LabelText("偏差yaw值, 顺时针为正，逆时针为负")]
        public float offsetYaw;

    }

    public class ActionSetArtCameraOffset:BSAction<SetArtCameraOffsetAsset>
    {
        protected override void _OnEnter()
        {
            context.battle.cameraTrace.SetArtYawOffset(clip.offsetYaw);
        }

        protected override void _OnExit()
        {
            context.battle.cameraTrace.SetArtYawOffset(0);
        }
    }
}
