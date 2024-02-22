using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using CollisionQuery;
using Unity.Mathematics;
using X3Battle.UnityPhysics;

namespace X3Battle
{
    public class CollisionDetectionInfo
    {
        public ColliderTag tag;
        public Actor hitActor;
        public CqCollider hitCollider;
    }
    
    public class CollisionDetectionHitInfo : CollisionDetectionInfo
    {
        public CqRaycastHit hitInfo;
    }
    
    public static partial class X3Physics
    {
        private static HashSet<int> _noRepeatHashCodes;
        private static CqCollider[] _colliders;
        private static Dictionary<CqCollider, X3Collider> _colliderMonoCache;
        private static ReadOnlyCollection<CollisionDetectionInfo> _readOnlyInfo;
        private static List<Actor> _tempActors;
        private static float _sqrFxMaxHeight;
        private static int _maxIterCount = 3;

        static partial void _Init()
        {
            // 事先扩容
            _noRepeatHashCodes = new HashSet<int>();
            for (int i = 0; i < MaxResultNum; i++)
            {
                _noRepeatHashCodes.Add(i);
            }
            _colliders = new CqCollider[MaxResultNum];
            _colliderMonoCache = new Dictionary<CqCollider, X3Collider>();
            // 无碰撞点
            var listInfo = new List<CollisionDetectionInfo>(MaxResultNum);
            for (int i = 0; i < MaxResultNum; i++)
            {
                listInfo.Add(new CollisionDetectionHitInfo());
            }
            _readOnlyInfo = new ReadOnlyCollection<CollisionDetectionInfo>(listInfo);
            _tempActors = new List<Actor>(MaxResultNum);
            _sqrFxMaxHeight = TbUtil.battleConsts.DamageBoxFxMaxHeight * TbUtil.battleConsts.DamageBoxFxMaxHeight;
            
            X3UnityPhysics.TryInit();
        }

        static partial void _Destroy()
        {
            _colliderMonoCache = null;
            _noRepeatHashCodes = null;
            _readOnlyInfo = null;
            _tempActors = null;
            X3UnityPhysics.Destroy();
        }

        /// <summary>
        /// 物理检测： 连续检测， 非连续检测
        /// </summary>
        /// <param name="pos">当前位置</param>
        /// <param name="prevPos">连续检测开始的位置</param>
        /// <param name="rot">旋转信息</param>
        /// <param name="shape">形状属性</param>
        /// <param name="isContinuousMode">是否连续</param>
        /// <returns>碰到的所有的Actor, 注意这里的result，外部逻辑不可缓存后使用</returns>
        public static void CollisionTestNoGC(Vector3 pos, Vector3 prevPos, Vector3 rot, BoundingShape shape,
            bool isContinuousMode, int layerMask, out List<Actor> results)
        {
            using (ProfilerDefine.CollisionTestPMarker.Auto())
            {
                int hitNum = CollisionTest(pos, prevPos, rot, shape, isContinuousMode, ref _colliders, layerMask);
                _noRepeatHashCodes.Clear();
                _tempActors.Clear();
                results = _tempActors;
                for (int i = 0; i < hitNum; i++)
                {
                    var mono = GetX3Collider(_colliders[i]);
                    var actorCollider = mono as X3ActorCollider;
                    if (actorCollider == null)
                        continue;
                    var actor = actorCollider.actor;
                    if (actor == null)
                        continue;
                    if (_noRepeatHashCodes.Add(actor.insID))
                        results.Add(actor);
                }
            }
        }

