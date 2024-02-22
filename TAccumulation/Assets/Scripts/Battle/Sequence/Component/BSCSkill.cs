using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using PapeGames.X3;
using UnityEngine;
using X3Battle.UnityPhysics;

namespace X3Battle
{
    public class BSCSkill: BSCBase, IReset
    {
        private bool _needEvalCoopPos;
        private bool _isBoyCoopSkill;
        public bool enableCamera { get; private set; } = true;
        
        private BoundingShape _coopSkillUseShape = new BoundingShape()
        {
            ShapeType = ShapeType.Sphere,
            Radius =  0.01f,
        };

        public void Reset()
        {
            _needEvalCoopPos = false;
            _isBoyCoopSkill = false;
            enableCamera = true;
        }
        
        protected override void _OnInit()
        {
            _BuildEvalCoopSkill();
        }

        public void Replay()
        {
            // TODO: 长空后面再整理下
            var actionContext = _battleSequencer.bsCreateData.bsActionContext;
            var skill = actionContext?.skill;
            var actor = actionContext?.actor;
            if(actor.IsBoy() && (skill.GetSkillType() == SkillType.EXMaleActive || skill.GetSkillType() == SkillType.MaleActive))
            {
                // 如果是男主主动/QTE技能
                enableCamera = _GetCoopCameraEnable(actionContext.actor, actionContext.skill);
                _EnableCoopCamera(enableCamera);
            }

            if (_needEvalCoopPos)
            {
                actionContext = _battleSequencer.bsCreateData.bsActionContext;
                _EvalCoopGirlPosForward(actionContext.actor, actionContext.skill);
                enableCamera = _GetCoopCameraEnable(actionContext.actor, actionContext.skill);
                _EnableCoopCamera(enableCamera);
            }

            if (_isBoyCoopSkill)
            {
                // 男主用女主的
                var girl = Battle.Instance.actorMgr.girl;
                if (girl != null)
                {
                    var curSkill = girl.skillOwner.currentSlot?.skill;
                    if (curSkill != null && curSkill.config.Type == SkillType.Coop)
                    {
                        var skillTime = curSkill as SkillTimeline;
                        var curSequencer = skillTime.curBattleSequencer;
                        if (curSequencer != null)
                        {
                            var girlBSCSkill = curSequencer.GetComponent<BSCSkill>();
                            if (girlBSCSkill != null)
                            {
                                enableCamera = girlBSCSkill.enableCamera;
                                _EnableCoopCamera(enableCamera);
                            }
                        }
                    }
                }
            }
        }

        // getCoopCameraEnabled
        public bool _GetCoopCameraEnable(Actor actor, SkillActive skill)
        {
            if (actor == null || skill == null)
            {
                return true;
            }

            var config = skill.config;
            if (config.CameraCollisionPoint != null && config.CameraCollisionPoint.Length > 0)
            {
                var skillCastActorPos = skill.actor.transform.position;
                var skillCastActorForward = skill.actor.transform.forward;
                foreach (var offsetPos in config.CameraCollisionPoint)
                {
                    var localOffset = Quaternion.LookRotation(skillCastActorForward) * offsetPos;
                    var pos = skillCastActorPos + localOffset;
#if UNITY_EDITOR
                    X3PhysicsDebug.AddCameraTestShape(pos, Vector3.zero, _coopSkillUseShape);
                    Debug.DrawLine(pos, skillCastActorPos, Color.red, 1f);
#endif
                    // TODO：后面cameraCollider换成新版物理后，把该接口也换成新版物理 by:sanxi
                    if (Physics.Raycast(new Ray(skillCastActorPos, localOffset.normalized), out var infos, localOffset.magnitude, X3LayerMask.CameraColliderTest))
                    {
                        LogProxy.Log($"【技能】共鸣技选点禁用相机, SkillCfg.ID={config.ID}, OffsetPos={offsetPos}");
                        return false;
                    }
                }
            }
            
            return true;
        }
        
        
        // 处理共鸣技相机
        private void _EnableCoopCamera(bool enable)
        {
            var cameraCom = _battleSequencer.GetComponent<BSCControlCamera>();
            if (cameraCom != null)
            {
                cameraCom.SetCameraGroupEnable(enable);
            }
        }
        
