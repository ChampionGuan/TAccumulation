using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/修改芯核护盾值上限值")]
    [Serializable]
    public class ModifyCoreShieldMaxAsset : BSActionAsset<ActionModifyCoreShieldMax>
    {
        [LabelText("修改类型（增加或减少）")]
        public ModifyShieldType type;
        [LabelText("修改的值")]
        public float value;
    }

    public class ActionModifyCoreShieldMax : BSAction<ModifyCoreShieldMaxAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.actorWeak?.ModifyShieldMax(clip.value, clip.type);
        }
    }
}
