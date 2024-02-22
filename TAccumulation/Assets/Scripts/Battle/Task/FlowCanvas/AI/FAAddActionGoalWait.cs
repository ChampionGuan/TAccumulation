using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("阻塞行为队列")]
    [Name("AddActionGoal_Wait")]
    public class FAAddActionGoalWait : FActorAIAction
    {
        public AIActionParams wait = new AIActionParams();

        protected override void _Invoke()
        {
            AddAction<AIWaitActionGoal>(wait);
        }
    }
}
