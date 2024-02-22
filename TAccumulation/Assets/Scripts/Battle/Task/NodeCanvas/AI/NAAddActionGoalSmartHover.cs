using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;


namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("更智能地向目标徘徊")]
    [Name("AddActionGoal_SmartHover")]
    public class NAAction_SmartHover : NActorAIDecorator
    {
        public AISmartHoverActionParams hover = new AISmartHoverActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (hover.target.isNoneOrNull)
            {
                return Status.Failure;
            }

            var result = AddAction<AISmartHoverActionGoal>(hover, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }
}
