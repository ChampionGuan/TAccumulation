using System;
using System.Collections.Generic;
using ParadoxNotion.Design;
using UnityEngine;
using PapeGames.X3;

namespace X3Battle
{
    /// <summary>
    /// 战斗单位
    /// 通过组件组装的方式创建出完整体
    /// </summary>
    public class Actor : ECComponent, IDeltaTime, IUnscaledDeltaTime
    {
        [ExposeField] protected int _insID;
        [ExposeField] protected int _spawnID;
        [ExposeField] protected int _groupID;
        [ExposeField] protected string _createName;

        protected ActorTransform _transform;
        protected ActorModel _model;
        protected ActorObstacle _obstacle;
        protected ActorTimeScaler _timeScaler;
        protected AttributeOwner _attributeOwner;
        protected SkillOwner _skillOwner;
        protected AIOwner _aiOwner;
        protected ActorHate _actorHate;
        protected ActorTaunt _actorTaunt;
        protected ActorEffectPlayer _effectPlayer;
        protected ActorCommander _commander;
        protected LocomotionCtrl _locomotion;
        protected ActorMainState _mainState;
        protected ActorIdle _idle;
        protected LookAt _lookAtOwner;
        protected ActorWeapon _weapon;
        protected TargetSelector _targetSelector;
        protected ActorStateTag _stateTag;
        protected BuffOwner _buffOwner;
        protected ColliderBehavior _collider;
        protected ActorSequencePlayer _sequencePlayer;
        protected ActorHurt _hurt;
        protected ActorWeak _actorWeak;
        protected EnergyOwner _energyOwner;
        protected SignalOwner _signalOwner;
        protected ActorEventMgr _eventMgr;
        protected BattleTimer _timer;
        protected HaloOwner _haloOwner;
        protected TriggerArea _triggerArea;
        protected ActorShadowPlayer _shadowPlayer;
        protected ActorInput _input;
        protected ActorDamageMeters _damageMeters;
        protected HPOwner _hpOwner;
        protected LocomotionView _locomotionView;
        protected ActorFrozen _frozen;
        protected InterActorOwner _interActorOwner;
        protected ActorShield _shield;

        protected float _lifetime = -1;
        protected bool _isUpdateLifetime;
        protected bool _isAutoRecycleOnDead;
        protected HashSet<object> _refObjs = new HashSet<object>();
        protected RewritingString _rewriteName = new RewritingString(23);

#if UNITY_EDITOR
        protected ActorMono _monoBehaviour;
#endif

        public float lifetime => _lifetime;
        public int insID => _insID;
        public int cfgID => config.ID;
        public int suitID => suitCfg?.SuitID ?? 0;
        public int spawnID => _spawnID;
        public int groupId => _groupID;
        public new string name { get; private set; }
        public int level { get; private set; }
        public int status { get; private set; }
        public bool isDead => _InStatus(ActorStatus.Dying) || _InStatus(ActorStatus.Dead);
        public bool isRecycled => _InStatus(ActorStatus.Recycling) || _InStatus(ActorStatus.Recycled);
        public FactionType factionType { get; private set; }
        public new ActorType type => config.Type;
        public int subType => config.SubType;
        public ModelInfo modelInfo { get; private set; }
        public float radius => modelInfo.characterCtrl?.Radius ?? 0;
        public float height => modelInfo.characterCtrl?.Height ?? 0;
        public Battle battle { get; private set; }
        public Actor master { get; private set; }
        public Actor moveTarget { get; set; }
        public float unscaledDeltaTime => battle.deltaTime;
        public float deltaTime => timeScaler.deltaTime;
        public float time => timeScaler.time;
        public float timeScale => timeScaler.scale;
        public int refCount => _refObjs.Count;

        public ActorCfg config { get; }
        public ActorSuitCfg suitCfg { get; }
        public ActorCreateCfg createCfg { get; }
        public ActorBornCfg bornCfg { get; private set; }
        public RoleCfg roleCfg => config as RoleCfg;
        public BoyCfg boyCfg => config as BoyCfg;
        public MonsterCfg monsterCfg => config as MonsterCfg;
        public RoleBornCfg roleBornCfg => bornCfg as RoleBornCfg;
        public ItemBornCfg itemBornCfg => bornCfg as ItemBornCfg;
        
