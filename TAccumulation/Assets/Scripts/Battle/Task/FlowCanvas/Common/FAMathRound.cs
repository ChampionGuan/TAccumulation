using System;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("运算函数Round\nMathRound")]
    public class FAMathRound: FlowAction
    {
        public enum RoundType
        {
            Round = 1,
            RoundUp,
            RoundDown,
            
        }
        private ValueInput<double> _value;
        public int digits;
        public RoundType roundType = RoundType.Round;
        protected override void _OnRegisterPorts()
        {
            _value = AddValueInput<double>("value");
            AddValueOutput<double>("Result", _RoundResult);

        }
        protected double _RoundResult()
        {
            switch (roundType)
            {
                case RoundType.Round:
                {
                    return Math.Round(_value.GetValue(), digits);
                }
                    break;
                case RoundType.RoundUp:
                {
                    double multiplier = Math.Pow(10, digits);
                    return Math.Ceiling(_value.GetValue() * multiplier) / multiplier;
                }
                    break;
                case RoundType.RoundDown:
                {
                    double multiplier = Math.Pow(10, digits);
                    return Math.Floor(_value.GetValue() * multiplier) / multiplier;
                }
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }
}