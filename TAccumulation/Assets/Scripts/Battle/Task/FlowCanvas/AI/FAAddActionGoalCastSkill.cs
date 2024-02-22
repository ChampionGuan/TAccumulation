using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("释放技能")]
    [Name("AddActionGoal_CastSkill")]
    public class FAAddActionGoalCastSkill : FActorAIAction
    {
        public AICastSkillActionParams castSkill = new AICastSkillActionParams();

        protected override void _Invoke()
        {
            AddAction<AICastSkillActionGoal>(castSkill);
        }
    }
}
