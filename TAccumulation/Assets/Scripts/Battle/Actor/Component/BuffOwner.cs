using System;
using System.Collections.Generic;
using System.Linq;
using BattleCurveAnimator;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;


namespace X3Battle
{
    public partial class BuffOwner : ActorComponent
    {
        private class MatAnimRefData
        {
            public CurveAnimAsset EffectAsset;
            public int RefCount = 0;
        }
        
        private struct FxRefData
        {
            public int fxID;
            public X3Buff buff;
        }
        
        private List<X3Buff> _buffList = new List<X3Buff>();

        private List<X3Buff> _uiBuffs = new List<X3Buff>(3);
        private List<X3Buff> _actionBuffs = new List<X3Buff>();

        /// <summary>
        /// 内部缓存用list
        /// </summary>
        private List<X3Buff> _tempBuffs = new List<X3Buff>();

        /// <summary>
        /// GetBuffs缓存用list
        /// </summary>
        private List<X3Buff> _outTempbuffs = new List<X3Buff>();

        /// <summary>
        /// 为了处理在删除过程中，发送buffchange事件时又添加新的buff
        /// </summary>
        private Queue<X3Buff> _tempMarkDeletebuffs = new Queue<X3Buff>();

        /// <summary>
        /// 处理多个buff使用相同特效的引用计数
        /// </summary>
        public Dictionary<int, int> fxPlayedRefCounts = new Dictionary<int, int>(5);

        /// <summary>
        /// 处理多个材质动画的引用计数，材质动画和特效的需求不太一样，多个相同材质动画action，start的时候要重复start,
        /// stop的时候全部都stop的时候再stop
        /// </summary>
        private Dictionary<string, MatAnimRefData> _materialPlayedRefCounts = new Dictionary<string, MatAnimRefData>(3);

        private Comparison<X3Buff> _comparisonByUI;

        private List<FxRefData> _asyncStopFxs = new List<FxRefData>(3);

        private int _defaultLayerCount = 1;

        //免疫某些指定标签
        private List<int> _immunityTags = new List<int>();

        //是否免疫所有buff，即什么buff都加不上
        private bool _immunityAllBuff = false;

        private List<IBuffAddSection> _buffAddSections = new List<IBuffAddSection>(1);

        public bool ImmunityAllBuff
        {
            get => _immunityAllBuff;
            set => _immunityAllBuff = value;
        }

        private Comparison<IBuff> _sortByBuffTime;

        public BuffOwner() : base(ActorComponentType.Buff)
        {
            _comparisonByUI = SortBuffFun;
            _sortByBuffTime = SortByBuffTime;
        }

        public override void OnBorn()
        {
            // 添加出生时需要添加的buff
            if (null != actor.bornCfg.BuffDatas)
            {
                foreach (var bornBuffData in actor.bornCfg.BuffDatas)
                {
                    Add(bornBuffData.ID, null, null, bornBuffData.Level,actor);
                }
            }
        }

        public override void OnRecycle()
        {
            _tempMarkDeletebuffs.Clear();
            _immunityTags.Clear();
            //真正销毁
            if (_buffList.Count > 0)
            {
                LogProxy.LogError("OnRecycle 时，buff 没有recycle！已知问题");
                RemoveAllBuff();
                //处理特效异步删除
                if (_asyncStopFxs.Count > 0)
                {
                    foreach (var fxRefData in _asyncStopFxs)
                    {
                        if (fxPlayedRefCounts.TryGetValue(fxRefData.fxID, out var count) && count <= 0)
                        {
                            actor.effectPlayer.StopFX(fxRefData.fxID,creator:fxRefData.buff?.caster);
                            fxPlayedRefCounts.Remove(fxRefData.fxID);
                        }
                    }

                    _asyncStopFxs.Clear();
                }

                //真正销毁
                foreach (var buff in _buffList)
                {
                    buff.Recycle();
                }
                _buffList.Clear();
            }

            _buffList.Clear();
            _actionBuffs.Clear();
            _outTempbuffs.Clear();
            _tempBuffs.Clear();
            _uiBuffs.Clear();
            _asyncStopFxs.Clear();
            _materialPlayedRefCounts.Clear();
        }

