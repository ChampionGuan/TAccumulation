using Framework;
using PapeAnimation;
using UnityEngine;
using UnityEngine.Playables;

namespace X3Battle
{
    public class ActorPlayable : PlayableNode
    {
        private PlayableInstance _playableInstance;
        public PlayableAnimationManager playableAnimMgr { get; protected set; }
        public bool isDestroyed { get; protected set; }

        public ActorPlayable(Animator animator) : base(1, 0, (int) ActorPlayableType.Num)
        {
            _playableInstance = new PlayableInstance(this);

            isDestroyed = false;
            playableAnimMgr = PlayableAnimationManager.Instance();
            playableAnimMgr.AddAnimation(animator, _playableInstance, EStaticSlot.Battle);
            playableAnimMgr.SetBlendingWeight(animator.gameObject, EStaticSlot.Battle, weight);
        }

        public Playable RebuildPlayable(PlayableGraph graph)
        {
            if (isDestroyed)
            {
                return Playable.Null;
            }

            _graph = graph;
            return RebuildPlayable();
        }

        public override void OnDestroy()
        {
            if (isDestroyed)
            {
                return;
            }

            base.OnDestroy();
            isDestroyed = true;
            playableAnimMgr.RemoveAnimation(_playableInstance);
        }
    }

    public class PlayableInstance : GenericAnimationNode
    {
        private ActorPlayable _actorPlayable;

        public PlayableInstance(ActorPlayable actorPlayable)
        {
            _actorPlayable = actorPlayable;
        }

        protected override void OnBuild()
        {
            _actorPlayable.RebuildPlayable(GetPlayableGraph());
        }

        protected override void OnDestroy()
        {
            _actorPlayable?.OnDestroy();
        }

        public override GenericAnimationMixer GetMixer()
        {
            return null;
        }

        public override Playable GetOutput()
        {
            return _actorPlayable?.playable ?? Playable.Null;
        }

        public override Playable GetInput()
        {
            return _actorPlayable?.playable ?? Playable.Null;
        }

        public override void Tick(float deltaTime)
        {
        }
    }
}