        // 处理共鸣技
        private void _BuildEvalCoopSkill()
        {
            var actionContext = _battleSequencer.bsCreateData.bsActionContext;
            var skill = actionContext?.skill;
            var actor = actionContext?.actor;
            // 有actor和skill，并且是主角单位，并且是共鸣技
            if (skill != null && actor != null && actor.type == ActorType.Hero && skill.config.Type == SkillType.Coop)
            {
                if (skill.config.CoopSetPos)
                {
                    _needEvalCoopPos = true;
                }
                if (actor.subType == (int)HeroType.Girl)
                {
                    // 策划定的明规则：女主共鸣技能处理：如果男主和女主共鸣技是一个美术部分，则只播男主，否则男女主都播)
                    bool onlyBoy = false;
                    BattleEnv.StartupArg.cacheBornCfgs.TryGetValue(BattleEnv.StartupArg.boyID, out var cacheBoyCfg);
                    var boySkillSlots = cacheBoyCfg != null ? cacheBoyCfg.SkillSlots : null;
                    if (boySkillSlots == null)
                    {
                        TbUtil.TryGetCfg(BattleEnv.StartupArg.boyID, out BoyCfg staticBoyCfg);
                        if (staticBoyCfg != null)
                        {
                            boySkillSlots = staticBoyCfg.SkillSlots;
                        }
                    }
                    if (boySkillSlots != null)
                    {
                        var slotID = BattleUtil.GetSlotID(SkillSlotType.Coop, 0);
                        boySkillSlots.TryGetValue(slotID, out var boySlotCfg);
                        if (boySlotCfg != null)
                        {
                            var skillCfg = TbUtil.GetCfg<SkillCfg>(boySlotCfg.SkillID);
                            if (skillCfg != null)
                            {
                                var boyModules = skillCfg.ActionModuleIDs;
                                if (boyModules != null && boyModules.Length > 0)
                                {
                                    var boyModule = boyModules[0];
                                    var moduleCfg = TbUtil.GetCfg<ActionModuleCfg>(boyModule);
                                    if (moduleCfg != null && moduleCfg.ArtTimeline == _battleSequencer.bsCreateData.artResPath)
                                    {
                                        onlyBoy = true;
                                    }
                                }
                            }
                        }
                    }
                    if (onlyBoy)
                    {
                        _battleSequencer.bsCreateData.artResPath = null;
                    }
                }
                else if(actor.subType == (int)HeroType.Boy)
                {
                    // 男主共鸣技能关闭强制绑定actor模式，转而从场上取
                    _isBoyCoopSkill = true;
                    var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
                    bindCom.notBindCreator = true;
                    bindCom.manModel = actor.GetDummy(ActorDummyType.Model).gameObject;
                    bindCom.womanModel = null == actor.battle.actorMgr.girl ? null : actor.battle.actorMgr.girl.GetDummy(ActorDummyType.Model).gameObject;
                }
            }
        }
        
        private static List<PointInfo> _pointInfos = new List<PointInfo>(8);
        private static List<MeshPointInfo> _meshPointInfos = new List<MeshPointInfo>(8);
        private static List<MeshPointInfo> _temp1MeshPoint = new List<MeshPointInfo>(8);
        private static List<MeshPointInfo> _temp2MeshPoint = new List<MeshPointInfo>(8);

        private void _EvalCoopGirlPosEmpty(Actor actor, SkillActive skill)
        {
            var skillCfg = skill.config;
            var curPos = actor.transform.position;
            var newPos = BattleUtil.GetNavmeshPos(curPos, skillCfg.CoopPlayRadius,true);
            actor.transform.SetPosition(newPos, true);
            // skill.RefreshCastPosForward();
        }
        
