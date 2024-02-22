using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;


namespace X3Battle
{
    /// <summary>
    /// 子弹解析
    /// </summary>
    public class MissileAnalyzer: ResAnalyzer
    {
        private int _missileID;
        private bool _containsRicochet;
        public override int ResID => _missileID;
        
        public MissileAnalyzer(ResModule parent, int missileIDID, bool containsRicochet) : base(parent)
        {
            _missileID = missileIDID;
            _containsRicochet = containsRicochet;
        }

        protected override void DirectAnalyze()
        {
            var missileCfg = TbUtil.GetCfg<MissileCfg>(_missileID);
            if (missileCfg == null)
            {
                PapeGames.X3.LogProxy.LogWarningFormat("资源分析：新子弹id={0}，对应的配置表不存在", _missileID);
                return;
            }

            // 解析新子弹通用数据
            resModule.AddResultByFxId(missileCfg.FX);
            resModule.AddResultByFxId(missileCfg.natureDisappearFx);
            resModule.AddResultByFxId(missileCfg.CollideSceneFX);
            if (missileCfg.DamageBox > 0)
            {
                var damageAnalyze = new DamageBoxAnalyzer(resModule, missileCfg.DamageBox);
                damageAnalyze.Analyze();
            }

            if (missileCfg.IsBlastEffect)
            {
                if (missileCfg.BlastDamageBox > 0)
                {
                    var damageAnalyze = new DamageBoxAnalyzer(resModule, missileCfg.BlastDamageBox);
                    damageAnalyze.Analyze();
                }
                
                resModule.AddResultByFxId(missileCfg.BlastFX);

                if (!string.IsNullOrEmpty(missileCfg.BlastMusic))
                {
                    resModule.AddResultByPath(missileCfg.BlastMusic, BattleResType.BulletAudio);
                }
            }

            if(!string.IsNullOrEmpty(missileCfg.CameraShakePath))
            {
                resModule.AddResultByPath(missileCfg.CameraShakePath, BattleResType.CameraImpulseAsset);
            }
            
            // 解析子弹音频
            if (!string.IsNullOrEmpty(missileCfg.FlyMusic))
            {
                resModule.AddResultByPath(missileCfg.FlyMusic, BattleResType.BulletAudio);
            }
            if (!string.IsNullOrEmpty(missileCfg.HitSceneMusic))
            {
                resModule.AddResultByPath(missileCfg.HitSceneMusic, BattleResType.BulletAudio);
            }
            if (!string.IsNullOrEmpty(missileCfg.HitActorMusic))
            {
                resModule.AddResultByPath(missileCfg.HitActorMusic, BattleResType.BulletAudio);
            }

            if (_containsRicochet && missileCfg.ricochetActive && missileCfg.ricochetMissileID > 0)
            {
                var childIDs = new HashSet<int>();
                RicochetUtil.GatherRicochetMissile(missileCfg.ricochetMissileID, ref childIDs);
                foreach (var childID in childIDs)
                {
                    var missileAnalyze = new MissileAnalyzer(resModule, childID, false);
                    missileAnalyze.Analyze();
                }
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is MissileAnalyzer analyzer)
            {
                return analyzer._missileID == _missileID && _containsRicochet == analyzer._containsRicochet;
            }

            return false;
        }
    }
}