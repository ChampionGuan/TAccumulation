using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("获取技能攻击距离")]
    public class GetSkillRange : BattleAction
    {
        public BBParameter<Actor> caster = new BBParameter<Actor>();
        public BBParameter<SkillSlotType> skillType = new BBParameter<SkillSlotType>();
        public BBParameter<int> skillIndex = new BBParameter<int>();
        public BBParameter<bool> isMinRange = new BBParameter<bool>();
        public BBParameter<float> storeResult = new BBParameter<float>();

        protected override void OnExecute()
        {
            if (null == caster || caster.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var slotID = BattleUtil.GetSlotID(skillType.value, skillIndex.value);
            var skill = caster.value.skillOwner.GetSkillBySlot(slotID);
            if (null == skill)
            {
                EndAction(false);
                return;
            }

            storeResult.value = isMinRange.value ? skill.config.MinRange : skill.config.MaxRange;
            EndAction(true);
        }
    }
}
