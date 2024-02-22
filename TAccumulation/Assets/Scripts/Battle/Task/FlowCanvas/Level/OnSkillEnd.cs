using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("NPC技能打断监听器\nOnSkillEnd")]
    public class OnSkillEnd : FlowListener
    {
        [Name("SpawnID")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<int> skillId = new BBParameter<int>();

        private Action<EventEndSkill> _actionOnSkillEnd;

        public OnSkillEnd()
        {
            _actionOnSkillEnd = _OnSkillEnd;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, _actionOnSkillEnd, "OnSkillEnd._OnSkillEnd");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _actionOnSkillEnd);
        }

        private void _OnSkillEnd(EventEndSkill arg)
        {
            if (IsReachMaxCount())
                return;
            if (arg.endType == SkillEndType.Complete)
                return;
            if (arg.skill == null)
                return;
            if (arg.skill.actor == null || arg.skill.actor.spawnID != actorId.GetValue())
                return;
            if (arg.skill.GetID() != skillId.GetValue())
                return;

            _Trigger();
        }
    }
} 