        /// <summary>
        /// 物理检测： 连续检测， 非连续检测
        /// </summary>
        /// <param name="pos">当前位置</param>
        /// <param name="prevPos">连续检测开始的位置</param>
        /// <param name="rot">旋转信息</param>
        /// <param name="shape">形状属性</param>
        /// <param name="isContinuousMode">是否连续</param>
        /// <param name="result">碰到的所有的actor的碰撞信息，外部无需new</param>
        /// <returns>有效的碰撞信息的数量,注意同时可能碰到Actor上的多个Collider</returns>
        public static int CollisionTestNoGC(Vector3 pos, Vector3 prevPos, Vector3 rot, BoundingShape shape, bool isContinuousMode, out ReadOnlyCollection<CollisionDetectionInfo> result, int layerMask)
        {
            using (ProfilerDefine.CollisionTestNoGCPMarker.Auto())
            {
                int hitNum = CollisionTest(pos, prevPos, rot, shape, isContinuousMode, ref _colliders, layerMask);
                result = _readOnlyInfo;
                for (int i = 0; i < hitNum; i++)
                {
                    var x3Collider = GetX3Collider(_colliders[i]);
                    Actor actor = null;
                    if (x3Collider is X3ActorCollider x3ActorCollider)
                    {
                        actor = x3ActorCollider.actor;
                    }

                    var collisionInfo = _readOnlyInfo[i];
                    collisionInfo.tag = x3Collider != null ? x3Collider.tag : ColliderTag.Default;
                    collisionInfo.hitActor = actor;
                    collisionInfo.hitCollider = _colliders[i];
                    (collisionInfo as CollisionDetectionHitInfo).hitInfo = default(CqRaycastHit);
                }

                return hitNum;
            }
        }
        
        public static void CacheX3Collider(X3Collider x3Collider)
        {
            if (x3Collider == null || x3Collider.Collider == null)
                return;
            if (_colliderMonoCache.TryGetValue(x3Collider.Collider, out X3Collider mono))
            {
                if (mono != null && mono != x3Collider)
                {
                    PapeGames.X3.LogProxy.LogErrorFormat("异常情况：一个Collider：{0}，被两个ColliderMono缓存：{1}， {2}",
                        x3Collider.Collider.name, x3Collider.name, mono.name);
                    return;
                }
            }
            // 这里使用了缓存，优化了GetComponent的开销
            _colliderMonoCache[x3Collider.Collider] = x3Collider;
        }
        
        public static void UnCacheX3Collider(X3Collider x3Collider)
        {
            if (x3Collider == null || x3Collider.Collider == null)
                return;
            if (_colliderMonoCache == null)
                return;
            if (!_colliderMonoCache.ContainsKey(x3Collider.Collider))
                return;
            _colliderMonoCache.Remove(x3Collider.Collider);
        }
        
        /// <summary>
        /// 胶囊体碰撞获得碰撞点，并通过角色进行过滤
        /// </summary>
        /// <param name="centerPos"></param>
        /// <param name="up"></param>
        /// <param name="height"></param>
        /// <param name="radius"></param>
        /// <param name="direction"></param>
        /// <param name="moveDistance"></param>
        /// <param name="points"></param>
        /// <param name="target"></param>
        /// <param name="layerMask"></param>
        public static void CapsuleTestPoints(Vector3 centerPos, Vector3 up, float height, float radius, Vector3 direction, float moveDistance, List<Vector3> points, Actor target, int layerMask)
        {
            points.Clear();
            int hitNum = _CapsuleTest(centerPos, up, height, radius, direction, moveDistance, layerMask);
            for (int i = 0; i < hitNum; i++)
            {
                var raycastHit = _raycastHit[i];
                X3Collider x3Collider = GetX3Collider(raycastHit.Collider);
                if (x3Collider is X3ActorCollider)
                {
                    X3ActorCollider x3ActorCollider = x3Collider as X3ActorCollider;
                    if (x3ActorCollider.actor == target)
                    {
                        points.Add(raycastHit.point);
                    }
                }
            }
        }

        public static X3Collider GetX3Collider(CqCollider collider)
        {
            if (ReferenceEquals(collider, null))
                return null;
            // 这里使用了缓存，优化了GetComponent的开销
            _colliderMonoCache.TryGetValue(collider, out X3Collider mono);
            return mono;
        }
    
        public static bool IsHaveBehaviourFlag(CqCollider collider, CollisionBehavior behavior)
        {
            var mono = GetX3Collider(collider);
            if (ReferenceEquals(mono, null))
                return false;
            return (mono.flags & behavior) != 0;
        }
        
