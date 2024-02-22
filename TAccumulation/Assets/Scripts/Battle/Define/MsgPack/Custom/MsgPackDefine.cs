using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Battle
{
    /// <summary>
    /// 启动启动方式
    /// </summary>
    public enum BattleStartupType
    {
        Online = 0,
        OfflineQuickBattle, //离线快速战斗
        OfflineCustom, //离线自定义战斗
        OfflineLevel, //离线关卡战斗
    }

    /// <summary>
    /// 战斗回放模式
    /// </summary>
    public enum BattleReplayMode
    {
        Nothing,// 什么都不做
        Record,// 录像
        Replay,// 回放
    }
    
    /// <summary> 游戏玩法 </summary>
    public enum BattleGameplayType
    {
        Default,
        Rogue,
    }

    /// <summary> 玩法参数 </summary>
    [Union(0, typeof(RogueArg))]
    [MessagePackObject]
    [Serializable]
    public abstract class BattleGameplayArg
    {
    }
    
    [MessagePackObject]
    [Serializable]
    public class RogueArg : BattleGameplayArg, ICloneable
    {
        /// <summary> 每一层的数据 </summary>
        [Key(0)]
        public List<RogueLayerData> LayerDatas = new List<RogueLayerData>();
        
        /// <summary> 影响词条库（词条抽取）相关的玩法数据 </summary>
        [Key(1)]
        public RogueEntryLibraryData EntryLibraryData = new RogueEntryLibraryData();

        [Key(2)] public int RollDoorTimes;

        /// <summary> 当前层的玩法数据 </summary>
        [IgnoreMember] public RogueLayerData CurrentLayerData => LayerDatas.Count > 0 ? LayerDatas[LayerDatas.Count - 1] : null;
        
        /// <summary> 上一层的玩法数据 </summary>
        [IgnoreMember] public RogueLayerData PreviousLayerData => LayerDatas.Count > 1 ? LayerDatas[LayerDatas.Count - 2] : null;
        
        public object Clone()
        {
            var newRogueArg = new RogueArg();
            newRogueArg.EntryLibraryData = (RogueEntryLibraryData)this.EntryLibraryData.Clone();
            foreach (var layerData in this.LayerDatas)
            {
                newRogueArg.LayerDatas.Add((RogueLayerData)layerData.Clone());
            }

            newRogueArg.RollDoorTimes = RollDoorTimes;

            return newRogueArg;
        }
    }

    /// <summary> 需要存储的本地模拟服务器的相关数据 </summary>
    [MessagePackObject]
    [Serializable]
    public class RogueLocalData
    {
        [Key(0)]
        public RogueArg Arg = new RogueArg();

        [Key(1)]
        public int GirlID;
        
        [Key(2)]
        public int GirlSuitID;

        [Key(3)]
        public int GirlWeaponID;

        [Key(4)]
        public int BoyID;
        
        [Key(5)]
        public int BoySuitID;

        /// <summary>
        /// 初始启动玩法后的游戏种子.
        /// </summary>
        [Key(6)]
        public int Seed;

        /// <summary>
        /// 步骤随机种子, 新起每一层数据时, 该随机种子==Seed.
        /// </summary>
        [Key(7)]
        public int StepSeed;
    }

    [MessagePackObject]
    [Serializable]
    public class RogueEntryLibraryData : ICloneable
    {
        /// <summary> 词条库ID </summary>
        [Key(0)]
        public int ID;

        /// <summary> 词条Roll的轮数 </summary>
        [Key(1)]
        public int RoundNum;

        /// <summary> 整个词条能重Roll的剩余次数 </summary>
        [Key(2)]
        public int ReRollLeftTimes;

        /// <summary> 额外奖励次数 </summary>
        [Key(5)]
        public List<RogueEntriesExtraRollParam> ExtraRewardList = new List<RogueEntriesExtraRollParam>();

        public object Clone()
        {
            var tempData = new RogueEntryLibraryData()
            {
                ID = this.ID,
                RoundNum = this.RoundNum,
                ReRollLeftTimes = this.ReRollLeftTimes,
            };
            foreach (var extraReward in ExtraRewardList)
            {
                tempData.ExtraRewardList.Add(new RogueEntriesExtraRollParam()
                    { tagLimit = extraReward.tagLimit, hasRolled = extraReward.hasRolled });
            }
            return tempData;
        }
    }

    /// <summary>
    /// Rogue层数据
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class RogueLayerData : ICloneable
    {
        /// <summary> 当前层ID 对应 BattleRogue.ID </summary>
        [Key(0)]
        public int LayerID;

        /// <summary> 当前关ID 对应 BattleRogueLevel.ID </summary>
        [Key(1)]
        public int LevelID;
        
        /// <summary> 所有战利品数据 </summary>
        [Key(2)]
        public List<RogueTrophyData> TrophyDatas = new List<RogueTrophyData>();

        /// <summary> 所有交互物数据 </summary>
        [Key(3)]
        public List<RogueInterActorData> InterActorDatas = new List<RogueInterActorData>();

        /// <summary> 当前层展示的门数据 </summary>
        [Key(4)] 
        public List<RogueDoorData> DoorDatas = new List<RogueDoorData>();

        /// <summary> 当前关额外战利品奖励的参数 (上一层便已经决定好的) </summary>
        [Key(5)] 
        public int TrophyParam;

        /// <summary> 该层的进度步骤状态. </summary>
        [Key(6)] 
        public RogueStageStep StageStep;

        /// <summary> 该层剩余的男主血量 </summary>
        [Key(7)] 
        public float BoyHp;
        
        /// <summary> 该层剩余的女主血量 </summary>
        [Key(8)] 
        public float GirlHp;

        [Key(9)] public int BattleLevelID;

        public object Clone()
        {
            var newRogueLayerData = new RogueLayerData()
            {
                LayerID = this.LayerID,
                LevelID = this.LevelID,
                TrophyParam = this.TrophyParam,
                StageStep = this.StageStep,
                BoyHp = this.BoyHp,
                GirlHp = this.GirlHp,
            };
            
            foreach (var trophyData in TrophyDatas)
            {
                newRogueLayerData.TrophyDatas.Add((RogueTrophyData)trophyData.Clone());
            }
            
            foreach (var interActorData in InterActorDatas)
            {
                newRogueLayerData.InterActorDatas.Add((RogueInterActorData)interActorData.Clone());
            }

            foreach (var doorData in DoorDatas)
            {
                newRogueLayerData.DoorDatas.Add((RogueDoorData)doorData.Clone());
            }

            return newRogueLayerData;
        }
    }

    [MessagePackObject]
    [Serializable]
    public class RogueEntriesExtraRollParam
    {
        [Key(0)]
        public int tagLimit = 0;
        [Key(1)]
        public bool hasRolled = false;
#if UNITY_EDITOR
        [IgnoreMember][NonSerialized]
        public bool selected;
#endif
    }
    /// <summary>
    /// 战利品数据
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class RogueTrophyData : ICloneable
    {
        /// <summary> 层ID </summary>
        [Key(0)]
        public int LayerID;
        
        /// <summary> 步骤ID </summary>
        [Key(1)]
        public int StepID;

        /// <summary> 该步骤的第几次领取的奖励 </summary>
        [Key(2)]
        public int Index;
        
        /// <summary> 是否领取 </summary>
        [Key(3)]
        public bool IsReceive;

        /// <summary> 奖励 </summary>
        [Key(4)] 
        public RogueRewardType Type;

        /// <summary> 具体的奖励数据内容 </summary>
        [Key(5)]
        [SerializeReference]
        public RogueRewardData Data;

        public object Clone()
        {
            return new RogueTrophyData()
            {
                LayerID =  this.LayerID,
                StepID =  this.StepID,
                Index = this.Index,
                IsReceive = this.IsReceive,
                Type = this.Type,
                Data = (RogueRewardData)this.Data.Clone()
            };
        }
    }

    /// <summary>
    /// Rogue奖励数据
    /// </summary>
    [MessagePackObject]
    [Serializable]
    [Union(0, typeof(RogueEntryRewardData))]
    public abstract class RogueRewardData : ICloneable
    {
        [Key(0)]
        public int ID;

        public abstract object Clone();
    }

    /// <summary>
    /// 词条奖励数据
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class RogueEntryRewardData : RogueRewardData
    {
        /// <summary> 词条等级 </summary>
        [Key(1)]
        public int Level;

        public override object Clone()
        {
            return new RogueEntryRewardData() { ID = this.ID, Level = this.Level };
        }
    }

    /// <summary>
    /// 交互物数据
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class RogueInterActorData : ICloneable
    {
        /// <summary> 层ID </summary>
        [Key(0)] 
        public int LayerID;
        
        /// <summary> 交互物ID </summary>
        [Key(1)]
        public int ID;

        /// <summary> 剩余可交互次数 </summary>
        [Key(2)]
        public int LeftNum;

        public object Clone()
        {
            return new RogueInterActorData() { LayerID = this.LayerID, ID = this.ID, LeftNum = this.LeftNum };
        }
    }

    /// <summary>
    /// Rogue门数据
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class RogueDoorData : ICloneable
    {
        /// <summary> Rogue关ID </summary>
        [Key(0)]
        public int ID;

        /// <summary> 额外奖励类型 </summary>
        [Key(1)]
        public RogueRewardType ExtraRewardType;

        /// <summary> 额外奖励参数 </summary>
        [Key(2)]
        public int ExtraRewardParam;

        [Key(3)] public int BattleLevelID;

        public object Clone()
        {
            return new RogueDoorData() { ID = this.ID, ExtraRewardType = this.ExtraRewardType, ExtraRewardParam = this.ExtraRewardParam, BattleLevelID = this.BattleLevelID };
        }
    }

    /// <summary>
    /// 战斗启动参数
    /// </summary>
    [Serializable]
    [MessagePackObject]
    public class BattleArg
    {
        [Key(0)] public int levelID;
        [Key(1)] public int girlID;
        [Key(2)] public int girlSuitID;
        [Key(3)] public int girlWeaponID;
        [Key(4)] public int boyID;
        [Key(5)] public int boySuitID;
        [Key(6)] public TargetLockModeType startedLockMode;
        [Key(7)] public bool startedLockBtnActive;
        [Key(8)] public bool isNumberMode;
        [Key(9)] public BattleStartupType startupType;
        [Key(10)] public int playerID;
        [Key(11)] public string sceneName;
        [Key(12)] public string replayPath;
        [Key(13)] public BattleReplayMode replayMode;
        [Key(14)] public string fromGameState;
        /// <summary>
        /// 注意此字段只允许测试使用 正式环境不允许使用
        /// </summary>
        [Key(15)] public bool isOpenAuto;

        // 该数据 离线时由读表生成， 在线时由服务器下发数据 + 读表生成
        [Key(16)] public Dictionary<int, ActorCacheBornCfg> cacheBornCfgs;
        [Key(17)] public bool isShowTips;
        [Key(18)] public List<SkillSlotConfig> affixesSkillSlotConfigs;
        
        // 该数据由服务器下发
        [Key(19)] public List<int> scoreTags;
        [Key(20)] public List<int> levelTags;
        [Key(21)] public int commonStageId;
        
        /// <summary> 玩法类型 </summary>
        [Key(22)] public BattleGameplayType gameplayType;
        /// <summary> 玩法启动参数|数据 </summary>
        [SerializeReference]
        [Key(23)] public BattleGameplayArg gameplayArg;
        
        public BattleArg()
        {
            cacheBornCfgs = new Dictionary<int, ActorCacheBornCfg>();
            scoreTags = new List<int>();
            levelTags = new List<int>();
            affixesSkillSlotConfigs = new List<SkillSlotConfig>();
            isOpenAuto = false;
        }

        private string _toStringInfo;
        public override string ToString()
        {
            if (!string.IsNullOrEmpty(_toStringInfo)) return _toStringInfo;

            var scoreTag = string.Empty;
            if (null != scoreTags)
            {
                var count = scoreTags.Count;
                for (var index = 0; index < count; index++)
                {
                    var tag = scoreTags[index];
                    scoreTag += index == count - 1 ? $"{tag}" : $"{tag}|";
                }
            }

            var levelTag = string.Empty;
            if (null != levelTags)
            {
                var count = levelTags.Count;
                for (var index = 0; index < count; index++)
                {
                    var tag = levelTags[index];
                    levelTag += index == count - 1 ? $"{tag}" : $"{tag}|";
                }
            }

            return _toStringInfo = $"levelID:{levelID},girlSuitID:{girlSuitID},girlWeaponID:{girlWeaponID},boySuitID:{boySuitID},isShowTips:{isShowTips},scoreTag:{scoreTag},levelTag:{levelTag}"; }
    }

    [Serializable]
    [MessagePackObject]
    public class ActorCacheBornCfg
    {
        [Key(0)] public int ConfigID { get; set; }
        [Key(1)] public int Level { get; set; }
        [Key(2)] public Dictionary<int, SkillSlotConfig> SkillSlots { get; set; }
        [Key(3)] public string AnimatorCtrlName { get; set; }
        [Key(4)] public Dictionary<int, int> AttrsOnline { get; set; }
        [Key(5)] public List<BuffData> BuffDatas { get; set; }
        /// <summary> 技能其他来源查找表，{SkillSlotID，(其他来源的ConfigID)} </summary>
        [Key(6)] public Dictionary<int, int> SkillSourceTable { get; set; }

        public ActorCacheBornCfg()
        {
            SkillSlots = new Dictionary<int, SkillSlotConfig>();
            AttrsOnline = new Dictionary<int, int>();
            BuffDatas = new List<BuffData>();
            SkillSourceTable = new Dictionary<int, int>();
        }
    }

    [Serializable]
    [MessagePackObject]
    public class BuffData
    {
        [Key(0)] public int ID;
        [Key(1)] public int Level;
    }

#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public struct X3Vector3
    {
        [Key(0)] public float x;
        [Key(1)] public float y;
        [Key(2)] public float z;

        public static implicit operator X3Vector3(Vector3 source)
        {
            X3Vector3 data = new X3Vector3()
            {
                x = source.x,
                y = source.y,
                z = source.z,
            };
            return data;
        }

        public X3Vector3(float x = 0, float y = 0, float z = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public static implicit operator Vector3(X3Vector3 source)
        {
            Vector3 data = new Vector3(source.x, source.y, source.z);
            return data;
        }
        
        public static bool operator ==(X3Vector3 lhs, X3Vector3 rhs)
        {
            float num1 = lhs.x - rhs.x;
            float num2 = lhs.y - rhs.y;
            float num3 = lhs.z - rhs.z;
            return  num1 * num1 +  num2 * num2 +  num3 * num3 < 9.99999943962493E-11;
        }

        public static bool operator !=(X3Vector3 lhs, X3Vector3 rhs)
        {
            return !(lhs == rhs);
        }
    }
}