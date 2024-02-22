using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("【关卡】给对象移除信号\nRemoveSignalInLevel")]
    public class FALevelRemoveSignal : FlowAction
    {
        [Name("ActorId Girl=-1, Boy=-2")]
        public BBParameter<int> actorId = new BBParameter<int>();
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
                _LogError("请联系策划【楚门】, 节点【【关卡】给对象移除信号】配置错误, 【SignalKey】参数配置不合法");
                return;
            }
            
            int actorTypeId = actorId.GetValue();
            var target = BattleUtil.GetActorByIDType(actorTypeId);
            if (target == null)
            {
                _LogError($"请联系策划【楚门】, 节点【【关卡】给对象移除信号】配置错误, 找不到目标Actor, 参数为actorId={actorTypeId}");
                return;
            }
            
            if (target.signalOwner == null)
            {
                _LogError($"请联系策划【楚门】, 节点【【关卡】给对象移除信号】配置错误, 目标Actor.cfgID:{target.cfgID}, Actor.name:{target.name}没有SignalOwner组件. 参数为actorId={actorTypeId}");
                return;
            }

            target.signalOwner.Remove(signalKey);
        }
    }
}
