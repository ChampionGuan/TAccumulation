using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("怪物出生监听器\nMonsterBorn")]
    public class OnMonsterBorn : FlowListener
    {
        [Description("角色实例ID, -1 代表不开启条件判断")]
        [Name("SpawnID")]
        public BBParameter<int> InsID = new BBParameter<int>(-1);
        [Description("怪物所属队伍, -1 代表不开启条件判断")]
        public BBParameter<int> GroupID = new BBParameter<int>(-1);
        [Description("怪物模板ID, -1 代表不开启条件判断")]
        [Name("MonsterTemplateID")]
        public BBParameter<int> MonsterID = new BBParameter<int>(-1);

        private Action<EventActorBase> _actionActorBorn;
        private EventActorBase _eventActor;

        public OnMonsterBorn()
        {
            _actionActorBorn = _OnEventActor;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput(nameof(Actor), () => _eventActor?.actor);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.ActorBorn,  _actionActorBorn, "OnMonsterBorn._OnEventActor");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.ActorBorn,  _actionActorBorn);
        }

        private void _OnEventActor(EventActorBase args)
        {
            if (IsReachMaxCount())
            {
                return;
            }
            
            if (args?.actor == null)
            {
                return;
            }
            
            var actor = args.actor;
            if (!actor.IsMonster())
            {
                return;
            }
            
            var spawnID = InsID.GetValue();
            if (spawnID > 0 && actor.spawnID != spawnID)
            {
                return;
            }
            
            var groupID = GroupID.GetValue();
            if (groupID > 0 && actor.groupId != groupID)
            {
                return;
            }

            var monsterID = MonsterID.GetValue();
            if (monsterID > 0 && args.actor.config.ID != monsterID)
            {
                return;
            }

            _eventActor = args;
            _Trigger();
            _eventActor = null;
        }
    }
}
