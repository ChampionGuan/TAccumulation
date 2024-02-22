using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("调整技能能量使用值\nSetSkillCostEnergy")]
    public class FASetSkillCostEnergy : FlowAction
    {
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>(SkillSlotType.Active);

        public BBParameter<int> skillIndex = new BBParameter<int>();

        public BBParameter<ModifyMode> modifyMode = new BBParameter<ModifyMode>(ModifyMode.Add);

        public BBParameter<float> modifyValue = new BBParameter<float>(1f);

        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            var o = AddFlowOutput("Out");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                _Invoke();
                o.Call(f);
            });

            _viActor = AddValueInput<Actor>(nameof(Actor));
        }
        
        protected override void _Invoke()
        {
            var target = _viActor.GetValue();
            if (target == null)
            {
                _LogError($"请联系策划【蜗牛君】【调整技能能量使用值 FASetSkillCostEnergy】配置错误, 引脚[Actor]没有正确赋值.");
                return;
            }
            
            var skillSlot = target.skillOwner.GetSkillSlot(skillSlotType.GetValue(), skillIndex.GetValue());
            if (skillSlot == null)
            {
                _LogError($"请联系策划【蜗牛君】【调整技能能量使用值 FASetSkillCostEnergy】配置错误, SkillSlotType={skillSlotType.GetValue()}, skillIndex={skillIndex.GetValue()}");
                return;
            }

            var mode = modifyMode.GetValue();
            var value = modifyValue.GetValue();
            switch (mode)
            {
                case ModifyMode.Add:
                    skillSlot.AddCostEnergyValue(AttrType.SkillEnergy, value);
                    break;
                case ModifyMode.Set:
                    skillSlot.SetCostEnergyValue(AttrType.SkillEnergy, value);
                    break;
            }
        }
    }
}
