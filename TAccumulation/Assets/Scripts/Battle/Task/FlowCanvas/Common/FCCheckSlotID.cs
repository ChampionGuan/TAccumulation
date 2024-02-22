using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断技能ID或槽位ID\nCheckSlotID")]
    public class FCCheckSlotID : FlowCondition
    {
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>(SkillSlotType.SkillID);
        public BBParameter<int> skillSlotIndex = new BBParameter<int>(0);

        private ValueInput<ISkill> _viSkill;
        
        protected override void _OnAddPorts()
        {
            _viSkill = AddValueInput<ISkill>("ISkill");
        }

        protected override bool _IsMeetCondition()
        {
            var skill = _viSkill.GetValue();
            if (skill == null)
            {
                _LogError("节点【判断技能ID或槽位ID CheckSlotID】, 请联系策划【蜗牛君】, ISkill引脚配置错误, 参数为null");
                return false;
            }

            var skillSlot = skill.actor.skillOwner.GetSkillSlot(skillSlotType.GetValue(), skillSlotIndex.GetValue());
            if (skillSlot == null)
            {
                return false;
            }
            
            if (skillSlot.skill != skill)
            {
                return false;
            }

            return true;
        }
    }
}
