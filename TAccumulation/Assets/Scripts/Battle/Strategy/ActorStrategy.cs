using System;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    public class ActorStrategy
    {
        public Actor owner;
        public int insId;
        public GroupStrategy groupStrategy;
        public StrategyAreaType areaType {get; private set;}
        public Vector3 movePos;
        public Vector3 lockOffset;//移动点相对锁定目标的位置

        public StrategyAreaType curAreaType;
        public StrategyAreaType targetAreaType;
        public int sectorIndex;
        public float sqrDistance;

        public bool isWander;
        public bool isAdded;
        
        private StrategyWander _strategyWander;
        private float _turnAngle;
        private float _runThreshold;

        private  StrategyState _state = StrategyState.Negative;
        private int _typePoint;
        private int _aggressiveToken;
        private int _totalScore;
        private int _upWeight;
        private float _delaySecond;//进入积极的延迟时间
        private float _lifeTime;

        public bool isStrategy => owner.aiOwner != null && owner.aiOwner.isStrategy;
        public bool strategyIsWork => _state == StrategyState.Negative && isStrategy;
        public int aggressiveToken => _aggressiveToken;
        public StrategyState state => _state;
        /// <summary>
        /// 真机调试器专用
        /// </summary>
        public int totalScore => _totalScore;
        
        private Action<EventEndSkill> _actionOnEndSkill;
        
        public ActorStrategy()
        {
            _actionOnEndSkill = _OnEndSkill;
        }
        
        public void Awake()
        {
            if (owner.config.SubType == (int) MonsterType.Boss)
            {
                _typePoint = TbUtil.battleConsts.StrategyTypePoint[0];
            }
            else if (owner.config.SubType == (int) MonsterType.Elite)
            {
                _typePoint = TbUtil.battleConsts.StrategyTypePoint[1];
            }
            else if (owner.config.SubType == (int) MonsterType.Mobs)
            {
                _typePoint = TbUtil.battleConsts.StrategyTypePoint[2];
            }
            else
            {
                _typePoint = TbUtil.battleConsts.StrategyTypePoint[3];
            }
            _aggressiveToken = owner.monsterCfg?.AggressiveToken ?? 0;
            areaType = owner.monsterCfg == null || owner.monsterCfg.IsArcher ? StrategyAreaType.OuterCircle : StrategyAreaType.InnerCircle;
            targetAreaType = areaType;
            lockOffset = Vector3.zero;
            _strategyWander = ObjectPoolUtility.StrategyWander.Get();
            _strategyWander.actorStrategy = this;
            _strategyWander.Awake();
            _turnAngle = TbUtil.battleConsts.StrategyTurnAngle;
            _runThreshold = TbUtil.battleConsts.StrategyRunThreshold;

            lockOffset = Vector3.zero;
            _state = StrategyState.Negative;
            owner.aiOwner?.PauseAI( groupStrategy.isRunning && isStrategy);
            owner.aiOwner?.ChangeStrategyControl(groupStrategy.isRunning && isStrategy);
            Battle.Instance.eventMgr.AddListener(EventType.EndSkill, _actionOnEndSkill, "ActorStrategy._OnEndSkill");
        }        
        /// <summary>
        /// 重置徘徊
        /// </summary>
        public void ResetWander()
        {
            _strategyWander.Exit();
        }
        
        /// <summary>
        /// 进入徘徊
        /// </summary>
        /// <param name="rightAngle"></param>
        /// <param name="leftAngle"></param>
        private void _ExecuteWander(float rightAngle, float leftAngle)
        {
            isWander = true;
            _strategyWander.Init(rightAngle, leftAngle);
            _strategyWander.Enter();
        }
        
        /// <summary>
        /// 执行后退指令
        /// </summary>
        /// <param name="areaType"></param>
        public void ExecuteBack(StrategyAreaType areaType)
        {
            targetAreaType = areaType;
            groupStrategy.PlusSectorRefCountByPos(this, owner.transform.position);
            ActorMoveDirCmd cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
            cmd.Init(groupStrategy.owner.insID, MoveType.Wander, MoveWanderAnimName.Back, float.MaxValue, groupStrategy.GetRandomRadius(targetAreaType));
            owner.commander.TryExecute(cmd);
            PapeGames.X3.LogProxy.Log($"【Strategy】MoveDir:Back:{MoveWanderAnimName.Back}|{owner.insID}|{groupStrategy.owner.insID}");
        }
        
        /// <summary>
        /// 尝试执行移动指令
        /// </summary>
        /// <param name="areaType"></param>
        public void TryExecuteMove(StrategyAreaType areaType)
        {
            targetAreaType = areaType;
            Vector3 lockToMonsterDir = owner.transform.position - groupStrategy.owner.transform.position;
            if (groupStrategy.CalculateMovePos(this, lockToMonsterDir))
            {
                ActorMovePosCmd cmd = ObjectPoolUtility.GetActorCmd<ActorMovePosCmd>();
                cmd.InitByThreshold(movePos, 0.5f, float.MaxValue, _runThreshold, 1, groupStrategy.owner.insID);
                owner.commander.TryExecute(cmd);
                PapeGames.X3.LogProxy.Log($"【Strategy】MovePos:RunOrWalk:{owner.insID}|{groupStrategy.owner.insID}");
            }
        }
        
        /// <summary>
        /// 尝试执行Idle
        /// </summary>
        /// <param name="angleOffsetRatio"></param>
        public void TryExecuteIdle(float angleOffsetRatio)
        {
            Vector3 monsterToLockDir = groupStrategy.owner.transform.position - owner.transform.position;
            Vector3 monsterForward = owner.transform.forward;
            float angle = Vector3.Angle(monsterForward, monsterToLockDir);
            if (angle > _turnAngle)
            {
                ActorMoveDirCmd cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                cmd.Init(groupStrategy.owner.insID, MoveType.Turn);
                owner.commander.TryExecute(cmd);
                PapeGames.X3.LogProxy.Log($"【Strategy】MoveDir:Turn:{MoveType.Turn}|{owner.insID}|{groupStrategy.owner.insID}");
            }
            else
            {
                if (owner.mainState != null && owner.mainState.mainStateType == ActorMainStateType.Idle)
                {
                    StrategySector strategySector = groupStrategy.FindStrategySector(this);
                    float randomAngleOffset = (strategySector.upAngle - strategySector.downAngle) * angleOffsetRatio;
                    float rightAngle = strategySector.downAngle + randomAngleOffset;
                    float leftAngle = strategySector.upAngle - randomAngleOffset;
                    _ExecuteWander(rightAngle, leftAngle);
                }
                else if (IsRunOrWalk() || IsBack())
                {
                    owner.commander?.ClearMoveCmd();
                    PapeGames.X3.LogProxy.Log($"【Strategy】ClearToIdle:Idle:{owner.insID}|{groupStrategy.owner.insID}");
                }
            }
        }

        /// <summary>
        /// 计算评分
        /// </summary>
        public void CalculateScore()
        {
            if (!strategyIsWork)
            {
                return;
            }
            int cameraPoint = Battle.Instance.cameraTrace.IsInSight(owner) ? TbUtil.battleConsts.StrategyCameraPoint[0] : TbUtil.battleConsts.StrategyCameraPoint[1];
            int lockPoint = Battle.Instance.player == null || owner != Battle.Instance.player.GetTarget() ? TbUtil.battleConsts.StrategyLockPoint[1] : TbUtil.battleConsts.StrategyLockPoint[0];
            Transform cameraTrans = Battle.Instance.cameraTrace.GetCameraTransform();
            Vector3 cameraLookAtMonsterDir = owner.transform.position - cameraTrans.position;
            float cameraAngle = Vector3.Angle(cameraLookAtMonsterDir, cameraTrans.forward);
            int cameraAnglePoint = Mathf.RoundToInt((180 - cameraAngle) * TbUtil.battleConsts.StrategyCameraAnglePoint);
            int distancePoint = areaType == StrategyAreaType.InnerCircle ? TbUtil.battleConsts.StrategyNearDistancePoint[(int)curAreaType] : TbUtil.battleConsts.StrategyRemoteDistancePoint[(int)curAreaType];
            int curTotalScore = cameraPoint * lockPoint * cameraAnglePoint * _typePoint * distancePoint;
            if (_totalScore != curTotalScore)
            {
                _totalScore = curTotalScore;
                _SendDebugEvent();
            }
        }
        
        
        /// <summary>
        /// 计算权重上区间
        /// </summary>
        /// <param name="weightCursor"></param>
        /// <returns></returns>
        public int CalculateWeight(int weightCursor)
        {
            if (!strategyIsWork)
            {
                _upWeight = 0;
                return weightCursor;
            }
            weightCursor += _totalScore;
            _upWeight = weightCursor;
            return weightCursor;
        }

        public void Update(float deltaTime)
        {
            if (_state == StrategyState.WillAggressive)
            {
                _delaySecond -= deltaTime;
                if (_delaySecond < 0)
                {
                    _TryGoAggressive();
                }
            }
            else if (_state == StrategyState.Aggressive)
            {
                _lifeTime -= deltaTime;
                //计时器结束时并未发起攻击
                if (_lifeTime < 0 && _TryGoNegative())
                {
                    float coldSecond = Random.Range(TbUtil.battleConsts.AutoExitAggressiveColdSecond[0], TbUtil.battleConsts.AutoExitAggressiveColdSecond[1]);
                    coldSecond *= BattleUtil.GetAggressiveTokenExitSpeedup();
                    groupStrategy.AddColdToken(_aggressiveToken, coldSecond);
                }
            }
            _strategyWander.Update();
        }
        
        //获得消极怪物的位置或者积极怪物的移动点（如果有的话，没有同样取所在位置）
        public Vector3 GetMonsterPos(float sqrRadius)
        {
            if (strategyIsWork ||  owner.locomotion == null || owner.locomotion.isMoveFinish)
            {
                return owner.transform.position;
            }
            Vector3 e = groupStrategy.owner.transform.position - owner.transform.position;
            Vector3 d = (owner.locomotion.movePos - owner.transform.position).normalized;
            float a = Vector3.Dot(e, d);
            float sqrE = e.sqrMagnitude;
            float sqrF = sqrRadius + a * a - sqrE;
            if (sqrF < 0)//移动方向射线不与圆相交
            {
                return owner.locomotion.movePos;
            }
            float t = a - Mathf.Sqrt(sqrF);
            float sqrMoveDistance = (owner.locomotion.movePos - owner.transform.position).sqrMagnitude;
            if (sqrMoveDistance < t * t)//怪物与移动位置的向量不与圆相交
            {
                return owner.locomotion.movePos;
            }
            Vector3 node = owner.transform.position + t * d;
            Vector3 lockToNodeDir = (node - groupStrategy.owner.transform.position).normalized;
            node -= lockToNodeDir * 0.1f;
            return node;
        }

        public bool IsBack()
        {
            return owner.locomotion != null &&
                   (owner.locomotion.moveAnim == MoveWanderAnimName.Back && curAreaType > targetAreaType);
        }
        
        public bool IsRunOrWalk()
        {
            return owner.locomotion != null &&
                   ((owner.locomotion.moveAnim == MoveRunAnimName.Run || owner.locomotion.moveAnim == MoveRunAnimName.Walk) && curAreaType < targetAreaType);
        }
        
        public bool IsWander()
        {
            return owner.locomotion != null &&
                   ((owner.locomotion.moveAnim == MoveWanderAnimName.Left || owner.locomotion.moveAnim == MoveWanderAnimName.Right) && curAreaType == targetAreaType);
        }
        
        /// <summary>
        /// 尝试将要积极态
        /// </summary>
        /// <param name="weight"></param>
        /// <returns></returns>
        public bool TryWillAggressive(int weight)
        {
            if (weight > _upWeight)
            {
                return false;
            }
            return TryWillAggressive();
        }
        
        /// <summary>
        /// 尝试将要积极态
        /// </summary>
        /// <returns></returns>
        public bool TryWillAggressive()
        {
            if (!strategyIsWork)
            {
                return false;
            }
            groupStrategy.MinusToken(_aggressiveToken);
            _state = StrategyState.WillAggressive;
            _delaySecond = Random.Range(TbUtil.battleConsts.EnterAggressiveColdSecond[0], TbUtil.battleConsts.EnterAggressiveColdSecond[1]);
            _SendDebugEvent();
            return true;
        }
        
        /// <summary>
        /// 重置到消极态
        /// </summary>
        public void ResetToNegative()
        {
            if (_state == StrategyState.WillAggressive || _state == StrategyState.Aggressive)//将要积极或者积极状态
            {
                groupStrategy.PlusToken(_aggressiveToken);
            }
            lockOffset = Vector3.zero;
            _state = StrategyState.Negative;
            owner.aiOwner?.PauseAI( groupStrategy.isRunning && isStrategy);
            owner.aiOwner?.ChangeStrategyControl(groupStrategy.isRunning && isStrategy);
            _SendDebugEvent();
        }
        
        /// <summary>
        /// 尝试进入消极态
        /// </summary>
        /// <returns></returns>
        private bool _TryGoNegative()
        {
            if (!groupStrategy.isRunning)
            {
                return false;
            }

            if (_state == StrategyState.Negative)
            {
                return false;
            }
            lockOffset = Vector3.zero;
            _state = StrategyState.Negative;
            owner.aiOwner?.PauseAI(true);
            _SendDebugEvent();
            return true;
        }

        /// <summary>
        /// 尝试进入积极态
        /// </summary>
        private void _TryGoAggressive()
        {
            if (_state == StrategyState.Aggressive)
            {
                return;
            }
            if (_state == StrategyState.Negative)
            {
                groupStrategy.MinusToken(_aggressiveToken);
            }
            owner.commander?.ClearMoveCmd();
            PapeGames.X3.LogProxy.Log($"【Strategy】ClearToIdle:GoAggressive:{owner.insID}|{groupStrategy.owner.insID}");
            _strategyWander.Exit();
            _state = StrategyState.Aggressive;
            _lifeTime = TbUtil.battleConsts.AggressiveMaxSecond;
            owner.aiOwner?.PauseAI(false);
            _SendDebugEvent();
        }

        private void _OnEndSkill(EventEndSkill eventEndSkill)
        {
            if (eventEndSkill.skill.GetCaster() != owner)
            {
                return;
            }
            if (eventEndSkill.skill.config.Type != SkillType.Attack)
            {
                return;
            }
            //攻击技能结束并且行为队列为空
            if (owner.aiOwner != null && owner.aiOwner.ActionGoalsIsEmpty() && _TryGoNegative())
            {
                float coldSecond;
                if (eventEndSkill.endType == SkillEndType.Complete)
                {
                    coldSecond = Random.Range(TbUtil.battleConsts.AttackNormalExitAggressiveColdSecond[0], TbUtil.battleConsts.AttackNormalExitAggressiveColdSecond[1]);
                }
                else
                {
                    coldSecond = Random.Range(TbUtil.battleConsts.AttackAbnormalExitAggressiveColdSecond[0], TbUtil.battleConsts.AttackAbnormalExitAggressiveColdSecond[1]);
                }
                coldSecond *= BattleUtil.GetAggressiveTokenExitSpeedup();
                groupStrategy.AddColdToken(_aggressiveToken, coldSecond);
            }
        }

        public void Destroy()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.EndSkill, _actionOnEndSkill);
            ObjectPoolUtility.StrategyWander.Release(_strategyWander);
            _strategyWander = null;
            _state = StrategyState.Negative;
            owner.aiOwner?.PauseAI(false);
            owner = null;
            groupStrategy = null;
        }
        
        private void _SendDebugEvent()
        {
            if(!BattleEnv.InDebugging) return;
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugActorStrategyDataChange>();
            eventData.Init(this);
            Battle.Instance.eventMgr.Dispatch(EventType.DebugActorStrategyDataChange, eventData);
        }
    }
}