using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("移动并释放技能")]
    [Name("AddActionGoal_MoveAndCastSkill")]
    public class FAAddActionGoalMoveAndCastSkill : FActorAIAction
    {
        public AIMoveAndCastSkillActionParams moveAndCastSkill = new AIMoveAndCastSkillActionParams();

        protected override void _Invoke()
        {
            if (moveAndCastSkill.target.isNoneOrNull)
            {
                return;
            }

            AddAction<AIMoveAndCastSkillActionGoal>(moveAndCastSkill);
        }
    }
}
