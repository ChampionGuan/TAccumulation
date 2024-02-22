using System;
using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{

    /// <summary>
    /// 肉鸽玩法词条
    /// </summary>
    public class RogueEntry
    {
        private readonly RogueEntryCfg _config;
        
        public bool Active { get; set; }
        public int Level { get; set; }
        public int ID => _config.ID;
        public EntryQuality Quality => _config.Quality;

        public int OriginalPriority => _OriginalPriority;

        private int _OriginalPriority = 0;

        public string Description => _config.Description;

        public int ExecutionOrder => _config.ExecutionOrder;

        public string Name => _config.Name;

        public List<int> Tags => _config.Tags;

#if UNITY_EDITOR
        public bool selected;
#endif
        
        private bool _conditionCheck(int index)
        {
            //策划填的数组下标从1开始
            if (index > _config.Conditions.Count || index <= 0)
            {
                LogProxy.LogError($"RogueEntriesData 条件解析式传入index = {index} 参数错误!");
                return false;
            }

            var conditonCfg = _config.Conditions[index-1];
            switch (conditonCfg.Type)
            {
                case ConditionType.GirlWeapon:
                {
                    //TODO,从关卡那获取
                    if (conditonCfg is EntryConditionGirlWeaponCfg entryConditionGirlWeaponCfg)
                    {
                        foreach (var weaponID in entryConditionGirlWeaponCfg.WeaponIDs)
                        {
                            if (Battle.Instance.arg.girlWeaponID == weaponID)
                            {
                                return true;
                            }
                        }
                    }
                    else
                    {
                        LogProxy.LogError($"数据错误，GirlWeapon条件类型错误！index = {index},ID = {ID}");
                    }
                    return false;
                }
                    break;
                case ConditionType.BoyScore:
                {
                    if (conditonCfg is EntryConditionBoyScoreCfg entryConditionBoyScoreCfg)
                    {
                        foreach (var scoreID in entryConditionBoyScoreCfg.ScoreIDs)
                        {
                            if (Battle.Instance.arg.boyID == scoreID)
                            {
                                return true;
                            }
                        }
                    }
                    else
                    {
                        LogProxy.LogError($"数据错误，BoyScore条件类型错误！index = {index},ID = {ID}");
                    }

                    return false;
                }
                    break;
                case ConditionType.EntryLevel:
                {
                    if (conditonCfg is EntryConditionEntryLevelCfg entryConditionEntryLevelCfg)
                    {
                        foreach (var entryIDLevel in entryConditionEntryLevelCfg.EntryIDLevels)
                        {
                            if (Battle.Instance.rogue.TryGetRogueEntry(entryIDLevel.ID, out var rogueEntryRewardData))
                            {
                                if (rogueEntryRewardData.Level < entryIDLevel.Level)
                                {
                                    return false;
                                }
                            }
                            else
                            {
                                return false;
                            }
                        }
                        return true;
                    }
                    return false;
                }
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        public bool DynamicConditionJudge(int currentRound,int tagLimit)
        {
            if (tagLimit > 0 && !HasTag(tagLimit))
            {
                return false;
            }
            //权重==0也直接过滤掉
            if (GetCurrentPriorityWeight(currentRound) <= 0)
            {
                return false;
            }
            //只有一个条件的时候不用判断逻辑公式
            if (_config.Conditions.Count == 1)
            {
                return _conditionCheck(1);
            }
            return  BattleUtil.CheckEntryCondition(_config.ConditionExpression,_conditionCheck);
        }

        public RogueEntry(RogueEntryCfg cfg,int level = 1)
        {
            _config = cfg;
            Level = level;//TODO 等级
            Active = true;
            _Init();
        }

        private void _Init()
        {
            //策划要求基础权重值可以用excel配置,编辑器也可以配置，excel的配置覆盖编辑器的
            var excelConfig = TbUtil.GetCfg<RogueEntriesConfig>(ID);
            _OriginalPriority = _config.OriginalPriority;
            if (excelConfig == null)
            {
                LogProxy.LogError($"词条 {ID} 对应的 excel配置缺失");
                return;
            }

            if (excelConfig.OriginalPriority > 0)
            {
                _OriginalPriority = excelConfig.OriginalPriority;
            }
        }

        public int GetCurrentPriorityWeight(int currentRound)
        {
            //前置词条权重
            int entryPriority = _OriginalPriority;
            foreach (var preEntry in _config.PreEntryWeights)
            {
                if (Battle.Instance.rogue.TryGetRogueEntry(preEntry.ID, out var entryRewardData))
                {
                    entryPriority += preEntry.Value;
                }
            }
            //轮次权重
            if (currentRound > 0 && currentRound < _config.RoundPriorityWeights.Count)
            {
                entryPriority += _config.RoundPriorityWeights[currentRound];
            }

            if (entryPriority < 0)
            {
                LogProxy.LogError($"词条 {ID} 权重配置出现负数{entryPriority},初始权重配置 {_OriginalPriority}");
                entryPriority = 0;
            }
            
            return entryPriority;
        }

        public bool HasTag(int tag)
        {
            return _config.Tags != null && _config.Tags.Contains(tag);
        }

    }


}