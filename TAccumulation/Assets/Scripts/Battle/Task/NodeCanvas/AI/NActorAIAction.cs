using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    public abstract class NActorAIAction : BattleAction
    {
        private ActorAIContext _aiContext;

        protected override void _OnGraphStart()
        {
            _aiContext = _context as ActorAIContext;
        }

        public bool AddAction<T>(IAIGoalParams @params, Node node = null, Component agent = null, IBlackboard blackboard = null) where T : class, IAIActionGoal
        {
            if (null == _aiContext) return false;
            return _aiContext.AddAction<T>(true, @params, node, agent, blackboard);
        }

        public void AddCondition<T>(IAIGoalParams @params) where T : class, IAIConditionGoal
        {
            _aiContext?.AddCondition<T>(@params);
        }

        public void ClearAllActions()
        {
            _aiContext?.ClearAllActions();
        }
    }
}
