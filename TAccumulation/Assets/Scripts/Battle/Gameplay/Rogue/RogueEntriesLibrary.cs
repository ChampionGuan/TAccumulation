using System;
using System.Collections.Generic;

using PapeGames.X3;

namespace X3Battle
{
    /// <summary>
    /// 肉鸽玩法 词条库
    /// </summary>
    public class RogueEntriesLibrary
    {
        //随机种子
        private int _randSeed;

        //词条库ID
        private int _id;

        private BattleRandom _random;

        private int _weightSum;

        //当前配置词条库中的词条
        private List<RogueEntry> _entriesList = new List<RogueEntry>(50);

        private List<int> _filteredList = new List<int>(20);

        private List<RogueEntry> _tempRollEntriesList = new List<RogueEntry>(3);

        public int RollTimes { get; private set; }

        public int CurrentRound;

        //当前获取到的词条
        public List<RogueEntry> CurrentObtainEntriesList = new List<RogueEntry>(10);
        
        public int TagLimit = 0;//限制抽取到的词条的tag

        public void Init(RogueEntryLibraryData rogueEntryLibraryData, BattleRandom random)
        {
            _weightSum = 0;
            _id = rogueEntryLibraryData.ID;
            CurrentRound = rogueEntryLibraryData.RoundNum;
            _random = random;
            
            SetRollTimes(rogueEntryLibraryData.ReRollLeftTimes);

            //初始化词库
            RogueEntriesLibraryConfig libraryCfg = TbUtil.GetCfg<RogueEntriesLibraryConfig>(_id);
            if (libraryCfg != null)
            {
                foreach (var entryID in libraryCfg.EntriesID)
                {
                    var rogueEntry = TbUtil.GetCfg<RogueEntryCfg>(entryID);

                    if (rogueEntry != null)
                    {
                        _entriesList.Add(new RogueEntry(rogueEntry));
                    }
                    else
                    {
                        LogProxy.LogError($"词条id {entryID} ,缺少词条相关配置，词条库id {_id}");
                    }
                }
            }
        }

        public void SetRollTimes(int rollTimes)
        {
            RollTimes = rollTimes;
        }

        public void PrintDebugLog()
        {
            #if UNITY_EDITOR
            string logActive = "【Rogue词条抽取】  当前所有已激活词条数据\n";
            string logUnActive = "【Rogue词条抽取】  当前所有未激活词条数据\n";
            foreach (var rogueEntry in _entriesList)
            {
                if (rogueEntry.Active)
                {
                    logActive += $"词条id={rogueEntry.ID},name={rogueEntry.Name},Level={rogueEntry.Level},Quality={rogueEntry.Quality},OriginalPriority={rogueEntry.OriginalPriority} Description={rogueEntry.Description}\n";
                    logActive += $"当前权重值={rogueEntry.GetCurrentPriorityWeight(CurrentRound)},是否满足抽取条件:{rogueEntry.DynamicConditionJudge(CurrentRound,0)} \n";
                }
                else
                {
                    logUnActive += $"词条id={rogueEntry.ID},name={rogueEntry.Name},Level={rogueEntry.Level},Quality={rogueEntry.Quality},OriginalPriority={rogueEntry.OriginalPriority} Description={rogueEntry.Description}\n";
                }
            }
            LogProxy.Log(logActive);
            LogProxy.Log(logUnActive);
            #endif
        }

        public void OnDestroy()
        {
            _entriesList.Clear();
            CurrentObtainEntriesList.Clear();
        }

        public int SetRogueEntriesActive(Func<RogueEntry, bool> filter, bool active)
        {
            if (filter == null)
            {
                LogProxy.LogError($"{_id} 词库设置过滤条件为空！");
                return 0;
            }

            int changeCount = 0;
            foreach (var entry in _entriesList)
            {
                if (filter(entry))
                {
                    entry.Active = active;
                    changeCount++;
                }
            }

            return changeCount;
        }
        
        public void RogueRewardObtain(RogueEntryRewardData rewardData)
        {
            var rogueEntryCfg = TbUtil.GetCfg<RogueEntryCfg>(rewardData.ID);

            if (rogueEntryCfg != null)
            {
                //不重复添加
                if (CurrentObtainEntriesList.FindIndex(x=>x.ID == rewardData.ID)>=0)
                {
                    LogProxy.LogError($"RogueRewardObtain 尝试重复添加词条 {rewardData.ID}");
                    return;
                }
                CurrentObtainEntriesList.Add(new RogueEntry(rogueEntryCfg,rewardData.Level));
            }
        }

        /// <summary>
        /// 刷新重置，重新过滤，会将之前抽取不放回的词条放回
        /// </summary>
        /// <param name="player"></param>
        /// <param name="minQuality"></param>
        private void _RefreshFilteredList(Actor player, EntryQuality minQuality)
        {
            _weightSum = 0;
            //固定的过滤条件
            _filteredList.Clear();
            for (int i = 0; i < _entriesList.Count; i++)
            {
                var entry = _entriesList[i];
                if (!entry.Active || entry.Quality < minQuality)
                {
                    continue;
                }

                if (!entry.DynamicConditionJudge(CurrentRound,TagLimit))
                {
                    continue;
                }

                _filteredList.Add(i);
                _weightSum += _entriesList[i].GetCurrentPriorityWeight(CurrentRound);
            }
        }