        private void _EvalCoopGirlPosForward(Actor actor, SkillActive skill)
        {
            var skillCfg = skill.config;
            // 只有配了CoopSetPos才需要拉
            var targetActor = actor.GetTarget(TargetType.Skill);
            if (targetActor == null)
            {
                // 没有目标空放的话，取一个合适的寻路点
                _EvalCoopGirlPosEmpty(actor, skill);
                return;
            }

            if (skillCfg.CoopAttackRadius <= 0)
            {
                // 攻击半径是0的话，策划认为是个纯表演共鸣技，取一个合适的寻路点即可
                _EvalCoopGirlPosEmpty(actor, skill);
                return;
            }
            
            // s1: 首先确定优先级从高到低的八个点
            var attackRadius = skillCfg.CoopAttackRadius + actor.radius + targetActor.radius;
            foreach (var pointInfo in _pointInfos)
            {
                ObjectPoolUtility.PointInfo.Release(pointInfo);   
            }
            _pointInfos.Clear();
            var targetPos = targetActor.transform.position;
            targetPos.y = 0;
            var actorPos = actor.transform.position;
            actorPos.y = 0;
            var axisZ = (actorPos - targetPos).normalized;
            var axisX = Vector3.Cross(Vector3.up, axisZ);
            for (int i = 0; i < MathConst.directions8.Length; i++)
            {
                var localDirect = MathConst.directions8[i];  // 局部方向
                var worldDirect = localDirect.x * axisX + localDirect.z * axisZ;  // 世界方向
                var preOriginPoint = targetPos + worldDirect * attackRadius;  // 世界原点
               
                // 世界坐标点修正
                var trueMonsterRadius = BattleUtil.GetMonsterRadius(actor, preOriginPoint, targetActor);
                var trueAttackRadius = skillCfg.CoopAttackRadius + actor.radius + trueMonsterRadius;
                var originPoint = targetPos + worldDirect * trueAttackRadius;
                
                var pointInfo = ObjectPoolUtility.PointInfo.Get();
                pointInfo.pos = originPoint;
                pointInfo.forward = -worldDirect;

                //todo 如果给定的点不对 排除 二次后修改
                if (!BattleUtil.IsRightPoint(pointInfo.pos, actor.transform.position))
                {
                    continue;
                }
                
                // 导航网格的合法点
                var validMeshPos = BattleUtil.GetNavmeshPos(pointInfo.pos, skillCfg.CoopPlayRadius, true);
                pointInfo.validMeshPos = validMeshPos;
                if (BattleUtil.IsRightPoint(validMeshPos, actor.transform.position) && pointInfo.pos == validMeshPos)
                {
                    pointInfo.isNavMeshValid = true;
                    var rightDirect = Vector3.Cross(Vector3.up, pointInfo.forward);
                    var offset = rightDirect * skillCfg.CoopPlayRadius;
                    var leftPos = pointInfo.pos - offset;
                    var rightPos = pointInfo.pos + offset;
                    
                    // 检测演出半径（半球）
                    var shape = new BoundingShape();
                    shape.ShapeType = ShapeType.Sphere;
                    shape.Radius = skillCfg.CoopPlayRadius;
                    if (X3Physics.CheckShapeValid(shape, LogType.Warning))
                    {
                        // 形状合法才进行检测
                        X3Physics.CollisionTestNoGC(originPoint, originPoint, Vector3.zero, shape, false, out var collisionInfo, X3LayerMask.ColliderTest);
                        _EvalEnemyAndWallValid(actor, targetActor, collisionInfo, out pointInfo.isAreaEnemyValid, out pointInfo.isAreaWallValid);   
                    }
                    
                    // 检测补充演出区三角形
                    X3Physics.TriangleTest(leftPos, rightPos, targetPos, out var collisionInfo2, X3LayerMask.ColliderTest);
                    _EvalEnemyAndWallValid(actor, targetActor, collisionInfo2, out pointInfo.isAreaEnemyValid2, out pointInfo.isAreaWallValid2);
                }
                _pointInfos.Add(pointInfo);
                
                if (pointInfo.isAllValid())
                {
                    // 筛选出三个都ok的点直接返回，不用再生成后面的了
                    // var trans = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
                    // trans.position = pointInfo.pos;
                    // trans.localScale = new Vector3(0.5f, 0.5f, 0.5f);
                    _SetCoopActorPos(actor, skill, pointInfo.pos, pointInfo.forward);
                    return;
                }
            }
            
            // s2：选表演区域补充表演区域没有碰撞点
            for (int i = 0; i < _pointInfos.Count; i++)
            {
                var pointInfo = _pointInfos[i];
                if (pointInfo.isNavMeshValid && pointInfo.isPlayAreaValid())
                {
                    _SetCoopActorPos(actor, skill, pointInfo.pos, pointInfo.forward);
                    return;
                }
            }
            
            // s3：选择演出区域没有空气墙的点
            for (int i = 0; i < _pointInfos.Count; i++)
            {
                var pointInfo = _pointInfos[i];
                if (pointInfo.isNavMeshValid && pointInfo.isAreaWallValid)
                {
                    _SetCoopActorPos(actor, skill, pointInfo.pos, pointInfo.forward);
                    return;
                }
            }
            
            // s4：走到这里就说明八个点都不符合要求，要用挤出选点
            // s4.1: 构造挤出点
            foreach (var info in _meshPointInfos)
            {
                ObjectPoolUtility.MeshPointInfo.Release(info);    
            }
            _meshPointInfos.Clear();
            _temp1MeshPoint.Clear();
            _temp2MeshPoint.Clear();
            
            for (int i = 0; i < _pointInfos.Count; i++)
            {
                var pointInfo = _pointInfos[i];
                var meshPointInfo = ObjectPoolUtility.MeshPointInfo.Get();
                meshPointInfo.oldPos = pointInfo.pos;
                meshPointInfo.meshPos = pointInfo.validMeshPos;
                var offset = targetPos - pointInfo.validMeshPos;
                offset.y = 0;
                meshPointInfo.meshForward = offset.normalized;
                _meshPointInfos.Add(meshPointInfo);
            }
            
            // s4.2 按照距离筛选
            float curMinDistance = float.MaxValue;
            for (int i = 0; i < _meshPointInfos.Count; i++)
            {
                var meshPoint = _meshPointInfos[i];
                var curDistance = meshPoint.GetSqrDistance();
                if (curDistance <= curMinDistance)
                {
                    if (curDistance < curMinDistance)
                    {
                        curMinDistance = curDistance;
                        _temp1MeshPoint.Clear();
                    }
                    _temp1MeshPoint.Add(meshPoint);
                }
            }

            if (_temp1MeshPoint.Count == 1)
            {
                var pointInfo = _temp1MeshPoint[0];
                _SetCoopActorPos(actor, skill, pointInfo.meshPos, pointInfo.meshForward);
                return;
            }
            
            // s4.3 按照瞬移角度筛选
            float curMaxCos = 0;
            var actorForward = actor.transform.forward;
            for (int i = 0; i < _temp1MeshPoint.Count; i++)
            {
                var meshPoint = _temp1MeshPoint[i];
                var toMeshForward = (meshPoint.meshPos - actorPos).normalized;
                var curCos = Vector3.Dot(actorForward, toMeshForward);
                if (curCos >= curMaxCos)
                {
                    if (curCos > curMaxCos)
                    {
                        curMaxCos = curCos;
                        _temp2MeshPoint.Clear();
                    }
                    _temp2MeshPoint.Add(meshPoint);
                }
            }

            if (_temp2MeshPoint.Count == 1)
            {
                var pointInfo = _temp2MeshPoint[0];
                _SetCoopActorPos(actor, skill, pointInfo.meshPos, pointInfo.meshForward);
                return;
            }
            
            // s4.4 按照顺逆时针选、
            for (int i = 0; i < _temp2MeshPoint.Count; i++)
            {
                var meshPoint = _temp2MeshPoint[i];
                var toMeshForward = (meshPoint.meshPos - actorPos).normalized;
                var crossValue = actorForward.z * toMeshForward.x - actorForward.x * toMeshForward.z;
                if (crossValue > 0)
                {
                    _SetCoopActorPos(actor, skill, meshPoint.meshPos, meshPoint.meshForward);   
                }
            }
            
            //todo 二测后修改
            if (_temp2MeshPoint.Count > 0)
            {
                _SetCoopActorPos(actor, skill, _temp2MeshPoint[0].meshPos, _temp2MeshPoint[0].meshForward);
            }
        }

        
        private void _SetCoopActorPos(Actor actor, SkillActive skill, Vector3 pos, Vector3 forward)
        {
            actor.transform.SetPosition(pos, true);
            actor.transform.SetForward(forward);
            // skill.RefreshCastPosForward();
        }

