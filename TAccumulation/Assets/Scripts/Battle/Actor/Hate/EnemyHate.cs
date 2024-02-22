using System;
using PapeGames.X3;

namespace X3Battle
{
    public class EnemyHate : ActorHate
    {
        /// <summary>
        /// 缓冲阈值
        /// </summary>
        private float[] _threshold;
        
        // 衰减周期：如果在一段时间内未对自己进行仇恨相关的操作，则需要以一定速度衰减仇恨值。
        // 操作：①仇恨值变动 ②嘲讽
        private float _attenuateCheckPeriod;

        // 衰减速度：每秒减低x点仇恨，仇恨值不能小于0，且需要保证不能脱离仇恨列表
        private float _attenuateSpeed;
        
        private Action<EventDamageExporterMeter> _actionOnDamageExporterMeter;
        private Action<EventTauntActor> _actionOnTauntTargetChange;

        public EnemyHate()
        {
            _actionOnDamageExporterMeter = _OnDamageExporterMeter;
            _actionOnTauntTargetChange = _OnTauntTargetChange;
        }
        
        protected override void OnAwake()
        {
            base.OnAwake();

            _attenuateCheckPeriod = TbUtil.battleConsts.HateCheckPeriod;
            _attenuateSpeed = TbUtil.battleConsts.HateDeclineSpd;
            
            _isPlayerFriend = false;
            _hateSqrRadius = TbUtil.battleConsts.MonsterHateRange * TbUtil.battleConsts.MonsterHateRange;
            float[] upDistance;
            if (actor.monsterCfg.UpDistance.Length == 0)
            {
                upDistance = TbUtil.battleConsts.MonsterUpDistance;
                _threshold = TbUtil.battleConsts.HateThreshold;
            }
            else
            {
                upDistance = actor.monsterCfg.UpDistance;
                _threshold = actor.monsterCfg.HateThreshold;
            }
            _upSqrDistance = new float[upDistance.Length];
            for (int i = 0; i < upDistance.Length; i++)
            {
                _upSqrDistance[i] = upDistance[i] * upDistance[i];
            }
            _updateHateCd = actor.monsterCfg.ChangeTargetCD > 0.1f ? actor.monsterCfg.ChangeTargetCD : TbUtil.battleConsts.ChangeTargetCD;
        }

        public override void OnBorn()
        {
            base.OnBorn();
            UpdateHates();
            if (_hate != null)
            {
                _curUpdateHateTime = _updateHateCd;
            }
            else
            {
                SelectHate();
            }
            battle.eventMgr.AddListener(EventType.OnDamageMeter, _actionOnDamageExporterMeter, "EnemyHate._OnDamageExporterMeter");
            battle.eventMgr.AddListener(EventType.TauntActorChange, _actionOnTauntTargetChange, "EnemyHate._OnTauntTargetChange");
        }
        
        public override void OnRecycle()
        {
            battle.eventMgr.RemoveListener(EventType.OnDamageMeter, _actionOnDamageExporterMeter);
            battle.eventMgr.RemoveListener(EventType.TauntActorChange, _actionOnTauntTargetChange);
            base.OnRecycle();
        }

        protected override void OnUpdate()
        {
            // 处理衰减逻辑
            for (int i = 0; i < _hates.Count; i++)
            {
                EnemyHateData hateData = _hates[i] as EnemyHateData;
                if (hateData.attenuateTime > 0)
                {
                    // 衰减时间倒计时中    
                    hateData.attenuateTime -= actor.deltaTime;
                    if (hateData.attenuateTime <= 0)
                    {
                        // 策划要求倒计时到了立即衰减一次
                        hateData.attenuatePeriod = 1f;
                        _TryAttenuateHateValue(hateData);
                    }
                }
                else
                {
                    // 衰减时间倒计时已到，处理衰减速度倒计时
                    hateData.attenuatePeriod -= actor.deltaTime;
                    if (hateData.attenuatePeriod <= 0)
                    {
                        hateData.attenuatePeriod = 1f;
                        _TryAttenuateHateValue(hateData);
                    }
                }
            }
            
            // 先进行衰减，再在基类中排序仇恨目标
            base.OnUpdate();    
        }