        public void AddBuffAddSection(IBuffAddSection section)
        {
            _buffAddSections.Add(section);
        }
        
        public void RemoveBuffAddSection(IBuffAddSection section)
        {
            _buffAddSections.Remove(section);
        }

        public override void OnDead()
        {
            base.OnDead();
            RemoveAllBuff();
            //处理特效异步删除
            if (_asyncStopFxs.Count > 0)
            {
                foreach (var fxRefData in _asyncStopFxs)
                {
                    if (fxPlayedRefCounts.TryGetValue(fxRefData.fxID, out var count) && count <= 0)
                    {
                        actor.effectPlayer.StopFX(fxRefData.fxID,creator:fxRefData.buff?.caster);
                        fxPlayedRefCounts.Remove(fxRefData.fxID);
                    }
                }

                _asyncStopFxs.Clear();
            }

            //真正销毁
            foreach (var buff in _buffList)
            {
                buff.Recycle();
            }
            _buffList.Clear();
        }

        protected override void OnUpdate()
        {
            //处理特效异步删除
            if (_asyncStopFxs.Count > 0)
            {
                foreach (var fxRefData in _asyncStopFxs)
                {
                    if (fxPlayedRefCounts.TryGetValue(fxRefData.fxID, out var count) && count <= 0)
                    {
                        actor.effectPlayer.StopFX(fxRefData.fxID,creator:fxRefData.buff?.caster);
                        fxPlayedRefCounts.Remove(fxRefData.fxID);
                    }
                }

                _asyncStopFxs.Clear();
            }

            for (int i = _buffList.Count - 1; i >= 0 && i < _buffList.Count; i--)
            {
                var buff = _buffList[i];
                if (buff.isDestroyed)
                {
                    buff.Recycle();
                    _buffList.RemoveAt(i);
                }
                else
                {
                    buff.Update(actor.deltaTime);
                    if (buff.totalTime > 0 && buff.leftTime < 0)
                    {
                        //这个StackClear字段指，当buff时间到了，只扣除层数并刷新时间
                        if (buff.config.StackClear && buff.layer > 1)
                        {
                            buff.ReduceLayer(1);
                            buff.RefreshTime();
                            if (buff.layer <= 0)
                            {
                                _DestroyBuff(buff,EventBuffChange.DestroyedReason.NormalDestory);
                            }
                        }
                        else
                        {
                            _DestroyBuff(buff,EventBuffChange.DestroyedReason.NormalDestory);
                        }
                    }
                }
            }
        }

        public int UpdateUIBuffDatas()
        {
            _uiBuffs.Clear();
            foreach (var buff in _buffList)
            {
                if (buff == null)
                    continue;

                if (buff.isDestroyed)
                {
                    continue;
                }

                if (buff.config.IconFlag != IconShowType.NotShow &&
                    !string.IsNullOrEmpty(buff.config.BuffIcon))
                {
                    _uiBuffs.Add(buff);
                }
            }
            // _uiBuffs.Sort(_comparisonByUI);
            SortByIconLevel(_uiBuffs);
            return _uiBuffs.Count;
        }
        
        public X3Buff GetUIBuffData(int index)
        {
            if (index < 0 || index >= _uiBuffs.Count)
            {
                PapeGames.X3.LogProxy.LogError($"尝试获取不存在的buffUI信息,index = {index},actor = {actor}");
                return null;
            }
            return _uiBuffs[index];
        }
        
