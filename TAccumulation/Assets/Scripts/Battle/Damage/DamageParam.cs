using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class DamageParam : IReset
    {
        public int depth { get; set; }
        public DamageExporter damageExporter { get; private set; }
        public DamageBoxCfg damageBoxCfg { get; private set; }
        public HitParamConfig hitParamConfig { get; private set; }
        public float damageProportion { get; private set; }
        public List<HitTargetInfo> hitTargetInfos { get; private set; } = new List<HitTargetInfo>(10);
        
        /// <summary> 是否造成伤害的回调. </summary>
        public Action<Actor, bool> exportedDamageAction { get; set; }

        public void Init(DamageExporter damageExporter, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, float damageProportion, List<HitTargetInfo> hitTargetInfos)
        {
            this.damageExporter = damageExporter;
            this.damageBoxCfg = damageBoxCfg;
            this.hitParamConfig = hitParamConfig;
            this.damageProportion = damageProportion;
            this.hitTargetInfos.AddRange(hitTargetInfos);
        }

        public void Reset()
        {
            this.depth = 0;
            this.hitTargetInfos.Clear();
            this.damageExporter = null;
            this.damageBoxCfg = null;
            this.hitParamConfig = null;
            this.damageProportion = 0f;
            this.exportedDamageAction = null;
        }
        
        public static DamageParam Create(DamageExporter damageExporter, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, float damageProportion, List<HitTargetInfo> hitTargetInfos)
        {
            var damageParam = ObjectPoolUtility.DamageParamPool.Get();
            damageParam.Init(damageExporter, damageBoxCfg, hitParamConfig, damageProportion, hitTargetInfos);
            return damageParam;
        }

        public static void Recycle(DamageParam damageParam)
        {
            ObjectPoolUtility.DamageParamPool.Release(damageParam);
        }
    }
}