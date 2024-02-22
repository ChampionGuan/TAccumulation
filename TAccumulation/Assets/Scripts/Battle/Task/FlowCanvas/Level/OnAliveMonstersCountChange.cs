using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("怪物存活数量监听器\nListener:MonsterActiveNum")]
    public class OnAliveMonstersCountChange : FlowListener
    {
        public BBParameter<MonsterCountListenerMode> mode = new BBParameter<MonsterCountListenerMode>();
        public BBParameter<int> targetValue = new BBParameter<int>();
        public BBParameter<int> groupID = new BBParameter<int>();
        [Name("MonsterTemplateID")]
        public BBParameter<int> templateID = new BBParameter<int>();
        public BBParameter<ECompareOperator> comparison = new BBParameter<ECompareOperator>();
        private Action<EventActorBase> _onActorBorn;
        private Action<EventActorBase> _onActorDead;

        public OnAliveMonstersCountChange()
        {
            _onActorBorn = _OnActorBorn;
            _onActorDead = _OnActorDead;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventActorBase>(EventType.ActorBorn, _onActorBorn, "OnAliveMonstersCountChange._OnActorBorn");
            Battle.Instance.eventMgr.AddListener<EventActorBase>(EventType.ActorDead, _onActorDead, "OnAliveMonstersCountChange._OnActorDead");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventActorBase>(EventType.ActorBorn, _onActorBorn);
            Battle.Instance.eventMgr.RemoveListener<EventActorBase>(EventType.ActorDead, _onActorDead);
        }

        private void _OnActorBorn(EventActorBase args)
        {
            _OnStateChange(args);
        }
        
        private void _OnActorDead(EventActorBase args)
        {
            _OnStateChange(args);
        }
        
        private void _OnStateChange(EventActorBase args)
        {
            if (IsReachMaxCount())
                return;
            if (args.actor.type != ActorType.Monster)
                return;

            int monsterNum;
            if (templateID == null)
                return;

            if (mode.value == MonsterCountListenerMode.MonsterActiveFinish)
            {
                monsterNum = _battle.actorMgr.GetActiveCount(ActorType.Monster, groupID.value, templateID.value);
            }
            else
            {
                monsterNum = _battle.actorMgr.GetActiveCount(ActorType.Monster, groupID.value, templateID.value, true);
            }

            if (BattleUtil.IsCompareSize(monsterNum, targetValue.value, comparison.value))
            {
                _Trigger();
            }
        }
    }
}
