using System.Collections.Generic;
using NodeCanvas.Framework.Internal;
using PapeGames.X3;
using ParadoxNotion.Serialization;
using UnityEngine;
using X3Sequence;

namespace X3Battle
{
    public class BSSharedVariables : ISharedVariables
    {
        public ActiveInputCacheData activeInputCache { get; private set; }

        public TransInfoCache transInfoCache { get; private set; }

        public BSBlackboard blackboard { get; private set; }

        public BSSharedVariables(BSCreateData createData)
        {
            activeInputCache = new ActiveInputCacheData();
            transInfoCache = new TransInfoCache();
            blackboard = new BSBlackboard(createData.blackboardData);
        }
        
        // 每次重新play之前都会Reset一下
        public void Reset()
        {
            activeInputCache.Reset();
            transInfoCache.Reset();
            blackboard.Reset();
        }
    }

    public class BSBlackboard
    {
        // 被设置过值的参数（仅限directInput模式参数，blackboard模式依赖蓝图重置）
        private Dictionary<IBSParameter, IBSParameter> _overwriteParameters;
        public BlackboardSource blackboardSource { get; private set; }

        public BSBlackboard(string blackboardData)
        {
            if (!string.IsNullOrEmpty(blackboardData))
            {
                blackboardSource = JSONSerializer.Deserialize<BlackboardSource>(blackboardData);
            }
            _overwriteParameters = new Dictionary<IBSParameter, IBSParameter>(4);
        }
        
        public T GetVariable<T>(IBSParameter parameter)
        {
            _overwriteParameters.TryGetValue(parameter, out var runtimeParameter);
            // TODO 等蓝图支持后这里支持选择多个作用域黑板
            return (runtimeParameter ?? parameter).GetValue<T>(blackboardSource);   
        }

        public void SetVariable<T>(IBSParameter parameter, T value)
        {
            var target = parameter;
            if (!parameter.IsFromBlackboard())
            {
                // 直接输入值的参数，当外部设置值时需要用runtimeParameter存储临时变量
                _overwriteParameters.TryGetValue(parameter, out var runtimeParameter);
                if (runtimeParameter == null)
                {
                    // TODO 这里有GC后面版本优化
                    runtimeParameter = parameter.CreateRuntimeParameter();
                    _overwriteParameters[parameter] = runtimeParameter;
                }
                target = runtimeParameter;
            }
            // TODO 等蓝图支持后这里支持选择多个作用域黑板
            target.SetValue(blackboardSource, value);
        }
        
        public void Reset()
        {
            // TODO 老艾，需要实现一下Reset接口
            blackboardSource?.Reset();
            // 重置变量
            foreach (var iter in _overwriteParameters)
            {
                iter.Value.ResetToOriginal();
            }
        }
    }
        
    public class TransInfoCache
    {
        private Dictionary<int, TransInfo> data;
        
        public TransInfoCache()
        {
            data = new Dictionary<int, TransInfo>();
        }

        public void Record(int id, Vector3 pos, Vector3 forward)
        {
            // TODO GC后面集中优化
            data[id] = new TransInfo(pos, forward);
        }

        public TransInfo TryGetInfo(int id)
        {
            data.TryGetValue(id, out var transInfo);
            return transInfo;
        }

        public void Reset()
        {
            data.Clear();
        }
    }

    public class ActiveInputCacheData
    {
        public struct RecordItem
        {
            public PlayerBtnTypeFlag flag;
            public BtnStateInputFlag stateFlag;
            public float recordTime;
            public float recordEndTime;
        }
        
        private Dictionary<ActionActiveInputCache, RecordItem> _recordTimes;
        
        public ActiveInputCacheData()
        {
            _recordTimes = new Dictionary<ActionActiveInputCache, RecordItem>(5);
        }

