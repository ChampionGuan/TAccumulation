using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("设置战斗主UI显示模式\nSetBattleWndMode")]
    public class FASetBattleWndMode : FlowAction
    {
        public BBParameter<BattleWndMode> wndMode = new BBParameter<BattleWndMode>();

        protected override void _Invoke()
        {
            BattleEnv.LuaBridge.SetBattleWndMode(wndMode.value);
        }
    }
}