        public LocomotionCtrl locomotion => _locomotion;
        public BattleAnimator animator => model?.animator;
        protected ActorTimeScaler timeScaler => _timeScaler ?? (_timeScaler = GetComponent<ActorTimeScaler>());
        public ActorTransform transform => _transform ?? (_transform = GetComponent<ActorTransform>((int)ActorComponentType.Transform));
        public ActorModel model => _model ?? (_model = GetComponent<ActorModel>((int)ActorComponentType.Model));
        public ActorObstacle obstacle => _obstacle ?? (_obstacle = GetComponent<ActorObstacle>((int)ActorComponentType.Obstacle));
        public SkillOwner skillOwner => _skillOwner ?? (_skillOwner = GetComponent<SkillOwner>((int)ActorComponentType.Skill));
        public AIOwner aiOwner => _aiOwner ?? (_aiOwner = GetComponent<AIOwner>((int)ActorComponentType.AI));
        public ActorHate actorHate => _actorHate ?? (_actorHate = GetComponent<ActorHate>((int)ActorComponentType.Hate));
        public ActorTaunt actorTaunt => _actorTaunt ?? (_actorTaunt = GetComponent<ActorTaunt>((int)ActorComponentType.Taunt));
        public ActorEffectPlayer effectPlayer => _effectPlayer ?? (_effectPlayer = GetComponent<ActorEffectPlayer>((int)ActorComponentType.EffectPlayer));
        public ActorIdle idle => _idle ?? (_idle = GetComponent<ActorIdle>((int)ActorComponentType.Idle));
        public LookAt lookAtOwner => _lookAtOwner ?? (_lookAtOwner = GetComponent<LookAt>((int)ActorComponentType.LookAt));
        public ActorWeapon weapon => _weapon ?? (_weapon = GetComponent<ActorWeapon>((int)ActorComponentType.Weapon));
        public AttributeOwner attributeOwner => _attributeOwner ?? (_attributeOwner = GetComponent<AttributeOwner>((int)ActorComponentType.Attribute));
        public ActorCommander commander => _commander ?? (_commander = GetComponent<ActorCommander>((int)ActorComponentType.Commander));
        public ActorMainState mainState => _mainState ?? (_mainState = GetComponent<ActorMainState>((int)ActorComponentType.MainState));
        public ColliderBehavior collider => _collider ?? (_collider = GetComponent<ColliderBehavior>((int)ActorComponentType.Collider));
        public TargetSelector targetSelector => _targetSelector ?? (_targetSelector = GetComponent<TargetSelector>((int)ActorComponentType.TargetSelector));
        public ActorStateTag stateTag => _stateTag ?? (_stateTag = GetComponent<ActorStateTag>((int)ActorComponentType.StateTag));
        public BuffOwner buffOwner => _buffOwner ?? (_buffOwner = GetComponent<BuffOwner>((int)ActorComponentType.Buff));
        public ActorSequencePlayer sequencePlayer => _sequencePlayer ?? (_sequencePlayer = GetComponent<ActorSequencePlayer>((int)ActorComponentType.SequencePlayer));
        public ActorHurt hurt => _hurt ?? (_hurt = GetComponent<ActorHurt>((int)ActorComponentType.Hurt));
        public ActorWeak actorWeak => _actorWeak ?? (_actorWeak = GetComponent<ActorWeak>((int)ActorComponentType.Weak));
        public EnergyOwner energyOwner => _energyOwner ?? (_energyOwner = GetComponent<EnergyOwner>((int)ActorComponentType.Energy));
        public SignalOwner signalOwner => _signalOwner ?? (_signalOwner = GetComponent<SignalOwner>((int)ActorComponentType.Signal));
        public ActorEventMgr eventMgr => _eventMgr ?? (_eventMgr = GetComponent<ActorEventMgr>((int)ActorComponentType.EventMgr));
        public BattleTimer timer => _timer ?? (_timer = GetComponent<BattleTimer>());
        public HaloOwner haloOwner => _haloOwner ?? (_haloOwner = GetComponent<HaloOwner>((int)ActorComponentType.Halo));
        public TriggerArea triggerArea => _triggerArea ?? (_triggerArea = GetComponent<TriggerArea>((int)ActorComponentType.TriggerArea));
        public ActorShadowPlayer shadowPlayer => _shadowPlayer ?? (_shadowPlayer = GetComponent<ActorShadowPlayer>((int)ActorComponentType.ShadowPlayer));
        public ActorInput input => _input ?? (_input = GetComponent<ActorInput>((int)ActorComponentType.ActorInput));
        public ActorDamageMeters damageMeters => _damageMeters ?? (_damageMeters = GetComponent<ActorDamageMeters>((int)ActorComponentType.DamageMeters));
        public HPOwner hpOwner => _hpOwner ?? (_hpOwner = GetComponent<HPOwner>((int)ActorComponentType.HP));
        public LocomotionView locomotionView => _locomotionView ?? (_locomotionView = GetComponent<LocomotionView>((int)ActorComponentType.LocomotionView));
        public ActorFrozen frozen => _frozen ?? (_frozen = GetComponent<ActorFrozen>((int)ActorComponentType.Frozen));
        public InterActorOwner interActorOwner => _interActorOwner ?? (_interActorOwner = GetComponent<InterActorOwner>((int)ActorComponentType.InteractorOwner));
        public ActorShield shield => _shield ?? (_shield = GetComponent<ActorShield>((int)ActorComponentType.Shield));

