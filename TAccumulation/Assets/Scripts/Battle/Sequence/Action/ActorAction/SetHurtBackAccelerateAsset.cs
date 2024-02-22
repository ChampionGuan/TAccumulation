using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{

    [TimelineMenu("角色动作/设置受击加速度")]
    [Serializable]
    public class SetHurtBackAccelerateAsset : BSActionAsset<ActionSetHurtBackAccelerate>
    {
        [LabelText("设置受击水平加速度")]
        public float hurtBackAccelate;
        [LabelText("设置受击竖直加速度")]
        public float hurtHeightAccelate;
    }

    public class ActionSetHurtBackAccelerate : BSAction<SetHurtBackAccelerateAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.hurt.SetHurtBackAccelerate(clip.hurtBackAccelate, clip.hurtHeightAccelate);
        }   
    }
}
