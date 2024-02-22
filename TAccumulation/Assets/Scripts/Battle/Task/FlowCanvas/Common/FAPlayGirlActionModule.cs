using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("女主播完美闪避动作模组\nFAPlayGirlActionModule")]
    public class FAPlayGirlActionModule : FlowAction
    {
        // 是否播放全套特效，是则男主带来的动作模组和battleConst表里的都会播，否则只播battleConst表里的
        [Name("是否播放全套特效")]
        public BBParameter<bool> isPlayAll = new BBParameter<bool>();
        
        protected override void _OnGraphStart()
        {
            var girl = Battle.Instance.actorMgr.girl;
            if (girl != null)
            {
                TbUtil.TryGetCfg(BattleEnv.StartupArg.boyID, out BoyCfg staticBoyCfg);
                if (staticBoyCfg != null && staticBoyCfg.PerfectDodgeActionModule > 0)
                {
                    girl.sequencePlayer.CreateFlowCanvasModule(staticBoyCfg.PerfectDodgeActionModule);
                }

                if (TbUtil.battleConsts.SuccessDodgeActionModuleID > 0)
                {
                    girl.sequencePlayer.CreateFlowCanvasModule(TbUtil.battleConsts.SuccessDodgeActionModuleID);
                }
            }
        }

        protected override void _Invoke()
        {
            var girl = Battle.Instance.actorMgr.girl;
            if (girl != null)
            {
                if (TbUtil.battleConsts.SuccessDodgeActionModuleID > 0)
                {
                    girl.sequencePlayer.PlayFlowCanvasModule(TbUtil.battleConsts.SuccessDodgeActionModuleID);    
                }
                
                if (isPlayAll.GetValue())
                {
                    TbUtil.TryGetCfg(BattleEnv.StartupArg.boyID, out BoyCfg staticBoyCfg);
                    if (staticBoyCfg != null && staticBoyCfg.PerfectDodgeActionModule > 0)
                    {
                        girl.sequencePlayer.PlayFlowCanvasModule(staticBoyCfg.PerfectDodgeActionModule);
                    }    
                }
            }
        }
    }
}