        // TODO 沧澜：建议使用事件通知的方式获取，代替当前的每帧轮询！！
        // public List<X3Buff> GetUIBuffs()
        // {
        //     _uiBuffs.Clear();
        //     foreach (var buff in _buffList)
        //     {
        //         if (buff == null)
        //             continue;
        //
        //         if (buff.isDestroyed)
        //         {
        //             continue;
        //         }
        //
        //         if (buff.config.IconFlag != IconShowType.NotShow && buff.config.IconLevel > 0 &&
        //             !string.IsNullOrEmpty(buff.config.BuffIcon))
        //         {
        //             _uiBuffs.Add(buff);
        //         }
        //     }
        // 
        //     using (ProfilerDefine.BuffsSortPMarker.Auto())
        //     {
        //         _uiBuffs.Sort(_comparisonByUI);
        //     }
        //     return _uiBuffs;
        // }

        public List<X3Buff> GetBuffs()
        {
            _outTempbuffs.Clear();
            foreach (var buff in _buffList)
            {
                if (buff == null)
                    continue;

                if (buff.isDestroyed)
                {
                    continue;
                }

                _outTempbuffs.Add(buff);
            }

            return _outTempbuffs;
        }

        private int SortBuffFun(IBuff buff1, IBuff buff2)
        {
            if (buff1.config.IconLevel > buff2.config.IconLevel)
            {
                return -1;
            }
            else if (buff1.config.IconLevel < buff2.config.IconLevel)
            {
                return 1;
            }

            return 0;
        }

        /// <summary>
        /// 伤害时添加buff
        /// </summary>
        /// <param name="operationID"></param>
        /// <param name="targets">目标</param>
        /// <param name="owner">exporter以及派生类</param>
        public void ExeOperation(int operationID, List<Actor> targets, DamageExporter owner)
        {
        }

        /// <summary>
        /// 削减buff层数, 对于不能堆叠的buff，削减一层就等同于移除
        /// </summary>
        /// <param name="id"></param>
        /// <param name="count"></param>
        public void ReduceStack(int id, int count)
        {
            using (ProfilerDefine.BuffReduceStackPMarker.Auto())
            {
                var buffList = _GetBuffByID(id);
                if (buffList.Count > 1)
                {
                    PapeGames.X3.LogProxy.LogError($"试图减少相互独立存在的buff的层数，buffid = {id}");
                }

                if (buffList.Count == 0)
                {
                    return;
                }

                var buff = buffList[0];
                buff.ReduceLayer(count);
                if (buff.layer <= 0)
                {
                    _DestroyBuff(buff, EventBuffChange.DestroyedReason.Others);
                }
            }
        }

        /// <summary>
        /// 移除buff
        /// </summary>
        /// <param name="buffID">buffID</param>
        public void Remove(int buffID)
        {
            foreach (var buff in _buffList)
            {
                if (buff.config.ID == buffID && !buff.isDestroyed)
                    _tempMarkDeletebuffs.Enqueue(buff);
            }

            while (_tempMarkDeletebuffs.Count > 0)
            {
                _DestroyBuff(_tempMarkDeletebuffs.Dequeue(),EventBuffChange.DestroyedReason.Others);
            }
        }

        /// <summary>
        /// 移除所有负面buff
        /// </summary>
        public void RemoveAllDebuff()
        {
            for (int i = _buffList.Count - 1; i >= 0; i--)
            {
                var buff = _buffList[i];
                if (buff.config.BuffTag == BuffTag.Debuff)
                    _DestroyBuff(_buffList[i],EventBuffChange.DestroyedReason.Others);
            }
        }

        public void RemoveAllBuff()
        {
            //删除buff的时候有可能触发事件再添加buff或删除buff
            for (int i = _buffList.Count - 1; i >= 0; i--)
            {
                _DestroyBuff(_buffList[i],EventBuffChange.DestroyedReason.Others);
            }
        }
        
        private void _DestroyBuff(X3Buff buff,EventBuffChange.DestroyedReason destroyedReason)
        {
            using (ProfilerDefine.BuffDestroyPMarker.Auto())
            {
                if (buff != null)
                {
                    buff.Destroy(destroyedReason);
                }
            }
        }

