using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/条件")]
    [Name(("IsInsideScreen"))]
    [Description("判断目标是否处于镜头内")]
    public class IsInsideScreen : BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();

        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            return BattleUtil.GetPositionIsInViewByPosition(actor.transform.position);
        }
    }
}
