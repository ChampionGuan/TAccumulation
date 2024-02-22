using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断技能Type\nCompareSkillType")]
    public class FACompareSkillType : FlowCondition
    {
        public BBParameter<SkillType> skillType = new BBParameter<SkillType>();
        private ValueInput<ISkill> _viSkill;

        protected override void _OnAddPorts()
        {
            _viSkill = AddValueInput<ISkill>(nameof(ISkill));
        }

        protected override bool _IsMeetCondition()
        {
            var skill = _viSkill.GetValue();
            if (skill == null)
                return false;
            var type = skillType.GetValue();
            if (!skill.CompareSkillType(type))
            {
                return false;
            }

            return true;
        }
    }
}
