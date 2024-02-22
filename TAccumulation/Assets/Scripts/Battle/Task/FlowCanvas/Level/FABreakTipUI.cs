using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("显示击破UI\nShowJipoUI")]
    public class FABreakTipUI : FlowAction
    {
        public float remainTime;
        protected override void _Invoke()
        {
            BattleEnv.LuaBridge.ShowBreakTipUI(remainTime);
            _battle.ppvMgr.Play(TbUtil.battleConsts.WinBreakPPV);
        }
    }
}