        /// <summary>
        /// 不同buffstate在添加时的关系逻辑，保证部分状态互斥
        /// </summary>
        /// <param name="buffCfg"></param>
        /// <returns></returns>
        private bool _ConflictControl(BuffCfg buffCfg)
        {
            foreach (var buff in _buffList)
            {
                if (buff.isDestroyed)
                {
                    continue;
                }

                if (TbUtil.TryGetCfg(buff.config.BuffConflictTag, out Dictionary<BuffConflictType, BuffTagConflictConfig> item))
                {
                    if (item.TryGetValue(BuffConflictType.CannnotAdd, out var relationTags))
                    {
                        if (relationTags.Tags != null && relationTags.Tags.Contains(buffCfg.BuffConflictTag))
                        {
                            return false;
                        }
                    }
                }
            }

            //TODO:优化，减少这次遍历
            //新buff确实能加上去后再覆盖
            foreach (var buff in _buffList)
            {
                if (buff.isDestroyed)
                {
                    continue;
                }

                if (TbUtil.TryGetCfg(buff.config.BuffConflictTag, out Dictionary<BuffConflictType, BuffTagConflictConfig> item))
                {
                    if (item.TryGetValue(BuffConflictType.Cover, out var relationTags))
                    {
                        if (relationTags.Tags != null && relationTags.Tags.Contains(buffCfg.BuffConflictTag))
                        {
                            PapeGames.X3.LogProxy.Log($"[BuffOwner.AddBuff]:{buff.ID} Buff因为冲突被新buff {buffCfg.ID}覆盖掉!");
                            _DestroyBuff(buff,EventBuffChange.DestroyedReason.Others);
                        }
                    }
                }
            }

            return true;
        }

        /// <summary>
        /// 策划需要的不需要配置就能直接添加的buffAction效果
        /// </summary>
        /// <param name="action">action效果</param>
        /// <param name="buffTime">buff持续时间，负数是永远存在</param>
        /// <param name="caster">施法者</param>
        public void AddDynamicAcionBuff(BuffActionBase action, float buffTime, Actor caster)
        {
            X3Buff buff = ObjectPoolUtility.X3BuffPool.Get();
            buff.Init(this, X3Buff.sDynamicFixedBuffCfg, buffTime, 1, 1, caster);
            buff.AddDynamicBuffAction(action);
            _buffList.Add(buff);
            buff.OnCreate();
        }

        public void AddDamageBuff(Actor caster, int damageBoxID, float buffTime, X3Vector3 damageBoxAngle)
        {
            X3Buff.sDamageTestBuffCfg.GetLayerData(1).DamageBoxID = damageBoxID;
            X3Buff buff = ObjectPoolUtility.X3BuffPool.Get();
            buff.Init(this, X3Buff.sDamageTestBuffCfg, buffTime, 1, 1, caster);
            buff.SetBuffDamageBox(damageBoxAngle);
            _buffList.Add(buff);
            buff.OnCreate();
        }

