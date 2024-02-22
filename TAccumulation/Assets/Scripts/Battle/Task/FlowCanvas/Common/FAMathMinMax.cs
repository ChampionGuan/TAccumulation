using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("运算函数MaxMin\nMathMinMax")]
    public class FAMathMinMax: FlowAction
    {
        public enum MinOrMax
        {
            Min =1,
            Max
        }
        public MinOrMax minOrMax = MinOrMax.Min;
        
        [SerializeField, ExposeField]
        [GatherPortsCallback]
        [MinValue(2), DelayedField]
        private int _portCount = 2;

        private List<ValueInput<float>> _inputValues = new List<ValueInput<float>>(3);

        protected override void _OnRegisterPorts() {
            _inputValues.Clear();
            for ( var i = 0; i < _portCount; i++ ) {
                _inputValues.Add(AddValueInput<float>(i.ToString()));
            }

            AddValueOutput<float>("Result", () =>
            {
                if (minOrMax == MinOrMax.Min)
                {
                    float min = float.MaxValue;
                    foreach (var input in _inputValues)
                    {
                        if (input.value < min)
                        {
                            min = input.value;
                        }
                    }

                    return min;
                }
                else
                {
                    float max = float.MinValue;
                    foreach (var input in _inputValues)
                    {
                        if (input.value > max)
                        {
                            max = input.value;
                        }
                    }

                    return max;
                }
            });
        }

    }
}

