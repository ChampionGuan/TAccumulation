using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle.UnityPhysics
{
    public struct CircleData
    {
        public Vector3 pos; // 圆心
        public float radius; // 半径
        public Collider Collider;
        public bool remove;

        public CircleData(Vector3 pos, float radius, Collider collider)
        {
            this.pos = pos;
            this.radius = radius;
            this.Collider = collider;
            remove = false;
        }
    }
    
    public static partial class X3UnityPhysics
    {
        // 最大值的解释：最大目标数量Actor*单个Actor上的HurtBox的数量
        private const int MaxResultNum = 100;
        private static Collider[] _colliders;
        private static List<Collider> _tempColliders;
        private static List<CircleData> _tempCircles;
        private static RaycastHit[] _raycastHit;
        private static BoundingShape _tempCubeShape = new BoundingShape();
        
        # if UNITY_EDITOR
        static X3UnityPhysics()
        {
            TryInit();
        }
        #endif

        public static void TryInit()
        {
            if (_tempColliders != null)
                return;
            _colliders = new Collider[MaxResultNum];
            _tempColliders = new List<Collider>(MaxResultNum);
            _tempCircles = new List<CircleData>(MaxResultNum);
            _raycastHit = new RaycastHit[MaxResultNum];
        }

        public static void Destroy()
        {
            _colliders = null;
            _tempColliders = null;
            _tempCircles = null;
            _raycastHit = null;
        }
        
        /// <summary>
        /// 物理检测： 连续检测， 非连续检测
        /// ！！！！！！！！注意！！！！！！！！
        /// 因对接了新版物理后，Unity的物理更新进入战斗后已经关掉，且Collider组件也换成了新版的组件
        /// 所以通过Unity的接口只能检测静态的Unity的Collider组件
        /// </summary>
        /// <param name="pos">当前位置</param>
        /// <param name="prevPos">连续检测开始的位置</param>
        /// <param name="rot">旋转信息</param>
        /// <param name="shape">形状属性</param>
        /// <param name="isContinuousMode">是否连续</param>
        /// <param name="result">碰到的所有的actor的碰撞信息，外部无需new</param>
        /// <returns>有效的碰撞信息的数量,注意同时可能碰到Actor上的多个Collider</returns>
        public static int CollisionTestNoGC(Vector3 pos, Vector3 prevPos, Vector3 rot, BoundingShape shape, bool isContinuousMode, out Collider[] result, int layerMask)
        {
            using (ProfilerDefine.X3UnityPhysicsCollisionTestNoGCPMarker.Auto())
            {
                int hitNum = CollisionTest(pos, prevPos, rot, shape, isContinuousMode, ref _colliders, layerMask);
                result = _colliders;
                return hitNum;
            }
        }
        
        /// <summary>
        /// 从一组collider上，找出距离给定点，最近的点（如果给定点在Collider内部，则返回给定点）
        /// </summary>
        public static Vector3 GetClosestPoint(Vector3 pos, List<Collider> colliders)
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
                var point = colliders[i].ClosestPoint(pos);
                float disSqr = Vector3.SqrMagnitude(pos - point);
                if (disSqr < minDis)
                {
                    minDis = disSqr;
                    closestPoint = point;
                }
            }
            return closestPoint;
        }
        
        /// <summary>
        /// 从一组collider上，找出距离给定点，最近的点（如果给定点在Collider内部，则返回给定点）
        /// </summary>
        public static Vector3 GetClosestPoint(Vector3 pos, Collider[] colliders, int hitNum)
        {
            int num = colliders == null ? 0 : colliders.Length;
            num = Mathf.Min(hitNum, num);
            if (num <= 0)
            {
                return pos;
            }

            float minDis = float.MaxValue;
            Vector3 closestPoint = pos;
            for (int i = 0; i < num; i++)
            {
                var collider = colliders[i];
                if (collider == null)
                {
                    continue;
                }
                var point = collider.ClosestPoint(pos);
                float disSqr = Vector3.SqrMagnitude(pos - point);
                if (disSqr < minDis)
                {
                    minDis = disSqr;
                    closestPoint = point;
                }
            }
            return closestPoint;
        }
        
        public static bool CollisionTestOutHitPos(Vector3 pos, Vector3 prevPos, Vector3 rot, BoundingShape shape, bool isContinuousMode, out Collider[] result, int layerMask, out Vector3 hitPos)
        {
            int hitNum = CollisionTestNoGC(pos, prevPos, rot, shape, isContinuousMode, out result, layerMask);
            hitPos = GetClosestPoint(pos, result, hitNum);
            return hitNum > 0;
        }
        
        /// <summary>
        /// 物理检测： 连续检测， 非连续检测
        /// </summary>
        /// <param name="pos">当前位置</param>
        /// <param name="prevPos">连续检测开始的位置</param>
        /// <param name="rot">旋转信息</param>
        /// <param name="shape">形状属性</param>
        /// <param name="isContinuousMode">是否连续</param>
        /// <param name="colliders">碰到的所有的collider</param>
        /// <returns></returns>
        public static int CollisionTest(Vector3 centPos, Vector3 prevCenterPos, Vector3 rot, BoundingShape shape, bool isContinuousMode, ref Collider[] colliders, int layerMask)
        {
#if UNITY_EDITOR
            if (X3Physics.debugModel && X3PhysicsDebug.isInit) // debug 模式
            {
                int UUID = shape.GetHashCode();
                ContinuousArg arg = null;
                if (isContinuousMode && prevCenterPos != centPos)
                {
                    arg = new ContinuousArg();
                    arg.rot = rot;
                    arg.startPos = prevCenterPos;
                    arg.endPos = centPos;
                }
                X3PhysicsDebug.Ins.TryCreateShape(UUID, ShapeUseType.PhysicTest, shape, arg);
                X3PhysicsDebug.Ins.UpdateShapePos(UUID, ShapeUseType.PhysicTest, centPos, rot);
            }
            X3Physics.CheckShapeValid(shape);
#endif
            Quaternion quaternion = Quaternion.identity;
            quaternion.eulerAngles = rot;
            int hitNum = 0;
            if (isContinuousMode && prevCenterPos != centPos)
            {
                hitNum = ContinueCollisionTest(prevCenterPos, centPos, quaternion, shape, colliders, layerMask);
            }
            else
            {
                hitNum = CollisionTest(centPos, quaternion, shape, colliders, layerMask);
            }
            return hitNum;
        }

        /// <summary>
        /// 碰撞检测
        /// 指定位置生成一个Collider（不可见），检测内部的或者与其接触的一个或者多个Collider
        /// </summary>
        /// <param name="centerPos">collider 的中心位置</param>
        /// <param name="rot">旋转</param>
        /// <param name="shape">形状属性</param>
        /// <param name="resultNumLimit">检测结果的数量限制</param>
        /// <returns>检测到的，不重复的Actor对象</returns>
        private static int CollisionTest(Vector3 centerPos, Quaternion rot, BoundingShape shape, Collider[] result, int layerMask)
        {
            ShapeType type = shape.ShapeType;
            int hitNum = CollisionTest(type, centerPos, rot, shape, result, layerMask);
            return hitNum;
        }
        
        private static int CollisionTest(ShapeType type, Vector3 centerPos, Quaternion rot, BoundingShape shape, Collider[] result,int layerMask)
        {
            QueryTriggerInteraction flag = QueryTriggerInteraction.Ignore;
            int hitNum = 0;
            switch (type)
            {
                case ShapeType.Cube:
                    Vector3 half = new Vector3(shape.Length * 0.5f, shape.Height * 0.5f, shape.Width * 0.5f);
                    hitNum = Physics.OverlapBoxNonAlloc(centerPos, half, result, rot, layerMask, flag);
                    break;
                case ShapeType.Sphere:
                    hitNum = Physics.OverlapSphereNonAlloc(centerPos, shape.Radius, result, layerMask, flag);
                    break;
                case ShapeType.FanColumn: 
                    // 理论上：先做一次圆柱半径检测，在判断角度是否符合，可以实现扇形检测。
                    // 这里圆柱使用胶囊体的中间部分, 检测的范围，多了胶囊体两头的半球范围, 通过射线在做一次筛选
                    float radius = shape.Radius;
                    float height = shape.Height * 0.5f;
                    Vector3 localUp = (rot * Vector3.up).normalized;    
                    Vector3 point0 = centerPos + localUp * height;
                    Vector3 point1 = centerPos - localUp * height;
                    hitNum = Physics.OverlapCapsuleNonAlloc(point0, point1, radius, result, layerMask, flag);
                    if (hitNum > 0) // 角度筛选
                    {
                        Vector3 localFoward = (rot * Vector3.forward).normalized;
                        int validTarget = 0;
                        _tempColliders.Clear();
                        for (int i = 0; i < hitNum; i++) 
                        {
                            var hitCollider = result[i];
                            var coliderPos = hitCollider.bounds.center;
                            Ray ray = new Ray(point0, localFoward);
                            //识别 collider 不在角度内，但与扇形侧面有相交的情况
                            Vector3 toVec = (coliderPos - centerPos).normalized;
                            toVec.y = localFoward.y; // 角度判定是二维计算，需要确保同一平面
                            // Debug.DrawRay(centerPos, toVec, Color.white, 2);
                            var angle = Vector3.SignedAngle(localFoward, toVec, localUp);
                            if (Mathf.Abs(angle) > shape.Angle * 0.5f)
                            {
                                // 1 : collider在扇形，右方，  -1:左方
                                // 在collider一侧，扇形的侧面上发送上，中，下三条射线，补充检测是否碰到collider
                                int signBit = angle > 0 ? 1 : -1;
                                float rotAngle = shape.Angle * 0.5f * signBit;
                                ray.direction = Quaternion.AngleAxis(rotAngle, localUp) * localFoward;
                                ray.origin = centerPos;
                                // Debug.DrawRay(ray.origin, ray.direction, Color.blue, 2);
                                if (TryHitColliderByRay(ray, radius, layerMask, hitCollider)) 
                                {
                                    _tempColliders.Add(result[i]);
                                    validTarget += 1;
                                    continue;
                                }
                                ray.origin = point0;
                                // Debug.DrawRay(ray.origin, ray.direction, Color.red, 2);
                                if (TryHitColliderByRay(ray, radius, layerMask, hitCollider))
                                {
                                    _tempColliders.Add(result[i]);
                                    validTarget += 1;
                                    continue;
                                }
                                ray.origin = point1;
                                // Debug.DrawRay(ray.origin, ray.direction, Color.green, 2);
                                if (TryHitColliderByRay(ray, radius, layerMask, hitCollider))
                                {
                                    _tempColliders.Add(result[i]);
                                    validTarget += 1;
                                    continue;
                                }
                            }
                            else
                            {
                                _tempColliders.Add(result[i]);
                                validTarget += 1;
                                continue;
                            }
                        }
                        if (hitNum != validTarget)
                        {
                            hitNum = validTarget;
                            _tempColliders.CopyTo(result, 0);
                        }
                    }
                    break;
                case ShapeType.Capsule:
                    localUp = (rot * Vector3.up).normalized;    // todo 考虑优化一下normalized
                    float len = (shape.Height - shape.Radius * 2) * 0.5f;
                    point0 = centerPos + localUp * len;
                    point1 = centerPos - localUp * len;
                    hitNum = Physics.OverlapCapsuleNonAlloc(point0, point1, shape.Radius, result, layerMask, flag);
                    break;
                case ShapeType.Ray:
                    Vector3 dir = rot * Vector3.forward;
                    float  rayLen = shape.Length < 0 ? float.MaxValue : shape.Length;
                    hitNum = Physics.RaycastNonAlloc(centerPos, dir, _raycastHit, rayLen, layerMask, flag);
                    for (int i = 0; i < hitNum; i++)
                    {
                        result[i] = _raycastHit[i].collider;
                    }
                    break;
                case ShapeType.RingFanColumn:
                    //注意： 仅适用于检测竖直无xz轴旋转的胶囊体, 和球
                    // 算法思想：
                    // 第一步: 使用外半径圆柱（胶囊体去掉上下半球）检测出所有与圆柱相交的 collider （只识别胶囊体和球）
                    //      符合第一步的，Collider平面投影后都是圆，下圆即代表collider
                    // 第二步：(2D)平面计算，去掉内半径圆完全内涵的圆。 可以得出与圆环相交的圆
                    // 第三步：遍历上一步的圆，2D判定圆（外半径）和扇形是否相交，算法：使用用离心轴定理
                    _tempCircles.Clear();
                    radius = shape.Radius;
                    height = shape.Height * 0.5f;
                    localUp = Vector3.up; // 不支持旋转
                    point0 = centerPos + localUp * height;
                    point1 = centerPos - localUp * height;
                    hitNum = Physics.OverlapCapsuleNonAlloc(point0, point1, radius, result, layerMask, flag);
                    if (hitNum <= 0)
                        break;
                    // 算法 第一步
                    for (int i = 0; i < hitNum; i++)
                    {
                        if (result[i] is CapsuleCollider capsuleCollider)
                        {
                            Vector3 pos = capsuleCollider.transform.position;
                            float offset = capsuleCollider.height * 0.5f;
                            float minY = pos.y -  offset; // 底部顶点
                            float maxY = pos.y + offset;  // 头部顶点
                            if (minY > point0.y || maxY < point1.y) // 排除上下半球碰到的collider
                                continue;
                            pos.y = 0; // 压扁
                            _tempCircles.Add(new CircleData(pos, capsuleCollider.radius, result[i]));
                        }
                        else if (result[i] is SphereCollider sphereCollider)
                        {
                            Vector3 pos = sphereCollider.transform.position;
                            float sphereRadius = sphereCollider.radius;
                            float minY = pos.y -  sphereRadius; // 底部顶点
                            float maxY = pos.y + sphereRadius;  // 头部顶点
                            if (minY > point0.y || maxY < point1.y)
                                continue;
                            pos.y = 0; // 压扁
                            _tempCircles.Add(new CircleData(pos, sphereCollider.radius, result[i]));
                        }
                    }
                    // 算法 第二步
                    centerPos.y = 0; // 压扁
                    hitNum = 0;
                    for (int i = 0; i < _tempCircles.Count; i++)
                    {
                        float sqrtInnerRadius = Mathf.Pow(shape.Length - _tempCircles[i].radius, 2) ; // 约定的内圆的半径
                        float disSqr = (centerPos - _tempCircles[i].pos).sqrMagnitude;
                        // 是否与内圆内含(两圆心距离 <= 内圆半径 - 圆半径), 内含舍弃
                        if (disSqr < sqrtInnerRadius)
                        {
                            _tempCircles[i] = new CircleData() { remove = true };
                            continue;
                        }
                        result[hitNum] = _tempCircles[i].Collider;
                        hitNum++;
                    }
                    if (shape.Angle >= 360)
                        break;
                    // 算法 第三步
                    hitNum = 0;
                    for (int i = 0; i < _tempCircles.Count; i++)
                    {
                        var circleData = _tempCircles[i];
                        if (circleData.remove)
                            continue;
                        float circleRadius = circleData.radius;
                        float sectorRadius = shape.Radius; // 外半径
                        
                        // 扇形朝向z轴，只考虑y轴旋转
                        var rotEuler = rot.eulerAngles;
                        float rotY = rotEuler.y - 90; // 下面的计算是按照扇形朝向X轴做的计算, 所以逆时针旋转90度
                        Vector3 targetPos = circleData.pos - centerPos; // 圆转到扇形圆心为原点的坐标系下
                        float rotRadian = - rotY * Mathf.Deg2Rad;
                        float cosAngle = Mathf.Cos(rotRadian);
                        float sinAngle = Mathf.Sin(rotRadian);
                        float x = targetPos.x * cosAngle + targetPos.z * sinAngle;
                        float z = targetPos.z * cosAngle - targetPos.x * sinAngle;

                        targetPos = new Vector3(x, targetPos.y, z);
                        Vector2 p = new Vector2(x, z); // 扇形坐标系下，映射到第一象限的向量
                        float disSqr = p.sqrMagnitude;
                        if (disSqr > Mathf.Pow(circleRadius + sectorRadius, 2))
                        {
                            // 圆与 扇形所在的圆 相离
                            continue; 
                        }
                        if (disSqr <= Mathf.Pow(circleRadius, 2))
                        {
                            // 扇形圆心顶点 在圆内部
                            result[hitNum] = _tempCircles[i].Collider;
                            hitNum++;
                            continue;
                        }

                        float radian = shape.Angle * Mathf.Deg2Rad * 0.5f;
                        if (p.x >= Mathf.Sqrt(disSqr) * Mathf.Cos(radian))
                        {
                            // 圆心在扇形内部
                            result[hitNum] = _tempCircles[i].Collider;
                            hitNum++;
                            continue;
                        }
                        // 求 圆心到扇形两条边的最短向量
                        Vector2 b = new Vector2(sectorRadius * Mathf.Cos(radian), sectorRadius *Mathf.Sin(radian));
                        Vector2 pointP = new Vector2(targetPos.x, Mathf.Abs(p.y));
                        Vector2 minVec = PointToSegmentMinVec(pointP, Vector2.zero, b);
                        // // TODO 这两条线的绘制错误，重新绘制
                        // Debug.DrawLine(Vector3.zero, new Vector3(b.x, 0, b.y), Color.red, 20);
                        // Vector3 endVec = b + minVec;
                        // Debug.DrawLine(new Vector3(b.x, 0, b.y), new Vector3(endVec.x, 0, endVec.y) , Color.blue, 20);
                        if (minVec.sqrMagnitude <= Mathf.Pow(circleRadius, 2))
                        {
                            // 圆和扇形相交
                            result[hitNum] = _tempCircles[i].Collider;
                            hitNum++;
                        }
                    }
                    break;
                default:
                    PapeGames.X3.LogProxy.LogErrorFormat("形状：{0} 物理检测暂不支持", type);
                    break;
            }
            return hitNum;
        }
        
        private static bool TryHitColliderByRay(Ray ray, float maxDis, int mask, Collider hitCollider)
        {
           int num = Physics.RaycastNonAlloc(ray, _raycastHit, maxDis, mask, QueryTriggerInteraction.Ignore);
           if (num <= 0)
           {
               return false;
           }
           for (int i = 0; i < num; i++)
           {
               if (_raycastHit[i].collider == hitCollider)
               {
                   return true;
               }
           }
           return false;
        }
        
        /// <summary>
        /// 胶囊体碰撞检测
        /// </summary>
        /// <param name="centerPos"></param>
        /// <param name="up"></param>
        /// <param name="height"></param>
        /// <param name="radius"></param>
        /// <param name="direction"></param>
        /// <param name="moveDistance"></param>
        /// <param name="layerMask"></param>
        /// <returns></returns>
        private static int _CapsuleTest(Vector3 centerPos, Vector3 up, float height, float radius, Vector3 direction, float moveDistance, int layerMask)
        {
            float len = (height - radius * 2) * 0.5f;
            Vector3 point0 = centerPos + up * len;
            Vector3 point1 = centerPos - up * len;
            int hitNum = Physics.CapsuleCastNonAlloc(point0, point1, radius, direction, _raycastHit, moveDistance, layerMask, QueryTriggerInteraction.Ignore);
            return hitNum;
        }
        
        /// <summary>
        /// 连续碰撞检测
        /// 指定方向，距离投射一个collider（不可见），检测与其接触的一个或者多个Collider
        /// </summary>
        /// <param name="StartCenterPos">开始检测位置</param>
        /// <param name="EndCenterPos">结束检测位置</param>
        /// <param name="rot">旋转</param>
        /// <param name="shape">形状属性</param>
        /// <param name="resultNumLimit">检测结果的数量限制</param>
        /// <returns>检测到的，不重复的Actor对象</returns>
        public static int ContinueCollisionTest(Vector3 StartCenterPos, Vector3 EndCenterPos, Quaternion rot, BoundingShape shape, Collider[] result, int layerMask)
        {
            ShapeType type = shape.ShapeType;
            QueryTriggerInteraction flag = QueryTriggerInteraction.Ignore;
            Vector3 dir = (EndCenterPos - StartCenterPos).normalized;
            float moveDis = Vector3.Distance(StartCenterPos, EndCenterPos);    
            
            int hitNum = 0;
            switch (type)
            {
                case ShapeType.Cube:
                    Vector3 half = new Vector3(shape.Length * 0.5f, shape.Height * 0.5f, shape.Width * 0.5f);
                    hitNum = Physics.BoxCastNonAlloc(StartCenterPos, half, dir, _raycastHit, rot, moveDis, layerMask, flag);
                    break;
                case ShapeType.Sphere:
                    hitNum = Physics.SphereCastNonAlloc(StartCenterPos, shape.Radius, dir, _raycastHit, moveDis, layerMask, flag);
                    break;
                case ShapeType.FanColumn: 
                    // 开始位置，结束位置使用扇形体检测，中间使用cube检测
                    _tempColliders.Clear();
                    hitNum = CollisionTest(ShapeType.FanColumn, StartCenterPos, rot, shape, result, layerMask);
                    for (int i = 0; i < hitNum; i++)
                    {
                        _tempColliders.Add(result[i]);
                    }
                    hitNum = CollisionTest(ShapeType.FanColumn, EndCenterPos, rot, shape, result, layerMask);
                    for (int i = 0; i < hitNum; i++)
                    {
                        _tempColliders.Add(result[i]);
                    }
                    float cubeX = Mathf.Sin(shape.Angle * 0.5f) * 2;
                    float cubeZ = (EndCenterPos - StartCenterPos).magnitude;
                    var cubePos = (Mathf.Cos(shape.Angle * 0.5f) + cubeZ * 0.5f) * dir;
                    _tempCubeShape.ShapeType = ShapeType.Cube;
                    _tempCubeShape.Height = shape.Height;
                    _tempCubeShape.Length = cubeX;
                    _tempCubeShape.Width = cubeZ;
                    hitNum = CollisionTest(ShapeType.Cube, cubePos, rot, _tempCubeShape, result, layerMask);
                    for (int i = 0; i < hitNum; i++)
                    {
                        _tempColliders.Add(result[i]);
                    }
                    hitNum = _tempColliders.Count;
                    _tempColliders.CopyTo(result, 0);
                    break;
                case ShapeType.Capsule:
                    Vector3 localUp = (rot * Vector3.up).normalized;
                    float len = (shape.Height - shape.Radius * 2) * 0.5f;
                    Vector3 point0 = StartCenterPos + localUp * len;
                    Vector3 point1 = StartCenterPos - localUp * len;
                    hitNum = Physics.CapsuleCastNonAlloc(point0, point1, shape.Radius, dir, _raycastHit, moveDis, layerMask, flag);
                    break;
                case ShapeType.Ray:
                    // 射线连续碰撞检测与非连续一致
                    dir = rot * Vector3.forward;
                    float  rayLen = shape.Length < 0 ? float.MaxValue : shape.Length;
                    hitNum = Physics.RaycastNonAlloc(EndCenterPos, dir, _raycastHit, rayLen, layerMask, flag);
                    // PapeGames.X3.LogProxy.LogWarningFormat("形状：射线连续碰撞检测暂不支持，使用不连续检测代替");
                    break;
                default:
                    PapeGames.X3.LogProxy.LogErrorFormat("形状：{0} 物理连续碰撞检测暂不支持", type);
                    break;
            }

            if (type != ShapeType.FanColumn)
            {
                for (int i = 0; i < hitNum; i++)
                {
                    result[i] = _raycastHit[i].collider;
                }
            }
            return hitNum;
        }

        /// <summary>
        /// 获取指定Cllider上，距离指定点最近的点
        /// </summary>
        /// <param name="collider"></param>
        /// <param name="pos"></param>
        /// <param name="inSideDis">pos在Collider内部的穿透距离</param>
        /// <returns></returns>
        public static Vector3 GetClosetPoint(Collider collider, Vector3 pos, float inSideDis=100)
        { 
            // pos 在Collider内部时最近的点就是pos
           Vector3 result = collider.ClosestPoint(pos);
           if (result == pos)
           {
               // 此时Pos在Collider内部
               var colliderPos = collider.bounds.center;
               var dir = colliderPos - pos;
               result = collider.ClosestPoint(pos -dir*inSideDis);
           }
           return result;
        }

        /// <summary>
        /// 计算 xz平面内，点到线段的最短向量
        /// </summary>
        /// <param name="p">点</param>
        /// <param name="a">线段端点</param>
        /// <param name="b">线段端点</param>
        /// <returns>最短向量，P为向量终点</returns>
        public static Vector2 PointToSegmentMinVec(Vector2 p, Vector2 a, Vector2 b)
        {
            Vector2 ap = p - a;
            Vector2 ab = b - a;
            float apDotab = Vector2.Dot(ap, ab);
            float abSqr = ab.sqrMagnitude;
            if (abSqr == 0)
            {
                return ap; // 两端点重合
            }
            // ap 在线段上的投影的粗略计算
            float r = apDotab / abSqr;
            if (r < 0)
            {
                // p 与 A 垂直，或者在A左边
                return ap;  
            }
            if (r >= 1)
            {
                // P 与 B垂直 ，或者在B右边
                return p - b;
            }
            // ap 在线段上的精确投影
            float acDis = apDotab / ab.magnitude;
            ab.Normalize();
            Vector2 c = new Vector2(a.x + ab.x * acDis, a.y + ab.y * acDis); // p到线段上的垂足c
            return p - c;
        }
    }
}   