        public static bool IsHaveBehaviourFlag(X3Collider collider, CollisionBehavior behavior)
        {
            if (ReferenceEquals(collider, null))
                return false;
            return (collider.flags & behavior) != 0;
        }
        
        /// <summary>
        /// 射线检测， 默认 actor去重， collider去重
        /// 注意：
        /// 一：建议射线的起点，高度不要放在脚底，actor碰撞器大多为Capsule
        /// 二：如果起点在一个Collider内部，该Collider无法检测到
        /// </summary>
        /// <param name="layerMask">指定检测的层</param>
        /// <param name="dis">射线的最大长度</param>
        /// <returns></returns>
        public static int RayCast(Vector3 startPos, Vector3 dir, out ReadOnlyCollection<CollisionDetectionInfo> result, int layerMask, float dis=float.MaxValue)
        {
#if UNITY_EDITOR
            if (X3PhysicsDebug.isInit)
                X3PhysicsDebug.RayCast(startPos, dir, dis);
#endif
            using (ProfilerDefine.RayCastPMarker.Auto())
            {
                QueryTriggerInteraction flag = QueryTriggerInteraction.Ignore;
                result = _readOnlyInfo;
                _noRepeatHashCodes.Clear();
                int resultNum = 0;
                //int hitNum = Physics.RaycastNonAlloc(startPos,dir, _raycastHit, dis, layerMask, flag);
                int hitNum = Collision.RayCast(new CqRay(startPos, dir), dis, _raycastHit, layerMask);
                TryAddActorCollisionInfo(hitNum, ref resultNum, ref _raycastHit);
                return resultNum;
            }
        }
        
        public static int SphereCast(Vector3 startPos, Vector3 endPos, float radius, out ReadOnlyCollection<CollisionDetectionInfo> result, int layerMask, float dis=float.MaxValue)
        {
            using (ProfilerDefine.SphereCastPMarker.Auto())
            {
                QueryTriggerInteraction flag = QueryTriggerInteraction.Ignore;
                result = _readOnlyInfo;
                _noRepeatHashCodes.Clear();
                int resultNum = 0;
                Vector3 dir = endPos - startPos;
                int hitNum = Collision.SphereCast(new CqSphere(startPos, radius), dir.normalized, dir.magnitude,
                    _raycastHit, layerMask);
                TryAddActorCollisionInfo(hitNum, ref resultNum, ref _raycastHit);
                return resultNum;
            }
        }

        /// <summary>
        /// 三角形碰撞检测， 默认 actor去重， collider去重
        /// 算法：以a为顶点向对边bc发射线，数量由a角度除以角度间隔确定
        /// </summary>
        /// <param name="one"></param>
        /// <param name="two"></param>
        /// <param name="three"></param>
        /// <param name="result"></param>
        /// <param name="layerMask"></param>
        /// <returns></returns>
        public static int TriangleTest(Vector3 a, Vector3 b, Vector3 c, out ReadOnlyCollection<CollisionDetectionInfo> result, int layerMask, float angleInterval = 5)
        {
#if UNITY_EDITOR
            if (X3PhysicsDebug.isInit)
                X3PhysicsDebug.TriangleTest(a, b, c, angleInterval);
#endif
            using (ProfilerDefine.TriangleTestPMarker.Auto())
            {
                QueryTriggerInteraction flag = QueryTriggerInteraction.Ignore;
                result = _readOnlyInfo;
                _noRepeatHashCodes.Clear();
                Vector3 ab = b - a;
                Vector3 ac = c - a;
                Vector3 bc = c - b;
                Vector3 bcNorm = bc.normalized;
                float bcLen = bc.magnitude;
                float angle = Vector3.Angle(ab, ac);
                int splitNum = (int)(angle / angleInterval);
                float splitDis = bcLen / splitNum;
                int resultNum = 0;
                // 射线数量 splitNum + 1 条（包括ab， ac）
                for (int i = 0; i <= splitNum; i++)
                {
                    Vector3 rayEndPos = b + bcNorm * i * splitDis;
                    Vector3 rayDir = rayEndPos - a;
                    float dis = rayDir.magnitude;
                    //int hitNum = Physics.RaycastNonAlloc(a, rayDir, _raycastHit, dis, layerMask, flag);
                    int hitNum = Collision.RayCast(new CqRay(a, rayDir), dis, _raycastHit, layerMask);
                    TryAddActorCollisionInfo(hitNum, ref resultNum, ref _raycastHit);
                }

                //支持： 当a 如果在一个Collider内部时，无法检测到该Collider情况
                //int hitNum2 = Physics.RaycastNonAlloc(a, ab, _raycastHit, ab.magnitude, layerMask, flag);
                int hitNum2 = Collision.RayCast(new CqRay(a, ab), ab.magnitude, _raycastHit, layerMask);
                TryAddActorCollisionInfo(hitNum2, ref resultNum, ref _raycastHit);
                return resultNum;
            }
        }
        
