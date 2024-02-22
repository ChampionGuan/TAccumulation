using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Name("AddActionGoal_SubTree")]
    [Category("X3Battle/AI行为队列")]
    [Description("作为传递子树作为ActionGoal的装饰节点,一定返回success")]
    public class NAAction_SubTree : NActorAIDecorator
    {
        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            var result = AddAction<AITickSubTreeGoal>(null, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }
}
