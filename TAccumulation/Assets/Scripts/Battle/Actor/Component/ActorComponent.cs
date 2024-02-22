using Unity.Profiling;

namespace X3Battle
{
    public interface IActorComponent
    {
        ProfilerMarker namePMarker { get; }
        void OnBorn();
        void OnDead();
        void OnRecycle();
    }

    public class ActorComponent : ECComponent, IActorComponent
    {
        private Actor _actor;
        public Actor actor => _actor ?? (_actor = GetComponent<Actor>());
        public Battle battle => actor.battle;

        public ActorComponent(ActorComponentType type) : base((int)type)
        {
        }

        public virtual void OnBorn()
        {
        }

        public virtual void OnDead()
        {
        }

        public virtual void OnRecycle()
        {
        }
    }
}