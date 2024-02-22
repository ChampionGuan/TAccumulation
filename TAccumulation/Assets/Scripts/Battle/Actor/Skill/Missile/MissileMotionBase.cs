using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using X3Battle.UnityPhysics;

namespace X3Battle
{
    public struct MotionParameter
    {
        /// <summary> 运动数据 </summary>
        public MissileMotionData missileMotionData;

        /// <summary> 形状数据 </summary>
        public ShapeBoxInfo shapeBoxInfo;

        /// <summary> 目标Actor </summary>
        public Actor targetActor;

        /// <summary> 是否需要地面碰撞检测 </summary>
        public bool needGroundCollision;

        /// <summary> 是否需要场景相机碰撞检测 </summary>
        public bool needCameraCollision;

        /// <summary> 碰到地板的回调 </summary>
        public Action<Vector3, bool> collideGroundCallback;
        
        /// <summary> 碰到场景相机的回调 </summary>
        public Action<Vector3> collideCameraCallback;
    }
    
    public class MissileMotionBase
    {
        protected ActorTransform _model;  // 子弹Actor
        protected MissileMotionData _cfg;
        protected SkillActive _missileSkill;  // 子弹技能
        protected Actor _targetActor;  // 目标
        protected float _curSpeed;
        protected Transform _missileTrans;  //子弹trans
        private Vector3? _startPos; // 初始设置一次的位置.
        public Vector3 lastPos => _startPos ?? _model.prevPosition;
        public Vector3 lastForward => _model.prevForward;

        public Transform missileTrans => _missileTrans;

        public Vector3 curPos => _model.position;
        public Vector3 curForward => _model.forward;
        
        public bool isStart { get; private set; }

        public MissileMotionData cfg => _cfg;
        
        public Battle battle { get; private set; }

        protected bool _isStopUpdate = false;
        private bool _isFallingWall;
        private float _fallingSpeedY;
        private float _fallingGravitationalAcceleration;

        private MotionParameter _motionParameter;
		// TODO 考虑封装第一次碰算碰撞的逻辑.
		private int _lastAirColliderCheckFrame = -1;
        private List<X3Collider> _lastAirColliders = new List<X3Collider>(5);
        private List<X3Collider> _tempAirColliders = new List<X3Collider>(5);
            
        private ShapeBox _shapeBox;

        public ShapeBox shapeBox
        {
            get => _shapeBox;
        }

        // 初始化
        public void Init(SkillActive missileSkill, MotionParameter motionParameter)
        {
            isStart = false;
			battle = Battle.Instance;
            _motionParameter = motionParameter;
            _cfg = motionParameter.missileMotionData;
            _fallingSpeedY = 0f;
            _isFallingWall = false;
            _model = missileSkill.actor.transform;
            _missileTrans = missileSkill.actor.GetDummy();
            _missileSkill = missileSkill;
            _targetActor = motionParameter.targetActor;
            _curSpeed = _cfg.InitialSpeed;
			_lastAirColliderCheckFrame = -1;

            if (motionParameter.shapeBoxInfo != null)
            {
                _shapeBox = new ShapeBox();
                _shapeBox.Init(motionParameter.shapeBoxInfo, new VirtualTrans(missileSkill.actor.GetDummy()));
            }

            _fallingGravitationalAcceleration = _cfg.GravitationalAcceleration;
            if (_cfg.MotionType == MissileMotionType.Curve && _cfg.CurveData.MissileCurveTraceMode == MissileCurveTraceMode.Parabola)
            {
                _fallingGravitationalAcceleration += _cfg.CurveData.GravitationalAcceleration;
            }
            
            _OnInit();
        }