        /// </summary>
        /// 添加buff接口
        /// 处理buff冲突关系
        /// </summary>
        /// <param name="buffID"></param>
        /// <param name="layer"></param>  buff的层数
        /// <param name="level"></param>  buff的等级
        /// <param name="time"></param>   buff持续时间（单位：秒）， 若<0或=null采用buff默认时间， 若>=0 采用该时间
        /// <param name="caster"></param> buff释放者, 若为null则默认为自己
        /// <returns> 返回添加buff是否通过了冲突or免疫的处理结果. </returns>
        public bool Add(int buffID, int? layer, float? time, int level, Actor caster, DamageExporter casterExporter = null)
        {
            using (ProfilerDefine.BuffAddPMarker.Auto())
            {
                if (_immunityAllBuff)
                {
                    return false;
                }
                
                if (buffID == 0)
                {
                    return false;
                }
                
                if (caster == null)
                {
                    caster = actor;
                }

                BuffCfg config = TbUtil.GetCfg<BuffCfg>(buffID);

                if (!_JudgeBeforeAdd(config))
                {
                    return false;
                }
                

                if (layer == null || layer <= 0)
                {
                    layer = _defaultLayerCount;
                }

                if (time == null)
                {
                    //遗留的潜规则，目前时间配置全部取一级一层的
                    BuffLevelConfig levelCfg = TbUtil.GetBuffLevelConfig(buffID, 1, (int)1, false);
                    if (levelCfg != null)
                        time = levelCfg.Time;
                    else
                        time = config.Time;
                }

                var buffList = _GetBuffByID(buffID);
                if (buffList.Count == 0 || config.MutexRelation == MutexRelationType.Isolate)
                {
                    CreateBuffByConfig(config, (float)time, (int)level, (int)layer, caster, casterExporter);
                }
                else
                {
                    var buff = buffList[0];
                    if (buffList.Count > 1)
                    {
                        PapeGames.X3.LogProxy.LogError($"出现多个非互相独立的buff！，buffid = {buffID}");
                    }
                    
                    buff.SendBuffAddEvent(false);

                    if (config.MutexRelation == MutexRelationType.ReplaceOldBuff)
                    {
                        // 销毁旧buff, 替换为新的buff
                        buff.Reset((float)time);
                        return true;
                    }

                    buff.OnAddRepeatedly();
                    if (config.MutexRelation == MutexRelationType.NotReplace)
                    {
                        return true;
                    }

                    // 处理刷新
                    if (config.ClearCondition == TimeConditionType.RefreshTime)
                    {
                        buff.RefreshTime();
                    }

                    // 叠加时间
                    if (config.ClearCondition == TimeConditionType.AddTime)
                    {
                        buff.AddExtraTime((float)time);
                    }

                    // 是否增加层数
                    if (config.MultiplyStack)
                    {
                        buff.AddLayer((int)layer);
                    }
                    
                }
                return true;
            }
        }
        public void CreateBuffByConfig(BuffCfg config, float time, int level, int layer = 1, Actor caster = null,DamageExporter damageExporter = null)
        {
            using (ProfilerDefine.BuffsCreateByConfigPMarker.Auto())
            {
                X3Buff buff = ObjectPoolUtility.X3BuffPool.Get();
                buff.Init(this, config, time, level, layer, caster, damageExporter);
                _buffList.Add(buff);
                buff.OnCreate();
                //单位在buff.Init执行过程中收到buff伤害导致死亡，清空_buffList,但这个buff在之后又添加了。这里要再清掉
                if (actor.isDead)
                {
                    RemoveAllBuff();
                }
            }
        }

        private bool _JudgeBeforeAdd(BuffCfg config)
        {
            if (config == null)
            {
                return false;
            }
            
            //不对召唤物生效
            if (actor.IsSummoner() && config.NoToSummon)
            {
                return false;
            }
            
            if (!_ImmunityDetection(config))
            {
                // PapeGames.X3.LogProxy.Log($"[BuffOwner.AddBuff]:{buffID} Buff因为标签免疫无法添加!");
                return false;
            }

            if (!_ConflictControl(config))
            {
                PapeGames.X3.LogProxy.Log($"[BuffOwner.AddBuff]:{config.ID} Buff因为冲突添加失败!");
                return false;
            }

            foreach (var buffAddSection in _buffAddSections)
            {
                if (buffAddSection.InterceptBuffAdd(config))
                {
                    return false;
                }
            }
            
            if (actor.stateTag != null && actor.stateTag.IsActive(ActorStateTagType.DebuffImmunity) && config.BuffTag == BuffTag.Debuff)
            {
                return false;
            }

            return true;
        }

        private void Swap(ref X3Buff buff1, ref X3Buff buff2)
        {
            (buff1, buff2) = (buff2, buff1);
        }
        
