using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("范围判断")]
    [Name("AddConditionGoal_IsTargetInArea")]
    public class FCAddConditionGoalIsTargetInArea : FActorAIAction
    {
        public AIIsTargetInAreaConditionParams isTargetInArea = new AIIsTargetInAreaConditionParams();

        protected override void _Invoke()
        {
            AddCondition<AIIsTargetInAreaConditionGoal>(isTargetInArea);
        }
    }
}
