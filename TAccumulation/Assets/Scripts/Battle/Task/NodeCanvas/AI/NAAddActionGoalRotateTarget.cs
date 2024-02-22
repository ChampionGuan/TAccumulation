using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("转向目标")]
    [Name("AddActionGoal_RotateTarget")]
    public class NAAction_RotateTarget : NActorAIDecorator
    {
        public AIRotateTargetActionParams rotateTarget = new AIRotateTargetActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (rotateTarget.target.isNoneOrNull)
            {
                return Status.Failure;
            }

            var result = AddAction<AIRotateTargetActionGoal>(rotateTarget, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("转向目标")]
    [Name("AddActionGoal_RotateTarget")]
    public class NAAddActionGoalRotateTarget : NActorAIAction
    {
        public AIRotateTargetActionParams rotateTarget = new AIRotateTargetActionParams();

        protected override void OnExecute()
        {
            if (rotateTarget.target.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var result = AddAction<AIRotateTargetActionGoal>(rotateTarget);
            EndAction(result);
        }
    }
}
