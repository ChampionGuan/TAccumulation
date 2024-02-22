using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("发起战斗结束\nBattleEnd")]
    public class FABattleEnd : FlowAction
    {
        public BBParameter<bool> isWin = new BBParameter<bool>();

        protected override void _Invoke()
        {
            Battle.Instance.End(isWin.GetValue(), endReason: BattleEndReason.Technic);
        }
    }
}
