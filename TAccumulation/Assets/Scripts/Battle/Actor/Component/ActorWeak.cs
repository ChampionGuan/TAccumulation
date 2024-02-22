using PapeGames.X3;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class ActorWeak : ActorComponent
    {
        public float recoverTime => _recoverTime;
        public float recoverTotalTime { get; private set; }
        public int EquipWeak
        {
            get
            {
                if (actor.monsterCfg != null)
                    return actor.monsterCfg.EquipShield;
                else
                    return 0;
            }
        }
        public bool locked { get; private set; } // 芯核是否被锁定 锁定情况下不会受到芯核伤害

        public float ShieldMax { get; private set; }
        public WeakType weakType { get; set; }

        public bool IsWeakOrLightWeak { 
            get 
            { 
                return ((actor.monsterCfg != null && actor.monsterCfg.EquipShield == (int)CoreType.Boss && actor.actorWeak.weak) || actor.actorWeak.lightWeak); 
            } 
        } // 是否处于大虚弱或小虚弱 }

        private bool _weak;
        private bool _lightWeak;
        private float _recoverTime;
        private string _shieldReduceAnimName = "HurtIntruder_Light";

        public int weakCount { get; private set; } // 已进入虚弱的次数

        // 临时
        private int _shieldBreakFxID = 123;
        private float _toughnessChange;
        private FxPlayer _fx1, _fx2, _fx3;

        public ActorWeak() : base(ActorComponentType.Weak)
        {
            _weak = false;
            _recoverTime = 0;
        }

        public bool weak => _weak;
        public bool lightWeak => _lightWeak;

        public override void OnBorn()
        {
            _weak = false;
            _lightWeak = false;
            if (NoShield())
                return;
            locked = false;
            recoverTotalTime = actor.monsterCfg.WeakRecoverTime;
            ShieldMax = actor.monsterCfg.ShieldMax;
            actor.attributeOwner.GetAttr(AttrType.WeakPoint)?.Set(actor.monsterCfg.ShieldInit);
            weakType = WeakType.None;
            weakCount = 0;
        }

        public override void OnDead()
        {
            if (NoShield())
                return;
            _weak = false;
            _lightWeak = false;
            battle.ppvMgr.Stop(TbUtil.battleConsts.WeakBreakPPV);
            actor.effectPlayer.StopFX(_fx1);
            actor.effectPlayer.StopFX(_fx2);
            actor.effectPlayer.StopFX(_fx3);
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            if (NoShield())
                return;

            if (!_weak)
                return;

            _recoverTime -= actor.deltaTime;

            if (_recoverTime <= 0)
            {
                StopWeak();
            }
        }

        private void _OnExitWeak()
        {
            actor.attributeOwner.GetAttr(AttrType.WeakHurtAdd).Sub(actor.monsterCfg.VulnerableValue * 1000f, 0);
            actor.attributeOwner.GetAttr(AttrType.WeakPoint).Set(ShieldMax); // 芯核直接回满
            actor.effectPlayer.StopFX(_fx1);
            actor.effectPlayer.StopFX(_fx2);
            actor.effectPlayer.StopFX(_fx3);

            _recoverTime = 0;
            _weak = false;
            _lightWeak = false;
            var eventData = battle.eventMgr.GetEvent<EventCoreChange>();
            eventData.Init(actor, false, null);
            battle.eventMgr.Dispatch(EventType.CoreChange, eventData);

            var eventWeakEnd = battle.eventMgr.GetEvent<EventWeakEnd>();
            eventWeakEnd.Init(actor);
            battle.eventMgr.Dispatch(EventType.WeakEnd, eventWeakEnd);
        }

        public void OnWeakHurt(DamageBoxCfg damageBoxCfg)
        {
            if (actor.monsterCfg != null && actor.monsterCfg.EquipShield == (int)CoreType.Boss)
            {
                // 设置魔女禁用
                actor.SetWitchDisabled(true);
                // 进入顿帧
                actor.SetTimeScale(TbUtil.battleConsts.DuringDamageBoxTimeScale, damageBoxCfg.HurtScaleDuration, (int)ActorTimeScaleType.Base);
                // 虚弱时被攻击
                actor.locomotion.TriggerFSMEvent("OnWeakHurt");
            }
        }

        /// <summary>
        /// 对芯核 上\解锁
        /// </summary>
        public void LockCore(bool isLock)
        {
            locked = isLock;
        }

        public void ShieldBreak(HitInfo hitInfo = null)
        {
            using (ProfilerDefine.ActorWeakShieldBreakPMarker.Auto())
            {
                if (NoShield())
                {
                    return;
                }

                if (_weak)
                {
                    return;
                }

                if (actor.monsterCfg != null && actor.monsterCfg.EquipShield == (int)CoreType.Elite)
                {
                    _toughnessChange = actor.hurt.hurtProtectValue - actor.hurt.toughness;
                    actor.hurt.AddToughness(_toughnessChange);
                    // 进入虚弱清空受击保护数据
                    actor.hurt.RefreshHurtProtected();
                }
                else
                {
                    TryEnterWeak(WeakType.Heavy);

                    // 发送信号
                    var signal = TbUtil.battleConsts.BattleShieldBreakSignal;
                    var actors = ObjectPoolUtility.CommonActorList.Get();
                    battle.actorMgr.GetActors(ActorType.Hero, outResults: actors);
                    foreach (var ac in actors)
                    {
                        ac.signalOwner.Write(signal[0], signal[1], actor);
                    }

                    ObjectPoolUtility.CommonActorList.Release(actors);
                }

                actor.attributeOwner.GetAttr(AttrType.WeakHurtAdd).Add(actor.monsterCfg.VulnerableValue * 1000f, 0);
                actor.battle.SetTimeScale(actor.monsterCfg.WeakTimeScale, actor.monsterCfg.WeakTimeScaleDuration, (int)LevelTimeScaleType.Bullet);

                using (ProfilerDefine.ActorWeakPlayFxPMarker.Auto())
                {
                    _fx1 = actor.effectPlayer.PlayFx(TbUtil.battleConsts.BreakFx01, timeScaleType: FxPlayer.TimeScaleType.Battle);
                    _fx2 = actor.effectPlayer.PlayFx(TbUtil.battleConsts.BreakFx02, timeScaleType: FxPlayer.TimeScaleType.Battle);
                    _fx3 = actor.effectPlayer.PlayFx(_shieldBreakFxID, timeScaleType: FxPlayer.TimeScaleType.Battle);
                }

                //虚弱时间计算
                var recoverAttr = actor.attributeOwner.GetAttrValue(AttrType.ShieldRecoverTime);
                var weakPeriodRate = 0f;
                var weakPeriodAdd = 0f;
                if (hitInfo != null)
                {
                    var caster = hitInfo.damageExporter.GetCaster();
                    if (caster != null)
                    {
                        weakPeriodRate = caster.attributeOwner.GetAttrValue(AttrType.WeakPeriodRate);
                        weakPeriodAdd = caster.attributeOwner.GetAttrValue(AttrType.WeakPeriodAdd);
                    }
                }
                recoverTotalTime = _recoverTime = recoverAttr * (1 + weakPeriodRate / 1000f) + weakPeriodAdd;
                _weak = true;

                battle.ppvMgr.Play(TbUtil.battleConsts.WeakBreakPPV);
                weakCount += 1;

                using (ProfilerDefine.ActorWeakDispatchPMarker.Auto())
                {
                    var eventData = battle.eventMgr.GetEvent<EventWeakFull>();
                    eventData.Init(actor, hitInfo);
                    battle.eventMgr.Dispatch(EventType.WeakFull, eventData); // 进入破盾
                }
            }
        }

        /// <summary>
        /// 判断是否可以受到芯核护盾伤害 条件：不在虚弱状态，且护盾当前值以及最大值>0，boss最大值为0也可以
        /// </summary>
        /// <returns></returns>
        public bool CanReduceShield()
        {
            return !_weak && (HasShield() || BossShield());
        }

        public bool NoShield()
        {
            return actor.monsterCfg == null || actor.monsterCfg.EquipShield == (int)CoreType.None;
        }

        public bool HasShield()
        {
            return !NoShield() && (actor.attributeOwner.GetAttrValue(AttrType.WeakPoint) > 0 && ShieldMax > 0);
        }

        public bool BossShield()
        {
            return !NoShield() && (actor.monsterCfg.EquipShield == (int)CoreType.Boss &&
                ShieldMax == 0 && actor.attributeOwner.GetAttrValue(AttrType.WeakPoint) == 0);
        }

        /// <summary>
        /// 强制进入虚弱
        /// </summary>
        public void ForceEnterWeak()
        {
            if (!_weak)
            {
                // 虚弱条涨满， 进入虚弱
                actor.attributeOwner.SetAttrValue(AttrType.WeakPoint, actor.monsterCfg.ShieldMax);
                ShieldBreak();
            }
        }

        /// <summary>
        /// 强退虚弱， 不会播虚弱退出动画
        /// </summary>
        public void ForceExitWeak()
        {
            if(actor.mainState.HasAbnormalType(ActorAbnormalType.Weak))
                actor.mainState.TryEndAbnormal(ActorAbnormalType.Weak, this);
        }

        /// <summary>
        /// 退出虚弱，如果当前在大虚弱，则会播虚弱退出动画。
        /// </summary>
        public void StopWeak()
        {
            if (_weak)
            {
                if (actor.monsterCfg != null && actor.monsterCfg.EquipShield == (int)CoreType.Elite)
                {
                    actor.hurt.AddToughness(-_toughnessChange);
                }
                else
                {
                    actor.locomotion.TriggerFSMEvent("WeakEnd");
                }

                _OnExitWeak();
            }
        }

        /// <summary>
        /// 修改芯核最大值
        /// </summary>
        /// <param name="value"></param> 修改的值
        /// <param name="type"></param> 增加或减少
        public void ModifyShieldMax(float value, ModifyShieldType type = ModifyShieldType.Add)
        {
            if (value < 0)
                return;

            if (type == ModifyShieldType.Add)
                ShieldMax += value;
            else
            {
                ShieldMax -= value;
                if (ShieldMax < 0)
                    ShieldMax = 0;

                if (ShieldMax < actor.attributeOwner.GetAttrValue(AttrType.WeakPoint))
                {
                    actor.attributeOwner.SetAttrValue(AttrType.WeakPoint, ShieldMax); // 如果在这种情况下护盾值设为了0，不会触发破盾虚弱
                }
            }

            var eventData = battle.eventMgr.GetEvent<EventCoreMaxChange>();
            eventData.Init(actor);
            battle.eventMgr.Dispatch(EventType.CoreMaxChange, eventData);
        }

        public void ModifyShield(float value, ModifyShieldType type = ModifyShieldType.Add)
        {
            if (value < 0)
                return;

            if (type == ModifyShieldType.Sub)
            {
                SubShield(value);
            }
            else
            {
                AddShield(value);
            }
        }

        public void AddShield(float value)
        {
            var spAttr = actor.attributeOwner.GetAttr(AttrType.WeakPoint);

            if (spAttr.GetValue() + value > ShieldMax)
                value = ShieldMax - spAttr.GetValue();

            spAttr.Add(value, 0);
            var eventData = battle.eventMgr.GetEvent<EventCoreChange>();
            eventData.Init(actor, false, null);
            battle.eventMgr.Dispatch(EventType.CoreChange, eventData);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <param name="hitInfo"></param>
        /// <returns></returns> 返回是否忽略韧性值判断
        public bool SubShield(float value, HitInfo hitInfo = null)
        {
            bool ignoreToughness = false;
            bool forceEnter = false;
            var spAttr = actor.attributeOwner.GetAttr(AttrType.WeakPoint);
            if (hitInfo != null)
            {
                var damegeExporter = hitInfo.damageExporter;
                if (actor.monsterCfg != null && actor.monsterCfg.EquipShield == (int)CoreType.Boss &&
                    damegeExporter is SkillActive skill && (null == actor.stateTag || !actor.stateTag.IsActive(ActorStateTagType.HurtIgnore)))
                {
                    for (int i = 0; i < TbUtil.battleConsts.WeakSkillType.Length; i++)
                    {
                        if (skill.CompareSkillType((SkillType)TbUtil.battleConsts.WeakSkillType[i]))
                        {
                            forceEnter = true;
                        }
                    }

                    for (int i = 0; i < TbUtil.battleConsts.WeakSkillTag.Length; i++)
                    {
                        if (skill.HasSkillTag(TbUtil.battleConsts.WeakSkillTag[i]))
                        {
                            forceEnter = true;
                        }
                    }
                }
            }

            if (value == 0 && !forceEnter) // 特定技能造成的伤害即使没有芯核伤害 也会进小虚弱
                return ignoreToughness;

            if (value > spAttr.GetValue())
                value = spAttr.GetValue();

            spAttr.Sub(value, 0);
            if (value != 0)
            {
                var eventData = battle.eventMgr.GetEvent<EventCoreChange>();
                eventData.Init(actor, true, hitInfo);
                battle.eventMgr.Dispatch(EventType.CoreChange, eventData);
            }

            if (BossShield())//boss无护盾 进入小虚弱
            {
                if(forceEnter)
                    BossWeakLight(hitInfo);
                return ignoreToughness;
            }
            else if (spAttr.GetValue() == 0)
            {
                ShieldBreak(hitInfo);
                return ignoreToughness;
            }
            else
            {
                if (actor.monsterCfg == null)
                    return ignoreToughness; ;

                if (actor.monsterCfg.EquipShield == (int)CoreType.Boss)
                {
                    BossWeakLight(hitInfo);
                }
                else if (actor.monsterCfg.EquipShield == (int)CoreType.Elite)
                {
                    ignoreToughness = true;
                    // 精英怪 会在后续受击无视韧性值判定

                }
                return ignoreToughness;
            }
        }

        public void BossWeakLight(HitInfo hitInfo = null)
        {
            // Boss怪进入小虚弱
            using (ProfilerDefine.ActorWeakShieldReducePMarker.Auto())
            {
                if (actor.animator.GetAnimatorStateClip(_shieldReduceAnimName) != null)
                {
                    // 芯核值减少
                    TryEnterWeak(WeakType.Light);
                    _lightWeak = true;
                    actor.SetTimeScale(TbUtil.battleConsts.DuringDamageBoxTimeScale, hitInfo?.damageBoxCfg.HurtScaleDuration);
                }
                else
                {
                    actor.skillOwner.TryEndSkill(SkillEndType.Interrupt);
                }
            }
        }

        /// <summary>
        /// 刷新虚弱时间, 不在虚弱状态则无法刷新
        /// </summary>
        /// <param name="time"></param> 若time <= 0, 则设为进入本次虚弱时的时长,如果如果当前值小于刷新值,则设为刷新值 否则不处理.
        public void RefreshWeakTime(float time)
        {
            if (!weak)
                return;

            if (time <= 0)
                _recoverTime = recoverTotalTime;
            else if(time > _recoverTime)
                _recoverTime = time;
        }

        /// <summary>
        /// 获取当前星核数量
        /// </summary>
        /// <returns></returns>
        public float GetWeakNum()
        {
            return actor.attributeOwner.GetAttrValue(AttrType.WeakPoint);
        }

        /// <summary>
        /// 是否有芯核
        /// </summary>
        /// <returns></returns>
        public bool IsHaveCore()
        {
            if (ShieldMax <= 0)
            {
                return false;
            }

            return true;
        }

        public void TryEnterWeak(WeakType weakType)
        {
            if (this.weakType != WeakType.None)
                actor.mainState?.TryEndAbnormal(ActorAbnormalType.Weak, this);

            this.weakType = weakType;
            if (weakType == WeakType.Light)
                actor.battle.wwiseBattleManager.PlaySound(actor.monsterCfg.CoreBreakSound, actor.GetDummy(ActorDummyType.Model).gameObject, actorInsId: actor.insID);

            actor.mainState?.TryEnterAbnormal(ActorAbnormalType.Weak, this);
        }
    }
}
