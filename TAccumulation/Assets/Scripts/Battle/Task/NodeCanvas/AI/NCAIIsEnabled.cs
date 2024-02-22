using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("判断AI是否开启")]
    public class NCAIIsEnabled : BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();

        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            return actor.aiOwner?.enabled ?? false;
        }
    }
}
