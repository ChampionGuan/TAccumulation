using System;
using System.Collections.Generic;
using System.IO;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public static partial class BattleUtil
    {
        private static string RogueFileRoot = Application.persistentDataPath + "/";
        private static string RogueFileName = "OfflineRogueArg";
        private static string RogueFileExt = "bytes";

        public static void CreateDoor(List<RogueDoorData> doorDatas)
        {
            int doorConfigCount = Battle.Instance.rogue.doorConfigs.Count;
            if (doorConfigCount < doorDatas.Count)
            {
                LogProxy.LogError($"【战斗】【Rogue】该关卡编辑器配置:{Battle.Instance.actorMgr.stageConfig.ID}, 配置的门数量:{doorDatas.Count} < 随机出的门数量:{doorDatas.Count}");
            }

            int minCount = Math.Min(doorConfigCount, doorDatas.Count);
            for (var i = 0; i < minCount; i++)
            {
                var doorData = doorDatas[i];
                var doorConfig = Battle.Instance.rogue.doorConfigs[i];
                // DONE: 门描述信息中文拼接. 关卡类型中文 + 奖励类型中文 + 奖励参数类型中文
                string rogueLevelTypeText = "";
                if (TbUtil.battleRogueLevelConfigs.TryGetValue(doorData.ID, out var battleRogueLevelConfig))
                {
                    rogueLevelTypeText = BattleUtil.GetRogueLevelTypeText((RogueStageType)battleRogueLevelConfig.Type);
                }

                string rogueRewardTypeText = BattleUtil.GetRogueRewardTypeText(doorData.ExtraRewardType);
                string rogueRewardParamText = "";
                if (doorData.ExtraRewardType == RogueRewardType.Entry)
                {
                    if (TbUtil.TryGetCfg(doorData.ExtraRewardParam, out EntriesTag entries))
                    {
                        rogueRewardParamText = TbUtil.GetDebugText(entries.EditorName);
                    }
                }
                
                string showText = $"{rogueLevelTypeText}-{rogueRewardTypeText}-{rogueRewardParamText}";
                var door = Battle.Instance.actorMgr.CreateInterActor(doorConfig.ID, desc: showText);
                Battle.Instance.rogue.doors.Add(door);
                LogProxy.Log($"【战斗】【Rogue】创建了一扇门 ID={doorData.ID}, 额外奖励类型={doorData.ExtraRewardType}, 额外奖励类型={doorData.ExtraRewardParam}, {showText}");
            }
        }

        public static void RollCurDoor(Action<List<RogueDoorData>> rollDoorCallback)
        {
            Battle battle = Battle.Instance;
            if (battle == null)
            {
                rollDoorCallback(null);
            }
            HashSet<int> usedLevelIds = new HashSet<int>();
            foreach (RogueLayerData rogueLayerData in battle.rogue.arg.LayerDatas)
            {
                usedLevelIds.Add(rogueLayerData.BattleLevelID);
            }
            rollDoorCallback(RollDoor(battle.rogue.config, usedLevelIds));
        }

        /// <summary>
        /// 重新Roll门
        /// </summary>
        public static void ReRollDoor()
        {
            if (Battle.Instance.rogue.rollDoorTimes <= 0)
            {
                return;
            }

            // 回收已创出的门, 并重新Roll新的门
            if (Battle.Instance.rogue.doors.Count > 0)
            {
                foreach (var door in Battle.Instance.rogue.doors)
                {
                    Battle.Instance.actorMgr.RecycleActor(door);
                }
                
                RollCurDoor(CreateDoor);
                Battle.Instance.rogue.rollDoorTimes -= 1;
            }
        }
        
        public static List<RogueDoorData> RollDoor(BattleRogueConfig battleRogueConfig, HashSet<int> usedLevelIds)
        {
            int rogueLevelNum;
            if (battleRogueConfig.PortalNum == null || battleRogueConfig.PortalNum.Length != 2)
            {
                LogProxy.LogError("【战斗】【Rogue】BattleRogue的PortalNum参数配置错误！");
                rogueLevelNum = 1;
            }
            else
            {
                rogueLevelNum = BattleRandom.instance.Next(battleRogueConfig.PortalNum[0], battleRogueConfig.PortalNum[1] + 1);
            }

            List<RogueLevelWeight> rogueLevelWeights = new List<RogueLevelWeight>();
            List<int> rogueLevelIds = new List<int>();
            List<int> conflictIDs = new List<int>();
            if (battleRogueConfig.RogueLevelIDs != null)
            {
                foreach (S2Int s2Int in battleRogueConfig.RogueLevelIDs)
                {
                    BattleRogueLevelConfig battleRogueLevelConfig = TbUtil.GetCfg<BattleRogueLevelConfig>(s2Int.ID);
                    if (battleRogueLevelConfig == null)
                    {
                        continue;
                    }

                    if (s2Int.Num <= 0)
                    {
                        if (s2Int.Num < 0)
                        {
                            rogueLevelIds.Add(s2Int.ID);
                            conflictIDs.Add(battleRogueLevelConfig.ConflictID);
                        }
                        continue;
                    }
                    RogueLevelWeight rogueLevelWeight = new RogueLevelWeight()
                    {
                        id = s2Int.ID,
                        weight = s2Int.Num,
                        canDuplicate = battleRogueLevelConfig.CanDuplicate,
                        conflictID = battleRogueLevelConfig.ConflictID
                    };

                    if(!conflictIDs.Contains(rogueLevelWeight.conflictID))
                        rogueLevelWeights.Add(rogueLevelWeight);
                    
                }
            }
            
            //权重随机逻辑
            while (rogueLevelIds.Count < rogueLevelNum && rogueLevelWeights.Count > 0)
            {
                int totalWeight = 0;
                //统计总权重值
                foreach (RogueLevelWeight rogueLevelWeight in rogueLevelWeights)
                {
                    rogueLevelWeight.topWeight = rogueLevelWeight.weight + totalWeight;
                    totalWeight += rogueLevelWeight.weight;
                }
                //随机出选中的门
                int randomWeight = BattleRandom.instance.Next(0, totalWeight + 1);
                foreach (RogueLevelWeight rogueLevelWeight in rogueLevelWeights)
                {
                    if (randomWeight <= rogueLevelWeight.topWeight)
                    {
                        rogueLevelIds.Add(rogueLevelWeight.id);
                        if (!rogueLevelWeight.canDuplicate)
                        {
                            rogueLevelWeights.Remove(rogueLevelWeight);
                        }

                        if (rogueLevelWeight.conflictID != 0)
                        {
                            // 移除冲突的ID
                            for (int i = rogueLevelWeights.Count - 1; i >= 0; i--)
                            {
                                if (rogueLevelWeights[i].conflictID == rogueLevelWeight.conflictID)
                                    rogueLevelWeights.Remove(rogueLevelWeights[i]);
                            }
                        }
                        break;
                    }
                }
            }
            
            //保底给个门
            if (rogueLevelIds.Count == 0)
            {
                if (battleRogueConfig.DefaultRogueLevelID == 0)
                {
                    rogueLevelIds.Add(1);
                }
                else
                {
                    rogueLevelIds.Add(battleRogueConfig.DefaultRogueLevelID);
                }
            }

            List<RogueDoorData> rogueDoorDatas = new List<RogueDoorData>();
            List<RogueReward> rogueRewards = new List<RogueReward>();
            foreach (int rogueLevelId in rogueLevelIds)
            {
                rogueDoorDatas.Add(GetRogueDoorData(rogueLevelId, usedLevelIds, rogueRewards));
            }
            return rogueDoorDatas;
        }

        public static RogueDoorData GetRogueDoorData(int rogueLevelId, HashSet<int> usedLevelIds, List<RogueReward> rogueRewards = null)
        {
            BattleRogueLevelConfig battleRogueLevelConfig = TbUtil.GetCfg<BattleRogueLevelConfig>(rogueLevelId);
            RogueDoorData doorData = new RogueDoorData();
            
            doorData.ID = rogueLevelId;
            doorData.ExtraRewardType = (RogueRewardType)battleRogueLevelConfig.RewardType;
            if (battleRogueLevelConfig.RewardParams != null)
            {
                foreach (S2Int s2Int in battleRogueLevelConfig.RewardParams)
                {
                    if (s2Int.Num < 0)
                    {
                        doorData.ExtraRewardParam = s2Int.ID;
                        break;
                    }
                }

                if (doorData.ExtraRewardParam <= 0)
                {
                    int totalWeight = 0;
                    
                    foreach (S2Int s2Int in battleRogueLevelConfig.RewardParams)
                    {
                        if (s2Int.Num < 0 || IsRewardForbid(rogueRewards, battleRogueLevelConfig.Type, battleRogueLevelConfig.RewardType, s2Int.ID))
                        {
                            continue;
                        }
                        totalWeight += s2Int.Num;
                    }

                    if (totalWeight > 0)
                    {
                        int randomWeight = BattleRandom.instance.Next(0, totalWeight + 1);
                        int topWeight = 0;
                        foreach (S2Int s2Int in battleRogueLevelConfig.RewardParams)
                        {
                            if (s2Int.Num < 0 || IsRewardForbid(rogueRewards, battleRogueLevelConfig.Type, battleRogueLevelConfig.RewardType, s2Int.ID))
                            {
                                continue;
                            }
                            topWeight += s2Int.Num;
                            if (randomWeight <= topWeight)
                            {
                                doorData.ExtraRewardParam = s2Int.ID;
                                break;
                            }
                        }
                    }
                }
            }

            RogueReward reward = new RogueReward()
            {
                type = battleRogueLevelConfig.Type,
                rewardType = battleRogueLevelConfig.RewardType,
                rewardParam = doorData.ExtraRewardParam
            };
            rogueRewards?.Add(reward);
            
            if (battleRogueLevelConfig.RandomMode == (int)RogueRandomModeType.Average)
            {
                doorData.BattleLevelID = battleRogueLevelConfig.LevelIDs[BattleRandom.instance.Next(0, battleRogueLevelConfig.LevelIDs.Length)];
            }
            else
            {
                List<int> levelIds = new List<int>();
                foreach (int levelId in battleRogueLevelConfig.LevelIDs)
                {
                    if (usedLevelIds.Contains(levelId))
                    {
                        continue;
                    }
                    levelIds.Add(levelId);
                }

                doorData.BattleLevelID = levelIds[BattleRandom.instance.Next(0, levelIds.Count)];
            }
            
            return doorData;
        }

        /// <summary>
        /// 和已有的奖励重复了
        /// </summary>
        /// <returns></returns>
        private static bool IsRewardForbid(List<RogueReward> rogueRewards, int type, int rewardType, int rewardParam)
        {
            if (rogueRewards == null)
                return false;
            foreach (var reward in rogueRewards)
            {
                if (reward.type == type && reward.rewardType == rewardType && reward.rewardParam == rewardParam)
                    return true;
            }

            return false;
        }
        
        public static RogueLocalData ReadRogueLocalData()
        {
            RogueLocalData rogueArg = null;
#if UNITY_EDITOR
                rogueArg = MpUtil.Deserialize<RogueLocalData>(RogueFileRoot, RogueFileName);
#else
                rogueArg = MpUtil.Deserialize<RogueLocalData>(RogueFileRoot, RogueFileName);
#endif
            return rogueArg;
        }

        public static void SaveRogueLocalData(RogueLocalData data)
        {
            //editor下存入json文件
#if UNITY_EDITOR
                MpUtil.EditorSerializeToJson(data, RogueFileRoot, RogueFileName);
                MpUtil.Serialize(data, RogueFileRoot, RogueFileName);
#else
                MpUtil.Serialize<RogueLocalData>(data, RogueFileRoot, RogueFileName);
#endif
            LogProxy.Log($"【存取离线Rogue数据】成功! path:{RogueFileRoot}/{RogueFileName}");
        }

        public static void DeleteRogueLocalData()
        {
            File.Delete($"{RogueFileRoot}{RogueFileName}.{RogueFileExt}");
        }
        
        public static void SaveRogueData()
        {
            var rogueGameplay = Battle.Instance.rogue;
            var saveData = ReadRogueLocalData();
            var saveArg = (RogueArg)rogueGameplay.arg.Clone();
            var saveCurrLayerData = saveArg.CurrentLayerData;
            saveData.Arg = saveArg;

            saveData.Arg.RollDoorTimes = rogueGameplay.rollDoorTimes;

            // DONE: 保存过程随机种子.
            if (BattleRandom.instance != null)
            {
                saveData.StepSeed = BattleRandom.instance.seed;    
            }

            // DONE: 记录战斗玩法已经结束的状态.
            saveCurrLayerData.StageStep = Battle.Instance.isEnd ? RogueStageStep.End : RogueStageStep.Mid;

            // DONE: 词条库相关数据保存.
            rogueGameplay.SaveToRogueArg(saveArg);
            
            // DONE: 如果选则的门数据不为空, 计算下一层的关卡数据.
            if (rogueGameplay.selectDoorData != null)
            {
                // DONE: 尾关判断.
                int nextLayerID = rogueGameplay.config.NextID;
                int nextLevelID = rogueGameplay.selectDoorData.ID;
                int nextTrophyParam = rogueGameplay.selectDoorData.ExtraRewardParam;
                int nextBattleLevelID = rogueGameplay.selectDoorData.BattleLevelID;
                if (nextLayerID > 0)
                {
                    var nextLayerData = new RogueLayerData();
                    nextLayerData.LayerID = nextLayerID;
                    nextLayerData.LevelID = nextLevelID;
                    nextLayerData.BattleLevelID = nextBattleLevelID;
                    nextLayerData.TrophyParam = nextTrophyParam;
                    nextLayerData.StageStep = RogueStageStep.Before;
                    saveData.StepSeed = saveData.Seed;
                    saveArg.LayerDatas.Add(nextLayerData);
                }
            }
            // DONE: 如果还没选门, 记录Roll出来的门数据.
            else if (rogueGameplay.doorDatas != null && rogueGameplay.doorDatas.Count > 0)
            {
                foreach (var doorData in rogueGameplay.doorDatas)
                {
                    saveCurrLayerData.DoorDatas.Add((RogueDoorData)doorData.Clone());
                }
            }
            
            // DONE: 战利品数据保存.
            saveCurrLayerData.TrophyDatas.Clear();
            foreach (var trophyData in rogueGameplay.currentTrophyDatas)
            {
                saveCurrLayerData.TrophyDatas.Add((RogueTrophyData)trophyData.Clone());
            }
            
            // DONE: 关卡结束了, 记录当前关最后剩余的血量.
            if (Battle.Instance.isEnd)
            {
                var boyAttributeOwner = Battle.Instance.actorMgr.boy?.attributeOwner;
                if (boyAttributeOwner != null)
                {
                    saveCurrLayerData.BoyHp = boyAttributeOwner.GetAttrValue(AttrType.HP);
                }

                var girlAttributeOwner = Battle.Instance.actorMgr.girl?.attributeOwner;
                if (girlAttributeOwner != null)
                {
                    saveCurrLayerData.GirlHp = girlAttributeOwner.GetAttrValue(AttrType.HP);
                }
            }

            SaveRogueLocalData(saveData);
        }

        public static bool HasRogueData()
        {
            return MpUtil.FileExists(RogueFileRoot, RogueFileName, RogueFileExt);
        }

        public static void OpenRogueDataDic()
        {
            var tempPath = RogueFileRoot.Replace("/", "\\"); // 换成 windows格式
            System.Diagnostics.Process.Start("explorer.exe",tempPath);
        }

        /// <summary>
        /// 获取该枚举对应的中文Text.
        /// </summary>
        /// <param name="stageType"></param>
        /// <returns></returns>
        public static string GetRogueLevelTypeText(RogueStageType stageType)
        {
            int index = (int)stageType;
            var textIds = TbUtil.battleConsts.RogueLevelTypeUItextID;
            if (textIds == null || index < 0 || index >= textIds.Length)
            {
                return "策划配置错误！请检查！";
            }

            int textId = textIds[index];
            return BattleEnv.LuaBridge.GetUIText(textId);
        }

        /// <summary>
        /// 获取该枚举对应的中文Text
        /// </summary>
        /// <param name="rewardType"></param>
        /// <returns></returns>
        public static string GetRogueRewardTypeText(RogueRewardType rewardType)
        {
            int index = (int)rewardType;
            var textIds = TbUtil.battleConsts.RogueRewardTypeUItextID;
            if (textIds == null || index < 0 || index >= textIds.Length)
            {
                return "策划配置错误！请检查！";
            }

            int textId = textIds[index];
            return BattleEnv.LuaBridge.GetUIText(textId);
        }
        
        /// <summary>
        /// 是否含有某种rogue关卡类型
        /// </summary>
        /// <param name="flag"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static bool ContainRogueStageType(RogueStageFlag flag, RogueStageType type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }

        #region 词条抽取相关
        public static List<RogueEntry> RollEntryForEditor(int layerId, int rewardParam,EntryQuality minRarity,RogueEntriesLibrary rogueEntriesLibrary)
        {
            if (rogueEntriesLibrary == null)
            {
                return null;
            }
            //策划在词条表中配置的是当前回合数
            rogueEntriesLibrary.CurrentRound = layerId;
            rogueEntriesLibrary.TagLimit = rewardParam;
            return rogueEntriesLibrary.RollEntriesForPlayer(3,false,minRarity);
        }
        /// <summary>
        /// 运行时condition检查接口expressionStr=null或者checkItemFunc=null直接返回true
        /// </summary>
        /// <param name="expressionStr">rougue编辑器中配的表达式，RogueEntryCfg.ConditionExpression</param>
        /// <param name="checkItemFunc">每个conditon的判断回调</param>
        /// <returns></returns>
        public static bool CheckEntryCondition(string expressionStr, Func<int, bool> checkItemFunc = null)
        {
            if (expressionStr == null || checkItemFunc == null)
            {
                return true;
            }
            
            var expressionNode = ObjectPoolUtility.EntryExpressionRootNodePool.Get();
            expressionNode.Init(expressionStr, checkItemFunc);
            var result = expressionNode.GetResult();
            ObjectPoolUtility.EntryExpressionRootNodePool.Release(expressionNode);
            return result;
        }
        
        #endregion

    }
}