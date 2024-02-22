using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/设置是否受击倒地")]
    [Serializable]
    public class SetIsLyingAsset : BSActionAsset<ActionSetIsLying>
    {
        [LabelText("设置是否处于倒地")]
        public bool isLying;
    }

    public class ActionSetIsLying : BSAction<SetIsLyingAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.hurt.SetIsLying(clip.isLying);
        }   
    }
}