        private void SortByBuffTime(List<X3Buff> buffList)
        {
            for (int i = 0; i < buffList.Count-1; i++)
            {
                for (int j = i+1; j < i; j++)
                {
                    var buff1 = buffList[i];
                    var buff2 = buffList[j];
                    if (buff1.leftTime > buff2.leftTime)
                    {
                        Swap(ref buff1,ref buff2);
                    }
                }
            }
        }
        
        private void SortByIconLevel(List<X3Buff> buffList)
        {
            for (int i = 0; i < buffList.Count-1; i++)
            {
                for (int j = i+1; j < i; j++)
                {
                    var buff1 = buffList[i];
                    var buff2 = buffList[j];
                    if (buff1.config.IconLevel < buff2.config.IconLevel)
                    {
                        Swap(ref buff1,ref buff2);
                    }
                }
            }
        }

        public int? GetLayerByID(int id)
        {
            // return _GetBuffByID(id)?[0].layer;
            var buffList = _GetBuffByID(id);
            if (buffList.Count <= 0)
            {
                return null;
            }

            if (buffList.Count > 1)
            {
                PapeGames.X3.LogProxy.LogError($"尝试对互相独立的buff 获取层数！，buffid = {id}");
            }

            //和策划讨论的保底情况，互相独立的buff不会获取层数，直接取第一个
            return buffList[0].layer;
        }

        private List<X3Buff> GetBuffWithAction(BuffAction actionType)
        {
            _actionBuffs.Clear();
            for (int i = 0; i < _buffList.Count; i++)
            {
                if (_buffList[i].HasBuffAction(actionType) && !_buffList[i].isDestroyed)
                    _actionBuffs.Add(_buffList[i]);
            }

            return _actionBuffs;
        }

        public void GetBuffsByID(int id, List<X3Buff> outList)
        {
            var result = _GetBuffByID(id);
            if (outList != null)
            {
                foreach (var buff in result)
                {
                    outList.Add(buff);
                }
            }
        }
        
        private List<X3Buff> _GetBuffByID(int id)
        {
            //后续如果在外部有遍历的操作，需要改成二维数组，防止遍历中修改临时数组
            _tempBuffs.Clear();
            foreach (var buff in _buffList)
            {
                if (buff.config.ID == id && !buff.isDestroyed)
                    _tempBuffs.Add(buff);
            }

            return _tempBuffs;
        }

        // private int _GetBuffIndex(int id)
        // {
        //     for(int i = 0; i < _buffList.Count-1; i ++)
        //     {
        //         if (_buffList[i].config.ID == id && !_buffList[i].isDestroyed)
        //             return i;
        //     }
        //     return -1;
        // }

        public bool HasBuff(int id)
        {
            foreach (var buff in _buffList)
            {
                if (buff.config.ID == id && !buff.isDestroyed)
                    return true;
            }

            return false;
        }

        /// <summary>
        /// 根据剩余时间，升序排序
        /// </summary>
        /// <param name="buff1"></param>
        /// <param name="buff2"></param>
        /// <returns></returns>
        private int SortByBuffTime(IBuff buff1, IBuff buff2)
        {
            if (buff1.leftTime > buff2.leftTime || (buff1.totalTime < 0 && buff2.totalTime > 0))
            {
                return 1;
            }
            else if (buff1.leftTime < buff2.leftTime || (buff1.totalTime > 0 && buff2.totalTime < 0))
            {
                return -1;
            }

            return 0;
        }

        public int FindFirstMatchBuff(BuffType buffType, BuffTag buffTag, int buffMultipleTags,int buffConflictTag,
            bool ignoreBuffType = false, bool ignoreBuffTag = false,bool ignoreBuffMultipleTags = true)
        {
            foreach (var buff in _buffList)
            {
                if (buff.MatchTypeAndTag(buffType, buffTag, buffMultipleTags, buffConflictTag, ignoreBuffType, ignoreBuffTag, ignoreBuffMultipleTags))
                {
                    return buff.ID;
                }
            }
            return 0;
        }

