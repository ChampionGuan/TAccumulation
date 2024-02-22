using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("与或门逻辑\nAndOr")]
    public class FAAndOr : FlowNode
    {
        public BBParameter<int> orTimes = new BBParameter<int>();
        public BBParameter<int> andTimes = new BBParameter<int>();

        private FlowOutput _orOutput;
        private FlowOutput _andOutput;

        private int _orCount;
        private int _andCount;
        private int _andState;

        protected override void RegisterPorts()
        {
            _orOutput = AddFlowOutput("Or");
            _andOutput = AddFlowOutput("And");

            AddFlowInput("In1", flow => { _Invoke(-1); });
            AddFlowInput("In2", flow => { _Invoke(1); });

            _Reset();
        }

        public override void OnGraphStarted()
        {
            _Reset();
        }

        private void _Reset()
        {
            _orCount = 0;
            _andCount = 0;
            _andState = 0;
        }

        private void _Invoke(int state)
        {
            _Or();
            _And(state);
        }

        private void _Or()
        {
            // DONE: Or放水次数达到限制.
            if (_orCount >= orTimes.GetValue())
                return;
            ++_orCount;
            _orOutput.Call(Flow.New);
        }

        private void _And(int state)
        {
            // DONE: And放水次数达到限制
            if (_andCount >= andTimes.GetValue())
                return;
            // DONE: 等到两个流都进入了才执行.
            _andState += state;
            if (_andState < 0) _andState = -1;
            if (_andState > 0) _andState = 1;
            if (_andState != 0)
                return;
            ++_andCount;
            _andOutput.Call(Flow.New);
        }
    }
}
