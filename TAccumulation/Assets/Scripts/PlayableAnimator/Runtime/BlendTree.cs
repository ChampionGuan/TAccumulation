using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Animations;

namespace X3.PlayableAnimator
{
    public enum BlendTreeType
    {
        Simple1D,
        SimpleDirectional2D,
        FreeformDirectional2D,
        FreeformCartesian2D,
        Direct,
    }

    public enum ComputeThresholdsType
    {
        Speed,
        VelocityX,
        VelocityY,
        VelocityZ,
        AngularSpeed,
    }

    public struct BlendTreeInfo
    {
        public float minThreshold;
        public float maxThreshold;
        public float outSpeed;
        public float outSpeedNormalize;

        public BlendTreeInfo(float minThreshold, float maxThreshold, float outSpeed, float outSpeedNormalize)
        {
            this.minThreshold = minThreshold;
            this.maxThreshold = maxThreshold;
            this.outSpeed = outSpeed;
            this.outSpeedNormalize = outSpeedNormalize;
        }
    }

    [Serializable]
    public class BlendTree : Motion
    {
        [SerializeField] private float m_MinThreshold;
        [SerializeField] private float m_MaxThreshold;
        [SerializeField] private string m_BlendParameterName;
        [SerializeField] private BlendTreeType m_BlendType;
        [SerializeField] private bool m_UseAutomaticThresholds;
        [SerializeField] private List<BlendTreeChild> m_ChildMotions = new List<BlendTreeChild>();

        [NonSerialized] private bool m_IsValid;
        [NonSerialized] private float m_Length;
        [NonSerialized] private int m_InputIndex;
        [NonSerialized] private BonePrevMixer.BonePrevMixerPlayable m_PlayableParent;
        [NonSerialized] private AnimatorController m_AnimCtrl;

        public AnimatorController animCtrl => m_AnimCtrl;
        public BonePrevMixer.BonePrevMixerPlayable playable { get; private set; }
        public override float length => m_Length;
        public override bool isLooping => false;
        public override double normalizedTime => playable.GetTime() / length;
        public override bool hasEmptyClip => false;
        public float minThreshold => m_MinThreshold;
        public float maxThreshold => m_MaxThreshold;
        public string blendParameterName => m_BlendParameterName;
        public BlendTreeType blendType => m_BlendType;
        public bool useAutomaticThresholds => m_UseAutomaticThresholds;
        public int childrenCount => m_ChildMotions.Count;
        public float outSpeed { get; private set; }
        public float outSpeedNorm { get; private set; }
        public List<BlendTreeChild> childMotions => m_ChildMotions;

        public List<AnimationClip> animationClips
        {
            get
            {
                var clips = new List<AnimationClip>();
                for (var index = 0; index < m_ChildMotions.Count; index++)
                {
                    var motion = m_ChildMotions[index];
                    if (null != motion.clip && !clips.Contains(motion.clip))
                    {
                        clips.Add(motion.clip);
                    }
                }

                return clips;
            }
        }

        public BlendTree()
        {
        }

        public BlendTree(float minThreshold, float maxThreshold, string blendParameterName, BlendTreeType blendType, bool useAutomaticThresholds, List<BlendTreeChild> childMotions)
        {
            m_MinThreshold = minThreshold;
            m_MaxThreshold = maxThreshold;
            m_BlendParameterName = blendParameterName;
            m_BlendType = blendType;
            m_UseAutomaticThresholds = useAutomaticThresholds;
            m_ChildMotions = childMotions;
        }

        public void AddChild(BlendTreeChild[] motions)
        {
            if (null == motions)
            {
                return;
            }

            for (var index = 0; index < motions.Length; index++)
            {
                AddChild(motions[index]);
            }
        }

        public void AddChild(BlendTreeChild motion)
        {
            if (null == motion)
            {
                return;
            }

            motion.Reset();
            m_IsValid = false;
            m_ChildMotions.Add(motion);
        }