        /// <summary>
        /// 删除所有符合条件的buff
        /// </summary>
        /// <param name="buffType"></param>
        /// <param name="buffTag"></param>
        /// <param name="buffMultipleTags"></param>
        /// <param name="buffConflictTag"></param>
        /// <param name="ignoreBuffType"></param>
        /// <param name="ignoreBuffTag"></param>
        /// <param name="ignoreBuffMultipleTags"></param>
        /// <returns>删除的buff个数</returns>
        public int RemoveAllMatchBuff(BuffType buffType, BuffTag buffTag, int buffMultipleTags,int buffConflictTag,
            bool ignoreBuffType = false, bool ignoreBuffTag = false,bool ignoreBuffMultipleTags = true)
        {
            int removeCount = 0;
            //_buffList在删除过程中不会减少，但是可能会增加在末尾,循环中新增的buff不再遍历
            for (int i = _buffList.Count - 1; i >= 0; i--)
            {
                var buff = _buffList[i];
                if (buff.isDestroyed)
                {
                    continue;
                }
                if ((ignoreBuffType || buff.config.BuffType == buffType) &&
                    (ignoreBuffTag || buff.config.BuffTag == buffTag) &&
                    (ignoreBuffMultipleTags || (buff.config.BuffMultipleTags != null &&
                                                buff.config.BuffMultipleTags.Contains(buffMultipleTags))))
                {
                    if (buffConflictTag == 0 || buffConflictTag == buff.config.BuffConflictTag)
                    {
                        _DestroyBuff(buff,EventBuffChange.DestroyedReason.Others);
                        removeCount++;
                    }
                }
            }

            return removeCount;
        }

        /// <summary>
        /// 统计所有匹配buff的数量
        /// </summary>
        /// <param name="buffType"></param>
        /// <param name="buffTag"></param>
        /// <param name="buffMultipleTags"></param>
        /// <param name="buffConflictTag"></param>
        /// <param name="ignoreBuffType"></param>
        /// <param name="ignoreBuffTag"></param>
        /// <param name="ignoreBuffMultipleTags"></param>
        /// <returns></returns>
        public int GetAllMatchBuffNum(BuffType buffType, BuffTag buffTag, int buffMultipleTags, int buffConflictTag,
            bool ignoreBuffType = false, bool ignoreBuffTag = false, bool ignoreBuffMultipleTags = true)
        {
            int Count = 0;
            foreach (var buff in _buffList)
            {
                if (buff.isDestroyed)
                {
                    continue;
                }
                if ((ignoreBuffType || buff.config.BuffType == buffType) &&
                    (ignoreBuffTag || buff.config.BuffTag == buffTag) &&
                    (ignoreBuffMultipleTags || (buff.config.BuffMultipleTags != null &&
                                                buff.config.BuffMultipleTags.Contains(buffMultipleTags))))
                {
                    if (buffConflictTag == 0 || buffConflictTag == buff.config.BuffConflictTag)
                    {
                        Count++;
                    }
                }
            }

            return Count;
        }

        /// <summary>
        /// 处理多个buff使用同一个特效的情况
        /// </summary>
        /// <param name="fxID"></param>
        public void FxBegin(int fxID, Actor creater)
        {
            
            //buff特效屏蔽
            if (actor.monsterCfg != null && actor.monsterCfg.UnableBuffFX.Length > 0)
            {
                if (actor.monsterCfg.UnableBuffFX[0] == -1 || actor.monsterCfg.UnableBuffFX.Contains(fxID))
                {
                    return;
                }
            }

            if (fxPlayedRefCounts.TryGetValue(fxID, out var refCount))
            {
                fxPlayedRefCounts[fxID] = refCount + 1;
            }
            else
            {
                var fxPlayer = actor.effectPlayer.PlayFx(fxID, creator: creater);
                if (fxPlayer != null)
                {
                    fxPlayer.InitFadeOut();
                }
                else
                {
                    PapeGames.X3.LogProxy.LogError($"[BuffOwner.FxBegin]:{fxID} 播放特效失败，返回空值!");
                }
                fxPlayedRefCounts.Add(fxID, 1);
            }
        }

