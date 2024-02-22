using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    public enum ActorStateEventType
    {
        Born,
        Dead,
        All,
    }
    
    [Category("X3Battle/通用/Event")]
    [Name("Actor数量变化事件\nActorStateChange")]
    public class FEActorStateChange : FlowEvent
    {
        public BBParameter<int> monsterTemplateID = new BBParameter<int>(0);
        public FactionFlag factionFlag = FactionFlag.Monster;
        public IncludeSummonType includeSummonType = IncludeSummonType.AnyType;
        public ActorStateEventType actorStateEventType = ActorStateEventType.Born;
        
        private Action<EventActorBase> _actionOnActorBorn;
        private Action<EventActorBase> _actionOnActorDead;

        private Actor _actor;
        private int _count;

        public FEActorStateChange()
        {
            _actionOnActorBorn = _OnActorBorn;
            _actionOnActorDead = _OnActorDead;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput(nameof(Actor), () => _actor);
            AddValueOutput("RemainingCount", () => _count);
        }

        protected override void _RegisterEvent()
        {
            switch (actorStateEventType)
            {
                case ActorStateEventType.Born:
                    Battle.Instance.eventMgr.AddListener(EventType.ActorBorn, _actionOnActorBorn, "FEActorStateChange._OnActorBorn");
                    break;
                case ActorStateEventType.Dead:
                    Battle.Instance.eventMgr.AddListener(EventType.ActorDead, _actionOnActorDead, "FEActorStateChange._OnActorDead");
                    break;
                case ActorStateEventType.All:
                    Battle.Instance.eventMgr.AddListener(EventType.ActorBorn, _actionOnActorBorn, "FEActorStateChange._OnActorBorn");
                    Battle.Instance.eventMgr.AddListener(EventType.ActorDead, _actionOnActorDead, "FEActorStateChange._OnActorDead");
                    break;
            }
        }

        protected override void _UnRegisterEvent()
        {
            switch (actorStateEventType)
            {
                case ActorStateEventType.Born:
                    Battle.Instance.eventMgr.RemoveListener(EventType.ActorBorn, _actionOnActorBorn);
                    break;
                case ActorStateEventType.Dead:
                    Battle.Instance.eventMgr.RemoveListener(EventType.ActorDead, _actionOnActorDead);
                    break;
                case ActorStateEventType.All:
                    Battle.Instance.eventMgr.RemoveListener(EventType.ActorBorn, _actionOnActorBorn);
                    Battle.Instance.eventMgr.RemoveListener(EventType.ActorDead, _actionOnActorDead);
                    break;
            }
        }

        private void _OnActorBorn(EventActorBase args)
        {
            _TryTrigger(args);
        }

        private void _OnActorDead(EventActorBase args)
        {
            _TryTrigger(args);
        }

        private void _TryTrigger(EventActorBase args)
        {
            if (_isTriggering)
            {
                return;
            }

            var actor = args.actor;
            if (actor == null)
            {
                return;
            }
            
            if (monsterTemplateID.value > 0 && actor.cfgID != monsterTemplateID.value)
            {
                return;
            }

            if (!BattleUtil.ContainFactionType(factionFlag, actor.factionType))
            {
                return;
            }

            if (!BattleUtil.IsEligibleActor(actor, includeSummonType))
            {
                return;
            }

            _actor = args.actor;
            _count = _GetAliveActorCount();
            _Trigger();
            _actor = null;
            _count = 0;
        }

        private int _GetAliveActorCount()
        {
            int count = 0;
            foreach (var actor in _battle.actorMgr.actors)
            {
                if (actor.isDead)
                {
                    continue;
                }

                if (monsterTemplateID.value > 0 && actor.cfgID != monsterTemplateID.value)
                {
                    continue;
                }
                
                if (!BattleUtil.ContainFactionType(factionFlag, actor.factionType))
                {
                    continue;
                }
                
                if (!BattleUtil.IsEligibleActor(actor, includeSummonType))
                {
                    continue;
                }

                ++count;
            }
            return count;
        }
    }
}