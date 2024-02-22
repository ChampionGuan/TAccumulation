using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("移除信号\nRemoveSignal")]
    public class FARemoveSignal : FlowAction
    {
        private ValueInput<string> _viSignalKey;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            this._viSignalKey = AddValueInput<string>("SignalKey");
        }

        protected override void _Invoke()
        {
            string signalKey = _viSignalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                _LogError("请联系策划【卡宝】, 【发送信号 WriteSignal】节点 【SignalKey】参数配置不合法");
                return;
            }

            if (this._actor == null)
            {
                _LogError("请联系策划【卡宝】, 【发送信号 WriteSignal】节点使用参数, 该图没有绑定Actor对象.");
                return;
            }

            if (this._actor.signalOwner == null)
            {
                _LogError("请联系策划【卡宝】, 【发送信号 WriteSignal】节点使用参数, 该图拥有者没有SignalOwner组件.");
                return;
            }

            // DONE: 移除自身的信号槽.
            this._actor.signalOwner.Remove(signalKey);
        }
    }
}
