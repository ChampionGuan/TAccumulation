using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("打印Log\nPrintLog")]
    public class FALogText : FlowNode
    {
        private ValueInput<string> _viLogText;

        protected override void RegisterPorts()
        {
            var o = AddFlowOutput("Out");
            _viLogText = AddValueInput<string>("Text");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                string content = _viLogText.GetValue();
                if (!string.IsNullOrEmpty(content) && !string.IsNullOrWhiteSpace(content))
                {
                    PapeGames.X3.LogProxy.Log(content);
                }
                o.Call(f);
            });
        }
    }
}
