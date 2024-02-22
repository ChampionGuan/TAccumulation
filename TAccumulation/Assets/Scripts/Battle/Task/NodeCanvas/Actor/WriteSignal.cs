using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("发送信号 WriteSignal")]
    public class WriteSignal : BattleAction
    {
        public BBParameter<Actor> reciver = new BBParameter<Actor>();
        public BBParameter<string> signalKey = new BBParameter<string>();
        public BBParameter<string> signalValue = new BBParameter<string>();

        protected override void OnExecute()
        {
            var actor = reciver.GetValue();
            if (actor == null || actor.signalOwner == null)
            {
                EndAction(false);
                return;
            }
            string key  = signalKey.GetValue();
            if (string.IsNullOrWhiteSpace(key) || string.IsNullOrEmpty(key))
            {
                PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝】, 【发送信号 WriteSignal】NC节点 【SignalKey】参数配置不合法");
                EndAction(false);
                return;
            }

            actor.signalOwner.Write(key, signalValue.GetValue(), _actor);
            EndAction(true);
        }
    }
}
