using FlowCanvas;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("运算函数ABS\nMathABS")]
    public class FAMathABS: FlowAction
    {
        private ValueInput<float> _value;
        protected override void _OnRegisterPorts()
        {
            _value = AddValueInput<float>("value");
            AddValueOutput<float>("Result", () => Mathf.Abs(_value.GetValue()));
        }
    }
}