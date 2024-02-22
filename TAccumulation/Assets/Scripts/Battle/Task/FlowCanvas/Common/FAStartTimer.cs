using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name(("启动计时器\nStartTimer"))]
    [Description("启动计时器")]
    public class FAStartTimer : FlowAction
    {
        public BBStartTimer startTimer = new BBStartTimer();

        protected override void _Invoke()
        {
            startTimer.Start(_actor);
        }
    }
}
