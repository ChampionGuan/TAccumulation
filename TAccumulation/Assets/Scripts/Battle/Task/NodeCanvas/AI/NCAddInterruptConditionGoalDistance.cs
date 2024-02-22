using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("打断距离条件")]
    [Name("AddInterruptConditionGoal_Distance")]
    public class NCAddInterruptConditionGoalDistance : NActorAIAction
    {
        public AIDistanceConditionParams distance = new AIDistanceConditionParams();
 
        protected override void OnExecute()
        {
            AddCondition<AIDistanceConditionGoal>(distance);
            EndAction(true);
        }
    }
}
