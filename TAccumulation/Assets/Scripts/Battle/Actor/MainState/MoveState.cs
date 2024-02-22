namespace X3Battle
{
    public class MoveState : BaseMainState
    {
        public override ActorMainStateType stateType => ActorMainStateType.Move;
        public MoveState(ActorMainState actorMainState) : base(actorMainState)
        {
        }
    }
}