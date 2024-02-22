using System;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;
using UnityEngine.Profiling;

namespace X3Battle
{
    public enum OnSkillStep
    {
        Start,
        End,
    }
    
    public class SkillSlotTypeComparer : IEqualityComparer<SkillSlotType>
    {
        public bool Equals(SkillSlotType x, SkillSlotType y)
        {
            return x == y;
        }

        public int GetHashCode(SkillSlotType obj)
        {
            return (int)obj;
        }
    }

    public class EntityData
    {
        public int spawnID;
        public ActorType actorType;
        public float leftHp = 0; //剩余生命
        public float maxHp = 0; //最大生命
        public float damageGet = 0; //受到的总伤害
        public float cureGive = 0; //造成的总治愈
        public float cureGet = 0; // 受到的总治愈
        public float damageGive = 0; //造成的总伤害
        public float bornTm = 0;
        public float deadTm = 0;
        public int configID = 0;

        private static SkillSlotTypeComparer comparer = new SkillSlotTypeComparer();

        // 技能伤害按种类汇总
        public Dictionary<SkillSlotType, float> skillDamageSum = new Dictionary<SkillSlotType, float>(15, comparer);

        // 技能时间按种类汇总
        public Dictionary<SkillSlotType, float> skillTimeSum = new Dictionary<SkillSlotType, float>(15, comparer);

        // 技能次数按种类汇总
        public Dictionary<SkillSlotType, int> skillCastCountSum = new Dictionary<SkillSlotType, int>(15, comparer);

        // 技能命中次数
        public Dictionary<SkillSlotType, int> skillHitCount = new Dictionary<SkillSlotType, int>(15, comparer);

        // 技能伤害按种类汇总
        public List<SkillSlotType> skillIDList = new List<SkillSlotType>();
        public Dictionary<int, float> skillCastTime = new Dictionary<int, float>(100);
    }
    

    public partial class BattleStatistics : BattleComponent
    {
        private bool _result = false;
        private string _uid = "default";
        private int _scoreSetGroupId = 0;
        private int _scoreSetId = 0;
        private int _dungeonId = 0;
        private int _dungeonGroupId = 0;
        private int _weaponSetId = 0;
        private int _count = 0;
        private float _time = 0;
        private string _path = ""; //"../Tools/verifybattle/results"

        private Dictionary<int, EntityData> _entities = new Dictionary<int, EntityData>();
        public Dictionary<int, int> killMonsters = new Dictionary<int, int>();

        public Dictionary<QTEResultType, Dictionary<int, int>> qte =
            new Dictionary<QTEResultType, Dictionary<int, int>>()
            {
                [QTEResultType.Perfect] = new Dictionary<int, int>(),
                [QTEResultType.Success] = new Dictionary<int, int>(),
            };

        private List<EntityData> _entityDatas = new List<EntityData>();
        private HashSet<int> _tempIDS = new HashSet<int>();
        
        /// <summary> 是否爆衫过 </summary>
        public bool isAlreadyBrokenSuit { get; private set; }

        public Dictionary<int, EntityData> entities
        {
            get => _entities;
            set => _entities = value;
        }

        public BattleStatistics() : base(BattleComponentType.BattleStatistics)
        {
            for (int i = 0; i < 20; i++)
            {
                var emptyData = NewEmptyEntityData();
                _entityDatas.Add(emptyData);
                _entities[i] = emptyData;
                _tempIDS.Add(i);
            }
            _entities.Clear();
        }

        public EntityData GetEntityData(int entityID)
        {
            _entities.TryGetValue(entityID, out var data);
            return data;
        }
        
        public void SetWritePath(string path)
        {
            _path = path;
        }

        protected override void OnStart()
        {
            base.OnStart();
            battle.eventMgr.AddListener<EventBattleEnd>(EventType.OnBattleEnd, OnBattleEnd, "BattleStatistics.OnBattleEnd");
            _AddListener();
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            battle.eventMgr.RemoveListener<EventBattleEnd>(EventType.OnBattleEnd, OnBattleEnd);
            _RemoveListener();
            _ClearActorInfos();
        }

