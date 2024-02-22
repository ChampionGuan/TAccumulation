using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("召唤创生物事件（主动）\nEvent：SummonCreature")]
    public class FESummonCreature : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventActorBase _eventActor;
        private Action<EventActorBase> _actionOnActorBorn;

        public FESummonCreature()
        {
            _actionOnActorBorn = _OnActorBorn;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput("SummonMaster", () => _eventActor?.actor?.master);
            AddValueOutput("SummonCreature", () => _eventActor?.actor); 
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventActorBase>(EventType.ActorBorn, _actionOnActorBorn, "FESummonCreature._OnActorBorn");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventActorBase>(EventType.ActorBorn, _actionOnActorBorn);
        }

        private void _OnActorBorn(EventActorBase arg)
        {
            if (_isTriggering || arg == null)
            {
                return;
            }
            
            if (arg.actor == null)
            {
                return;
            }

            // DONE: 判断是否是创建.
            if (!arg.actor.IsCreature())
            {
                return;
            }
            
            // DONE: 判断是否是图拥有着创建的创生物.
            if (!_IsMainObject(EventTarget.GetValue(), arg.actor.master))
                return;

            _eventActor = arg;
            _Trigger();
            _eventActor = null;
        }
    }
}
