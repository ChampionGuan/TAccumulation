using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class Missile
    {
        public enum State
        {
            Init,
            Suspend,
            Flying,
            WaitingBlast,
            Blast,
            WaitingCreateMagic,//等待创建法术场
            WaitingStop,
            Stop,
        }
        private const float BLAST_DEFAULT_DURATION = 5;
        private State _state = State.Init;
        public State state
        {
            get { return _state; }
            private set
            {
                if (_state != value)
                {
                    var oldState = _state;
                    _state = value;
                    _OnChangeState(oldState, _state); 
                }
            }
        }
        private Actor _masterActor;  // 创建者单位
        private Transform _masterTrans;  // 创建者单位
        private Actor _missileActor;  // 子弹Actor
        private Transform _missileTrans;  // 创建者单位
        private MissileCfg _cfg;  // 子弹配置
        private CreateMissileParam _createParam;  // 创建参数
        private SkillMissile _missileSkill;  // 子弹技能
        private MissileMotionBase _motion;  // 运动逻辑
        private TransInfoCache _transInfoCache;
        private Battle _battle;

        private Vector3 _masterLocalPos;
        private Vector3 _masterLocalForward;
        private float _suspendRemainTime;
        private float _lifeRemainTime;
        private bool _limitLifeTime;
        private float _waitingBlastDelayTime; // 等待播放爆炸效果的时长 = 爆炸延迟 + 播放子弹的End特效时长 + 爆炸特效开始时间偏移
        private float _waitingFlyEndDelayTime; // 等待播放飞行子弹End特效的时长 = 爆炸延迟.
        private float _stopRemainTime;
        private MissileBlastCondition _blastCondition;
        private bool _ignoreBlast;
        private bool _hasCastOriginalDamageBox;
        public MissileBlastCondition blastCondition => _blastCondition;
        private HashSet<Actor> _collideActors = new HashSet<Actor>();

        private Vector3 _lastHitPos;  // 上次碰撞点
        private Vector3? _blastPos;  // 爆炸点

        private RicochetShareData _ricochetShareData;  // 子弹弹射共享参数

        private RicochetData? _ricochetData;  // 子弹弹射参数

        private bool _isRoot;  // 是否为根子弹

        private Action<EventActorBase> _actionOnMasterDead;
        private Action<EventWeakFull> _actionOnMasterWeakFull;

        public float lifeRemainTime => _lifeRemainTime;

        public Missile()
        {
            _actionOnMasterDead = _OnMasterDead;
            _actionOnMasterWeakFull = _OnMasterWeakFull;
        }
        
        public Vector3 GetDestroyPos()
        {
            if (_blastPos != null)
            {
                return _blastPos.Value;
            }
            else
            {
                return _missileActor.transform.position;
            }
        }

        public void Init(SkillMissile missileSkill, MissileCfg cfg, CreateMissileParam createParam, RicochetShareData ricochetShareData, RicochetData? ricochetData, TransInfoCache transInfoCache = null)
        {
            _battle = missileSkill.actor.battle;
            _transInfoCache = transInfoCache; 
            _missileSkill = missileSkill;
            _cfg = cfg;
            _createParam = createParam;
            _missileActor = missileSkill.actor;
             var masterExporter = missileSkill.masterExporter;
            _masterActor = masterExporter.actor;
            _masterTrans = _masterActor.GetDummy(ActorDummyType.Root);
            _missileTrans = _missileActor.GetDummy(ActorDummyType.Root);
            _lifeRemainTime = _cfg.Duration;
            _limitLifeTime = _lifeRemainTime > 0;
            _ricochetShareData = ricochetShareData;
            _ricochetData = ricochetData;
            state = State.Init;
            _isRoot = createParam != null;
            if (_cfg.MotionData.MotionType == MissileMotionType.Line)
            {
                _motion = new MissileMotionLine();
            }
            else if(_cfg.MotionData.MotionType == MissileMotionType.Curve)
            {
                _motion = new MissileMotionCurve();
            }
            else if (_cfg.MotionData.MotionType == MissileMotionType.Bezier)
            {
                _motion = new MissileMotionBezier();
            }
            var targetActor = _masterActor.GetTarget(TargetType.Skill);
            if (ricochetData != null)
            {
                targetActor = ricochetData.Value.targetActor;
            }

            _waitingBlastDelayTime = 0f;
            _waitingFlyEndDelayTime = 0f;
            
            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(cfg.DamageBox);
            var motionData = new MotionParameter
            {
                missileMotionData = cfg.MotionData,
                targetActor = targetActor,
                shapeBoxInfo = damageBoxCfg?.ShapeBoxInfo,
                needGroundCollision = !_cfg.IgnoreCollideScene,
                needCameraCollision = !_cfg.IgnoreCollideCamera,
                collideGroundCallback = _CollideGround,
                collideCameraCallback = _CollideCamera,
            };
            _motion.Init(missileSkill, motionData);
        }

        // 尝试弹射
        private void _TryRicochet(Actor hitActor)
        {
            if (hitActor == null || !_cfg.ricochetActive || _cfg.ricochetMissileID <= 0)
            {
                // 如果不激活弹射，或者弹射子弹id<=0, 退出
                return;
            }

            if (_isRoot)
            {
                // 根子弹_createParam不为空会走这个分支，派生子弹不会走
                if ( _cfg.ricochetMaxNum > 0)
                {
                    _ricochetShareData = ObjectPoolUtility.RicochetShareData.Get();
                    _ricochetShareData.Init(_missileActor, _cfg);
                }
            }
            
            // 根子弹和派生子弹都会走这里
            if (_ricochetShareData != null && _ricochetShareData.CanRicochet())
            {
                var target = _GetNextRicochetTarget(hitActor);
                if (target != null)
                {
                    var ricochetData = new RicochetData();
                    ricochetData.targetActor = target;
                    ricochetData.hitActor = hitActor;
                    ricochetData.hitPosition = _lastHitPos;
                    ricochetData.createMissileID = _cfg.ricochetMissileID;
                    LogProxy.LogFormat("创建弹射子弹：父子弹ID {0}，弹射子弹ID {1}", this._cfg.ID, ricochetData.createMissileID);
                    var newMissile = _missileActor.battle.actorMgr.CreateMissile(_missileSkill.masterExporter, null, _ricochetShareData, ricochetData);
                    if (newMissile != null)
                    {
                        _ricochetShareData.AddChildMissile(newMissile);
                        _ricochetShareData.AddHittingActor(hitActor);
                    }
                }
            }
        }

        // 获取下一个弹射目标
        private Actor _GetNextRicochetTarget(Actor ignoreActor)
        {
            var rootCfg = _ricochetShareData.rootMissileCfg;
            var sqrDistance = rootCfg.ricochetRadius * rootCfg.ricochetRadius;
            var actors = _missileActor.battle.actorMgr.actors;

            var curDistance = 0f;
            Actor curTarget = null;
            
            for (int i = actors.Count - 1; i >= 0; i--)
            {
                var targetActor = actors[i];
                var shareDataAllow = rootCfg.ricochetAllowRepeat || !_ricochetShareData.HasHitActor(targetActor);
                if (shareDataAllow)
                {
                    var actorStateAllow = targetActor.IsRole() && !targetActor.stateTag.IsActive(ActorStateTagType.LockIgnore) && !targetActor.isDead && (targetActor.aiOwner?.isActive ?? true);
                    if (actorStateAllow)
                    {
                        if (targetActor != ignoreActor)
                        {
                            var relationAllow = _masterActor.GetFactionRelationShip(targetActor) == rootCfg.ricochetFactionRelationship;
                            if (relationAllow)
                            {
                                var targetPos = targetActor.transform.position;
                                var offset = targetPos - _lastHitPos;
                                var magnitude = offset.sqrMagnitude;
                                if (magnitude <= sqrDistance)
                                {
                                    if (curTarget == null || magnitude < curDistance)
                                    {
                                        curTarget = targetActor;
                                        curDistance = magnitude;
                                    }
                                }   
                            }
                        }
                    }
                }
            }
            return curTarget;
        }

        // 是否忽略本次actor的hit
        public bool HittingIgnoreActor(Actor actor)
        {
            if (_ricochetData != null && _ricochetData.Value.hitActor == actor)
            {
                // 父子弹碰到的就是这个actor，直接跳出
                return true;
            }

            if (_ricochetShareData != null && !_ricochetShareData.rootMissileCfg.ricochetAllowRepeat)
            {
                if (_ricochetShareData.HasHitActor(actor))
                {
                    // 不允许重复伤害，已经伤害过了就直接跳出
                    return true;
                }
            }
            
            // DONE: 询问运动模式能不能命中该目标, 不能即忽略该目标.
            if (_state == State.Flying && !_motion.CanHit(actor))
            {
                return true;
            }
            
            return false;
        }
        
        public void Start()
        {
            _EvalInitTrans();

            if (_isRoot && _suspendRemainTime == 0)
            {
                // root子弹并且_suspendRemainTime为0，直接进飞行
                _EnterFlying();
            }
            else
            {
                _EnterSuspend();
            }
        }

        public void Stop()
        {
            // 弹射数据回收
            if (_ricochetShareData != null)
            {
                _ricochetShareData.RemoveMissile(_missileActor);
                if (_ricochetShareData.IsMissileEmpty())
                {
                    ObjectPoolUtility.RicochetShareData.Release(_ricochetShareData);
                    _ricochetShareData = null;
                }
            }
        }

        // 更新运动motion
        public void UpdateMotion(float deltaTime)
        {
            if (_state == State.Flying)
            {
                _motion.Update(deltaTime);  
            }
        }

        // 更新逻辑
        public void UpdateLogic(float deltaTime)
        {
            if (_state == State.Suspend || _state == State.Flying)
            {
                if (_state == State.Suspend)
                {
                    // 悬停判断
                    _UpdateSuspend(deltaTime);
                }
                else if(_state == State.Flying)
                {
                    // 运动判断
                    var isComplete = _motion.IsComplete();
                    if (isComplete)
                    {
                        _motion.Stop();
                        // 运动结束进入爆炸等待状态
                        _blastCondition = MissileBlastCondition.LifeOver;
                        _EnterWaitingBlast();
                        return;  // 此处需要跳出，保证状态切换是尾调用
                    }
                }
                
                // 生命周期判断
                if (_limitLifeTime && _lifeRemainTime > 0)
                {
                    _lifeRemainTime = _lifeRemainTime - deltaTime;
                    if (_lifeRemainTime <= 0)
                    {
                        // 生命周期结束进入爆炸等待状态
                        _blastCondition = MissileBlastCondition.LifeOver;
                        _EnterWaitingBlast();
                    }
                }
            }
            else if (_state == State.WaitingBlast)
            {
                if (_waitingFlyEndDelayTime > 0)
                {
                    _waitingFlyEndDelayTime -= deltaTime;
                    if (_waitingFlyEndDelayTime <= 0f)
                    {
                        _TryStopFlyFX();
                    }
                }
                
                _waitingBlastDelayTime -= deltaTime;
                if (_waitingBlastDelayTime <= 0)
                {
                    _EnterBlastEffect();
                }
            }
            else if (_state == State.WaitingCreateMagic)
            {
                _WaitingCreateMagic(deltaTime);
            }
            else if (_state == State.WaitingStop)
            {
                _stopRemainTime = _stopRemainTime - deltaTime;
                if (_stopRemainTime <= 0)
                {
                    _EnterStop();
                }
            }
            else if (_state == State.Stop)
            {
                // 检查子弹是否死亡
                _missileActor.Dead();
            }
        }

        private void _EnterWaitingBlast()
        {
            // 计算爆炸点
            if (_blastCondition == MissileBlastCondition.CollideActor || _blastCondition == MissileBlastCondition.CollideGround || _blastCondition == MissileBlastCondition.CollideSceneCamera) 
            {
               _blastPos = _lastHitPos;
            }
            else
            {
               var actorPos = _missileActor.transform.position;
               _blastPos = actorPos;
            }
           
            // 播自然销毁特效
            if (_blastCondition == MissileBlastCondition.LifeOver)
            {
                // 如果是生命周期结束，尝试播自然销毁特效, 时机在进入等待爆炸状态
                if (_cfg.natureDisappearFx > 0)
                {
                   _missileActor.effectPlayer.PlayFx(_cfg.natureDisappearFx, offsetPos: _blastPos, isWorldParent: true);
                }
            }
            
            // 播自然销毁、碰到地销毁、碰到相机销毁音效
            if (_blastCondition == MissileBlastCondition.LifeOver || _blastCondition == MissileBlastCondition.CollideGround || _blastCondition == MissileBlastCondition.CollideSceneCamera)
            {
                if (_masterActor != null)
                {
                    var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(_cfg.DamageBox);
                    if (damageBoxCfg != null)
                    {
                        var hurtSceneSound = BattleUtil.GetHurtSound(damageBoxCfg, HurtMaterialType.Default);
                        if (!string.IsNullOrEmpty(hurtSceneSound))
                        {
                            _masterActor.PlaySound(BattleResType.ActorAudio, hurtSceneSound, _missileActor.GetDummy(ActorDummyType.Model).gameObject);
                        }
                    }   
                }
            }
            
            _missileSkill.ClearDamageBoxes();  // 清理掉飞行时的Boxes
            
            //进入爆炸处理流程
           if (_cfg.IsBlastEffect && (_cfg.BlastCondition & _blastCondition) > 0 && !_ignoreBlast)
           {
               state = State.WaitingBlast;
               // DONE: 计算爆炸的等待时间.
               float blastDelay = _cfg.BlastDelay < 0 ? 0f : _cfg.BlastDelay;
               _waitingFlyEndDelayTime = blastDelay;
            
               // DONE: 如果要播放飞行子弹的End特效时, 才计算飞行子弹的End特效时长 + 爆炸特效的开始时间偏移.
               float flyFxEndDuration = 0f;
               float blastFXStartTimeOffset = 0f;
               if (_CanPlayFlyEndEffect(_blastCondition))
               {
                   flyFxEndDuration = _battle.fxMgr.GetFx(_missileActor.insID, _cfg.FX)?.endTime ?? 0f;
                   blastFXStartTimeOffset = _cfg.BlastFXStartTimeOffset;
                   if (blastFXStartTimeOffset < 0 && Mathf.Abs(blastFXStartTimeOffset) > flyFxEndDuration)
                   {
                       blastFXStartTimeOffset = -flyFxEndDuration;
                   }
               }
               
               _waitingBlastDelayTime = blastDelay + flyFxEndDuration + blastFXStartTimeOffset;
               
               // DONE: 规则 偏移的时长不能导致开始爆炸效果时刻提前超过飞行子弹第三段开始时的时间刻度.
               if (_waitingBlastDelayTime < _waitingFlyEndDelayTime)
               {
                   _waitingBlastDelayTime = _waitingFlyEndDelayTime;
               }
               
               if (_waitingFlyEndDelayTime <= 0)
               {
                   // 时间如果没配，直接进入爆炸
                   _TryStopFlyFX();
               }

               if (_waitingBlastDelayTime <= 0)
               {
                   state = State.Blast;
               }

               return;
           }

           //播放结束效果 
           _TryStopFlyFX();
            //没有爆炸效果直接进入下一个流程
            state = State.WaitingCreateMagic;
        }

        //进入等待创建法术场状态
        private void _WaitingCreateMagic(float deltaTime)
        {
            if (_cfg.isCreateMagicField && (_cfg.magicFieldBlastCondition & _blastCondition) > 0 && _cfg.magicFieldData != null && _cfg.magicFieldData.ID > 0)
            {
                _cfg.magicFieldOffsetTime -= deltaTime;
                if (_cfg.magicFieldOffsetTime <= 0)
                {
                    CoorPoint coorPoint = _cfg.magicFieldData.pointData;
                    CoorOrientation coorOrientation = _cfg.magicFieldData.forwardData;
                    if (_cfg.magicFieldData.enableValidation)
                    {
                        if (!CoorHelper.IsValidCoorConfig(this._missileActor, coorPoint, coorOrientation, false))
                        {
                            coorPoint = _cfg.magicFieldData.pointData2;
                            coorOrientation = _cfg.magicFieldData.forwardData2;
                        }
                    }
            
                    // DONE: 覆盖阵营逻辑.
                    FactionType? faction = _missileActor.factionType;

                    _battle.CreateMagicField(_missileActor, _missileSkill, _cfg.magicFieldData.ID, coorPoint, coorOrientation, false, _cfg.magicFieldData.createParam, factionType: faction);
                    
                    _EnterWaitingStop();
                }
            }
            else
            {
                _EnterWaitingStop();
            }
        }

        private bool _CanPlayFlyEndEffect(MissileBlastCondition condition)
        {
            if (condition == MissileBlastCondition.LifeOver ||
                (condition == MissileBlastCondition.CollideActor && !_cfg.NotPlayEndFx))
            {
                return true;
            }

            return false;
        }

        // 生命周期结束时，根据情况结束（命中场景在外面已经判断过）
        private void _TryStopFlyFX()
        {
            bool canPlayFlyEndEffect = _CanPlayFlyEndEffect(_blastCondition);
            _missileActor.effectPlayer.StopFX(_cfg.FX, !canPlayFlyEndEffect);
        }

        // 进入等待结束状态
        private void _EnterWaitingStop()
        {
            state = State.WaitingStop;
            if (_stopRemainTime <= 0)
            {
                _EnterStop();
            }
        }
        
        // 进入结束状态
        private void _EnterStop()
        {
            state = State.Stop;
        }
        
        private void _EnterBlastEffect()
        {
            state = State.Blast;
            // 特效
            if (_cfg.BlastFX > 0)
            {
                // DONE: 策划需求潜规则: 爆炸特效默认挂点是世界挂点.
                var fxObj = _missileActor.effectPlayer.PlayFx(_cfg.BlastFX, offsetPos: _blastPos, isWorldParent: true);
                if (fxObj != null)
                {
                    // 设置延迟销毁时长
                    _stopRemainTime = fxObj.duration;
                    if (_stopRemainTime < 0)
                    {
                        _stopRemainTime = BLAST_DEFAULT_DURATION;
                    }
                }
            }
            // 音频
            if (!string.IsNullOrEmpty(_cfg.BlastMusic))
            {
                if (_masterActor != null)
                {
                    _masterActor.PlaySound(BattleResType.ActorAudio, _cfg.BlastMusic, _missileActor.GetDummy(ActorDummyType.Model).gameObject);   
                }
            }
            // 伤害盒
            _missileSkill.CastDamageBox(null, _cfg.BlastDamageBox, _missileSkill.level, out _, null, null, isContinue: true, layerMask: X3LayerMask.HurtTest, terminalPos:_blastPos);
            //震屏
            if (_cfg.ImpulseParameter != null)
            {
                _missileActor.battle.cameraImpulse.AddWorldImpulse(_cfg.CameraShakePath,
                        _cfg.ImpulseParameter, _masterActor, null, _missileActor.GetDummy().gameObject.transform.position);
            }

            state = State.WaitingCreateMagic;//爆炸完了进入等待法术场状态
        }

        // 更新悬停状态
        private void _UpdateSuspend(float deltaTime)
        {
            if (_isRoot)
            {
                // 根子弹
                if (_createParam.SuspendType != MissileSuspendType.None)
                {
                    if(_createParam.SuspendType == MissileSuspendType.FollowCaster)
                    {
                        // 跟随角色的需要刷新位置
                        var worldPos = _masterTrans.TransformPoint(_masterLocalPos);
                        var forward = _masterTrans.TransformDirection(_masterLocalForward);
                        _missileActor.transform.SetPosition(worldPos);
                        _missileActor.transform.SetForward(forward, false);   
                    }
                
                    _suspendRemainTime = _suspendRemainTime - deltaTime;
                    if (_suspendRemainTime <= 0)
                    {
                        // 判断时间
                        _EnterFlying();
                    }
                }
                else
                {
                    _EnterFlying();
                }
            }
            else
            {
                // 派生子弹
                if (TbUtil.battleConsts.MarbleLowestTime > 0)
                {
                    _suspendRemainTime = _suspendRemainTime - deltaTime;
                    if (_suspendRemainTime <= 0)
                    {
                        _missileActor.transform.SetVisible(true);
                        _EnterFlying();   
                    }
                }
                else
                {
                    _EnterFlying();
                }
            }
        }

        // 进入悬停状态
        private void _EnterSuspend()
        {
            state = State.Suspend;
            if (_createParam != null && _createParam.SuspendCanDamage)
            {
                // 悬停期间可以造成伤害的话，直接释放伤害盒
                _CastOriginalDamageBox();
            }
        }
        
        private void _EnterFlying()
        {
            state = State.Flying;
            if (!string.IsNullOrEmpty(_cfg.FlyMusic))
            {
                if (_masterActor != null)
                {
                    _masterActor.PlaySound(BattleResType.ActorAudio, _cfg.FlyMusic, _missileActor.GetDummy(ActorDummyType.Model).gameObject);   
                }
            }
            _motion.Start();
            _CastOriginalDamageBox();
        }

        // 释放初始阶段的伤害盒（飞行和悬停）
        private void _CastOriginalDamageBox()
        {
            if (_hasCastOriginalDamageBox)
            {
                return;
            }
            _hasCastOriginalDamageBox = true;
            _missileSkill.CastDamageBox(null, _cfg.DamageBox, _missileSkill.level, out _, null, null, -1, isContinue: true, layerMask: X3LayerMask.MissileTest);
        }

        public void OnHitAny(DamageBox damageBox)
        {
            var hitTargets = damageBox.lastHitTargets;
            LogProxy.LogFormat("子弹 {0} 命中了单位", _cfg.ID);
            if (hitTargets != null && hitTargets.Count > 0 && hitTargets[0].hitPos != null)
            {
                _lastHitPos = hitTargets[0].hitPos.Value;
            }

            if (_state == State.Flying || _state == State.Suspend)
            {
                if (hitTargets != null && hitTargets.Count > 0)
                {
                    if (!string.IsNullOrEmpty(_cfg.HitActorMusic))
                    {
                        _masterActor.PlaySound(BattleResType.ActorAudio, _cfg.HitActorMusic, _missileActor.GetDummy(ActorDummyType.Model).gameObject);
                    }
                    // 弹射逻辑，目前碰撞点只有1个，所以先只弹第1个人
                    _TryRicochet(hitTargets[0].actor);
                    
                    // 飞行中打人到上限，进入waitingBlast状态
                    _ignoreBlast = false;
                    foreach (var hitTargetInfo in hitTargets)
                    {
                        var hitActor = hitTargetInfo.actor;
                        _motion.HitAny(hitActor);
                        _collideActors.Add(hitActor);
                        if (!_ignoreBlast && hitActor != null)
                        {
                            if (hitActor.stateTag.IsActive(ActorStateTagType.MissileBlastIgnore))
                            {
                                // 命中了有免疫爆炸buff的人，子弹就不爆炸
                                _ignoreBlast = true;
                            }
                        }
                    }
                    
                    if (_cfg.MaxCollideNum > 0 &&  _collideActors.Count >= _cfg.MaxCollideNum)
                    {
                        _blastCondition = MissileBlastCondition.CollideActor;
                        _EnterWaitingBlast();
                    }
                }
            }
        }

        // 开始时初始化位置和旋转
        private void _EvalInitTrans()
        {
            if (_isRoot)
            {
                // 根子弹会走这里
                var pos = _createParam.StartPos.GetCoordinatePoint(_masterActor, _createParam.IsTargetType, transInfoCache: _transInfoCache);
                _missileActor.transform.SetPosition(pos);
            
                if (_createParam.MissileCalculateForward)
                {
                    var forward = _createParam.StartForward.GetCoordinateOrientation(_missileActor, _createParam.IsTargetType, transInfoCache: _transInfoCache);
                    _missileActor.transform.SetForward(forward, false);
                }
                else
                {
                    var forward = _createParam.StartForward.GetCoordinateOrientation(_masterActor, _createParam.IsTargetType, transInfoCache: _transInfoCache);
                    _missileActor.transform.SetForward(forward, false);
                }
                
                if (_createParam.SuspendType != MissileSuspendType.None)
                {
                    if (_createParam.SuspendType == MissileSuspendType.FollowCaster)
                    {
                        _masterLocalPos = _masterTrans.InverseTransformPoint(_missileTrans.position);
                        _masterLocalForward = _masterTrans.InverseTransformDirection(_missileTrans.forward);
                    }   
                    _suspendRemainTime = _createParam.SuspendTime;
                }   
            }
            else if (_ricochetData != null)
            {
                var data = _ricochetData.Value;
                // 派生子弹会走这里
                _missileActor.transform.SetPosition(data.hitPosition);
                if (data.targetActor != null)
                {
                    var forward = (data.targetActor.transform.position - data.hitPosition).normalized;
                    _missileActor.transform.SetForward(forward);   
                }
                if (TbUtil.battleConsts.MarbleLowestTime > 0)
                {
                    _suspendRemainTime = TbUtil.battleConsts.MarbleLowestTime;
                    _missileActor.transform.SetVisible(false);
                }
            }
        }

        // 当状态变化时额外做一些逻辑，
        // 主要要处理离开某种状态时的逻辑，比如事件注册等，逻辑需要轻量
        private void _OnChangeState(State oldState, State curState)
        {
            if (oldState == State.Suspend)
            {
                if (_createParam != null && _createParam.SuspendDestroyType != SuspendDestroyType.None)
                {
                    _RemoveListenerForSuspendDestroy();
                }
            }
            else if (curState == State.Suspend)
            {
                if (_createParam != null && _createParam.SuspendDestroyType != SuspendDestroyType.None)
                {
                    _AddListenerForSuspendDestroy();
                }
            }
        }

        private void _AddListenerForSuspendDestroy()
        {
            if (this._masterActor == null)
            {
                return;
            }

            var eventMgr = this._masterActor.battle.eventMgr;
            switch (_createParam.SuspendDestroyType)
            {
                case SuspendDestroyType.None:
                    break;
                case SuspendDestroyType.CoreBreakFull:
                    eventMgr.AddListener<EventWeakFull>(EventType.WeakFull, _actionOnMasterWeakFull, "Missile._OnMasterWeakFull");
                    break;
                case SuspendDestroyType.Death:
                    eventMgr.AddListener<EventActorBase>(EventType.ActorDead, _actionOnMasterDead, "Missile._OnMasterDead");
                    break;
                case SuspendDestroyType.CoreBreakFullOrDeath:
                    eventMgr.AddListener<EventWeakFull>(EventType.WeakFull, _actionOnMasterWeakFull, "Missile._OnMasterWeakFull");
                    eventMgr.AddListener<EventActorBase>(EventType.ActorDead, _actionOnMasterDead, "Missile._OnMasterDead");
                    break;
            }
        }

        private void _RemoveListenerForSuspendDestroy()
        {
            if (this._masterActor == null)
            {
                return;
            }
            
            var eventMgr = this._masterActor.battle.eventMgr;
            switch (_createParam.SuspendDestroyType)
            {
                case SuspendDestroyType.None:
                    break;
                case SuspendDestroyType.CoreBreakFull:
                    eventMgr.RemoveListener<EventWeakFull>(EventType.WeakFull, _actionOnMasterWeakFull);
                    break;
                case SuspendDestroyType.Death:
                    eventMgr.RemoveListener<EventActorBase>(EventType.ActorDead, _actionOnMasterDead);
                    break;
                case SuspendDestroyType.CoreBreakFullOrDeath:
                    eventMgr.RemoveListener<EventWeakFull>(EventType.WeakFull, _actionOnMasterWeakFull);
                    eventMgr.RemoveListener<EventActorBase>(EventType.ActorDead, _actionOnMasterDead);
                    break;
            }
        }

        private void _OnMasterWeakFull(EventWeakFull args)
        {
            if (args.actor != this._masterActor)
            {
                return;
            }
            
            _EnterStop();
        }

        private void _OnMasterDead(EventActorBase args)
        {
            if (args.actor != this._masterActor)
            {
                return;
            }
            
            _EnterStop();
        }

        private void _CollideGround(Vector3 hitGroundPos, bool isJumpEnd)
        {
            // 飞行中打到墙进入WaitingBlast状态
            _blastCondition = MissileBlastCondition.CollideGround;
            
            _lastHitPos = hitGroundPos;

            // DONE: 把子弹拉到与射线检测的位置.
            _missileActor.transform.SetPosition(hitGroundPos);

            _PlayCollideSceneEffect(hitGroundPos);
            
            //如果弹跳没有结束 不走销毁逻辑
            if (!isJumpEnd)
            {
                return;
            }

            _EnterWaitingBlast();
        }

        private void _CollideCamera(Vector3 hitCameraPos)
        {
            _blastCondition = MissileBlastCondition.CollideSceneCamera;
            _lastHitPos = hitCameraPos;
            _PlayCollideSceneEffect(hitCameraPos);
            _EnterWaitingBlast();
        }

        /// <summary>
        /// 播放碰撞场景效果.
        /// </summary>
        /// <param name="pos"></param>
        private void _PlayCollideSceneEffect(Vector3 pos)
        {
            if (!string.IsNullOrEmpty(_cfg.HitSceneMusic))
            {
                if (_masterActor != null)
                {
                    _masterActor.PlaySound(BattleResType.ActorAudio, _cfg.HitSceneMusic, _missileActor.GetDummy(ActorDummyType.Model).gameObject);
                }
            }

            if (_cfg.CollideSceneFX > 0)
            {
                // DONE: 策划需求特殊处理, 命中场景特效也默认世界坐标.
                var fxObj = _missileActor.effectPlayer.PlayFx(_cfg.CollideSceneFX, offsetPos: pos, isWorldParent: true);
                if (fxObj != null)
                {
                    _stopRemainTime = fxObj.duration;
                    if (_stopRemainTime < 0)  // 循环特效时长是0
                    {
                        _stopRemainTime = BLAST_DEFAULT_DURATION;
                    }
                }
            }
        }
    }
}