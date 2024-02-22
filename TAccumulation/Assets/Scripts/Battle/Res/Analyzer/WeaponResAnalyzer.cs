using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 女主武器分析使用
    /// </summary>
    public class WeaponResAnalyzer : ResAnalyzer
    {
        private int _weaponSkinID;
        public override int ResID => _weaponSkinID;

        public WeaponResAnalyzer(int weaponSkinID, ResModule parent=null) : base(parent)
        {
            this._weaponSkinID = weaponSkinID;
        }

        protected override void DirectAnalyze()
        {
            AnalyzeWeapon();
        }

        private void AnalyzeWeapon()
        {
            TbUtil.TryGetCfg<WeaponSkinConfig>(_weaponSkinID, out WeaponSkinConfig weaponSkinCfg);
            if (weaponSkinCfg == null)
            {
                LogProxy.LogErrorFormat("weapon分析器启动失败，weaponSkinID:{0}不存在", _weaponSkinID);
                return;
            }

            //FX
            for (int i = 0; i < weaponSkinCfg.FadeInFxs.Length; i++)
                resModule.AddResultByFxId(weaponSkinCfg.FadeInFxs[i], type:BattleResType.FX);
            for (int i = 0; i < weaponSkinCfg.FadeOutFxs.Length; i++)
                resModule.AddResultByFxId(weaponSkinCfg.FadeOutFxs[i], 2, type:BattleResType.FX);
            
            //Mat
            resModule.AddResultByPath(weaponSkinCfg.FadeInMat, BattleResType.MatCurveAsset);
            resModule.AddResultByPath(weaponSkinCfg.FadeOutMat, BattleResType.MatCurveAsset);

            //Sound
            resModule.AddResultByPath(weaponSkinCfg.FadeOutSound, BattleResType.ActorAudio);

            var partConfigIDs = BattleUtil.GetWeaponParts(weaponSkinCfg.ID);
            if (partConfigIDs != null)
            {
                ResModule weaponPartsModule = resModule.AddChild("weaponParts");
                for (int i = 0; i < partConfigIDs.Length; i++)
                {
                    var analyze = new WeaponPartsAnalyze(partConfigIDs[i]);
                    weaponPartsModule.AddConditionAnalyze(analyze);
                }
            }

            // 分析武器特定的动作模组
            foreach (var config in TbUtil.stateToTimelines.Values)
            {
                if (config.GroupID != 0 && config.GroupID == weaponSkinCfg.BSTTGroupID)
                {
                    if (Application.isPlaying)
                        LogProxy.Log("动作模组预加载： 武器 + ActionModeID = " + config.ActionModeID + " GroupID = " + config.GroupID);
                    ResAnalyzeUtil.AnalyzeActionModule(resModule, config.ActionModeID);
                }
            }

            // 分析武器的技能（女主的部分技能和武器绑定，另外的技能由男主确定）
            var logicCfg = TbUtil.GetCfg<WeaponLogicConfig>(weaponSkinCfg.WeaponLogicID);
            if (logicCfg == null)
            {
                return;
            }
            
            //  此处的AI配置，目前只用于女主。 男主的仍然配置方式仍然使用的是RoleCfg中的CombatAI
            if (!string.IsNullOrEmpty(logicCfg.AI))
            {
                resModule.AddResultByPath(logicCfg.AI, BattleResType.AITree);
                AnalyzeFromLoadedRes<GameObject>(logicCfg.AI, BattleResType.AITree, ResAnalyzeUtil.AnalyzerGraphPrefab, resModule);
            }
            
            // 分析武器给与女主出生，和死亡动作模组
            ResAnalyzeUtil.AnalyzeActionModule(resModule, logicCfg.BornActionModeID);
            ResAnalyzeUtil.AnalyzeActionModule(resModule, logicCfg.DeadActionModeID);
    
            // 分析给女主的技能
            resModule.AddConditionAnalyze(new GirlSkillAnalyze(weaponSkinCfg.WeaponLogicID));
        }
        
        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is WeaponResAnalyzer analyzer)
            {
                return analyzer._weaponSkinID == _weaponSkinID;
            }
            return false;
        }
    }
}