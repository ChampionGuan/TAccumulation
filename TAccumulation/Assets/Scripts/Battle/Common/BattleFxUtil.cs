using System;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System.Reflection;
using PapeGames.X3;
using System.ComponentModel;
using PapeGames.Rendering;

namespace X3Battle
{
    public class FxActor
    {
        public string name;
        public string prefabName;
        public int id;
        public int insId;

        public List<int> skillIds;
        public Actor actor;
    }

    //只提供给特效测试工具使用 其他地方请不要使用
    public class BattleFxUtil : PapeGames.X3.Singleton<BattleFxUtil>
    {
        public List<FxActor> actors;

        private Battle _battle => Battle.Instance;

        public BattleFxUtil()
        {
            _InitializeActorData();
        }

        public Actor CreateRole(int actorId, Vector3 position, bool ai, FactionType factionType, int spawnID)
        {
            if (!TbUtil.TryGetCfg(actorId, out ActorCfg roleCfg))
            {
                return null;
            }

            RoleBornCfg roleBornCfg = _battle.player.roleBornCfg;
            if (roleBornCfg == null)
            {
                return null;
            }

            RoleBornCfg targetRoleBornCfg = new RoleBornCfg();
            targetRoleBornCfg.Reset();
            targetRoleBornCfg.SpawnID = spawnID;
            targetRoleBornCfg.Position = position;
            targetRoleBornCfg.FactionType = factionType;
            targetRoleBornCfg.CfgID = actorId;
            targetRoleBornCfg.IsPlayer = false;
            targetRoleBornCfg.IsAIActive = true;
            if (null != roleBornCfg.Attrs)
            {
                foreach (var keyValue in roleBornCfg.Attrs)
                {
                    targetRoleBornCfg.Attrs.Add(keyValue.Key, keyValue.Value);
                }
            }

            Actor targetActor = _battle.actorMgr.CreateActor(roleCfg.Type, targetRoleBornCfg);
            if (targetActor == null)
                return null;

            targetActor.aiOwner?.DisableAI(!ai, AISwitchType.Debug);

            if (!ai)
            {
                targetActor.locomotion.StopMove();
            }

            foreach (var info in actors)
            {
                if (info.id == actorId)
                {
                    info.actor = targetActor;
                    info.insId = targetActor.insID;
                }
            }

            return targetActor;
        }

        public void RemoveRole(int actorId)
        {
            _battle.actorMgr.SetCacheEnable(false);
            Actor tempActor = null;
            foreach (var info in actors)
            {
                if (info.id == actorId)
                {
                    tempActor = info.actor;
                    break;
                }
            }

            if (tempActor == null)
            {
                LogProxy.LogWarning($"找不到要被移除的actor, cfgId:{actorId}");
                return;
            }

            StopFx(tempActor.cfgID);
            tempActor?.Dead();
            // tempActor?.Destroy(); // 回池
            // tempActor?.timelinePlayer.Destroy(); // 所有预加载Timeline回池
            Destroy(tempActor.cfgID);
            _battle.actorMgr.SetCacheEnable(true);
        }

        public bool PlaySkill(int actorId, int skillId)
        {
            Actor tempActor = null;
            foreach (var info in actors)
            {
                if (info.id == actorId)
                {
                    tempActor = info.actor;
                    break;
                }
            }

            if (tempActor == null)
                return false;

            tempActor.skillOwner.TryEndSkill();
            int slotId = BattleUtil.GetSlotID(SkillSlotType.Attack, 0);
            var slot = tempActor.skillOwner.GetSkillSlot(slotId);

            if (slot == null || slot.skill.GetID() != skillId)
            {
                if (slot != null)
                {
                    tempActor.skillOwner.RemoveSkillSlot(slotId);
                }

                tempActor.skillOwner.CreateSkillSlotByDebugEditor(slotId, skillId);
                slot = tempActor.skillOwner.GetSkillSlot(slotId);
            }

            if (slot == null)
            {
                return false;
            }

            _ClearSlotCD(slot);
            if (!tempActor.skillOwner.CanCastSkillBySlot(slot.ID))
            {
                return false;
            }

            tempActor.skillOwner.TryCastSkillBySlot(slotId);
            return true;
        }

        public void _ClearSlotCD(SkillSlot slot)
        {
            SkillLevelCfg skillLevelCfg = TbUtil.GetCfg<SkillLevelCfg>(slot.skill.config.ID, 1);
            skillLevelCfg.CD = 0;
            skillLevelCfg.StartCD = 0;
            slot.SetRemainCD(0);
        }

        private void _InitializeActorData(bool isLauncher = false)
        {
            actors = new List<FxActor>();
            _AddActors(TbUtil.actorCfgs);
        }

        private void _AddActors<T>(Dictionary<int, T> actorCfgs) where T : ActorCfg
        {
            foreach (var actorCfg in actorCfgs.Values)
            {
                int id = actorCfg.ID;
                FxActor actor = new FxActor();
                actor.id = id;
                actor.name = actor.id + actorCfg.Name;
                actor.prefabName = actorCfg.PrefabName;
                actor.skillIds = new List<int>();
                if (null != actorCfg.SkillSlots)
                {
                    foreach (var slot in actorCfg.SkillSlots.Values.Where(
                                 slot => !actor.skillIds.Contains(slot.SkillID)))
                    {
                        actor.skillIds.Add(slot.SkillID);
                    }
                }

                actor.skillIds.Sort(_intSortFun);
                actors.Add(actor);
            }
        }

        private int _intSortFun(int id1, int id2)
        {
            if (id1 < id2)
            {
                return -1;
            }
            else if (id1 > id2)
            {
                return 1;
            }

            return 0;
        }

