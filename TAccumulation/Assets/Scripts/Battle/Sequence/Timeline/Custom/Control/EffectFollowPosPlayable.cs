using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace PapeGames
{
    // 运行时根据参考节点
    public class EffectFollowPosPlayable : MountPlayableBehaviourBase
    {
        private Transform referent;
        private Vector3 lastPos;

        private FxPlayerPlayable fxPlayerPlayable;

        public void SetReferent(Transform referent)
        {
            this.referent = referent;
            if (referent != null) 
            {
               lastPos = referent.position;  
            }
        }

        public void SetFxPlayerPlayable(FxPlayerPlayable fxPlayable)
        {
            fxPlayerPlayable = fxPlayable;
        }

        protected override void OnBehaviourPlay(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            if (referent != null && Application.isPlaying)
            {
                Transform targetTransform = CheckValidAndGetTargetTransform(behaviour);
                if (targetTransform != null)
                {
                    var offset = referent.position - lastPos;
                    targetTransform.position += offset;
                }
            }

            if (fxPlayerPlayable != null)
                fxPlayerPlayable.Play(behaviour, playable, info);
        }

        protected override void OnProcessFrame(PlayableBehaviour behaviour, Playable playable, FrameData info, object userData)
        {
            base.OnProcessFrame(behaviour, playable, info, userData);
            if (fxPlayerPlayable != null)
                fxPlayerPlayable.ProcessFrame(behaviour, playable, info, userData);
        }

        protected override void OnBehaviourPause(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            base.OnBehaviourPause(behaviour, playable, info);

            if (fxPlayerPlayable != null)
                fxPlayerPlayable.Pause(behaviour, playable, info);
        }

        private Transform CheckValidAndGetTargetTransform(PlayableBehaviour behaviour)
        {
            if (referent != null && Application.isPlaying)
            {
                ActivationControlPlayable activePlayable = behaviour as ActivationControlPlayable;
                if (activePlayable != null && activePlayable.gameObject != null)
                {
                    return activePlayable.gameObject.transform;
                }
            }

            return null;
        }
    }
}