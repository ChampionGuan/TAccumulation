using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("向目标坐标点徘徊")]
    [Name("AddActionGoal_HoverPoint")]
    public class NAAction_HoverPoint : NActorAIDecorator
    {
        public AIHoverPointActionParams hover = new AIHoverPointActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {

            var result = AddAction<AIHoverPointActionGoal>(hover, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

}