        public void RemoveChild(BlendTreeChild motion)
        {
            if (null == motion)
            {
                return;
            }

            m_IsValid = false;
            m_ChildMotions.Remove(motion);
        }

        public BlendTreeChild GetChild(int index)
        {
            if (index < 0 || index >= childrenCount)
            {
                return null;
            }

            return m_ChildMotions[index];
        }

        public override void SetTime(double time)
        {
            playable.SetTime(time);
            for (var i = 0; i < childrenCount; i++)
            {
                m_ChildMotions[i].SetTime(normalizedTime * m_ChildMotions[i].length);
            }

            base.SetTime(time);
        }

        public override void Reset()
        {
            m_IsValid = false;
            m_AnimCtrl = null;
            for (var index = 0; index < m_ChildMotions.Count; index++)
            {
                m_ChildMotions[index].Reset();
            }
        }

        public override Motion DeepCopy()
        {
            var blendTree = new BlendTree
            {
                m_MinThreshold = m_MinThreshold,
                m_MaxThreshold = m_MaxThreshold,
                m_BlendParameterName = m_BlendParameterName,
                m_BlendType = m_BlendType,
                m_UseAutomaticThresholds = m_UseAutomaticThresholds,
                m_ChildMotions = new List<BlendTreeChild>()
            };
            for (var i = 0; i < childrenCount; i++)
            {
                blendTree.m_ChildMotions.Add(m_ChildMotions[i].DeepCopy() as BlendTreeChild);
            }

            return blendTree;
        }

        public void GetAnimationClips(List<AnimationClip> clips)
        {
            if (null == clips)
            {
                return;
            }

            for (var index = 0; index < m_ChildMotions.Count; index++)
            {
                var clip = m_ChildMotions[index]?.clip;
                if (null != clip && !clips.Contains(clip))
                {
                    clips.Add(clip);
                }
            }
        }

        public virtual bool IsValidPlayable(AnimatorController ctrl)
        {
            if (animCtrl != ctrl || !m_IsValid)
            {
                return false;
            }

            for (var index = 0; index < m_ChildMotions.Count; index++)
            {
                if (!m_ChildMotions[index].isValid)
                {
                    return false;
                }
            }

            return true;
        }

        public override void RebuildPlayable(AnimatorController ctrl, BonePrevMixer.BonePrevMixerPlayable parent, int inputIndex, float weight)
        {
            m_IsValid = true;
            m_PlayableParent = parent;
            m_InputIndex = inputIndex;
            m_AnimCtrl = ctrl;
            playable = BonePrevMixer.BonePrevMixerPlayable.Create(ctrl.playableGraph, null, childrenCount);

            for (var i = 0; i < childrenCount; i++)
            {
                m_ChildMotions[i].RebuildPlayable(ctrl, playable, i, 0);
            }

            var parameter = ctrl.GetParameter(m_BlendParameterName);
            if (null != parameter)
            {
                parameter.m_OnValueChanged -= OnParameterValueChanged;
                parameter.m_OnValueChanged += OnParameterValueChanged;
                SetChildWeight(parameter.defaultFloat);
            }
            else
            {
                SetChildWeight(0);
                // Debug.LogError($"[playable animator][frameCount:{Time.frameCount}][parameter not found, please check!!][parameterName:{m_BlendParameterName}]");
            }

            parent.DisconnectInput(inputIndex);
            parent.ConnectInput(inputIndex, playable, 0, weight);
        }