        public Actor(Battle battle, ActorCfg config, ActorSuitCfg suitCfg, ActorCreateCfg createCfg) : base((int)ActorComponentType.Actor)
        {
            _createName = name = BattleUtil.StrConcat("Actor_", null != suitCfg ? suitCfg.Name : config.Name, "-", config.ID.ToString());
            this.battle = battle;
            this.config = config;
            this.suitCfg = suitCfg;
            this.createCfg = createCfg;
            requiredLateUpdate = true;
        }

        protected override void OnAwake()
        {
            var key = createCfg.ModelCfg.ModelKey;
            if (string.IsNullOrEmpty(key) || key == BattleConst.EmptyActorModelKey)
            {
                modelInfo = new ModelInfo();
            }
            else
            {
                modelInfo = TbUtil.GetCfg<ModelInfo>(key) ?? new ModelInfo();
            }
        }

        protected override void OnStart()
        {
            if (_locomotion != null)
            {
                var agent = BattleUtil.AStarIsActive ? BattleUtil.AStarIsGrid ? (IRMAgent)this.EnsureComponent<RMGridAgent>() : this.EnsureComponent<RMNavMeshAgent>() : null;
                locomotion.OnStart(new LocomotionCtrlContext(this), agent, roleCfg, mainState);
            }

#if UNITY_EDITOR
            _monoBehaviour = this.EnsureComponent<ActorMono>();
            _monoBehaviour.TryInit(this);
#endif
        }

        protected override void OnDestroy()
        {
            _refObjs.Clear();
#if UNITY_EDITOR
            _monoBehaviour.TryUninit();
#endif
            locomotion?.Discard();
            master?.RemoveRef(this);
            battle = null;
        }

        public void Born(ActorBornCfg bornCfg)
        {
            if (status != 0 && !isRecycled)
            {
                LogProxy.LogError($"[Actor出生]角色(id={config.ID}):角色出生失败，此单位正在使用中，不可重复使用！！");
                return;
            }

            using (ProfilerDefine.ActorBornPMarker.Auto())
            {
                status = (int)ActorStatus.InBirth;
                _isAutoRecycleOnDead = false;
                _isUpdateLifetime = true;
                _insID = bornCfg.InsID;
                _groupID = bornCfg.GroupID;
                _spawnID = bornCfg.SpawnID;
                _lifetime = bornCfg.LifeTime;
                master = bornCfg.Master;
                factionType = bornCfg.FactionType;
                level = bornCfg.Level;
                entity.enabled = true;
                this.bornCfg = bornCfg;
                // note:特殊约定逻辑！非Role单位，给创建者增加引用，为了解决创建者死亡后，此单位仍需获取Master信息，延时让Master回池复用。
                if (!this.IsRole()) master?.AddRef(this);
                // name
                if (_spawnID != cfgID) name = _rewriteName.ReConcat(_createName, "", "-", _spawnID >= BattleConst.MinActorSpawnID ? _spawnID : _insID);

                if (!battle.isPreloading && !battle.isEnd && (type == ActorType.Hero || type == ActorType.Monster || type == ActorType.TriggerArea))
                {
                    CriticalLog.LogFormat("[战斗][角色][Actor.Born()] name:{0}", name);
                }

                locomotion?.Born(roleCfg, this);
                for (var i = 0; i < comps.Length; i++)
                {
                    try
                    {
                        if (!(comps[i] is IActorComponent comp))
                        {
                            continue;
                        }

                        using (comp.namePMarker.Auto())
                        {
                            comp.OnBorn();
                        }
                    }

                    catch (Exception e)
                    {
                        LogProxy.LogFatal(e);
                    }
                }

                var eventData = battle.eventMgr.GetEvent<EventActor>();
                eventData.Init(this, ActorLifeStateType.Born);
                battle.eventMgr.Dispatch(EventType.Actor, eventData);
                var eventData2 = battle.eventMgr.GetEvent<EventActorBase>();
                eventData2.Init(this);
                battle.eventMgr.Dispatch(EventType.ActorBorn, eventData2);

                if (_lifetime == 0)
                {
                    LogProxy.LogWarning($"[Actor构造]角色(id={config.ID}):生命时长等于0，一帧内就会被销毁，请确认？");
                }

                status = (int)ActorStatus.Born;
                mainState?.TryToState(ActorMainStateType.Born);
            }
        }

