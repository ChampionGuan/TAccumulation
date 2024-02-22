
using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Name("CoolDownDecorator")]
    [Description("限制冷却时间的装饰节点")]
    [Category("Decorators")]
    public class NDCoolDownDecorator : BTDecorator
    {
        public float coolDown = 0f;
        
        private float _lastTimeStamp = 0f;
        private ActorAIContext _aiContext;

        public sealed override void OnGraphStart()
        {
            base.OnGraphStart();
            _aiContext = graph.blackboard.GetVariable(BattleConst.ContextVariableName).value as ActorAIContext;
            _lastTimeStamp = 0f;
        }

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            var currentTime = _aiContext.actor.time;
            if (currentTime - _lastTimeStamp < coolDown)
            {
                return Status.Failure;
            }

            if (decoratedConnection.Execute(agent, blackboard) == Status.Success)
            {
                _lastTimeStamp = currentTime;
                return Status.Success;
            }
            return Status.Failure;
        }
    }
}
