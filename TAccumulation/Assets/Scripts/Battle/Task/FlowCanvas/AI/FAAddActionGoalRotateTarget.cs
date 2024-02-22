using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("转向目标")]
    [Name("AddActionGoal_RotateTarget")]
    public class FAAddActionGoalRotateTarget : FActorAIAction
    {
        public AIRotateTargetActionParams rotateTarget = new AIRotateTargetActionParams();
        
        protected override void _Invoke()
        {
            if (rotateTarget.target.isNoneOrNull)
            {
                return;
            }
        
            AddAction<AIRotateTargetActionGoal>(rotateTarget);
        }
    }
}
