#if UNITY_EDITOR
using System;
#endif
using System.Collections.Generic;
using JetBrains.Annotations;
using MessagePack;
using UnityEngine.Serialization;

namespace X3Battle
{
    [MessagePackObject]
    public class SkillCfgs
    {
        [Key(0)] public Dictionary<int, SkillCfg> skillCfgs;
    }
    
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class SkillCfg
    {
        // 技能ID
        [Key(0)]
        public int ID;
        
        // 技能名称
        [Key(1)]
        public string Name;

        // 技能锁定类型
        [Key(2)] 
        public SkillLockChangeType LockChangeType = SkillLockChangeType.Update;

        // 技能优先级
        [Key(3)] 
        public float Priority = 1;

        // 技能播放速率
        [Key(4)] 
        public float PlaySpeed = 1;

        // 目标选择类型
        [Key(5)] 
        public TargetSelectType TargetSelectType = TargetSelectType.Lock;

        // 技能释放距离最小值
        [Key(6)]
        public float MinRange;

        // 技能释放距离最大值
        [Key(7)]
        public float MaxRange = 1000;
       
        // 使用次数
        [Key(8)]
        public int CastCount;

        // 触发器ID，目前只有被动技能用
        [Key(9)]
        public int TriggerID;
        
        // 触发器持续时间，目前只有被动技能用(无效字段, 整理后删除)
        [Key(10)] 
        public float TriggerDuration = -1;

        // 编辑器用的虚拟目录字段
        [Key(11)] 
        public string VirtualPath ;
        
        // 技能释放类型，主动还是被动
        [Key(12)] 
        public SkillReleaseType ReleaseType = SkillReleaseType.Active;
        
        // 描述
        [Key(13)]
        public string Description;

        /// <summary>
        /// AI进入战斗状态CD
        /// </summary>
        [Key(14)] 
        public float AIBattleCD;

        /// <summary>
        /// BuffID, 目前只用于被动技能.
        /// </summary>
        [Key(15)]
        public List<int> BuffIDs;

        /// <summary>
        /// 动作模组ID
        /// </summary>
        [Key(16)] public int[] ActionModuleIDs;
        
        // 是否面向技能目标
        [Key(17)] 
        public bool IsRotateToTarget = false;
        
        // AI时间间隔
        [Key(18)]
        public float AISkillCD; 
        
        // 是否面向此刻人物期望方向（从主状态机输入那里拿）
        [Key(19)] 
        public bool IsRotateToExpectation;
        
        // 技能Tag
        [Key(20)] public List<int> Tags;
        // 演出半径
        [Key(21)] public float CoopPlayRadius;
        // 攻击半径
        [Key(22)] public float CoopAttackRadius;
        // 是否移动到目标位置
        [Key(23)] public bool CoopSetPos;
        /// <summary>
        /// 技能Tag
        /// </summary>
        [Key(24)] public SkillType Type = SkillType.Attack;
        /// <summary>
        /// 是否使用动作模组中CD控制
        /// </summary>
        [Key(25)] public bool IsActiveControlCD;
        
        // 当选择锁定目标时出的范围
        [Key(26)] public float NearestEnemySelectRange;

        // 主动技是否设置位移位置
        [Key(27)] public bool ActiveSkillTransport;
        [Key(28)] public BoyTransportTargetType TransportTargetType;
        [Key(29)] public float TransportMinRadius;
        [Key(30)] public float TransportMaxRadius;
        [Key(31)] public float TransportAngle;
        [Key(32)] public int PreTransportFX;
        [Key(33)] public int PostTransportFX;
        /// <summary>
        /// 爆衣动作模组ID
        /// </summary>
        [Key(34)] public int[] BrokenShirtActionModuleIDs;

        // DogeOffset开关（知有闪避技能有用）
        [Key(35)] public bool DodgeOffset;

        // AI进战斗最大CD
        [Key(36)] public float AIBattleCDMax;

        /// <summary>
        /// 共鸣技/QTE参照选点
        /// </summary>
        [Key(42)] public X3Vector3[] CameraCollisionPoint;
        
        // 是否受关卡策略影响
        [Key(43)]
        public bool IsStageStrategy = true;
        
        // QTE技能优先选点
        [Key(44)] 
        public QTEDirectionFlag QTEPriorityDirections; 
        
        //是否使用破核技能选敌逻辑
        [Key(45)] 
        public bool IsUseCoreSelect; 
        
#if UNITY_EDITOR
        /// <summary>调试器使用</summary>
        [NonSerialized][IgnoreMember] 
        public SkillCfg oCfg;
        [NonSerialized][IgnoreMember] 
        public List<int> cloneIds;
#endif
    }
}