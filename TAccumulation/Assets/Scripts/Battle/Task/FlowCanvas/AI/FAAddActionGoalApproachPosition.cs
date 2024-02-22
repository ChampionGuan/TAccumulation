using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("移动到目标点")]
    [Name("AddActionGoal_ApproachPosition")]
    public class FAAddActionGoalApproachPosition : FActorAIAction
    {
        public AIApproachPositionActionParams approachPosition = new AIApproachPositionActionParams();

        protected override void _Invoke()
        {
            AddAction<AIApproachPositionActionGoal>(approachPosition);
        }
    }
}
