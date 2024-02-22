using UnityEngine;
using UnityEngine.Playables;
using X3;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class AnimCtrlPlayable : PlayableNode
    {
        private PlayableAnimator _animator;

        public AnimCtrlPlayable(PlayableAnimator animator) : base(1, (int) ActorPlayableType.AnimCtrl)
        {
            _animator = animator;
        }

        public override Playable CreatePlayable()
        {
            var animCtrl = _animator.runtimeAnimatorController;
            if (null == animCtrl)
            {
                return Playable.Null;
            }

            var playable = animCtrl.RebuildPlayable((_animator as BattleAnimator).CreateContext(), _animator, parent.playable, inputIndex);
            animCtrl.OnStart();
            return playable;
        }
    }
}