        private static void TryAddActorCollisionInfo(int hitNum, ref int index, ref CqRaycastHit[] hitInfos)
        {
            for (int i = 0; i < hitNum; i++)
            {
                var x3Collider = GetX3Collider(hitInfos[i].Collider);
                Actor actor = null;
                if (x3Collider is X3ActorCollider x3ActorCollider)
                {
                    // 对Actor去重
                    actor = x3ActorCollider.actor;
                    if (!_noRepeatHashCodes.Add(actor.insID))
                        continue;
                }
                // 对Collider去重
                if (!_noRepeatHashCodes.Add(hitInfos[i].Collider.GetHashCode()))
                    continue;
                var collisionInfo = _readOnlyInfo[index];
                collisionInfo.tag = x3Collider != null ? x3Collider.tag : ColliderTag.Default;
                collisionInfo.hitActor = actor;
                collisionInfo.hitCollider = hitInfos[i].Collider;
                (collisionInfo as CollisionDetectionHitInfo).hitInfo = hitInfos[i];
                index ++;
            }
        }
        
        /// <summary>
        /// 从一组collider上，找出距离给定点，最近的点（如果给定点在Collider内部，则返回给定点）
        /// </summary>
        public static Vector3 GetClosestPoint(Vector3 pos, List<CollisionDetectionInfo> colliders)
        {
            int num = colliders == null ? 0 : colliders.Count;
            if (num <= 0)
            {
                return pos;
            }
            float minDis = float.MaxValue;
            Vector3 closestPoint = pos;
            for (int i = 0; i < num; i++)
            {
                var point = colliders[i].hitCollider.ClosestPoint(pos);
                float disSqr = Vector3.SqrMagnitude(pos - (Vector3)point);
                if (disSqr < minDis)
                {
                    minDis = disSqr;
                    closestPoint = point;
                }
            }
            return closestPoint;
        }
        
        /// <summary>
        /// 从一组collider上，找出距离给定点，最近的点（如果给定点在Collider内部，则既是给定点）
        /// 给定点到最近的点的向量 a，拿a在dir上投影 b,  b+pos = EndPos(投影的末端位置)
        /// 在EndPos重复上一个过程
        /// 到达迭代次数上限或使用EndPos重新取ClosetPoint
        /// </summary>
        public static Vector3 GetClosestPoint(Vector3 pos, Vector3 dir, List<CollisionDetectionInfo> colliders)
        {
            int num = colliders == null ? 0 : colliders.Count;

            if (num <= 0)
            {
                return pos;
            }
            float minDis = float.MaxValue;
            Vector3 closestPoint = pos;
            CqCollider closeCollider = null;

            for (int i = 0; i < num; i++)
            {
                var point = colliders[i].hitCollider.ClosestPoint(pos);
                float disSqr = Vector3.SqrMagnitude(pos - (Vector3)point);
                if (disSqr < minDis)
                {
                    minDis = disSqr;
                    closestPoint = point;
                    closeCollider = colliders[i].hitCollider;
                }
            }

            if (closeCollider != null)
            {
                for (int j = 0; j < _maxIterCount; j++)
                {
                    var a = closestPoint - pos;
                    var b = Vector3.Project(a, dir);

                    pos += b;
                    closestPoint = closeCollider.ClosestPoint(pos);
                    if (a.sqrMagnitude - b.sqrMagnitude <= _sqrFxMaxHeight)
                        break;
                }
            }

            return closestPoint;
        }

