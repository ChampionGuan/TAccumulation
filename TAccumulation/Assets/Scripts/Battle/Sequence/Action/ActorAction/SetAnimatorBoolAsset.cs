using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置Animator Bool参数")]
    [Serializable]
    public class SetAnimatorBoolAsset : BSActionAsset<ActionSetAnimatorBool>
    {
        [LabelText("参数名")]
        public string paramterName;
        [LabelText("值")]
        public bool value;
    }

    public class ActionSetAnimatorBool : BSAction<SetAnimatorBoolAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.animator.SetBool(clip.paramterName, clip.value);
        }   
    }
}