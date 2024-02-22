using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("读取信号 ReadSignal")]
    public class ReadSignal : BattleAction
    {
        public BBParameter<string> signalKey = new BBParameter<string>();
        public BBParameter<string> saveAs = new BBParameter<string>();

        protected override void OnExecute()
        {
            saveAs.value = null;
            if (_actor == null || _actor.signalOwner == null)
            {
                EndAction(false);
                return;
            }
            string key = signalKey.GetValue();
            if (string.IsNullOrWhiteSpace(key) || string.IsNullOrEmpty(key))
            {
                PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝】, 【读取信号 ReadSignal】NC节点 【SignalKey】参数配置不合法");
                EndAction(false);
                return;
            }

            saveAs.value = _actor.signalOwner.Read(key);
            EndAction(true);
        }
    }
}