        private T Clone<T>(T sourceT)
        {
            T targetT = Activator.CreateInstance<T>();
            PropertyInfo[] propertyInfos = targetT.GetType().GetProperties();
            foreach (PropertyInfo propertyInfo in propertyInfos)
            {
                if (propertyInfo.PropertyType.IsGenericType &&
                    propertyInfo.PropertyType.GetGenericTypeDefinition() == typeof(Nullable<>))
                {
                    NullableConverter nullableConverter = new NullableConverter(propertyInfo.PropertyType);
                    propertyInfo.SetValue(targetT,
                        Convert.ChangeType(propertyInfo.GetValue(sourceT), nullableConverter.UnderlyingType));
                }
                else
                {
                    propertyInfo.SetValue(targetT,
                        Convert.ChangeType(propertyInfo.GetValue(sourceT), propertyInfo.PropertyType));
                }
            }

            foreach (var fieldInfo in targetT.GetType().GetFields())
            {
                if (fieldInfo.FieldType.IsGenericType &&
                    fieldInfo.FieldType.GetGenericTypeDefinition() == typeof(Nullable<>))
                {
                    NullableConverter nullableConverter = new NullableConverter(fieldInfo.FieldType);
                    fieldInfo.SetValue(targetT,
                        Convert.ChangeType(fieldInfo.GetValue(sourceT), nullableConverter.UnderlyingType));
                }
                else
                {
                    fieldInfo.SetValue(targetT, Convert.ChangeType(fieldInfo.GetValue(sourceT), fieldInfo.FieldType));
                }
            }

            return targetT;
        }

        /// <summary>
        /// 停止某个技能的FX
        /// </summary>
        public void StopFx(int actorId, int skillId)
        {
            foreach (var info in actors)
            {
                if (info.id == actorId)
                {
                    info.actor.effectPlayer.StopFX(skillId);
                    break;
                }
            }
        }

        /// <summary>
        /// 清除某个角色
        /// </summary>
        public void Destroy(int actorId)
        {
            foreach (var info in actors)
            {
                if (info.id == actorId && info.actor != null)
                {
                    foreach (var comp in info.actor.comps)
                    {
                        comp?.Destroy();
                    }

                    // info.actor.model.Destroy();
                    // info.actor.timelinePlayer.Destroy();
                    info.actor?.Destroy();
                    break;
                }
            }
        }

        /// <summary>
        /// 停止角色的Fx
        /// </summary>
        /// <remarks>挂在角色身上的，不包括身外的fx</remarks>
        public void StopFx(int actorId)
        {
            foreach (var info in actors)
            {
                if (info.id == actorId)
                {
                    info.actor.effectPlayer.StopBodyFX();
                    break;
                }
            }
        }

        public void BattleResTryUninit()
        {
            BattleResMgr.Instance.UnloadUnusedAll();
        }

        public static Actor GetControlActor()
        {
            return Battle.Instance.actorMgr.GetFirstActor(ActorType.Hero, includeSummoner: false);
        }

        public static void HideEnv()
        {
            //  所有预先存在的角色
            var actors = ObjectPoolUtility.CommonActorList.Get();
            Battle.Instance.actorMgr.GetActors(ActorType.Hero, outResults: actors, includeSummoner: false);
            foreach (var actor in actors)
            {
                actor.transform.SetVisible(false);
            }

            actors.Clear();
            Battle.Instance.actorMgr.GetActors(ActorType.Monster, outResults: actors, includeSummoner: false);
            foreach (var actor in actors)
            {
                actor.transform.SetVisible(false);
            }
            ObjectPoolUtility.CommonActorList.Release(actors);
            
            // 场景
            var sceneRoot = Res.GetSceneRoot();
            foreach (var lightMapObject in sceneRoot.GetComponentsInChildren<LightMapObjectManager>())
            {
                lightMapObject.gameObject.SetActive(false);
            }

            // UI
            BattleUtil.SetUIActive(false);
        }

        public void CleanUp()
        {
            _battle.actorMgr.SetCacheEnable(false);
            // 停掉角色的所有buff和技能逻辑及表现
            foreach (var actor in _battle.actorMgr.actors)
            {
                if (actor.buffOwner != null)
                {
                    actor.buffOwner.RemoveAllBuff();
                }

                if (actor.skillOwner != null)
                {
                    actor.skillOwner.TryEndSkill();
                    actor.skillOwner.ClearSkillRemainFX();
                }
            }

            BattleResMgr.Instance.UnloadUnusedAll();

            // 停掉所有非角色对象
            foreach (var actor in _battle.actorMgr.actors)
            {
                if (actor.type == ActorType.Machine ||
                    actor.type == ActorType.Obstacle ||
                    actor.type == ActorType.BattleElement ||
                    actor.type == ActorType.TriggerArea ||
                    actor.type == ActorType.SkillAgent)
                {
                    actor?.Recycle();
                    actor?.Destroy();
                }
            }

            // 额外单独停掉Fx表现
            _battle.fxMgr.DestroyAllFx();

            BattleResMgr.Instance.UnloadUnusedAll();

            LogProxy.Log("清除");

            _battle.actorMgr.SetCacheEnable(true);
        }

        public void CleanUpSkillFxTest()
        {
            _battle.actorMgr.SetCacheEnable(false);
            foreach (var actor in _battle.actorMgr.actors)
            {
                if (actor.type == ActorType.Machine ||
                    actor.type == ActorType.Obstacle ||
                    actor.type == ActorType.BattleElement ||
                    actor.type == ActorType.TriggerArea ||
                    actor.type == ActorType.SkillAgent)
                {
                    actor?.Recycle();
                    actor?.Destroy();
                }
            }

            _battle.fxMgr.DestroyAllFx();

            BattleResMgr.Instance.UnloadUnusedAll();
            _battle.actorMgr.SetCacheEnable(true);
        }
    }
}