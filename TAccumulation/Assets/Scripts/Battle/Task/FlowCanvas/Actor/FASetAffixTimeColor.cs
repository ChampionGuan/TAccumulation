using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("设置词缀提示颜色\nSetAffixTipColor")]
    public class FASetAffixTimeColor : FlowAction
    {
        public BBParameter<int> type = new BBParameter<int>();

        protected override void _Invoke()
        {
            BattleEnv.LuaBridge.SetAffixTimeColor(type.value);
        }
    }
}
