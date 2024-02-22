using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("以一定速度向目标靠近")]
    [Name("AddActionGoal_MovetoTargetBySpeed")]
    public class NAAction_ApproachTargetBySpeed : NActorAIDecorator
    {
        public AIApproachTargetBySpeedActionParams actionParams = new AIApproachTargetBySpeedActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (actionParams.target.isNoneOrNull)
            {
                return Status.Failure;
            }

            var result = AddAction<AIApproachTargetBySpeedActionGoal>(actionParams, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }
}
