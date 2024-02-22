using System;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3.PlayableAnimator
{
    [Serializable]
    public class ClipMotion : Motion
    {
        [SerializeField] public AnimationClip m_Clip;

        [NonSerialized] protected AnimatorController m_AnimCtrl;
        [NonSerialized] protected float m_CacheLength = -1;
        [NonSerialized] protected bool m_IsValid;

        public AnimatorController animCtrl => m_AnimCtrl;
        public Playable playable { get; protected set; }
        public bool isValid => m_IsValid;
        public bool legacy => null != m_Clip && m_Clip.legacy;
        public override bool isLooping => null != m_Clip && m_Clip.isLooping;
        public override float length => m_CacheLength > 0 ? m_CacheLength : m_CacheLength = null == m_Clip ? 1 : m_Clip.length;
        public override bool hasEmptyClip => m_Clip == null;
        public float averageSpeed => clip.averageSpeed.magnitude;

        public AnimationClip clip
        {
            get => m_Clip;
            set
            {
                if (m_Clip == value)
                {
                    return;
                }

                m_IsValid = false;
                m_CacheLength = -1;
                m_Clip = value;
            }
        }

        public override double normalizedTime
        {
            get
            {
                var time = playable.GetTime();
                if (!isLooping) return time / length;
                return time % length / length;
            }
        }

        public ClipMotion(AnimationClip clip)
        {
            m_Clip = clip;
        }

        public override void SetTime(double time)
        {
            playable.SetTime(time);
            base.SetTime(time);
        }

        public override void Reset()
        {
            m_IsValid = false;
            m_AnimCtrl = null;
        }

        public override Motion DeepCopy()
        {
            var motion = new ClipMotion(m_Clip);
            motion.SetConcurrent(concurrent?.DeepCopy());
            return motion;
        }

        public override void RebuildPlayable(AnimatorController ctrl, BonePrevMixer.BonePrevMixerPlayable parent, int inputIndex, float weight)
        {
            m_IsValid = true;
            m_AnimCtrl = ctrl;
            playable = ctrl.context.CreateClipPlayable(clip);

            parent.DisconnectInput(inputIndex);
            parent.ConnectInput(inputIndex, playable, 0, weight);
        }
    }
}
