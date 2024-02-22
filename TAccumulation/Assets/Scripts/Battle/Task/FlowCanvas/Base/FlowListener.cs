using FlowCanvas;
using NodeCanvas.Framework;

namespace X3Battle
{
    public abstract class FlowListener : BattleFlowNode
    {
        protected FlowInput _activeInput;
        protected FlowInput _disableInput;
        protected FlowOutput _outInput;
        protected FlowOutput _triggeredOutput;
        public BBParameter<int> times = new BBParameter<int>(1);

        protected int _remainTimes;
        protected bool _isRegisterEvent;

        protected sealed override void _OnRegisterPorts()
        {
            _activeInput = AddFlowInput("Active", _OnActiveInput);
            _disableInput = AddFlowInput("Disable", _OnDisableInput);
            _outInput = AddFlowOutput("Out");
            _triggeredOutput = AddFlowOutput("Triggered");

            _OnAddPorts();
        }

        protected void _OnActiveInput(Flow flow)
        {
            this._TryRegisterEvent();
            _OnActiveEnter();
            _outInput.Call(flow);
        }

        protected virtual void _OnActiveEnter()
        {
            
        }

        protected void _OnDisableInput(Flow flow)
        {
            this._TryUnregisterEvent();
            _outInput.Call(flow);
        }

        protected virtual void _OnAddPorts()
        {
        }

        protected sealed override void _OnPostGraphStarted()
        {
            base._OnPostGraphStarted();
            _remainTimes = times.GetValue();
        }

        protected sealed override void _OnPostGraphStoped()
        {
            base._OnPostGraphStoped();
            this._TryUnregisterEvent();
        }

        private void _TryRegisterEvent()
        {
            if (_isRegisterEvent)
                return;
            _isRegisterEvent = true;
            _RegisterEvent();
        }

        private void _TryUnregisterEvent()
        {
            if (!_isRegisterEvent)
                return;
            _isRegisterEvent = false;
            _UnRegisterEvent();
        }

        protected abstract void _RegisterEvent();
        protected abstract void _UnRegisterEvent();

        protected bool IsReachMaxCount()
        {
            return _remainTimes <= 0;
        }

        protected void _Trigger()
        {
            if (IsReachMaxCount())
                return;
            --_remainTimes;
            _triggeredOutput.Call(new FlowCanvas.Flow());
        }
        
#if UNITY_EDITOR
        protected override void OnNodeGUI()
        {
            base.OnNodeGUI();

            if (UnityEngine.Application.isPlaying)
            {
                UnityEditor.EditorGUILayout.LabelField($"剩余可触发次数: {_remainTimes}");   
            }
        }
#endif
    }
}
