using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作(法术场)/法术场进行Hit")]
    [Serializable]
    public class MagicFieldHitAsset : BSActionAsset<ActionMagicFieldHit>
    {
        [LabelText("伤害盒ID (>0有效)", jumpType:JumpModuleType.ViewDamageBox)]
        public int damageBoxID;
        [LabelText("创建光环ID (>0有效)", jumpType:JumpModuleType.ViewHalo)]
        public int haloID;
    }

    public class ActionMagicFieldHit : BSAction<MagicFieldHitAsset>
    {
        protected override void _OnEnter()
        {
            var magicFieldSkill = context.skill as SkillMagicField;
            if (magicFieldSkill != null)
            {
                magicFieldSkill.Hit(clip.damageBoxID, clip.haloID);   
            }
        }   
    }
}