using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/关卡/Event")]
    [Name("监听设置机关状态的消息(InsID需要相等)\nMReceiveStateChange")]
    public class MReceiveStateChange : FlowEvent
    {
        protected int _state;

        private Action<EventSetMachineState> _actionSetMachineState;

        public MReceiveStateChange()
        {
            _actionSetMachineState = OnSetState;
        }
        
        protected override void _OnAddPorts()
        {
            base._OnAddPorts();
            AddValueOutput("state", () => _state);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventSetMachineState>(EventType.SetMachineState, _actionSetMachineState, "MReceiveStateChange.OnSetState");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventSetMachineState>(EventType.SetMachineState, _actionSetMachineState);
        }

        private void OnSetState(EventSetMachineState par)
        {
            if (_isTriggering)
            {
                return;
            }

            _state = par.State;
            if (_actor == null)
            {
                return;
            }
            if (_actor.insID != par.InsID)
            {
                return;
            }
            _Trigger();
        }
    }
}
