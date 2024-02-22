using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 在线文档：https://papergames.feishu.cn/wiki/HQFhwvkVXi03aEkmueocY2p2nUf
    /// </summary>
    public class BattleDamageProcess : BattleComponent
    {
        private Queue<DamageParam> _damageParamQueue = new Queue<DamageParam>(10);
        private DamageParam _currDamageParam;
        private bool _enableDamage;

        public bool EnableDamage
        {
            get => _enableDamage;
            set
            {
                _enableDamage = value;
                if (!value)
                {
                    _damageParamQueue.Clear();
                }
            }
        }

        public BattleDamageProcess() : base(BattleComponentType.BattleDamageProcess)
        {
            _enableDamage = true;
        }

        protected override void OnDestroy()
        {
            _damageParamQueue.Clear();
        }

        public void ExportDamage(DamageParam damageParam)
        {
            if (!EnableDamage)
            {
                return;
            }

            if (damageParam == null)
            {
                return;
            }
            
            if (damageParam.damageExporter == null)
            {
                return;
            }

            if (damageParam.damageBoxCfg == null)
            {
                return;
            }

            if (damageParam.hitParamConfig == null)
            {
                return;
            }

            if (damageParam.hitTargetInfos == null || damageParam.hitTargetInfos.Count <= 0)
            {
                return;
            }

            int curDepth = _currDamageParam?.depth ?? 0;
            
            // DONE: 当堆栈深度达到5层时.
            var targetDepth = curDepth + 1;
            if (targetDepth > 5)
            {
                LogProxy.LogFatalFormat("【战斗】【严重错误】伤害流程存在嵌套深度 > 5层的设计 输出类型:{0}, CfgID:{1}.", damageParam.damageExporter.exporterType, damageParam.damageExporter.GetCfgID());
                return;
            }

            damageParam.depth = targetDepth;
            _damageParamQueue.Enqueue(damageParam);
            
            // DONE: 当前正在迭代, 只加队列即可.
            if (null != _currDamageParam)
            {
                return;
            }
            
            while (_damageParamQueue.Count > 0)
            {
                var param = _damageParamQueue.Dequeue();
                
                // DONE: 产生的递归当前的迭代深度.
                _currDamageParam = param;
                try
                {
                    DamageProcess.ProcessExportDamage(param);
                }
                catch (Exception e)
                {
                    LogProxy.LogError(e);
                }

                DamageParam.Recycle(param);
            }
            
            // DONE: 堆栈清空
            _currDamageParam = null;
        }

        public void PreCalDamage(DamageInfo damageInfo, DamageExporter damageExporter, Actor target, HitParamConfig hitParamConfig, float damageProportion, bool isCritical, DamageType damageType, List<AttrModifyData> attrModifyDatas, bool bIsTarget, float damageRandomValue)
        {
            DamageProcess.PreCalDamage(damageInfo, damageExporter, target, hitParamConfig, damageProportion, isCritical, damageType, attrModifyDatas, bIsTarget, damageRandomValue);
        }
        
        private static class DamageProcess
        {
            /// <summary>
            /// 伤害预计算
            /// </summary>
            /// <returns></returns>
            public static void PreCalDamage(DamageInfo damageInfo, DamageExporter damageExporter, Actor target, HitParamConfig hitParamConfig, float damageProportion, bool isCritical, DamageType damageType, List<AttrModifyData> attrModifyDatas, bool bIsTarget, float damageRandomValue)
            {
                damageInfo.Reset();
                damageInfo.actor = target;
                
                if (damageType == DamageType.Sub)
                {
                    DamageFormula.CalcDamage(ref damageInfo, damageExporter, target, null, hitParamConfig, 90, damageProportion, isCritical, attrModifyDatas, bIsTarget, damageRandomValue);
                }
                else if(damageType == DamageType.Add)
                {
                    DamageFormula.CalcHeal(ref damageInfo, damageExporter, target, hitParamConfig, damageProportion, attrModifyDatas, bIsTarget);
                }
            }
            
            /// <summary>
            /// 进入伤害流程.
            /// </summary>
            public static void ProcessExportDamage(DamageParam damageParam)
            {
                var damageExporter = damageParam.damageExporter;
                var damageBoxCfg = damageParam.damageBoxCfg;
                var hitParamConfig = damageParam.hitParamConfig;
                var damageProportion = damageParam.damageProportion;
                var hitTargetInfos = damageParam.hitTargetInfos;

                if (damageExporter?.actor == null)
                {
                    return;
                }
                
                if (damageBoxCfg == null)
                {
                    return;
                }

                if (hitParamConfig == null)
                {
                    return;
                }

                if (hitTargetInfos == null || hitTargetInfos.Count <= 0)
                {
                    return;
                }

                var battle = damageExporter.actor.battle;
                var eventMgr = battle.eventMgr;
                bool hasExportedDamage = false;

                using (ProfilerDefine.DamageProcess_FilterRules_PMarker.Auto())
                {
                    // DONE: 过滤规则
                    _FilterRules(damageExporter, hitTargetInfos, damageBoxCfg);
                }

                using (ProfilerDefine.DamageProcess_SortHitTargets_PMarker.Auto())
                {
                    _SortHitTargets(damageExporter, hitTargetInfos);
                }
                
                // DONE: 总命中流程开始事件.
                using (ProfilerDefine.DamageProcess_EventHitProcessStartDispatch_PMarker.Auto())
                {
                    var eventHitProcessStart = eventMgr.GetEvent<EventHitProcessStart>();
                    eventHitProcessStart.Init(damageExporter, damageBoxCfg, hitParamConfig);
                    eventMgr.Dispatch(EventType.OnHitProcessStart, eventHitProcessStart);
                }
                
                using (ProfilerDefine.DamageProcess_ExportDamage_PMarker.Auto())
                {
                    bool isCameraShake = false; //只播一次
                    foreach (var hitTargetInfo in hitTargetInfos)
                    {
                        var target = hitTargetInfo.actor;
                        var hitPoint = hitTargetInfo.hitPos;
                        var onlyPlayHitEffect = hitTargetInfo.onlyPlayHitEffect;
                        if (!isCameraShake && damageExporter.GetCaster().factionType == FactionType.Hero || target == Battle.Instance.player)
                        {
                            isCameraShake = true;
                            if (hitPoint != null)
                            {
                                using (ProfilerDefine.DamageProcess_PlayCameraShake_PMarker.Auto())
                                {
                                    Battle.Instance.cameraImpulse.AddWorldImpulse(damageBoxCfg.CameraShakePath, damageBoxCfg.ImpulseParameter, damageExporter.GetCaster(), null, hitPoint.Value);
                                }
                            }
                        }

                        bool isExportedDamage = false;
                        // DONE: 执行每一个目标的命中流程.
                        using (ProfilerDefine.DamageProcess_TryExecute_PMarker.Auto())
                        {
                            if (!onlyPlayHitEffect)
                            {
                                TryExecute(damageExporter, target, damageBoxCfg, hitParamConfig, damageProportion, hitPoint, out isExportedDamage);
                            }
                            else
                            {
                                _HitEffect(damageExporter, target, damageBoxCfg, hitPoint);
                            }
                        }

                        if (damageParam.exportedDamageAction != null)
                        {
                            using (ProfilerDefine.DamageProcess_ExportedDamageAction_PMarker.Auto())
                            {
                                damageParam.exportedDamageAction.Invoke(target, isExportedDamage);
                            }
                        }

                        hasExportedDamage |= isExportedDamage;
                    }
                }

                // DONE: 总命中流程结束事件.
                using (ProfilerDefine.DamageProcess_EventHitProcessEndDispatch_PMarker.Auto())
                {
                    var eventHitProcessEnd = eventMgr.GetEvent<EventHitProcessEnd>();
                    eventHitProcessEnd.Init(damageExporter, damageBoxCfg, hitParamConfig, hasExportedDamage);
                    eventMgr.Dispatch(EventType.OnHitProcessEnd, eventHitProcessEnd);
                }
            }

            /// <summary>
            /// 过滤规则
            /// </summary>
            /// <param name="hitTargetInfos"> 待过滤的命中列表 </param>
            /// <param name="damageBoxCfg"> 伤害盒配置数据 </param>
            private static void _FilterRules(DamageExporter damageExporter, List<HitTargetInfo> hitTargetInfos, DamageBoxCfg damageBoxCfg)
            {
                // DONE: TAG过滤, 假身女主过滤：如果这一次Hit列表既有女主又有假身，则视为女主没被Hit
                var hitGirlFakeBody = false; // 是否命中过女主假身
                var needRemoveGirl = false; // 是否需要移除女主
                for (int i = hitTargetInfos.Count - 1; i >= 0; i--)
                {
                    var target = hitTargetInfos[i].actor;
                    var hitPos = hitTargetInfos[i].hitPos;

                    // DONE: 检测是否命中女主假身
                    if (target.IsFakebody() && target.master.IsGirl())
                    {
                        hitGirlFakeBody = true;
                        
                        // DONE: 当是子弹命中并且子弹还配置了命中假身仅播放特效.
                        if (damageExporter is SkillMissile skillMissile && skillMissile.missileCfg.IsHitFakebodyPlayEffect)
                        {
                            hitTargetInfos[i] = new HitTargetInfo
                            {
                                actor = target,
                                hitPos = hitPos,
                                onlyPlayHitEffect = true
                            };
                        }
                        else
                        {
                            hitTargetInfos.RemoveAt(i);
                        }
                        continue;
                    }
                    
                    // DONE: 免疫命中的过滤掉.
                    if (target.stateTag != null && target.stateTag.IsActive(ActorStateTagType.HitIgnore))
                    {
                        if (damageExporter is SkillMissile missile && missile.missileCfg.IsHitFakebodyPlayEffect)
                        {
                            hitTargetInfos[i] = new HitTargetInfo
                            {
                                actor = target,
                                hitPos = hitPos,
                                onlyPlayHitEffect = true
                            };
                        }
                        else
                        {
                            hitTargetInfos.RemoveAt(i);
                        }
                        continue;
                    }

                    // DONE: 免疫攻击的过滤掉
                    if (target.stateTag != null && target.stateTag.IsActive(ActorStateTagType.AttackIgnore) && damageBoxCfg.DamageBoxType == DamageBoxType.Attack)
                    {
                        if (damageExporter is SkillMissile missile && missile.missileCfg.IsHitFakebodyPlayEffect)
                        {
                            hitTargetInfos[i] = new HitTargetInfo
                            {
                                actor = target,
                                hitPos = hitPos,
                                onlyPlayHitEffect = true
                            };
                        }
                        else
                        {
                            hitTargetInfos.RemoveAt(i);
                        }
                        continue;
                    }

                    // DONE：这个需要记录Idx，所以需要放后面
                    if (target.IsGirl()) // 如果命中女主
                    {
                        needRemoveGirl = true;
                        if (hitGirlFakeBody) // 如果先命中女主假身，再命中女主，则移除女主
                        {
                            needRemoveGirl = false;
                            hitTargetInfos.RemoveAt(i);
                            continue;
                        }
                    }
                }

                // DONE: 如果先命中了女主，再命中了女主假身，则移除女主
                if (hitGirlFakeBody && needRemoveGirl)
                {
                    for (int i = hitTargetInfos.Count - 1; i >= 0; i--)
                    {
                        var target = hitTargetInfos[i].actor;
                        if (target.IsGirl())
                        {
                            hitTargetInfos.RemoveAt(i);
                            break;
                        }
                    }
                }
            }

            /// <summary>
            /// 命中目标排序, 优化的冒泡算法
            /// 1、锁定目标；2、依据距离由近到远
            /// </summary>
            private static void _SortHitTargets(DamageExporter damageExporter, List<HitTargetInfo> hitTargetInfos)
            {
                var count = hitTargetInfos.Count;
                if (count <= 1) return;

                var caster = damageExporter.GetCaster();
                var position = caster.transform.position;
                var lockTarget = caster.GetTarget(TargetType.Lock);

                for (var i = 0; i < count - 1; i++)
                {
                    var swapped = false;
                    for (var j = 0; j < count - i - 1; j++)
                    {
                        var hitTargetA = hitTargetInfos[j];
                        var hitTargetB = hitTargetInfos[j + 1];

                        if (hitTargetA.actor == lockTarget)
                        {
                            continue;
                        }

                        if (hitTargetB.actor == lockTarget)
                        {
                            swapped = true;
                            hitTargetInfos[j] = hitTargetB;
                            hitTargetInfos[j + 1] = hitTargetA;
                            continue;
                        }

                        var disA = (hitTargetA.actor.transform.position - position).sqrMagnitude;
                        var disB = (hitTargetB.actor.transform.position - position).sqrMagnitude;
                        if (disB < disA)
                        {
                            swapped = true;
                            hitTargetInfos[j] = hitTargetB;
                            hitTargetInfos[j + 1] = hitTargetA;
                            continue;
                        }
                    }

                    // 如果在这一轮中没有发生交换，说明数组已经排序完成，可以提前结束
                    if (!swapped)
                        break;
                }
            }
            
            /// <summary>
            /// 执行命中流程
            /// </summary>
            private static void TryExecute(DamageExporter damageExporter, Actor target, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, float damageProportion, Vector3? hitPoint, out bool isExportedDamage)
            {
                isExportedDamage = false;
                if (!_CanHit(target)) 
                    return;
                var caster = damageExporter.GetCaster();
                PapeGames.X3.LogProxy.LogFormat("[{0}]的 伤害包围盒ID={1} 命中了[{2}]", caster.name, damageBoxCfg.ID, target.name);

                var battle = damageExporter.actor.battle;
                var eventMgr = battle.eventMgr;
                var hitInfo = ObjectPoolUtility.HitInfoPool.Get();
                hitInfo.Init(damageExporter, damageBoxCfg, hitParamConfig, target, damageProportion, hitPoint);
                var dynamicHitInfo = ObjectPoolUtility.DynamicHitInfoPool.Get();

                // DONE: 命中前事件.
                using (ProfilerDefine.DamageProcess_EventBeforeHitDispatch_PMarker.Auto())
                {
                    var eventBeforeHit = eventMgr.GetEvent<EventBeforeHit>();
                    eventBeforeHit.Init(hitInfo, dynamicHitInfo, damageProportion);
                    eventMgr.Dispatch(EventType.OnBeforeHit, eventBeforeHit);
                }
                
                // 来自damageExporter的增幅
                // 举例：普攻连续释放4次，打出4发子弹，前两发子弹附带伤害增幅效果
                if (damageExporter.finalDamageAddAttr > 0)
                {
                    dynamicHitInfo.attrModifies.Add(new AttrModifyData()
                    {
                        actor = caster,
                        attrType = AttrType.FinalDamageAdd,
                        additionalValue = damageExporter.finalDamageAddAttr,
                    });
                }

                // DONE: 伤害随机值.
                float damageRandomValue = 0f;
                if (!hitParamConfig.IsSkipRandomDamage)
                {
                    damageRandomValue = UnityEngine.Random.Range(0, 1f);
                }

                // DONE: 暴击骰子
                bool isCritical = false;
                bool isWeak = target.actorWeak?.weak ?? false; 

                // DONE: 是否跳过暴击骰子
                if (!hitParamConfig.IsSkipCrit && !hitParamConfig.IsTrueDamage && !isWeak)
                {
                    using (ProfilerDefine.DamageProcess_CriticalJudge_PMarker.Auto())
                    {
                        isCritical = DamageFormula.CriticalJudge(hitParamConfig, caster, dynamicHitInfo.criticalModifies, dynamicHitInfo.attrModifies);
                    }
                }
                
                if (isCritical)
                {
                    // DONE: 暴击事件.
                    using (ProfilerDefine.DamageProcess_EventCriticalJudgeDispatch_PMarker.Auto())
                    {
                        var eventDamageCritical = eventMgr.GetEvent<EventDamageCritical>();
                        eventDamageCritical.Init(hitInfo, dynamicHitInfo, damageProportion);
                        eventMgr.Dispatch(EventType.OnDamageCritical, eventDamageCritical);
                    }
                }

                // DONE: 伤害前效果
                _PrevDamage(damageExporter, target, damageBoxCfg);

                using (ProfilerDefine.DamageProcess_EventPrevDamage_PMarker.Auto())
                {
                    // DONE: 发出伤害前事件.
                    var eventPrevDamage = eventMgr.GetEvent<EventPrevDamage>();
                    eventPrevDamage.Init(hitInfo, dynamicHitInfo, damageProportion, isCritical, damageRandomValue);
                    eventMgr.Dispatch(EventType.OnPrevDamage, eventPrevDamage);
                }
                
                // DONE: 命中表现
                _HitEffect(damageExporter, target, damageBoxCfg, hitPoint);

                // DONE: 打断流程
                if (dynamicHitInfo.isInterruptHitProcess)
                {
                    using (ProfilerDefine.DamageProcess_IsInterruptHitProcess_PMarker.Auto())
                    {
                        ObjectPoolUtility.HitInfoPool.Release(hitInfo);
                        ObjectPoolUtility.DynamicHitInfoPool.Release(dynamicHitInfo);
                        PapeGames.X3.LogProxy.LogFormat("[{0}]的 伤害包围盒ID={1} 命中[{2}]的 流程被打断了", caster.name, damageBoxCfg.ID, target.name);
                    }
                    return;
                }
                
                // DONE: 能量消耗
                _ResourceCost(damageExporter, target, hitParamConfig, damageProportion);
                
                // DONE: 伤害结算
                _TakeDamage(hitInfo, target, damageProportion, isCritical, dynamicHitInfo.attrModifies, damageRandomValue, out isExportedDamage);
                
                // DONE: 虚弱处理
                _BrokenShield(target, hitInfo, out bool ignoreToughness);
                
                // DONE: 破韧计算
                _BrokenToughness(damageExporter, target, damageBoxCfg, hitInfo, ignoreToughness);

                // DONE: 命中后效果
                _AfterHit(damageExporter, target, damageBoxCfg);

                // DONE: 死亡判断.
                _TryDead(hitInfo, target);

                ObjectPoolUtility.HitInfoPool.Release(hitInfo);
                ObjectPoolUtility.DynamicHitInfoPool.Release(dynamicHitInfo);
                PapeGames.X3.LogProxy.LogFormat("[{0}] 命中 [{1}] 的命中流程结束", caster.name, target.name);
            }

            /// <summary>
            /// 检测是否允许命中
            /// </summary>
            /// <returns></returns>
            private static bool _CanHit(Actor target)
            {
                if (target == null)
                {
                    return false;
                }
                
                // DONE: 已经死亡的就不要继续处理了.
                if (target.isDead)
                {
                    return false;
                }

                return true;
            }
            
            /// <summary>
            /// 通常的命中表现效果在命中成功后立即处理：攻击方定帧/受击音效/受击特效/震屏/砍痕
            /// </summary>
            private static void _HitEffect(DamageExporter damageExporter, Actor target, DamageBoxCfg damageBoxCfg, Vector3? hitPoint)
            {
                using (ProfilerDefine.DamageProcess_HitEffect_PMarker.Auto())
                {
                    if (damageExporter == null)
                        return;

                    // DONE: 优先取主人的model, 如果主人死亡了, 则取伤害包围盒的拥有者.
                    var caster = damageExporter.GetCaster();
                    caster = !(caster == null || caster.isDead) ? caster : damageExporter.actor;

                    // DONE: 受击特效
                    if (damageBoxCfg.HurtFXID != 0)
                    {
                        _PlayHurtFX(caster, target, damageBoxCfg, hitPoint);
                    }

                    // DONE: 受击音效
                    using (ProfilerDefine.DamageProcess_HitEffect_PlaySound_PMarker.Auto())
                    {
                        var sound = target.hurt?.GetHurtSound(damageBoxCfg);
                        if (!string.IsNullOrEmpty(sound) && !string.IsNullOrWhiteSpace(sound))
                        {
                            caster.PlaySound(BattleResType.ActorAudio, sound, caster.GetDummy(ActorDummyType.Model).gameObject);
                        }
                    }
                    
                    // DONE: 受击材质动画
                    using (ProfilerDefine.DamageProcess_HitEffect_PlayMatAnimator_PMarker.Auto())
                    {
                        if (target.type == ActorType.Monster && damageBoxCfg.PlayHurtFXMat)
                        {
                            target.model.curveAnimator.Play(target.battle.misc.hitMatEffect);
                        }
                    }
                }
            }
            
            /// <summary>
            /// 伤害前效果
            /// </summary>
            private static void _PrevDamage(DamageExporter damageExporter, Actor target, DamageBoxCfg damageBoxCfg)
            {
                using (ProfilerDefine.DamageProcess_PrevDamage_PMarker.Auto())
                {
                    // DONE: 处理命中后的添加Buff效果.
                    if (damageBoxCfg.PreAddBuffDatas != null)
                    {
                        for (int i = 0; i < damageBoxCfg.PreAddBuffDatas.Length; i++)
                        {
                            var addBuffData = damageBoxCfg.PreAddBuffDatas[i];
                            _ExeAddBuffAffect(damageExporter, target, addBuffData);
                        }
                    }
                }
            }

            /// <summary>
            /// 步骤2：资源消耗
            /// </summary>
            private static void _ResourceCost(DamageExporter damageExporter, Actor target, HitParamConfig hitParamConfig, float damageProportion)
            {
                using (ProfilerDefine.DamageProcess_ResourceCost_PMarker.Auto())
                {
                    // 男主受击，消耗女主能量
                    if (target.IsBoy())
                        target = Battle.Instance.actorMgr.girl;
                    // DONE: 对目标的能量处理
                    _ConsumeEnergy(target, hitParamConfig.TargetEnergy, damageProportion);

                    // DONE: 对目标的爆发能量处理
                    _ConsumeUltraEnergy(target, hitParamConfig.TargetUltraEnergy, damageProportion);

                    // 男主攻击，消耗女主能量
                    var caster = damageExporter.GetCaster();
                    if (caster.IsBoy())
                        caster = Battle.Instance.actorMgr.girl;
                    // DONE: 对施法者的能量处理
                    _ConsumeEnergy(caster, hitParamConfig.SelfEnergy, damageProportion);

                    // DONE: 对施法者的爆发能量处理
                    _ConsumeUltraEnergy(caster, hitParamConfig.SelfUltraEnergy, damageProportion);
                }
            }

            private static void _ConsumeEnergy(Actor target, S2Int[] s2IntArr, float damageProportion)
            {
                if (target?.energyOwner == null)
                    return;
                if (s2IntArr == null || s2IntArr.Length <= 0)
                    return;
                foreach (var s2Int in s2IntArr)
                {
                    float energy = s2Int.Num * damageProportion;
                    if (energy > 0)
                    {
                        target.energyOwner.GatherEnergy((AttrType) s2Int.ID, energy);
                    }
                    else if (energy < 0)
                    {
                        target.energyOwner.ConsumeEnergy((AttrType) s2Int.ID, -energy,false,0);
                    }
                }
            }

            private static void _ConsumeUltraEnergy(Actor target, int ultraEnergy, float damageProportion)
            {
                if (target?.energyOwner == null)
                    return;
                float energy = ultraEnergy * damageProportion;
                if (energy > 0)
                {
                    target.energyOwner.GatherEnergy(AttrType.UltraEnergy, energy);
                }
                else if (energy < 0)
                {
                    target.energyOwner.ConsumeEnergy(AttrType.UltraEnergy, -energy,false,0);
                }
            }

            /// <summary>
            /// 步骤3：虚弱芯核计算(虚弱处理)
            /// </summary>
            private static void _BrokenShield(Actor target, HitInfo hitInfo, out bool ignoreToughness)
            {
                using (ProfilerDefine.DamageProcess_BrokenShield_PMarker.Auto())
                {
                    ignoreToughness = false;
                    // DONE: 芯核伤害免疫
                    if (target.stateTag != null && target.stateTag.IsActive(ActorStateTagType.CoreDamageImmunity))
                    {
                        return;
                    }

                    if (target.actorWeak == null || target.actorWeak.locked)
                        return;

                    if (target.actorWeak.weak && hitInfo.damageBoxCfg.HurtType != HurtType.Null && hitInfo.damageBoxCfg.ToughnessReduce > 0)
                    {
                        target.actorWeak.OnWeakHurt(hitInfo.damageBoxCfg);
                    }

                    if (target.actorWeak.CanReduceShield())
                    {
                        var spAttr = target.attributeOwner.GetAttr(AttrType.WeakPoint);
                        if (spAttr == null)
                            return;

                        var caster = hitInfo.damageExporter.GetCaster();
                        float spDamage = hitInfo.hitParamConfig.TargetShieldReduce == 0 ? 0 : hitInfo.hitParamConfig.TargetShieldReduce * caster.attributeOwner.GetAttrValue(AttrType.CoreDamageRatio) + caster.attributeOwner.GetAttrValue(AttrType.CoreDamageAdd);
                        ignoreToughness = target.actorWeak.SubShield(spDamage, hitInfo);
                    }
                }
            }

            /// <summary>
            /// 步骤4：破韧计算
            /// </summary>
            private static void _BrokenToughness(DamageExporter damageExporter, Actor target, DamageBoxCfg damageBoxCfg, HitInfo hitInfo, bool ignoreToughness)
            {
                using (ProfilerDefine.DamageProcess_BrokenToughness_PMarker.Auto())
                {
                    if (target.hurt == null)
                        return;
                    if (damageBoxCfg.DamageBoxType == DamageBoxType.Attack)
                    {
                        Vector3 hurtDir;
                        using (ProfilerDefine.DamageProcess_BrokenToughness_HurtDir_PMarker.Auto())
                        {
                            //Default如果伤害施加者是子弹，则使用子弹的面朝方向， 否则用连线方向
                            if (damageExporter is SkillMissile)
                            {
                                hurtDir = damageExporter.actor.transform.forward;
                            }
                            //  - 如果是Timeline创建的打击盒 使用timeline方向
                            else if (damageExporter is SkillActive skillActive && damageBoxCfg.HurtBackStrategy == HurtBackStrategy.Timeline)
                            {
                                hurtDir = skillActive.castActorForward;
                            }
                            else if (damageExporter.actor.IsRole() && damageBoxCfg.HurtBackStrategy == HurtBackStrategy.Attacker)
                            {
                                hurtDir = damageExporter.actor.transform.forward;
                            }
                            else if (damageExporter is X3Buff)
                            {
                                hurtDir = target.transform.position - damageExporter.GetCaster().transform.position;
                                hurtDir = hurtDir.normalized;
                                if (hurtDir.x == 0 && hurtDir.z == 0)
                                    hurtDir = -target.transform.forward;
                            }
                            else
                            {
                                hurtDir = target.transform.position - damageExporter.actor.transform.position;
                                hurtDir = hurtDir.normalized;
                                if (hurtDir.x == 0 && hurtDir.z == 0)
                                {
                                    //法术场/子弹爆炸对目标单位的连线方向
                                    //如果此连线向量为0  那么取释放法术场/子弹爆炸的所有者与目标单位的连线方向
                                    if (damageExporter is SkillMagicField ||
                                        damageExporter is SkillMissile && (damageExporter as SkillMissile).missileCfg.IsBlastEffect && damageBoxCfg.ID == (damageExporter as SkillMissile).missileCfg.BlastDamageBox)
                                    {
                                        hurtDir = target.transform.position - damageExporter.GetCaster().transform.position;
                                        hurtDir = hurtDir.normalized;
                                        if (hurtDir.x == 0 && hurtDir.z == 0)
                                            hurtDir = -target.transform.forward;
                                    }
                                    else
                                    {
                                        hurtDir = -target.transform.forward;
                                    }
                                }

                                hurtDir = hurtDir.normalized;
                            }
                        }

                        float hurtBackDis = damageBoxCfg.HurtBackDis;
                        if (damageBoxCfg.DistanceDecrease)
                        {
                            // 如果配置了击退距离衰减
                            float actorDis = BattleUtil.GetActorDistance(target, damageExporter.actor);
                            if (actorDis <= damageBoxCfg.MinDecreaseDistance)
                            {
                                hurtBackDis = damageBoxCfg.MaxHurtBackDistance;
                            }
                            else if (actorDis >= damageBoxCfg.MaxDecreaseDistance)
                            {
                                hurtBackDis = damageBoxCfg.MinHurtBackDistance;
                            }
                            else
                            {
                                hurtBackDis = (damageBoxCfg.MaxDecreaseDistance - actorDis) / (damageBoxCfg.MaxDecreaseDistance - damageBoxCfg.MinDecreaseDistance) * (damageBoxCfg.MaxHurtBackDistance - damageBoxCfg.MinHurtBackDistance) + damageBoxCfg.MinHurtBackDistance;
                            }
                        }

                        target.hurt.TakeEffect(hurtDir, hurtBackDis, damageBoxCfg, ignoreToughness, out bool isEnterHurt);

                        if (isEnterHurt)
                        {
                            using (ProfilerDefine.DamageProcess_BrokenToughness_OnEventEnterHurt_PMarker.Auto())
                            {
                                var eventMgr = damageExporter.actor.battle.eventMgr;
                                var eventEnterHurt = eventMgr.GetEvent<OnEventEnterHurt>();
                                eventEnterHurt.Init(damageExporter.GetCaster(), target, hitInfo);
                                eventMgr.Dispatch(EventType.EnterHurt, eventEnterHurt);
                            }
                        }
                    }
                }
            }

            /// <summary>
            /// 步骤5：伤害/治疗计算
            /// </summary>
            private static void _TakeDamage(HitInfo hitInfo, Actor target, float damageProportion, bool isCritical, List<AttrModifyData> modifyAttrValues, float damageRandomValue, out bool isExportedDamage)
            {
                using (ProfilerDefine.DamageProcess_TakeDamage_PMarker.Auto())
                {
                    isExportedDamage = false;

                    using (ProfilerDefine.DamageProcess_TakeDamage_Target_PMarker.Auto())
                    {
                        // DONE: 处理目标的伤害结算
                        _TakeDamageHandle(hitInfo, target, damageProportion, isCritical, (DamageType)hitInfo.hitParamConfig.TargetDamageType, modifyAttrValues, true, damageRandomValue, out bool toSelfExportedDamage);
                        isExportedDamage |= toSelfExportedDamage;
                    }
                    
                    using (ProfilerDefine.DamageProcess_TakeDamage_Caster_PMarker.Auto())
                    {
                        // DONE: 处理自己的伤害结算
                        _TakeDamageHandle(hitInfo, hitInfo.damageExporter.GetCaster(), damageProportion, isCritical, (DamageType)hitInfo.hitParamConfig.SelfDamageType, modifyAttrValues, false, damageRandomValue, out bool toTargetExportedDamage);
                        isExportedDamage |= toTargetExportedDamage;
                    }
                }
            }

            private static void _TakeDamageHandle(HitInfo hitInfo, Actor target, float damageProportion, bool isCritical, DamageType damageType, List<AttrModifyData> modifyAttrValues, bool bIsTarget, float damageRandomValue, out bool isExportedDamage)
            {
                isExportedDamage = false;
                var battle = target.battle;
                var eventMgr = battle.eventMgr;
                var damageExporter = hitInfo.damageExporter;
                var damageBoxCfg = hitInfo.damageBoxCfg;
                var hitParamConfig = hitInfo.hitParamConfig;

                var damageInfo = ObjectPoolUtility.DamageInfoPool.Get();
                damageInfo.actor = target;
                
                // 伤害
                if (damageType == DamageType.Sub)
                {
                    // DONE: 伤害免疫.
                    if (target.stateTag != null && target.stateTag.IsActive(ActorStateTagType.DamageImmunity))
                    {
                        // DONE: 伤害无效事件.
                        using (ProfilerDefine.DamageProcess_TakeDamage_OnDamageInvalid_PMarker.Auto())
                        {
                            var eventDamageInvalid = eventMgr.GetEvent<EventDamageInvalid>();
                            eventDamageInvalid.Init(hitInfo, DamageInvalidType.DamageImmunity);
                            eventMgr.Dispatch(EventType.OnDamageInvalid, eventDamageInvalid);
                        }
                        ObjectPoolUtility.DamageInfoPool.Release(damageInfo);
                        return;
                    }

                    // DONE: 获取协作者.
                    Actor assistor = damageBoxCfg.HasAssist ? _GetAssistor(damageExporter.GetCaster()) : null;
                    
                    using (ProfilerDefine.DamageProcess_TakeDamage_CalcDamage_PMarker.Auto())
                    {
                        // TODO hurtAddAngle
                        DamageFormula.CalcDamage(ref damageInfo, damageExporter, target, assistor, hitParamConfig, 90, damageProportion, isCritical, modifyAttrValues, bIsTarget, damageRandomValue);
                    }

                    // DONE: 伤害结算前事件.
                    var eventPreExportDamage = eventMgr.GetEvent<EventPreExportDamage>();
                    eventPreExportDamage.Init(hitInfo, damageInfo, damageType);
                    eventMgr.Dispatch(EventType.OnPreExportDamage, eventPreExportDamage, false);
                    
                    PapeGames.X3.LogProxy.LogFormat("[{0}] 对 [{1}] 使用{2}-{3} DamageBox:{7}, 造成伤害: DamageInfo: damage={4}, realDamage={5}, isCritical={6}", damageExporter.GetCaster().name, target.name, damageExporter.exporterType, damageExporter.GetID(), damageInfo.damage, damageInfo.realDamage, damageInfo.isCritical, damageBoxCfg.ID);

                    // DONE: 扣血
                    if (damageInfo.realDamage != 0f)
                    {
                        float realDamage = damageInfo.realDamage;
                        var hpAttr = target.attributeOwner.GetAttr(AttrType.HP);

                        // DONE: 处理锁血(锁值)逻辑
                        bool bIsLockHp = false;
                        float lockHpValue = eventPreExportDamage.dynamicDamageInfo.lockHpValue;
                        int buffId = eventPreExportDamage.dynamicDamageInfo.lockHpBuffId;
                        if (eventPreExportDamage.dynamicDamageInfo.isLockHp && lockHpValue > 0f)
                        {
                            var curHpValue = hpAttr.GetValue();
                            // DONE: 当前血量已小于等于锁血值时, 伤害为0.
                            if (curHpValue <= lockHpValue)
                            {
                                realDamage = 0f;
                            }
                            else
                            {
                                var remainHp = curHpValue - damageInfo.realDamage;
                                if (remainHp < lockHpValue)
                                {
                                    bIsLockHp = true;
                                    realDamage = curHpValue - lockHpValue;
                                }
                            }
                        }

                        target.hpOwner.Sub(realDamage, 0, 0);

                        // DONE: 扣除伤害后, 才发出锁血事件.
                        if (bIsLockHp)
                        {
                            var eventData = eventMgr.GetEvent<EventLockHp>();
                            eventData.Init(hitInfo, damageInfo, lockHpValue,buffId);
                            eventMgr.Dispatch(EventType.OnLockHp, eventData);
                        }
                    }
                    
                    // DONE: 伤害结算后事件.
                    using (ProfilerDefine.DamageProcess_TakeDamage_EventExportDamage_PMarker.Auto())
                    {
                        var eventAftExportDamage = eventMgr.GetEvent<EventExportDamage>();
                        eventAftExportDamage.Init(hitInfo, damageInfo, damageType);
                        eventMgr.Dispatch(EventType.ExportDamage, eventAftExportDamage);
                    }

                    eventMgr.ReleaseEvent(eventPreExportDamage);

                    isExportedDamage = true;
                }
                // 治疗
                else if (damageType == DamageType.Add)
                {
                    using (ProfilerDefine.DamageProcess_TakeDamage_CalcHeal_PMarker.Auto())
                    {
                        DamageFormula.CalcHeal(ref damageInfo, damageExporter, target, hitParamConfig, damageProportion, modifyAttrValues, bIsTarget);
                    }

                    // DONE: 伤害结算前事件.
                    var eventPreExportDamage = eventMgr.GetEvent<EventPreExportDamage>();
                    eventPreExportDamage.Init(hitInfo, damageInfo, damageType);
                    eventMgr.Dispatch(EventType.OnPreExportDamage, eventPreExportDamage, false);

                    PapeGames.X3.LogProxy.LogFormat("[{0}] 对 [{1}] 使用{2}-{3} DamageBox={7}, 造成治疗: DamageInfo: damage={4}, realDamage={5}, isCritical={6}", damageExporter.GetCaster().name, target.name, damageExporter.exporterType, damageExporter.GetID(), damageInfo.damage, damageInfo.realDamage, damageInfo.isCritical, damageBoxCfg.ID);
                    
                    target.hpOwner.Add(damageInfo.realDamage, 0, 0);
                    
                    // DONE: 伤害结算后事件.
                    var eventAftExportDamage = eventMgr.GetEvent<EventExportDamage>();
                    eventAftExportDamage.Init(hitInfo, damageInfo, damageType);
                    eventMgr.Dispatch(EventType.ExportDamage, eventAftExportDamage);

                    eventMgr.ReleaseEvent(eventPreExportDamage);
                }
                else if (damageType == DamageType.Deduct)
                {
                    using (ProfilerDefine.DamageProcess_TakeDamage_CalcDeduct_PMarker.Auto())
                    {
                        DamageFormula.CalcDeduct(ref damageInfo, damageExporter, target, hitParamConfig);
                    }
                    
                    // DONE: 伤害结算前事件.
                    var eventPreExportDamage = eventMgr.GetEvent<EventPreExportDamage>();
                    eventPreExportDamage.Init(hitInfo, damageInfo, damageType);
                    eventMgr.Dispatch(EventType.OnPreExportDamage, eventPreExportDamage, false);

                    PapeGames.X3.LogProxy.LogFormat("[{0}] 对 [{1}] 使用{2}-{3} DamageBox={8}, 造成扣除: DamageInfo: damage={4}, realDamage={5}, isCritical={6}", damageExporter.GetCaster().name, target.name, damageExporter.exporterType, damageExporter.GetID(), damageInfo.damage, damageInfo.realDamage, damageInfo.isCritical, damageBoxCfg.ID);
                    target.hpOwner.DeductHp(damageInfo.realDamage);
                    
                    // DONE: 伤害结算后事件.
                    var eventAftExportDamage = eventMgr.GetEvent<EventExportDamage>();
                    eventAftExportDamage.Init(hitInfo, damageInfo, damageType);
                    eventMgr.Dispatch(EventType.ExportDamage, eventAftExportDamage);

                    eventMgr.ReleaseEvent(eventPreExportDamage);
                }

                ObjectPoolUtility.DamageInfoPool.Release(damageInfo);
            }

            /// <summary>
            /// 步骤6：命中之后
            /// </summary>
            private static void _AfterHit(DamageExporter damageExporter, Actor target, DamageBoxCfg damageBoxCfg)
            {
                using (ProfilerDefine.DamageProcess_AfterHit_PMarker.Auto())
                {
                    // DONE: 处理命中后的添加Buff效果.
                    if (damageBoxCfg.AfterAddBuffDatas != null)
                    {
                        for (int i = 0; i < damageBoxCfg.AfterAddBuffDatas.Length; i++)
                        {
                            var addBuffData = damageBoxCfg.AfterAddBuffDatas[i];
                            _ExeAddBuffAffect(damageExporter, target, addBuffData);
                        }
                    }

                    if (damageBoxCfg.AfterTractionData != null)
                    {
                        var dragAction = ObjectPoolUtility.BuffActionDragPool.Get();
                        var targetPos = damageExporter.actor.transform.position + Quaternion.LookRotation(damageExporter.actor.transform.forward) * damageBoxCfg.AfterTractionData.OffsetPos;
                        var time = damageBoxCfg.AfterTractionData.Time;
                        var tweenEaseType = damageBoxCfg.AfterTractionData.TweenEaseType;

                        // DONE: 创建牵引buff.
                        target.buffOwner.AddDynamicAcionBuff(dragAction, time, damageExporter.actor);
                        dragAction.SetDragData(targetPos, time, tweenEaseType);
                    }
                }
            }
            
            /// <summary>
            /// 步骤7：死亡检测
            /// </summary>
            private static void _TryDead(HitInfo hitInfo, Actor target)
            {
                using (ProfilerDefine.DamageProcess_TryDead_PMarker.Auto())
                {
                    var curHp = target.attributeOwner.GetAttrValue(AttrType.HP);
                    if (curHp > 0)
                        return;

                    using (ProfilerDefine.DamageProcess_TryDead_EventOnKillTarget_PMarker.Auto())
                    {
                        var eventMgr = target.battle.eventMgr;
                        var eventData = eventMgr.GetEvent<EventOnKillTarget>();
                        eventData.Init(hitInfo, hitInfo.damageCaster, target);
                        eventMgr.Dispatch(EventType.OnKillTarget, eventData);
                    }

                    // 死亡时触发顿帧
                    target.SetTimeScale(TbUtil.battleConsts.DuringDamageBoxTimeScale, hitInfo.damageBoxCfg.HurtScaleDuration);
                    target.Dead();
                }
            }
            
            /// <summary>
            /// 播放受击特效
            /// </summary>
            /// <param name="caster"> 攻击者 </param>
            /// <param name="target"> 目标Actor </param>
            /// <param name="damageBoxCfg"> 伤害包围盒配置文件 </param>
            /// <param name="hitPoint"> 命中点 </param>
            private static void _PlayHurtFX(Actor caster, Actor target, DamageBoxCfg damageBoxCfg, Vector3? hitPoint)
            {
                using (ProfilerDefine.DamageProcess_HitEffect_PlayHurtFX_PMarker.Auto())
                {
                    var casterTransform = caster.transform;
                    Vector3 normal = Vector3.forward;
                    Vector3 hitPos = target.transform.position;
                    Vector3 worldEuler = Vector3.zero;

                    bool bIsWorldParent = false;

                    // 1.命中特效以该次命中的攻击包围盒与受击包围盒的交点作为特效播放的位置点
                    // 2.Front面朝向命中施加者（Z方向正对受击施加者）
                    if (!damageBoxCfg.IsFxCfgHangPoint)
                    {
                        Vector3? referPoint = null;
                        // DONE: 物理检测类型, 使用命中点位置.
                        if (damageBoxCfg.CheckTargetType == CheckTargetType.Physical)
                        {
                            referPoint = hitPoint;
                        }
                        // DONE: 直接检测类型, 默认使用Point_Hit挂点位置.
                        else
                        {
                            referPoint = target.GetDummy(TbUtil.battleConsts.DamageBoxDirectFx)?.position;
                        }

                        if (referPoint != null)
                        {
                            bIsWorldParent = true;

                            var pos = referPoint.Value;
                            
                            // 特效位置，特效位置使用局部空间坐标系
                            // 计算出局部坐标系坐标轴
                            var localZAxis = target.transform.position - casterTransform.position;
                            localZAxis.y = 0;
                            localZAxis = localZAxis.normalized;
                            var localXAxis = Vector3.Cross(Vector3.up, localZAxis);
                            // 计算出偏移
                            var hurtFxOffsetPos = damageBoxCfg.HurtFxOffsetPos;
                            var offsetPos = hurtFxOffsetPos.x * localXAxis + hurtFxOffsetPos.y * Vector3.up + hurtFxOffsetPos.z * localZAxis;
                            // 计算出最终hitPos点
                            hitPos = pos + offsetPos;

                            // 特效朝向
                            normal = casterTransform.position - hitPos;
                            normal.y = 0f;
                            normal.Normalize();
                            // 角度偏移
                            Vector3 randomAngle = new Vector3(UnityEngine.Random.Range(0f, damageBoxCfg.HurtFxRandomEuler.x), UnityEngine.Random.Range(0f, damageBoxCfg.HurtFxRandomEuler.y), UnityEngine.Random.Range(0f, damageBoxCfg.HurtFxRandomEuler.z));
                            // 世界旋转
                            var rotation = Quaternion.LookRotation(normal) * Quaternion.Euler(damageBoxCfg.HurtFxOffsetEuler + randomAngle);
                            worldEuler = rotation.eulerAngles;

                            #region 特效点随机逻辑

                            var hurtRandomType = damageBoxCfg.RandomHurtFxType;
                            var hurtRandomFxRadius = damageBoxCfg.RandomHurtFxRadius;
                            if (hurtRandomType == BattleFXRandomHurtType.Square)
                            {
                                var randomResult = UnityEngine.Random.Range(-hurtRandomFxRadius, hurtRandomFxRadius);
                                var xAxis = Vector3.Cross(Vector3.up, normal);
                                hitPos.x += xAxis.x * randomResult;
                                hitPos.y += randomResult;
                                hitPos.z += xAxis.z * randomResult;
                            }

                            #endregion
                        }
                    }

                    var attackFxID = damageBoxCfg.HurtFXID;
                    FxPlayer fxObj = null;

                    // 受击特效，根据
                    int? hurtFxID = target.hurt?.GetHurtFxID(damageBoxCfg);
                    using (ProfilerDefine.DamageProcess_HitEffect_PlayHurtFX_PlayFx__PMarker.Auto())
                    {
                        if (bIsWorldParent)
                        {
                            fxObj = target.effectPlayer.PlayFx(attackFxID, hitPos, worldEuler, true, resType: BattleResType.HurtFX, creator: caster, timeScaleType: FxPlayer.TimeScaleType.Battle);
                            if (hurtFxID != null)
                                target.effectPlayer.PlayFx((int)hurtFxID, hitPos, worldEuler, true, resType: BattleResType.HurtFX, creator: caster, timeScaleType: FxPlayer.TimeScaleType.Battle);
                        }
                        else
                        {
                            fxObj = target.effectPlayer.PlayFx(attackFxID, null, null, false, resType: BattleResType.HurtFX, creator: caster, timeScaleType: FxPlayer.TimeScaleType.Battle);
                            if (hurtFxID != null)
                                target.effectPlayer.PlayFx((int)hurtFxID, null, null, false, resType: BattleResType.HurtFX, creator: caster, timeScaleType: FxPlayer.TimeScaleType.Battle);
                        }
                    }

                    if (fxObj != null && damageBoxCfg.FxFreezeFrame)
                    {
                        fxObj.SetFreezeFrame(TbUtil.battleConsts.DuringDamageBoxTimeScale, damageBoxCfg.HurtScaleDuration, damageBoxCfg.FreezeFrameDelay);
                    }
                }
            }

            /// <summary>
            /// 处理添加Buff效果
            /// </summary>
            private static void _ExeAddBuffAffect(DamageExporter damageExporter, Actor target, AddBuffData addBuffData)
            {
                if (target == null)
                    return;
                if (addBuffData == null)
                    return;
                
                int buffId = addBuffData.ID;
                AffectTargetType affectTargetType = addBuffData.AffectTargetType;
                Actor actorTarget = null;
                if (affectTargetType == AffectTargetType.Behurt)
                {
                    actorTarget = target;
                }
                else
                {
                    actorTarget = damageExporter.GetCaster().GetTarget((TargetType) affectTargetType);
                }

                if (actorTarget == null)
                {
                    return;
                }

                int? layer = addBuffData.BuffLayer > 0 ? (int?) addBuffData.BuffLayer : null;
                float? time = addBuffData.BuffTime > 0 ? (float?) addBuffData.BuffTime : null;
                int level = addBuffData.BuffLevel > 0 ? addBuffData.BuffLevel : 1;

                actorTarget.buffOwner.Add(buffId, layer, time, level, damageExporter.GetCaster(), damageExporter);
            }

            /// <summary>
            /// 获取协作者, 仅在伤害流程中调用, 不能public.
            /// </summary>
            private static Actor _GetAssistor(Actor refActor)
            {
                if (refActor == null)
                {
                    return null;
                }
                
                if (refActor.IsBoy())
                {
                    return Battle.Instance.actorMgr.girl;
                }

                if (refActor.IsGirl())
                {
                    return Battle.Instance.actorMgr.boy;
                }

                return null;
            }
        }
    }
}