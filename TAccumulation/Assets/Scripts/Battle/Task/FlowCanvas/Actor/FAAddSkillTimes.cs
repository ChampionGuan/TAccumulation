using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("技能充能次数增加\nAddSkillTimes")]
    public class FAAddSkillTimes : FlowAction
    {
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>(SkillSlotType.SkillID);
        public BBParameter<int> skillSlotIndex = new BBParameter<int>(0);
        public BBParameter<int> addTimes = new BBParameter<int>(1);

        private ValueInput<Actor> _viTarget;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viTarget = AddValueInput<Actor>("Target");
        }

        protected override void _Invoke()
        {
            var target = _viTarget.GetValue();
            if (target == null)
            {
                _LogError("请联系策划【蜗牛君】,【技能充能次数增加 AddSkillTimes】Target的引脚没有配置, 目前为null");
                return;
            }
            if (target.skillOwner == null)
            {
                _LogError($"请联系策划【蜗牛君】,【技能充能次数增加 AddSkillTimes】Target的引脚没有正确配置, {target.name}没有SkillOwner组件.");
                return;
            }
            
            var skillSlot = target.skillOwner.GetSkillSlot(skillSlotType.GetValue(), skillSlotIndex.GetValue());
            if (skillSlot == null)
            {
                _LogError($"请联系策划【蜗牛君】,【技能充能次数增加 AddSkillTimes】技能没有正确配置, {target.name}没有该技能配置, skillSlotType:{skillSlotType.GetValue()}, skillSlotIndex:{skillSlotIndex.GetValue()}.");
                return;
            }

            var times = addTimes.GetValue();
            if (times < 0)
            {
                _LogError($"请联系策划【蜗牛君】,【技能充能次数增加 AddSkillTimes】次数没有正确配置, 次数:{times}.");
                return;
            }
            
            skillSlot.AddCastCount(times);
            PapeGames.X3.LogProxy.LogFormat("图【{0}】【技能充能次数增加 AddSkillTimes】添加次数{1}", this._graphOwner.name, times);

            // DONE: 当充能后, 技能次数处于最大值时, 使当前技能CD结束.
            if (skillSlot.IsFullCastCount())
            {
                skillSlot.SetRemainCD(0f);
            }
        }
    }
}
