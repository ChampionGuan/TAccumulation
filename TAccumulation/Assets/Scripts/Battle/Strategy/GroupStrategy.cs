using System;
using System.Collections.Generic;
using Random = UnityEngine.Random;

namespace X3Battle
{
    public partial class GroupStrategy
    {
        public Actor owner;

        private bool _enabled;//怪物数量小于2个，则不工作，如果存在怪物，则清除单位策略数据，并启动该怪物的个体AI
        private bool _paused;
        private int _totalToken;
        private List<ActorStrategy> _actorStrategys = new List<ActorStrategy>(5);
        private List<ActorStrategy> _cachedActorStrategys = new List<ActorStrategy>(2);
        private List<ColdToken> _coldTokens = new List<ColdToken>(10);
        private const float _calculateScoreCd = 0.5f;
        private float _curCalculateScoreTime;
        private int _weightCursor;
        private List<int> _randomIndexPool = new List<int>(10);
        private List<Actor> _cacheMonsters = new List<Actor>(10);

        private List<StrategySector> _strategySectors = new List<StrategySector>(10);
        private Comparison<ActorStrategy> _actorStrategyComparisonByDistance;
        
        private Action<EventActorBase> _actionActorDead;
        private Action<EventChangeLockTarget> _actionChangeLockTarget;

        public bool isRunning => _enabled && !_paused;
        /// <summary>
        /// 真机调试器专用
        /// </summary>
        public List<ActorStrategy> actorStrategys => _actorStrategys;

        public void Awake()
        {
            _actionActorDead = _OnActorDead;
            _actionChangeLockTarget = _OnChangeLockTarget;
            _curCalculateScoreTime = 0;
            if (owner == owner.battle.player)
            {
                _totalToken = TbUtil.battleConsts.LockPlayerToken;
            }
            else
            {
                _totalToken = TbUtil.battleConsts.LockOtherToken;
            }
            _totalToken += BattleUtil.GetAggressiveToken();
            
            _innerCircleMax = TbUtil.battleConsts.StrategyInnerCircleMax;
            _innerRadius = TbUtil.battleConsts.StrategyCircle[0];
            _middleRadius = TbUtil.battleConsts.StrategyCircle[1];
            _outerRadius = TbUtil.battleConsts.StrategyCircle[2];
            _innerSqrRadius = _innerRadius * _innerRadius;
            _middleSqrRadius = _middleRadius * _middleRadius;
            _outerSqrRadius = _outerRadius * _outerRadius;
            float innerRandomRadiusOffset = (_middleRadius - _innerRadius) * _randomRadiusRatio;
            _innerRandomDown = _innerRadius + innerRandomRadiusOffset;
            _innerRandomUp = _middleRadius - innerRandomRadiusOffset;
            float outerRandomRadiusOffset = (_outerRadius - _middleRadius) * _randomRadiusRatio;
            _outerRandomDown = _middleRadius + outerRandomRadiusOffset;
            _outerRandomUp = _outerRadius - outerRandomRadiusOffset;
            _downInnerSectorRandomAngle = TbUtil.battleConsts.StrategyInnerAngle[0];
            _upInnerSectorRandomAngle = TbUtil.battleConsts.StrategyInnerAngle[1];
            _downOuterSectorRandomAngle = TbUtil.battleConsts.StrategyOuterAngle[0];
            _upOuterSectorRandomAngle = TbUtil.battleConsts.StrategyOuterAngle[1];
            _sectorMinAngle = TbUtil.battleConsts.StrategyMinSectorAngle;
            _lockChangeAngle = TbUtil.battleConsts.StrategyLockChangeAngle;
            _actorStrategyComparisonByDistance = _SortActorStrategyByDistance;
            _curCalculateMonstersMoveTime = 0;
            _ownerPos = owner.transform.position;
            _AddStrategySectors(StrategyAreaType.InnerCircle, 0, 0);
            _AddStrategySectors(StrategyAreaType.OuterCircle, 0, 0);
            _paused = false;
            
            _cacheMonsters.Clear();
            List<Actor> actors = Battle.Instance.actorMgr.actors;
            int strategyCount = 0;
            foreach (Actor actor in actors)
            {
                if (actor.type != ActorType.Monster || actor.isDead)
                {
                    continue;
                }

                if (actor.GetTarget() == owner)
                {
                    _cacheMonsters.Add(actor);
                    if (actor.aiOwner.isStrategy)
                    {
                        strategyCount++;
                    }
                }
            }
            _enabled = strategyCount > 1;
            foreach (Actor monster in _cacheMonsters)
            {
                _AddActorStrategy(monster);
            }
            Battle.Instance.eventMgr.AddListener(EventType.ActorDead, _actionActorDead, "GroupStrategy._OnActor()");
            Battle.Instance.eventMgr.AddListener(EventType.ChangeLockTarget, _actionChangeLockTarget, "GroupStrategy._OnChangeLockTarget()");
        }

