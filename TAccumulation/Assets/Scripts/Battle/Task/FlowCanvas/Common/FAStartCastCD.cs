using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("技能开始CD\nFAStartCastCD")]
    public class FAStartCastCD : FlowAction
    {
        private ValueInput<ISkill> _viSkill;
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSkill = AddValueInput<ISkill>(nameof(ISkill));
        }

        protected override void _Invoke()
        {
            var skill = _viSkill?.GetValue() ?? _source as ISkill;
            if (skill == null)
            {
                _LogError("请联系策划【佚之喵】,【技能开始CD FAStartCastCD】节点只能在技能图里使用.");
                return;
            }
            
            var slot = skill.actor.skillOwner.GetSkillSlot(skill.slotID);
            if (slot != null)
            {
                slot.StartCastCD();
            }
        }
    }
}