        public void Start()
        {
            if (isStart)
            {
                return;
            }
            
            isStart = true;
            _OnStart();
            
            if (_cfg.AirWallCollisionType == AirWallCollisionType.Fall || _cfg.AirWallCollisionType == AirWallCollisionType.Ricochet)
            {
                var pos = BattleUtil.GetNavMeshNearestPoint(this.curPos);
                this._model.SetPosition(pos);
            }
            
            _startPos = this.curPos;
            LogProxy.LogFormat("【子弹运动】出生点： this.curPos={0}, this.curForward={1}, this.lastPos={2}, this.lastForward={3}", this.curPos, this.curForward, this.lastPos, this.lastForward);
        }

        public void Update(float deltaTime)
        {
            _curSpeed = _curSpeed + _cfg.Accelerate * deltaTime;

            if (_cfg.MaxSpeed > 0f)
            {
                if (_cfg.Accelerate < 0f && _curSpeed < _cfg.MaxSpeed)
                {
                    _curSpeed = _cfg.MaxSpeed;
                }
                else if (_cfg.Accelerate >= 0f && _curSpeed > _cfg.MaxSpeed)
                {
                    _curSpeed = _cfg.MaxSpeed;
                }
            }

            if (_isFallingWall)
            {
                _FallingFree(deltaTime);
            }
            else
            {
                if (!_isStopUpdate)
                {
                    _OnUpdate(deltaTime);
                }
                _TryCollideAirWallAndSceneEdge();
            }

            // DONE: 地面检测.
            _CheckGround();
            
            // DONE: 相机碰撞检测.
            _CheckCameraCollide();
            
            _shapeBox?.Update();
            
            if (_startPos != null)
            {
                _startPos = null;
            }
        }

        /// <summary>s
        /// 尝试空气墙和场景边缘检测，并处理响应的行为.
        /// </summary>
        /// <returns></returns>
        private bool _TryCollideAirWallAndSceneEdge()
        {
            if (_cfg.AirWallCollisionType == AirWallCollisionType.None)
            {
                return false;
            }

            bool isCollide = false;
            Vector3 normal = Vector3.zero;
            float distance = 0f;
            Vector3? noPenetrationPosition = null;
            
            // DONE: 空气墙检测
            if (_CheckAirWall(out Vector3 noPenetrationPos1, out Vector3 normal1))
            {
                isCollide = true;
                normal = normal1;
                noPenetrationPosition = noPenetrationPos1;
            }
            // DONE: 场景边缘检测.
            else if (_CheckSceneEdge(out Vector3 noPenetrationPos2, out Vector3 normal2))
            {
                isCollide = true;
                normal = normal2;
                noPenetrationPosition = new Vector3(noPenetrationPos2.x, curPos.y, noPenetrationPos2.z);
            }

            if (!isCollide)
            {
                return false;
            }

            if (_cfg.AirWallCollisionType == AirWallCollisionType.Fall)
            {
                _isFallingWall = true;
            }
            else if (_cfg.AirWallCollisionType == AirWallCollisionType.Ricochet)
            {
                // DONE: 立即将子弹设为反方向, y轴方向不变.
                var reflectedDir = Vector3.Reflect(_model.forward, normal).normalized;
                _model.SetForward(reflectedDir);
                
                // DONE: 碰撞分离.
                var pos = curPos + normal * distance;
                if (noPenetrationPosition != null)
                {
                    pos = noPenetrationPosition.Value;
                }
                _model.SetPosition(pos);

                LogProxy.LogFormat("【子弹运动】反弹修正后的朝向和位置, curForward:{0}, curPos:{1}", curForward, curPos);
            }
            
            return true;
        }

