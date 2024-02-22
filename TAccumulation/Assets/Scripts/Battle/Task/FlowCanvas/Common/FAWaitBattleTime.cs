using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("等待战斗时间\nWaitBattleTime")]
    public class FAWaitBattleTime : FlowAction
    {
        [Name("WaitTime(秒)")]
        public BBParameter<float> WaitTime = new BBParameter<float>(1f);

        private FlowOutput _triggeredOutput;
        private Flow _flow;
        private int _timerId;
        private Action<int> _actionWaitComplete;

        public FAWaitBattleTime()
        {
            _actionWaitComplete = _WaitComplete;
        }

        protected override void _OnRegisterPorts()
        {
            var o = AddFlowOutput("Out");
            _triggeredOutput = AddFlowOutput("Triggered");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                // DONE: 直接出.
                o.Call(f);

                // DONE: 等待时间<=0, 则触发直接出.
                var waitTime = WaitTime.GetValue();
                if (waitTime <= 0f)
                {
                    _triggeredOutput.Call(f);
                    return;
                }
                
                _flow = f;
                
                if (_timerId != null)
                {
                    _battle.battleTimer.Discard(null, _timerId);
                    _timerId = 0;
                }
                
                _timerId = _battle.battleTimer.AddTimer(null, delay: waitTime, funcComplete: _actionWaitComplete);
            });
        }

        private void _WaitComplete(int id)
        {
            _triggeredOutput.Call(_flow);
            _timerId = 0;
        }
    }
}
