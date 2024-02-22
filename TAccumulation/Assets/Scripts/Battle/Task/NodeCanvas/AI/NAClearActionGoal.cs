using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("清除行为队列")]
    [Name("ClearActionGoal")]
    public class NAClearActionGoal : NActorAIAction
    {
        protected override void OnExecute()
        {
            ClearAllActions();
            EndAction(true);
        }
    }
}
