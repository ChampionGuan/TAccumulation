using System;
using NodeCanvas.Framework;
using Random = UnityEngine.Random;

namespace X3Battle
{
    [Serializable]
    public class AISmartHoverActionParams : AIActionParams<AISmartHoverActionParams>
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<float> MaxTime = 0;
        public BBParameter<float> HoverTime = 0;
        public BBParameter<float> MinRadius = 0;
        public BBParameter<float> MaxRadius = 0;
        public BBParameter<float> RunRadius = 0;
        public bool targetMustBeLegal = true;

        public override void CopyFrom(AISmartHoverActionParams @params)
        {
            target.value = @params.target.value;
            MaxTime.value = @params.MaxTime.value;
            HoverTime.value = @params.HoverTime.value;
            MinRadius.value = @params.MinRadius.value;
            MaxRadius.value = @params.MaxRadius.value;
            RunRadius.value = @params.RunRadius.value;
            targetMustBeLegal = @params.targetMustBeLegal;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            target.value = null;
            MaxTime.value = 0;
            HoverTime.value = 0;
            MinRadius.value = 0;
            MaxRadius.value = 0;
            RunRadius.value = 0;
            targetMustBeLegal = true;
            base.Reset();
        }
    }

    /// <summary>
    /// 更智能的向目标徘徊行为
    /// 具体见文档：depot/x3/策划文档/战斗/5.系统设计/2.AI规则/AI行为节点整理.xlsx
    /// </summary>
    public class AISmartHoverActionGoal : AIActionGoal<AISmartHoverActionParams>
    {
        public enum Phase
        {
            None = -1,
            NeedWalkBack,
            NeedHover,
            NeedWalkForward,
            NeddRunForward
        }

        private Phase _currPhase = Phase.None;
        private float _moveTimeTick = 0f;

        protected ActorMoveDirCmd _cmd;
        private Action<EventActorEnterStateBase> _actionOnAbnormalStateChange;

        public AISmartHoverActionGoal()
        {
            _actionOnAbnormalStateChange = OnAbnormalStateChange;
        }

        protected override void OnEnter()
        {
            actor.eventMgr.AddListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange, "AISmartHoverActionGoal.OnAbnormalStateChange");
            _UpdatePhase();
        }

        protected override void OnExit()
        {
            actor.eventMgr.RemoveListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange);
        }

        protected override void OnReset()
        {
            _currPhase = Phase.None;
            _cmd = null;
            _moveTimeTick = 0f;
        }

        protected override void OnUpdate(float deltaTime)
        {
            _moveTimeTick += deltaTime;
            //移动计时超过设定最大值，则结束此行为
            if (_moveTimeTick > parameters.MaxTime.value)
            {
                SetFinish();
                return;
            }

            _UpdatePhase();
        }

        protected void OnAbnormalStateChange(EventActorEnterStateBase data)
        {
            //角色进入异常状态，则结束此行为及后续行为
            SetFinish(false, true);
        }

        private void _UpdatePhase()
        {
            float distance = BattleUtil.GetActorDistance(parameters.target.value, actor);
            if (distance <= parameters.MinRadius.value)
            {
                _SetActionPhase(Phase.NeedWalkBack);
            }
            else if (distance > parameters.MinRadius.value && distance <= parameters.MaxRadius.value)
            {
                _SetActionPhase(Phase.NeedHover);
            }
            else if (distance > parameters.MaxRadius.value && distance <= parameters.RunRadius.value)
            {
                _SetActionPhase(Phase.NeedWalkForward);
            }
            else
            {
                _SetActionPhase(Phase.NeddRunForward);
            }
        }

        protected override void OnCmdFinished()
        {
            if (cmd.state != ActorCmdState.Successful)
            {
                SetFinish(false, true);
                return;
            }

            //徘徊结束，重新徘徊
            _currPhase = Phase.None;
        }

        protected override bool OnVerifyingConditions(AIConditionPhaseType phaseType)
        {
            switch (phaseType)
            {
                case AIConditionPhaseType.Pending:
                    //策划特殊需求：有等待当前行为结束的条件时，不再走后续检测逻辑
                    if (AIGoalUtil.HasWaitCurrActionCondition(this, phaseType)) break;
                    //此时不可移动
                    if (!AIGoalUtil.CanEnterMove(actor)) return false;
                    break;
                case AIConditionPhaseType.PreRun:
                    //目标死亡或不可锁定
                    if (parameters.targetMustBeLegal&&AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.target.value)) return false;
                    //此时不可移动
                    if (!AIGoalUtil.CanEnterMove(actor)) return false;
                    break;
                case AIConditionPhaseType.Running:
                    //目标死亡或不可锁定
                    if (parameters.targetMustBeLegal&&AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.target.value)) return false;
                    //此时不可移动
                    if (!AIGoalUtil.CanEnterMove(actor)) return false;
                    break;
            }

            return base.OnVerifyingConditions(phaseType);
        }

        /// <summary>
        /// 设置行为阶段
        /// </summary>
        /// <param name="type"></param>
        protected void _SetActionPhase(Phase type)
        {
            if (_currPhase == type)
            {
                return;
            }

            _currPhase = type;
            _cmd = null;
            switch (type)
            {
                case Phase.NeedWalkBack:
                {
                    var cmdMove = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                    cmdMove.Init(parameters.target.value.insID, MoveType.Wander, MoveWanderAnimName.Back,moveWithoutTarget:!parameters.targetMustBeLegal);
                    _cmd = cmdMove;
                }
                    break;
                case Phase.NeedHover:
                {
                    var cmdMove = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                    int value = Random.Range(0, 2);
                    if (value == 0)
                    {
                        cmdMove.Init(parameters.target.value.insID, MoveType.Wander, MoveWanderAnimName.Left, parameters.HoverTime.value,moveWithoutTarget:!parameters.targetMustBeLegal);
                    }
                    else
                    {
                        cmdMove.Init(parameters.target.value.insID, MoveType.Wander, MoveWanderAnimName.Right, parameters.HoverTime.value,moveWithoutTarget:!parameters.targetMustBeLegal);
                    }

                    _cmd = cmdMove;
                }
                    break;
                case Phase.NeedWalkForward:
                {
                    var cmdMove = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                    cmdMove.Init(parameters.target.value.insID, MoveType.Wander, MoveWanderAnimName.Forward,moveWithoutTarget:!parameters.targetMustBeLegal);
                    _cmd = cmdMove;
                }
                    break;
                case Phase.NeddRunForward:
                {
                    var cmdMove = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                    cmdMove.Init(parameters.target.value.insID, MoveType.Run, MoveWanderAnimName.Forward,moveWithoutTarget:!parameters.targetMustBeLegal);
                    _cmd = cmdMove;
                }
                    break;
                default:
                    PapeGames.X3.LogProxy.LogError($"{actor} error Phase {type}!");
                    break;
            }

            if (!ExecuteCmd(_cmd))
            {
                SetFinish(false);
            }
        }
    }
}