        /// <summary>
        /// 添加冷却Token对象
        /// </summary>
        /// <param name="token"></param>
        /// <param name="coldSecond"></param>
        public void AddColdToken(int token, float coldSecond)
        {
            ColdToken coldToken = ObjectPoolUtility.ColdToken.Get();
            coldToken.token = token;
            coldToken.coldSecond = coldSecond;
            _coldTokens.Add(coldToken);
        }

        public void Pause(bool paused)
        {
            if (paused == _paused)
            {
                return;
            }
            bool curIsRunning = isRunning;
            _paused = paused;
            if (curIsRunning == isRunning)
            {
                return;
            }
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                actorStrategy.ResetToNegative();
            }
        }
        
        /// <summary>
        /// 移除冷却Token对象
        /// </summary>
        /// <param name="coldToken"></param>
        private void _RemoveColdToken(ColdToken coldToken)
        {
            PlusToken(coldToken.token);
            ObjectPoolUtility.ColdToken.Release(coldToken);
            _coldTokens.Remove(coldToken);
        }
        
        /// <summary>
        /// 添加个体策略对象
        /// </summary>
        /// <param name="monster"></param>
        private void _AddActorStrategy(Actor monster)
        {
            if (!monster.monsterCfg.IsStrategy)
            {
                return;
            }
            ActorStrategy actorStrategy = _FindActorStrategy(monster);
            if (actorStrategy != null)
            {
                return;
            }

            foreach (ActorStrategy cachedActorStrategy in _cachedActorStrategys)
            {
                if (cachedActorStrategy.owner == monster)
                {
                    cachedActorStrategy.insId = monster.insID;
                    cachedActorStrategy.isAdded = true;
                    return;
                }
            }
            
            actorStrategy = ObjectPoolUtility.ActorStrategy.Get();
            actorStrategy.owner = monster;
            actorStrategy.insId = monster.insID;
            actorStrategy.groupStrategy = this;
            actorStrategy.isAdded = true;
            _cachedActorStrategys.Add(actorStrategy);
        }
        
        /// <summary>
        /// 移除个体策略对象
        /// </summary>
        /// <param name="monster"></param>
        private void _RemoveActorStrategy(Actor monster)
        {
            ActorStrategy actorStrategy = _FindActorStrategy(monster);
            if (actorStrategy == null || _cachedActorStrategys.Contains(actorStrategy))
            {
                return;
            }
            actorStrategy.isAdded = false;
            _cachedActorStrategys.Add(actorStrategy);
        }

        private void _InnerAddOrRemoveActorStrategy(ActorStrategy actorStrategy)
        {
            bool isAdded = actorStrategy.isAdded;
            if (actorStrategy.isAdded)
            {
                if (actorStrategy.owner.insID != actorStrategy.insId || actorStrategy.owner.isDead || actorStrategy.owner.targetSelector.GetTarget() != owner)
                {
                    actorStrategy.owner = null;
                    actorStrategy.groupStrategy = null;
                    ObjectPoolUtility.ActorStrategy.Release(actorStrategy);
                    return;
                }
                actorStrategy.Awake();
                _actorStrategys.Add(actorStrategy);
            }
            else
            {
                if (actorStrategy.state != StrategyState.Negative)//非消极状态立即归还Token
                {
                    PlusToken(actorStrategy.aggressiveToken);
                }
                _actorStrategys.Remove(actorStrategy);
                actorStrategy.Destroy();
                ObjectPoolUtility.ActorStrategy.Release(actorStrategy);
            }
            _UpdateRunning();
            _SendDebugEvent(isAdded, actorStrategy);
        }

        public bool UpdateStrategy(Actor monster)
        {
            ActorStrategy actorStrategy = _FindActorStrategy(monster);
            if (actorStrategy == null)
            {
                return false;
            }
            actorStrategy.ResetToNegative();
            _UpdateRunning();
            return true;
        }

