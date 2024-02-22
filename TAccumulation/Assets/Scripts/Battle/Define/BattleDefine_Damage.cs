using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    // 包围盒检测模式
    public enum DamageBoxCheckMode
    {
        Once = 1, // 单次生效模式：在Box生效期间（Duration持续期间内），凡是触碰到新的目标单位的HurtBox（或其他被动判定Box）则判定为Box命中，进入后续命中流程，单个单位只会被判定一次命中，应用例子：标准近战攻击
        PeriodCount = 2, // 周期生效模式, 在Box生效期间在Box生效期间（Duration持续期间内），以一定周期检测Box范围内是否触碰到目标单位的HurtBox（或其他被动判定Box）, 只要在AttackBox的周期判定生效时处于Box内，且该单位未达到最大命中次数，则判定为Box命中。应用例子：脉冲/地震等高频率AOE，对所有范围内的单位统一造成伤害
        ActorCDCount = 3, // 单位周期判定模式：在Box生效期内，凡是触碰到新的目标单位的（或其他被动判定Box），且该单位未达到最大命中次数，则判定为Box命中，对于同一单位的判定拥有一个CD时间，实际上比较类似Once模式，只是同单位判定有一个最短间隔，如果间隔之后该单位还会被进行命中判定。应用例：激光/龙车
    }

    // 伤害输出类型
    public enum DamageExporterType
    {
        Skill = 1,
        Buff = 2,
    }

    public enum DamageType
    {
        None = 0,
        Sub = 1, // 伤害
        Add = 2, // 治疗
        Deduct = 3, // 扣除生命
    }

    //伤害来源角色
    public enum DamageSourceActor
    {
        Default,
        Girl,
        Boy,
        BoyAndGirl,
    }

    /// <summary>
    /// 伤害包围盒类型
    /// </summary>
    public enum DamageBoxType
    {
        Attack,
        Enhance,
        Dot,
        Function,
    }

    [Flags]
    public enum DamageBoxTypeFlag
    {
        Attack = 1 << DamageBoxType.Attack,
        Enhance = 1 << DamageBoxType.Enhance,
        Dot = 1 << DamageBoxType.Dot
    }

    /// <summary> 伤害无效的类型 </summary>
    public enum DamageInvalidType
    {
        /// <summary> 伤害免疫 </summary>
        DamageImmunity,
    }
    
    /// <summary>
    /// 可修改的属性类型
    /// </summary>
    public enum ModifiableAttrType
    {
        FinalDamageAdd = AttrType.FinalDamageAdd,
        FinalDamageDec = AttrType.FinalDamageDec,
        IgnoreDefence = AttrType.IgnoreDefence,
        CureAdd = AttrType.CureAdd,
        CuredAdd = AttrType.CuredAdd,
        CritHurtAdd = AttrType.CritHurtAdd,
        AttackSkillAdd = AttrType.AttackSkillAdd,
        ThumpSkillAdd = AttrType.ThumpSkillAdd,
        ActiveSkillAdd = AttrType.ActiveSkillAdd,
        AssistSkillAdd = AttrType.AssistSkillAdd,
        CoopSkillAdd = AttrType.CoopSkillAdd,
        UltraSkillAdd = AttrType.UltraSkillAdd,
        CoreDamageRatio = AttrType.CoreDamageRatio,
        CoreDamageAdd = AttrType.CoreDamageAdd,
        WeakDamageAdd = AttrType.WeakDamageAdd,
        WeakHurtAdd = AttrType.WeakHurtAdd,
        PhyDefence = AttrType.PhyDefence,
        CritVal = AttrType.CritVal,
    }

    /// <summary>
    /// 可修改的暴击属性类型
    /// </summary>
    public enum ModifiableCriticalType
    {
        CritValue,
        CritValueAdd,
    }
    
    /// <summary>
    /// 属性变换值 (目前仅用于命中流程记录属性的变化值, 命中结束后将差值还原.)
    /// </summary>
    public struct AttrModifyData
    {
        public Actor actor;
        public AttrType attrType;
        public float additionalValue;
        public float percentValue;
    }
    
    public class ModifyAttrValue: IReset
    {
        public AttrType type;
        public float additionalValue;
        public float percentValue;
        public float finalValue; // 最终加成过后的值.
        public void Reset()
        {
            additionalValue = 0f;
            percentValue = 0f;
            finalValue = 0f;
        }
    }

    public struct CriticalModifyData
    {
        public ModifiableCriticalType modifiableCriticalType;
        public float modifyValue;
    }

    /// <summary>
    /// 假设: 扣除护甲后的伤害是200点, 血量护盾抵消 hpShieldDamage=90 点, 还剩110点的伤害, 敌人血量仅剩10点, 则实际造成伤害realDamage=10;
    /// 伤害统计 与 伤害飘字 都是 damage= 90+10=100
    /// </summary>
    public class DamageInfo : IReset
    {
        // 受击者
        public Actor actor;

        // 伤害/治疗 (用于伤害统计和飘字)
        public float damage; // 100

        // 实际造成伤害/治疗 (溢出部分扣除, 例如：扣血100点, 但hp仅剩10点, 则实际伤害为10点; 治疗同理)
        public float realDamage; // 10

        // 是否暴击
        public bool isCritical;

        public void Reset()
        {
            this.actor = null;
        }
    }

    public class DynamicDamageInfo : IReset
    {
        // 是否锁血
        public bool isLockHp = false;

        //当前造成锁血效果的buffid
        public int lockHpBuffId = 0;

        // 锁多少血. 该值也必须大于0f, 否则锁血也会失败. (当isLockHp==true时, 读取该值.)
        public float lockHpValue = 0f;

        public void Reset()
        {
            this.isLockHp = false;
            this.lockHpValue = 0f;
            this.lockHpBuffId = 0;
        }
    }

    public class HitInfo : IReset
    {
        public DamageExporter damageExporter { get; private set; }
        public DamageBoxCfg damageBoxCfg { get; private set; }
        public HitParamConfig hitParamConfig { get; private set; }
        public Actor damageCaster => damageExporter.GetCaster();
        public Actor damageTarget { get; private set; }
        public float damageProportion { get; private set; }
        public Vector3? hitPoint { get; private set; }

        public void Init(DamageExporter damageExporter, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, Actor target, float damageProportion, Vector3? hitPoint)
        {
            this.damageExporter = damageExporter;
            this.damageBoxCfg = damageBoxCfg;
            this.hitParamConfig = hitParamConfig;
            this.damageTarget = target;
            this.damageProportion = damageProportion;
            this.hitPoint = hitPoint;
        }

        public void Reset()
        {
            damageExporter = null;
            hitParamConfig = null;
            damageBoxCfg = null;
            hitPoint = null;
        }
    }

    public class DynamicHitInfo : IReset
    {
        /// <summary> 是否中断命中流程 </summary>
        public bool isInterruptHitProcess = false;

        /// <summary> 记录命中流程中产生的变化, 命中流程结束后还原变化. </summary>
        public List<AttrModifyData> attrModifies = new List<AttrModifyData>(10);

        /// <summary> 记录暴击率修正, 暴击骰子结束后还原变化. </summary>
        public List<CriticalModifyData> criticalModifies = new List<CriticalModifyData>(2);

        public void Reset()
        {
            this.isInterruptHitProcess = false;
            this.attrModifies.Clear();
            this.criticalModifies.Clear();
        }
    }

    /// <summary>
    /// 伤害统计(主动方)
    /// </summary>
    public class DamageExportMeters : IReset
    {
        /// <summary> 开始记录 </summary>
        public bool isRecord;

        /// <summary>
        /// 伤害统计
        /// {受击者, 受击者收到的伤害|治疗}
        /// </summary>
        public Dictionary<Actor, DamageMeter> damageMeters = new Dictionary<Actor, DamageMeter>(20);

        public void Add(Actor hurtActor)
        {
            var damageMeter = ObjectPoolUtility.DamageMetersPool.Get();
            damageMeter.actor = hurtActor;
            damageMeters.Add(hurtActor, damageMeter);
        }

        public void Reset()
        {
            isRecord = false;

            foreach (var keyValuePair in damageMeters)
            {
                ObjectPoolUtility.DamageMetersPool.Release(keyValuePair.Value);
            }

            damageMeters.Clear();
        }
    }

    public class DamageMeter : IReset
    {
        /// <summary>
        /// 受击者
        /// </summary>
        public Actor actor;

        /// <summary>
        /// 受到的伤害相关
        /// </summary>
        public float damage;

        public float realDamage;
        public float hpShieldDamage;
        public bool isCriticalDamage;

        /// <summary>
        /// 受到的治疗相关
        /// </summary>
        public float cure;

        public float realCure;
        public float hpShieldCure;
        public bool isCriticalCure;

        public void Reset()
        {
            actor = null;

            damage = 0f;
            realDamage = 0f;
            // hpShieldDamage = 0f;
            isCriticalDamage = false;

            cure = 0f;
            realCure = 0f;
            // hpShieldCure = 0f;
            isCriticalCure = false;
        }
    }
    
    public struct HitTargetInfo
    {
        public Actor actor;
        public Vector3? hitPos; // actor的命中点.
        public bool onlyPlayHitEffect; // 是否只播放受击特效.
    }
}