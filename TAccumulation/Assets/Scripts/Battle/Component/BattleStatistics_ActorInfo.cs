using System.Collections.Generic;

namespace X3Battle
{
    public partial class BattleStatistics
    {
        /// <summary> {insID, ActorInfo} </summary>
        private Dictionary<int, ActorInfo> _actorInfos = new Dictionary<int, ActorInfo>();

        private void _ClearActorInfos()
        {
            foreach (var kActorInfo in _actorInfos)
            {
                ObjectPoolUtility.ActorInfoPool.Release(kActorInfo.Value);
            }

            _actorInfos.Clear();
        }

        private void _AddListener()
        {
            battle.eventMgr.AddListener<EventActorBase>(EventType.ActorBorn, _OnActorBorn, "BattleStatistics_ActorMgr._OnActorBorn");
            battle.eventMgr.AddListener<EventActorBase>(EventType.ActorDead, _OnActorDead, "BattleStatistics_ActorMgr._OnActorDead");
            battle.eventMgr.AddListener<EventActorBase>(EventType.ActorRecycle, _OnActorRecycle, "BattleStatistics_ActorMgr._OnActorRecycle");
        }

        private void _RemoveListener()
        {
            battle.eventMgr.RemoveListener<EventActorBase>(EventType.ActorBorn, _OnActorBorn);
            battle.eventMgr.RemoveListener<EventActorBase>(EventType.ActorDead, _OnActorDead);
            battle.eventMgr.RemoveListener<EventActorBase>(EventType.ActorRecycle, _OnActorRecycle);
        }

        private void _OnActorBorn(EventActorBase args)
        {
            var actor = args.actor;
            // 判断种植ID是否有效
            if (actor.spawnID < BattleConst.MinActorSpawnID) return;
            if (!_actorInfos.TryGetValue(actor.spawnID, out ActorInfo actorInfo))
            {
                actorInfo = ObjectPoolUtility.ActorInfoPool.Get();
                actorInfo.Init(actor.spawnID, actor.groupId, actor.cfgID, actor.type, actor.bornCfg?.CreatureType);
                _actorInfos.Add(actor.spawnID, actorInfo);
            }

            actorInfo.Born();
        }

        private void _OnActorDead(EventActorBase args)
        {
            var actor = args.actor;
            if (!_actorInfos.TryGetValue(actor.spawnID, out ActorInfo actorInfo))
            {
                return;
            }

            actorInfo.Dead();
        }

        private void _OnActorRecycle(EventActorBase args)
        {
            var actor = args.actor;
            if (!_actorInfos.TryGetValue(actor.spawnID, out ActorInfo actorInfo))
            {
                return;
            }

            actorInfo.Recycle();
        }

        public ActorInfo GetActorInfo(int spawnID)
        {
            ActorInfo result;
            _actorInfos.TryGetValue(spawnID, out result);
            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="outList"></param>
        /// <param name="actorType"> null 代表无视该条件 </param>
        /// <param name="groupID"> -1 代表无视该条件 </param>
        /// <param name="templateID"> -1 代表无视该条件 </param>
        /// <param name="spawnID"> -1 代表无视该条件 </param>
        /// <param name="state"> null 代表无视该条件 </param>
        public void QueryActorInfos(List<ActorInfo> outList, ActorType? actorType = null, int? groupID = null, int? templateID = null, int? spawnID = null, ActorInfo.State? state = null)
        {
            if (outList == null)
            {
                return;
            }

            foreach (var kActorInfo in _actorInfos)
            {
                var actorInfo = kActorInfo.Value;
                if (actorType != null && actorInfo.actorType != actorType)
                {
                    continue;
                }

                if (groupID != null && groupID > 0 && actorInfo.groupID != groupID)
                {
                    continue;
                }

                if (templateID != null && templateID > 0 && actorInfo.cfgID != templateID)
                {
                    continue;
                }

                if (spawnID != null && spawnID > 0 && actorInfo.spawnID != spawnID)
                {
                    continue;
                }

                if (state != null && actorInfo.state != state)
                {
                    continue;
                }

                outList.Add(actorInfo);
            }
        }
    }
}