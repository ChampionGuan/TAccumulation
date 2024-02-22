using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/关卡/Event")]
    [Name("交互物交互\nInterActorResult")]
    public class FEInterActorResult : FlowEvent
    {
        private EventInterActorDone _eventInterActorDone;
        private Action<EventInterActorDone> _action;

        public FEInterActorResult()
        {
            _action = _OnInterActorDone;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput("InsId", () => _eventInterActorDone?.insId);
            AddValueOutput("BattleActorId", () => _eventInterActorDone?.cfgId);
            AddValueOutput("Result", () => _eventInterActorDone?.res);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.InterActorDone, _action, "InterActorDone.EventInterActorDone");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.InterActorDone, _action);
        }

        private void _OnInterActorDone(EventInterActorDone eventInterActorDone)
        {
            if (_isTriggering || eventInterActorDone == null)
                return;
            
            _eventInterActorDone = eventInterActorDone;
            _Trigger();
        }
    }
}
