using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("关卡计时监听器\nListener:LevelTimer")]
    public class OnLevelTimeCountChange : FlowListener
    {
        public BBParameter<float> time = new BBParameter<float>();
        public BBParameter<ECompareOperator> comparison = new BBParameter<ECompareOperator>();
        private int _timerId;
        private Action<int, int> _actionTick;
        
        public OnLevelTimeCountChange()
        {
            _actionTick = _TickAction;
        }
        
        protected override void _RegisterEvent()
        {
            _timerId = _actor.timer.AddTimer(null, 0f, 0f, -1, "", null, _actionTick);
        }

        protected override void _UnRegisterEvent()
        {
            _actor.timer.Discard(null, _timerId);
            _timerId = 0;
        }

        private void _TickAction(int id, int repeatCount)
        {
            if (IsReachMaxCount())
                return;

            int curTime = (int)Battle.Instance.levelFlow.GetCurTime();
            if (!BattleUtil.IsCompareSize(curTime, time.value, comparison.value))
            {
                return;
            }

            _Trigger();
        }
    }
}
