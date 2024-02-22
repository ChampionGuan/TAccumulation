using System;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Serializable]
    public class AIApproachTargetBySpeedActionParams : AIActionParams<AIApproachTargetBySpeedActionParams>
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public float mindis = 0;
        public float middis = 0;
        public float maxdis = 0;
        public float minspeed = 0;
        public float midspeed = 0;
        public float maxspeed = 0;
        public float maxMoveTime = 0;
        public float minSpeedTime = 0f;
        public float midSpeedTime = 0f;
        public float maxSpeedTime = 0f;

        [Tooltip("行为在行为队列中执行前的条件需要满足目标不能处于【死亡或不可锁定】, 并且行为过程中【目标死亡或不可锁定】时会异常结束")]
        public bool targetMustBeLegal = true;
        
        public override void CopyFrom(AIApproachTargetBySpeedActionParams @params)
        {
            target.value = @params.target.value;
            mindis = @params.mindis;
            middis = @params.middis;
            maxdis = @params.maxdis;
            minspeed = @params.minspeed;
            midspeed = @params.midspeed;
            maxspeed = @params.maxspeed;
            maxMoveTime = @params.maxMoveTime;
            minSpeedTime = @params.minSpeedTime;
            midSpeedTime = @params.midSpeedTime;
            maxSpeedTime = @params.maxSpeedTime;
            targetMustBeLegal = @params.targetMustBeLegal;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            target.value = null;
            mindis = 0;
            middis = 0;
            maxdis = 0;
            minspeed = 0;
            midspeed = 0;
            maxspeed = 0;
            maxMoveTime = 0;
            minSpeedTime = 0;
            midSpeedTime = 0;
            maxSpeedTime = 0;
            targetMustBeLegal = true;
            base.Reset();
        }
    }
    public class AIApproachTargetBySpeedActionGoal : AIActionGoal<AIApproachTargetBySpeedActionParams>
    {
        
        protected ActorMovePosCmd _cmd;
        private Action<EventActorEnterStateBase> _actionOnAbnormalStateChange;
        private float _currSpeed;
        private float _currSpeedKeepingTime; // 当前速度维持倒计时.
        private RangeType? _currSpeedRangeType; // 当前速度的来源范围.
        
        protected override ActorCmd cmd
        {
            get
            {
                if (null != _cmd) return _cmd;
                _cmd = ObjectPoolUtility.GetActorCmd<ActorMovePosCmd>();
                _cmd.Init(parameters.target.value.insID, parameters.mindis, parameters.maxMoveTime);
                return _cmd;
            }
            set => _cmd = value as ActorMovePosCmd;
        }
        private float _moveTimeTick = 0f;

        protected override bool clearCmdAftExit => true;

        public AIApproachTargetBySpeedActionGoal()
        {
            _actionOnAbnormalStateChange = OnAbnormalStateChange;
        }

        protected override void OnReset()
        {
            _moveTimeTick = 0f; 
            _currSpeed = 0f;
            _currSpeedKeepingTime = 0f;
            _currSpeedRangeType = null;
        }

        protected override void OnEnter()
        {
            actor.eventMgr.AddListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange, "AIApproachTargetBySpeedActionGoal.OnAbnormalStateChange");
        }

        protected override void OnExit()
        {
            actor.eventMgr.RemoveListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange);
        }

        protected override void OnUpdate(float deltaTime)
        {
            _currSpeedKeepingTime -= deltaTime;
            
            //目标死亡或不可锁定，则结束此行为
            if (parameters.targetMustBeLegal && AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.target.value))
            {
                SetFinish(false, true);
            }
            
            _moveTimeTick += deltaTime;
            //移动计时超过设定最大值，则结束此行为
            if (_moveTimeTick > parameters.maxMoveTime)
            {
                SetFinish();
                return;
            }

            float distance = BattleUtil.GetActorDistance(parameters.target.value,actor);
            
            if (distance <= parameters.mindis)
            {
                SetFinish();
                return;
            }

            // DONE: 当前速度维持倒计时结束 == 当速度切换时重开倒计时器 == 重新检测区间. 
            if (_currSpeedKeepingTime <= 0f)
            {
                float currSpeed;
                RangeType currSpeedRangeType;
                float rangeSpeedKeepingTime;
                if (distance > parameters.mindis && distance <= parameters.middis)
                {
                    currSpeed = parameters.minspeed;
                    currSpeedRangeType = RangeType.Min;
                    rangeSpeedKeepingTime = parameters.minSpeedTime;
                }
                else if (distance > parameters.middis && distance <= parameters.maxdis)
                {
                    currSpeed = parameters.midspeed;
                    currSpeedRangeType = RangeType.Mid;
                    rangeSpeedKeepingTime = parameters.midSpeedTime;
                }
                else
                {
                    currSpeed = parameters.maxspeed;
                    currSpeedRangeType = RangeType.Max;
                    rangeSpeedKeepingTime = parameters.maxSpeedTime;
                }

                // DONE: 切换了区域配置的速度, 需要重新开启对应区域的计时器.
                if (currSpeedRangeType != _currSpeedRangeType)
                {
                    _currSpeedKeepingTime = rangeSpeedKeepingTime;
                    _currSpeedRangeType = currSpeedRangeType;
                }
                
                if (_currSpeed != currSpeed)
                {
                    _currSpeed = currSpeed;
                    actor.locomotion.SetWalkRunBlend(_currSpeed);
                }
            }
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
                    if (parameters.targetMustBeLegal && AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.target.value)) return false;
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