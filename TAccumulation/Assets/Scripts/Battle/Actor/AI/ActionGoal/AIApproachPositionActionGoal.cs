using System;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Serializable]
    public class AIApproachPositionActionParams : AIActionParams<AIApproachPositionActionParams>
    {
        public BBParameter<Vector3> moveTo = Vector3.zero;
        public BBParameter<float> radius = 0;
        public BBParameter<float> maxMoveTime = 0;
        public BBParameter<AIMoveType> moveType = new BBParameter<AIMoveType>(AIMoveType.Run);

        public override void CopyFrom(AIApproachPositionActionParams @params)
        {
            moveTo.value = @params.moveTo.value;
            radius.value = @params.radius.value;
            maxMoveTime.value = @params.maxMoveTime.value;
            moveType.value = @params.moveType.value;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            moveTo.value = Vector3.zero;
            radius.value = 0;
            maxMoveTime.value = 0;
            moveType.value = 0;
            base.Reset();
        }
    }

    /// <summary>
    /// 移动到目标点行为
    /// 具体见文档：depot/x3/策划文档/战斗/5.系统设计/2.AI规则/AI行为节点整理.xlsx
    /// </summary>
    public class AIApproachPositionActionGoal : AIActionGoal<AIApproachPositionActionParams>
    {
        protected ActorMovePosCmd _cmd;
        private Action<EventActorEnterStateBase> _actionOnAbnormalStateChange;

        protected override ActorCmd cmd
        {
            get
            {
                if (null != _cmd) return _cmd;
                _cmd = ObjectPoolUtility.GetActorCmd<ActorMovePosCmd>();
                _cmd.Init(parameters.moveTo.value, parameters.radius.value, parameters.maxMoveTime.value, AIGoalUtil.GetMoveAnimName(parameters.moveType.value));
                return _cmd;
            }
            set => _cmd = value as ActorMovePosCmd;
        }

        protected override bool clearCmdAftExit => true;

        public AIApproachPositionActionGoal()
        {
            _actionOnAbnormalStateChange = OnAbnormalStateChange;
        }

        protected override void OnEnter()
        {
            actor.eventMgr.AddListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange, "AIApproachPositionActionGoal.OnAbnormalStateChange");
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