        private void _TryAttenuateHateValue(EnemyHateData hateData)
        {
            // 别的逻辑有可能已经置为负数，这里加个保护, 只有正值才真的衰减
            var value = hateData.value;
            if (value > 0)
            {
                value -= _attenuateSpeed;
                if (value < 0)
                {
                    value = 0;
                }
                hateData.value = value;
            }
        }
        
        // 嘲讽目标改变事件监听
        private void _OnTauntTargetChange(EventTauntActor arg)
        {
            if (arg.actor != actor || null == arg.tauntTarget) return;

            LogProxy.LogFormat("【目标】：仇恨组件收到嘲讽事件，{0} 被 {1} 嘲讽，尝试更新衰减数据。", actor.name, arg.tauntTarget.name);
            for (var i = 0; i < _hates.Count; i++)
            {
                if (_hates[i] is EnemyHateData hateData && hateData.insId == arg.tauntTarget.insID)
                {
                    hateData.ResetAttenuateData();
                    break;
                }
            }
        }
        
        /// <summary>
        /// 选择仇恨目标
        /// </summary>
        protected override void SelectHate()
        {
            HateDataBase cacheHate = _hate;
            if (!_hates.Contains(_hate) || !_hate.lockable)
            {
                _hate = null;
            }
            EnemyHateData wheelHate = null;
            _cacheHates.Clear();
            for (int i = 0; i < _hates.Count; i++)
            {
                EnemyHateData hate = _hates[i] as EnemyHateData;
                if (hate.lockable)
                {
                    if (wheelHate == null)
                    {
                        wheelHate = hate;
                    }
                    else
                    {
                        float hateThreshold = _GetHateThreshold(hate);
                        float wheelHateThreshold = _GetHateThreshold(wheelHate);
                        if(wheelHate.value * hateThreshold < hate.value * wheelHateThreshold)
                        {
                            wheelHate = hate;
                        }
                    }
                }
            }

            if (_hate == null)
            {
                _hate = wheelHate;
            }
            else if(wheelHate != null)
            {
                float wheelHateThreshold = _GetHateThreshold(wheelHate);
                if ((_hate as EnemyHateData).value * wheelHateThreshold < wheelHate.value)
                {
                    _hate = wheelHate;
                }
            }

            if (_hate != cacheHate)//仇恨目标变化，发送事件
            {
                var eventData = actor.eventMgr.GetEvent<EventHateActor>();
                eventData.Init(actor, hateTarget);
                PapeGames.X3.LogProxy.LogFormat("【目标】：{0}的仇恨目标变为{1}", actor.name, _hate == null ? "空" : hateTarget?.name);
                actor.eventMgr.Dispatch(EventType.HateActorChange, eventData);
                _curUpdateHateTime = _updateHateCd;
            }
            else
            {
                _curUpdateHateTime = _updateHateFailCd;
            }
        }

        protected override HateDataBase CreateHate(Actor actor)
        {
            EnemyHateData hateData = ObjectPoolUtility.EnemyHateData.Get();
            hateData.insId = actor.insID;
            hateData.lockable = !actor.stateTag?.IsActive(ActorStateTagType.LockIgnore) ?? true;
            hateData.value = TbUtil.battleConsts.EnterBattleHatred;
            
            if (actor.IsGirl())
            {
                WeaponLogicConfig weaponLogicConfig = BattleUtil.GetCurrentWeaponLogicConfig();
                hateData.ratio = weaponLogicConfig?.HateRatio ?? 10;
            }
            else if (actor.IsBoy())
            {
                hateData.ratio = actor.boyCfg?.HateRatio ?? 10;
            }
            else
            {
                hateData.ratio = TbUtil.battleConsts.OtherHateRatio;
            }
            //主控被添加到怪物仇恨列表里
            if (actor == battle.player)
            {
                (battle.player.actorHate as PlayerHate)?.PlayerIsHated();
            }
            return hateData;
        }
        
