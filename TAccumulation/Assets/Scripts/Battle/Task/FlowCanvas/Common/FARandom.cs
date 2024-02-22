using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("随机\nRandom")]
    [Description("Out1的权重，0~1000 (Out2 Weight=1000 - Out1 Wiehgt)")]
    public class FARandom : FlowAction
    {
        public BBParameter<int> out1Weight = new BBParameter<int>();

        private Random _random = new Random();

        protected override void _OnRegisterPorts()
        {
            var ouput1 = AddFlowOutput("Out1");
            var ouput2 = AddFlowOutput("Out2");
            AddFlowInput("In", flow =>
            {
                int num = _random.Next(0, 1000);

                if (num < out1Weight.GetValue())
                {
                    ouput1.Call(flow);
                }
                else
                {
                    ouput2.Call(flow);
                }
            });
        }
    }
}
