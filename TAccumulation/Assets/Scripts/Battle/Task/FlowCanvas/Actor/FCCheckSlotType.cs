using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("检查SlotType\nCheckSlotType")]
    public class FCCheckSlotType : FlowCondition
    {
        public BBParameter<SkillSlotType> SlotType = new BBParameter<SkillSlotType>(SkillSlotType.Attack);
        private ValueInput<ISkill> _viSkill;

        protected override void _OnAddPorts()
        {
            _viSkill = AddValueInput<ISkill>("Skill");
        }

        protected override bool _IsMeetCondition()
        {
            var skill = _viSkill.GetValue();
            if (skill == null)
                return false;
            if (skill.GetSlotType() != SlotType.GetValue())
                return false;
            return true;
        }
    }
}
