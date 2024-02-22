using FlowCanvas;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("运算函数Clamp\nMathClamp")]
    public class FAMathClamp: FlowAction
    {
        private ValueInput<float> _value;
        private ValueInput<float> _min;
        private ValueInput<float> _max;
        protected override void _OnRegisterPorts()
        {
            _value = AddValueInput<float>("value");
            _min = AddValueInput<float>("Min");
            _max = AddValueInput<float>("Max");
            AddValueOutput<float>("Result", () => Mathf.Clamp(_value.GetValue(), _min.GetValue(), _max.GetValue()));
        }
    
    }
}