        //洗牌
        private void _ShuffleFilteredList()
        {
            // _filteredList = _filteredList.OrderBy((x) => _random.Next()).ToList();
            for (var i = 0; i < _filteredList.Count - 1; i++)
            {
                var index = _random.Next(i, _filteredList.Count);
                (_filteredList[i], _filteredList[index]) = (_filteredList[index], _filteredList[i]);
            }
        }

        /// <summary>
        /// 按权重不放回的随机抽一次词条
        /// </summary>
        /// <returns></returns>
        private RogueEntry _RandomPick(Actor player)
        {
            if (_filteredList.Count <= 0)
            {
                LogProxy.LogError($"词条库中没有可以抽取的词条了！tagLimit = {TagLimit}");
                return null;
            }
            int randomValue = _random.Next(_weightSum);
            for (int i = 0; i < _filteredList.Count; i++)
            {
                var selectEntry = _entriesList[_filteredList[i]];
                if (randomValue < selectEntry.GetCurrentPriorityWeight(CurrentRound))
                {
                    //抽取不放回
                    _weightSum -= selectEntry.GetCurrentPriorityWeight(CurrentRound);
                    _filteredList.RemoveAt(i);
                    return selectEntry;
                }

                randomValue -= selectEntry.GetCurrentPriorityWeight(CurrentRound);
            }

            LogProxy.LogError("按权重抽取算法出错！");
            return null;
        }

        /// <summary>
        /// 抽词条
        /// </summary>
        /// <param name="entriesList"></param>
        /// <param name="player"></param>
        /// <param name="count"></param>
        /// <param name="minRarity"></param>
        /// <returns></returns>
        private void _RollEntries(List<RogueEntry> entriesList, Actor player, int count, EntryQuality minRarity)
        {
            entriesList.Clear();
            //TODO:优化。不用每次都过滤,洗牌
            _RefreshFilteredList(player, minRarity);
            _ShuffleFilteredList();
            //按权重抽N次，抽取不重复，不放回。
            for (int i = 0; i < count; i++)
            {
                var entry = _RandomPick(player);
                if (entry != null)
                {
                    entriesList.Add(entry);
                }
            }
        }

        /// <summary>
        /// 玩家抽取指定个数词条
        /// </summary>
        /// <param name="count"></param>
        /// <param name="minRarity"></param>
        /// <param name="reduceReRollTime"></param>
        /// <returns></returns>
        public List<RogueEntry> RollEntriesForPlayer(int count, bool reduceReRollTime ,EntryQuality minRarity = EntryQuality.Star1)
        {
            if (RollTimes > 0||reduceReRollTime == false)
            {
                _RollEntries(_tempRollEntriesList, Battle.Instance.actorMgr.girl, count, minRarity);
                if (reduceReRollTime) RollTimes--;
            }
            LogProxy.Log($"玩家发起一次随机抽取 {count}个 词条，最低稀有度 {minRarity},剩余随机抽取次数={RollTimes}");
            return _tempRollEntriesList;
        }

        /// <summary>
        /// 确定选中的词条，如果不是调用RollEntriesForPlayer抽到的话，不会成功
        /// </summary>
        /// <param name="selectEntry"></param>
        /// <returns></returns>
        public bool ConfirmSelectEntry(RogueEntry selectEntry, Action confirmCallback)
        {
            if (_tempRollEntriesList.Contains(selectEntry))
            {
                _tempRollEntriesList.Clear();
                //TODO 改为事件
                return Battle.Instance.rogue.ObtainRogueEntry(selectEntry, confirmCallback);
            }

            return false;
        }

        public void AddEntry(RogueEntry entry)
        {
            //不重复添加
            if (CurrentObtainEntriesList.Contains(entry))
            {
                LogProxy.LogError($"尝试重复添加词条 {entry.ID}");
                return;
            }
            CurrentObtainEntriesList.Add(entry);
        }

        public bool RemoveEntry(RogueEntry entry)
        {
            return CurrentObtainEntriesList.Remove(entry);
        }
        
        /// <summary>
        /// 保存当前状态到初始化参数
        /// </summary>
        /// <returns></returns>
        public bool SaveCurrentData(RogueEntryLibraryData rogueEntryLibraryData)
        {
            if (rogueEntryLibraryData == null)
            {
                return false;
            }

            rogueEntryLibraryData.ID = _id;
            rogueEntryLibraryData.RoundNum = CurrentRound;

            rogueEntryLibraryData.ReRollLeftTimes = RollTimes;

            if (_random == null)
            {
                return false;
            }

            return true;
        }
        
    }
}