        public void Record(ActionActiveInputCache playable, PlayerBtnTypeFlag flag, BtnStateInputFlag stateFlag, float curTime)
        {
            _recordTimes[playable] = new RecordItem()
            {
                flag = flag,
                stateFlag = stateFlag,
                recordTime = curTime,
                recordEndTime = -1.0f
            };
        }

        public void SetEndTime(ActionActiveInputCache playable, float endTime)
        {
            if (_recordTimes.TryGetValue(playable, value: out RecordItem recordItem))
            {
                recordItem.recordEndTime = endTime;
                _recordTimes[playable] = recordItem;
            }
            else
            {
                LogProxy.LogError("输入缓存轨道，没有开始意外结束 playable.name = " + playable.name);
            }
        }

        public void UnRecord(ActionActiveInputCache playable)
        {
            _recordTimes.Remove(playable);
        }
        
        public float GetValidElapseTime(PlayerBtnType type, PlayerBtnStateType stateType, float curTime, float defaultValue = 0)
        {
            float? recordTime = null;
            foreach (var iter in _recordTimes)
            {
                var recordItem = iter.Value;
                if (BattleUtil.ContainPlayerBtnType(recordItem.flag, type) && BattleUtil.ContainBtnStateType(recordItem.stateFlag, stateType))
                {
                    if (recordTime == null || recordTime.Value > recordItem.recordTime)
                    {
                        recordTime = recordItem.recordTime;
                    }    
                }
            }
            var elapseTime = defaultValue;
            if (recordTime != null)
            {
                elapseTime = curTime - recordTime.Value;
            }
            return elapseTime;
        }

        /// <summary>
        /// 判断按钮缓存能否使用
        /// </summary>
        /// <param name="type"></param>
        /// <param name="stateType"></param>
        /// <param name="btnTime"></param>按钮时间
        /// <param name="curTime"></param>当前轨道时间
        /// <returns></returns>
        public bool CanUseBtn(PlayerBtnType type, PlayerBtnStateType stateType, float btnTime, float curTime)
        {
            float? recordTime = null;
            float recordEndTime = 0;
            foreach (var iter in _recordTimes)
            {
                var recordItem = iter.Value;
                if (BattleUtil.ContainPlayerBtnType(recordItem.flag, type) && BattleUtil.ContainBtnStateType(recordItem.stateFlag, stateType))
                {
                    if (recordTime == null || recordTime.Value > recordItem.recordTime)
                    {
                        recordTime = recordItem.recordTime;
                        recordEndTime = recordItem.recordEndTime;
                    }    
                }
            }
            if (recordTime != null)
            {
                //如果输入缓存轨道没有结束 && 按钮输入缓存生效之后 直接能使用
                if (recordEndTime < 0 && btnTime > recordTime)
                {
                    return true;
                }
                
                //如果按钮时间在输入缓存轨道生效时间内
                if (btnTime > recordTime.Value && btnTime < recordEndTime)
                {
                    //当前时间 《 clipEnd时间+ 输入缓存全局时间
                    if (curTime < recordEndTime + TbUtil.battleConsts.ActiveInputCache)
                    {
                        return true;
                    }
                }
                
                //如果按钮时间不在输入缓存轨道生效时间内
                //当前时间 - 按钮时间 <= 输入缓存全局时间 
                if (curTime - btnTime <= TbUtil.battleConsts.ActiveInputCache)
                {
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 判断是否有对应的输入缓存
        /// </summary>
        /// <param name="type"></param>
        /// <param name="stateType"></param>
        /// <returns></returns>
        public bool IsHaveShared(PlayerBtnType type, PlayerBtnStateType stateType)
        {
            foreach (var iter in _recordTimes)
            {
                var recordItem = iter.Value;
                if (BattleUtil.ContainPlayerBtnType(recordItem.flag, type) && BattleUtil.ContainBtnStateType(recordItem.stateFlag, stateType))
                {
                    return true;
                }
            }

            return false;
        }
        public void Reset()
        {
            _recordTimes.Clear();
        }
    }
}