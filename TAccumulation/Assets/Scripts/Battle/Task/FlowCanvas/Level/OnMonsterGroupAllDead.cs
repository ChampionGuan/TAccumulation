using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("（特殊）NpcGroup死亡监听器\nOnMonsterGroupAllDead")]
    public class OnMonsterGroupAllDead : FlowListener
    {
        public BBParameter<int> groupID = new BBParameter<int>();

        private Action<EventActorBase> _actionOnActorDead;
        private EventActorBase _eventActor;

        public OnMonsterGroupAllDead()
        {
            _actionOnActorDead = _OnActorDead;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput(nameof(Actor), () => _eventActor?.actor);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventActorBase>(EventType.ActorDead, _actionOnActorDead, "OnMonsterGroupAllDead._OnActorDead");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventActorBase>(EventType.ActorDead, _actionOnActorDead);
        }

        private void _OnActorDead(EventActorBase args)
        {
            if (IsReachMaxCount())
                return;
            var target = args.actor;
            if (!target.IsMonster())
            {
                return;
            }
            
            if (target.groupId <= 0 || target.groupId != groupID.value)
            {
                return;
            }
            
            if (!Battle.Instance.actorMgr.IsGroupAllDead(groupID.value, ActorType.Monster))
            {
                return;
            }

            _eventActor = args;
            _Trigger();
            _eventActor = null;
        }
    }
}
