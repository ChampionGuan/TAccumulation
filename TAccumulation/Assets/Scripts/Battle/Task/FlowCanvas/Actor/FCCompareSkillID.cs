using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("判断技能ID\nCompareSkillID")]
    public class FCCompareSkillID : FlowCondition
    {
        public BBParameter<int> skillID = new BBParameter<int>();
        
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
            var id = skillID.GetValue();
            if (skill.GetID() != id)
            {
                return false;
            }

            return true;
        }
    }
}
