using UnityEngine;

namespace X3Battle
{
    public class StrategyWander
    {
        public ActorStrategy actorStrategy;
        private bool _isWander;
        private float _wanderSpeed;
        private float _downWanderTime;
        private float _upWanderTime;
        private float _downIdleTime;
        private float _upIdleTime;
        private StrategyWanderState _strategyWanderState;
        private float _wanderTime;
        private float _idleTime;
        private float _rightAngle;
        private float _leftAngle;
        private bool _isWanderRight;

        public void Awake()
        {
            _wanderSpeed = TbUtil.battleConsts.StrategyWanderSpeed;
            _downWanderTime = TbUtil.battleConsts.StrategyWanderTime[0];
            _upWanderTime = TbUtil.battleConsts.StrategyWanderTime[1];
            _downIdleTime = TbUtil.battleConsts.StrategyIdleTime[0];
            _upIdleTime = TbUtil.battleConsts.StrategyIdleTime[1];
            _isWander = false;
            _strategyWanderState = StrategyWanderState.None;
        }

        public void Init(float rightAngle, float leftAngle)
        {
            _rightAngle = rightAngle;
            _leftAngle = leftAngle;
        }

        public void Enter()
        {
            if (!actorStrategy.strategyIsWork || actorStrategy.owner.locomotion == null || actorStrategy.owner.mainState == null)
            {
                return;
            }

            if (_isWander)
            {
                if (actorStrategy.owner.commander.currentCmd is ActorMoveDirCmd)
                {
                    ActorMoveDirCmd oldActorMoveDirCmd = actorStrategy.owner.commander.currentCmd as ActorMoveDirCmd;
                    oldActorMoveDirCmd?.UpdateAngle(_GetAngleOffset());
                }
                return;
            }
            _isWander = true;
            StrategyWanderState strategyWanderState = (StrategyWanderState)Random.Range(1, 3);
            _wanderTime = Random.Range(_downWanderTime, _upWanderTime);
            _idleTime = Random.Range(_downIdleTime, _upIdleTime);
            _isWanderRight = strategyWanderState == StrategyWanderState.Right;
            _Execute(strategyWanderState);
        }

        private float _GetAngleOffset()
        {
            Vector3 lockToMonsterDir = actorStrategy.owner.transform.position - actorStrategy.groupStrategy.owner.transform.position;
            float monsterAngle = StrategyUtil.CalculateAngleByDir(lockToMonsterDir);
            float angleOffset;
            if (_strategyWanderState == StrategyWanderState.Right)
            {
                angleOffset = Mathf.Abs(_rightAngle - monsterAngle);
            }
            else
            {
                angleOffset = Mathf.Abs(_leftAngle - monsterAngle);
            }
            if (angleOffset > 180)
            {
                angleOffset = 360 - angleOffset;
            }
            return angleOffset;
        }

        private void _Execute(StrategyWanderState strategyWanderState)
        {
            _strategyWanderState = strategyWanderState;
            string animName = _strategyWanderState == StrategyWanderState.Right ? MoveWanderAnimName.Right : MoveWanderAnimName.Left;
            ActorMoveDirCmd cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
            cmd.Init(actorStrategy.groupStrategy.owner.insID, MoveType.Wander, animName, _wanderTime, _GetAngleOffset(), _wanderSpeed);
            actorStrategy.owner.commander.TryExecute(cmd);
            PapeGames.X3.LogProxy.Log($"【Strategy】MoveDir:StrategyWander:{animName}|{actorStrategy.owner.insID}|{actorStrategy.groupStrategy.owner.insID}");
        }

        public void Update()
        {
            if (!_isWander)
            {
                return;
            }

            if (_strategyWanderState == StrategyWanderState.Left || _strategyWanderState == StrategyWanderState.Right)
            {
                _wanderTime -= actorStrategy.owner.deltaTime;
                if (_wanderTime < 0)
                {
                    _wanderTime = Random.Range(_downWanderTime, _upWanderTime);
                    _strategyWanderState = StrategyWanderState.Idle;
                    actorStrategy.owner.commander?.ClearMoveCmd();
                    PapeGames.X3.LogProxy.Log($"【Strategy】ClearToIdle:StrategyWander:{actorStrategy.owner.insID}|{actorStrategy.groupStrategy.owner.insID}");
                }
                else if (actorStrategy.owner.commander.currentCmd == null)
                {
                    _wanderTime = Random.Range(_downWanderTime, _upWanderTime);
                    _strategyWanderState = StrategyWanderState.Idle;
                }
            }
            else if (_strategyWanderState == StrategyWanderState.Idle)
            {
                _idleTime -= actorStrategy.owner.deltaTime;
                if (_idleTime < 0)
                {
                    _idleTime = Random.Range(_downIdleTime, _upIdleTime);
                    _isWanderRight = !_isWanderRight;
                    _Execute(_isWanderRight ? StrategyWanderState.Right : StrategyWanderState.Left);
                }
            }
        }
        
        public void Exit()
        {
            _isWander = false;
        }
    }
    
    public enum StrategyWanderState
    {
        None = 0,
        Right,
        Left,
        Idle,
    }
}