        public static bool CheckShapeValid(BoundingShape shape, LogType type = LogType.Error)
        {
            if (shape == null)
                return false;
            var shapeType = shape.ShapeType;
            bool isValid = false;
            switch (shapeType)
            {
                case ShapeType.Capsule:
                    isValid = shape.Radius > 0 && shape.Height >= shape.Radius * 2;
                    break;
                case ShapeType.Cube:
                    isValid = shape.Length > 0 && shape.Width > 0 && shape.Height > 0;
                    break;
                case ShapeType.Ray:
                    isValid = shape.Length > 0;
                    break;
                case ShapeType.Sphere:
                    isValid = shape.Radius >= 0;
                    break;
                case ShapeType.FanColumn:
                    isValid = shape.Angle > 0 && shape.Radius > 0;
                    break;
                case ShapeType.RingFanColumn:
                    isValid = shape.Angle > 0 && shape.Radius > 0 && shape.Length > 0;
                    break;
                default:
                    LogProxy.LogErrorFormat("形状参数合法性检测失败，不支持的类型：{0}", shape.ShapeType);
                    return true;
            }
            if (!isValid)
            {
                string errorInfo = "";
                switch (shapeType)
                {
                    case ShapeType.Capsule:
                        var str = "BoundShape参数无效(高度>=半径的二倍),Type:{0},Radius:{1}, Height:{2}";
                        errorInfo = string.Format(str, shapeType, shape.Radius, shape.Height);
                        break;
                    case ShapeType.Cube:
                        str= "BoundShape参数无效,Type:{0},Length:{1}, Width:{2}, Height:{3}";
                        errorInfo = string.Format(str, shapeType, shape.Length, shape.Width, shape.Height);
                        break;
                    case ShapeType.Ray:
                        str = "BoundShape参数无效,Type:{0},Length:{1}";
                        errorInfo = string.Format(str, shapeType, shape.Length);
                        break;
                    case ShapeType.Sphere:
                        str = "BoundShape参数无效,Type:{0},Radius:{1}";
                        errorInfo = string.Format(str, shapeType, shape.Radius);
                        break;
                    case ShapeType.FanColumn:
                        str = "BoundShape参数无效,Type:{0},Radius:{1},Angle:{2}";
                        errorInfo = string.Format(str, shapeType, shape.Radius, shape.Angle);
                        break;
                    case ShapeType.RingFanColumn:
                        str = "BoundShape参数无效,Type:{0},Radius:{1},Angle:{2},内径:{3}";
                        errorInfo = string.Format(str, shapeType, shape.Radius, shape.Angle, shape.Length);
                        break;
                }

                switch (type)
                {
                    case LogType.Error:
                        LogProxy.LogError(errorInfo);
                        break;
                    case LogType.Warning:
                        LogProxy.LogWarning(errorInfo);
                        break;
                    case LogType.Log:
                        LogProxy.Log(errorInfo);
                        break;
                    default:
                        LogProxy.LogError(errorInfo);
                        break;
                }
            }
            return isValid;
        }

