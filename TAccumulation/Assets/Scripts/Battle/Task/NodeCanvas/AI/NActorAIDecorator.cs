using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    public abstract class NActorAIDecorator : BTDecorator
    {
        private ActorAIContext _aiContext;

        public sealed override void OnGraphStart()
        {
            base.OnGraphStart();
            _aiContext = graph.blackboard.GetVariable(BattleConst.ContextVariableName).value as ActorAIContext;
            _OnGraphStart();
        }

        protected virtual void _OnGraphStart()
        {
        }

        public bool AddAction<T>(IAIGoalParams @params, Component agent = null, IBlackboard blackboard = null) where T : class, IAIActionGoal
        {
            if (null == _aiContext) return false;
            return _aiContext.AddAction<T>(true, @params, decoratedNode, agent, blackboard);
        }
    }
}
