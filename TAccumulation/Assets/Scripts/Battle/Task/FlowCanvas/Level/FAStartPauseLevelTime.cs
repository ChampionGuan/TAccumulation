using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("暂停|继续关卡计时\nSetTimerPause")]
    public class FAStartPauseLevelTime : FlowAction
    {
        public BBParameter<bool> isPause = new BBParameter<bool>(false);

        protected override void _Invoke()
        {
            var paused = isPause.GetValue();
            Battle.Instance.levelFlow.Pause(paused);
        }
    }
}
