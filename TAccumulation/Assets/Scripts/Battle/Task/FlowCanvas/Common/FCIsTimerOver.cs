using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("定时器是否结束\nIsTimerOver"))]
    [Description("定时器是否结束")]
    public class FCIsTimerOver : FlowCondition
    {
        public BBIsTimerOver isTimerOver = new BBIsTimerOver();
        
        protected override bool _IsMeetCondition()
        {
            return isTimerOver.IsOver(_actor);
        }
    }
}
