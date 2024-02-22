using System;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Serializable]
    public class AIRotateTargetActionParams : AIActionParams<AIRotateTargetActionParams>
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();

        public override void CopyFrom(AIRotateTargetActionParams @params)
        {
            target.value = @params.target.value;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            target.value = null;
            base.Reset();
        }
    }

    /// <summary>
    /// 向目标转身行为
    /// 具体见文档：depot/x3/策划文档/战斗/5.系统设计/2.AI规则/AI行为节点整理.xlsx
    /// </summary>
    public class AIRotateTargetActionGoal : AIActionGoal<AIRotateTargetActionParams>
    {
        protected ActorMoveDirCmd _cmd;
        private Action<EventActorEnterStateBase> _actionOnAbnormalStateChange;

        protected override ActorCmd cmd
        {
            get
            {
                if (null != _cmd) return _cmd;
                _cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                _cmd.Init(parameters.target.value.insID, MoveType.Turn);
                return _cmd;
            }
            set => _cmd = value as ActorMoveDirCmd;
        }

        public AIRotateTargetActionGoal()
        {
            _actionOnAbnormalStateChange = OnAbnormalStateChange;
        }

        protected override void OnEnter()
        {
            actor.eventMgr.AddListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange, "AIRotateTargetActionGoal.OnAbnormalStateChange");
        }

        protected override void OnExit()
        {
            actor.eventMgr.RemoveListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange);
        }

        protected void OnAbnormalStateChange(EventActorEnterStateBase data)
        {
            //角色进入异常状态，则结束此行为及后续行为
            SetFinish(false, true);
        }

        protected override void OnCmdFinished()
        {
            //指令执行完成，则结束此行为
            if (cmd.state == ActorCmdState.Successful)
            {
                SetFinish();
            }
            else
            {
                SetFinish(false, true);
            }
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
                    if (AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.target.value)) return false;
                    //此时不可移动
                    if (!AIGoalUtil.CanEnterMove(actor)) return false;
                    break;
                case AIConditionPhaseType.Running:
                    break;
            }

            return base.OnVerifyingConditions(phaseType);
        }
    }
}
