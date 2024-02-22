using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("移除信号 RemoveSignal")]
    public class RemoveSignal : BattleAction
    {
        public BBParameter<string> signalKey = new BBParameter<string>();

        protected override void OnExecute()
        {
            if (_actor == null || _actor.signalOwner == null)
            {
                EndAction(false);
                return;
            }

            string key = signalKey.GetValue();
            if (string.IsNullOrWhiteSpace(key) || string.IsNullOrEmpty(key))
            {
                PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝】, 【移除信号 RemoveSignal】NC节点 【SignalKey】参数配置不合法");
                EndAction(false);
                return;
            }

            _actor.signalOwner.Remove(key);
            EndAction(true);
        }
    }
}
