using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("将要发生技能衔接\nFESwitchRunningSkill")]
    public class FESwitchRunningSkill : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        
        private EventSwitchRunningSkill _eventSwitchSkill;
        private Action<EventSwitchRunningSkill> _actionOnCastSkill;

        public FESwitchRunningSkill()
        {
            _actionOnCastSkill = _OnSwitchRunningSkill;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<ISkill>("FirstISkill", () => _eventSwitchSkill?.curSkill);
            AddValueOutput<ISkill>("NextISkill", () => _eventSwitchSkill?.nextSkill);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventSwitchRunningSkill>(EventType.SwitchRunningSkill, _actionOnCastSkill, "FESwitchRunningSkill._OnCastSkill");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventSwitchRunningSkill>(EventType.SwitchRunningSkill, _actionOnCastSkill);
        }

        private void _OnSwitchRunningSkill(EventSwitchRunningSkill eventCastSkill)
        {
            if (_isTriggering || eventCastSkill == null || eventCastSkill.curSkill == null || eventCastSkill.nextSkill == null)
                return;
            
            if (!_IsMainObject(this.EventTarget.GetValue(), eventCastSkill.curSkill.GetCaster()))
                return;
            
            //SkillTimeline 类型的技能释放才能接受 并且 不是法术场
            if (!(eventCastSkill.curSkill is SkillTimeline && eventCastSkill.nextSkill is SkillTimeline) || eventCastSkill.curSkill is SkillMagicField || eventCastSkill.nextSkill is SkillMagicField)
                return;

            _eventSwitchSkill = eventCastSkill;
            _Trigger();
            _eventSwitchSkill = null;
        }
    }
}
