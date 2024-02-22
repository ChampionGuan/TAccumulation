using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/行为队列")]
    [Description("打断是否不处于【全局技能间隔】冷却中条件")]
    [Name("AddInterruptConditionGoal_NotInGlobalCD")]
    public class NCAddInterruptConditionGoalNotInGlobalCD : NActorAIAction
    {
        public AINotInGlobalCDConditionParams notInGlobalCD = new AINotInGlobalCDConditionParams();

        protected override void OnExecute()
        {
            AddCondition<AINotInGlobalCDConditionGoal>(notInGlobalCD);
            EndAction(true);
        }
    }
}
