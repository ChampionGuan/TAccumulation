using UnityEngine;

namespace X3Battle
{
    public class TriggerBuffContext : TriggerContext, IActorContext
    {
        public override float deltaTime => buff.GetDeltaTime();
        
        public override Transform parent => actor.GetDummy();
        public override object creater => buff;

        public Actor actor => buff.owner.actor;

        public IBuff buff { get; }

        public TriggerBuffContext(IBuff buff): base(buff.owner.battle)
        {
            this.buff = buff;
        }

        public TriggerBuffContext(IBuff buff, float time) : base(buff.owner.battle, lifeTime: time, level: ((X3Buff) buff).layer)
        {
            this.buff = buff;
        }
    }
}
