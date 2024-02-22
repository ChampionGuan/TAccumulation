using System.Collections.Generic;
using UnityEngine;

namespace X3Battle.TargetSelect
{
    // TODO 目前策划侧已经弃用不再维护，代码先留着，稳定了再删
    public class ManualSelectMode : SelectModeBase
    {
        /// <summary> 锁定缓存队列 </summary>
        private List<Actor> _lockCache = new List<Actor>();

        /// <summary> 用于对比两个列表的字典 </summary>
        private HashSet<Actor> _lockHashSet = new HashSet<Actor>();

        /// <summary> 是否有锁定缓存队列 </summary>
        private bool _hasLockCache;

        /// <summary> 锁定缓存队列可持续的剩余时间 </summary>
        private float _remainTime;
        
        public bool hasLockCache => _hasLockCache;

        public ManualSelectMode(TargetSelector targetSelector) : base(targetSelector, TargetLockModeType.Manual)
        {
        }

        protected override void _OnStart()
        {
            _actor.eventMgr.AddListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _OnActorEnterDeadState, "ManualSelectMode.OnActorEnterDeadState");
            _SetCurLockTarget(null);
        }

        protected override void _OnStop()
        {
            _actor.eventMgr.RemoveListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _OnActorEnterDeadState);
            _SetCurLockTarget(null);
        }

        protected override void _OnUpdate()
        {
            // DONE: 锁定缓存时间倒计时.
            if (!_hasLockCache)
                return;
            if (_remainTime <= 0f)
            {
                _ClearLockCache();
                return;
            }
            
            _remainTime -= _targetSelector.actor.deltaTime;
        }

        protected override void _OnTryUpdateTarget(TargetSelectorUpdateType type, object _data)
        {
            // 当手动切换目标和技能锁定目标时, 都可以切换目标.
            if (type == TargetSelectorUpdateType.SwitchTarget || (type == TargetSelectorUpdateType.SkillSelectTarget && (_data as SkillSelectData)?.lockChangeType == SkillLockChangeType.Update))
            {
                PapeGames.X3.LogProxy.Log("手动模式, 切换目标");
                // DONE: 1.当前玩家是否有锁定目标
                // 无锁定
                if (!_HasLockTarget())
                {
                    // DONE 2.当前锁定范围内是否还有可锁定的目标.
                    if (!TargetSelectUtil.HasTargetInLockRange(_targetSelector, null))
                    {
                        return;
                    }

                    // DONE: 3.当前是否有摇杆方向输入
                    var hasInputDir = _targetSelector.actor.HasDirInput();
                    // DONE: 4.射程区半径变为R(有方向输入锁定射程)
                    var lockTarget = TargetSelectUtil.GetSmartModeTarget(_targetSelector, false, hasInputDir);
                    // DONE: 5.获取锁定单位
                    this._SetCurLockTarget(lockTarget);
                }
                // 有锁定 (仅当手动切换锁定按钮时, 才切换目标)
                else if (type == TargetSelectorUpdateType.SwitchTarget)
                {
                    // DONE: 2.当前锁定范围内是否还有可锁定的目标.
                    var tempLst = ObjectPoolUtility.CommonActorList.Get();
                    if (!TargetSelectUtil.HasTargetInLockRange(_targetSelector, tempLst))
                    {
                        ObjectPoolUtility.CommonActorList.Release(tempLst);
                        return;
                    }

                    // DONE: 3当前锁定缓存队列是否存在
                    if (this.hasLockCache)
                    {
                        // DONE: 3.1更新缓存队列，并获取队列排序最上方的单位
                        _UpdateLockCache(tempLst);
                    }
                    else
                    {
                        // DONE: 3.2生成锁定缓存队列, 并获取队列排序最上方的单位.
                        _GenLockCache(tempLst);
                    }
                    ObjectPoolUtility.CommonActorList.Release(tempLst);

                    // DONE: 4.获取锁定单位, 获取队列排序最上方的单位.
                    var lockTarget = _lockCache[0];
                    this._SetCurLockTarget(lockTarget);
                }
            }
            else if (type == TargetSelectorUpdateType.CancelLockCache)
            {
                PapeGames.X3.LogProxy.Log("手动模式, 取消缓存队列");
                _ClearLockCache();
            }
        }

        /// <summary>
        /// 生成锁定缓存队列
        /// </summary>
        /// <param name="tempLst"> 潜在可选目标列表 </param>
        private void _GenLockCache(List<Actor> tempLst)
        {
            _lockCache.Clear();
            _lockHashSet.Clear();
            TargetSelectUtil.SortLockCache(tempLst, GetTarget());
            foreach (Actor actor in tempLst)
            {
                _lockCache.Add(actor);
                _lockHashSet.Add(actor);
            }

            _hasLockCache = true;
            _ResetLockCacheTime();
        }

        /// <summary>
        /// 更新锁定缓存队列
        /// </summary>
        /// <param name="tempLst"> 潜在可选目标列表 </param>
        private void _UpdateLockCache(List<Actor> tempLst)
        {
            // DONE: 是否有新增可选目标.
            bool bAdded = false;

            foreach (var actor in tempLst)
            {
                if (!_lockHashSet.Contains(actor))
                {
                    bAdded = true;
                    break;
                }
            }

            // 有 新增可选目标, 则重新生成锁定缓存队列.
            if (bAdded)
            {
                // DONE: 重新生成锁定缓存队列
                _GenLockCache(tempLst);
            }
            // 无
            else
            {
                // DONE: 剔除缓存队列中死亡的目标.
                for (int i = _lockCache.Count - 1; i >= 0; i--)
                {
                    if (_lockCache[i] == null || _lockCache[i].isDead)
                    {
                        _lockCache.RemoveAt(i);
                    }
                }

                // DONE: 将当前【锁定目标】置于队列底部即可.
                var curLockTarget = _lockCache[0];
                _lockCache.RemoveAt(0);
                _lockCache.Add(curLockTarget);
            }

            _ResetLockCacheTime();
        }

        /// <summary> 当前是否有锁定目标 </summary>
        private bool _HasLockTarget()
        {
            return _target != null;
        }

        /// <summary> 重置缓存时间 </summary>
        private void _ResetLockCacheTime()
        {
            PapeGames.X3.LogProxy.Log("重置 锁定缓存队列 时间");
            _remainTime = TbUtil.battleConsts.LockSeqDuration;
        }

        private void _ClearLockCache()
        {
            _lockCache.Clear();
            _lockHashSet.Clear();
            _remainTime = 0f;
            _hasLockCache = false;
            
            // DONE: 清楚当前目标.
            _SetTargetWithEvent(null);
        }

        private void _SetCurLockTarget(Actor curLockTarget)
        {
            if (_target == curLockTarget)
                return;
            
            // DONE: 当前锁定目标为null, 重置缓存队列
            if (curLockTarget == null)
            {
                _ClearLockCache();
                return;
            }
            
            _SetTargetWithEvent(curLockTarget);
            PapeGames.X3.LogProxy.Log($"手动索敌目标切换为 {curLockTarget.insID}");
        }

        private void _OnActorEnterDeadState(EventActorEnterStateBase arg)
        {
            if (arg.actor != this._target)
            {
                return;
            }

            // DONE: 当前锁定的目标死亡.
            _SetCurLockTarget(null);
        }
    }
}