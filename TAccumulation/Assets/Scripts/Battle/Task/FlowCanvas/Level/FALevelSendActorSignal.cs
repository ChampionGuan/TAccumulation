using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("关卡向单位发送信号\nLevelWriteSignal")]
    public class FALevelSendActorSignal : FlowAction
    {
        public enum ReciverType
        {
            All = 0, // 向所有Uid
            Uid,
        }
        
        public BBParameter<string> signalKey = new BBParameter<string>();
        public BBParameter<string> signalValue = new BBParameter<string>();
        public BBParameter<ReciverType> reciverType = new BBParameter<ReciverType>();
        [Name("SpawnID")]
        public BBParameter<int> uid = new BBParameter<int>();

        protected override void _Invoke()
        {
            var keyStr = signalKey.GetValue();
            if (string.IsNullOrWhiteSpace(keyStr) || string.IsNullOrEmpty(keyStr))
            {
                _LogError("请联系策划【五当】,【关卡向单位发送信号】节点 【SignalKey】参数配置不合法, 不能为空.");
                return;
            }
            
            var reciverEnum = reciverType.GetValue();
            if (reciverEnum == ReciverType.All)
            {
                var actors = Battle.Instance.actorMgr.actors;
                foreach (var actor in actors)
                {
                    if (actor.signalOwner == null)
                        continue;
                    actor.signalOwner.Write(keyStr, signalValue.GetValue(), null);
                }
            }
            else if (reciverEnum == ReciverType.Uid)
            {
                var actor = Battle.Instance.actorMgr.GetActor(uid.GetValue());
                if (actor == null)
                {
                    _LogError("请联系策划【五当】,【关卡向单位发送信号】节点 该【Uid】目标不在.");
                    return;
                }

                if (actor.signalOwner == null)
                {
                    _LogError("请联系策划【五当】,【关卡向单位发送信号】节点 该【Uid】目标存在, 但没有【SignalOwner】组件.");
                    return;
                }
                
                actor.signalOwner.Write(keyStr, signalValue.GetValue(), null);
            }
        }
    }
}
