using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class BattleResAnalyzerBranchMerge : BattleResAnalyzerBuildApp
    {

        public BattleResAnalyzerBranchMerge(BuildAppAnalyzePars pars) : base(pars)
        {
        }
        
        protected override void OnEndAnalyze()
        {
            if (!ResAnalyzeUtil.TryAnalyzeDynamicCfgs(resModule))
            {
                LogProxy.LogError("分支合并，资源分析时，动态配置分析结果为空，将导致动态配置无法合并");
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is BattleResAnalyzerBranchMerge)
            {
                return true;
            }
            return false;
        }
    }
}