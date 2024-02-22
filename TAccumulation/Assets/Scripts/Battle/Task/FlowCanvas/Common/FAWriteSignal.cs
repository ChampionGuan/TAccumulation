using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("发送信号\nWriteSignal")]
    public class FAWriteSignal : FlowAction
    {
        private ValueInput<Actor> _viReceiver;
        private ValueInput<string> _viSignalKey;
        private ValueInput<string> _viSignalValue;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            this._viReceiver = AddValueInput<Actor>("Receiver");
            this._viSignalKey = AddValueInput<string>("SignalKey");
            this._viSignalValue = AddValueInput<string>("SignalValue");
        }

        protected override void _Invoke()
        {
            var receiver = _viReceiver.GetValue();
            if (receiver == null || receiver.signalOwner == null)
                return;
            string signalKey = _viSignalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                _LogError("请联系策划【卡宝】, 【发送信号 WriteSignal】节点 【SignalKey】参数配置不合法");
                return;
            }

            receiver.signalOwner.Write(signalKey, _viSignalValue.GetValue(), this._actor);
        }
    }
}
