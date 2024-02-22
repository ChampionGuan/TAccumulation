using System;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class BSADynamicActorAnim : X3Sequence.Action
    {
        private string _clipName;
        private Func<string, PlayableAnimator> _animatorFunc;
        private Func<string, string> _animNameFunc;

        public void SetData(string clipName, Func<string, PlayableAnimator> animatorFunc, Func<string, string> animNameFunc)
        {
            _clipName = clipName;
            _animatorFunc = animatorFunc;
            _animNameFunc = animNameFunc;
        }

        protected override void _OnEnter()
        {
            if (_animatorFunc== null)
            {
                return;
            }

            if (_animNameFunc == null)
            {
                return;
            }

            var animator = _animatorFunc.Invoke(_clipName);
            var animName = _animNameFunc.Invoke(_clipName);
            if (animator != null && !string.IsNullOrEmpty(animName))
            {
                PapeGames.X3.LogProxy.LogFormat("timeline尝试播放Animator动画 {0}", animName);
                // DONE: 动画需求重置播放.
                animator.Play(animName, 0, 0f);
                animator.Update(startOffsetTime, true);
            }
        }
    }
}