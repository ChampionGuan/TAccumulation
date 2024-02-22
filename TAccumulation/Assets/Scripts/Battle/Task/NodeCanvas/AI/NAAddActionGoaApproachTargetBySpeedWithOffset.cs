using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("以一定速度向目标的偏移值靠近")]
    [Name("AddActionGoal_MovetoTargetBySpeedWithOffset")]
    public class NAAction_ApproachTargetBySpeedWithOffset : NActorAIDecorator
    {
        public AIApproachTargetBySpeedWithOffsetActionParams actionParams = new AIApproachTargetBySpeedWithOffsetActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (actionParams.target.isNoneOrNull)
            {
                return Status.Failure;
            }

            var result = AddAction<AIApproachTargetBySpeedWithOffsetActionGoal>(actionParams, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }
}
