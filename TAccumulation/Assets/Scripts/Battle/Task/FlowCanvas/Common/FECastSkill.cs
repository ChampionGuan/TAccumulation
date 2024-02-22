using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("释放技能时\nCastSkill")]
    public class FECastSkill : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventCastSkill _eventCastSkill;

        private Action<EventCastSkill> _actionOnCastSkill;

        public FECastSkill()
        {
            _actionOnCastSkill = _OnCastSkill;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventCastSkill>(nameof(EventCastSkill), () => _eventCastSkill);
            AddValueOutput<Actor>("SkillCaster", () => _eventCastSkill?.skill?.actor);
            AddValueOutput<Actor>("SkillTarget", () => _eventCastSkill?.skillTarget);
            AddValueOutput<ISkill>("ISkill", () => _eventCastSkill?.skill);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _actionOnCastSkill, "FECastSkill._OnCastSkill");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, _actionOnCastSkill);
        }

        private void _OnCastSkill(EventCastSkill eventCastSkill)
        {
            if (_isTriggering || eventCastSkill == null || eventCastSkill.skill == null)
                return;
            if (!_IsMainObject(this.EventTarget.GetValue(), eventCastSkill.skill.GetCaster()))
                return;
            //SkillTimeline 类型的技能释放才能接受 并且 不是法术场
            if (!(eventCastSkill.skill is SkillTimeline) || eventCastSkill.skill is SkillMagicField)
                return;

            _eventCastSkill = eventCastSkill;
            _Trigger();
            _eventCastSkill = null;
        }
    }
}
