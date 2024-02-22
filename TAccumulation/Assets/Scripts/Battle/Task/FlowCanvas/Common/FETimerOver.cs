using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("计时器结束\nTimerOver")]
    public class FETimerOver : FlowEvent
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<int> timerId = new BBParameter<int>();
        private Action<EventTimerOver> _actionTimerOver;

        public FETimerOver()
        {
            _actionTimerOver = _OnTimerOver; 
        }

        protected override void _RegisterEvent()
        {
            if (source.isNoneOrNull)
            {
                return;
            }
            source.value.eventMgr.AddListener(EventType.TimerOver, _actionTimerOver, "FETimerOver._TimerOver");    
        }

        protected override void _UnRegisterEvent()
        {
            if (source.isNoneOrNull)
            {
                return;
            }
            source.value.eventMgr.RemoveListener(EventType.TimerOver, _actionTimerOver);
        }

        private void _OnTimerOver(EventTimerOver timerOver)
        {
            if (timerOver.timerId != timerId.value)
            {
                return;
            }
            _Trigger();
        }
    }
}
