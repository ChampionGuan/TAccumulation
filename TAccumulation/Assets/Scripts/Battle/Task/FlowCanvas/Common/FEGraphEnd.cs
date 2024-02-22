using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("图禁用时\nGraphDisable")]
    public class FEGraphEnd : FlowNode
    {
        private FlowOutput end;
        
        protected override void RegisterPorts()
        {
            end = AddFlowOutput("Received");
        }
        
        public override void OnPostGraphStoped()
        {
            end.Call(new Flow());
        }
    }
}