        public void Dead()
        {
            if (isDead)
            {
                LogProxy.LogFormat("Actor.Dead(): actor(id={0}, name={1}) already dead", config.ID, config.Name);
                return;
            }

            if (!_InStatus(ActorStatus.Born))
            {
                _lifetime = 0;
                _isUpdateLifetime = true;
                return;
            }

            using (ProfilerDefine.ActorDeadPMarker.Auto())
            {
                if (!battle.isPreloading && !battle.isEnd && (type == ActorType.Hero || type == ActorType.Monster || type == ActorType.TriggerArea))
                {
                    CriticalLog.LogFormat("[战斗][角色][Actor.Dead()] name:{0}", name);
                }

                var eventPreDead = battle.eventMgr.GetEvent<EventActorBase>();
                eventPreDead.Init(this);
                battle.eventMgr.Dispatch(EventType.ActorPreDead, eventPreDead);

                status |= (int)ActorStatus.Dying;
                skillOwner?.TryEndSkill();
                aiOwner?.ClearCombatAIGoal();
                aiOwner?.DisableAI(true, AISwitchType.Revive);
                commander?.ClearCmd();
                buffOwner?.RemoveAllDebuff();
                stateTag?.ReleaseAllTag();
                for (var i = 0; i < comps.Length; i++)
                {
                    try
                    {
                        if (!(comps[i] is IActorComponent comp))
                        {
                            continue;
                        }

                        using (comp.namePMarker.Auto())
                        {
                            comp.OnDead();
                        }
                    }
                    catch (Exception e)
                    {
                        LogProxy.LogFatal(e);
                    }
                }

                var eventData = battle.eventMgr.GetEvent<EventActor>();
                eventData.Init(this, ActorLifeStateType.Dead);
                battle.eventMgr.Dispatch(EventType.Actor, eventData);
                var eventData2 = battle.eventMgr.GetEvent<EventActorBase>();
                eventData2.Init(this);
                battle.eventMgr.Dispatch(EventType.ActorDead, eventData2);

                status |= (int)ActorStatus.Dead;
                mainState?.TryToState(ActorMainStateType.Dead);
                if (_isAutoRecycleOnDead || null == _mainState)
                {
                    battle.actorMgr.RecycleActor(this);
                }
            }
        }

        public void Recycle()
        {
            if (isRecycled || entity.isDestroyed)
            {
                return;
            }

            if (!_InStatus(ActorStatus.Dead))
            {
                _isAutoRecycleOnDead = true;
                if (!_InStatus(ActorStatus.Dying)) Dead();
                return;
            }

            using (ProfilerDefine.ActorRecyclePMarker.Auto())
            {
                status |= (int)ActorStatus.Recycling;
                entity.enabled = false;
                for (var i = 0; i < comps.Length; i++)
                {
                    try
                    {
                        if (!(comps[i] is IActorComponent comp))
                        {
                            continue;
                        }

                        using (comp.namePMarker.Auto())
                        {
                            comp.OnRecycle();
                        }
                    }
                    catch (Exception e)
                    {
                        LogProxy.LogFatal(e);
                    }
                }

                locomotion?.OnDestroy();
                master?.RemoveRef(this);

                var eventData = battle.eventMgr.GetEvent<EventActor>();
                eventData.Init(this, ActorLifeStateType.Recycle);
                battle.eventMgr.Dispatch(EventType.Actor, eventData);
                var eventData2 = battle.eventMgr.GetEvent<EventActorBase>();
                eventData2.Init(this);
                battle.eventMgr.Dispatch(EventType.ActorRecycle, eventData2);

                status |= (int)ActorStatus.Recycled;
            }
        }

        public void ForceIdle()
        {
            if (isDead)
            {
                return;
            }

            hurt?.StopHurt();
            actorWeak.ForceExitWeak();
            locomotion.ResetInterrupt();
            //移除所有属于控制的buff
            buffOwner?.RemoveAllMatchBuff(BuffType.Control, BuffTag.Buff, 0, 0, false, true, true);
            skillOwner?.TryEndSkill();
            skillOwner?.ClearSkillRemainFX();
            aiOwner?.ClearCombatAIGoal();
            input?.ClearCache();
            commander?.ClearCmd();
            mainState?.TryToState(ActorMainStateType.Idle);
        }

