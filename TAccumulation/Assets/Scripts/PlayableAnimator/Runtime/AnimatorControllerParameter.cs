using System;
using UnityEngine;

namespace X3.PlayableAnimator
{
    public enum AnimatorControllerParameterType
    {
        Float = 1,
        Int = 3,
        Bool = 4,
        Trigger = 9
    }

    [Serializable]
    public class AnimatorControllerParameter
    {
        [SerializeField] private string m_Name;
        [SerializeField] private AnimatorControllerParameterType m_Type;
        [SerializeField] private int m_DefaultInt;
        [SerializeField] private float m_DefaultFloat;
        [SerializeField] private bool m_DefaultBool;

        [NonSerialized] public Action<AnimatorControllerParameter> m_OnValueChanged;
        [NonSerialized] private AnimatorController m_AnimCtrl;
        [NonSerialized] private float m_TargetFloat;
        [NonSerialized] private float? m_LerpTime;

        public AnimatorController animCtrl => m_AnimCtrl;
        public string name => m_Name;
        public AnimatorControllerParameterType type => m_Type;

        public float defaultFloat
        {
            get => m_DefaultFloat;
            private set
            {
                if (m_Type != AnimatorControllerParameterType.Float)
                {
                    return;
                }

                if (m_DefaultFloat != value)
                {
                    m_DefaultFloat = value;
                    m_OnValueChanged?.Invoke(this);
                }
            }
        }

        public int defaultInt
        {
            get => m_DefaultInt;
            set
            {
                if (m_Type != AnimatorControllerParameterType.Int)
                {
                    return;
                }

                if (m_DefaultInt != value)
                {
                    m_DefaultInt = value;
                    m_OnValueChanged?.Invoke(this);
                }
            }
        }

        public bool defaultBool
        {
            get => m_DefaultBool;
            set
            {
                if (m_Type != AnimatorControllerParameterType.Bool && m_Type != AnimatorControllerParameterType.Trigger)
                {
                    return;
                }

                if (m_DefaultBool != value)
                {
                    m_DefaultBool = value;
                    m_OnValueChanged?.Invoke(this);
                }
            }
        }

        public AnimatorControllerParameter(string name, AnimatorControllerParameterType type)
        {
            m_Name = name;
            m_Type = type;
        }

        public AnimatorControllerParameter(string name, AnimatorControllerParameterType type, object value)
        {
            m_Name = name;
            m_Type = type;
            switch (type)
            {
                case AnimatorControllerParameterType.Trigger:
                    m_DefaultBool = false;
                    break;
                case AnimatorControllerParameterType.Bool:
                    m_DefaultBool = value is bool ? (bool)value : false;
                    break;
                case AnimatorControllerParameterType.Float:
                    m_DefaultFloat = value is float ? (float)value : 0;
                    break;
                case AnimatorControllerParameterType.Int:
                    m_DefaultInt = value is int ? (int)value : 0;
                    break;
            }
        }

        public void OnStart()
        {
        }

        public void OnUpdate(AnimatorController ctrl, float deltaTime)
        {
            m_AnimCtrl = ctrl;
            if (type != AnimatorControllerParameterType.Float)
            {
                return;
            }

            if (null == m_LerpTime || defaultFloat == m_TargetFloat)
            {
                return;
            }

            if (m_LerpTime > 0)
            {
                defaultFloat -= (defaultFloat - m_TargetFloat) / m_LerpTime.Value * deltaTime;
                m_LerpTime -= deltaTime;
            }

            if (m_LerpTime <= 0)
            {
                defaultFloat = m_TargetFloat;
            }
        }

        public void OnDestroy()
        {
        }

        public AnimatorControllerParameter DeepCopy()
        {
            var parameter = new AnimatorControllerParameter(m_Name, m_Type)
            {
                m_DefaultInt = m_DefaultInt,
                m_DefaultFloat = m_DefaultFloat,
                m_DefaultBool = m_DefaultBool,
            };
            return parameter;
        }

        public void SetFloat(float targetValue, float time)
        {
            m_LerpTime = time;
            m_TargetFloat = time <= 0 ? defaultFloat = targetValue : targetValue;
        }
    }
}