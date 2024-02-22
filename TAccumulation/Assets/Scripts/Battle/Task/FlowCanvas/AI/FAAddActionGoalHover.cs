using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("向目标徘徊")]
    [Name("AddActionGoal_Hover")]
    public class FAAddActionGoalHover : FActorAIAction
    {
        public AIHoverActionParams hover = new AIHoverActionParams();
        
        protected override void _Invoke()
        {
            if (hover.target.isNoneOrNull)
            {
                return;
            }
          
            AddAction<AIHoverActionGoal>(hover);
        }
    }
}
