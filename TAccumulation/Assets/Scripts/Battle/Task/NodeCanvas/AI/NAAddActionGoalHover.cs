using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("向目标徘徊")]
    [Name("AddActionGoal_Hover")]
    public class NAAction_Hover : NActorAIDecorator
    {
        public AIHoverActionParams hover = new AIHoverActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (hover.target.isNoneOrNull)
            {
                return Status.Failure;
            }

            var result = AddAction<AIHoverActionGoal>(hover, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("向目标徘徊")]
    [Name("AddActionGoal_Hover")]
    public class NAAddActionGoalHover : NActorAIAction
    {
        public AIHoverActionParams hover = new AIHoverActionParams();

        protected override void OnExecute()
        {
            if (hover.target.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var result = AddAction<AIHoverActionGoal>(hover);
            EndAction(result);
        }
    }
}