        private bool _CheckAirWall(out Vector3 noPenetrationPos, out Vector3 normal)
        {
            noPenetrationPos = Vector3.zero;
            normal = Vector3.forward;
            
            if (_shapeBox == null)
            {
                return false;
            }
            
            var prevPos = lastPos;
            var currPos = curPos;
            
            // TODO @付强, 目前物理接口要求StartCenterPos 不能与 EndCenterPos相等, 临时特殊处理一下.
            if (prevPos == currPos)
            {
                currPos = prevPos + curForward * 0.01f;
            }

            var dir = currPos - prevPos;
            _tempAirColliders.Clear();
            bool b = BattleUtil.GetNoPenetrationPos(prevPos, dir.normalized, dir.magnitude, _shapeBox.GetCurWorldEuler(), _shapeBox.GetBoundingShape(), X3LayerMask.ColliderTest,  out noPenetrationPos, out normal, ref _tempAirColliders);
            if (b)
            {
                // DONE: 上一帧与当前帧的碰撞器存在重合则不算碰撞.
                bool hasSameCollider = false;
                if (_lastAirColliderCheckFrame + 1 == battle.frameCount)
                {
                    foreach (var lastAirCollider in _lastAirColliders)
                    {
                        if (_tempAirColliders.Contains(lastAirCollider))
                        {
                            hasSameCollider = true;
                            break;
                        }
                    }
                }
                
                if (hasSameCollider)
                {
                    b = false;
                }
                
                LogProxy.LogFormat("【子弹运动】碰撞空气墙获取到的碰撞点，与墙体不在碰撞的一个点 noPenetrationPos:{0}, normal:{1}, 用于检测的prevPos:{2}, currPos:{3}, dir.normalized:{4}, dir.magnitude:{5}", noPenetrationPos, normal, prevPos, currPos, dir.normalized, dir.magnitude);
            }

            // DONE: 记录当前帧碰到的Collider.
            _lastAirColliderCheckFrame = battle.frameCount;
            _lastAirColliders.Clear();
            _lastAirColliders.AddRange(_tempAirColliders);
            _tempAirColliders.Clear();
            
            return b;    
        }

        private bool _CheckSceneEdge(out Vector3 point, out Vector3 normal)
        {
            point = Vector3.zero;
            normal = Vector3.zero;
            var astarData = AstarPath.active?.data;
            if (astarData == null)
            {
                return false;
            }
            
            var prevPos = lastPos;
            var currPos = curPos;
            if (prevPos == currPos)
            {
                currPos = prevPos + curForward * 0.01f;
            }

            bool isDetected = false;
            if (!astarData.IsCollideBoundary(new Vector2(lastPos.x, lastPos.z), new Vector2(currPos.x, currPos.z), out Vector2 interPoint, out Vector2 interNormal, out isDetected, true))
            {
                // LogProxy.Log($"没有交点:curPos.x =  {currPos.x} curPos.z: {currPos.z} lastPos.x = {lastPos.x} lastPos.z = {lastPos.z}");
                return false;
            }

            // DONE: 起点在线上，终点不在线上，且重点在寻路范围内，认为没有碰到.
            if (isDetected)
            {
                LogProxy.LogFormat("【子弹运动】往navmesh之内 出发点在线上 curPos: {0} lastPos: {1} 交点 {2} 法向量: {3}", curPos, lastPos, interPoint, interNormal);
                return false;
            }

            LogProxy.LogFormat("【子弹运动】场景边缘检测碰到墙壁交点: {0} 法向量: {1}, prevPos:{2}, currPos:{3}", interPoint, interNormal, new Vector2(lastPos.x, lastPos.z), new Vector2(currPos.x, currPos.z));
            
            point = new Vector3(interPoint.x, 0f, interPoint.y);
            normal = new Vector3(interNormal.x, 0f, interNormal.y);
            return true;
        }
        