        /// <summary>
        /// 外部增加仇恨值
        /// </summary>
        /// <param name="insId"></param>
        /// <param name="value"></param>
        public void AddHateValue(int insId, float value)
        {
            for (int i = 0; i < _hates.Count; i++)
            {
                EnemyHateData curHate = _hates[i] as EnemyHateData;
                if (insId == curHate.insId)
                {
                    curHate.value += value;
                    SelectHate();
                    break;
                }
            }
        }

        /// <summary>
        /// 更新仇恨值
        /// </summary>
        private void _OnDamageExporterMeter(EventDamageExporterMeter meter)
        {
            if (!(meter.damageExporter is ISkill))
            {
                return;
            }
            ISkill skill = meter.damageExporter as ISkill;
            Actor caster = skill.GetCaster();
            if (caster.isDead)
            {
                return;
            }
            Actor target = meter.skillTarget;
            if (target != null && caster.GetFactionRelationShip(target) != FactionRelationship.Enemy)
            {
                return;
            }
            SkillLevelCfg levelConfig = skill.levelConfig;
            //仇恨主体对仇恨目标释放技能
            if (caster == actor)
            {
                if (target != null && _hates != null)
                {
                    for (int i = 0; i < _hates.Count; i++)
                    {
                        EnemyHateData hate = _hates[i] as EnemyHateData;
                        if (target.insID == hate.insId)
                        {
                            var oldValue = hate.value;
                            float reduceValue;
                            if (meter.isHitSkillTarget)
                            {
                                reduceValue = hate.value * levelConfig.HitReduceHatredPercent * 0.01f + levelConfig.HitReduceHatredNumber;
                            }
                            else
                            {
                                reduceValue = hate.value * levelConfig.MissReduceHatredPercent * 0.01f + levelConfig.MissReduceHatredNumber;
                            }
                            hate.value -= reduceValue;
                            if (hate.value < 0)
                            {
                                hate.value = 0;
                            }
                            if (oldValue != hate.value)
                            {
                                // 仇恨值变了，重置衰减数据
                                hate.ResetAttenuateData();
                            }
                            break;
                        }
                    }
                }
            }
            //仇恨目标对仇恨主体释放技能
            else if (target == actor)
            {
                EnemyHateData enemyHate = null;
                
                if (_hates != null)
                {
                    for (int i = 0; i < _hates.Count; i++)
                    {
                        EnemyHateData hate = _hates[i] as EnemyHateData;
                        if (caster.insID == hate.insId)
                        {
                            enemyHate = hate;
                            break;
                        }
                    }
                }

                if (enemyHate == null)
                {
                    enemyHate = AddHate(caster) as EnemyHateData;
                }
                float addValue = 0;
                foreach (DamageMeter damageMeter in meter.damageMeters)
                {
                    if (damageMeter.actor == actor)
                    {
                        //addValue = (damageMeter.realDamage + damageMeter.realCure * TbUtil.battleConsts.HealHaterCoefficient) * levelConfig.HatredCoefficient * enemyHate.ratio + levelConfig.ExtraHatred;
                        addValue = (levelConfig.HatredCoefficient + levelConfig.ExtraHatred) * enemyHate.ratio;
                        break;
                    }
                }

                var oldValue = enemyHate.value;
                enemyHate.value += addValue;
                if (oldValue != enemyHate.value)
                {
                    enemyHate.ResetAttenuateData();
                }
            }
        }
        
        private float _GetHateThreshold(HateDataBase hate)
        {
            Actor curActor = battle.actorMgr.GetActor(hate.insId);
            if (curActor == null)
            {
                return 1;
            }
            float sqrDistance = (position - curActor.transform.position).sqrMagnitude;
            float hateThreshold = 0;
            if (_upSqrDistance != null)
            {
                for (int i = 0; i < _upSqrDistance.Length; i++)
                {
                    if (sqrDistance <= _upSqrDistance[i])
                    {
                        hateThreshold = _threshold[i];
                        break;
                    }
                }
            }
            return hateThreshold;
        }
    }
}