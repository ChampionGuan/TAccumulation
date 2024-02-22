using System;
using System.ComponentModel;
using UnityEngine;

namespace X3.PlayableAnimator
{
    //[Serializable, DisplayName("内置条件/控制器参数")]
    //public class CtrlParameterComparision : Condition
    //{
    //    [SerializeField] private ComparisonType m_Type;
    //    [SerializeField] private string m_ParameterName;
    //    [SerializeField] private float m_Threshold;

    //    [NonSerialized] private AnimatorControllerParameter m_CacheParameter;

    //    public override bool IsMeet(StateMotion fromState)
    //    {
    //        if (string.IsNullOrEmpty(m_ParameterName))
    //        {
    //            return false;
    //        }

    //        if (null == m_CacheParameter || m_CacheParameter.name != m_ParameterName || m_CacheParameter.animCtrl != fromState.animCtrl)
    //        {
    //            m_CacheParameter = fromState.animCtrl.GetParameter(m_ParameterName);
    //        }

    //        if (null == m_CacheParameter)
    //        {
    //            // Debug.Log($"[playable animator][frameCount:{Time.frameCount}][parameter not found, please check!!][parameterName:{parameterName}]");
    //            return false;
    //        }

    //        if (m_CacheParameter.type == AnimatorControllerParameterType.Trigger)
    //        {
    //            return m_CacheParameter.defaultBool;
    //        }

    //        switch (m_Type)
    //        {
    //            case ComparisonType.If:
    //                return m_CacheParameter.type == AnimatorControllerParameterType.Bool && m_CacheParameter.defaultBool;
    //            case ComparisonType.IfNot:
    //                return m_CacheParameter.type == AnimatorControllerParameterType.Bool && !m_CacheParameter.defaultBool;
    //            case ComparisonType.Equals:
    //                return m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt == m_Threshold;
    //            case ComparisonType.NotEqual:
    //                return m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt != m_Threshold;
    //            case ComparisonType.Greater:
    //                return (m_CacheParameter.type == AnimatorControllerParameterType.Float && m_CacheParameter.defaultFloat > m_Threshold) || (m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt > m_Threshold);
    //            case ComparisonType.Less:
    //                return (m_CacheParameter.type == AnimatorControllerParameterType.Float && m_CacheParameter.defaultFloat < m_Threshold) || (m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt < m_Threshold);
    //        }

    //        return false;
    //    }

    //    public override void OnMeet()
    //    {
    //        if (null != m_CacheParameter && m_CacheParameter.type == AnimatorControllerParameterType.Trigger)
    //        {
    //            m_CacheParameter.defaultBool = false;
    //        }
    //    }

    //    public override Condition DeepCopy()
    //    {
    //        var condition = CreateInstance<CtrlParameterComparision>();
    //        condition.m_Type = m_Type;
    //        condition.m_ParameterName = m_ParameterName;
    //        condition.m_Threshold = m_Threshold;
    //        return condition;
    //    }

    //    public override NewCondition Convert()
    //    {
    //        return new NewCtrlParameterComparision((int)m_Type, m_ParameterName, m_Threshold);
    //    }

    //    public enum ComparisonType
    //    {
    //        If = 1,
    //        IfNot = 2,
    //        Greater = 3,
    //        Less = 4,
    //        Equals = 6,
    //        NotEqual = 7
    //    }
    //}

    [Serializable, DisplayName("内置条件/控制器参数")]
    public class NewCtrlParameterComparision : Condition
    {
        [SerializeField] private ComparisonType m_Type;
        [SerializeField] private string m_ParameterName;
        [SerializeField] private float m_Threshold;

        [NonSerialized] private AnimatorControllerParameter m_CacheParameter;

        public NewCtrlParameterComparision()
        {

        }

        public NewCtrlParameterComparision(int type, string parameterName, float threshold)
        {
            m_Type = (ComparisonType)type;
            m_ParameterName = parameterName;
            m_Threshold = threshold;
        }

        public override bool IsMeet(StateMotion fromState)
        {
            if (string.IsNullOrEmpty(m_ParameterName))
            {
                return false;
            }

            if (null == m_CacheParameter || m_CacheParameter.name != m_ParameterName || m_CacheParameter.animCtrl != fromState.animCtrl)
            {
                m_CacheParameter = fromState.animCtrl.GetParameter(m_ParameterName);
            }

            if (null == m_CacheParameter)
            {
                // Debug.Log($"[playable animator][frameCount:{Time.frameCount}][parameter not found, please check!!][parameterName:{parameterName}]");
                return false;
            }

            if (m_CacheParameter.type == AnimatorControllerParameterType.Trigger)
            {
                return m_CacheParameter.defaultBool;
            }

            switch (m_Type)
            {
                case ComparisonType.If:
                    return m_CacheParameter.type == AnimatorControllerParameterType.Bool && m_CacheParameter.defaultBool;
                case ComparisonType.IfNot:
                    return m_CacheParameter.type == AnimatorControllerParameterType.Bool && !m_CacheParameter.defaultBool;
                case ComparisonType.Equals:
                    return m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt == m_Threshold;
                case ComparisonType.NotEqual:
                    return m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt != m_Threshold;
                case ComparisonType.Greater:
                    return (m_CacheParameter.type == AnimatorControllerParameterType.Float && m_CacheParameter.defaultFloat > m_Threshold) || (m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt > m_Threshold);
                case ComparisonType.Less:
                    return (m_CacheParameter.type == AnimatorControllerParameterType.Float && m_CacheParameter.defaultFloat < m_Threshold) || (m_CacheParameter.type == AnimatorControllerParameterType.Int && m_CacheParameter.defaultInt < m_Threshold);
            }

            return false;
        }

        public override void OnMeet()
        {
            if (null != m_CacheParameter && m_CacheParameter.type == AnimatorControllerParameterType.Trigger)
            {
                m_CacheParameter.defaultBool = false;
            }
        }

        public override Condition DeepCopy()
        {
            var condition = new NewCtrlParameterComparision();
            condition.m_Type = m_Type;
            condition.m_ParameterName = m_ParameterName;
            condition.m_Threshold = m_Threshold;
            return condition;
        }

        public enum ComparisonType
        {
            If = 1,
            IfNot = 2,
            Greater = 3,
            Less = 4,
            Equals = 6,
            NotEqual = 7
        }
    }
}