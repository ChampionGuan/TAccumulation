using UnityEngine;

namespace X3Battle
{
    public class TriggerSkillContext : TriggerContext, IActorContext
    {
        public override float deltaTime => skill.GetDeltaTime();
        public override Transform parent => actor.GetDummy();

        public override object creater => skill;

        public Actor actor => skill.actor;

        public ISkill skill { get; }

        public TriggerSkillContext(ISkill skill) : base(skill.actor.battle, level: skill.level)
        {
            this.skill = skill;
        }
    }
}