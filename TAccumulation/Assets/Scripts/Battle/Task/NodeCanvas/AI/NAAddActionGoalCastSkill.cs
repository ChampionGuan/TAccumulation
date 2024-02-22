using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("释放技能")]
    [Name("AddActionGoal_CastSkill")]
    public class NAAction_CastSkill : NActorAIDecorator
    {
        public AICastSkillActionParams castSkill = new AICastSkillActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            var result = AddAction<AICastSkillActionGoal>(castSkill, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("释放技能")]
    [Name("AddActionGoal_CastSkill")]
    public class NAAddActionGoalCastSkill : NActorAIAction
    {
        public AICastSkillActionParams castSkill = new AICastSkillActionParams();

        protected override void OnExecute()
        {
            var result = AddAction<AICastSkillActionGoal>(castSkill);
            EndAction(result);
        }

        protected override string info
        {
            get { return "CastSkill" + "【"+castSkill.skillIndex.ToString()+"】" ; }
        }
    }
}
