using UnityEngine;

namespace X3Battle
{
    public class BornState : BaseMainState
    {
        public override ActorMainStateType stateType => ActorMainStateType.Born;

        public BornState(ActorMainState actorMainState) : base(actorMainState)
        {
        }

        protected override void OnUpdate()
        {
            if (_actor.locomotion?.moveType != MoveType.Num && _actor.locomotion?.destDir != Vector3.zero )
            {
                _mainState.TryToState(ActorMainStateType.Move);
            }
        }
    }
}