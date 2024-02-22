using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/条件")]
    [Name(("IsInGlobalCD"))]
    [Description("判断目标是否处于【全局技能间隔】冷却中")]
    public class NCIsInGlobalCD : BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();

        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            return actor.aiOwner != null && actor.aiOwner.IsInGlobalCD();
        }
    }
}
