using PapeGames.X3;

namespace X3Battle
{
    public class UIResAnalyzer : ResAnalyzer
    {
        private int _levelID;
        public override int ResID => _levelID;
        
        public UIResAnalyzer(ResModule parent, int levelID) : base(parent)
        {
            _levelID = levelID;
        }

        protected override void DirectAnalyze()
        {
            resModule.AddResultByPath(FloatWordDatas.DamagePL, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath(FloatWordDatas.DamageST, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath(FloatWordDatas.Hurt, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath(FloatWordDatas.CriticalDamagePL, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath(FloatWordDatas.Cure, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath(FloatWordDatas.Dot, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath(FloatWordDatas.Text, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath(FloatWordDatas.Weak, BattleResType.DynamicUI, 10);
            resModule.AddResultByPath("UIView_BattleWnd", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_BattleTipsWnd", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_BattleMainTips", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_TipsWnd", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_BattleSoulTrialLayer", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_BattleInfoPopup", BattleResType.UI, 1);
            
            // 以下UI 属于战斗内可能会出现的UI。 无需预加载
            resModule.AddResultByPath("UIView_BattleSettingWnd", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_MessageBox", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_BattleBuffTipsWnd", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_BattleMonsterInf", BattleResType.UI, 1);
            resModule.AddResultByPath("UIView_BattleInterActorPopup", BattleResType.UI, 1);
            //跟策划（五当）约定为新手关卡
            if (BattleUtil.IsGuideLevel(_levelID))
            {
                resModule.AddResultByPath("UIView_NoviceGuideWnd", BattleResType.UI, 1);
                foreach (var v in TbUtil.battleGuides.Values)
                {
                    resModule.AddResultByPath(v.Sound, BattleResType.UIAudio, 1);
                }
            }

            //切换镜头角色选中特效
            FXConfig fxConfig = TbUtil.GetCfg<FXConfig>(TbUtil.battleConsts.SelectedMonsterFXID);
            if (fxConfig != null)
            {
                resModule.AddResultByPath(fxConfig.PrefabName, BattleResType.FX);
            }
            
            fxConfig = TbUtil.GetCfg<FXConfig>(TbUtil.battleConsts.UnSelectedMonsterFXID);
            if (fxConfig != null)
            {
                resModule.AddResultByPath(fxConfig.PrefabName, BattleResType.FX);
            }
            
            fxConfig = TbUtil.GetCfg<FXConfig>(TbUtil.battleConsts.SelectedRoleFXID);
            if (fxConfig != null)
            {
                resModule.AddResultByPath(fxConfig.PrefabName, BattleResType.FX);
            }
            resModule.AddResultByFxId(TbUtil.battleConsts.DirGuideFxId);
            ResAnalyzeUtil.AnalyzeIcon(resModule, TbUtil.battleConsts.RobotIcon);
        }
        
        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is UIResAnalyzer analyzer)
            {
                return analyzer._levelID == _levelID;
            }
            return false;
        }
    }
}