        protected override void OnUpdate()
        {
            locomotion?.Update(deltaTime);
            _UpdateLifetime();
        }

        protected override void OnLateUpdate()
        {
            locomotion?.LateUpdate();
        }

        /// <summary>
        /// 为Actor添加LocomotionCtrl组件
        /// 目前只有Role单位会持有此组件
        /// </summary>
        public void AddLocomotionCtrl()
        {
            if (null == _locomotion)
            {
                _locomotion = new LocomotionCtrl();
            }
        }
        
        /// <summary>
        /// 将对象加入到引用列表
        /// </summary>
        /// <param name="obj"></param>
        public void AddRef(object obj)
        {
            if (null == obj)
            {
                return;
            }

            if (!_refObjs.Add(obj))
            {
                LogProxy.LogError($"[Actor.AddRef()]添加引用异常，已存在相同对象，请检查！ name:{name}");
            }
        }

        /// <summary>
        /// 从引用列表中移除对象
        /// </summary>
        /// <param name="obj"></param>
        public void RemoveRef(object obj)
        {
            if (null == obj)
            {
                return;
            }

            _refObjs.Remove(obj);
        }

        /// <summary>
        /// 将召唤者置空
        /// </summary>
        public void SetMasterNull()
        {
            master = null;
        }

        public bool HasDirInput()
        {
            return _locomotion.HasDestDir;
        }

        /// <summary>
        /// 返回摇杆方向 如果没有摇杆方向 返回角色方向
        /// </summary>
        public Vector3 GetDestDir()
        {
            return _locomotion.HasDestDir ? _locomotion.destDir : transform.forward;
        }

        /// <summary>
        /// 设置方向
        /// </summary>
        /// <param name="v"></param>
        /// <returns></returns>
        public Vector3 SetDestDir(Vector3 v)
        {
            return _locomotion.destDir = v;
        }

        /// <summary>
        /// 播放音效需要根据皮肤ID来播放音效
        /// </summary>
        /// <param name="battleResType"></param>
        /// <param name="resPath"></param>
        /// <param name="gameObject"></param>
        public void PlaySound(BattleResType battleResType, string resPath, GameObject gameObject)
        {
            using (ProfilerDefine.ActorPlaySoundPMarker.Auto())
            {
                var path = BattleUtil.GetPathBySkinID(this.bornCfg.SkinID, battleResType, resPath);
                battle?.wwiseBattleManager.PlaySound(path, gameObject, actorInsId: this.insID);
            }
        }

        /// <summary>
        /// 设置某种类型的scale值
        /// </summary>
        public void SetTimeScale(float timeScale, float? duration = null, int type = 0)
        {
            timeScaler.SetScale(timeScale, duration, type);
        }

        /// <summary>
        /// 设置魔女时间，与魔女设定
        /// </summary>
        public void SetWitchTime(float scale, float? duration, ActorWitchTimeSettings settings = null)
        {
            timeScaler.SetWitchTime(scale, duration, settings);
        }

        /// <summary>
        /// 设置魔女禁用
        /// </summary>
        public void SetWitchDisabled(bool disabled)
        {
            timeScaler.SetWitchDisabled(disabled);
        }

        /// <summary>
        /// 获取某种类型的ScaleData
        /// </summary>
        public TimeScaler.ScaleData GetScaleData(int type)
        {
            return timeScaler.GetScaleData(type);
        }

        /// <summary>
        /// 修改生命时长 (time 可为负值.)
        /// </summary>
        /// <param name="value"></param>
        public void ModifyLifetime(float value)
        {
            if (_lifetime < 0 || isDead)
                return;
            _lifetime += value;

            if (_lifetime <= 0f)
            {
                _lifetime = 0f;
            }
        }

        /// <summary>
        /// 是否禁用更新LifeTime
        /// </summary>
        /// <param name="disable"></param>
        public void DisableLifetime(bool disable)
        {
            _isUpdateLifetime = !disable;
        }

        /// <summary>
        /// 刷新当前剩余的LifeTime置为出生配置的LifeTime
        /// </summary>
        public void ResetLifetime()
        {
            _lifetime = bornCfg.LifeTime;
        }

        protected void _UpdateLifetime()
        {
            if (!_isUpdateLifetime)
            {
                return;
            }

            if (_lifetime < 0 || isDead)
            {
                return;
            }

            _lifetime -= deltaTime;
            if (_lifetime <= 0f)
            {
                Dead();
            }
        }

        protected bool _InStatus(ActorStatus status)
        {
            return (this.status & (int)status) == (int)status;
        }

        public override string ToString()
        {
            return name;
        }
    }
}