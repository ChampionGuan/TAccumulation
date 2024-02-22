using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class BattleStrategy : BattleComponent
    {
        private List<GroupStrategy> _groupStrategies = new List<GroupStrategy>(4);
        private Action<EventActorBase> _actionActorBorn;
        private Action<EventActorBase> _actionActorDead;
        /// <summary>
        /// 真机调试器专用
        /// </summary>
        public List<GroupStrategy> groupStrategies => _groupStrategies;
        public BattleStrategy() : base(BattleComponentType.BattleStrategy)
        {
            _actionActorBorn = _OnActorBorn;
            _actionActorDead = _OnActorDead;
        }

        protected override void OnAwake()
        {
            List<Actor> actors = Battle.Instance.actorMgr.actors;
            foreach (Actor actor in actors)
            {
                _AddGroupStrategy(actor);
            }
            
            Battle.Instance.eventMgr.AddListener(EventType.ActorBorn, _actionActorBorn, "BattleStrategy._OnActorBorn");
            Battle.Instance.eventMgr.AddListener(EventType.ActorDead, _actionActorDead, "BattleStrategy._OnActorDead");
        }
        
        /// <summary>
        /// 添加群体策略对象
        /// </summary>
        /// <param name="actor"></param>
        private void _AddGroupStrategy(Actor actor)
        {
            if (!_isPlayerOrFriend(actor))
            {
                return;
            }

            if (_FindGroupStrategy(actor) != null)
            {
                return;
            }
            GroupStrategy groupStrategy = ObjectPoolUtility.ColonyStrategy.Get();
            groupStrategy.owner = actor;
            groupStrategy.Awake();
            _groupStrategies.Add(groupStrategy);
            _SendDebugEvent(true, groupStrategy);
        }
        
        /// <summary>
        /// 移除群体策略对象
        /// </summary>
        /// <param name="actor"></param>
        private void _RemoveGroupStrategy(Actor actor)
        {
            GroupStrategy groupStrategy = _FindGroupStrategy(actor);
            if (groupStrategy != null)
            {
                groupStrategy.Destroy();
                ObjectPoolUtility.ColonyStrategy.Release(groupStrategy);
                _groupStrategies.Remove(groupStrategy);
                _SendDebugEvent(false, groupStrategy);
            }
        }
        
        /// <summary>
        /// 查找群体策略对象
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        private GroupStrategy _FindGroupStrategy(Actor actor)
        {
            foreach (GroupStrategy colonyStrategy in _groupStrategies)
            {
                if (colonyStrategy.owner == actor)
                {
                    return colonyStrategy;
                }
            }
            return null;
        }

        protected override void OnUpdate()
        {
            foreach (GroupStrategy groupStrategy in _groupStrategies)
            {
                groupStrategy.Update();
            }
        }
        /// <summary>
        /// 角色、主控或者友方
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        private bool _isPlayerOrFriend(Actor actor)
        {
            if (!actor.IsRole())
            {
                return false;
            }

            return actor == battle.player || battle.player.GetFactionRelationShip(actor) == FactionRelationship.Friend;
        }
        
        /// <summary>
        /// 当角色出生
        /// </summary>
        /// <param name="eventActor"></param>
        private void _OnActorBorn(EventActorBase eventActor)
        {
            _AddGroupStrategy(eventActor.actor);
        }

        /// <summary>
        /// 当角色死亡
        /// </summary>
        /// <param name="eventActor"></param>
        private void _OnActorDead(EventActorBase eventActor)
        {
            _RemoveGroupStrategy(eventActor.actor);
        }

        protected override void OnDestroy()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.ActorBorn, _actionActorBorn);
            Battle.Instance.eventMgr.RemoveListener(EventType.ActorDead, _actionActorDead);

            foreach (GroupStrategy groupStrategy in _groupStrategies)
            {
                groupStrategy.Destroy();
                ObjectPoolUtility.ColonyStrategy.Release(groupStrategy);
            }
            _groupStrategies.Clear();
        }
        
        private void _SendDebugEvent(bool isAdd, GroupStrategy groupStrategy)
        {
            if(!BattleEnv.InDebugging) return;
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugGroupStrategyChange>();
            eventData.Init(isAdd, groupStrategy);
            Battle.Instance.eventMgr.Dispatch(EventType.DebugColonyStrategyChange, eventData);
        }

        public void PauseStrategy(bool pause)
        {
            foreach (GroupStrategy groupStrategy in _groupStrategies)
            {
                groupStrategy.Pause(pause);
            }
        }

        public void UpdateStrategy(Actor monster)
        {
            if (!monster.IsMonster())
            {
                return;
            }
            foreach (GroupStrategy groupStrategy in _groupStrategies)
            {
                if (groupStrategy.UpdateStrategy(monster))
                {
                    return;
                }
            }
        }
    }
}