        public static bool CheckShapeValid(ShapeInfo shapeInfo)
        {
            if (shapeInfo == null)
            {
                return false;
            }

            bool isValid = false;
            switch (shapeInfo.ShapeType)
            {
                case ShapeType.Capsule:
                    isValid = shapeInfo.CapsuleShapeInfo != null && shapeInfo.CapsuleShapeInfo.Radius > 0 && shapeInfo.CapsuleShapeInfo.Height >= shapeInfo.CapsuleShapeInfo.Radius * 2;
                    break;
                case ShapeType.Cube:
                    isValid = shapeInfo.CubeShapeInfo != null && shapeInfo.CubeShapeInfo.Length > 0 && shapeInfo.CubeShapeInfo.Width > 0 && shapeInfo.CubeShapeInfo.Height > 0;
                    break;
                case ShapeType.FanColumn:
                    isValid = shapeInfo.FanColumnShapeInfo != null && shapeInfo.FanColumnShapeInfo.Angle > 0 && shapeInfo.FanColumnShapeInfo.Radius > 0;
                    break;
                case ShapeType.Sphere:
                    isValid = shapeInfo.SphereShapeInfo != null && shapeInfo.SphereShapeInfo.Radius >= 0;
                    break;
                case ShapeType.Ray:
                    isValid = shapeInfo.RayShapeInfo != null && (shapeInfo.RayShapeInfo.Length > 0 || shapeInfo.RayShapeInfo.Length == -1f);
                    break;
                case ShapeType.RingFanColumn:
                    isValid = shapeInfo.RingShapeInfo != null && shapeInfo.RingShapeInfo.Angle > 0 && shapeInfo.RingShapeInfo.InnerRadius > 0 && shapeInfo.RingShapeInfo.OuterRadius > 0;
                    break;
                default:
                    isValid = false;
                    break;
            }

            #region 抛错误信息

            if (!isValid)
            {
                string errorInfo = "";
                switch (shapeInfo.ShapeType)
                {
                    case ShapeType.Capsule:
                        
                        if (shapeInfo.CapsuleShapeInfo == null)
                        {
                            errorInfo = "请联系【程序】排查, 胶囊体的形状数据==null";
                        }
                        else
                        {
                            var str = "BoundShape参数无效(高度>=半径的二倍),Type:{0},Radius:{1}, Height:{2}";    
                            errorInfo = string.Format(str, shapeInfo.ShapeType, shapeInfo.CapsuleShapeInfo.Radius, shapeInfo.CapsuleShapeInfo.Height);    
                        }
                        break;
                    case ShapeType.Cube:
                        if (shapeInfo.CubeShapeInfo == null)
                        {
                            errorInfo = "请联系【程序】排查, 立方体的形状数据==null";
                        }
                        else
                        {
                            var str = "BoundShape参数无效,Type:{0},Length:{1}, Width:{2}, Height:{3}";
                            errorInfo = string.Format(str, shapeInfo.ShapeType, shapeInfo.CubeShapeInfo.Length, shapeInfo.CubeShapeInfo.Width, shapeInfo.CubeShapeInfo.Height);
                        }
                        break;
                    case ShapeType.Ray:
                        if (shapeInfo.RayShapeInfo == null)
                        {
                            errorInfo = "射线的形状数据==null";
                        }
                        else
                        {
                            var str = "请联系【程序】排查, BoundShape参数无效,Type:{0},Length:{1}";
                            errorInfo = string.Format(str, shapeInfo.ShapeType, shapeInfo.RayShapeInfo.Length);
                        }
                        break;
                    case ShapeType.Sphere:
                        if (shapeInfo.SphereShapeInfo == null)
                        {
                            errorInfo = "请联系【程序】排查, 球体的形状数据==null";
                        }
                        else
                        {
                            var str = "BoundShape参数无效,Type:{0},Radius:{1}";
                            errorInfo = string.Format(str, shapeInfo.ShapeType, shapeInfo.SphereShapeInfo.Radius);
                        }
                        break;
                    case ShapeType.FanColumn:
                        if (shapeInfo.FanColumnShapeInfo == null)
                        {
                            errorInfo = "请联系【程序】排查, 扇形柱体的形状数据=null";
                        }
                        else
                        {
                            var str = "BoundShape参数无效,Type:{0},Radius:{1},Angle:{2}";
                            errorInfo = string.Format(str, shapeInfo.ShapeType, shapeInfo.FanColumnShapeInfo.Radius, shapeInfo.FanColumnShapeInfo.Angle);
                        }
                        break;
                    case ShapeType.RingFanColumn:
                        if (shapeInfo.RingShapeInfo == null)
                        {
                            errorInfo = "请联系【程序】排查, 环扇形的形状数据==null";
                        }
                        else
                        {
                            var str = "BoundShape参数无效,Type:{0},Radius:{1},Angle:{2},内径:{3}";
                            errorInfo = string.Format(str, shapeInfo.ShapeType, shapeInfo.RingShapeInfo.OuterRadius, shapeInfo.RingShapeInfo.Angle, shapeInfo.RingShapeInfo.InnerRadius);    
                        }
                        break;
                    default:
                        errorInfo = $"请联系【程序】排查, 无此形状类型 {(int)shapeInfo.ShapeType}";
                        break;
                }

                if (Application.isPlaying)
                {
                    LogProxy.LogError(errorInfo);
                }
                else
                {
                    LogProxy.LogError(errorInfo);
                }
            }

            #endregion

            return isValid;
        }
        
