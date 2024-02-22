using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public static class BattleExtension
    {
        /// <summary>
        /// 创建创生物
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="skill"></param>
        /// <param name="summonId"></param>
        /// <param name="coorPoint"></param>
        /// <param name="coorOrientation"></param>
        /// <param name="bIsTargetType"></param>
        public static void SummonCreature(this Battle battle, Actor actor, ISkill skill, int summonId, FactionType? factionType, CoorPoint coorPoint, CoorOrientation coorOrientation, bool bIsTargetType, TransInfoCache transInfoCache = null)
        {
            // DONE: 算位置时：以召唤者为主体
            var refPos = CoorHelper.GetRefCoordinatePoint(coorPoint, actor, bIsTargetType, cache: transInfoCache);
            var targetPos = CoorHelper.GetCoordinatePoint(coorPoint, actor, bIsTargetType, transInfoCache: transInfoCache);

            Vector3 pos = targetPos;
            if (targetPos != refPos)
            {
                pos = BattleUtil.RayCastByColliderTest(refPos, targetPos);
            }

            var creatureActor = battle.actorMgr.SummonMonster(skill, summonId, pos, 0, factionType: factionType);

            // DONE: 算朝向时，以召唤单位为主体
            if (creatureActor != null)
            {
                var forward = CoorHelper.GetCoordinateOrientation(coorOrientation, creatureActor, bIsTargetType, transInfoCache: transInfoCache);
                creatureActor.transform.SetForward(forward);
            }
        }

        /// <summary>
        /// 创建法术场
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="damageExporter"></param>
        /// <param name="magicFieldId"></param>
        /// <param name="coorPoint"></param>
        /// <param name="coorOrientation"></param>
        /// <param name="bIsTargetType"></param>
        public static Actor CreateMagicField(this Battle battle, Actor actor, DamageExporter damageExporter, int magicFieldId, CoorPoint coorPoint, CoorOrientation coorOrientation, bool bIsTargetType, CreateMagicFieldParam createParam = null, FactionType? factionType = null, TransInfoCache transInfoCache = null)
        {
            // DONE: 算位置时：以召唤者为主体
            var refPos = CoorHelper.GetRefCoordinatePoint(coorPoint, actor, bIsTargetType, cache:transInfoCache);
            var targetPos = CoorHelper.GetCoordinatePoint(coorPoint, actor, bIsTargetType, transInfoCache:transInfoCache);

            Vector3 pos = targetPos;
            if (targetPos != refPos)
            {
                pos = BattleUtil.RayCastByColliderTest(refPos, targetPos);
            }

            var magicFieldActor = battle.actorMgr.CreateMagicField(damageExporter, magicFieldId, pos, actor.transform.eulerAngles, createParam: createParam, factionType:factionType);

            // 算朝向时，以召唤单位为主体
            if (magicFieldActor != null)
            {
                var forward = CoorHelper.GetCoordinateOrientation(coorOrientation, magicFieldActor, bIsTargetType, transInfoCache:transInfoCache);
                magicFieldActor.transform.SetForward(forward);
                magicFieldActor.skillOwner.TryCastSkillBySlot(0, safeCheck: false);
            }

            return magicFieldActor;
        }

        /// <summary>
        /// 创建道具
        /// </summary>
        /// <param name="master"></param>
        /// <param name="itemLevel"></param>
        /// <param name="itemId"></param>
        /// <param name="coorPoint"></param>
        /// <param name="coorOrientation"></param>
        /// <param name="bIsTargetType"></param>
        public static void CreateItem(this Battle battle, Actor master, DamageExporter damageExporter, int itemLevel, int itemId, CoorPoint coorPoint, CoorOrientation coorOrientation, bool bIsTargetType, TransInfoCache transInfoCache = null)
        {
            // DONE: 算位置时：以召唤者为主体
            var refPos = CoorHelper.GetRefCoordinatePoint(coorPoint, master, bIsTargetType, cache: transInfoCache);
            var targetPos = CoorHelper.GetCoordinatePoint(coorPoint, master, bIsTargetType, transInfoCache: transInfoCache);

            Vector3 pos = targetPos;
            if (targetPos != refPos)
            {
                pos = BattleUtil.RayCastByColliderTest(refPos, targetPos);
            }

            Actor itemActor = battle.actorMgr.CreateItem(master, damageExporter, itemLevel, itemId, pos, 0);
            // 算朝向时，以召唤单位为主体
            if (itemActor != null)
            {
                var forward = CoorHelper.GetCoordinateOrientation(coorOrientation, itemActor, bIsTargetType, transInfoCache: transInfoCache);
                itemActor.transform.SetForward(forward, false);
            }

            // 发送道具创建事件
            if (itemActor != null)
            {
                var eventData = battle.eventMgr.GetEvent<EventCreateItem>();
                eventData.Init(itemActor, itemId);
                battle.eventMgr.Dispatch(EventType.CreateItem, eventData);   
            }
        }

        public static void DestroyItemByCfgID(this Battle battle, int cfgID)
        {
            if (battle == null)
            {
                return;
            }
            foreach (Actor actor in battle.actorMgr.actors)
            {
                if (actor.IsItem() && actor.config.ID == cfgID)
                {
                    actor.Dead();
                }
            }
        }

        /// <summary>
        /// 设置魔女时间
        /// </summary>
        /// <param name="battle"></param>
        /// <param name="owner">由谁设置</param>
        /// <param name="isRestoreActorsScale">清除所有单位的魔女缩放</param>
        /// <param name="isExclusion">是否为排除选择</param>
        /// <param name="witchTimeDatas">选择的数据列表</param>
        /// <param name="scale">缩放值</param>
        /// <param name="duration">时长</param>
        /// <param name="pauseSound">是否暂停音效</param>
        public static void SetActorsWitchTime(this Battle battle, Actor owner, bool isRestoreActorsScale, bool isExclusion, List<WitchTimeIncludeData> witchTimeDatas, float scale, float duration, bool pauseSound)
        {
            if (owner == null)
            {
                return;
            }

            if (null == witchTimeDatas)
            {
                return;
            }

            // 所选单位列表
            var settings = ObjectPoolUtility.WitchTimeSettings.Get();
            var tgtActors = ObjectPoolUtility.CommonActorList.Get();
            for (var i = 0; i < witchTimeDatas.Count; i++)
            {
                var actor = owner.GetTarget(witchTimeDatas[i].targetType);
                tgtActors.Add(tgtActors.Contains(actor) ? null : actor);
            }

            // 所选单位是否为排除(选中单位设置参数并清除魔女时间，其他单位进入魔女时间)
            if (isExclusion)
            {
                using (ProfilerDefine.BattleExtensionSetActorsWitchTimeExclusionPMarker.Auto())
                {
                    foreach (var actor in owner.battle.actorMgr.actors)
                    {
                        if (tgtActors.Contains(actor))
                        {
                            var index = tgtActors.IndexOf(actor);
                            var info = witchTimeDatas[index];

                            // 清除魔女时间
                            if (isRestoreActorsScale) actor.SetWitchTime(1, null);
                            // 同步魔女设置
                            settings.Reset();
                            settings.syncSelf = false;
                            settings.syncCreatures = !info.isIncludeSummoned;
                            settings.syncBullets = !info.isIncludeBullets;
                            settings.syncItems = !info.isIncludeItems;
                            settings.syncMagicFields = !info.isIncludeMagicFields;
                            settings.pauseSoundForSummon = pauseSound;
                            actor.SetWitchTime(scale, duration, settings);
                            continue;
                        }

                        if (null != actor.master && tgtActors.Contains(actor.master))
                        {
                            var index = tgtActors.IndexOf(actor.master);
                            var info = witchTimeDatas[index];
                            var result = BattleUtil.IsIncludeActor(actor, info);
                            if (result)
                            {
                                // 清除魔女时间
                                if (isRestoreActorsScale) actor.SetWitchTime(1, null);
                                // 同步魔女设置
                                settings.Reset();
                                settings.syncSelf = false;
                                actor.SetWitchTime(scale, duration, settings);
                                continue;
                            }
                        }

                        // 进入魔女时间
                        settings.Reset();
                        settings.pauseSoundForSelf = pauseSound;
                        settings.syncSelf = true;
                        actor.SetWitchTime(scale, duration, settings);
                    }

                }
            }
            // 所选单位是否为进入(选中单位进入魔女时间，其他单位不变)
            else
            {
                using (ProfilerDefine.BattleExtensionSetActorsWitchTimeInclusionPMarker.Auto())
                {
                    foreach (var actor in owner.battle.actorMgr.actors)
                    {
                        if (tgtActors.Contains(actor))
                        {
                            var index = tgtActors.IndexOf(actor);
                            var info = witchTimeDatas[index];

                            // 进入魔女时间
                            settings.Reset();
                            settings.syncSelf = true;
                            settings.syncCreatures = info.isIncludeSummoned;
                            settings.syncBullets = info.isIncludeBullets;
                            settings.syncItems = info.isIncludeItems;
                            settings.syncMagicFields = info.isIncludeMagicFields;
                            settings.pauseSoundForSelf = pauseSound;
                            actor.SetWitchTime(scale, duration, settings);
                            continue;
                        }

                        if (null != actor.master && tgtActors.Contains(actor.master))
                        {
                            var index = tgtActors.IndexOf(actor.master);
                            var info = witchTimeDatas[index];
                            var result = BattleUtil.IsIncludeActor(actor, info);
                            if (result)
                            {
                                // 进入魔女时间
                                settings.Reset();
                                settings.pauseSoundForSelf = pauseSound;
                                settings.syncSelf = true;
                                actor.SetWitchTime(scale, duration, settings);
                                continue;
                            }
                        }

                        // 清除魔女时间
                        if (isRestoreActorsScale)
                        {
                            actor.SetWitchTime(1, null);
                        }
                    }

                }
            }

            ObjectPoolUtility.CommonActorList.Release(tgtActors);
            ObjectPoolUtility.WitchTimeSettings.Release(settings);
        }
        
        /// <summary>
        /// 清除场上所有单位的魔女时间效果
        /// </summary>
        public static void ClearActorsWitchTime(this Battle battle)
        {
            foreach (var actor in battle.actorMgr.actors)
            {
                actor.SetWitchTime(1, null);
            }
        }
        
        //Timeline爆发技专用 播放设定的Idle
        public static void SetIdleParam(this Battle battle, Actor actor, bool isBattleIdle, bool weaponEffect = true)
        {
            if (!weaponEffect)//不播武器淡出
            {
                actor.weapon.SetOnceOutEffect(null, null, null);
                actor.weapon.ClearOnceOutEffectLate();
            }
            actor.idle.SetIdleState(isBattleIdle, true);
        }
        
        /// <summary>
        /// 通用的，对应策划A|B|C|D|E类型配置的属性查询
        /// </summary>
        /// <param name="mainActor">用来判断的单位</param>
        /// <param name="mainAttr">目标消耗属性</param>
        /// <param name="coefficient1">计算系数1（千分比）</param>
        /// <param name="coefficient2">计算系数2（固定值）</param>
        /// <param name="choseTarget">其他角色</param>
        /// <param name="paramAttr">（其他角色的）参与计算属性</param>
        /// <returns>属性值是否大于等于所需要消耗的值</returns>
        public static bool QueryConsumeAttr(this Battle battle, Actor mainActor, AttrType mainAttr, int coefficient1, float coefficient2, AttrChoseTarget choseTarget = AttrChoseTarget.Self, AttrType paramAttr = AttrType.None)
        {
            if (mainActor == null)
            {
                return false;
            }

            if (paramAttr == AttrType.None)
            {
                paramAttr = mainAttr;
            }

            // 传入的是None直接返回（用来做无消耗情况和策划配了两个空）
            if (mainAttr == AttrType.None && paramAttr == AttrType.None)
            {
                return true;
            }

            switch (choseTarget)
            {
                case AttrChoseTarget.Self:
                {
                    float attrValue = mainActor.attributeOwner.GetAttrValue(mainAttr);
                    float castValue = attrValue * coefficient1 / 1000.0f + coefficient2;
                    return attrValue >= castValue;
                }
                    break;
                case AttrChoseTarget.Girl:
                {
                    var actor = Battle.Instance.actorMgr.girl;
                    if (actor == null)
                    {
                        LogProxy.LogError($"QueryConsumeAttr girl is null!，mainAttr={mainAttr}！");
                        return false;
                    }

                    float attrValue = actor.attributeOwner.GetAttrValue(mainAttr);
                    float castValue = actor.attributeOwner.GetAttrValue(paramAttr) * coefficient1 / 1000.0f + coefficient2;
                    return attrValue >= castValue;
                }
                    break;
                case AttrChoseTarget.Boy:
                {
                    var actor = Battle.Instance.actorMgr.boy;
                    if (actor == null)
                    {
                        LogProxy.LogError($"QueryConsumeAttr boy is null!，mainAttr={mainAttr}！");
                        return false;
                    }

                    float attrValue = actor.attributeOwner.GetAttrValue(mainAttr);
                    float castValue = actor.attributeOwner.GetAttrValue(paramAttr) * coefficient1 / 1000.0f + coefficient2;
                    return attrValue >= castValue;
                }
                    break;
                default:
                {
                    LogProxy.LogError($"CanCostAttr choseTarget参数类型错误，mainAttr={mainAttr}！");
                }
                    break;
            }

            return false;
        }

        /// <summary>
        /// 通用的，对应策划A|B|C|D|E类型配置的属性消耗,默认不会扣成负数
        /// 会触发消耗能量相关的事件
        /// </summary>
        /// <param name="mainActor">用来判断的单位</param>
        /// <param name="mainAttr">目标消耗属性</param>
        /// <param name="coefficient1">计算系数1（千分比）</param>
        /// <param name="coefficient2">计算系数2（固定值）</param>
        /// <param name="choseTarget">其他角色</param>
        /// <param name="paramAttr">（其他角色的）参与计算属性</param>
        /// <param name="MinValue">扣除后的最小值</param>
        public static void ConsumeAttr(this Battle battle, Actor mainActor, AttrType mainAttr, int coefficient1, float coefficient2, AttrChoseTarget choseTarget = AttrChoseTarget.Self, AttrType paramAttr = AttrType.None, int MinValue = 0)
        {
            if (mainActor == null)
            {
                LogProxy.LogError($"ConsumeAttr 消耗失败 mainAttr = {mainAttr}");
                return;
            }

            if (mainAttr == AttrType.None && paramAttr == AttrType.None)
            {
                LogProxy.Log("ConsumeAttr 传入的属性类型都是AttrType.None，不消耗属性!");
                return;
            }

            //消耗常规属性时报错----ID在1000以上的是【即时属性】
            if (mainAttr < AttrType.HP)
            {
                LogProxy.LogError($"ConsumeAttr 尝试消耗常规属性， mainAttr = {mainAttr}");
                return;
            }

            if (paramAttr == AttrType.None)
            {
                paramAttr = mainAttr;
            }

            LogProxy.Log($"ConsumeAttr! mainActor = {mainActor},mainAttr={mainAttr},coefficient1={coefficient1},coefficient2={coefficient2},choseTarget={choseTarget},paramAttr={paramAttr},MinValue={MinValue}");
            switch (choseTarget)
            {
                case AttrChoseTarget.Self:
                {
                    float attrValue = mainActor.attributeOwner.GetAttrValue(paramAttr);
                    float castValue = attrValue * coefficient1 / 1000.0f + coefficient2;
                    mainActor.energyOwner.ConsumeEnergy(mainAttr, castValue, true, MinValue);
                }
                    break;
                case AttrChoseTarget.Girl:
                {
                    var actor = Battle.Instance.actorMgr.girl;
                    if (actor == null)
                    {
                        LogProxy.LogError($"ConsumeAttr girl is null!，mainAttr={mainAttr}！");
                        return;
                    }

                    float castValue = actor.attributeOwner.GetAttrValue(paramAttr) * coefficient1 / 1000.0f + coefficient2;
                    actor.energyOwner.ConsumeEnergy(mainAttr, castValue, true, MinValue);
                }
                    break;
                case AttrChoseTarget.Boy:
                {
                    var actor = Battle.Instance.actorMgr.boy;
                    if (actor == null)
                    {
                        LogProxy.LogError($"ConsumeAttr boy is null!，mainAttr={mainAttr}！");
                        return;
                    }

                    float castValue = actor.attributeOwner.GetAttrValue(paramAttr) * coefficient1 / 1000.0f + coefficient2;
                    actor.energyOwner.ConsumeEnergy(mainAttr, castValue, true, MinValue);
                }
                    break;
                default:
                {
                    LogProxy.LogError($"ConsumeAttr choseTarget参数类型错误，mainAttr={mainAttr}！");
                }
                    break;
            }
        }

        /// <summary>
        /// 通用的，对应策划A|B|C|D|E类型配置的属性获取
        /// </summary>
        /// <param name="mainActor">用来判断的单位</param>
        /// <param name="mainAttr">目标获取属性</param>
        /// <param name="coefficient1">计算系数1（千分比）</param>
        /// <param name="coefficient2">计算系数2（固定值）</param>
        /// <param name="choseTarget">其他角色</param>
        /// <param name="paramAttr">（其他角色的）参与计算属性</param>
        ///
        public static void GatherAttr(this Battle battle, Actor mainActor, AttrType mainAttr, int coefficient1, float coefficient2, AttrChoseTarget choseTarget = AttrChoseTarget.Self, AttrType paramAttr = AttrType.None)
        {
            if (mainActor == null || mainAttr == AttrType.None)
            {
                LogProxy.LogError($"GatherAttr 获取属性失败 mainAttr = {mainAttr}");
                return;
            }

            //回复常规属性时报错----ID在1000以上的是【即时属性】
            if (mainAttr < AttrType.HP)
            {
                LogProxy.LogError($"GatherAttr 尝试回复常规属性， mainAttr = {mainAttr}");
                return;
            }

            if (paramAttr == AttrType.None)
            {
                paramAttr = mainAttr;
            }

            LogProxy.Log($"GatherAttr! mainActor = {mainActor},mainAttr={mainAttr},coefficient1={coefficient1},coefficient2={coefficient2},choseTarget={choseTarget},paramAttr={paramAttr}");
            switch (choseTarget)
            {
                case AttrChoseTarget.Self:
                {
                    float attrValue = mainActor.attributeOwner.GetAttrValue(paramAttr);
                    float castValue = attrValue * coefficient1 / 1000.0f + coefficient2;
                    mainActor.energyOwner.GatherEnergy(mainAttr, castValue);
                }
                    break;
                case AttrChoseTarget.Girl:
                {
                    var actor = battle.actorMgr.girl;
                    if (actor == null)
                    {
                        LogProxy.LogError($"GatherAttr girl is null!，mainAttr={mainAttr}！");
                        return;
                    }

                    float castValue = actor.attributeOwner.GetAttrValue(paramAttr) * coefficient1 / 1000.0f + coefficient2;
                    actor.energyOwner.GatherEnergy(mainAttr, castValue);
                }
                    break;
                case AttrChoseTarget.Boy:
                {
                    var actor = battle.actorMgr.boy;
                    if (actor == null)
                    {
                        LogProxy.LogError($"GatherAttr boy is null!，mainAttr={mainAttr}！");
                        return;
                    }

                    float castValue = actor.attributeOwner.GetAttrValue(paramAttr) * coefficient1 / 1000.0f + coefficient2;
                    actor.energyOwner.GatherEnergy(mainAttr, castValue);
                }
                    break;
                default:
                {
                    LogProxy.LogError($"GatherAttr choseTarget参数类型错误，mainAttr={mainAttr}！");
                }
                    break;
            }
        }
        
        /// <summary>
        /// 清除单位的所有技能CD
        /// </summary>
        /// <param name="actorId"></param>
        public static void ClearSkillsCd(this Battle battle, int actorId)
        {
            var actor = battle.actorMgr.GetActor(actorId);
            var slots = actor.skillOwner.slots;
            foreach (var slotItem in slots)
            {
                var slot = slotItem.Value;
                var slotId = slotItem.Key;
                slot.SetRemainCD(0);
                slot.SetEnergyFull();
                if (slotId == BattleUtil.GetSlotID(SkillSlotType.Dodge, 0))
                {
                    slot.castCount = slot.maxCastCount;
                }
            }

            if (actor != battle.player || !actor.IsGirl()) return;
            var boy = battle.actorMgr.boy;
            if (boy == null || !boy.IsBoy()) return;
            var qteController = boy.skillOwner.qteController;
            qteController?.ClearCD();
            if (((BoyCfg)boy.config).ComboSkillStarter != 2) return;
            var comboSlot = battle.input.GetStaticSkillSlot(PlayerBtnType.Coop, boy.insID);
            comboSlot.SetRemainCD(0);
        }
        
        /// <summary>
        /// 设置物理中，穿透分离的最大迭代次数
        /// </summary>
        /// <param name="nums"></param>
        public static void SetMaxDepenetrationIterations(this Battle battle, int nums)
        {
            if (battle == null)
                return;
            var actors = battle.actorMgr.actors;
            if (actors == null)
                return;
            foreach (var actor in actors)
            {
                if (actor.model == null)
                    continue;
                if (actor.transform.characterMove == null)
                    continue;
                actor.transform.characterMove.maxDepenetrationIterations = nums;
            }
        }
        
        /// <summary>
        /// 启停所有角色表现以及显隐部分UI
        /// </summary>
        /// <param name="enable"> 是否启用 </param>
        public static void SetActorsEnable(this Battle battle, bool enable)
        {
            if (enable)
            {
                CriticalLog.Log("[战斗][关卡前流程][Battle.SetLevelBeforeUIActive()] 打开战斗UI，激活场上所有单位!");
            }
            
            BattleUtil.SetLevelBeforeUIActive(enable);
            var actors = battle.actorMgr.actors;
            foreach (Actor actor in actors)
            {
                if (enable)
                {
                    actor.stateTag?.ReleaseTag(ActorStateTagType.CannotMove);
                    actor.stateTag?.ReleaseTag(ActorStateTagType.CannotCastSkill);
                }
                else
                {
                    actor.stateTag?.AcquireTag(ActorStateTagType.CannotMove);
                    actor.stateTag?.AcquireTag(ActorStateTagType.CannotCastSkill);
                }
            }
        }
    }
}