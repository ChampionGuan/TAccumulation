using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Old")]
    [Description("判断信号存在 HasSignal")]
    public class HasSignal : BattleCondition
    {
        public BBParameter<string> signalKey = new BBParameter<string>();

        protected override bool OnCheck()
        {
            if (_actor == null || _actor.signalOwner == null)
                return false;
            string key  = signalKey.GetValue();
            if (string.IsNullOrWhiteSpace(key) || string.IsNullOrEmpty(key))
            {
                PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝】, 【判断信号存在 HasSignal】NC节点 【SignalKey】参数配置不合法");
                return false;
            }
            
            return _actor.signalOwner.HasSignal(key);
        }
    }
}
