using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("广播信号\nBroadcastSignal")]
    [Description("广播目标：所有怪物, Boy, Girl, (对顺序无要求, 默认按添加顺序广播.).")]
    public class FABroadcastSignal : FlowAction
    {
        private ValueInput<string> _viSignalKey;
        private ValueInput<string> _viSignalValue;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            this._viSignalKey = AddValueInput<string>("SignalKey");
            this._viSignalValue = AddValueInput<string>("SignalValue");
        }
        
        protected override void _Invoke()
        {
            string signalKey = _viSignalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                _LogError("请联系策划【五当】, 【广播信号 BroadcastSignal】节点 【SignalKey】参数配置不合法");
                return;
            }

            // DONE: 遍历查找指定目标.
            var allActors = Battle.Instance.actorMgr.actors;
            for (int i = 0; i < allActors.Count; i++)
            {
                var targetActor = allActors[i];
                if (targetActor == null)
                    continue;
                if (!(targetActor.IsGirl() || targetActor.IsBoy() || targetActor.type == ActorType.Monster))
                    continue;
                targetActor.signalOwner.Write(signalKey, _viSignalValue.GetValue(), this._actor);
            }
        }
    }
}
