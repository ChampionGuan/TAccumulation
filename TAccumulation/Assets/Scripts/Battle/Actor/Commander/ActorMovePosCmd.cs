using MessagePack;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorMovePosCmd : ActorCmd
    {
        [Key(0)] public int targetActorID = 0;
        [Key(1)] public Vector3 destPos;
        [Key(2)] public float posRadius;
        [Key(3)] public float maxTime;
        [Key(4)] public string moveAnim;
        [Key(5)] public float animSpeed;
        [Key(6)] public int lookAtTargetID;
        [Key(7)] public float moveSpeedThreshold = -1;
        [IgnoreMember] private Actor _targetActor;
        [IgnoreMember] private Actor _lookAtActor;
        [IgnoreMember] private float _runTime;
        [IgnoreMember] private float _oldAnimSpeed;
        [IgnoreMember] private float _walkRunTolerant;

        public ActorMovePosCmd()
        {
            _walkRunTolerant = TbUtil.battleConsts.WalkRunThresholdTolerant;
        }

        /// <summary>
        /// 指定动画移动
        /// </summary>
        /// <param name="pos">移动到的位置点</param>
        /// <param name="radius">位置点范围</param>
        /// <param name="maxTime">最多移动多久</param>
        /// <param name="moveAnim">移动用的动画</param>
        /// <param name="animSpeed"></param>
        /// <param name="lookAtTargetID">移动时看向的目标</param>
        public void Init(Vector3 pos, float radius = 0, float maxTime = float.MaxValue, string moveAnim = null, float animSpeed = 1, int lookAtTargetID = 0)
        {
            this.destPos = pos;
            this.posRadius = radius;
            this.maxTime = maxTime;
            this.moveAnim = moveAnim ?? MoveRunAnimName.Run;
            this.animSpeed = animSpeed;
            this.lookAtTargetID = lookAtTargetID;
        }

        /// <summary>
        /// 走跑阈值移动指令
        /// <param name="threshold">距离小于阈值用walk,大于阈值用run</param>
        /// </summary>
        public void InitByThreshold(Vector3 pos, float radius = 0, float maxTime = float.MaxValue, float threshold = -1f, float animSpeed = 1, int lookAtTargetID = 0)
        {
            this.destPos = pos;
            this.posRadius = radius;
            this.maxTime = maxTime;
            this.moveSpeedThreshold = threshold;
            this.animSpeed = animSpeed;
            this.lookAtTargetID = lookAtTargetID;
        }

        /// <summary>
        /// 指定动画,移动到目标
        /// </summary>
        public void Init(int targetActorID, float radius = 0, float maxTime = float.MaxValue, string moveAnim = null, float animSpeed = 1)
        {
            this.targetActorID = targetActorID;
            this.posRadius = radius;
            this.maxTime = maxTime;
            this.moveAnim = moveAnim ?? MoveRunAnimName.Run;
            this.animSpeed = animSpeed;
        }

        protected override void _OnReset()
        {
            base._OnReset();
            targetActorID = 0;
            destPos = Vector3.zero;
            posRadius = 0;
            moveAnim = "";
            maxTime = float.MaxValue;
            lookAtTargetID = 0;
            moveSpeedThreshold = -1;
            _targetActor = null;
            _lookAtActor = null;
            _runTime = 0;
        }

        protected override void _OnEnter()
        {
            _runTime = maxTime;
            if (actor.animator != null)
            {
                _oldAnimSpeed = actor.animator.speed;
                actor.animator.speed = animSpeed;
            }

            if (targetActorID != 0)
            {
                _targetActor = Battle.Instance.actorMgr.GetActor(targetActorID);
                if (_targetActor == null) return;

                if (_targetActor.isDead)
                {
                    Finish();
                    return;
                }

                actor.moveTarget = _targetActor;
                BattleUtil.CalculateActorsRadius(actor, _targetActor, out float radius1, out float radius2);
                actor.locomotion.CheckWalkRunBlend(ref moveAnim);
                actor.locomotion.MovePos(_targetActor.transform.position, posRadius + radius1 + radius2, true, moveAnim);
            }
            else
            {
                if (lookAtTargetID != 0)
                {
                    _lookAtActor = Battle.Instance.actorMgr.GetActor(lookAtTargetID);
                    if (_lookAtActor != null) actor.moveTarget = _lookAtActor;
                }

                EnterThresholdWalkRun();
                actor.locomotion.CheckWalkRunBlend(ref moveAnim);
                actor.locomotion.MovePos(destPos, posRadius, true, moveAnim);
            }
        }

        protected override void _OnUpdate()
        {
            _runTime -= Battle.Instance.deltaTime;
            float radius1 = 0;
            float radius2 = 0;
            if (_targetActor != null)
            {
                if (_targetActor.isDead)
                {
                    Finish();
                    return;
                }

                destPos = _targetActor.transform.position;
                BattleUtil.CalculateActorsRadius(actor, _targetActor, out radius1, out radius2);
            }

            if (actor.locomotion.isMoveFinish)
            {
                Finish();
                return;
            }

            if (_runTime <= 0)
            {
                Finish(interrupt: true);
                return;
            }

            UpdateThresholdWalkRun();
            actor.locomotion.MovePos(destPos, posRadius + radius1 + radius2, false, moveAnim);

#if UNITY_EDITOR
            Debug.DrawLine(actor.transform.position, destPos, Color.white);
#endif
        }

        protected void EnterThresholdWalkRun()
        {
            if (moveSpeedThreshold < 0) return;

            var distance = destPos - actor.transform.position;
            if (distance.sqrMagnitude <= moveSpeedThreshold * moveSpeedThreshold)
            {
                if (moveAnim == MoveRunAnimName.Walk) return;
                LogProxy.Log($"【移动cmd】Enter阈值:Walk");
                moveAnim = MoveRunAnimName.Walk;
            }
            else
            {
                if (moveAnim == MoveRunAnimName.Run) return;
                LogProxy.Log($"【移动cmd】Enter阈值:Run");
                moveAnim = MoveRunAnimName.Run;
            }
        }

        protected void UpdateThresholdWalkRun()
        {
            //走跑阈值 默认小于0 如果有设置才去更新
            if (moveSpeedThreshold < 0) return;

            var distance = destPos - actor.transform.position;
            if (moveAnim == MoveRunAnimName.Run)
            {
                if (distance.sqrMagnitude < Mathf.Pow(moveSpeedThreshold - _walkRunTolerant, 2))
                {
                    LogProxy.Log($"【移动cmd】阈值切换到Walk");
                    moveAnim = MoveRunAnimName.Walk;
                }
            }
            else
            {
                if (distance.sqrMagnitude > Mathf.Pow(moveSpeedThreshold + _walkRunTolerant, 2))
                {
                    LogProxy.Log($"【移动cmd】阈值切换到Run");
                    moveAnim = MoveRunAnimName.Run;
                }
            }
        }

        protected override void _OnExit(ActorCmd nextCmd)
        {
            if (actor.animator != null) actor.animator.speed = _oldAnimSpeed;
            actor.locomotion.StopMove();
            actor.moveTarget = null;
        }
        public override bool CanExecuted()
        {
            return actor.locomotion.CanMoveInterrupt();
        }
    }
}
