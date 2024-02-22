using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class IdleState : BaseMainState
    {
        public override ActorMainStateType stateType => ActorMainStateType.Idle;
        public IdleState(ActorMainState actorMainState) : base(actorMainState)
        {
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            var res = StateUtil.CommonSateUseCacheInput(_actor);
            if (res)
            {
                return;
            }
            if (_actor.locomotion?.moveType != MoveType.Num && _actor.locomotion?.destDir != Vector3.zero )
            {
                _mainState.TryToState(ActorMainStateType.Move);
            }
        }
    }
}