        // 更新地板检测逻辑
        private void _CheckGround()
        {
            if (!_motionParameter.needGroundCollision)
            {
                return;
            }
            
            if (!isStart)
            {
                return;
            }
            
            var curPos = this.curPos;

            //子弹修正比例判断
            float checkValue = 0.0f;
            if (this.shapeBox != null && this.shapeBox.shapeBoxInfo.ShapeInfo.ShapeType == ShapeType.Sphere)
            {
                var moveScale = this.cfg.SphereMoveScale;
                float tempRadius = this.shapeBox.shapeBoxInfo.ShapeInfo.SphereShapeInfo.Radius;
                if (moveScale > 0.0f)
                {
                    checkValue = tempRadius * moveScale;
                    var curPosy = curPos.y - checkValue;
                    LogProxy.Log("子弹碰撞地面：没入之前 curPos.y = " + this.curPos.y + " 没入之后 curpPos.y = " + curPosy);
                    curPos = new Vector3(curPos.x, curPosy, curPos.z);
                }
            }
                
            var lastPos = this.lastPos;
            
            if (lastPos.y <= BattleUtil.GetPosY() && curPos.y > BattleUtil.GetPosY())
            {
                LogProxy.Log("特殊情况 出发点在地板 结束点在地板上 不算碰撞：curPos = " + curPos + " lastPos = " + lastPos);
                return;
            }
            
            if (!BattleUtil.RayCastGround(lastPos, curPos, out Vector3 hitGroundPos))
            {
                return;
            }
            
            // TODO 地板接口不全，和付强讨论后先这加0.001避免边界情况，后面单独出方案正规处理
            hitGroundPos.y += 0.001f;
            
            //把子弹拉回到修正比例的位置
            hitGroundPos.y += checkValue;
            LogProxy.Log("子弹碰撞地面: Y = " + hitGroundPos.y);

            bool jumpEnd = _OnJump();
            _motionParameter.collideGroundCallback?.Invoke(hitGroundPos, jumpEnd);
        }

        /// <summary> 检测相机碰撞体 </summary>
        private bool _CheckCameraCollide()
        {
            if (!_motionParameter.needCameraCollision)
            {
                return false;
            }
            
            if (_shapeBox == null)
            {
                return false;
            }
            
            Vector3 currPos = curPos;
            Vector3 prevPos = lastPos;
            bool result = X3UnityPhysics.CollisionTestOutHitPos(currPos, prevPos, _shapeBox.GetCurWorldEuler(), _shapeBox.GetBoundingShape(), true, out _, X3LayerMask.CameraColliderTest, out Vector3 hitPos);
            if (result)
            {
                _motionParameter.collideCameraCallback?.Invoke(hitPos);
            }
            
            return result;
        }

        /// <summary>
        /// 自由下落
        /// </summary>
        private void _FallingFree(float deltaTime)
        {
            float newPosY = curPos.y;
            _fallingSpeedY -= deltaTime * _fallingGravitationalAcceleration;
            newPosY += _fallingSpeedY * deltaTime;
            var fallingPos = new Vector3(curPos.x, newPosY, curPos.z);
            _model.SetPosition(fallingPos);
        }
        
        public void Stop()
        {
            isStart = false;
            _OnStop();
        }

        public void HitAny(Actor actor)
        {
            _OnHitAny(actor);
        }

        // ------------------ 提供给子类实现的方法 ---------------------------

        /// <summary>
        /// 初始化方法，不需要可以不重写
        /// </summary>
        protected virtual void _OnInit()
        {
                
        }

        /// <summary>
        /// 每次悬停结束，开始运动时会调用一次
        /// </summary>
        protected virtual void _OnStart()
        {
            
        }

        /// <summary>
        /// 每次Start之后，end之前会调用
        /// </summary>
        /// <param name="deltaTime"></param>
        protected virtual void _OnUpdate(float deltaTime)
        {
            
        }
        
        /// <summary>
        /// 每次子弹运动结束会调用一次，不需要可以不重写
        /// </summary>
        protected virtual void _OnStop()
        {
            
        }

        protected virtual void _OnHitAny(Actor actor)
        {
            
        }

        public virtual bool CanHit(Actor actor)
        {
            return true;
        }
        
        /// <summary>
        /// 每次Update之后会调用，这里需要告诉上层逻辑，自己是否结束了
        /// </summary>
        /// <returns></returns>
        public virtual bool IsComplete()
        {
            return false;
        }

        protected virtual bool _OnJump()
        {
            return true;
        }
    }
}