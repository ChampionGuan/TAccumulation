using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    // 男主分析特殊之处：
    // 套装分析会分析男主的技能，武器
    // Actor分析器，不会分析男主的技能武器信息
    
    // 套装概念只有男女主才有
    public class HeroResAnalyzer:ActorResAnalyzer
    {
        public HeroResAnalyzer(int actorId, ResModule parent=null):base(parent, GetCfg(actorId))
        {
            
        }
        
        private static ActorCfg GetCfg(int id)
        {
            int actorID = id;
            ActorCfg actorCfg = null;
            if (TbUtil.TryGetCfg(actorID, out HeroCfg girlCfg))
            {
                actorCfg = girlCfg;
            }
            else if (TbUtil.TryGetCfg(actorID, out BoyCfg boyCfg))
            {
                actorCfg = boyCfg;
            }
            if (actorCfg == null)
            {
                LogProxy.LogErrorFormat("分析器分析失败，actorCfgID：{0}不存在,非男女主ID", actorID);
            }
            return actorCfg;
        }
        
        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is HeroResAnalyzer analyzer)
            {
                return ResID == analyzer.ResID;
            }
            return false;
        }
        
        protected override void DirectAnalyze()
        {
            base.DirectAnalyze();
            
            if (_actorCfg == null)
                return;
            if (_actorCfg is BoyCfg boyCfg)
            {
                // 男主技能分析
                resModule.AddConditionAnalyze(new BoySkillAnalyze(boyCfg.ID));

                // 分析 男女主的爆发技模型.
                resModule.AddConditionAnalyze(new UltraModelAnalyze());
            }
            else
            {
                // 走到此分支说明是女主， 预加载一下完美闪避动作模组
                if (TbUtil.battleConsts.SuccessDodgeActionModuleID > 0)
                {
                    ResAnalyzeUtil.AnalyzeActionModule(resModule, TbUtil.battleConsts.SuccessDodgeActionModuleID);   
                }
            }
        }
        
    }
}