        /// <summary>
        /// 获取parameter的值，使blendTree输出的RootMotion变量设为期望值
        /// 目前只支持在blendTree中配置的clip的速度是从小到大排列的情况下计算，后续如有需要会完全支持
        /// </summary>
        /// <param name="expectedValue"></param> 期望值
        /// <param name="type"></param> 类型
        /// <returns></returns>要获得期望的parameter的值
        public float CalParameterValue(float expectedValue, ComputeThresholdsType type = ComputeThresholdsType.Speed)
        {
            if (childrenCount <= 1) return 0;
            if (expectedValue < GetChildValue(type, m_ChildMotions[0]))
                return m_ChildMotions[0].threshold;
            if (expectedValue > GetChildValue(type, m_ChildMotions[childrenCount - 1]))
                return m_ChildMotions[childrenCount - 1].threshold;

            for (var i = 0; i < childrenCount; i++)
            {
                if (i < childrenCount - 1 && expectedValue >= m_ChildMotions[i].averageSpeed && expectedValue <= m_ChildMotions[i + 1].averageSpeed)
                {
                    var lengthA = m_ChildMotions[i].length;
                    var lengthB = m_ChildMotions[i + 1].length;
                    var speedA = GetChildValue(type, m_ChildMotions[i]);
                    var speedB = GetChildValue(type, m_ChildMotions[i + 1]);
                    var thresholdA = m_ChildMotions[i].threshold;
                    var thresholdB = m_ChildMotions[i + 1].threshold;

                    var weight = (lengthB * expectedValue - lengthB * speedB) /
                                 (lengthA * speedA - lengthB * speedB - lengthA * expectedValue + lengthB * expectedValue);
                    return (thresholdB - thresholdA) * (1 - weight) + thresholdA;
                }
            }

            return 0;
        }

        public float GetChildWeight(int i)
        {
            if(i < childrenCount && i >= 0)
            {
                return playable.GetInputWeight(i);
            }
            return 0;
        }

        private void CalOutValue(BlendTreeChild childA, BlendTreeChild childB, float weightB, ref float stateLength)
        {
            stateLength = childA.length * (1 - weightB) + childB.length * weightB;
            outSpeed = childB.averageSpeed * childB.length / stateLength * weightB + childA.averageSpeed * childA.length / stateLength * (1 - weightB);
            outSpeedNorm = (outSpeed - childA.averageSpeed) / (childB.averageSpeed - childA.averageSpeed);
        }

        private float GetChildValue(ComputeThresholdsType type, BlendTreeChild motion)
        {
            switch (type)
            {
                case ComputeThresholdsType.Speed:
                    return motion.averageSpeed;
                default:
                    return 0;
            }
        }

        private void OnParameterValueChanged(AnimatorControllerParameter parameter)
        {
            if (null == parameter || null == animCtrl || parameter.animCtrl != animCtrl || m_BlendParameterName != parameter.name)
            {
                return;
            }

            if (!IsValidPlayable(animCtrl))
            {
                RebuildPlayable(animCtrl, m_PlayableParent, m_InputIndex, m_PlayableParent.GetInputWeight(m_InputIndex));
            }

            SetChildWeight(parameter.defaultFloat);
        }

        private void SetChildWeight(float threshold)
        {
            var value = Mathf.Clamp(threshold, m_MinThreshold, m_MaxThreshold);
            m_Length = 0;
            if (childrenCount == 1)
            {
                playable.SetInputWeight(0, 1);
            }
            else if (childrenCount > 1)
            {
                for (var i = 0; i < childrenCount;)
                {
                    if (i < childrenCount - 1 && value >= m_ChildMotions[i].threshold && value <= m_ChildMotions[i + 1].threshold)
                    {
                        var weight = (value - m_ChildMotions[i].threshold) / (m_ChildMotions[i + 1].threshold - m_ChildMotions[i].threshold);
                        playable.SetInputWeight(i, 1 - weight);
                        playable.SetInputWeight(i + 1, weight);
                        CalOutValue(m_ChildMotions[i], m_ChildMotions[i + 1], weight, ref m_Length);
                        i += 2;
                    }
                    else
                    {
                        playable.SetInputWeight(i, 0);
                        i += 1;
                    }
                }
            }
        }
    }
}