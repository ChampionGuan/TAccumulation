using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public abstract class DamageBox: IReset
    {
        protected const float MinPeriod = 1 / 30f;  // 策划定的最低检测间隔暂定1/30毫秒
        protected DamageExporter _damageExporter;
        protected DamageBoxCfg _damageBoxCfg;
        protected HitParamConfig _hitParamConfig;
        protected float _damageProportion; // 伤害分段的权重.{0~1}
        protected float _duration;  // 持续时长
        protected FactionType _faction; // 阵营立场
        protected List<FactionRelationship> _relationShips = new List<FactionRelationship>(10); // 阵营关系
        protected float _period; // 检测周期
        protected float _effectPeriod; // 生效周期 
        protected float _periodCD; // 剩余检测CD
        protected DamageBoxCheckMode _checkMode;  // 检测模式 
        protected int _maxHitTimes;  // 最大hit次数
        protected float _curTime;  // 当前时间
        protected bool _isEnd;  // 是否结束
        protected Battle _battle;
        protected int _frameCount;  // 记录帧号
        protected float _firstDaleyTime;//首次生效延迟事件
        protected float _hitTime;  // 这次Hit的时间

        protected List<Actor> _dynamicExcludeRoles = new List<Actor>(20);  // 动态排除列表
        protected Dictionary<Actor, int> _role2HitTimesDict = new Dictionary<Actor, int>(20);  // 检测对象对应次数字典，period、UnitMultiple模式所用字段模式所用字段（只查询不遍历，不需要用顺序确定性字典） 
        protected Dictionary<Actor, float> _role2TimeDict = new Dictionary<Actor, float>(20);  // 存储每个单位命中时间值，UnitMultiple模式所用字段（只查询不遍历，不需要用顺序确定性字典）
        protected List<Actor> _reuseActors = new List<Actor>(20); // 重复使用用于优化, 每次检测目标都会 new List.
        protected List<CollisionDetectionInfo> _reuseActorCollisionInfo = new List<CollisionDetectionInfo>(20); // 重复使用用于优化, 每次检测目标都会 new List.

        public int InsID { get; private set; }
        public int GroupID { get; private set; }
        public List<Actor> dynamicExcludeRoles => _dynamicExcludeRoles;
        public float damageProportion => _damageProportion;
        public int level { get; private set; }
        public DamageBoxCfg damageBoxCfg => _damageBoxCfg;
        
        // TODO 之后考虑优化成有本地缓存先用本地缓存, 不然都直接查找配置.
        public HitParamConfig hitParamConfig
        {
            get
            {
                if (this._damageExporter.exporterType == DamageExporterType.Buff)
                {
                    return TbUtil.GetHitParamConfig(_hitParamConfig.HitParamID, this._damageExporter.GetLevel(), this._damageExporter.GetLayer());
                }

                return _hitParamConfig;
            }
        }

        /// <summary> 命中目标列表 (不考虑伤害流程里对Tag的过滤.) </summary>
        public List<HitTargetInfo> lastHitTargets { get; private set; } = new List<HitTargetInfo>(30);

        public Action<Actor, bool> OnDamageActor { get; private set; } // 对Actor造成伤害的回调
        private HashSet<Actor> _damagedActors = new HashSet<Actor>();  // 伤害过的角色
        private bool _isAlive;  // 盒子是否活着

        public DamageBox()
        {
            OnDamageActor = _OnDamageActor;
        }
        
        protected void _Init(DamageExporter damageExporter, int id, int groupID, int level, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, List<Actor> excludeSet, float damageProportion,  float? extDuration = null)
        {
            _damageExporter = damageExporter;
            this.InsID = id;
            this.GroupID = groupID;
            this.level = level;
            this._damageBoxCfg = damageBoxCfg;
            if (damageBoxCfg.ShapeBoxInfo?.ShapeInfo != null)
            {
                damageBoxCfg.ShapeBoxInfo.ShapeInfo.SetDebugInfo("【Alt+Z/伤害包围盒/{0}】", damageBoxCfg.ID);
            }
            this._hitParamConfig = hitParamConfig;
            this._damageProportion = damageProportion;
            
            // 持续时长
            this._duration = extDuration == null? damageBoxCfg.Duration : extDuration.Value;

            // 阵营立场
            this._faction = damageBoxCfg.IsOverrideFaction ? damageBoxCfg.OverrodeFaction : damageExporter.actor.factionType;
            
            // 阵营关系
            this._relationShips.Clear();
            if (damageBoxCfg.FactionRelationship != null && damageBoxCfg.FactionRelationship.Length > 0)
            {
                foreach (var relationship in damageBoxCfg.FactionRelationship)
                {
                    this._relationShips.Add(relationship);
                }
            }
            else
            {
                this._relationShips.Add(FactionRelationship.Enemy);
            }
            
            // 检测模式
            this._checkMode = damageBoxCfg.CheckMode;
            this._period = MinPeriod; // 默认设置为最小周期.
            _periodCD = 0f;
            if (damageBoxCfg.CheckMode == DamageBoxCheckMode.PeriodCount)
            {
                this._firstDaleyTime = damageBoxCfg.FirstDelayTime;
                _periodCD = this._firstDaleyTime;
            }

            _hitTime = 0f;
            switch (this._checkMode)
            {
                case DamageBoxCheckMode.Once:
                    break;
                case DamageBoxCheckMode.PeriodCount:
                    this._period = damageBoxCfg.Period < MinPeriod ? MinPeriod : damageBoxCfg.Period;
                    break;
                case DamageBoxCheckMode.ActorCDCount:
                    this._effectPeriod = damageBoxCfg.Period < MinPeriod ? MinPeriod : damageBoxCfg.Period;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            // 最大hit次数
            this._maxHitTimes = damageBoxCfg.BoxMaxHit;
            // 当前时间
            this._curTime = 0;
            // 是否结束
            this._isEnd = false;
            this._battle = this._damageExporter.actor.battle; 
            // 记录帧号
            this._frameCount = this._battle.frameCount;
            
            // 动态的排除列表，命中次数达到上限的进入这个列表
            this._dynamicExcludeRoles.Clear();
            if (excludeSet != null)
            {
                for (int i = 0; i < excludeSet.Count; i++)
                {
                    _dynamicExcludeRoles.Add(excludeSet[i]);
                }
            }

            // 检测对象对应次数字典，period、UnitMultiple模式所用字段模式所用字段（只查询不遍历，不需要用顺序确定性字典）
            this._role2HitTimesDict.Clear();

            // 存储每个单位命中时间值，UnitMultiple模式所用字段（只查询不遍历，不需要用顺序确定性字典）
            this._role2TimeDict.Clear();
            this.lastHitTargets.Clear();
            _damagedActors.Clear();
            _isAlive = true;
        }

        private void _OnDamageActor(Actor target, bool isDamage)
        {
            if (_isAlive && isDamage)
            {
                _damagedActors.Add(target);
            }
        }

        public bool IsDamagedActor(Actor target)
        {
            if (target == null)
            {
                return false;
            }
            return _damagedActors.Contains(target);
        }
        
        public void Update(float deltaTime)
        {
            // 避免同一帧tick两次
            var frameCount = this._battle.frameCount;
            if (frameCount == this._frameCount)
            {
                return;
            }
            this._frameCount = frameCount;
            
            // 更新时间
            this._curTime += deltaTime;

            if (_duration >= 0 && this._curTime >= this._duration)
            {
                this._isEnd = true;
            }

            if (this._isEnd)
            {
                return;
            }
            
            // 需要处理的时间
            _periodCD -= deltaTime;
            while (_periodCD < 0f)
            {
                _hitTime = _curTime + _periodCD;  // 本次Hit的时间点
                this.Evaluate();
                _periodCD += _period;
            }
            
            // TODO 下面代码被上面代码等价替换，观察一段时间，没问题删掉
            // //首次生效延迟处理
            // if (_firstDaleyTime > 0)
            // {
            //     if (_curTime - _firstDaleyTime > 0 && !_isFirstEffect)
            //     {
            //         _isFirstEffect = true;
            //         this.Evaluate();  
            //     }
            // }
            //
            // while (this._curTime - this._firstDaleyTime - this._periodElapsedTime >= this._period)
            // {
            //     this._periodElapsedTime += this._period;
            //     this.Evaluate();   
            // }
        }

        public void TryEvaluate()
        {
            // 刚创建时尝试触发一次
            if (damageBoxCfg.CheckMode == DamageBoxCheckMode.PeriodCount)
            {
                if (_periodCD == 0f)
                {
                    _periodCD = _period;
                    _hitTime = _curTime;
                    Evaluate();                  
                }
            }
            else
            {
                _hitTime = _curTime;
                Evaluate();
            }
        }
        
        public void Evaluate()
        {
            LogProxy.Log("打击盒检查：id = " + damageBoxCfg.ID + " time = " + _curTime);
            if (this._checkMode == DamageBoxCheckMode.Once)
            {
                using (ProfilerDefine.DamageBox_CastDamageBox_Evaluate_Once.Auto())
                {
                    __EvaluateOnceMode();
                }
            }
            else if (this._checkMode == DamageBoxCheckMode.PeriodCount)
            {
                using (ProfilerDefine.DamageBox_CastDamageBox_Evaluate_PeriodCount.Auto())
                {
                    __EvaluatePeriodMode();
                }
            }
            else if (this._checkMode == DamageBoxCheckMode.ActorCDCount)
            {
                using (ProfilerDefine.DamageBox_CastDamageBox_Evaluate_ActorCDCount.Auto())
                {
                    __EvaluateUnitMultiple();
                }
            }
            else
            {
                PapeGames.X3.LogProxy.LogErrorFormat("配置错误：DamageBoxID={0}的盒子检测模式不支持！", this._damageBoxCfg.ID);
                this._isEnd = true;
            }

            // 如果时间为负数，认为一直持续
            if (_duration >= 0)
            {
                if (this._curTime >= this._duration)
                {
                    // 策划持续时长配Fix(0), 检测完这一帧就结束
                    this._isEnd = true;
                } 
            }
        }

        /// <summary>
        ///  单次生效模式：在Box生效期间（Duration持续期间内），凡是触碰到新的目标单位的HurtBox（或其他被动判定Box）则判定为Box命中，进入后续命中流程，单个单位只会被判定一次命中，应用例子：标准近战攻击
        /// </summary>
        /// <returns></returns>
        private List<Actor> __EvaluateOnceMode()
        {
            var targets = _PickDamageBoxTargets(out var actorCollisionInfos);
            if (targets != null)
            {
                // DONE: 单次模式的重复剔除.
                for (int i = targets.Count - 1; i >= 0; i--)
                {
                    var target = targets[i];
                    if (_dynamicExcludeRoles.Contains(target))
                    {
                        targets.RemoveAt(i);
                    }
                }
                
                // DONE: 新一次的伤害目标新增至动态排除列表.
                foreach (var actor in targets)
                {
                    _dynamicExcludeRoles.Add(actor); 
                }
            }

            _ProcessExportDamage(targets, actorCollisionInfos);
            return targets;
        }
        
         /// <summary>
         /// 周期生效模式, 在Box生效期间在Box生效期间（Duration持续期间内），以一定周期检测Box范围内是否触碰到目标单位的HurtBox（或其他被动判定Box）, 只要在AttackBox的周期判定生效时处于Box内，且该单位未达到最大命中次数，则判定为Box命中。应用例子：脉冲/地震等高频率AOE，对所有范围内的单位统一造成伤害
         /// </summary>
         /// <returns></returns>
        private List<Actor> __EvaluatePeriodMode()
        {
            var targets = _PickDamageBoxTargets(out var actorCollisionInfos);
            this._UpdateAndFilterHitTimes(targets);
            _ProcessExportDamage(targets, actorCollisionInfos);
            return targets;
        }
        
         /// <summary>
         /// 位周期判定模式：在Box生效期内，凡是触碰到新的目标单位的（或其他被动判定Box），且该单位未达到最大命中次数，则判定为Box命中，对于同一单位的判定拥有一个CD时间，实际上比较类似Once模式，只是同单位判定有一个最短间隔，如果间隔之后该单位还会被进行命中判定。应用例：激光/龙车
         /// </summary>
         /// <returns></returns>
        private List<Actor> __EvaluateUnitMultiple()
        {
            // 从列表中去除CD时间到了的
            var count = this._dynamicExcludeRoles.Count;
            for (int i = count - 1; i >= 0; i--)
            {
                var role = this._dynamicExcludeRoles[i];
                if (!(_role2HitTimesDict.ContainsKey(role) && _role2HitTimesDict[role] >= _maxHitTimes))
                {
                    // TODO 等价替换，观察一段时间，没问题删掉
                    // if (_role2TimeDict.ContainsKey(role) && _role2TimeDict[role] + this._effectPeriod <= this._periodElapsedTime)
                    // 进入此if分支表示不是因为命中次数满了才进入排除列表中 （下面逻辑，判断因为CD而进入排除列表中)
                    if (_role2TimeDict.ContainsKey(role) && _hitTime - _role2TimeDict[role]  >= _effectPeriod)
                    {
                        // 进入此if分支表示已经有了命中时间记录，并且CD时间到了
                        _dynamicExcludeRoles.RemoveAt(i);
                    }
                }
            }

            var targets = _PickDamageBoxTargets(out var actorCollisionInfos);
            
            // 更新并筛选命中次数
            this._UpdateAndFilterHitTimes(targets);

            // 更新并筛选命中时间
            _UpdateAndFilterHitTime(targets);
            
            _ProcessExportDamage(targets, actorCollisionInfos);
            return targets;
        }

         // 更新角色命中时间，并将其加入排除列表中
         private void _UpdateAndFilterHitTime(List<Actor> targets)
         {
             foreach (var role in targets)
             {
                 this._role2TimeDict[role] = this._hitTime;
                 _dynamicExcludeRoles.Add(role);
             }
         }
         
        /// <summary>
        /// 次数判定，移除次数满的目标，并加入到排除列表中
        /// </summary>
        /// <param name="targets"></param>
        private void _UpdateAndFilterHitTimes(List<Actor> targets)
        {
            if (this._maxHitTimes <= 0)
            {
                return;
            }

            foreach (var role in targets)
            {
                _role2HitTimesDict.TryGetValue(role, out var roleTimes);
                roleTimes += 1;
                if (roleTimes >= this._maxHitTimes)
                {
                    _dynamicExcludeRoles.Add(role);
                }
                this._role2HitTimesDict[role] = roleTimes;
            }
        }

        /// <summary>
        /// 当创建盒子时，初始化命中信息（BoxGroup调用过来）
        /// </summary>
        public void InitHitTimes(Dictionary<Actor, int> hitActorTimesInfo)
        {
            if (hitActorTimesInfo == null || hitActorTimesInfo.Count <= 0)
            {
                return;
            }
            
            // 同步Hit时间
            _hitTime = _curTime;

            if (_checkMode == DamageBoxCheckMode.Once)
            {
                // Once模式直接加入排除列表即可
                foreach (var iter in hitActorTimesInfo)
                {
                    if (!_dynamicExcludeRoles.Contains(iter.Key))
                    {
                        _dynamicExcludeRoles.Add(iter.Key);
                    }
                }
            }
            else
            {
                var list = ObjectPoolUtility.CommonActorList.Get();
                
                // 同步设置命中次数
                foreach (var iter in hitActorTimesInfo)
                {
                    var actor = iter.Key;
                    var hitTimes = iter.Value;
                    
                    _role2HitTimesDict[actor] = hitTimes;
                    if (hitTimes >= this._maxHitTimes)
                    {
                        _dynamicExcludeRoles.Add(actor);
                    }
                    list.Add(actor);
                }
                
                if (_checkMode == DamageBoxCheckMode.PeriodCount)
                {
                    // 周期模式，在剩余(初始delay)和周期之间选较大值
                    _periodCD = Mathf.Max(_periodCD, _period);
                }
                else if (_checkMode == DamageBoxCheckMode.ActorCDCount)
                {
                    // 更新Hit每个Actor的时间， 并加入排除列表中
                    _UpdateAndFilterHitTime(list);
                }
                
                ObjectPoolUtility.CommonActorList.Release(list);
            }
        }
        
        /// <summary>
        /// 当组内其他伤害盒命中了单位时更新信息过来（BoxGroup调用过来）
        /// </summary>
        /// <param name="hitActors"></param>
        public void UpdateHitTimes(List<Actor> hitActors)
        {
            if (hitActors == null || hitActors.Count <= 0)
            {
                return;
            }
            
            // 同步Hit时间
            _hitTime = _curTime;
            
            switch (this._checkMode)
            {
                case DamageBoxCheckMode.Once:
                    _DynamicExcludeActors(hitActors);
                    break;
                case DamageBoxCheckMode.PeriodCount:
                    // 更新CD
                    _periodCD = _period;
                    // 更新ActorHit次数
                    _UpdateAndFilterHitTimes(hitActors);
                    break;
                case DamageBoxCheckMode.ActorCDCount:
                    // 更新Hit每个Actor的时间，并加入排除列表中
                    _UpdateAndFilterHitTime(hitActors);
                    // 更新ActorHit次数
                    _UpdateAndFilterHitTimes(hitActors);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        // 将Actors加入动态排除列表
        private void _DynamicExcludeActors(List<Actor> hitActors)
        {
            for (var i = 0; i < hitActors.Count; i++)
            {
                var hitActor = hitActors[i];
                if (!_dynamicExcludeRoles.Contains(hitActor))
                {
                    _dynamicExcludeRoles.Add(hitActor);
                }
            }
        }

        public int GetCanHitTimes(Actor hitActor)
        {
            int count = 0;
            
            if (_dynamicExcludeRoles.Contains(hitActor))
            {
                return count;
            }
            
            switch (this._checkMode)
            {
                case DamageBoxCheckMode.Once:
                    count = 1;
                    break;
                case DamageBoxCheckMode.PeriodCount:
                case DamageBoxCheckMode.ActorCDCount:
                    if (this._maxHitTimes <= 0)
                    {
                        count = -1;
                    }
                    else
                    {
                        _role2HitTimesDict.TryGetValue(hitActor, out int times);
                        count = this._maxHitTimes - times;
                    }
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
            return count;
        }

        public int GetLimitHitTimes()
        {
            int count = 0;
            switch (this._checkMode)
            {
                case DamageBoxCheckMode.Once:
                    count = 1;
                    break;
                case DamageBoxCheckMode.PeriodCount:
                case DamageBoxCheckMode.ActorCDCount:
                    count = this._maxHitTimes;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
            return count;
        }
        
        /// <summary>
        /// 是否结束
        /// </summary>
        /// <returns></returns>
        public bool IsEnd()
        {
            return this._isEnd;
        }

        public void Destroy()
        {
            OnDestroy();
        }
        
        protected virtual void OnDestroy()
        {
            
        }

        protected abstract List<Actor> _PickDamageBoxTargets(out List<CollisionDetectionInfo> collisionInfos);

        private void _ProcessExportDamage(List<Actor> targets, List<CollisionDetectionInfo> actorCollisionInfos)
        {
            if (targets == null || targets.Count <= 0)
            {
                return;
            }
            
            // DONE: 同步命中次数信息至打击盒组.
            _damageExporter.OnHitActorUpdateTimes(this.GroupID, this.InsID, targets);
            
            // 在这里由子类再次剔除
            var count = targets.Count;
            for (int i = count - 1; i >= 0; i--)
            {
                var actor = targets[i];
                if (_damageExporter.HittingIgnoreActor(actor))
                {
                    targets.RemoveAt(i);
                }
            }
            
            this.lastHitTargets.Clear();
            foreach (var actor in targets)
            {
                var collisionDetectionInfos = ObjectPoolUtility.CollisionInfoListPool.Get();
                foreach (var collisionDetectionInfo in actorCollisionInfos)
                {
                    if (collisionDetectionInfo.hitActor == actor)
                    {
                        collisionDetectionInfos.Add(collisionDetectionInfo);
                    }
                }

                Vector3? hitPos = null;
                var attackStartPoint = this.GetAttackStartPoint();
                if (attackStartPoint != null)
                {
                    var collideDir = GetCollideDir();
                    hitPos = X3Physics.GetClosestPoint(attackStartPoint.Value, collideDir, collisionDetectionInfos);
                }
                var hitTargetInfo = new HitTargetInfo
                {
                    actor = actor,
                    hitPos = hitPos
                };
                this.lastHitTargets.Add(hitTargetInfo);
                ObjectPoolUtility.CollisionInfoListPool.Release(collisionDetectionInfos);
            }
            
            _damageExporter.HitAny(this);
        }

        /// <summary>
        /// 获取攻击起始点.
        /// </summary>
        /// <returns></returns>
        public virtual Vector3? GetAttackStartPoint()
        {
            return null;
        }

        /// <summary>
        /// 获取碰撞朝向
        /// </summary>
        /// <returns></returns>
        public virtual Vector3 GetCollideDir()
        {
            return Vector3.zero;
        }

        public void Reset()
        {
            _isAlive = false;
            
            _OnReset();
        }

        protected virtual void _OnReset()
        {
        }
    }
}