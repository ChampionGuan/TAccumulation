using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("移动到目标点")]
    [Name("AddActionGoal_ApproachPosition")]
    public class NAAction_ApproachPosition : NActorAIDecorator
    {
        public AIApproachPositionActionParams approachPosition = new AIApproachPositionActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            var result = AddAction<AIApproachPositionActionGoal>(approachPosition, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("移动到目标点")]
    [Name("AddActionGoal_ApproachPosition")]
    public class NAAddActionGoalApproachPosition : NActorAIAction
    {
        public AIApproachPositionActionParams approachPosition = new AIApproachPositionActionParams();

        protected override void OnExecute()
        {
            var result = AddAction<AIApproachPositionActionGoal>(approachPosition);
            EndAction(result);
        }
    }
}
