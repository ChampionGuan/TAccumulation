using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("移动并释放技能")]
    [Name("AddActionGoal_MoveAndCastSkill")]
    public class NAAction_MoveAndCastSkill : NActorAIDecorator
    {
        public AIMoveAndCastSkillActionParams moveAndCastSkill = new AIMoveAndCastSkillActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (moveAndCastSkill.target.isNoneOrNull)
            {
                return Status.Failure;
            }


            var result = AddAction<AIMoveAndCastSkillActionGoal>(moveAndCastSkill);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("移动并释放技能")]
    [Name("AddActionGoal_MoveAndCastSkill")]
    public class NAAddActionGoalMoveAndCastSkill : NActorAIAction
    {
        public AIMoveAndCastSkillActionParams moveAndCastSkill = new AIMoveAndCastSkillActionParams();

        protected override void OnExecute()
        {
            if (moveAndCastSkill.target.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var result = AddAction<AIMoveAndCastSkillActionGoal>(moveAndCastSkill);
            EndAction(result);
        }

        protected override string info
        {
            get { return "MoveTo" + "【" + moveAndCastSkill.radius + "】" + " CastSkill" + "【" + moveAndCastSkill.skillIndex.ToString() + "】"; }
        }
    }
}
