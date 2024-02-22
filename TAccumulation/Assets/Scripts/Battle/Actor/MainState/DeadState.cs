namespace X3Battle
{
    public class DeadState : BaseMainState
    {
        public override ActorMainStateType stateType => ActorMainStateType.Dead;
        public DeadState(ActorMainState actorMainState) : base(actorMainState)
        {
        }
    }
}