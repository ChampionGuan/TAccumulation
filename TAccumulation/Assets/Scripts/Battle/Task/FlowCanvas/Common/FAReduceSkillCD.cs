using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("降低某个技能CD\nReduceSkillCD")]
    public class FAReduceSkillCD : FlowAction
    {
        public BBParameter<SkillSlotType> SkillSlotType = new BBParameter<SkillSlotType>();
        public BBParameter<int> SkillIndex = new BBParameter<int>();
        public BBParameter<float> Duration = new BBParameter<float>();

        private ValueInput<Actor> _viTarget;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viTarget = AddValueInput<Actor>("Target");
        }

        protected override void _Invoke()
        {
            var actor = _viTarget.GetValue();
            if (actor == null)
                return;
            var skillSlot = actor.skillOwner.GetSkillSlot(SkillSlotType.GetValue(), SkillIndex.GetValue());
            if (skillSlot == null)
            {
                _LogError($"请联系策划【卡宝】【降低某个技能CD ReduceSkillCD】配置错误, SkillSlotType={SkillSlotType.GetValue()}, SkillIndex={SkillIndex.GetValue()}");
                return;
            }

            var duration = Duration.GetValue();
            if (duration < 0f)
            {
                _LogError($"请联系策划【卡宝】【降低某个技能CD ReduceSkillCD】配置错误, SkillSlotType={SkillSlotType.GetValue()}, SkillIndex={SkillIndex.GetValue()}, Duration={Duration.GetValue()}");
                return;
            }
            
            skillSlot.ReduceRemainCD(Duration.GetValue());
        }
    }
}
