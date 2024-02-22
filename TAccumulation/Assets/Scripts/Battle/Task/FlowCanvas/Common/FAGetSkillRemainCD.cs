using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取技能剩余CD\nGetSkillRemainCD")]
    public class FAGetSkillRemainCD : FlowAction
    {
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>(SkillSlotType.SkillID);
        public BBParameter<int> skillSlotIndex = new BBParameter<int>(0);
        private ValueInput<Actor> _viActor;
        protected override void _OnRegisterPorts()
        {
            _viActor = AddValueInput<Actor>(nameof(Actor));
            AddValueOutput("CoolDownTime", () =>
            {
                var target = _viActor?.GetValue();
                if (target == null)
                {
                    _LogError($"【获取技能CD GetSkillCD】节点, 参数引脚配置错误, 【Actor】不应为null!");
                    return -1f;
                }

                if (target.skillOwner == null)
                {
                    _LogError($"【获取技能CD GetSkillCD】节点, 参数引脚配置错误, 【Actor】没有SkillOwner组件!");
                    return -1f;
                }
                
                var skillSlot = target.skillOwner.GetSkillSlot(skillSlotType.GetValue(), skillSlotIndex.GetValue());
                if (skillSlot == null)
                {
                    _LogError($"【获取技能CD GetSkillCD】节点, 参数配置错误, 目标{target.name} 没有skillSlotType={skillSlotType.GetValue()}, skillSlotIndex={skillSlotIndex.GetValue()}的技能!");
                    return -1f;
                }
                
                return skillSlot.remainCD;
            });
        }
    }
}