        /// <summary>
        /// 参数和上面的接口一致， 直接返回碰撞结果，不做额外处理
        /// StartCenterPos 不能与 EndCenterPos 相等.
        /// </summary>
        /// <returns></returns>
        public static int CollisionTestWithCollisionInfo(Vector3 startCenterPos, Vector3 endCenterPos, Quaternion rot, BoundingShape shape, out CqRaycastHit[] result, int layerMask)
        {
#if UNITY_EDITOR
            if (debugModel && X3PhysicsDebug.isInit) // debug 模式
            {
                // 注意这里的调试，只能代表 StartCenterPos == EndCenterPos
                // TODO 考虑支持连续碰撞检测的Debug 调试
                int UUID = shape.GetHashCode();
                X3PhysicsDebug.Ins.TryCreateShape(UUID, ShapeUseType.PhysicTest, shape);
                X3PhysicsDebug.Ins.UpdateShapePos(UUID, ShapeUseType.PhysicTest, startCenterPos, rot.eulerAngles);
            }
            CheckShapeValid(shape);
#endif
            if (startCenterPos == endCenterPos)
            {
                LogProxy.LogError("不支持起始一致，将无法获取碰撞信息");
            }
            
            ShapeType type = shape.ShapeType;
            QueryTriggerInteraction flag = QueryTriggerInteraction.Ignore;
            Vector3 dir = (endCenterPos - startCenterPos).normalized;
            float moveDis = Vector3.Distance(startCenterPos, endCenterPos);    
            
            int hitNum = 0;
            switch (type)
            {
                case ShapeType.Cube:
                    Vector3 half = new Vector3(shape.Length * 0.5f, shape.Height * 0.5f, shape.Width * 0.5f);
                    hitNum = Collision.BoxCast(new CqBox(new RigidTransform(rot, startCenterPos), half), dir, moveDis, _raycastHit,layerMask);
                    break;
                case ShapeType.Sphere:
                    hitNum = Collision.SphereCast(new CqSphere(startCenterPos, shape.Radius), dir, moveDis, _raycastHit,layerMask);
                    break;
                case ShapeType.Capsule:
                    Vector3 localUp = (rot * Vector3.up).normalized;
                    float len = (shape.Height - shape.Radius * 2) * 0.5f;
                    Vector3 point0 = startCenterPos + localUp * len;
                    Vector3 point1 = startCenterPos - localUp * len;
                    hitNum = Collision.CapsuleCast(new CqCapsule(point0, point1, shape.Radius), dir, moveDis, _raycastHit,layerMask);
                    break;
                case ShapeType.Ray:
                    dir = rot * Vector3.forward;
                    float  rayLen = shape.Length < 0 ? float.MaxValue : shape.Length;
                    hitNum = Collision.RayCast(new CqRay(endCenterPos, dir), rayLen, _raycastHit,layerMask);
                    break;
                default:
                    PapeGames.X3.LogProxy.LogErrorFormat("该形状：{0}, 不支持进行获取碰撞信息的检测", type);
                    break;
            }

            result = _raycastHit;
            return hitNum;
        }
        
    }
}