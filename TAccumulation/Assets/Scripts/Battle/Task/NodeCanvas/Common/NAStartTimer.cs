using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Action")]
    [Name(("StartTimer"))]
    [Description("启动计时器")]
    public class NAStartTimer : BattleAction
    {
        public BBStartTimer startTimer = new BBStartTimer();
        
        protected override void OnExecute()
        {
            if (startTimer.Start(_actor))
            {
                EndAction(true);
            }
            else
            {
                EndAction(false);
            }
        }
    }
}
