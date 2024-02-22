using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine.Serialization;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class RogueEntryCfg
    {
        // 技能ID
        [Key(0)]
        public int ID;
        
        // 技能名称
        [Key(1)]
        public string Name;
        
        // 编辑器用的虚拟目录字段
        [Key(2)] 
        public string VirtualPath ;
        
        // 描述
        [Key(3)]
        public string Description;
        
        // 稀有度
        [Key(4)]
        public EntryQuality Quality;
        
        // 初始权重值
        [Key(5)]
        public int OriginalPriority;
        
        // 等级上限
        [Key(6)]
        public int MaxLevel;
        
        // 条件列表
        [Key(8)]
        public List<EntryConditionCfg> Conditions;
        
        // 逻辑公式
        [Key(9)]
        public string ConditionExpression;
        
        // 等级配置
        [Key(10)]
        public Dictionary<int, RogueEntryLevelCfg> LevelCfgs;
        
        // 轮次权重值调整
        [Key(11)]
        public List<int> RoundPriorityWeights;
        
        // 前置词条调整
        [Key(12)]
        public List<S2IntValue> PreEntryWeights;

        // 执行顺序
        [Key(13)] 
        public int ExecutionOrder;
        
        // 标签
        [Key(14)]
        public List<int> Tags;
    }
    
    // 稀有度
    public enum EntryQuality
    {
        Star1 = 1,  // 一星
        Star2 = 2,  // 二星
        Star3 = 3,  // 三星
        Star4 = 4,  // 四星
    }

    // 词条Tag
    public enum EntryTag
    {
        Attack = 0,
        Defend = 1,
    }

    // 词条Condition
    public enum ConditionType
    {
        GirlWeapon = 0,  // 女主武器类型枚举，可多选（1904单手剑，1902大剑，1901双枪，1903法杖等，专武归类于同一类型）
        BoyScore = 1,  // 男主Score，可多选
        EntryLevel = 2,  // 当前词条必须依赖该ID的词条和等级才能生效，可填写多个
    }
    
    [Union(0, typeof(EntryConditionGirlWeaponCfg))]
    [Union(1, typeof(EntryConditionBoyScoreCfg))]
    [Union(2, typeof(EntryConditionEntryLevelCfg))]
    // Condition基类
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public abstract class EntryConditionCfg
    {
        [Key(0)]
        public ConditionType Type;
    }

    // 女主武器类型Condition配置
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class EntryConditionGirlWeaponCfg : EntryConditionCfg
    {
        [Key(1)]
        public List<int> WeaponIDs;
    }

    // 男主ScoreCondition配置
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class EntryConditionBoyScoreCfg : EntryConditionCfg
    {
        [Key(1)]
        public List<int> ScoreIDs;
    }

    // 词条ID和等级Condition配置
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class EntryConditionEntryLevelCfg : EntryConditionCfg
    {
        [Key(1)]
        public List<S2IntLevel> EntryIDLevels;
    }

    // 词条等级配置
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class RogueEntryLevelCfg
    {
        // 等级数值
        [Key(0)]
        public int Level;
        
        // 添加被动技能
        [Key(1)]
        public List<EntryPassiveSkillCfg> AddSkillActions;

        // 清除被动技能
        [Key(2)] 
        public List<EntryPassiveSkillCfg> ClearSkillActions;
    }

    // 挂载目标类型
    public enum EntryTargetType
    {
        Girl = 0,  // 女主
        Boy = 1,  // 男主
        Enemy = 2,  // 敌人
        Stage = 3,  // 关卡
    }
    
    // 添加被动技Action
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class EntryPassiveSkillCfg 
    {
        [Key(1)]
        public EntryTargetType TargetType;
        [Key(2)]
        public int SkillID;
    }
}
















