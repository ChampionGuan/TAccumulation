using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("判断是否有指定Buff")]
    public class HasBuff : BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<int> buffId = new BBParameter<int>();

        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            return actor.buffOwner.HasBuff(buffId.value);
        }
    }
}
