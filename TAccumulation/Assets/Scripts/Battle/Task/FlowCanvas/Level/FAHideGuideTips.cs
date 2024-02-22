using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("关闭引导提示\nCloseGuideTips")]
    public class FAHideGuideTips : FlowAction
    {
        public BBParameter<int> id = new BBParameter<int>();
        protected override void _Invoke()
        {
            var guideConfig = TbUtil.GetCfg<BattleGuide>(id.value);
            if (guideConfig == null)
            {
                return;
            }
            TipType tipType = (TipType)guideConfig.Type;
            switch (tipType)
            {
                case TipType.CenterTip:
                case TipType.LeftBoyDialog:
                    BattleEnv.LuaBridge.SetUiTipVisible(false, id.value);
                    break;
                case TipType.AffixTip:
                    BattleEnv.LuaBridge.SetAffixVisible(false, id.value);
                    break;
                case TipType.RightLevelTarget:
                case TipType.RightLevelTarget2:
                    BattleUtil.SetMissionTipsVisible(ShowMissionTipsType.Close, id.value);
                    break;
            }
        }
    }
}
