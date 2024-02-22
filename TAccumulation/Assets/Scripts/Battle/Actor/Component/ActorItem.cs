using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class ActorItem : ActorComponent
    {
        private ItemCfg _itemCfg;
        private int _slotId;
        private FlyMotion _flyMotion;
        private Adsorption _adsorption;
        private bool _adsorptionFlag;
        private FxPlayer _flyFx;
        private FxPlayer _itemFx;
        private List<Actor> _adsorptionTargetActors;
        private List<Actor> _effectTargetActors;
        private bool _isSameID = false; // _itemCfg.EnableFly && _itemCfg.FlyFxId == _itemCfg.ItemFxId
        
        private int? _adsorptionTimerId; // 吸附计时器ID.
        private int? _effectTimerId; // 开启生效功能计时器ID.
        private int? _effectRemainTimerId; // 生效后死亡倒计时ID.
        private bool _isOpenEffect => _effectTimerId == null;
        private bool _isOpenAdsorption => _adsorptionTimerId == null;
        
        private Action<int> _actionWaitComplete;
        private ItemState _itemState = ItemState.None;

        enum ItemState
        {
            None,
            Fly,
            Adsorption,
        }

        public ActorItem() : base(ActorComponentType.Items)
        {
            _actionWaitComplete = _WaitComplete;
        }

        protected override void OnStart()
        {
            _itemCfg = TbUtil.GetCfg<ItemCfg>(actor.config.ID);
            if (_itemCfg == null)
            {
                return;
            }

            if (_itemCfg.FlyBoxInfo?.ShapeInfo != null)
            {
                _itemCfg.FlyBoxInfo.ShapeInfo.SetDebugInfo("【Alt+Z/道具/{0}/预出生地面检测形状参数】", _itemCfg.ID);
            }

            if (_itemCfg.AdsorptionBoxInfo?.ShapeInfo != null)
            {
                _itemCfg.AdsorptionBoxInfo.ShapeInfo.SetDebugInfo("【Alt+Z/道具/{0}/吸附形状参数】", _itemCfg.ID);
            }

            if (_itemCfg.EffectBoxInfo?.ShapeInfo != null)
            {
                _itemCfg.EffectBoxInfo.ShapeInfo.SetDebugInfo("【Alt+Z/道具/{0}/生效形状参数】", _itemCfg.ID);
            }
            
            _slotId = actor.skillOwner.GetOrCreateEmptySkill(null, new SkillCfg()
            {
                ID = _itemCfg.ID,
                Name = $"item{_itemCfg.ID}",
            }, new SkillLevelCfg()
            {
                Level = 1,
            });
            
            _adsorptionTargetActors = new List<Actor>(2);
            _effectTargetActors = new List<Actor>(2);

            _isSameID = _itemCfg.EnableFly && _itemCfg.FlyFxId == _itemCfg.ItemFxId;
        }

        public override void OnBorn()
        {
            if (_itemCfg == null)
            {
                return;
            }
            
            SkillActive skillActive =  actor.skillOwner.GetSkillBySlot(_slotId) as SkillActive;
            skillActive?.SetMasterExporter(actor.itemBornCfg.damageExporter);
            _itemState = ItemState.None;
            
            // 预出生初始化
            if (_itemCfg.EnableFly)
            {
                _flyMotion = new FlyMotion(actor, skillActive, _itemCfg);
                _flyFx = actor.effectPlayer.PlayFx(_itemCfg.FlyFxId);
                _ChangeItemState(ItemState.Fly);
            }
            
            // 吸附初始化相关数据
            if (_itemCfg.EnableAdsorption)
            {
                _UpdateTargetActors(_adsorptionTargetActors, _itemCfg.AdsorptionFilterType);
                _adsorption = new Adsorption(actor, skillActive, _itemCfg);
                _adsorptionFlag = false;

                // DONE: 开启吸附倒计时
                if (_itemCfg.AdsorptionDelayTime > 0)
                {
                    _adsorptionTimerId = battle.battleTimer.AddTimer(null, delay: _itemCfg.AdsorptionDelayTime, tickInterval: 0f, funcComplete: _actionWaitComplete);
                }
            }
            
            // 生效初始化相关数据
            _UpdateTargetActors(_effectTargetActors, _itemCfg.EffectFilterType);
            
            // DONE: 开启生效倒计时
            if (_itemCfg.EffectDelayTime > 0)
            {
                _effectTimerId = battle.battleTimer.AddTimer(null, delay: _itemCfg.EffectDelayTime, tickInterval: 0f, funcComplete: _actionWaitComplete);
            }

            // DONE: 开启自毁倒计时
            float lifeTime = _itemCfg.EffectDelayTime + _itemCfg.LifeTime;
            if (lifeTime > 0)
            {
                _effectRemainTimerId = battle.battleTimer.AddTimer(null, delay: lifeTime, tickInterval: 0f, funcComplete: _actionWaitComplete);
            }
        }

        private void _UpdateTargetActors(List<Actor> targetActors, ItemFilterType filterType)
        {
            targetActors.Clear();
            if (filterType == 0 || (filterType & ItemFilterType.Girl) > 0)
            {
                targetActors.Add(actor.battle.player);
            }
            
            if ((filterType & ItemFilterType.Boy) > 0)
            {
                targetActors.Add(actor.battle.actorMgr.boy);
            }
        }

        protected override void OnUpdate()
        {
            // 倒计时
            if (_effectRemainTimerId == null)
            {
                actor.Dead();
                return;
            }
            
            // 开启了吸附功能, 就开始检测吸附目标.
            if (_isOpenAdsorption)
            {
                if (!_adsorptionFlag && _adsorption != null)
                {
                    Actor finalAdsorptionActor = _GetFinalAdsorptionActor();
                    _adsorption.SetTarget(finalAdsorptionActor);
                    _adsorptionFlag = true;
                    _ChangeItemState(ItemState.Adsorption);
                }
            }
            
            // 预处生播放飞行表演
            if (_itemState == ItemState.Fly)
            {
                if (_flyMotion != null)
                {
                    _flyMotion.Move(actor.deltaTime);
                    if (_flyMotion.isFinished)
                    {
                        _flyMotion = null;
                        if (!_isSameID)
                        {
                            _flyFx?.Stop();
                        }
                    }
                }
            }
            // 处于吸附运动中
            else if (_itemState == ItemState.Adsorption)
            {
                if (_adsorption != null)
                {
                    _adsorption.Move(actor.deltaTime);
                    if (_adsorption.isFinished)
                    {
                        _adsorption = null;
                    }
                }
            }

            // 没有计时器时, 即可以开启生效功能了.
            if (_isOpenEffect)
            {
                // DONE: 生效逻辑启用时 && ItemFxId != FlyFxId时, 创建ItemFxId特效.
                if (_itemFx == null && !_isSameID)
                {
                    _itemFx = actor.effectPlayer.PlayFx(_itemCfg.ItemFxId);
                }

                Actor finalEffectActor = _GetFinalEffectActor();
                if (finalEffectActor != null)
                {
                    if (_itemCfg.PickUpFxId > 0)
                    {
                        actor.effectPlayer.PlayFx(_itemCfg.PickUpFxId);
                    }

                    //生效
                    foreach (AddItemBuffData addBuffData in _itemCfg.AddBuffDatas)
                    {
                        Actor target = _GetTarget(addBuffData.TargetType, finalEffectActor);
                        _AddBuff(target, addBuffData, actor);
                    }

                    actor.skillOwner.TryCastSkillBySlot(_slotId);
                    foreach (AddDamageBoxData addDamageBoxData in _itemCfg.AddDamageBoxDatas)
                    {
                        Actor target = _GetTarget(addDamageBoxData.TargetType, finalEffectActor);
                        DamageBoxCfg damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(addDamageBoxData.ID);
                        CheckTargetType oldCheckTargetType = damageBoxCfg.CheckTargetType;
                        DirectSelectType oldDirectSelectType = damageBoxCfg.DirectSelectType;
                        damageBoxCfg.CheckTargetType = CheckTargetType.Direct;
                        damageBoxCfg.DirectSelectType = DirectSelectType.SpecifyTarget;
                        actor.skillOwner.currentSlot.skill.CastDamageBox(null, damageBoxCfg, target, 1, out _, null, null);
                        damageBoxCfg.CheckTargetType = oldCheckTargetType;
                        damageBoxCfg.DirectSelectType = oldDirectSelectType;
                    }

                    var eventData = battle.eventMgr.GetEvent<EventPickItem>();
                    eventData.Init(finalEffectActor, actor);
                    battle.eventMgr.Dispatch(EventType.OnPickItem, eventData);
                    actor.Dead();
                }
            }
        }

        private void _ChangeItemState(ItemState itemState)
        {
            var lastState = _itemState;
            if (lastState == itemState)
            {
                return;
            }
            
            if (lastState == ItemState.Fly)
            {
                if (_flyMotion != null)
                {
                    _flyMotion?.Stop();
                    _flyMotion = null;
                }
                if (!_isSameID)
                {
                    _flyFx?.Stop();
                }
            }
            _itemState = itemState;
        }

        private void _WaitComplete(int id)
        {
            if (id == _adsorptionTimerId)
            {
                _adsorptionTimerId = null;
            }
            else if (id == _effectTimerId)
            {
                _effectTimerId = null;
            }
            else if (id == _effectRemainTimerId)
            {
                _effectRemainTimerId = null;
            }
        }

        private void _AddBuff(Actor target, AddItemBuffData addBuffData, Actor caster)
        {
            if (target == null)
            {
                return;
            }
            int? layer = null;
            float? time = null;
            int level = actor.bornCfg.Level;
            if (addBuffData.IsOverrideLayer)
            {
                layer = addBuffData.Layer;
            }

            if (addBuffData.IsOverrideTime)
            {
                time = addBuffData.Time;
            }

            if (addBuffData.IsOverrideLevel)
            {
                level = addBuffData.Level;
            }
            target.buffOwner?.Add(addBuffData.ID, layer, time, level, caster);
        }
        
        private Actor _GetFinalAdsorptionActor()
        {
            List<Actor> adsorptionActors = BattleUtil.ShapeDetect(_itemCfg.AdsorptionBoxInfo, actor, out bool lastHitGround, out bool lastHitAirWall);
            foreach (var adsorptionActor in adsorptionActors)
            {
                foreach (var adsorptionTargetActor in _adsorptionTargetActors)
                {
                    if (adsorptionActor == adsorptionTargetActor)
                    {
                        return adsorptionActor;
                    }
                }
            }

            return null;
        }

        private Actor _GetFinalEffectActor()
        {
            List<Actor> effectActors = BattleUtil.ShapeDetect(_itemCfg.EffectBoxInfo, actor, out bool lastHitGround, out bool lastHitAirWall);
            foreach (var effectActor in effectActors)
            {
                foreach (var effectTargetActor in _effectTargetActors)
                {
                    if (effectActor == effectTargetActor)
                    {
                        return effectActor;
                    }
                }
            }

            return null;
        }

        private Actor _GetTarget(ItemTargetType targetType, Actor target)
        {
            if (targetType == ItemTargetType.Girl)
            {
                return actor.battle.player;
            }

            if (targetType == ItemTargetType.Boy)
            {
                return actor.battle.actorMgr.boy;
            }

            return target;
        }

        public override void OnDead()
        {
            _itemState = ItemState.None;
            _flyMotion = null;
            _adsorption = null;
            if (_itemFx != null)
                this.actor.effectPlayer.StopFX(_itemFx);
            _itemFx = null;
            if (_flyFx != null)
                _flyFx.Stop(true);
            _flyFx = null;
            if (_adsorptionTimerId != null)
            {
                battle.battleTimer.Discard(null, _adsorptionTimerId.Value);
                _adsorptionTimerId = null;
            }

            if (_effectTimerId != null)
            {
                battle.battleTimer.Discard(null, _effectTimerId.Value);
                _effectTimerId = null;
            }
            
            if (_effectRemainTimerId != null)
            {
                battle.battleTimer.Discard(null, _effectRemainTimerId.Value);
                _effectRemainTimerId = null;
            }
        }

        public override void OnRecycle()
        {
            _flyFx = null;
            _itemFx = null;
            _adsorptionTargetActors.Clear();
            _effectTargetActors.Clear();
        }

        protected override void OnDestroy()
        {
            _itemCfg = null;
        }

        class Adsorption
        {
            private Actor _actor;
            private Actor _targetActor;
            private ItemCfg _itemCfg;
            private MissileMotionBase _motion;
            private SkillActive _skillActive;
            private MissileMotionData _motionData;
            private bool _isHitGround;
            public bool isFinished { get; private set; }

            public Adsorption(Actor actor, SkillActive skillActive, ItemCfg itemCfg)
            {
                _actor = actor;
                _skillActive = skillActive;
                _itemCfg = itemCfg;
                isFinished = false;

                _motionData = _itemCfg.AdsorptionMotionData;
                switch (_motionData.MotionType)
                {
                    case MissileMotionType.Line:
                        _motion = new MissileMotionLine();
                        break;
                    case MissileMotionType.Curve:
                        _motion = new MissileMotionCurve();
                        break;
                    case MissileMotionType.Bezier:
                        _motion = new MissileMotionBezier();
                        break;
                    default:
                        throw new ArgumentOutOfRangeException();
                }
            }

            public void SetTarget(Actor targetActor)
            {
                isFinished = false;
                _targetActor = targetActor;
                MotionParameter motionParameter = new MotionParameter
                {
                    missileMotionData = _itemCfg.AdsorptionMotionData,
                    targetActor = _targetActor,
                    shapeBoxInfo = _itemCfg.FlyBoxInfo,
                    needGroundCollision = true,
                    needCameraCollision = false,
                    collideGroundCallback = _CollideGround,
                };
                _motion.Init(_skillActive, motionParameter);
                _motion.Start();
            }

            public void Move(float deltaTime)
            {
                if (isFinished)
                {
                    return;
                }

                _isHitGround = false;
                // 更新道具位置.
                _motion.Update(deltaTime);

                // 检测道具有没有碰到生效的单位.
                var actors = BattleUtil.ShapeDetect(_itemCfg.EffectBoxInfo, _actor, out bool lastHitGround, out bool lastHitAirWall);

                // 吸附运动完成 || 命中了吸附目标 || 碰撞到了地面
                if (_motion.IsComplete() || actors.Contains(_targetActor) || _isHitGround)
                {
                    _Finish();
                }
            }

            private void _CollideGround(Vector3 hitGroundPos, bool isJumpEnd)
            {
                _isHitGround = true;
                
                // DONE: 把道具Actor拉到与射线检测的位置.
                _actor.transform.SetPosition(hitGroundPos);
            }

            void _Finish()
            {
                _motion.Stop();
                _motion = null;
                _actor = null;
                _targetActor = null;
                _itemCfg = null;
                isFinished = true;
            }
        }

        class FlyMotion
        {
            private Actor _actor;
            private ItemCfg _itemCfg;
            private bool _isDetectAirWallOrMapBorder;
            private MissileMotionBase _motion;
            private SkillActive _skillActive;
            private MissileMotionData _motionData;
            private bool _isHitGround;
            public bool isFinished { get; private set; }

            public FlyMotion(Actor actor, SkillActive skillActive, ItemCfg itemCfg)
            {
                _actor = actor;
                _itemCfg = itemCfg;
                isFinished = false;
                _isDetectAirWallOrMapBorder = false;
                _skillActive = skillActive;
                
                _motionData = _itemCfg.FlyMotionData;
                switch (_motionData.MotionType)
                {
                    case MissileMotionType.Line:
                        _motion = new MissileMotionLine();
                        break;
                    case MissileMotionType.Curve:
                        _motion = new MissileMotionCurve();
                        break;
                    case MissileMotionType.Bezier:
                        _motion = new MissileMotionBezier();
                        break;
                    default:
                        throw new ArgumentOutOfRangeException();
                }

                MotionParameter motionParameter = new MotionParameter
                {
                    missileMotionData = _motionData,
                    targetActor = null,
                    shapeBoxInfo = itemCfg.FlyBoxInfo,
                    needGroundCollision = true,
                    needCameraCollision = false,
                    collideGroundCallback = _CollideGround
                };
                _motion.Init(skillActive, motionParameter);
                _motion.Start();
            }

            public void Move(float deltaTime)
            {
                if (isFinished)
                {
                    return;
                }

                _isHitGround = false;
                
                // 更新道具位置.
                _motion.Update(deltaTime);
                
                // 检测道具有没有碰到生效的单位.
                BattleUtil.ShapeDetect(_itemCfg.FlyBoxInfo, _actor, out bool lastHitGround, out bool lastHitAirWall);

                if (_motion.IsComplete() || _isHitGround)
                {
                    _Finish();
                }
            }

            public void Stop()
            {
                _Finish();
            }

            private void _CollideGround(Vector3 hitGroundPos, bool isJumpEnd)
            {
                _isHitGround = true;
                
                // DONE: 把道具Actor拉到与射线检测的位置.
                _actor.transform.SetPosition(hitGroundPos);
            }

            void _Finish()
            {
                _motion?.Stop();
                _motion = null;
                _actor = null;
                _itemCfg = null;
                isFinished = true;
            }
        }
    }
}