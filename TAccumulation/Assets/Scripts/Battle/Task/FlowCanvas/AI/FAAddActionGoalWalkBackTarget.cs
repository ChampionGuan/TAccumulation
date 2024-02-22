using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("方向目标后退")]
    [Name("AddActionGoal_WalkBackTarget")]
    public class FAAddActionGoalWalkBackTarget : FActorAIAction
    {
        public AIWalkBackTargetActionParams walkBackTarget = new AIWalkBackTargetActionParams();
        
        protected override void _Invoke()
        {
            if (walkBackTarget.target.isNoneOrNull)
            {
                return;
            }
         
            AddAction<AIWalkBackTargetActionGoal>(walkBackTarget);
        }
    }
}
