using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("延时（单位：毫秒ms）\nDelay")]
    public class FAWaitTime : FlowAction
    {
        private FlowOutput _triggeredOutput;
        [Name("延时（单位：毫秒ms）")] public BBParameter<float> delayTime = new BBParameter<float>();

        private Flow _flow;
        private int _timerId;
        private Action<int> _actionWaitComplete;

        public FAWaitTime()
        {
            _actionWaitComplete = _WaitComplete;
        }

        protected override void _OnRegisterPorts()
        {
            FlowOutput output = AddFlowOutput("Out");
            _triggeredOutput = AddFlowOutput("Triggered");
            FlowOutput interruptOutput = AddFlowOutput("Interrupt");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                // DONE: 直接出.
                output.Call(f);

                // DONE: 等待时间<=0, 则触发直接出.
                var waitTime = delayTime.GetValue() * 0.001f;
                if (waitTime <= 0f)
                {
                    _triggeredOutput.Call(f);
                    return;
                }

                _flow = f;

                if (_timerId > 0)
                {
                    _actor.timer.Discard(null, _timerId);
                    _timerId = 0;
                }

                _timerId = _actor.timer.AddTimer(null, delay: waitTime, tickInterval: 0f, funcComplete: _actionWaitComplete);
            });

            AddFlowInput("InterruptIn", (FlowCanvas.Flow f) =>
            {
                // DONE: 直接出.
                interruptOutput.Call(f);

                if (_timerId > 0)
                {
                    _actor.timer.Discard(null, _timerId);
                    _timerId = 0;
                }
            });
        }

        private void _WaitComplete(int id)
        {
            _triggeredOutput.Call(_flow);
            _timerId = 0;
        }
    }
}