        private void _EvalEnemyAndWallValid(Actor actor, Actor ignoreActor, ReadOnlyCollection<CollisionDetectionInfo> collisionInfo, out bool isAreaEnemyValid, out bool isAreaWallValid)
        {
            isAreaWallValid = true;
            isAreaEnemyValid = true;

            for (var i = 0; i < collisionInfo.Count; i++)
            {
                var collision = collisionInfo[i];
                if (collision.tag == ColliderTag.AirWall)
                {
                    // 有空气墙，标记为非法
                    isAreaWallValid = false;
                }

                if (collision.hitActor != null && collision.hitActor != ignoreActor)
                {
                    var relation = actor.GetFactionRelationShip(collision.hitActor);
                    if (relation == FactionRelationship.Enemy)
                    {
                        // 有目标之外的敌人，标记为非法
                        isAreaEnemyValid = false;
                    }
                }
            }
        }

        public class MeshPointInfo: IReset
        {
            public Vector3 oldPos;

            public Vector3 meshPos;
            public Vector3 meshForward;

            public void Reset()
            {
                oldPos = Vector3.zero;
                meshPos = Vector3.zero;
                meshForward = Vector3.zero;
            }
            
            public float GetSqrDistance()
            {
                var offset = meshPos - oldPos;
                return offset.sqrMagnitude;
            }
        }
        
        public class PointInfo: IReset
        {
            public Vector3 pos;
            public Vector3 forward;
            public Vector3 validMeshPos;
            public bool isNavMeshValid;
            public bool isAreaEnemyValid;
            public bool isAreaWallValid;
            public bool isAreaEnemyValid2;
            public bool isAreaWallValid2;

            public void Reset()
            {
                pos = Vector3.zero;
                forward = Vector3.zero;
                validMeshPos = Vector3.zero;
                isNavMeshValid = false;
                isAreaEnemyValid = false;
                isAreaWallValid = false;
                isAreaEnemyValid2 = false;
                isAreaWallValid2 = false;
            }
            
            // 全部ok
            public bool isAllValid()
            {
                return isNavMeshValid && isAreaEnemyValid && isAreaWallValid && isAreaEnemyValid2 && isAreaWallValid2;
            }

            // 表演区域OK
            public bool isPlayAreaValid()
            {
                return isNavMeshValid && isAreaEnemyValid && isAreaWallValid;
            }
        }
    }
}