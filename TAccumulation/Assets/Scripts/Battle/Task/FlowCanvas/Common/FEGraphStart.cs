using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("图启用时\nGraphEnable")]
    public class FEGraphStart : FlowNode
    {
        private FlowOutput start;
        
        protected override void RegisterPorts()
        {
            start = AddFlowOutput("Received");
        }
        
        public override void OnPostGraphStarted()
        {
            start.Call(new Flow());
        }
    }
}
