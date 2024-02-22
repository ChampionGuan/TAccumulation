using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class PhysicsDamageBox : DamageBox
    {
        private ShapeBox _shapeBox;

        public ShapeBox ShapeBox => _shapeBox;

        private bool? _isContinue;
        private int? _layerMask;

        private Comparison<Actor> _sortComparisonFunc;

        public PhysicsDamageBox()
        {
            _sortComparisonFunc = _ActorPositionSortComparison;
        }

        public void Init(DamageExporter damageExporter, int id, int groupID, int level, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, List<Actor> excludeSet, float damageProportion, float? extDuration, Vector3? angleY, Vector3? position, bool? isContinue = null, int? layerMask = null, Vector3? terminalPos = null, ShapeBoxInfo shapeBoxInfo = null)
        {
            this._Init(damageExporter, id, groupID, level, damageBoxCfg, hitParamConfig, excludeSet, damageProportion, extDuration);
            _isContinue = isContinue;
            _layerMask = layerMask;
            
            // DONE: 将形状逻辑的数据交由ShapeBox处理.
            var mountTarget = _GetMountVirtualTrans();
            if (mountTarget == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("PhysicsDamageBox 目标或者骨骼点都没有获取到. DamageBoxCfg.DummyName={0}", _damageBoxCfg.DummyName);
                return;
            }

            // DONE: 形状位置数据逻辑委托ShapeBox实现.
            var shapeBoxInfoVar = shapeBoxInfo ?? _damageBoxCfg.ShapeBoxInfo;
            _shapeBox = ObjectPoolUtility.ShapeBoxPool.Get();
            _shapeBox.Init(shapeBoxInfoVar, mountTarget, position, angleY, terminalPos: terminalPos);
        }


        // 获取伤害盒真正的mountTarget
        private VirtualTrans? _GetMountVirtualTrans()
        {
            VirtualTrans? virtualTrans = null;
            var mountType = _damageBoxCfg.MountType;

            switch (mountType)
            {
                case MountType.Self:
                case MountType.Target:
                case MountType.Girl:
                case MountType.Boy:
                case MountType.HpLessOfManAndWoman:
                    var actor = _GetMountActor();
                    if (actor != null)
                    {
                        var dummy = actor.GetDummy(_damageBoxCfg.DummyName);
                        if (dummy != null)
                        {
                            virtualTrans = new VirtualTrans(dummy);
                        }
                    }
                    break;
                case MountType.World:
                    virtualTrans = new VirtualTrans(Vector3.zero, Quaternion.identity);
                    break;
                case MountType.CastingActorTrans:
                    var position = _damageExporter.GetCastingPosition();
                    var rotation = _damageExporter.GetCastingRotation();
                    virtualTrans = new VirtualTrans(position, rotation);
                    break;
            }
            return virtualTrans;
        }
        
        // 获取绑定的actor
        private Actor _GetMountActor()
        {
            var actor = _damageExporter.actor;
            var mountType = _damageBoxCfg.MountType;
            switch (mountType)
            {
                case MountType.Self:
                    return _damageExporter.actor;
                case MountType.Target:
                    return actor.targetSelector?.GetTarget() ?? actor;
                case MountType.Girl:
                    return actor.battle.actorMgr.girl;
                case MountType.Boy:
                    return actor.battle.actorMgr.boy;
                case MountType.HpLessOfManAndWoman:
                    var boy = actor.battle.actorMgr.boy;
                    var girl = actor.battle.actorMgr.girl;
                    var boyHpRatio = boy.attributeOwner.GetAttrValue(AttrType.HP) / boy.attributeOwner.GetAttrValue(AttrType.MaxHP);
                    var girlHpRatio = girl.attributeOwner.GetAttrValue(AttrType.HP) / girl.attributeOwner.GetAttrValue(AttrType.MaxHP);
                    // 血量一样选女主
                    return girlHpRatio <= boyHpRatio ? girl : boy;
                default:
                    return null;
            }
        }
        
        protected override List<Actor> _PickDamageBoxTargets(out List<CollisionDetectionInfo> collisionInfos)
        {
            List<Actor> results = null;
            using (ProfilerDefine.DamageBox_PhysicsDamageBox_PickDamageBoxTargets.Auto())
            {
                _reuseActors.Clear();
                _reuseActorCollisionInfo.Clear();
                collisionInfos = _reuseActorCollisionInfo;
                if (_shapeBox == null)
                {

                    return _reuseActors;
                }

                _shapeBox.Update();

                var targetPosition = _shapeBox.GetCurWorldPos();
                var prevPosition = _shapeBox.GetPrevWorldPos();
                var euler = _shapeBox.GetCurWorldEuler();
                var bundingShape = _shapeBox.GetBoundingShape();

                // 新加逻辑，外部传入用外部，外部不传用配置
                var isContinue = _damageBoxCfg.IsContinuousMode;
                if (_isContinue != null)
                {
                    isContinue = _isContinue.Value;
                }

                var dynamicExcludeRoles = (_damageBoxCfg.CheckMode == DamageBoxCheckMode.Once && bundingShape.ShapeType == ShapeType.Ray) ? null : this._dynamicExcludeRoles;
                var actor = _damageExporter.actor;
                results = _reuseActors;
                BattleUtil.PickAOETargets(
                    _battle,
                    ref results,
                    targetPosition,
                    prevPosition,
                    euler,
                    bundingShape, // 这里的damageBoxConfig类型继承自BoundingShape，所以可以直接这样使用，不需要在创建新的shape，无GC
                    actor,
                    false,
                    dynamicExcludeRoles,
                    isContinue,
                    collisionInfos,
                    this._relationShips,
                    _damageBoxCfg.IsFactionRelationshipSelf,
                    layerMask: _layerMask,
                    coverFactionType: _faction);

                // DONE: 射线类型处理穿透数量逻辑.
                if (bundingShape.ShapeType == ShapeType.Ray)
                {
                    if (results.Count > 0)
                    {
                        if (_damageBoxCfg.PenetrateUnitNum == 0f)
                        {
                            results.Clear();
                        }
                        else if (_damageBoxCfg.PenetrateUnitNum > 0f)
                        {
                            if (_sortComparisonFunc != null)
                            {
                                results.Sort(_sortComparisonFunc);
                            }

                            int extraCount = results.Count - _damageBoxCfg.PenetrateUnitNum;
                            if (extraCount > 0)
                            {
                                results.RemoveRange(_damageBoxCfg.PenetrateUnitNum, extraCount);
                            }
                        }
                    }
                }
            }

            return results;
        }

        protected override void OnDestroy()
        {
            ObjectPoolUtility.ShapeBoxPool.Release(_shapeBox);
            _shapeBox = null;
        }

        protected override void _OnReset()
        {
            _shapeBox = null;
            _isContinue = null;
            _layerMask = null;
        }

        private int _ActorPositionSortComparison(Actor actor1, Actor actor2)
        {
            return (int)((actor1.transform.position - _shapeBox.GetCurWorldPos()).sqrMagnitude - (actor2.transform.position - _shapeBox.GetCurWorldPos()).sqrMagnitude);
        }

        public override Vector3? GetAttackStartPoint()
        {
            // DONE: 如果是射线类型, 不考虑策划配置, 直接将射线的发射端点作为命中的攻击起始点.
            if (_shapeBox != null)
            {
                var boundingShape = _shapeBox.GetBoundingShape();
                if (boundingShape.ShapeType == ShapeType.Ray)
                {
                    if (IsContinue())
                    {
                        return _shapeBox.GetPrevWorldPos();
                    }

                    return _shapeBox.GetCurWorldPos();
                }
            }
            
            return _damageExporter.actor.transform.prevPosition + Quaternion.LookRotation(_damageExporter.actor.transform.prevForward) * _damageBoxCfg.AttackStartPoint;
        }

        public override Vector3 GetCollideDir()
        {
            Vector3 dir = Vector3.zero;
            if (_shapeBox != null)
            {
                var shapeType = _shapeBox.shapeBoxInfo.ShapeInfo.ShapeType;
                if (shapeType == ShapeType.Ray)
                {
                    // 射线直接取射线方向
                    dir = Quaternion.Euler(_shapeBox.GetCurWorldEuler()) * Vector3.forward;
                }
                else
                {
                    // 非射线取运动方向
                    dir = (_shapeBox.GetCurWorldPos() - _shapeBox.GetPrevWorldPos()).normalized;
                }  
            }
            
            return dir;
        }

        /// <summary>
        /// 是否需要连续检测.
        /// </summary>
        public bool IsContinue()
        {
            // 新加逻辑，外部传入用外部，外部不传用配置
            var isContinue = _damageBoxCfg.IsContinuousMode;
            if (_isContinue != null)
            {
                isContinue = _isContinue.Value;
            }

            return isContinue;
        }
    }
}