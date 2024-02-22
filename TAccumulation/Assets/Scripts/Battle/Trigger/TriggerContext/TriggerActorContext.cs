using UnityEngine;

namespace X3Battle
{
    public class TriggerActorContext : TriggerContext, IActorContext
    {
        private Actor _actor;
        public override float deltaTime => _actor.deltaTime;
        public override Transform parent => _actor.GetDummy();
        public override object creater => _actor;

        public Actor actor
        {
            get => _actor;
            set => _actor = value;
        }

        public TriggerActorContext(Actor actor) : base(actor.battle)
        {
            _actor = actor;
        }
    }
}