        /// <summary>
        /// 处理多个buff使用同一个特效的情况
        /// </summary>
        /// <param name="fxID"></param>
        /// <param name="buff"></param>
        public void FxEnd(int fxID,X3Buff buff)
        {
            if (fxPlayedRefCounts.TryGetValue(fxID, out var refCount))
            {
                if (refCount - 1 == 0)
                {
                    //处理覆盖时先删后减
                    // actor.StopFX(fxID);
                    // _fxPlayedRefCounts.Remove(fxID);
                    _asyncStopFxs.Add(new FxRefData{fxID = fxID,buff = buff});
                }

                fxPlayedRefCounts[fxID] = refCount - 1;
            }
            // else
            // {
            //     // PapeGames.X3.LogProxy.LogError($"[BuffOwner.fxEnd]:{fxID} buff尝试结束一个没有在播放的特效!");
            // }
        }

        /// <summary>
        /// 用于统一管理材质动画冲突
        /// </summary>
        /// <param name="matAnimPath"></param>
        /// <returns>是否已经有相同的材质动画在播放了</returns>
        public bool MatAnimBegin(string matAnimPath)
        {
            bool alreadyHas = false;
            if (_materialPlayedRefCounts.TryGetValue(matAnimPath, out var refData))
            {
                refData.RefCount += 1;
                alreadyHas = true;
            }
            else
            {
                refData = new MatAnimRefData();
                refData.RefCount += 1;
                refData.EffectAsset =
                    BattleResMgr.Instance.Load<CurveAnimAsset>(matAnimPath, BattleResType.MatCurveAsset);
                _materialPlayedRefCounts.Add(matAnimPath, refData);
            }

            //这里需要多次play，但stop最后执行一次
            if (actor.model.curveAnimator != null)
            {
                actor.model.curveAnimator.Play(refData.EffectAsset);
            }

            return alreadyHas;
        }

        /// <summary>
        /// 用于统一管理材质动画冲突
        /// </summary>
        /// <param name="matAnimPath"></param>
        /// <returns>是否还有相同的材质动画在播放了</returns>
        public bool MatAnimEnd(string matAnimPath)
        {
            if (_materialPlayedRefCounts.TryGetValue(matAnimPath, out var refData))
            {
                if (refData.RefCount == 1)
                {
                    if (actor.model.curveAnimator != null)
                    {
                        actor.model.curveAnimator.Stop(refData.EffectAsset);
                    }

                    BattleResMgr.Instance.Unload(refData.EffectAsset);
                    _materialPlayedRefCounts.Remove(matAnimPath);
                    return false;
                }

                refData.RefCount -= 1;
                return true;
            }

            PapeGames.X3.LogProxy.LogError($"[BuffOwner.MatAnimEnd]:{matAnimPath} buff尝试结束一个没有在播放的材质特效!");
            return false;
        }

        public void AddImmunityTag(int tag)
        {
            if (_immunityTags.Contains(tag))
            {
                return;
            }

            _immunityTags.Add(tag);
        }

        private bool _ImmunityDetection(BuffCfg cfg)
        {
            if (cfg.BuffMultipleTags == null || cfg.BuffMultipleTags.Count == 0)
            {
                return true;
            }

            foreach (var immunityTag in _immunityTags)
            {
                foreach (var buffTag in cfg.BuffMultipleTags)
                {
                    if (buffTag == immunityTag)
                    {
                        return false;
                    }
                }
            }

            return true;
        }
    }
}