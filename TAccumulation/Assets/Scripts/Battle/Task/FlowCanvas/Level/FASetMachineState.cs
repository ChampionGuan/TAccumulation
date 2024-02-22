using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("设置机关状态\nSetMachineState")]
    public class FASetMachineState : FlowAction
    {
        public BBParameter<int> targetInsId = new BBParameter<int>();
        public BBParameter<int> machineState = new BBParameter<int>();

        protected override void _Invoke()
        {
            // DONE: 设置机关状态.
            var eventData = _battle.eventMgr.GetEvent<EventSetMachineState>();
            eventData.Init(targetInsId.GetValue(), machineState.GetValue());
            _battle.eventMgr.Dispatch(EventType.SetMachineState, eventData);
        }
    }
}
