using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Action/Actor")]
    [Name(("SendCustomLevelSignal"))]
    [Description("向关卡发送自定义信号")]
    public class NASendCustomLevelSignal : BattleAction
    {
        public BBParameter<string> signalKey = new BBParameter<string>();
        public BBParameter<string> signalValue = new BBParameter<string>();
        
        protected override void OnExecute()
        {
            var signalKey = this.signalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                PapeGames.X3.LogProxy.LogError("请联系策划【五当】,【NC】【向关卡发送自定义信号 SendCustomLevelSignal】节点 【SignalKey】参数配置不合法, 不能为空.");
                EndAction(false);
                return;
            }

            _battle.actorMgr.stage.signalOwner.Write(signalKey, signalValue.GetValue(), _actor);
            EndAction(true);
        }
    }
}
