using System;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("Actor即将死亡事件\nActorPreDead")]
    public class FEActorPreDead : FlowEvent
    {
        public FactionFlag factionFlag = FactionFlag.Monster;

        private Action<EventActorBase> _actionActorPreDead;
        private Actor _actor;

        public FEActorPreDead()
        {
            _actionActorPreDead = _OnPreDead;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput(nameof(Actor), () => _actor);
        }

        protected override void _RegisterEvent()
        {
            _battle.eventMgr.AddListener(EventType.ActorPreDead, _actionActorPreDead, "FEActorPreDead._OnPreDead");
        }

        protected override void _UnRegisterEvent()
        {
            _battle.eventMgr.RemoveListener(EventType.ActorPreDead, _actionActorPreDead);
        }

        private void _OnPreDead(EventActorBase args)
        {
            var target = args?.actor;
            if (target == null)
            {
                return;
            }

            if (!BattleUtil.ContainFactionType(factionFlag, target.factionType))
            {
                return;
            }

            _actor = target;
            _Trigger();
            _actor = null;
        }
    }
}