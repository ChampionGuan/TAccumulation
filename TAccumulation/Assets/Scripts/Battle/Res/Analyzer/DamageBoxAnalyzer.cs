using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class DamageBoxAnalyzer : ResAnalyzer
    {
        private int _damageBoxID;
        public override int ResID => _damageBoxID;

        public DamageBoxAnalyzer(ResModule parent, int damageBoxID) : base(parent)
        {
            _damageBoxID = damageBoxID;
        }

        protected override void DirectAnalyze()
        {
            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(_damageBoxID);
            if (damageBoxCfg == null)
            {
                return;
            }

            // DONE: 解析镜头震屏资源
            resModule.AddResultByPath(damageBoxCfg.CameraShakePath, BattleResType.CameraImpulseAsset);

            // DONE: 解析击打特效
            resModule.AddResultByFxId(damageBoxCfg.HurtFXID, type:BattleResType.HurtFX);

            // DONE: 解析受击音效
            // resModule.AddResultByPath(damageBoxCfg.HurtSound, BattleResType.ActorAudio);

            //解析受击映射表中配置的特效和音效
            if (!string.IsNullOrEmpty(damageBoxCfg.hurtWeaponType))
            {
                if (TbUtil.TryGetCfg(damageBoxCfg.hurtWeaponType, out Dictionary<int, HurtMaterialConfig> materialConfigs))
                {
                    foreach (var materialConfig in materialConfigs.Values)
                    {
                        resModule.AddResultByFxId(materialConfig.HurtEffectID, type:BattleResType.HurtFX);
                        resModule.AddResultByPath(materialConfig.HurtSound, BattleResType.ActorAudio);
                    }
                }
            }


            // // DONE: 解析受击砍痕特效
            // if (TbUtil.hurtScarConfigs.TryGetValue(damageBoxCfg.HurtScarID, out var hurtScarConfig))
            // {
            //     if (hurtScarConfig != null)
            //     {
            //         analyzer.AddResultByPath(parent, hurtScarConfig.Tex, BattleResType.Texture);
            //     }
            // }
            // analyzer.AddResultByFxId(parent, damageBoxCfg.HurtScarID);

            // DONE: 解析Buff
            if (damageBoxCfg.PreAddBuffDatas != null)
            {
                foreach (AddBuffData preAddBuffData in damageBoxCfg.PreAddBuffDatas)
                {
                    var buffAnalyze = new BuffResAnalyzer(preAddBuffData.ID,  parent:resModule);
                    buffAnalyze.Analyze();
                }
            }

            if (damageBoxCfg.AfterAddBuffDatas != null)
            {
                foreach (AddBuffData afterAddBuffData in damageBoxCfg.AfterAddBuffDatas)
                {
                    var buffAnalyze = new BuffResAnalyzer(afterAddBuffData.ID, parent:resModule);
                    buffAnalyze.Analyze();
                }
            }
            if (damageBoxCfg.HurtType == HurtType.FloatHurt || damageBoxCfg.HurtType == HurtType.FlyHurt)
            {
                // DONE: 曲线资源
                resModule.AddResultByPath(damageBoxCfg.HurtCurveVertical, BattleResType.HurtBackCurve);
                resModule.AddResultByPath(damageBoxCfg.HurtCurveHorizontal, BattleResType.HurtBackCurve);
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is DamageBoxAnalyzer analyzer)
            {
                return analyzer._damageBoxID == _damageBoxID;
            }

            return false;
        }
    }
}