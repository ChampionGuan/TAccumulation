using System;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("怪物击杀数监听器\nListener:MonsterKilledNum")]
    public class OnDeadMonsterCountChange : FlowListener
    {
        public BBParameter<int> targetValue = new BBParameter<int>();
        public BBParameter<int> groupID = new BBParameter<int>();
        [Name("MonsterTemplateID")]
        public BBParameter<int> templateID = new BBParameter<int>();
        public BBParameter<ECompareOperator> comparison = new BBParameter<ECompareOperator>();
        private int _deadCount;
        private Action<EventActorEnterStateBase> _actionActorEnterDeadState;

        public OnDeadMonsterCountChange()
        {
            _actionActorEnterDeadState = _OnActorEnterDeadState;
        }

        protected override void _OnActiveEnter()
        {
            if (templateID == null)
                return;
            _deadCount = Battle.Instance.actorMgr.GetDeadCount(ActorType.Monster, groupID.value, templateID.value);
            if (BattleUtil.IsCompareSize(_deadCount, targetValue.value, comparison.value))
            {
                _Trigger();
            }
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _actionActorEnterDeadState, "OnDeadMonsterCountChange._OnStateChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _actionActorEnterDeadState);
        }

        private void _OnActorEnterDeadState(EventActorEnterStateBase args)
        {
            if (IsReachMaxCount())
                return;
            if (args.actor.IsMonster())
            {
                if (groupID.value > 0 && args.actor.groupId != groupID.value)
                {
                    return;
                }
                _deadCount += 1;
                if (BattleUtil.IsCompareSize(_deadCount, targetValue.value, comparison.value))
                {
                    _Trigger();
                }
            }
        }
    }
}