        private void _UpdateRunning()
        {
            int strategyCount = 0;
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                if (actorStrategy.isStrategy)
                {
                    strategyCount++;
                }
            }
            bool curEnabled = strategyCount > 1;
            if (curEnabled == _enabled)
            {
                return;
            }
            bool curIsRunning = isRunning;
            _enabled = curEnabled;
            if (curIsRunning == isRunning)
            {
                return;
            }
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                actorStrategy.ResetToNegative();
            }
        }
        
        /// <summary>
        /// 查找个体策略数据
        /// </summary>
        /// <param name="monster"></param>
        /// <returns></returns>
        private ActorStrategy _FindActorStrategy(Actor monster)
        {
            if (monster == null || monster.type != ActorType.Monster)
            {
                return null;
            }
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                if (actorStrategy.owner == monster)
                {
                    return actorStrategy;
                }
            }
            return null;
        }

        public void Update()
        {
            if (!isRunning && _cachedActorStrategys.Count == 0)
            {
                return;
            }
            _CalculateScore();
            _RecursiveAllocateTokenWithWeight();
            _RecursiveAllocateTokenWithRandom();
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                actorStrategy.Update(owner.deltaTime);
            }
            
            foreach (ColdToken coldToken in _coldTokens)
            {
                if (coldToken.Update(owner.deltaTime))
                {
                    _RemoveColdToken(coldToken);
                    break;
                }
            }

            _curCalculateMonstersMoveTime -= owner.deltaTime;
            if (_curCalculateMonstersMoveTime < 0 || (_ownerPos - owner.transform.position).sqrMagnitude > _ownerPosChangeSqrDistance)//更新计时结束或者锁定目标移动了较大的距离
            {
                _CalculateStrategy();
            }

            foreach (ActorStrategy actorStrategy in _cachedActorStrategys)
            {
                _InnerAddOrRemoveActorStrategy(actorStrategy);
            }
            _cachedActorStrategys.Clear();
        }

        public void PlusToken(int token)
        {
            _totalToken += token;
        }

        public void MinusToken(int token)
        {
            _totalToken -= token;
        }
        
        /// <summary>
        /// 按指定CD 计算评分
        /// </summary>
        private void _CalculateScore()
        {
            _curCalculateScoreTime -= owner.deltaTime;
            if (_curCalculateScoreTime > 0)
            {
                return;
            }
            if (_totalToken < 0)
            {
                return;
            }
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                actorStrategy.CalculateScore();
            }
            _curCalculateScoreTime = _calculateScoreCd;
        }
        
        /// <summary>
        /// 按权重递归分配Token
        /// </summary>
        private void _RecursiveAllocateTokenWithWeight()
        {
            if (_totalToken <= 0)
            {
                return;
            }
            _weightCursor = 0;
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                _weightCursor = actorStrategy.CalculateWeight(_weightCursor);
            }
            if (_weightCursor > 0)
            {
                int randomWeight = Random.Range(0, _weightCursor + 1);
                foreach (ActorStrategy actorStrategy in _actorStrategys)
                {
                    if (actorStrategy.TryWillAggressive(randomWeight))
                    {
                        break;
                    }
                }
                _RecursiveAllocateTokenWithWeight();
            }
        }
        
        /// <summary>
        /// 按随机递归分配Token
        /// </summary>
        private void _RecursiveAllocateTokenWithRandom()
        {
            if (_totalToken <= 0)
            {
                return;
            }
            _randomIndexPool.Clear();
            for (int i = 0; i < _actorStrategys.Count; i++)
            {
                ActorStrategy actorStrategy = _actorStrategys[i];
                if (!actorStrategy.strategyIsWork)
                {
                    continue;
                }
                _randomIndexPool.Add(i);
            }
            if (_randomIndexPool.Count > 0)
            {
                int randomIndex = Random.Range(0, _randomIndexPool.Count);
                _actorStrategys[_randomIndexPool[randomIndex]].TryWillAggressive();
                _RecursiveAllocateTokenWithRandom();
            }
        }

        private void _OnActorDead(EventActorBase eventActor)
        {
            //怪物死亡移除数据
            _RemoveActorStrategy(eventActor.actor);
        }
        
        /// <summary>
        /// 锁定目标变化
        /// </summary>
        /// <param name="changeLockTarget"></param>
        private void _OnChangeLockTarget(EventChangeLockTarget changeLockTarget)
        {
            if (changeLockTarget.actor.type != ActorType.Monster)
            {
                return;
            }

            if (changeLockTarget.target == owner)
            {
                _AddActorStrategy(changeLockTarget.actor);
            }
            else
            {
                _RemoveActorStrategy(changeLockTarget.actor);
            }
        }
        
        private void _SendDebugEvent(bool isAdd, ActorStrategy actorStrategy)
        {
            if(!BattleEnv.InDebugging) return;
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugActorStrategyChange>();
            eventData.Init(isAdd, actorStrategy);
            Battle.Instance.eventMgr.Dispatch(EventType.DebugActorStrategyChange, eventData);
        }
        
        public void Destroy()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.ActorDead, _actionActorDead);
            Battle.Instance.eventMgr.RemoveListener(EventType.ChangeLockTarget, _actionChangeLockTarget);
            owner = null;
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                actorStrategy.Destroy();
                ObjectPoolUtility.ActorStrategy.Release(actorStrategy);
            }
            _actorStrategys.Clear();
            
            foreach (ActorStrategy actorStrategy in _cachedActorStrategys)
            {
                actorStrategy.Destroy();
                ObjectPoolUtility.ActorStrategy.Release(actorStrategy);
            }
            _cachedActorStrategys.Clear();
            
            foreach (ColdToken coldToken in _coldTokens)
            {
                ObjectPoolUtility.ColdToken.Release(coldToken);
            }
            _coldTokens.Clear();
            _randomIndexPool.Clear();
            
            foreach (StrategySector strategySector in _strategySectors)
            {
                ObjectPoolUtility.StrategySector.Release(strategySector);
            }
            _strategySectors.Clear();
            _cacheMonsters.Clear();
        }
    }
    
    public enum StrategyState
    {
        Aggressive,//积极
        Negative,//消极
        WillAggressive,//即将积极
    }

    public enum StrategyAreaType
    {
        InnerCircleIn = 0,
        InnerCircle,
        OuterCircle,
        OuterCircleOut,
    }
}