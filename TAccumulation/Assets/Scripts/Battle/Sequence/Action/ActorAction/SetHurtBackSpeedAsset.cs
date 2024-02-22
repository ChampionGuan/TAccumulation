using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置受击速度")]
    [Serializable]
    public class SetHurtBackSpeedAsset : BSActionAsset<ActionSetHurtBackSpeed>
    {
        [LabelText("设置受击水平速度")]
        public float hurtBackSpeed;
        [LabelText("设置受击竖直速度")]
        public float hurtHeightSpeed;
        [LabelText("是否使用配置")]
        public bool useConfig;
    }

    public class ActionSetHurtBackSpeed : BSAction<SetHurtBackSpeedAsset>
    {
        protected override void _OnEnter()
        {
            if (!clip.useConfig)
                context.actor.hurt.SetHurtBackSpeed(clip.hurtBackSpeed, clip.hurtHeightSpeed);
        }   
    }
}
