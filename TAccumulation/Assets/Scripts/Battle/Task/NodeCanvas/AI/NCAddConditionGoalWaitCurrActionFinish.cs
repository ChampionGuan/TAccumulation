using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("等待当前行为结束")]
    [Name("AddConditionGoal_WaitCurrActionFinish")]
    public class NCAddConditionGoalWaitCurrActionFinish : NActorAIAction
    {
        public AIWaitCurrActionFinishConditionParams source = new AIWaitCurrActionFinishConditionParams();

        protected override void OnExecute()
        {
            AddCondition<AIWaitCurrActionFinishConditionGoal>(source);
            EndAction(true);
        }
    }
}
