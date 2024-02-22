using System.Collections.Generic;
using JetBrains.Annotations;
using PapeGames.X3;

namespace X3Battle
{
    public partial class ActorMgr : BattleComponent
    {
        /// <summary>
        /// 关卡配置
        /// </summary>
        private StageConfig _stageConfig;

        /// <summary>
        /// 所有活跃的战斗单位
        /// </summary>
        private List<Actor> _actors = new List<Actor>();

        /// <summary>
        /// 所有活跃的战斗单位，key为实例ID
        /// </summary>
        private Dictionary<int, Actor> _actorDictByInsID = new Dictionary<int, Actor>();

        /// <summary>
        /// 所有活跃的策划种植的战斗单位，key为种植ID
        /// </summary>
        private Dictionary<int, List<Actor>> _actorDictBySpawnID = new Dictionary<int, List<Actor>>();

        /// <summary>
        /// 所有空闲的战斗单位
        /// </summary>
        private Dictionary<ActorType, Dictionary<int, List<Actor>>> _actorCache = new Dictionary<ActorType, Dictionary<int, List<Actor>>>();
        

        public List<Actor> actors => _actors;
        public Actor player { get; private set; }
        public Actor girl { get; private set; }
        public Actor boy { get; private set; }
        public Actor boss { get; private set; }
        public Actor stage { get; private set; }

        public StageConfig stageConfig => _stageConfig;
        public bool cacheEnabled { get; private set; } = true;

        public ActorMgr() : base(BattleComponentType.ActorMgr)
        {
            _actionStartCreateGroupMonster = _StartCreateGroupMonster;
            _actionTickCreateGroupMonster = _TickCreateGroupMonster;
            _actionCompleteCreateGroupMonster = _CompleteCreateGroupMonster;

            requiredPhysicalJobRunning = true;
            _actorGroups = new List<ActorGroup>();
            _stageConfig = TbUtil.GetCfg<StageConfig>(battle.config.StageID);
            _creatureSpawner = new CreatureSpawner(battle);
            _actorSpawners = new Dictionary<ActorType, ActorSpawner>
            {
                { ActorType.Hero, new HeroSpawner(battle) },
                { ActorType.Monster, new MonsterSpawner(battle) },
                { ActorType.Machine, new MachineSpawner(battle) },
                { ActorType.TriggerArea, new TriggerAreaSpawner(battle) },
                { ActorType.Obstacle, new ObstacleSpawner(battle) },
                { ActorType.SkillAgent, new SkillAgentSpawner(battle) },
                { ActorType.Item, new ItemSpawner(battle) },
                { ActorType.Stage, new StageSpawner(battle) },
                { ActorType.InterActor, new InterActorSpawner(battle) },
            };
        }

        protected override void OnAwake()
        {
            battle.eventMgr.AddListener<EventActor>(EventType.Actor, _OnActorLifeStateChanged, "ActorMgr._OnActorLifeStateChanged");
        }

        protected override void OnDestroy()
        {
            _ClearActorRefs();
            DestroyCacheActors(true);
            battle.eventMgr.RemoveListener<EventActor>(EventType.Actor, _OnActorLifeStateChanged);
            _magicFieldSkillLevelCfgs.Clear();
            _magicFieldSkillCfgs.Clear();
            _missileSkillCfg.Clear();
            _missileSkillLevelCfgs.Clear();
        }

        protected override void OnPhysicalJobRunning()
        {
            _TryRemoveRecycledActors();
        }

        public override void OnBattleShutDown()
        {
            RecycleAllActors();
        }

        public void SetCacheEnable(bool enabled)
        {
            if (cacheEnabled == enabled)
            {
                return;
            }

            if (!enabled)
            {
                DestroyCacheActors();
            }

            cacheEnabled = enabled;
        }

        public void DestroyCacheActors(bool ignoreRef = false)
        {
            foreach (var dict in _actorCache.Values)
            {
                foreach (var actors in dict.Values)
                {
                    for (var i = actors.Count - 1; i >= 0; i--)
                    {
                        var actor = actors[i];
                        if (!ignoreRef && actor.refCount > 0)
                        {
                            continue;
                        }

                        actor.entity.Destroy();
                        actors.RemoveAt(i);
                    }
                }
            }
        }

