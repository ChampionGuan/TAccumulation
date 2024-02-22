using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/修改当前芯核护盾值")]
    [Serializable]
    public class ModifyCoreShieldAsset : BSActionAsset<ActionModifyCoreShield>
    {
        [LabelText("修改类型（增加或减少）")]
        public ModifyShieldType type;
        [LabelText("修改的值")]
        public float value;
    }

    public class ActionModifyCoreShield : BSAction<ModifyCoreShieldAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.actorWeak?.ModifyShield(clip.value, clip.type);
        }
    }
}
