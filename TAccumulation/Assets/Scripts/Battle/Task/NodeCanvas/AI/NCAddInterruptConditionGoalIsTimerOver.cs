using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("打断计时器是否结束条件")]
    [Name("AddInterruptConditionGoal_IsTimerOver")]
    public class NCAddInterruptConditionGoalIsTimerOver : NActorAIAction
    {
        public AIIsTimerOverConditionParams isTimerOver = new AIIsTimerOverConditionParams();

        protected override void OnExecute()
        {
            AddCondition<AIIsTimerOverConditionGoal>(isTimerOver);
            EndAction(true);
        }
    }
}
