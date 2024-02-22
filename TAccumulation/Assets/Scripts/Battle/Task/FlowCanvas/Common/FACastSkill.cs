using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("释放技能\nCastSkill")]
    public class FACastSkill : FlowAction
    {
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>();
        public BBParameter<int> skillSlotIndex = new BBParameter<int>();
        public BBParameter<bool> resetCaster = new BBParameter<bool>();

        private ValueInput<Actor> _viSkillCaster;
        private ValueInput<Actor> _viSkillTarget;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viSkillCaster = AddValueInput<Actor>("SkillCaster");
            _viSkillTarget = AddValueInput<Actor>("SkillTarget");
        }

        protected override void _Invoke()
        {
            var caster = _viSkillCaster.GetValue();
            var target = _viSkillTarget.GetValue();
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
            caster.skillOwner.TryCastSkillBySlot(slotId.Value, target);
        }
    }
}
