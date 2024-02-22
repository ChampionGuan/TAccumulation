using MessagePack;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 战斗内角色移动都有指令发起、改变和停止
    /// </summary>
    [MessagePackObject]
    public class ActorMoveDirCmd : ActorCmd
    {
        [Key(0)] public int targetActorID = 0;
        [Key(1)] public Vector3 dir;
        [Key(2)] public MoveType moveType;
        [Key(3)] public string moveAnim;
        [Key(4)] public float distanceOrAngle;
        [Key(5)] public float maxTime;
        [Key(6)] public float animSpeed;
        [Key(7)] public bool moveWithoutTarget;
        [Key(8)] public Vector3 targetPos;
        [IgnoreMember] private Actor _targetActor;
        [IgnoreMember] private float _runTime;
        [IgnoreMember] private Vector3 _startDir;
        [IgnoreMember] private float _oldAnimSpeed;
        [IgnoreMember] private bool _isMoveEndWait;
        [IgnoreMember] private Vector3 _targetPos;

        public ActorMoveDirCmd()
        {
        }

        public void Init(Vector3 dir, MoveType moveType = MoveType.Run, string moveAnim = null, float maxTime = float.MaxValue, float animSpeed = 1)
        {
            this.dir = dir;
            this.moveType = moveType;
            this.moveAnim = moveAnim ?? MoveRunAnimName.Run;
            this.maxTime = maxTime;
            this.animSpeed = animSpeed;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="targetActorID"></param>
        /// <param name="moveType"></param>
        /// <param name="moveAnim"></param>
        /// <param name="maxTime"></param>
        /// <param name="distanceOrAngle">moveType为Wander并且moveAnim为非Forward时生效，若moveAnim为Back则表示距离目标的距离，若moveAnim为Right或者Left则表示绕着目标转过的角度</param>
        /// <param name="moveWithoutTarget">没有目标或目标死亡的时候是否继续移动</param>
        public void Init(int targetActorID, MoveType moveType = MoveType.Run, string moveAnim = null, float maxTime = float.MaxValue, float distanceOrAngle = float.MaxValue, float animSpeed = 1,bool moveWithoutTarget = false)
        {
            this.targetActorID = targetActorID;
            this.moveType = moveType;
            this.moveAnim = moveAnim ?? MoveRunAnimName.Run;
            this.maxTime = maxTime;
            this.distanceOrAngle = distanceOrAngle;
            this.animSpeed = animSpeed;
            this.moveWithoutTarget = moveWithoutTarget;
        }
        
        /// <summary>
        /// 
        /// </summary>
        /// <param name="targetActorID"></param>
        /// <param name="moveType"></param>
        /// <param name="moveAnim"></param>
        /// <param name="maxTime"></param>
        /// <param name="distanceOrAngle">moveType为Wander并且moveAnim为非Forward时生效，若moveAnim为Back则表示距离目标的距离，若moveAnim为Right或者Left则表示绕着目标转过的角度</param>
        /// <param name="moveWithoutTarget">没有目标或目标死亡的时候是否继续移动</param>
        public void InitByTargetPos(Vector3 targetPos, MoveType moveType = MoveType.Run, string moveAnim = null, float maxTime = float.MaxValue, float distanceOrAngle = float.MaxValue, float animSpeed = 1)
        {
            this.targetActorID = targetActorID;
            this.moveType = moveType;
            this.moveAnim = moveAnim ?? MoveRunAnimName.Run;
            this.maxTime = maxTime;
            this.distanceOrAngle = distanceOrAngle;
            this.animSpeed = animSpeed;
            this.moveWithoutTarget = true;
            this.targetPos = targetPos;
        }

        public void UpdateAngle(float distanceOrAngle)
        {
            this.distanceOrAngle = distanceOrAngle;
        }

        protected override void _OnReset()
        {
            base._OnReset();
            targetActorID = 0;
            _targetActor = null;
            dir = Vector3.zero;
            distanceOrAngle = 0;
            _isMoveEndWait = false;
            _runTime = 0;
            moveWithoutTarget = false;
            targetPos = Vector3.zero;
        }

        protected override void _OnEnter()
        {
            _runTime = maxTime;
            if (actor.animator != null)
            {
                _oldAnimSpeed = actor.animator.speed;
                actor.animator.speed = animSpeed;
            }
            _targetPos = targetPos;
            if (targetActorID != 0)
            {
                _targetActor = actor.battle.actorMgr.GetActor(targetActorID);
                if (_targetActor == null )
                {
                    if (moveWithoutTarget == false)
                    {
                        Finish();
                        return;
                    }
                }
                else
                {
                    _targetPos = _targetActor.transform.position;
                    actor.moveTarget = _targetActor;
                }
                _startDir = actor.transform.position - _targetPos;

                if(moveType == MoveType.Wander)
                {
                    dir = -_startDir;
                }

                if (_EnterWanderCheckLeftRightSidesHaveSpace(dir)) 
                    _TryMove(true);
            }
            else if (_EnterWanderCheckLeftRightSidesHaveSpace(dir))
            {
                actor.locomotion.CheckWalkRunBlend(ref moveAnim);
                actor.locomotion.MoveDir(dir, moveType, moveAnim, true);
            }
        }

        private void _TryMove(bool isEnterMove)
        {
            if (_targetActor == null && moveWithoutTarget == false)
            {
                return;
            }

            if (_targetActor != null && _targetActor.isDead && moveWithoutTarget == false)
            {
                actor.locomotion.StopMove();
                Finish();
                return;
            }

            var curDir = (_targetPos - actor.transform.position).normalized;
            bool OutDistance = false;
            if (_targetActor != null)
            {
                OutDistance = BattleUtil.CompareActorDistance(distanceOrAngle, _targetActor, actor, true, true,
                    ECompareOperator.GreaterThan);
            }
            else
            {
                float distance = distanceOrAngle + actor.radius;
                OutDistance = distance * distance < (_targetPos - actor.transform.position).sqrMagnitude;
            }
            if (moveType == MoveType.Wander)
            {
                if (moveAnim == MoveWanderAnimName.Back && OutDistance || 
                    (moveAnim == MoveWanderAnimName.Right || moveAnim == MoveWanderAnimName.Left) && Vector3.Angle(_startDir, -curDir) > distanceOrAngle)
                {
                    Finish();
                    return;
                }

                if (!_IsWanderCanMoveOrStop(curDir, isEnterMove))
                {
                    return;
                }
            }
            actor.locomotion.CheckWalkRunBlend(ref moveAnim);
            actor.locomotion.MoveDir(curDir, moveType, moveAnim, isEnterMove);
        }

        private bool _EnterWanderCheckLeftRightSidesHaveSpace(Vector3 targetDir)
        {
            //徘徊，给一个移动时间检测两边是否能移动，不能则原地发呆
            if (moveType != MoveType.Wander) return true;

            var checkTime = TbUtil.battleConsts.WanderCheckArriveTime;
            var wanderDirNor = targetDir.normalized;
            switch (moveAnim)
            {
                case MoveWanderAnimName.Left:
                    if (_IsSideCanArrive(wanderDirNor, -90, checkTime)) return true;
                    if (_IsSideCanArrive(wanderDirNor, 90, checkTime)) return true;
                    actor.locomotion.StopMove();
                    _isMoveEndWait = true;
                    return false;
                case MoveWanderAnimName.Right:
                    if (_IsSideCanArrive(wanderDirNor, 90, checkTime)) return true;
                    if (_IsSideCanArrive(wanderDirNor, -90, checkTime)) return true;
                    actor.locomotion.StopMove();
                    _isMoveEndWait = true;
                    return false;
                default:
                    return true;
            }
        }

        protected override void _OnUpdate()
        {
            _runTime -= actor.battle.deltaTime;

            if (_targetActor != null)
            {
                _targetPos = _targetActor.transform.position;
            }

            switch (moveType)
            {
                case MoveType.Wander:
                    if (_IsWanderCanMoveOrStop(dir, false)) 
                        _TryMove(false);
                    break;
                case MoveType.Turn:
                    if (actor.locomotion.isRotationFinish)
                    {
                        Finish();
                        return;
                    }

                    if (_targetActor == null && moveWithoutTarget == false)
                    {
                        break;
                    }

                    if (_targetActor.isDead && moveWithoutTarget == false)
                    {
                        actor.locomotion.StopMove();
                        Finish();
                        return;
                    }

                    var curDir = (_targetPos - actor.transform.position).normalized;
                    actor.locomotion.MoveDir(curDir, moveType, moveAnim, false);
                    break;
                case MoveType.Run:
                    if (moveWithoutTarget)
                    {
                        var tarDir = (_targetPos - actor.transform.position).normalized;
                        actor.locomotion.MoveDir(tarDir, moveType, moveAnim, false);
                        break;
                    }
                    
                    if (_targetActor != null)
                    {
                        if (_targetActor.isDead)
                        {
                            actor.locomotion.StopMove();
                            Finish();
                            return;
                        }
                        var tarDir = (_targetPos - actor.transform.position).normalized;
                        actor.locomotion.MoveDir(tarDir, moveType, moveAnim, false);
                    }
                    else if (actor.locomotion.isRotationFinish)
                    {
                        Finish();
                        return;
                    }
                    break;
            }

            if (_runTime <= 0)
            {
                Finish(interrupt: true);
                return;
            }
        }

        private bool _IsWanderCanMoveOrStop(Vector3 targetDir, bool isEnterMove)
        {
            //徘徊,移动时间内如果不能到达，换方向
            if (moveType != MoveType.Wander)
            {
                return true;
            }

            if (_isMoveEndWait)
            {
                return false;
            }

            Debug.DrawLine(actor.transform.position, targetDir + actor.transform.position, Color.white);
            var wanderDirNor = targetDir.normalized;
            switch (moveAnim)
            {
                case MoveWanderAnimName.Left:
                    if (_IsSideCanArrive(wanderDirNor, -90, actor.deltaTime)) return true;
                    if (!_IsSideCanArrive(wanderDirNor, 90, actor.deltaTime))
                    {
                        actor.locomotion.StopMove();
                        _isMoveEndWait = true;
                        return false;
                    }
                    else
                    {
                        moveAnim = MoveWanderAnimName.Right;
                        actor.locomotion.MoveDir(dir, moveType, moveAnim, isEnterMove);
                        return false;
                    }
                case MoveWanderAnimName.Right:
                    if (_IsSideCanArrive(wanderDirNor, 90, actor.deltaTime)) return true;
                    if (!_IsSideCanArrive(wanderDirNor, -90, actor.deltaTime))
                    {
                        actor.locomotion.StopMove();
                        _isMoveEndWait = true;
                        return false;
                    }
                    else
                    {
                        moveAnim = MoveWanderAnimName.Left;
                        actor.locomotion.MoveDir(dir, moveType, moveAnim, isEnterMove);
                        return false;
                    }
                default:
                    return true;
            }
        }

        private bool _IsSideCanArrive(Vector3 targetDir, float angle, float moveTime)
        {
            var canArrive = true;
            var startPos = actor.transform.position;
            var endDir = Quaternion.Euler(0, angle, 0) * targetDir;
            var endPos = actor.transform.position + endDir * actor.roleCfg.MoveSpeed * moveTime;
            var shape = actor.modelInfo.characterCtrl;
            if (shape == null)
            {
                PapeGames.X3.LogProxy.LogFormat("[移动指令] 角色:{0}没有找到shape", actor.name);
                return false;
            }

            if (BattleUtil.IsInNavMesh(endPos)) //判断是否在导航内
            {
                var targetIndex = X3Physics.CollisionTestNoGC(endPos, startPos, actor.transform.eulerAngles, shape, true, out var collider, X3LayerMask.ColliderTest);
                for (var i = 0; i < targetIndex; i++)
                {
                    if (collider[i].tag != ColliderTag.AirWall) continue;
                    canArrive = false;
                    break;
                }

                if (canArrive)
                {
                    Debug.DrawLine(startPos, endPos, Color.green);
                }
            }
            else
            {
                canArrive = false;
            }

            if (!canArrive)
                Debug.DrawLine(actor.transform.position, endPos, Color.red, 3f);

            return canArrive;
        }

        protected override void _OnExit(ActorCmd nextCmd)
        {
            if (actor.animator != null)
            {
                actor.animator.speed = _oldAnimSpeed;
            }

            switch (moveType)
            {
                case MoveType.Run:
                    if (!(nextCmd is ActorMoveDirCmd))
                        actor.locomotion.StopMove(false);
                    break;
                case MoveType.Turn:
                    if (actor.locomotion.CanMoveInterrupt() || nextCmd == null) //转身存在打断设定 不能stop
                        actor.locomotion.StopMove(); //策划:转身可以打断转身
                    break;
                default:
                    if (!(nextCmd is ActorMoveDirCmd)) //默认同样指令不打断
                        actor.locomotion.StopMove();
                    break;
            }

            actor.moveTarget = null;
        }

        public override bool CanExecuted()
        {
            return actor.locomotion.CanMoveInterrupt();
        }
    }
}
