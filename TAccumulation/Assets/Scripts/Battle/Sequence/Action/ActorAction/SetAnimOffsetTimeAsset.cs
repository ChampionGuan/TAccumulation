using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色运动/设置动画的offset")]
    [Serializable]
    public class SetAnimOffsetTimeAsset : BSActionAsset<ActionSetAnimOffsetTime>
    {
        [LabelText("动画名")]
        public string animName;
        [LabelText("起始offset")]
        public float offsetTime;
    }

    public class ActionSetAnimOffsetTime: BSAction<SetAnimOffsetTimeAsset>
    {
        protected override void _OnEnter()
        {
            (context.actor.animator.runtimeAnimatorController.context as BattleAnimatorCtrlContext)?.AddModifyOffsetTime(clip.animName, clip.offsetTime);
        }

        protected override void _OnExit()
        {
            (context.actor.animator.runtimeAnimatorController.context as BattleAnimatorCtrlContext)?.RemoveModefyOffsetTime(clip.animName);
        }
    }
}
