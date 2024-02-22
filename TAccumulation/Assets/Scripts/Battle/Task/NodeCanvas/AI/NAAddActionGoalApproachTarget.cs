using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("移动到目标位置")]
    [Name("AddActionGoal_ApproachTarget")]
    public class NAAction_ApproachTarget : NActorAIDecorator
    {
        public AIApproachTargetActionParams approachTarget = new AIApproachTargetActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (approachTarget.target.isNoneOrNull)
            {
                return Status.Failure;
            }

            var result = AddAction<AIApproachTargetActionGoal>(approachTarget, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("移动到目标位置")]
    [Name("AddActionGoal_ApproachTarget")]
    public class NAAddActionGoalApproachTarget : NActorAIAction
    {
        public AIApproachTargetActionParams approachTarget = new AIApproachTargetActionParams();

        protected override void OnExecute()
        {
            if (approachTarget.target.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var result = AddAction<AIApproachTargetActionGoal>(approachTarget);
            EndAction(result);
        }
    }
}
