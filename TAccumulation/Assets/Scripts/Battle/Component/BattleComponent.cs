namespace X3Battle
{
    public interface IBattleComponent
    {
        void OnActorBorn(Actor actor);
        void OnActorRecycle(Actor actor);
        void OnBattleBegin();
        void OnBattleEnd();
        void OnBattleShutDown();
    }

    public class BattleComponent : ECComponent, IBattleComponent
    {
        private Battle _battle;
        public Battle battle => _battle ?? (_battle = Battle.Instance);

        public BattleComponent(BattleComponentType type) : base((int) type)
        {
        }

        public virtual void OnActorBorn(Actor actor)
        {
        }

        public virtual void OnActorRecycle(Actor actor)
        {
        }

        public virtual void OnBattleBegin()
        {
        }

        public virtual void OnBattleEnd()
        {
        }

        public virtual void OnBattleShutDown()
        {
            
        }
    }
}
