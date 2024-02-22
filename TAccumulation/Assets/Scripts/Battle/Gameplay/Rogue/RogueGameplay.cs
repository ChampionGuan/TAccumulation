using System;
using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public class RogueGameplay : BattleGameplayBase
    {
        public override LevelFlowBase levelFlow { get; } = new RogueLevelFlow();
        public RogueArg arg => battle.arg.gameplayArg as RogueArg;
        public BattleRogueConfig config { get; private set; }
        public BattleRogueLevelConfig levelConfig { get; private set; }

        /// <summary> 门数据 </summary>
        public List<RogueDoorData> doorDatas { get; } = new List<RogueDoorData>();
        
        /// <summary> 选取的门数据 </summary>
        public RogueDoorData selectDoorData { get; private set; }

        /// <summary> 之前所有战利品数据 </summary>
        public List<RogueTrophyData> historyTrophyDatas { get; } = new List<RogueTrophyData>();
        
        //当前层奖励
        public List<RogueTrophyData> currentTrophyDatas { get; } = new List<RogueTrophyData>();

        /// <summary> 所有交互物数据 </summary>
        public List<RogueInterActorData> interActorDatas { get; } = new List<RogueInterActorData>();

        public List<InterActorPointConfig> doorConfigs { get; } = new List<InterActorPointConfig>();

        /// <summary>
        /// 所有的门
        /// </summary>
        public List<Actor> doors { get; } = new List<Actor>();

        private Action<List<RogueDoorData>> _rollDoorCacheCallback;
        private Action<List<RogueDoorData>> _rollDoorCallback;
        private Action<int> _selectDoorCacheCallback;
        private Action<int> _selectDoorCallback;
        

        #region 词条相关
        public RogueEntriesLibrary rogueEntriesLibrary { get; private set; }

        /// <summary> 当前词条抽取参数,0是没有限制 </summary>
        public List<RogueEntriesExtraRollParam> extraEntriesRollParamList =
            new List<RogueEntriesExtraRollParam>();
        private Action _selectRogueEntryCacheCallback;
        private Action<int,int> _selectRogueEntryCallback;
        
        private List<RogueEntryRewardData> _entriesRewardList = new List<RogueEntryRewardData>(5);
        
        private List<(int SkillID, int Level)> _girlEntriesAddSkillIDs = new List<(int, int)>(5);
        private List<int> _girlEntriesRemoveSkillIDs = new List<int>(5);
        private List<(int SkillID, int Level)> _boyEntriesAddSkillIDs = new List<(int, int)>(5);
        private List<int> _boyEntriesRemoveSkillIDs = new List<int>(5);
        private List<(int SkillID, int Level)> _enemyEntriesAddSkillIDs = new List<(int, int)>(5);
        private List<int> _enemyEntriesRemoveSkillIDs = new List<int>(5);
        private List<(int SkillID, int Level)> _stageEntriesAddSkillIDs = new List<(int, int)>(5);
        private List<int> _stageEntriesRemoveSkillIDs = new List<int>(5);
        
        #endregion

        public int rollDoorTimes;
		
		public RogueGameplay()
        {
            _rollDoorCallback = _RollDoorCallback;
            _selectDoorCallback = _SelectDoorCallback;
            _selectRogueEntryCallback = _SelectRogueEntryback;
            //初始化词条库
            rogueEntriesLibrary = new RogueEntriesLibrary();
        }
        
        protected override void OnAwake()
        {
            config = TbUtil.GetCfg<BattleRogueConfig>(arg.CurrentLayerData.LayerID);
            levelConfig = TbUtil.GetCfg<BattleRogueLevelConfig>(arg.CurrentLayerData.LevelID);

            // DONE: 初始化所有领取的战利品数据.
            _InitTrophyData();
            
            // DONE: 初始化所有已交互的交互物数据.
            _InitInterActorData();
            
            // Roll门相关数据
            rollDoorTimes = arg.RollDoorTimes;

            // TODO: 后面会给门单独写个模块，把这个移过去
            Battle.Instance.actorMgr.GetInterActorConfigCountByTag(RogueInterActorTag.Door, doorConfigs);
            
            rogueEntriesLibrary.Init(arg.EntryLibraryData, BattleRandom.instance);
            //初始化之前关卡积累到的词条奖励。(读取最新配置)
            _GetAllEntryRewardDatas(_entriesRewardList);
            _InitRogueEntryReward();

            //抽中过的词条不再被抽到
            //TODO,性能优化
            rogueEntriesLibrary.SetRogueEntriesActive(entry => TryGetRogueEntry(entry.ID, out var _), false);
            rogueEntriesLibrary.PrintDebugLog();
            Battle.Instance.eventMgr.AddListener<EventCreateBeforeBornStep>(EventType.OnActorCreateBeforeBornStep, _OnActorCreateBeforeBornStep, "RogueGameplay._OnActorCreateBeforeBornStep");
            base.OnAwake();
        }
		
        protected override void OnDestroy()
        {
            base.OnDestroy();
            doorDatas.Clear();
            selectDoorData = null;
            historyTrophyDatas.Clear();
            interActorDatas.Clear();
            doors.Clear();
            rogueEntriesLibrary.OnDestroy();
            Battle.Instance.eventMgr.RemoveListener<EventCreateBeforeBornStep>(EventType.OnActorCreateBeforeBornStep, _OnActorCreateBeforeBornStep);
        }

        public override void OnBattleEnd()
        {
            base.OnBattleEnd();
            
            // TODO 理论应该写在结算协议里的.
            BattleUtil.SaveRogueData();
        }

        /// <summary>
        /// 获取所有词条数据.
        /// </summary>
        /// <param name="outList"></param>
        private void _GetAllEntryRewardDatas(List<RogueEntryRewardData> outList)
        {
            if (outList == null)
            {
                return;
            }
            
            outList.Clear();
            foreach (var trophyData in historyTrophyDatas)
            {
                if (trophyData.Type == RogueRewardType.Entry)
                {
                    outList.Add(trophyData.Data as RogueEntryRewardData);
                }
            }
        }
        
        /// <summary>
        /// 玩家获得一个词条奖励
        /// </summary>
        /// <param name="rogueEntry"></param>
        /// <param name="confirmCallback"></param>
        public bool ObtainRogueEntry(RogueEntry rogueEntry,Action confirmCallback)
        {
            if (rogueEntry == null)
            {
                LogProxy.LogError("获取到空词条！");
                return false;
            }

            LogProxy.Log($"【战斗】【Rogue】玩家获得词条 id= {rogueEntry.ID},level = {rogueEntry.Level}");

            _selectRogueEntryCacheCallback = confirmCallback;

            BattleEnv.LuaBridge.server.SelectRogueEntry(rogueEntry.ID, _selectRogueEntryCallback);
            
            //这里先直接反激活，收到服务器回应前先阻塞。
            rogueEntry.Active = false;
            rogueEntriesLibrary.PrintDebugLog();
            return true;
        }

        public bool TryGetRogueEntry(int id,out RogueEntryRewardData rogueEntryRewardData)
        {
            rogueEntryRewardData = null;
            foreach (var rewardData in _entriesRewardList)
            {
                if (rewardData.ID == id)
                {
                    rogueEntryRewardData = rewardData;
                    return true;
                }
            }
            return false;
        }

        public void RemoveTrophyData(RogueRewardType rogueRewardType, int id)
        {
            foreach (RogueTrophyData rogueTrophyData in historyTrophyDatas)
            {
                if (rogueTrophyData.Type == rogueRewardType && rogueTrophyData.Data.ID == id)
                {
                    historyTrophyDatas.Remove(rogueTrophyData);
                    break;
                }
            }
            
            foreach (RogueTrophyData rogueTrophyData in currentTrophyDatas)
            {
                if (rogueTrophyData.Type == rogueRewardType && rogueTrophyData.Data.ID == id)
                {
                    currentTrophyDatas.Remove(rogueTrophyData);
                    break;
                }
            }
        }

        /// <summary>
        /// 根据条件获取对应的战利品数据.
        /// </summary>
        /// <param name="layer"> 层条件(必填) </param>
        /// <param name="step"> 步骤条件（可选） </param>
        /// /// <param name="index"> 索引（可选） </param>
        /// <param name="rewardType"> 奖励类型（可选） </param>
        /// <param name="outList"> 返回List </param>
        /// <returns></returns>
        public int GetTrophyDataCount(int layer, int? step, int? index, RogueRewardType? rewardType, List<RogueTrophyData> outList)
        {
            if (outList == null)
            {
                return 0;
            }
            
            int count = 0;
            outList.Clear();
            foreach (var trophyData in historyTrophyDatas)
            {
                if (layer != trophyData.LayerID)
                {
                    continue;
                }

                if (step != null && step != trophyData.StepID)
                {
                    continue;
                }

                if (index != null && index != trophyData.Index)
                {
                    continue;
                }
                
                if (rewardType != null && rewardType != trophyData.Type)
                {
                    continue;
                }
                
                outList.Add(trophyData);
                count++;
            }

            return count;
        }

        /// <summary>
        /// 是否最后一层
        /// </summary>
        /// <returns></returns>
        public bool IsLastLayer()
        {
            return this.config.NextID <= 0;
        }
        
        private void _InitTrophyData()
        {
            foreach (var layerData in arg.LayerDatas)
            {
                foreach (var trophyData in layerData.TrophyDatas)
                {
                    this.historyTrophyDatas.Add((RogueTrophyData)trophyData.Clone());
                }
            }
            //调试器可能多次重复当前层
            foreach (var trophyData in arg.CurrentLayerData.TrophyDatas)
            {
                currentTrophyDatas.Add((RogueTrophyData)trophyData.Clone());
            }
        }

        private void _InitInterActorData()
        {
            foreach (var interActorData in arg.CurrentLayerData.InterActorDatas)
            {
                this.interActorDatas.Add((RogueInterActorData)interActorData.Clone());
            }
        }
        
        private void _InitRogueEntryReward()
        {
            //之前的额外抽取参数
            extraEntriesRollParamList = arg.EntryLibraryData.ExtraRewardList;
            
            
            foreach (var rewardData in _entriesRewardList)
            {
                rogueEntriesLibrary.RogueRewardObtain(rewardData);
            }
            
            //按生效优先级排序
            var entriesList = rogueEntriesLibrary.CurrentObtainEntriesList;
            for (int i = 0; i < entriesList.Count-1; i++)
            {
                for (int j = i+1; j < i; j++)
                {

                    if (entriesList[i].ExecutionOrder < entriesList[j].ExecutionOrder)
                    {
                        (entriesList[i], entriesList[j]) = (entriesList[j], entriesList[i]);
                    }
                }
            }

            //预先存好
            foreach (var rogueEntry in entriesList)
            {
                var cfg = TbUtil.GetCfg<RogueEntryCfg>(rogueEntry.ID);
                if (cfg.LevelCfgs.TryGetValue(rogueEntry.Level, out var levelCfg))
                {
                    LogProxy.Log($"【Rogue词条抽取】玩家获取到的词条 ID：{rogueEntry.ID}, 生效");
                    foreach (var addAction in levelCfg.AddSkillActions)
                    {
                        switch (addAction.TargetType)
                        {
                            case EntryTargetType.Girl:
                            {
                                _girlEntriesAddSkillIDs.Add((addAction.SkillID,rogueEntry.Level));
                            }
                                break;
                            case EntryTargetType.Boy:
                            {
                                _boyEntriesAddSkillIDs.Add((addAction.SkillID,rogueEntry.Level));
                            }
                                break;
                            case EntryTargetType.Enemy:
                            {
                                _enemyEntriesAddSkillIDs.Add((addAction.SkillID,rogueEntry.Level));
                            }
                                break;
                            case EntryTargetType.Stage:
                            {
                                _stageEntriesAddSkillIDs.Add((addAction.SkillID,rogueEntry.Level));
                            }
                                break;
                            default:
                                throw new ArgumentOutOfRangeException();
                        }
                    }
                    
                    foreach (var addAction in levelCfg.ClearSkillActions)
                    {
                        switch (addAction.TargetType)
                        {
                            case EntryTargetType.Girl:
                            {
                                _girlEntriesRemoveSkillIDs.Add(addAction.SkillID);
                            }
                                break;
                            case EntryTargetType.Boy:
                            {
                                _boyEntriesRemoveSkillIDs.Add(addAction.SkillID);
                            }
                                break;
                            case EntryTargetType.Enemy:
                            {
                                _enemyEntriesRemoveSkillIDs.Add(addAction.SkillID);
                            }
                                break;
                            case EntryTargetType.Stage:
                            {
                                _stageEntriesRemoveSkillIDs.Add(addAction.SkillID);
                            }
                                break;
                            default:
                                throw new ArgumentOutOfRangeException();
                        }
                    }
                }
                else
                {
                    LogProxy.LogError($"词条{rogueEntry.ID}，等级 rewardData.Level，对应配置缺失！");
                }
            }
        }

        private void _OnActorCreateBeforeBornStep(EventCreateBeforeBornStep eventData)
        {
            if (eventData.bornCfg is RoleBornCfg roleBornCfg)
            {
                //女主相关词条效果
                List<(int skillID,int level)> addSkillList = null;
                List<int> removeSkillList = null;
                if (roleBornCfg.CfgID == battle.config.StageActorID)
                {
                    addSkillList = _stageEntriesAddSkillIDs;
                    removeSkillList = _stageEntriesRemoveSkillIDs;
                }
                else if (roleBornCfg.IsGirl())
                {
                    addSkillList = _girlEntriesAddSkillIDs;
                    removeSkillList = _girlEntriesRemoveSkillIDs;
                }
                else if(roleBornCfg.IsBoy())
                {
                    addSkillList = _boyEntriesAddSkillIDs;
                    removeSkillList = _boyEntriesRemoveSkillIDs;
                }
                else if (BattleUtil.GetFactionRelationShipByType(roleBornCfg.FactionType,FactionType.Hero) == FactionRelationship.Enemy)
                {
                    addSkillList = _enemyEntriesAddSkillIDs;
                    removeSkillList = _enemyEntriesRemoveSkillIDs;
                }

                if (addSkillList != null)
                {
                    foreach (var item in addSkillList)
                    {
                        BattleUtil.AddSkillCfg(roleBornCfg.SkillSlots,item.skillID,SkillSlotType.Passive, SkillSourceType.Rogue,item.level);
                    }
                }
                if (removeSkillList != null)
                {
                    foreach (var skillID in removeSkillList)
                    {
                        BattleUtil.RemoveSkillCfg(roleBornCfg.SkillSlots,skillID,SkillSlotType.Passive);
                    }
                }
            }

        }
        
        public void RollDoor(Action<List<RogueDoorData>> callback)
        {
            _rollDoorCacheCallback = callback;
            BattleUtil.RollCurDoor(_rollDoorCallback);
            //BattleEnv.LuaBridge.server.RollDoor(_rollDoorCallback);
        }

        public void RollEntries(Action callback)
        {
            rogueEntriesLibrary.TagLimit = arg.CurrentLayerData.TrophyParam;
            BattleEnv.LuaBridge.ShowRoguePickEntriesUI(callback);
        }
        
        public void RollEntriesForExtraTimes(Action callback)
        {
            for (int i = 0; i < extraEntriesRollParamList.Count; i++)
            {
                if (!extraEntriesRollParamList[i].hasRolled)
                {
                    rogueEntriesLibrary.TagLimit = extraEntriesRollParamList[i].tagLimit;
                    extraEntriesRollParamList[i].hasRolled = true;
                    BattleEnv.LuaBridge.ShowRoguePickEntriesUI(callback);
                    return;
                }
            }
            LogProxy.LogError("出现非法的额外roll词条操作！");
        }

        private void _RollDoorCallback(List<RogueDoorData> doorDatas)
        {
            if (doorDatas != null && doorDatas.Count > 0)
            {
                foreach (var doorData in doorDatas)
                {
                    this.doorDatas.Add(doorData);
                }
            }
            
            _rollDoorCacheCallback?.Invoke(doorDatas);
            _rollDoorCacheCallback = null;
        }

        public void SelectDoor(int index, Action<int> callback)
        {
            _selectDoorCacheCallback = callback;
            BattleEnv.LuaBridge.server.SelectDoor(index, _selectDoorCallback);
        }

        private void _SelectDoorCallback(int index)
        {
            selectDoorData = doorDatas[index];
            LogProxy.Log($"【战斗】【Rogue】选择了ID={selectDoorData.ID}的门，额外奖励类型={selectDoorData.ExtraRewardType}，额外奖励参数={selectDoorData.ExtraRewardParam}");
            _selectDoorCacheCallback?.Invoke(index);
            _selectDoorCacheCallback = null;
        }

        public void AddTrophyData(RogueRewardType rogueRewardType, int id, int level)
        {
            switch (rogueRewardType)
            {
                case RogueRewardType.Entry:
                    _SelectRogueEntryback(id, level);
                    break;
            }
        }
        
        private void _SelectRogueEntryback(int id, int level)
        {
            LogProxy.Log($"【战斗】【Rogue】玩家通过模拟服务器的回包回调，真正获取词条 id {id},level = {level}");
            //TODO,对象池
            var rogueEntryRewardData = new RogueEntryRewardData { ID = id, Level = level };
            _entriesRewardList.Add(rogueEntryRewardData);
            //存入保存数据
            var rogueTrophyData = new RogueTrophyData
            {
                IsReceive = true,
                Type = RogueRewardType.Entry,
                Data = rogueEntryRewardData
            };
            currentTrophyDatas.Add(rogueTrophyData);
            
            _selectRogueEntryCacheCallback?.Invoke();
            _selectRogueEntryCacheCallback = null;
        }
        
        /// <summary>
        /// 当前剩余额外词条抽取次数
        /// </summary>
        /// <returns></returns>
        public int GetExtraRollEntriesTime()
        {
            int count = 0;
            foreach (var param in extraEntriesRollParamList)
            {
                if (!param.hasRolled)
                {
                    count++;
                }
            }
            return count;
        }

        public void AddExtraRollEntryParam(int id)
        {
            RogueEntriesExtraRollParam rogueEntriesExtraRollParam = new RogueEntriesExtraRollParam
            {
                tagLimit = id,
                hasRolled = false
            };
            extraEntriesRollParamList.Add(rogueEntriesExtraRollParam);
        }

        public void RemoveExtraRollEntryParam(RogueEntriesExtraRollParam rogueEntriesExtraRollParam)
        {
            if (rogueEntriesExtraRollParam.hasRolled)
            {
                return;
            }

            foreach (RogueEntriesExtraRollParam curRogueEntriesExtraRollParam in extraEntriesRollParamList)
            {
                if (curRogueEntriesExtraRollParam == rogueEntriesExtraRollParam)
                {
                    extraEntriesRollParamList.Remove(curRogueEntriesExtraRollParam);
                    break;
                }
            }
        }

        public void SaveToRogueArg(RogueArg rogueArg)
        {
            rogueArg.EntryLibraryData.RoundNum = rogueEntriesLibrary.CurrentRound;
            rogueArg.EntryLibraryData.ReRollLeftTimes = rogueEntriesLibrary.RollTimes;
            rogueArg.EntryLibraryData.ExtraRewardList = extraEntriesRollParamList;
        }
    }
}