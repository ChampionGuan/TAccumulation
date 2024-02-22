using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using Unity.Profiling;
using UnityEngine;

namespace X3Battle
{
    public interface IAIGoalContext
    {
        Actor actor { get; }
        void GenerateActions(float deltaTime);
    }
    
    public interface IAIGoalParams
    {
        void CopyFrom(IAIGoalParams @params);
        void Reset();
    }

    public interface IAIActionGoal
    {
        bool isInitialized { get; }
        bool isRunning { get; }
        void Init(AIActionQueue owner);
        void Tick(float deltaTime);
        void SetFinish(bool successful = true, bool clearWaitActions = false);
        void SetParameters(IAIGoalParams @params, Node node, Component agent, IBlackboard blackboard);
        bool VerifyingOverTime(float deltaTime);
        bool VerifyingConditions(AIConditionPhaseType phaseType, out AIConditionBreakType breakType);
        void AddConditions(List<IAIConditionGoal> conditions);
        bool HasCondition(AIConditionPhaseType phaseType, Type type);
        //慎调
        void Reset();
    }

    public interface IAIConditionGoal
    {
        AIConditionPhaseType phaseType { get; }
        AIConditionBreakType breakType { get; }
        ProfilerMarker isMeetMaker { get; }
        
        Type type { get; }
        
        bool IsMeet();
        void SetParameters(IAIGoalParams @params);
        void Reset();
    }

    public class AIGoalBase<T> where T : IAIGoalParams, new()
    {
        public T parameters { get; } = new T();

        protected void SetParameters(T @params)
        {
            if (null == @params)
            {
                return;
            }

            parameters.CopyFrom(@params);
        }

        public virtual void Reset()
        {
            parameters.Reset();
        }
    }

    public class AIGoalSubTree
    {
        public Node node { get; private set; }
        public IBlackboard blackboard { get; private set; }
        public Component agent { get; private set; }

        public void SetParameters(Node node, Component agent, IBlackboard blackboard)
        {
            this.node = node;
            this.blackboard = blackboard;
            this.agent = agent;
        }

        public void Tick()
        {
            if (node == null) return;
            node.Reset();
            node.Execute(agent, blackboard);
        }

        public void Reset()
        {
            node = null;
            blackboard = null;
            agent = null;
        }
    }
}
