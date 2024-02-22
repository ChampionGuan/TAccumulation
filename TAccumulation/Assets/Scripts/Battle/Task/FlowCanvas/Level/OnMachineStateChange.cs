using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("机关状态监听器\nOnMachineStateChange")]
    public class OnMachineStateChange : FlowListener
    {
        [Name("SpawnID")]
        public BBParameter<int> insID = new BBParameter<int>();
        public BBParameter<int> machineState = new BBParameter<int>();
        public BBParameter<string> triggerMode = new BBParameter<string>();

        private Action<EventMachineStateChange> _actionOnMachineStateChange;

        public OnMachineStateChange()
        {
            _actionOnMachineStateChange = _OnMachineStateChange;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventMachineStateChange>(EventType.MachineStateChange, _actionOnMachineStateChange, "OnMachineStateChange._OnMachineStateChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventMachineStateChange>(EventType.MachineStateChange, _actionOnMachineStateChange);
        }

        private void _OnMachineStateChange(EventMachineStateChange eventData)
        {
            if (IsReachMaxCount())
                return;
            if (eventData == null)
                return;
            if (eventData.Actor.spawnID != insID.GetValue())
                return;
            if (eventData.State != machineState.GetValue())
                return;
            if (eventData.TriggerMode != triggerMode.GetValue())
                return;
            _Trigger();
        }
    }
}
