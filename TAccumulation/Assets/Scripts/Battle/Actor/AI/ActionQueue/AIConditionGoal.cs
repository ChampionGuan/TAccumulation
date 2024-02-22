using System;
using Unity.Profiling;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 条件所属阶段
    /// </summary>
    public enum AIConditionPhaseType
    {
        Pending, //行为等待阶段,当此阶段条件不满足时，持续等待，满足时则立即执行此行为
        PreRun, //行为执行前阶段，当此阶段条件不满足时，中断此行为并打断后续，满足时则无事发生
        Running, //行为执行中阶段，当此阶段条件不满足时，中断此行为，满足时则无事发生
    }

    /// <summary>
    /// 条件打断类型
    /// </summary>
    public enum AIConditionBreakType
    {
        Self, // 打断自身行为
        Clear, // 清除后续行为队列
        Hold, // 等待此条件达成
    }

    
    [Serializable]
    public class AIConditionParams : AIConditionParams<AIConditionParams>
    {
    }
    
    [Serializable]
    public class AIConditionParams<T> : IAIGoalParams where T : AIConditionParams<T>
    {
        public AIConditionPhaseType phaseType = AIConditionPhaseType.PreRun;
        [HideInInspector] public AIConditionBreakType breakType = AIConditionBreakType.Self;

        public virtual void CopyFrom(T @params)
        {
            phaseType = @params.phaseType;
            breakType = @params.breakType;
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
            phaseType = AIConditionPhaseType.PreRun;
            breakType = AIConditionBreakType.Self;
        }
    }

    public class AIConditionGoal<T> : AIGoalBase<T>, IAIConditionGoal where T : AIConditionParams<T>, new()
    {
        public AIConditionPhaseType phaseType => parameters.phaseType;
        public AIConditionBreakType breakType => parameters.breakType;
        public ProfilerMarker isMeetMaker { get; }
        public Type type { get; }

        public AIConditionGoal()
        {
            type = GetType();
            isMeetMaker = new ProfilerMarker($"_combatAI.IsMeet.{type}");
        }

        public virtual bool IsMeet()
        {
            return false;
        }

        public void SetParameters(IAIGoalParams @params)
        {
            base.SetParameters(@params as T);
        }

        public override void Reset()
        {
            base.Reset();
            ObjectPoolUtility.ReleaseAIConditionGoal(this);
        }
    }
}
