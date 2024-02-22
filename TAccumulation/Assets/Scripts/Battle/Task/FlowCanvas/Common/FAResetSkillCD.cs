using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("刷新技能CD\nResetSkillCD")]
    public class FAResetSkillCD : FlowAction
    {
        public BBParameter<SkillSlotType> SkillSlotType = new BBParameter<SkillSlotType>();
        public BBParameter<int> SkillIndex = new BBParameter<int>();

        private ValueInput<Actor> _viTarget;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viTarget = AddValueInput<Actor>("SourceActor");
        }

        protected override void _Invoke()
        {
            var actor = _viTarget.GetValue();
            if (actor == null)
                return;
            var skillSlot = actor.skillOwner.GetSkillSlot(SkillSlotType.GetValue(), SkillIndex.GetValue());
            if (skillSlot == null)
            {
                _LogError($"请联系策划【卡宝】【刷新技能CD ResetSkillCD】配置错误, SkillSlotType={SkillSlotType.GetValue()}, SkillIndex={SkillIndex.GetValue()}");
                return;
            }

            skillSlot.SetRemainCD(0f);
        }
    }
}
