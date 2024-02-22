using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/Action")]
    [Name("NACastActorSkill")]
    [Description("让指定actor释放指定的技能")]
    public class NACastActorSkill : BattleAction
    {
        public BBParameter<Actor> skillCaster = new BBParameter<Actor>();
        public BBParameter<Actor> skillTarget = new BBParameter<Actor>();
        public BBParameter<bool> resetCaster = new BBParameter<bool>();
        
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>();
        public BBParameter<int> skillSlotIndex = new BBParameter<int>();
        protected override void OnExecute()
        {
            var caster = skillCaster.GetValue();
            var target = skillTarget.GetValue();
            if (caster == null)
                return;
            var slotId = caster.skillOwner.GetSlotID(skillSlotType.GetValue(), skillSlotIndex.GetValue());
            if (null == slotId)
            {
                return;
            }

            // DONE: 是否强制重置角色状态
            if (resetCaster.GetValue())
            {
                caster.ForceIdle();
            }

            // DONE: 释放技能
            bool result = caster.skillOwner.TryCastSkillBySlot(slotId.Value, target);
            EndAction(result);
        }
    }
}
