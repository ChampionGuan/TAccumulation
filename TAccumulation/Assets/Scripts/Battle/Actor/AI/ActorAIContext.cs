using System.Collections.Generic;
using NodeCanvas.Framework;
using NodeCanvas.StateMachines;
using UnityEngine;

namespace X3Battle
{
    public class ActorAIContext : ActorContext, IAIGoalContext
    {
        public AIActionQueue actionQueue { get; set; }
        public ActorAIStatus status { get; set; }

        private NotionGraph<FSMOwner> _owner;
        private Dictionary<AIConditionPhaseType, List<IAIConditionGoal>> _conditions = new Dictionary<AIConditionPhaseType, List<IAIConditionGoal>>();

        #region 记录数据

        public float endInBackSwingTimeStamp = 0;

        #endregion

        public ActorAIContext(Actor actor, NotionGraph<FSMOwner> owner) : base(actor)
        {
            _owner = owner;
        }

        public void GenerateActions(float deltaTime)
        {
            _ClearConditions();
            if (!actionQueue.paused)
            {
                _owner?.Update(deltaTime);
            }
        }

        public bool AddAction<T>(bool addCheck, IAIGoalParams @params, Node node = null, Component agent = null, IBlackboard blackboard = null) where T : class, IAIActionGoal
        {
            var action = ObjectPoolUtility.GetAIActionGoal<T>();
            action.SetParameters(@params, node, agent, blackboard);
            if (null == actionQueue)
            {
                _ClearConditions();
                return false;
            }

            foreach (var conditions in _conditions.Values)
            {
                action.AddConditions(conditions);
                conditions.Clear();
            }

            return actionQueue.AddAction(action, addCheck);
        }

        public void ClearAllActions()
        {
            actionQueue.ClearAllActions();
            _ClearConditions();
        }

        public void AddCondition<T>(IAIGoalParams @params) where T : class, IAIConditionGoal
        {
            var condition = ObjectPoolUtility.GetAIConditionGoal<T>();
            condition.SetParameters(@params);
            if (!_conditions.TryGetValue(condition.phaseType, out var conditions))
            {
                conditions = new List<IAIConditionGoal>();
                _conditions.Add(condition.phaseType, conditions);
            }

            conditions.Add(condition);
        }

        private void _ClearConditions()
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
    }
}
