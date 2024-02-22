using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    // 套装概念只有男女主才有
    // 套装低模，高模使用的是完全不同的shader
    public class SuitResAnalyzer : ResAnalyzer
    {
        private int _suitID;
        public override int ResID => _suitID;

        public SuitResAnalyzer(int suitID, ResModule parent = null) : base(parent)
        {
            _suitID = suitID;
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is SuitResAnalyzer analyzer)
            {
                return _suitID == analyzer._suitID;
            }

            return false;
        }

        protected override void DirectAnalyze()
        {
            ActorSuitCfg suitCfg = null;
            if (TbUtil.TryGetCfg(_suitID, out FemaleSuitConfig girlCfg))
            {
                suitCfg = girlCfg;
            }
            else if (TbUtil.TryGetCfg(_suitID, out MaleSuitConfig boyCfg))
            {
                suitCfg = boyCfg;
            }

            if (suitCfg == null)
            {
                LogProxy.LogErrorFormat("套装分析器分析失败，suitID：{0}不存在,非男女主SuitID", _suitID);
                return;
            }

            // 分析 男主武器
            if (suitCfg is MaleSuitConfig maleSuitConfig)
            {
                var boyWeaponAnalyzer = new BoyWeaponResAnalyzer(maleSuitConfig.WeaponID, resModule);
                boyWeaponAnalyzer.Analyze();
            }

            ResAnalyzeUtil.AnalyzeIcon(resModule, BattleEnv.LuaBridge.GetSuitHeadIconName(_suitID));
            ResAnalyzeUtil.AnalyzeIcon(resModule, BattleEnv.LuaBridge.GetSuitBodyIconName(_suitID));

            TryAddResSVC(_suitID);
        }
        
        private void TryAddResSVC(int suitID)
        {
            BattleCharacterMgr.GetBase2PartKeysBySuitID(suitID, out var parts, out var baseKey);
            if (parts != null)
            {
                // 只遍历部件， 裸模没有SVC
                foreach (var part in parts)
                {
                    if (string.IsNullOrEmpty(part))
                        continue;
                    {
                        // 高模
                        string fullPath = BattleCharacterMgr.GetPartAssetPath(part, CharacterMgr.LOD_LD);
                        string svcFullPath = ResAnalyzeUtil.GetShaderSVCPath(fullPath);
                        resModule.AddResultByPath(svcFullPath, BattleResType.CharacterSVC, 1);
                    }
                    {
                        // 低模
                        string fullPath = BattleCharacterMgr.GetPartAssetPath(part, CharacterMgr.LOD_HD);
                        string svcFullPath = ResAnalyzeUtil.GetShaderSVCPath(fullPath);
                        resModule.AddResultByPath(svcFullPath, BattleResType.CharacterSVC, 1);
                    }
                }
            }
        }
    }
}