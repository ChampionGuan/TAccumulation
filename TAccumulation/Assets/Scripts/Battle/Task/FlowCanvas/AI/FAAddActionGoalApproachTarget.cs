using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("移动到目标位置")]
    [Name("AddActionGoal_ApproachTarget")]
    public class FAAddActionGoalApproachTarget : FActorAIAction
    {
        public AIApproachTargetActionParams approachTarget = new AIApproachTargetActionParams();

        protected override void _Invoke()
        {
            if (approachTarget.target.isNoneOrNull)
            {
                return;
            }

            AddAction<AIApproachTargetActionGoal>(approachTarget);
        }
    }
}
