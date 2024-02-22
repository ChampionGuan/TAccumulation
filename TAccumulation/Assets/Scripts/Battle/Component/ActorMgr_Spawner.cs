using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public partial class ActorMgr
    {
        /// <summary>
        /// Actor实例ID，
        /// 实例ID递减(在创建单位时由程序分配的唯一ID，区间：-10000~int.MinValue)，区分策划配置的种植ID(在关卡编辑器中由策划分配的ID,区间：10000~int.MaxValue)
        /// 实例ID小于0，种植ID大于0，等于0视为无效ID
        /// </summary>
        private int _nextActorInsID = BattleConst.MaxActorInsID;

        /// <summary>
        /// 创生物工厂
        /// </summary>
        private CreatureSpawner _creatureSpawner;

        /// <summary>
        /// Actor工厂类
        /// </summary>
        private Dictionary<ActorType, ActorSpawner> _actorSpawners;

        /// <summary>
        /// 动态构建的配置：法术场
        /// </summary>
        private Dictionary<int, SkillLevelCfg> _magicFieldSkillLevelCfgs = new Dictionary<int, SkillLevelCfg>();

        /// <summary>
        /// 动态构建的配置：法术场
        /// </summary>
        private Dictionary<int, SkillCfg> _magicFieldSkillCfgs = new Dictionary<int, SkillCfg>();

        /// <summary>
        /// 动态构建的配置：子弹
        /// </summary>
        private Dictionary<int, SkillLevelCfg> _missileSkillLevelCfgs = new Dictionary<int, SkillLevelCfg>();

        /// <summary>
        /// 动态构建的配置：子弹
        /// </summary>
        private Dictionary<int, SkillCfg> _missileSkillCfg = new Dictionary<int, SkillCfg>();

        /// <summary>
        /// 创建技能召唤物：法术场
        /// </summary>
        /// <returns></returns>
        public Actor CreateMagicField(DamageExporter master, int magicFieldID, Vector3 targetPos, Vector3 targetEuler, bool autoRelease = false, CreateMagicFieldParam createParam = null, FactionType? factionType = null)
        {
            if (null == master)
            {
                LogProxy.LogError("[ActorMgr.CreateMagicField]创建法术场失败，不允许召唤者为空, 请检查!");
                return null;
            }

            if (magicFieldID == 0)
            {
                return null;
            }

            var magicFieldCfg = TbUtil.GetCfg<MagicFieldCfg>(magicFieldID);
            if (magicFieldCfg == null)
            {
                LogProxy.LogErrorFormat("联系【楚门】：模块：{0} ID：{1} 创建法术场失败，法术场配置不存在, 请检查, 法术场ID:{2}!", master.GetType().Name, master.GetID(), magicFieldID);
                return null;
            }

            var level = master.GetLevel();
            if (!_magicFieldSkillLevelCfgs.TryGetValue(level, out var skillLvCfg))
            {
                skillLvCfg = new SkillLevelCfg
                {
                    Level = level
                };
                _magicFieldSkillLevelCfgs.Add(level, skillLvCfg);
            }

            if (!_magicFieldSkillCfgs.TryGetValue(magicFieldID, out var skillCfg))
            {
                skillCfg = new SkillCfg
                {
                    ID = magicFieldID,
                    Name = $"magicField {magicFieldID}",
                    ActionModuleIDs = new[] { magicFieldCfg.ActionModule },
                };
                _magicFieldSkillCfgs.Add(magicFieldID, skillCfg);
            }

            // 法术场位置在内部算，这里不需要算
            var actor = CreateAgentActor(master, magicFieldID, type: SkillAgentType.MagicField, factionType: factionType);
            if (actor == null)
            {
                return null;
            }

            //设置法术场是否贴地
            if (magicFieldCfg.isDown)
            {
                targetPos.y = BattleUtil.GetPosY();
            }

            // DONE: 策划需求, 法术场不能跑出地图外.
            targetPos = BattleUtil.GetNavMeshNearestPoint(targetPos);
            actor.transform.SetPosition(targetPos);
            actor.transform.SetEulerAngles(targetEuler);
            var slotID = actor.skillOwner.CreateMagicFieldSkill(master, skillCfg, skillLvCfg, skillLvCfg.Level, magicFieldCfg, createParam);
            // 自动释放技能
            if (autoRelease)
            {
                actor.skillOwner.TryCastSkillBySlot(slotID, safeCheck: false);
            }

            //设置法术场寻路信息
            if (actor.transform.updatePenalty != null)
            {
                actor.transform.updatePenalty.boyIsInclude = magicFieldCfg.boyAgentAvoid;
                actor.transform.updatePenalty.radius = magicFieldCfg.agentRadius;
            }

            return actor;
        }

        /// <summary>
        /// 创建技能召唤物：子弹
        /// </summary>
        /// <param name="master"></param>
        /// <param name="createParam"></param>
        /// <param name="ricochetShareData"></param>
        /// <param name="ricochetData"></param>
        /// <param name="transInfoCache"></param>
        /// <returns></returns>
        public Actor CreateMissile(DamageExporter master, CreateMissileParam createParam, RicochetShareData ricochetShareData = null, RicochetData? ricochetData = null, TransInfoCache transInfoCache = null)
        {
            if (null == master)
            {
                LogProxy.LogError("[ActorMgr.CreateMissile()]创建新子弹失败，不允许召唤者为空, 请检查!");
                return null;
            }

            var missileID = 0;
            if (createParam != null)
            {
                missileID = createParam.missileID;
            }
            else if (ricochetData != null)
            {
                missileID = ricochetData.Value.createMissileID;
            }

            if (missileID == 0)
            {
                return null;
            }

            var missileCfg = TbUtil.GetCfg<MissileCfg>(missileID);
            if (missileCfg == null)
            {
                LogProxy.LogErrorFormat("[ActorMgr.CreateMissile()]创建新子弹失败，技能子弹配置不存在, 请检查, missileID:{0}!", missileID);
                return null;
            }

            var level = master.GetLevel();
            if (!_missileSkillLevelCfgs.TryGetValue(level, out var skillLvCfg))
            {
                skillLvCfg = new SkillLevelCfg
                {
                    Level = level,
                };
                _missileSkillLevelCfgs.Add(level, skillLvCfg);
            }

            if (!_missileSkillCfg.TryGetValue(missileID, out var skillCfg))
            {
                skillCfg = new SkillCfg
                {
                    ID = missileID,
                    Name = $"missile {missileID}",
                };
                _missileSkillCfg.Add(missileID, skillCfg);
            }

            // 位置朝向逻辑层做，这里不用做
            var actor = CreateAgentActor(master, missileID, type: SkillAgentType.Missile);
            if (actor == null) return actor;

            // 创建子弹技能
            var target = master.actor.GetTarget(TargetType.Skill);
            var slotID = actor.skillOwner.CreateMissileSkill(master, skillCfg, skillLvCfg, missileCfg, createParam, ricochetShareData, ricochetData, transInfoCache: transInfoCache);
            actor.skillOwner.TryCastSkillBySlot(slotID, target, safeCheck: false);
            return actor;
        }

        /// <summary>
        /// 召唤创生物：怪
        /// </summary>
        /// <param name="masterSkill">召唤技能</param>
        /// <param name="summonId">MonsterTemplate.ID</param>
        /// <param name="pos">出生位置</param>
        /// <param name="angleY">出生朝向偏移</param>
        /// <param name="useWorldForward">使用世界朝向</param>
        /// <param name="factionType">所属阵营</param>
        /// <returns></returns>
        public Actor SummonMonster(ISkill masterSkill, int summonId, Vector3 pos, float angleY, bool useWorldForward = false, FactionType? factionType = null)
        {
            if (null == masterSkill)
            {
                return null;
            }

            var master = masterSkill.actor;
            if (master.isDead)
            {
                return null;
            }

            var battleSummon = TbUtil.GetCfg<BattleSummon>(summonId);
            if (battleSummon == null)
            {
                LogProxy.LogErrorFormat("请联系策划【卡宝】, BattleSummon配置获取失败, ID={0}", summonId);
                return null;
            }

            if (battleSummon.MaxNum <= 0)
            {
                LogProxy.LogErrorFormat("请联系策划【卡宝】, BattleSummon.MaxNum <=0");
                return null;
            }

            if (!TbUtil.TryGetCfg(battleSummon.Template, out MonsterCfg monsterCfg))
            {
                LogProxy.LogErrorFormat("请联系策划【五当/五当】,【ActorMgr.SummonCreature()】 角色configID:{0}的配置信息不存在, 进行检查!", battleSummon.Template);
                return null;
            }

            if (monsterCfg.CreatureType == CreatureType.None)
            {
                LogProxy.LogErrorFormat("请联系策划【程序】,【ActorMgr.SummonCreature()】 角色configID:{0}的CreatureType=None", battleSummon.Template);
                return null;
            }

            // DONE: 需要先将最早之前的Creature给Destroy掉.
            var summonCreatures = ObjectPoolUtility.CommonActorList.Get();
            var currNum = master.GetCreatures(battleSummon.ID, summonCreatures);
            if (battleSummon.MaxNum <= currNum)
            {
                summonCreatures[0].mainState?.SetDeadActionModule(battleSummon.DeadActionModule);
                summonCreatures[0].Dead();
            }

            ObjectPoolUtility.CommonActorList.Release(summonCreatures);

            // 构建出生点信息
            var actorPoint = new SummonCreaturePointData
            {
                Master = master,
                MasterSkill = masterSkill,
                SummonConfig = battleSummon,
                CreatureType = monsterCfg.CreatureType,
                ConfigID = monsterCfg.ID,
                FactionType = factionType ?? master.factionType,
                Position = BattleUtil.GetNavMeshNearestPoint(pos), //DONE: 策划需求, 所有召唤物不能跑出地图外.
                Rotation = useWorldForward ? new Vector3(0, angleY, 0) : Quaternion.LookRotation(Quaternion.AngleAxis(angleY, Vector3.up) * master.transform.forward).eulerAngles,
            };

            // DONE: 构建BornCfg
            // BattleSummon表里是==0启用，==1不启用.
            ActorSpawner spawner = _creatureSpawner;
            var bornCfg = spawner.CreateActorBornCfg<RoleBornCfg>(actorPoint);
            // DONE: 创生物类型直接采用配置表里的, 可用于判断一个Actor是否是创生物, 是哪种类型的创生物
            bornCfg.BornActionModule = monsterCfg.BornActionModule;
            bornCfg.DeadActionModule = monsterCfg.DeadActionModule;
            bornCfg.HurtLieDeadActionModule = monsterCfg.HurtLieDeadActionModule;
            // 不同创生物，单位构建工厂不同
            switch (monsterCfg.CreatureType)
            {
                case CreatureType.Monster:
                    spawner = _actorSpawners[ActorType.Monster];
                    break;
                case CreatureType.Substitute:
                    var actorTgt = master.GetTarget(monsterCfg.CopyTargetType);
                    if (actorTgt == null) return null;
                    spawner = _actorSpawners[ActorType.Monster];
                    // 从目标单位拷贝模型信息
                    bornCfg.ModelInfo.CopyFrom(actorTgt.model.config);
                    // ModelKey使用策划配置
                    bornCfg.ModelInfo.ModelKey = string.IsNullOrEmpty(monsterCfg.ModelKey) ? BattleConst.EmptyActorModelKey : monsterCfg.ModelKey;
                    // 使用创生物材质
                    bornCfg.Material = monsterCfg.CreatureMaterial;
                    break;
            }

            // 创建单位
            var actor = CreateActor(spawner, bornCfg, monsterCfg);
            if (null == actor)
            {
                return null;
            }

            // DONE: 预创建召唤动作模组.
            if (battleSummon.DeadActionModule > 0)
            {
                actor.sequencePlayer?.CreateFlowCanvasModule(battleSummon.DeadActionModule);
            }

            var collider = actor.collider;
            if (collider != null && !collider.HaveColliderType(ColliderType.Collider) && !collider.HaveColliderType(ColliderType.IgnoreCollision))
            {
                var shape = new BoundingShape
                {
                    ShapeType = ShapeType.Sphere,
                    Radius = 0.5f,
                };
                collider.AddCollider(ColliderType.IgnoreCollision, shape, ActorDummyType.Root);
            }

            // DONE: 召唤物, 免疫锁定&命中&伤害.
            if (battleSummon.EnableBeLocked == (int)SummonLocked.IgnoreLockHitDamage)
            {
                actor.stateTag.AcquireTag(ActorStateTagType.LockIgnore);
                actor.stateTag.AcquireTag(ActorStateTagType.HitIgnore);
                actor.stateTag.AcquireTag(ActorStateTagType.DamageImmunity);
            }

            //buff免疫标签
            if (battleSummon.IsImmunityAll)
            {
                actor.buffOwner.ImmunityAllBuff = true;
            }

            foreach (var tag in battleSummon.ImmunityTags)
            {
                actor.buffOwner.AddImmunityTag(tag);
            }

            LogProxy.LogFormat("新创建的创生物 insID={0}, level={1}, 技能masterSkill slotID={2}, skillLevel={3}", actor.insID, actor.level, masterSkill.slotID, masterSkill.level);
            return actor;
        }

        /// <summary>
        /// 召唤创生物：假身
        /// </summary>
        /// <returns></returns>
        public Actor SummonFakebody(Actor master)
        {
            if (null == master)
            {
                return null;
            }

            var pointCfg = ObjectPoolUtility.GetActorPointCfg<CreaturePointData>();
            pointCfg.Master = master;
            pointCfg.CreatureType = CreatureType.Fakebody;
            pointCfg.FactionType = master.factionType;
            pointCfg.Position = master.transform.position;
            pointCfg.Rotation = master.transform.eulerAngles;
            var bornCfg = _creatureSpawner.CreateActorBornCfg<ActorBornCfg>(pointCfg);

            pointCfg.Master = null;
            ObjectPoolUtility.ReleaseActorPointCfg(pointCfg);

            // 目前只有女主的假身模型数据，后续如果有其他类型角色的假身，修改此处即可！！
            bornCfg.ModelInfo.ModelKey = TbUtil.battleConsts.GirlFakebodyModelInfoKey;

            var actor = CreateActor(_creatureSpawner, bornCfg);
            if (null == actor) return actor;

            // 不可锁定，命中免疫，伤害免疫
            actor.stateTag.AcquireTag(ActorStateTagType.LockIgnore);
            actor.stateTag.AcquireTag(ActorStateTagType.HitIgnore);
            actor.stateTag.AcquireTag(ActorStateTagType.DamageImmunity);
            return actor;
        }

        /// <summary>
        /// 创建道具
        /// </summary>
        /// <param name="master"></param>
        /// <param name="itemLevel"></param>
        /// <param name="itemId"></param>
        /// <param name="pos"></param>
        /// <param name="angleY"></param>
        /// <returns></returns>
        public Actor CreateItem(Actor master, DamageExporter damageExporter, int itemLevel, int itemId, Vector3 pos, float angleY)
        {
            if (master.isDead)
            {
                return null;
            }

            if (itemId == 0)
            {
                return null;
            }

            var itemCfg = TbUtil.GetCfg<ItemCfg>(itemId);
            if (itemCfg == null)
            {
                LogProxy.LogErrorFormat("请联系策划【卡宝】, ItemCfg配置获取失败, ID={0}", itemId);
                return null;
            }

            var itemPoint = new ItemPointData
            {
                Name = itemCfg.Name,
                Master = master,
                damageExporter = damageExporter,
                FactionType = master.factionType,
                Level = itemLevel,
                ConfigID = itemId,
                Position = BattleUtil.GetNavMeshNearestPoint(pos), //DONE: 策划需求, 道具不能跑出地图外.
                Rotation = Quaternion.LookRotation(Quaternion.AngleAxis(angleY, Vector3.up) * master.transform.forward).eulerAngles,
                IsShowArrowIcon = itemCfg.IsShowArrowIcon,
            };
            return CreateActor(ActorType.Item, itemPoint);
        }

        public Actor CreateAgentActor(DamageExporter master, int ID, Vector3? pos = null, Vector3? forward = null, SkillAgentType type = SkillAgentType.Dynamic, FactionType? factionType = null)
        {
            if (null == master)
            {
                return null;
            }

            if (!_actorSpawners.TryGetValue(ActorType.SkillAgent, out var spawner))
            {
                LogProxy.LogError($"[ActorMgr.CreateSkillAgent()]创建Actor失败，不存在此类型的工厂类，请检查！ActorType:{ActorType.SkillAgent.ToString()}");
                return null;
            }

            var bornCfg = (spawner as SkillAgentSpawner).CreateActorBornCfg(master, ID, type, pos ?? master.actor.transform.position, forward ?? master.actor.transform.forward);
            if (factionType != null)
            {
                bornCfg.FactionType = factionType.Value;
            }

            return CreateActor(ActorType.SkillAgent, bornCfg);
        }

        public Actor CreateActor(ActorType actorType, PointBase pointCfg)
        {
            var bornCfg = _CreateBornCfg<ActorBornCfg>(actorType, pointCfg);
            return null == bornCfg ? null : CreateActor(actorType, bornCfg);
        }

        public Actor CreateActor(ActorSpawner spawner, PointBase pointCfg)
        {
            var bornCfg = _CreateBornCfg<ActorBornCfg>(spawner, pointCfg);
            return null == bornCfg ? null : CreateActor(spawner, bornCfg);
        }

        public Actor CreateActor(ActorType actorType, ActorBornCfg bornCfg, ActorCfg actorCfg = null)
        {
            if (null == bornCfg)
            {
                LogProxy.LogError($"[ActorMgr._CreateActor()]创建ActorBornCfg失败，参数ActorBornCfg不允许为空，请检查！ActorType:{actorType.ToString()}");
                return null;
            }

            if (!_actorSpawners.TryGetValue(actorType, out var spawner))
            {
                LogProxy.LogError($"[ActorMgr._CreateActor()]创建Actor失败，不存在此类型的工厂类，请检查！ActorType:{actorType.ToString()}");
                return null;
            }

            return CreateActor(spawner, bornCfg, actorCfg);
        }

        public Actor CreateActor(ActorSpawner spawner, ActorBornCfg bornCfg, ActorCfg actorCfg = null)
        {
            if (null == spawner)
            {
                return null;
            }

            var spawnID = bornCfg.SpawnID;
            if (spawnID != 0 && spawnID < BattleConst.MinActorSpawnID)
            {
                LogProxy.LogError($"[ActorMgr._CreateActor()]角色的种植ID不允许<{BattleConst.MinActorSpawnID}，请注意检查！");
                return null;
            }

#if UNITY_EDITOR
            if (null != GetActorBySpawnID(spawnID))
            {
                LogProxy.LogWarning($"[ActorMgr._CreateActor()]已存在相同关卡种植ID的对象，请确认合理性！种植ID:{spawnID}");
            }
#endif

            if (null == actorCfg)
            {
                actorCfg = spawner.CreateActorCfg(bornCfg);
                if (null == actorCfg)
                {
                    LogProxy.LogError($"[ActorMgr._CreateActor()]创建角色时，不允许角色配置为空，请留意检查！");
                    return null;
                }
            }

            var createCfg = bornCfg.CreateCfg;
            createCfg.ModelCfg.OverwriteDefault(actorCfg.ModelData);

            // 派发角色出生数据构建事件，可由外部进行后处理！
            var eventData = battle.eventMgr.GetEvent<EventCreateBeforeBornStep>();
            eventData.Init(bornCfg);
            battle.eventMgr.Dispatch(EventType.OnActorCreateBeforeBornStep, eventData);

            var insID = bornCfg.InsID = _nextActorInsID--;
            var actor = _TryGetActorFromCache(actorCfg, createCfg);
            if (null == actor)
            {
                try
                {
                    using (ProfilerDefine.CreateActor.Auto())
                    {
                        actor = spawner.CreateActor(actorCfg, createCfg.Copy());
                    }
                }
                catch (Exception e)
                {
                    LogProxy.LogError(e.ToString());
                }
            }

            if (actor == null) return null;

            //部分角色缓存
            switch (actor.type)
            {
                case ActorType.Hero:
                    // 非召唤单位
                    if (bornCfg.CreatureType != CreatureType.None) break;
                    switch ((HeroType)actor.subType)
                    {
                        case HeroType.Girl when null == girl:
                            girl = actor;
                            break;
                        case HeroType.Boy when null == boy:
                            boy = actor;
                            break;
                    }

                    break;
                case ActorType.Monster:
                    switch ((MonsterType)actor.subType)
                    {
                        case MonsterType.Boss when null == boss:
                            boss = actor;
                            break;
                    }

                    break;
                case ActorType.Stage:
                    stage = actor;
                    break;
            }

            if (null == player && bornCfg is RoleBornCfg roleBornCfg && roleBornCfg.IsPlayer)
            {
                player = actor;
            }

            if (spawnID >= BattleConst.MinActorSpawnID)
            {
                if (!_actorDictBySpawnID.TryGetValue(spawnID, out var list)) _actorDictBySpawnID[spawnID] = list = new List<Actor>();
                list.Add(actor);
            }

            _actorDictByInsID[insID] = actor;
            _actors.Add(actor);
            battle.AddEntity(actor.entity);

            actor.entity.Awake();
            actor.entity.Start();
            actor.Born(bornCfg);
            return actor;
        }

        private T _CreateBornCfg<T>(ActorType actorType, PointBase pointCfg) where T : ActorBornCfg
        {
            if (_actorSpawners.TryGetValue(actorType, out var spawner)) return _CreateBornCfg<T>(spawner, pointCfg);
            LogProxy.LogError($"[ActorMgr.CreateBornCfg()]创建ActorBornCfg失败，不存在此类型的工厂类，请检查！ActorType:{actorType.ToString()}");
            return null;
        }

        private T _CreateBornCfg<T>(ActorSpawner spawner, PointBase pointCfg) where T : ActorBornCfg
        {
            if (null != pointCfg) return spawner?.CreateActorBornCfg<T>(pointCfg);
            LogProxy.LogError("[ActorMgr.CreateBornCfg()]创建ActorBornCfg失败，参数ActorPoint不允许为空，请检查！");
            return null;
        }
    }
}