        public bool RecycleActor(Actor actor)
        {
            if (null == actor || actor.isRecycled)
            {
                return false;
            }

            if (!_actorDictByInsID.ContainsKey(actor.insID))
            {
                LogProxy.LogErrorFormat("[ActorMgr.RecycleActor()]Actor(id={0}, configId={1}) doesn't exist!", actor.insID, actor.cfgID);
                return false;
            }

            actor.Recycle();
            battle.RemoveEntity(actor.entity);
            return true;
        }

        public void RecycleAllActors()
        {
            for (var i = _actors.Count - 1; i >= 0; i--)
            {
                RecycleActor(_actors[i]);
            }
        }

        public int GetActorSpawnID(int insID)
        {
            var actor = GetActorByInsID(insID);
            return actor?.insID ?? BattleConst.InvalidActorID;
        }

        public int GetActorInsID(int spawnID)
        {
            var actor = GetActorBySpawnID(spawnID);
            return actor?.insID ?? BattleConst.InvalidActorID;
        }

        public Actor GetFirstMonster()
        {
            var actors = ObjectPoolUtility.CommonActorList.Get();
            GetActors(ActorType.Monster, null, actors);
            var actor = actors.Count > 0 ? actors[0] : null;
            ObjectPoolUtility.CommonActorList.Release(actors);
            return actor;
        }

        public Actor GetFirstActor(ActorType mainType, int? subType = null, bool includeSummoner = true)
        {
            var actors = ObjectPoolUtility.CommonActorList.Get();
            GetActors(mainType, subType, actors, includeSummoner: includeSummoner);
            var actor = actors.Count > 0 ? actors[0] : null;
            ObjectPoolUtility.CommonActorList.Release(actors);
            return actor;
        }

        public Actor GetActorByCfgID(int cfgId, bool includeSummoner = true)
        {
            var actors = ObjectPoolUtility.CommonActorList.Get();
            GetActors(cfgId: cfgId, outResults: actors, includeSummoner: includeSummoner);
            var actor = actors.Count > 0 ? actors[0] : null;
            ObjectPoolUtility.CommonActorList.Release(actors);
            return actor;
        }

        public int GetActorBySpawnID(int spawnID, List<Actor> outActors)
        {
            outActors?.Clear();
            if (!_actorDictBySpawnID.TryGetValue(spawnID, out var list)) return 0;
            outActors?.AddRange(list);
            return list.Count;
        }

        public Actor GetActorBySpawnID(int spawnID)
        {
            if (!_actorDictBySpawnID.TryGetValue(spawnID, out var list)) return null;
            var count = list.Count;
            return count < 1 ? null : list[count - 1];
        }

        public Actor GetActorByInsID(int insID)
        {
            return _actorDictByInsID.TryGetValue(insID, out var result) ? result : null;
        }

        public Actor GetActor(int id)
        {
            return id >= BattleConst.MinActorSpawnID ? GetActorBySpawnID(id) : id <= BattleConst.MaxActorInsID ? GetActorByInsID(id) : null;
        }

        public int GetActors(ActorType? mainType = null, int? subType = null, List<Actor> outResults = null, int? cfgId = null, bool includeSummoner = true)
        {
            var count = 0;
            outResults?.Clear();
            for (var i = 0; i < _actors.Count; i++)
            {
                var actor = _actors[i];
                if (null != mainType && actor.type != mainType)
                {
                    continue;
                }

                if (null != subType && actor.subType != subType.Value)
                {
                    continue;
                }

                if (null != cfgId && actor.cfgID != cfgId.Value)
                {
                    continue;
                }

                if (!includeSummoner && actor.IsSummoner())
                {
                    continue;
                }

                ++count;
                outResults?.Add(actor);
            }

            return count;
        }

        public void GetNotBornMonsterSpawnIDs(List<int> outIDs)
        {
            if (stageConfig == null || battle.statistics == null)
            {
                return;
            }

            outIDs.Clear();
            foreach (var spawnPointConfig in stageConfig.SpawnPoints)
            {
                if (spawnPointConfig.FactionType != FactionType.Monster)
                {
                    continue;
                }
                
                if (battle.statistics.GetActorInfo(spawnPointConfig.ID) == null)
                {
                    outIDs.Add(spawnPointConfig.ID); 
                }
            }
        }
        private void _TryRemoveRecycledActors()
        {
            for (var i = _actors.Count - 1; i >= 0; i--)
            {
                _TryRecycleActorToCache(_actors[i]);
            }
        }

