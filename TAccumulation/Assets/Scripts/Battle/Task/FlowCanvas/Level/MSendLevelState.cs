using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("给关卡发送机关状态\nSendMechanismStateToLevel")]
    public class MSendLevelState : FlowAction
    {
        public ValueInput<int> curState;
        public ValueInput<string> triggerMode;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            curState = AddValueInput<int>("curState");
            triggerMode = AddValueInput<string>("triggerMode");
        }

        protected override void _Invoke()
        {
            var machineType = MachineType.None;
            if (_actor.bornCfg is MachineBornCfg)
            {
                machineType = (_actor.bornCfg as MachineBornCfg).MachineType;
            }
            else
            {
                _LogError($"Actor bornConfig类型：{_actor.bornCfg.GetType()}， 无法转换为MachineBornCfg");
            }

            var eventData = _battle.eventMgr.GetEvent<EventMachineStateChange>();
            eventData.Init(_actor, machineType, curState.value, triggerMode.value);
            _battle.eventMgr.Dispatch(EventType.MachineStateChange, eventData);
        }
    }
}