        public override void OnBattleBegin()
        {
            battle.eventMgr.AddListener<EventActorBase>(EventType.ActorDead, OnActorDead, "BattleStatistics.OnActorDead");
            battle.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, OnSkill, "BattleStatistics.OnSkill");
            battle.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, OnSkillEnd, "BattleStatistics.OnSkillEnd");
            battle.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, OnExportDamage, "BattleStatistics.OnExportDamage");
            battle.eventMgr.AddListener<EventQTEButton>(EventType.QTEButtonPerfect, OnQTEButtonPerfectEvent, "BattleStatistics.OnQTEButtonPrefectEvent");
            battle.eventMgr.AddListener<EventQTEButton>(EventType.QTEButtonSuccess, OnQTEButtonSuccessEvent, "BattleStatistics.OnQTEButtonSuccessEvent");
            battle.eventMgr.AddListener<EventActorChangeParts>(EventType.ActorChangeParts, _OnActorChangeParts, "BattleStatistics._OnActorChangeParts");
        }

        public override void OnBattleEnd()
        {
            battle.eventMgr.RemoveListener<EventActorBase>(EventType.ActorDead, OnActorDead);
            battle.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, OnSkill);
            battle.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, OnSkillEnd);
            battle.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, OnExportDamage);
            battle.eventMgr.RemoveListener<EventQTEButton>(EventType.QTEButtonPerfect, OnQTEButtonPerfectEvent);
            battle.eventMgr.RemoveListener<EventQTEButton>(EventType.QTEButtonSuccess, OnQTEButtonSuccessEvent);
            battle.eventMgr.RemoveListener<EventActorChangeParts>(EventType.ActorChangeParts, _OnActorChangeParts);
        }

        public void PreloadFinished()
        {
            _ClearActorInfos();
        }

        // protected override void OnUpdate()
        // {
        //     base.OnUpdate();
        //     if (Input.GetKeyDown(KeyCode.Q))
        //     {
        //         SetWritePath("../Tools/verifybattle/results");
        //         WriteToLocalEditor();
        //     }
        // }

        private void OnSkill(EventCastSkill arg)
        {
            OnSkillStep(X3Battle.OnSkillStep.Start, arg.skill as SkillActive);
        }

        private void OnSkillEnd(EventEndSkill arg)
        {
            OnSkillStep(X3Battle.OnSkillStep.End, arg.skill as SkillActive);
        }

        private void OnSkillStep(OnSkillStep step, SkillActive skill)
        {
            if (!skill.actor.IsRole())
            {
                return;
            }

            EntityData entityData = TryGetEntityData(skill.actor);
            SkillSlotType type= SkillSlotType.Active;
            if (skill.actor.type == ActorType.Hero)
            {
                // type = (SkillSlotType) skill.config.SkillType;
                // switch (type)
                // {
                //     case SkillSlotType.Passive:
                //     case SkillSlotType.Love:
                //     case SkillSlotType.Coop:
                //     case SkillSlotType.QTEDodge:
                //     case SkillSlotType.Dead:
                //         type = SkillSlotType.Num;
                //         break;
                // }
            }
            else
            {
                type = (SkillSlotType) skill.GetID();
            }

            if (step == X3Battle.OnSkillStep.Start)
            {
                if (skill.IsPositive())
                    entityData.skillCastTime[skill.GetID()] = battle.time;
                int num = 0;
                entityData.skillCastCountSum.TryGetValue(type, out num);
                entityData.skillCastCountSum[type] = num + 1;
            }
            else
            {
                float startCastTime = 0;
                if (skill.IsPositive() && entityData.skillCastTime.TryGetValue(skill.GetID(), out startCastTime))
                {
                    startCastTime = battle.time - startCastTime;
                    entityData.skillCastTime[skill.GetID()] = 0;
                }

                float time = 0;
                entityData.skillTimeSum.TryGetValue(type, out time);
                entityData.skillTimeSum[type] = time + startCastTime;
            }
        }

        private void OnExportDamage(EventExportDamage arg)
        {
            Actor actor = arg.exporter.actor.master == null ? arg.exporter.actor : arg.exporter.actor.master;
            if (!actor.IsRole())
                return;
            if (!(arg.exporter is SkillActive))
                return;
            SkillActive skill = arg.exporter as SkillActive;
            EntityData entityData;
            using (ProfilerDefine.BattleStatisticsOnExportDamageTryGetEntityData.Auto())
            {
                entityData = TryGetEntityData(actor);
            }
            SkillSlotType type = SkillSlotType.Active;
            if (actor.type == ActorType.Hero)
            {
                // type = (SkillSlotType) skill.config.SkillType;
                // switch (type)
                // {
                //     case SkillSlotType.Passive:
                //     case SkillSlotType.Love:
                //     case SkillSlotType.Coop:
                //     case SkillSlotType.QTEDodge:
                //     case SkillSlotType.Dead:
                //         type = SkillSlotType.Num;
                //         break;
                // }
            }
            else
            {
                type = (SkillSlotType) skill.GetID();
            }
            int hitNum = 0;
            entityData.skillHitCount.TryGetValue(type, out hitNum);
            entityData.skillHitCount[type] = hitNum + 1;
            if (arg.damageInfo == null)
            {
                return;
            }

            using (ProfilerDefine.BattleStatisticsOnExportDamageSetEntityData.Auto())
            {
                var damageInfo = arg.damageInfo;
                var target = damageInfo.actor;
                if (arg.damageType == DamageType.Add)
                {
                    float cureNum = damageInfo.damage;
                    entityData.cureGive = entityData.cureGive + cureNum;
                    if (target.IsRole())
                    {
                        EntityData tempData = TryGetEntityData(target);
                        tempData.cureGet = tempData.cureGet + cureNum;
                    }
                }
                else
                {
                    float dameageNum = damageInfo.damage;
                    if (entityData.skillDamageSum.ContainsKey(type))
                    {
                        float curDamageNum = 0;
                        entityData.skillDamageSum.TryGetValue(type, out curDamageNum);
                        entityData.skillDamageSum[type] = curDamageNum + dameageNum;
                    }
                    else
                    {
                        entityData.skillDamageSum[type] = dameageNum;
                        entityData.skillIDList.Add(type);
                    }

                    entityData.damageGive = entityData.damageGive + dameageNum;
                    if (target.IsRole())
                    {
                        EntityData tempData = TryGetEntityData(target);
                        tempData.damageGet = tempData.damageGet + dameageNum;
                    }
                }
            }
        }

        private void OnQTEButtonPerfectEvent(EventQTEButton arg)
        {
            int num = 0;
            qte[QTEResultType.Perfect].TryGetValue(arg.qteId, out num);
            qte[QTEResultType.Perfect][arg.qteId] = num + 1;
        }

        private void OnQTEButtonSuccessEvent(EventQTEButton arg)
        {
            int num = 0;
            qte[QTEResultType.Success].TryGetValue(arg.qteId, out num);
            qte[QTEResultType.Success][arg.qteId] = num + 1;
        }

        private EntityData TryGetEntityData(Actor actor)
        {
            using (ProfilerDefine.BattleStatisticsTryGetEntityData.Auto())
            {
                int entityID = actor.insID;

                if (_entities.TryGetValue(entityID, out EntityData entity))
                {
                    entity.maxHp = actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
                    entity.leftHp = actor.attributeOwner.GetAttrValue(AttrType.HP);
                    return entity;
                }
                
                if (_entityDatas.Count > 0)
                {
                    entity = _entityDatas[0];
                    _entityDatas.RemoveAt(0);
                }
                else
                {
                    entity = NewEmptyEntityData();
                }
                _entities[entityID] = entity;
                entity.actorType = actor.type;
                entity.configID = actor.cfgID;
                entity.bornTm = battle.time;
                entity.spawnID = actor.spawnID;
                entity.maxHp = actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
                entity.leftHp = actor.attributeOwner.GetAttrValue(AttrType.HP);
                if (actor.type == ActorType.Hero)
                {
                    foreach (var type in entity.skillIDList)
                    {
                        entity.skillDamageSum[type] = 0;
                        entity.skillTimeSum[type] = 0;
                        entity.skillCastCountSum[type] = 0;
                    }
                }
                else if (null != actor.config.SkillSlots)
                {
                    _tempIDS.Clear();
                    entity.skillIDList.Clear();
                    foreach (var slot in actor.config.SkillSlots.Values)
                    {
                        if (_tempIDS.Add((int)slot.SlotType)) // 去重
                        {
                            entity.skillIDList.Add(slot.SlotType);
                            entity.skillDamageSum[slot.SlotType] = 0;
                            entity.skillTimeSum[slot.SlotType] = 0;
                            entity.skillCastCountSum[slot.SlotType] = 0;
                            entity.skillHitCount[slot.SlotType] = 0;
                        }
                    }
                }

                return entity;
            }
        }

        private EntityData NewEmptyEntityData()
        {
            var entity = new EntityData();
            entity.skillIDList = new List<SkillSlotType>()
            {
                SkillSlotType.Attack,
                SkillSlotType.Active,
                SkillSlotType.CoopAttack,
                SkillSlotType.Ultra,
                SkillSlotType.Special,
                SkillSlotType.Combo,
                SkillSlotType.Dodge,
                SkillSlotType.Support,
                SkillSlotType.Num
            };
            foreach (var type in entity.skillIDList)
            {
                entity.skillDamageSum[type] = 0;
                entity.skillTimeSum[type] = 0;
                entity.skillCastCountSum[type] = 0;
                entity.skillHitCount[type] = 0;
            }
            entity.skillDamageSum.Clear();
            entity.skillTimeSum.Clear();
            entity.skillCastCountSum.Clear();
            entity.skillHitCount.Clear();
            return entity;
        }

        private void OnActorDead(EventActorBase arg)
        {
            if (!arg.actor.IsRole())
                return;
            EntityData entityData = TryGetEntityData(arg.actor);
            entityData.deadTm = battle.time;
            int actorID = arg.actor.cfgID;
            if (arg.actor.master != null)
                actorID = arg.actor.master.cfgID;
            if (arg.actor.type == ActorType.Monster)
            {
                int num = 0;
                killMonsters.TryGetValue(actorID, out num);
                killMonsters[actorID] = num + 1;
            }
        }

        private void OnBattleEnd(EventBattleEnd arg)
        {
            _result = arg.isWin;
            _time = battle.time;
            RecordeActorCurHP();
            WriteToLocalEditor();
        }

        private void RecordeActorCurHP()
        {
            foreach (var actor in battle.actorMgr.actors)
            {
                if (!actor.IsRole())
                    continue;
                EntityData data = TryGetEntityData(actor);
                data.leftHp = actor.attributeOwner.GetAttrValue(AttrType.HP);
                data.maxHp = actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
            }
            
            //补全没有刷出来的怪物数据
            var spawnIDs = ObjectPoolUtility.CommonIntList.Get();
            
            battle.actorMgr.GetNotBornMonsterSpawnIDs(spawnIDs);
            foreach (var spawnID in spawnIDs)
            {
                var data = new EntityData();
                data.actorType = ActorType.Monster;
                data.maxHp = 1;
                data.leftHp = 1;
                data.spawnID = spawnID;
                _entities.Add(spawnID, data);
            }
            
            ObjectPoolUtility.CommonIntList.Release(spawnIDs);
        }

        private void WriteToLocalEditor()
        {
            if (!Application.isEditor)
                return;
            if (string.IsNullOrEmpty(_path))
                return;
            _time = battle.time;
            RecordeActorCurHP();
            string fileName = $"/BattleStat_{_uid}.csv";
            string fullPath = _path + fileName;
            StringBuilder builder = new StringBuilder(2048);
            using (StreamWriter writer = new StreamWriter(File.Open(fullPath, FileMode.OpenOrCreate)))
            {
                builder.AppendFormat("{0},{1},{2},{3},{4},{5},{6},",
                    _scoreSetGroupId, _scoreSetId, _dungeonGroupId, _dungeonId, _count, _time, _result);
                // writer.WriteLine(builder.ToString());
                // builder.Clear();
                Dictionary<SkillSlotType, string> skillHitRates = new Dictionary<SkillSlotType, string>();
                foreach (var item in _entities)
                {
                    EntityData entity = item.Value;
                    if (entity.actorType == ActorType.Hero)
                    {
                        builder.AppendFormat("{0},{1},{2},",
                            entity.leftHp,
                            entity.damageGet,
                            entity.damageGive
                        );
                        GenMonsterSkillStr<SkillSlotType, float>(entity.skillIDList, entity.skillDamageSum, builder);
                        builder.Append(",");
                        GenMonsterSkillStr<SkillSlotType, float>(entity.skillIDList, entity.skillTimeSum, builder);
                        builder.Append(",");
                        GenMonsterSkillStr<SkillSlotType, int>(entity.skillIDList, entity.skillCastCountSum, builder);
                    }
                    else
                    {
                        skillHitRates.Clear();
                        foreach (var type in entity.skillIDList)
                        {
                            if (!entity.skillCastCountSum.ContainsKey(type))
                            {
                                int count = 0;
                                entity.skillHitCount.TryGetValue(type, out count);
                                int countSum = 0;
                                entity.skillCastCountSum.TryGetValue(type, out countSum);
                                skillHitRates[type] = ((float) count / countSum).ToString("#0.0");
                            }
                            else
                            {
                                skillHitRates[type] = 0.ToString("#0.0");
                            }
                        }

                        float monsterAliveTime = entity.deadTm - entity.bornTm;
                        monsterAliveTime = entity.deadTm != 0 ? monsterAliveTime : _time;
                        builder.AppendFormat("{0},{1},{2},{3},",
                            entity.configID,
                            monsterAliveTime,
                            entity.leftHp,
                            entity.damageGive
                        );
                        genRoleSkillStr(entity.skillIDList, builder);
                        builder.Append(",");
                        GenMonsterSkillStr<SkillSlotType, float>(entity.skillIDList, entity.skillDamageSum, builder);
                        builder.Append(",");
                        GenMonsterSkillStr<SkillSlotType, float>(entity.skillIDList, entity.skillTimeSum, builder);
                        builder.Append(",");
                        GenMonsterSkillStr<SkillSlotType, int>(entity.skillIDList, entity.skillCastCountSum, builder);
                        builder.Append(",");
                        GenMonsterSkillStr<SkillSlotType, string>(entity.skillIDList, skillHitRates, builder);
                    }

                    builder.Append(",");
                    // writer.WriteLine(builder.ToString());
                    // builder.Clear();
                }

                writer.WriteLine(builder.ToString());
                builder.Clear();
            }
        }

        private void GenMonsterSkillStr<SkillSlotType, v>(List<SkillSlotType> idList, Dictionary<SkillSlotType, v> dic, StringBuilder builder)
        {
            foreach (var type in idList)
            {
                if (dic.ContainsKey(type))
                    builder.Append(dic[type]);
                else
                    builder.Append(0);
                builder.Append("|");
            }
        }

        private void genRoleSkillStr(List<SkillSlotType> idList, StringBuilder builder)
        {
            foreach (var type in idList)
            {
                builder.Append(type);
                builder.Append("|");
            }
        }
        
        private void _OnActorChangeParts(EventActorChangeParts arg)
        {
            if (arg.isBrokenSuit)
            {
                isAlreadyBrokenSuit = arg.isBrokenSuit;
            }
        }
    }
}