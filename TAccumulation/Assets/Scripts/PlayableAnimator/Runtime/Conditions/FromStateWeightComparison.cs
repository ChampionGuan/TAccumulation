using System;
using System.ComponentModel;
using UnityEngine;

namespace X3.PlayableAnimator
{
    //[Serializable, DisplayName("内置条件/权重比较")]
    //public class FromStateWeightComparison : Condition
    //{
    //    [SerializeField] private ComparisonType m_Type;
    //    [SerializeField] private float m_Weight;

    //    public override bool IsMeet(StateMotion fromState)
    //    {
    //        switch (m_Type)
    //        {
    //            case ComparisonType.Equals: return fromState.weight == m_Weight;
    //            case ComparisonType.NotEqual: return fromState.weight != m_Weight;
    //            case ComparisonType.Greater: return fromState.weight > m_Weight;
    //            case ComparisonType.GreaterOrEqual: return fromState.weight >= m_Weight;
    //            case ComparisonType.Less: return fromState.weight < m_Weight;
    //            case ComparisonType.LessOrEqual: return fromState.weight <= m_Weight;
    //            default: return false;
    //        }
    //    }

    //    public override Condition DeepCopy()
    //    {
    //        var condition = CreateInstance<FromStateWeightComparison>();
    //        condition.m_Type = m_Type;
    //        condition.m_Weight = m_Weight;
    //        return condition;
    //    }

    //    public override NewCondition Convert()
    //    {
    //        return new NewFromStateWeightComparison((int)m_Type, m_Weight);
    //    }

    //    public enum ComparisonType
    //    {
    //        Equals = 0,
    //        NotEqual,
    //        Less,
    //        LessOrEqual,
    //        Greater,
    //        GreaterOrEqual
    //    }
    //}

    [Serializable, DisplayName("内置条件/权重比较")]
    public class NewFromStateWeightComparison : Condition
    {
        [SerializeField] private ComparisonType m_Type;
        [SerializeField] private float m_Weight;

        public NewFromStateWeightComparison()
        {

        }

        public NewFromStateWeightComparison(int type, float weight)
        {
            m_Type = (ComparisonType)type;
            m_Weight = weight;
        }

        public override bool IsMeet(StateMotion fromState)
        {
            switch (m_Type)
            {
                case ComparisonType.Equals: return fromState.weight == m_Weight;
                case ComparisonType.NotEqual: return fromState.weight != m_Weight;
                case ComparisonType.Greater: return fromState.weight > m_Weight;
                case ComparisonType.GreaterOrEqual: return fromState.weight >= m_Weight;
                case ComparisonType.Less: return fromState.weight < m_Weight;
                case ComparisonType.LessOrEqual: return fromState.weight <= m_Weight;
                default: return false;
            }
        }

        public override Condition DeepCopy()
        {
            var condition = new NewFromStateWeightComparison();
            condition.m_Type = m_Type;
            condition.m_Weight = m_Weight;
            return condition;
        }

        public enum ComparisonType
        {
            Equals = 0,
            NotEqual,
            Less,
            LessOrEqual,
            Greater,
            GreaterOrEqual
        }
    }
}