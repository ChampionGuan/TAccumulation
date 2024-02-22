using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("方向目标后退")]
    [Name("AddActionGoal_WalkBackTarget")]
    public class NAAction_WalkBackTarget : NActorAIDecorator
    {
        public AIWalkBackTargetActionParams walkBackTarget = new AIWalkBackTargetActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (walkBackTarget.target.isNoneOrNull)
            {
                return Status.Failure;
            }

            var result = AddAction<AIWalkBackTargetActionGoal>(walkBackTarget, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("方向目标后退")]
    [Name("AddActionGoal_WalkBackTarget")]
    public class NAAddActionGoalWalkBackTarget : NActorAIAction
    {
        public AIWalkBackTargetActionParams walkBackTarget = new AIWalkBackTargetActionParams();

        protected override void OnExecute()
        {
            if (walkBackTarget.target.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var result = AddAction<AIWalkBackTargetActionGoal>(walkBackTarget);
            EndAction(result);
        }
    }
}
