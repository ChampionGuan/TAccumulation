using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("每隔一段时间（监听器）\nOnIntervalGraphTime")]
    public class OnIntervalGraphTime : FlowListener
    {
        [Name("IntervalTime(秒)")]
        public BBParameter<float> IntervalTime = new BBParameter<float>();
        public BBParameter<bool> Immediately = new BBParameter<bool>();

        private int _timerId;
        private Action<int, int> _actionTick;

        public OnIntervalGraphTime()
        {
            _actionTick = _TickAction;
        }

        protected override void _RegisterEvent()
        {
            var immediately = Immediately.GetValue();
            if (immediately)
            {
                _Trigger();
            }

            var intervalTime = _GetIntervalTime();
            _timerId = _actor.timer.AddTimer(null, 0f, intervalTime, -1, "", null, _actionTick);
        }

        protected override void _UnRegisterEvent()
        {
            _actor.timer.Discard(null, _timerId);
            _timerId = 0;
        }

        private void _TickAction(int id, int repeatCount)
        {
            _Trigger();
        }

        private float _GetIntervalTime()
        {
            var intervalTime = IntervalTime.GetValue();
            return intervalTime < 0f ? 0 : intervalTime;
        }
    }
}