        private void _TryRecycleActorToCache(Actor actor)
        {
            if (null == actor || !actor.isRecycled && !actor.isDestroyed)
            {
                return;
            }

            if (_actorDictBySpawnID.TryGetValue(actor.spawnID, out var list)) list.Remove(actor);
            _actorDictByInsID.Remove(actor.insID);
            _actors.Remove(actor);

            if (girl == actor)
            {
                girl = GetFirstActor(ActorType.Hero, (int)HeroType.Girl, includeSummoner: false);
            }
            else if (boy == actor)
            {
                boy = GetFirstActor(ActorType.Hero, (int)HeroType.Boy, includeSummoner: false);
            }
            else if (boss == actor)
            {
                boss = GetFirstActor(ActorType.Monster, (int)MonsterType.Boss, includeSummoner: false);
            }

            if (player == actor)
            {
                player = null;
            }

            // note:将此单位的所有召唤物上的召唤者信息置空！！
            foreach (var value in _actors)
            {
                if (null != value.master && value.master == actor)
                {
                    value.master.SetMasterNull();
                }
            }

            _TryAddActorToCache(actor);
        }

        private Actor _TryGetActorFromCache(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            if (!_actorCache.TryGetValue(actorCfg.Type, out var values) || !values.TryGetValue(actorCfg.ID, out var actors) || actors.Count <= 0) return null;

            var index = actors.Count;
            while (--index >= 0)
            {
                var actor = actors[index];
                if (actor.subType != actorCfg.SubType || actor.createCfg != createCfg || actor.isDestroyed || actor.refCount > 0) continue;

                actors.RemoveAt(index);
                return actor;
            }

            return null;
        }

        private void _TryAddActorToCache(Actor actor)
        {
            if (!actor.isRecycled)
            {
                return;
            }

            if (!cacheEnabled)
            {
                actor.entity.Destroy();
            }

            if (actor.isDestroyed)
            {
                return;
            }

            if (!_actorCache.ContainsKey(actor.type))
            {
                _actorCache.Add(actor.type, new Dictionary<int, List<Actor>>());
            }

            if (!_actorCache[actor.type].ContainsKey(actor.cfgID))
            {
                _actorCache[actor.type].Add(actor.cfgID, new List<Actor>());
            }

            if (_actorCache[actor.type][actor.cfgID].Contains(actor))
            {
                return;
            }

            _actorCache[actor.type][actor.cfgID].Add(actor);
            ObjectPoolUtility.ReleaseActorBornCfg(actor.bornCfg);
        }

        private void _ClearActorRefs()
        {
            RecycleAllActors();
            _TryRemoveRecycledActors();
            _DestroyAllGroup();
            _ResetTimerSpawnPoint();
            _actors.Clear();
            _actorDictByInsID.Clear();
            foreach (var list in _actorDictBySpawnID.Values) list.Clear();
            _nextActorInsID = BattleConst.MaxActorInsID;
            player = null;
            girl = null;
            boy = null;
            boss = null;
            stage = null;
        }

        private void _OnActorLifeStateChanged(EventActor data)
        {
            switch (data.state)
            {
                case ActorLifeStateType.Born:
                    _OnActorBorn(data.actor);
                    break;
                case ActorLifeStateType.Dead:
                    _OnActorDead(data.actor);
                    break;
                case ActorLifeStateType.Recycle:
                    _OnActorRecycled(data.actor);
                    break;
                case ActorLifeStateType.Destroy:
                    break;
            }
        }

        private void _OnActorBorn(Actor actor)
        {
            _InsertToActorGroup(actor);
            for (var i = 0; i < comps.Length; i++)
            {
                if (comps[i] == null)
                {
                    continue;
                }

                (comps[i] as IBattleComponent)?.OnActorBorn(actor);
            }
        }

        private void _OnActorDead(Actor actor)
        {
            // DONE: 当一个Actor死亡时, 将其所召唤的跟随母体死亡召唤物也清除掉.
            var list = ObjectPoolUtility.CommonActorList.Get();
            actor.GetCreatures(null, list);
            foreach (var creature in list)
            {
                if (creature.bornCfg.DeadWithMaster)
                {
                    creature.Dead();
                }
            }

            ObjectPoolUtility.CommonActorList.Release(list);
        }

        private void _OnActorRecycled(Actor actor)
        {
            _RemoveFromActorGroup(actor);
            for (var i = 0; i < comps.Length; i++)
            {
                if (comps[i] == null)
                {
                    continue;
                }

                (comps[i] as IBattleComponent)?.OnActorRecycle(actor);
            }
        }
    }
}