using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("概率节点\nProbability")]
    public class FAProbability : FlowAction
    {
        [SliderField(0f, 1f)]
        public BBParameter<float> trueProbability = new BBParameter<float>(1f);
        protected override void _OnRegisterPorts()
        {
            var trueOutput = AddFlowOutput("True");
            var falseOutput = AddFlowOutput("False");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                var randomValue =  UnityEngine.Random.Range(0f, 1f);
                if (randomValue <= trueProbability.GetValue())
                {
                    trueOutput.Call(f);
                }
                else
                {
                    falseOutput.Call(f);
                }
            });
        }
    }
}