using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("技能释放结束\nSkillEnd")]
    public class FESkillEnd : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public BBParameter<SkillEndFlag> skillEndFlag = new BBParameter<SkillEndFlag>(SkillEndFlag.Complete);

        private EventEndSkill _eventEndSkill;

        private Action<EventEndSkill> _actionOnEventEndSkill;

        public FESkillEnd()
        {
            _actionOnEventEndSkill = _OnEventEndSkill;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("SkillCaster", () => _eventEndSkill?.skill?.actor);
            AddValueOutput<Actor>("SkillTarget", () => _eventEndSkill?.skill?.actor.GetTarget(TargetType.Skill));
            AddValueOutput<ISkill>("ISkill", () => _eventEndSkill?.skill);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, _actionOnEventEndSkill, "FESkillEnd._OnEventEndSkill");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _actionOnEventEndSkill);
        }

        void _OnEventEndSkill(EventEndSkill args)
        {
            if (_isTriggering || args == null)
                return;
            
            // DONE: 主体判断.
            if (!_IsMainObject(EventTarget.GetValue(), args.skill.actor))
                return;

            // DONE: 是否是关注的结束条件.
            if (((1 << (int)args.endType) & (int)skillEndFlag.GetValue()) == 0)
            {
                return;
            }

            _eventEndSkill = args;
            _Trigger();
            _eventEndSkill = null;
        }
    }
}
