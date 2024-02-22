using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置Animator Float参数")]
    [Serializable]
    public class SetAnimatorFloatAsset : BSActionAsset<ActionSetAnimatorFloat>
    {
        [LabelText("参数名")]
        public string paramterName;
        [LabelText("float值")]
        public float value = 0;
    }

    public class ActionSetAnimatorFloat : BSAction<SetAnimatorFloatAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.animator.SetFloat(clip.paramterName, clip.value);

            //TurnBack只有一个State 按照turnLeft是正确的  如果moveDir大于0 取反
            if (clip.paramterName == AnimParams.StopFoot &&
                context.actor.animator.GetCurrentAnimatorStateName() == AnimStateName.TurnBack &&
                context.actor.animator.GetFloat(AnimParams.MoveDirection) > 0)
            {
                if (clip.value == 1)
                    context.actor.animator.SetFloat(AnimParams.StopFoot, 0);
                else
                    context.actor.animator.SetFloat(AnimParams.StopFoot, 1);
            }
        }   
    }
}