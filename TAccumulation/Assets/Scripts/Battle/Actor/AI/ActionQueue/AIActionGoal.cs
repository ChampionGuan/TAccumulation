using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using Unity.Profiling;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public interface IAICompositeAction
    {
        void GenSubActions(List<IAIActionGoal> outActions);
    }

    [Serializable]
    public class AIActionParams : AIActionParams<AIActionParams>
    {
    }

    [Serializable]
    public class AIActionParams<T> : IAIGoalParams where T : AIActionParams<T>
    {
        [ParadoxNotion.Design.Header("行为通用参数")]
        [Tooltip("行为在行为队列等待的时间")]
        public BBParameter<float> holdTime = 0;

        public virtual void CopyFrom(T @params)
        {
            holdTime.value = @params.holdTime.value;
        }

        public void CopyFrom(IAIGoalParams @params)
        {
            if (@params is T p)
            {
                CopyFrom(p);
            }
        }

        public virtual void Reset()
        {
            holdTime.value = 0;
        }

        public override string ToString()
        {
            return $"holdTime={holdTime.value}";
        }
    }

    public class AIActionGoal<T> : AIGoalBase<T>, IAIActionGoal where T : AIActionParams<T>, new()
    {
        /// <summary>
        /// 行为状态
        /// </summary>
        public enum ActionStatus
        {
            Reset,
            Inited,
            PreRun,
            Running,
            Finished,
        }

        /// <summary>
        /// 条件时机与打断关系
        /// </summary>
        private static Dictionary<AIConditionPhaseType, AIConditionBreakType> _conditionRelation = new Dictionary<AIConditionPhaseType, AIConditionBreakType>
        {
            { AIConditionPhaseType.Pending, AIConditionBreakType.Hold },
            { AIConditionPhaseType.PreRun, AIConditionBreakType.Clear },
            { AIConditionPhaseType.Running, AIConditionBreakType.Self },
        };

        /// <summary>
        /// 占位时长计时！
        /// </summary>
        private float _holdTimeTick;

        /// <summary>
        /// 调试信息
        /// </summary>
        protected virtual string _debugInfo { get; set; }

        /// <summary>
        /// 持有者
        /// </summary>
        protected AIActionQueue _owner { get; set; }

        /// <summary>
        /// 行为子树
        /// </summary>
        protected AIGoalSubTree _subTree { get; } = new AIGoalSubTree();

        /// <summary>
        /// 执行中的指令
        /// </summary>
        protected ActorCmd _executingCmd { get; private set; }

        /// <summary>
        /// 所有条件（包含等待时/执行前/执行中）
        /// </summary>
        protected Dictionary<AIConditionPhaseType, List<IAIConditionGoal>> _conditions { get; } = new Dictionary<AIConditionPhaseType, List<IAIConditionGoal>>();

        /// <summary>
        /// 指令结束事件
        /// </summary>
        private Action<EventActorCmdFinished> _cmdFinished;

        /// <summary>
        /// 单位
        /// </summary>
        public Actor actor => context?.actor;

        /// <summary>
        /// 上下文环境
        /// </summary>
        public IAIGoalContext context => _owner?.context;

        /// <summary>
        /// 行为状态
        /// </summary>
        public ActionStatus status { get; private set; } = ActionStatus.Reset;

        /// <summary>
        /// 是否已初始化
        /// </summary>
        public bool isInitialized => status != ActionStatus.Reset;

        /// <summary>
        /// 是否已运行
        /// </summary>
        public bool isRunning => status == ActionStatus.Running;

        /// <summary>
        /// 是否已结束
        /// </summary>
        public bool isFinished => status == ActionStatus.Finished;

        /// <summary>
        /// 行为指令
        /// </summary>
        protected virtual ActorCmd cmd { get; set; }

        /// <summary>
        /// 退出后清指令
        /// </summary>
        protected virtual bool clearCmdAftExit { get; }
        
        private ProfilerMarker _tickMarker;
        private ProfilerMarker _updateMarker;
        private ProfilerMarker _finishMarker;
        private ProfilerMarker _verifyingConditionsMarker;

        /// <summary>s
        /// 构造函数
        /// </summary>
        public AIActionGoal()
        {
            _cmdFinished = _CmdFinished;
            Type type = GetType();
            _tickMarker = new ProfilerMarker($"_combatAI.Tick.{type}");
            _updateMarker = new ProfilerMarker($"_combatAI.OnUpdate.{type}");
            _finishMarker = new ProfilerMarker($"_combatAI.SetFinish.{type}");
            _verifyingConditionsMarker = new ProfilerMarker($"_combatAI.VerifyingConditions.{type}");
        }

        /// <summary>
        /// 初始化
        /// </summary>
        public void Init(AIActionQueue owner)
        {
            _owner = owner;
            status = ActionStatus.Inited;
            actor.eventMgr.AddListener(EventType.ActorCmdFinished, _cmdFinished, "AIActionGoal._CmdFinished");
            OnInit();
        }

        /// <summary>
        /// 驱动行为
        /// </summary>
        /// <param name="deltaTime"></param>
        /// <returns></returns>
        public void Tick(float deltaTime)
        {
            if (!isInitialized || isFinished)
            {
                return;
            }

            using (_tickMarker.Auto())
            {

                if (!isRunning)
                {
                    status = ActionStatus.PreRun;
                    // 如果执行前条件不满足，则结束此行为，并清除后续行为队列
                    if (!VerifyingConditions(AIConditionPhaseType.PreRun, out var breakType1))
                    {
                        SetFinish(false, breakType1 == AIConditionBreakType.Clear);
                        return;
                    }

                    status = ActionStatus.Running;
                    OnEnter();

                    // 如果有指令，且指令执行失败，则结束此行为
                    if (null != cmd && !ExecuteCmd(cmd))
                    {
                        SetFinish(false);
                        return;
                    }
                }

                if (isFinished)
                {
                    return;
                }

                // 如果执行中条件不满足，则结束此行为
                if (!VerifyingConditions(AIConditionPhaseType.Running, out var breakType2))
                {
                    SetFinish(false, breakType2 == AIConditionBreakType.Clear);
                    return;
                }

                using (_updateMarker.Auto())
                {
                    OnUpdate(deltaTime);
                }
            }
        }

        /// <summary>
        /// 结束行为
        /// <param name="successful">是否正常结束</param>
        /// <param name="clearWaitActions">是否需要清除后续行为</param>
        /// </summary>
        public void SetFinish(bool successful = true, bool clearWaitActions = false)
        {
            using (_finishMarker.Auto())
            {
                if (isRunning)
                {
                    // 置为结束状态
                    status = ActionStatus.Finished;
                    // 执行OnExit，与OnEnter保存对齐
                    OnExit();
                    // 转为局部变量，因为cmd.Finish()的过程中，此行为检测到指令结束，有可能会再次触发SetFinish()
                    var tempCmd = _executingCmd;
                    _executingCmd = null;
                    // 退出后清指令
                    if (clearCmdAftExit)
                    {
                        tempCmd?.Finish();
                    }

                    if (_owner != null)
                    {
                        // 如果行为成功，则执行子树逻辑
                        if (successful && !_owner.paused) _subTree.Tick();
                    }
                }

                _owner?.OnActionFinished(this, !successful && clearWaitActions);

                if (!isInitialized)
                {
                    return;
                }

                Reset();
            }
        }

        /// <summary>
        /// 行为参数
        /// </summary>
        /// <param name="params"></param>
        /// <param name="node"></param>
        /// <param name="agent"></param>
        /// <param name="blackboard"></param>
        public void SetParameters(IAIGoalParams @params, Node node, Component agent, IBlackboard blackboard)
        {
            base.SetParameters(@params as T);
            _subTree.SetParameters(node, agent, blackboard);
        }

        /// <summary>
        /// 执行角色指令
        /// </summary>
        /// <param name="cmd"></param>
        /// <returns></returns>
        protected bool ExecuteCmd(ActorCmd cmd)
        {
            if (null == actor?.commander) return false;
            _executingCmd = cmd;
            actor.commander.TryExecute(cmd);
            if (null == actor?.commander) return false;
            var res1 = _executingCmd == actor.commander.currentCmd;
            var res2 = res1 || null == _executingCmd;
            if (!res1) _executingCmd = null;
            return res2;
        }

        /// <summary>
        /// 验证占位时长
        /// </summary>
        /// <param name="deltaTime"></param>
        /// <returns></returns>
        public bool VerifyingOverTime(float deltaTime)
        {
            if (null == parameters) return true;
            bool result = _holdTimeTick > parameters.holdTime.value;
            _holdTimeTick += deltaTime;
            return result;
        }

        /// <summary>
        /// 验证不同阶段条件
        /// </summary>
        /// <param name="phaseType"></param>
        /// <param name="breakType"></param>
        /// <returns></returns>
        public bool VerifyingConditions(AIConditionPhaseType phaseType, out AIConditionBreakType breakType)
        {
            using (_verifyingConditionsMarker.Auto())
            {
                breakType = _conditionRelation[phaseType];
                if (_conditions.TryGetValue(phaseType, out var conditions) && conditions.Count > 0)
                {
                    foreach (var condition in conditions)
                    {
                        using (condition.isMeetMaker.Auto())
                        {
                            if (!condition.IsMeet())
                            {
                                return false;
                            }
                        }
                       
                    }
                }

                bool ret = OnVerifyingConditions(phaseType);
                return ret;
            }
        }

        /// <summary>
        /// 添加条件
        /// </summary>
        /// <param name="conditions"></param>
        public void AddConditions(Dictionary<AIConditionPhaseType, List<IAIConditionGoal>> conditions)
        {
            if (null == conditions)
            {
                return;
            }

            foreach (var list in conditions.Values)
            {
                AddConditions(list);
            }

            conditions.Clear();
        }

        /// <summary>
        /// 添加条件
        /// </summary>
        /// <param name="conditions"></param>
        public void AddConditions(List<IAIConditionGoal> conditions)
        {
            if (null == conditions || conditions.Count < 1)
            {
                return;
            }

            var phaseType = conditions[0].phaseType;
            if (!_conditions.TryGetValue(phaseType, out var list))
            {
                list = new List<IAIConditionGoal>();
                _conditions.Add(phaseType, list);
            }

            list.AddRange(conditions);
            conditions.Clear();
        }

        /// <summary>
        /// 添加条件
        /// </summary>
        /// <param name="condition"></param>
        public void AddCondition(IAIConditionGoal condition)
        {
            if (null == condition)
            {
                return;
            }

            if (!_conditions.TryGetValue(condition.phaseType, out var list))
            {
                list = new List<IAIConditionGoal>();
                _conditions.Add(condition.phaseType, list);
            }

            list.Add(condition);
        }

        /// <summary>
        /// 是否有此类型的条件
        /// </summary>
        /// <param name="phaseType"></param>
        /// <returns></returns>
        public bool HasCondition(AIConditionPhaseType phaseType, Type type)
        {
            if (!_conditions.TryGetValue(phaseType, out var conditions) || conditions.Count < 1)
            {
                return false;
            }

            foreach (var condition in conditions)
            {
                if (condition.type == type)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 清除条件
        /// </summary>
        public void ClearConditions()
        {
            foreach (var conditions in _conditions.Values)
            {
                foreach (var condition in conditions)
                {
                    condition.Reset();
                }

                conditions.Clear();
            }
        }

        /// <summary>
        /// 重置操作
        /// </summary>
        public override void Reset()
        {
            actor?.eventMgr.RemoveListener(EventType.ActorCmdFinished, _cmdFinished);
            status = ActionStatus.Reset;
            OnReset();
            base.Reset();
            ClearConditions();
            _subTree.Reset();

            cmd = null;
            _executingCmd = null;
            _holdTimeTick = 0;
            _debugInfo = null;
            _owner = null;
            ObjectPoolUtility.ReleaseAIActionGoal(this);
        }

        /// <summary>
        /// 指令结束
        /// </summary>
        /// <param name="data"></param>
        private void _CmdFinished(EventActorCmdFinished data)
        {
            if (null == _executingCmd || data.cmd != _executingCmd)
            {
                return;
            }

            _executingCmd = null;
            OnCmdFinished();
        }

        protected virtual void OnInit()
        {
        }

        protected virtual void OnReset()
        {
        }

        protected virtual void OnEnter()
        {
        }

        protected virtual void OnUpdate(float deltaTime)
        {
        }

        protected virtual void OnExit()
        {
        }

        protected virtual void OnCmdFinished()
        {
        }

        protected virtual bool OnVerifyingConditions(AIConditionPhaseType phaseType)
        {
            return true;
        }

        public override string ToString()
        {
            return _debugInfo ?? (_debugInfo = $"[{GetType().FullName}]:{parameters}");
        }
    }
}