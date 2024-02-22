using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("距离条件")]
    [Name("AddConditionGoal_Distance")]
    public class NCAddConditionGoalDistance : NActorAIAction
    {
        public AIDistanceConditionParams distance = new AIDistanceConditionParams();

        protected override void OnExecute()
        {
            AddCondition<AIDistanceConditionGoal>(distance);
            EndAction(true);
        }
    }
}
