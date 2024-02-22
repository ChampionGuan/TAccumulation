using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Name(("IsInQTEActive"))]
    [Category("X3Battle/AI")]
    [Description("判断目标是否处于QTE激活状态")]
    public class NCIsInQTEActive : BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();

        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            return actor.skillOwner?.qteController?.isActive ?? false;
        }
    }
}