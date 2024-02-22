using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("向关卡发送自定义信号\nSendCustomLevelSignal")]
    public class FASendCustomLevelSignal : FlowAction
    {
        private ValueInput<string> _viSignalKey;
        private ValueInput<string> _viSignalValue;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSignalKey = AddValueInput<string>("SignalKey");
            _viSignalValue = AddValueInput<string>("SignalValue");
        }

        protected override void _Invoke()
        {
            var signalKey = _viSignalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                _LogError("请联系策划【五当】,【FC】【向关卡发送自定义信号 SendCustomLevelSignal】节点 【SignalKey】参数配置不合法, 不能为空.");
                return;
            }

            _battle.actorMgr.stage.signalOwner.Write(signalKey, _viSignalValue.GetValue(), _actor);
        }
    }
}
