using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("移除全部Actor指定信号\nRemoveSignalForAllActor")]
    public class FARemoveSignalForAllActor : FlowAction
    {
        private ValueInput<string> _viSignalKey;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSignalKey = AddValueInput<string>("SignalKey");
        }

        protected override void _Invoke()
        {
            string signalKey = _viSignalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                _LogError("请联系策划【路浩】, 【移除全部Actor指定信号 FARemoveSignalForAllActor】节点 【SignalKey】参数配置不合法");
                return;
            }

            var allActors = _battle.actorMgr.actors;
            for (int i = 0; i < allActors.Count; i++)
            {
                var actor = allActors[i];
                if (actor.signalOwner == null)
                {
                    continue;
                }
                actor.signalOwner.Remove(signalKey);
            }
        }
    }
}
