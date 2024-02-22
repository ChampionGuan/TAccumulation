using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("读取信号\nReadSignal")]
    public class FAReadSignal : FlowAction
    {
        private ValueInput<Actor> _viTarget;
        private ValueInput<string> _viSignalKey;
        private string _signalValue = null;

        protected override void _OnRegisterPorts()
        {
            var o = AddFlowOutput("Out");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                if (!TryReadSignal(out string signalValue))
                {
                    return;
                }
                
                _signalValue = signalValue;
                o.Call(f);
            });
            _viTarget = AddValueInput<Actor>("Target");
            _viSignalKey = AddValueInput<string>("SignalKey");
            AddValueOutput<string>("SignalValue", () => _signalValue);
        }

        private bool TryReadSignal(out string signalValue)
        {
            signalValue = null;
            var actor = _viTarget.GetValue();
            if (actor == null || actor.signalOwner == null)
                return false;
            string signalKey = _viSignalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                _LogError("请联系策划【卡宝】, 【读取信号 ReadSignal】节点 【SignalKey】参数配置不合法");
                return false;
            }

            signalValue = actor.signalOwner.Read(signalKey);
            return signalValue != null;
        }
    }
}
