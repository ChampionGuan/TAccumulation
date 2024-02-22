using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Condition")]
    [Name(("IsTimerOver"))]
    [Description("定时器是否结束")]
    public class NCIsTimerOver : BattleCondition
    {
        public BBIsTimerOver isTimerOver = new BBIsTimerOver();
        
        protected override bool OnCheck()
        {
            return isTimerOver.IsOver(_actor);
        }
    }
}
