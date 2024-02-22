using System;
using NodeCanvas.Framework;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    [Serializable]
    public class AIHoverPointActionParams : AIActionParams<AIHoverPointActionParams>
    {
        public BBParameter<Vector3> targetPoint = new BBParameter<Vector3>();
        public BBParameter<float> maxHoverTime = 0;

        public override void CopyFrom(AIHoverPointActionParams @params)
        {
            targetPoint.value = @params.targetPoint.value;
            maxHoverTime.value = @params.maxHoverTime.value;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            targetPoint.value = Vector3.zero;
            maxHoverTime.value = 0;
            base.Reset();
        }
    }

    /// <summary>
    /// 徘徊行为
    /// 具体见文档：depot/x3/策划文档/战斗/5.系统设计/2.AI规则/AI行为节点整理.xlsx
    /// </summary>
    public class AIHoverPointActionGoal : AIActionGoal<AIHoverPointActionParams>
    {
        protected ActorMoveDirCmd _cmd;
        private Action<EventActorEnterStateBase> _actionOnAbnormalStateChange;

        protected override ActorCmd cmd
        {
            get
            {
                if (null != _cmd) return _cmd;
                _cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();

                //TODO临时做法，后面寻路好了会去掉
                int value = Random.Range(0, 2);
                if (value == 0)
                {
                    _cmd.InitByTargetPos(parameters.targetPoint.value, MoveType.Wander, MoveWanderAnimName.Left, parameters.maxHoverTime.value);
                }
                else
                {
                    _cmd.InitByTargetPos(parameters.targetPoint.value, MoveType.Wander, MoveWanderAnimName.Right, parameters.maxHoverTime.value);
                }

                return _cmd;
            }
            set => _cmd = value as ActorMoveDirCmd;
        }

        public AIHoverPointActionGoal()
        {
            _actionOnAbnormalStateChange = OnAbnormalStateChange;
        }

        protected override void OnEnter()
        {
            actor.eventMgr.AddListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange, "AIHoverPointActionGoal.OnAbnormalStateChange");
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
