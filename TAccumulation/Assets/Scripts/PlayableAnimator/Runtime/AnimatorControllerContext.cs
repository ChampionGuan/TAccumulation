using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3.PlayableAnimator
{
    public class AnimatorControllerContext
    {
        protected AnimatorController m_Owner;
        protected Transform[] transforms = new Transform[0];
        protected Transform[] newParents = new Transform[0];

        public void SetOwner(AnimatorController owner)
        {
            m_Owner = owner;
        }

        public virtual void Reset()
        {
        }

        public virtual Playable CreateClipPlayable(AnimationClip clip)
        {
            return AnimationClipPlayable.Create(m_Owner.playableGraph, clip);
        }

        public virtual BoneLayerMixer.BoneLayerMixerPlayable CreateBoneLayerMixerPlayable(PlayableGraph graph, int layersCount)
        {
            return BoneLayerMixer.BoneLayerMixerPlayable.Create(graph, transforms, newParents, layersCount);
        }

        public virtual void ModifyTransition(int layerIndex, string destStateName, float destStateLength, ref float fixedOffsetTime)
        {

        }
    }
}