using System;
using System.Collections.Generic;
using Pathfinding;
using UnityEngine;
using Unity.Mathematics;
using UnityEngine.Profiling;
using CollisionQuery;
using PapeGames.X3;
using ThirdPlugins.AstarPathfindingProject.Utilities;

namespace X3Battle
{
    public static partial class BattleUtil
    {
        private static List<Vector2> _tempVec2Points = new List<Vector2>(8); //寻找路径点函数使用
        private static List<float> _tempFloatPoints = new List<float>(8); //寻找路径点函数使用
        private static float _floatEqual = 0.0003f;
        public static bool AStarIsActive => null != AstarPath.active?.data?.graphs && AstarPath.active.data.graphs.Length > 0;
        public static bool AStarIsGrid => AStarIsActive && null != AstarPath.active.data.gridGraph;
        private static NNConstraint _nnTriangleInfo = new NNConstraint();
        
        public static string Walk = "_Walk";
        // public enum PointType
        // {
        //     Point45,
        //     Point315
        // }
        
        /// <summary>
        /// 获取导航网格上的最近点
        /// </summary>
        /// <param name="point"></param>
        /// <returns></returns>
        public static Vector3 GetNavMeshNearestPoint(Vector3 point)
        {
            if (!AStarIsActive)
            {
                return point;
            }

            using (ProfilerDefine.UtilGetNavMeshNearestPointPMarker.Auto())
            {
                var y = point.y;
                var nearest = GetNearest(point, _nnTriangleInfo);
                point = nearest.node != null ? nearest.position : point;
                point.y = y;
                return point;
            }
        }

        /// <summary>
        /// 点是否在导航网格上
        /// </summary>
        /// <param name="point"></param>
        /// <returns></returns>
        public static bool IsInNavMesh(Vector3 point)
        {
            if (!AStarIsActive)
            {
                return true;
            }

            var nearest = GetNearest(point, _nnTriangleInfo);
            return Math.Abs(nearest.position.x - point.x) < BattleConst.EPSINON && Math.Abs(nearest.position.z - point.z) < BattleConst.EPSINON;
        }

        /// <summary>
        /// 判断这个点是否正确 是否在nevmesh内 && 是否在当前区域内
        /// </summary>
        /// point 当前要判断的点
        /// curpos 当前主角的点 确定是正确的点
        /// <returns></returns>
        public static bool IsRightPoint(Vector3 point, Vector3 curpos)
        {
            if (!AStarIsActive)
            {
                return true;
            }
            
            if (!IsInNavMesh(point))
                return false;

            if (Battle.Instance.misc.astarPath == null)
                return false;
            
            //单独发起一次寻路

            using (ProfilerDefine.UtilNavMeshSearchIsRightPointPMarker.Auto())
            {
                var abPath = ABPath.Construct(curpos, point);
                abPath.nnConstraint = _nnTriangleInfo;
                AstarPath.StartPath(abPath);
                abPath.BlockUntilCalculated();
                if (abPath.path == null || abPath.path.Count == 0 || abPath.vectorPath == null ||
                    abPath.vectorPath.Count == 0)
                {
                    return false;
                }

                if (abPath.CompleteState != PathCompleteState.Complete)
                {
                    LogProxy.LogError($"IsRightPoint 寻路失败 point= {point},curpos= {curpos}");
                    return false;
                }

                if (abPath.path.Count == 1)
                {
                    return !IsFindAirWall(curpos, point-curpos, (point-curpos).magnitude);
                }

                //funnel modifier
                FunnelModifier.NavMeshUtilModifier(abPath);
                var firstSegment = abPath.vectorPath[0] - abPath.startPoint;
                if (IsFindAirWall(abPath.startPoint, firstSegment, firstSegment.magnitude))
                {
                    return false;
                }

                for (int i = 0; i < abPath.vectorPath.Count - 1; i++)
                {
                    var beginPos = abPath.vectorPath[i];
                    var endPos = abPath.vectorPath[i + 1];
                    if (IsFindAirWall(beginPos, endPos - beginPos, (endPos - beginPos).magnitude))
                    {
                        return false;
                    }
                }

                var lastSegment = abPath.vectorPath[abPath.vectorPath.Count - 1] - abPath.endPoint;
                if (IsFindAirWall(abPath.endPoint, lastSegment, lastSegment.magnitude))
                {
                    return false;
                }
            }
            
            return true;
        }

        /// <summary>
        /// 给定一个圆 返回一个合适的圆
        /// </summary>
        /// <param name="curPos"></param>
        /// <param name="radius"></param>
        /// <param name="isWriteCircle"></param>
        /// <returns></returns>
        public static Vector3 GetNavmeshPos(Vector3 curPos, float radius, bool isWriteCircle = false)
        {
            using (ProfilerDefine.UtilGetNavmeshPosPMarker.Auto())
            {
                if (Battle.Instance.misc.astarPath == null)
                    return curPos;

                Vector3 returnPos = curPos;
                var astarData = Battle.Instance.misc.astarPath.data;

                //如果没有边界边数据直接返回
                if (astarData == null || !astarData.IsHaveBoundary())
                    return curPos;

                var actors = ObjectPoolUtility.CommonActorList.Get();
                Battle.Instance.actorMgr.GetActors(ActorType.Obstacle, outResults: actors);

                //向4周发射4条射线求碰撞点 然后计算应该移动到的位置
                returnPos = _GetXPoint(curPos, radius, actors);
                returnPos = _GetYPoint(returnPos, radius, actors);
                // returnPos = _Get45Or315Point(returnPos, radius, actors, PointType.Point45);
                // returnPos = _Get45Or315Point(returnPos, radius, actors, PointType.Point315);
                ObjectPoolUtility.CommonActorList.Release(actors);

                if (isWriteCircle)
                {
#if UNITY_EDITOR
                    //if (IsRightPoint(returnPos, actorPosition))
                    //{
                    Battle.Instance.misc.astarPath.DrawGizmosCircle(returnPos, Vector3.up, radius, 100, 9000);
                    //}
#endif
                }

                return returnPos;
            }
        }

        /// <summary>
        ///  求X轴交点
        /// </summary>
        /// <returns></returns>
        private static Vector3 _GetXPoint(Vector3 curPos, float radius, List<Actor> refActors)
        {
            var returnPos = curPos;
            var astarData = Battle.Instance.misc.astarPath.data;

            //首先判断以圆心为中心点 x轴为直线边 与navmesh边界边的交点
            _tempVec2Points.Clear();
            astarData.GetLinePoint(new Vector2(curPos.x + radius, curPos.z), new Vector2(curPos.x - radius, curPos.z), ref _tempVec2Points);

            //再判断是否碰到空气墙
            _GetColliderPoint(new Vector3(curPos.x, curPos.y, curPos.z), Vector3.right, radius, _tempVec2Points, refActors);
            _GetColliderPoint(new Vector3(curPos.x, curPos.y, curPos.z), Vector3.left, radius, _tempVec2Points, refActors);

            // //计算X轴离圆心点最近的左右两个交点
            float xPointLeft;
            float xPointRight;
            bool isInLine = false;//当前点是否在边界上
            _tempFloatPoints.Clear();
            for (int i = 0; i < _tempVec2Points.Count; i++)
            {
                if (IsFloatEqual(_tempVec2Points[i].x, curPos.x))
                {
                    isInLine = true;
                }
                _tempFloatPoints.Add(_tempVec2Points[i].x);
            }

            float curPosX = curPos.x;
            //如果人物刚好在边界边上特殊处理
            if (isInLine)
            {
                if (IsInNavMesh(new Vector3(curPos.x + 0.1f, curPos.y, curPos.z)))
                {
                    curPosX += 0.1f;
                }
                else if(IsInNavMesh(new Vector3(curPos.x - 0.1f, curPos.y, curPos.z)))
                {
                    curPosX -= 0.1f;
                }
            }
            
            _GetTwoPoints(out xPointLeft, out xPointRight, _tempFloatPoints, curPosX);

            returnPos.x = _GetCenterOfCircle(xPointLeft, xPointRight, curPosX, radius);

            return returnPos;
        }

        private static float _GetCenterOfCircle(float min, float max, float curPos, float radius)
        {
            float returnPos = curPos;
            var center = (max - min) / 2.0f + min;
            //判断圆的Ｘ轴是否和边界边有两个交点
            if (min > curPos - radius && max < curPos + radius)
            {
                //取两个交点的中间点为新的X轴点
                returnPos = center;
            }
            //判断圆的Ｘ轴是否和边界边有一个交点
            else if (max < curPos + radius)
            {
                returnPos = math.max(center, max - radius);
            }
            else if (min > curPos - radius)
            {
                returnPos = math.min(center, min + radius);
            }

            return returnPos;
        }
        

        /// <summary>
        ///  求Y轴交点
        /// </summary>
        /// <returns></returns>
        private static Vector3 _GetYPoint(Vector3 curPos, float radius, List<Actor> refActors)
        {
            var returnPos = curPos;
            var astarData = Battle.Instance.misc.astarPath.data;

            //判断以圆心为中心点 Y轴为直线边 与navmesh边界边的交点
            _tempVec2Points.Clear();
            astarData.GetLinePoint(new Vector2(curPos.x, curPos.z + radius), new Vector2(curPos.x, curPos.z - radius), ref _tempVec2Points);

            //再计算Y轴的直线与空气墙的交点
            _GetColliderPoint(new Vector3(curPos.x, curPos.y, curPos.z), Vector3.forward, radius, _tempVec2Points, refActors);
            _GetColliderPoint(new Vector3(curPos.x, curPos.y, curPos.z), Vector3.back, radius, _tempVec2Points, refActors);

            //求距离圆心最近的两个交点
            float yPointUp;
            float yPointDowm;
            _tempFloatPoints.Clear();
            for (int i = 0; i < _tempVec2Points.Count; i++)
            {
                _tempFloatPoints.Add(_tempVec2Points[i].y);
            }

            _GetTwoPoints(out yPointDowm, out yPointUp, _tempFloatPoints, curPos.z);

            returnPos.z = _GetCenterOfCircle(yPointDowm, yPointUp, curPos.z, radius);

            return returnPos;
        }

        /// <summary>
        ///  求45° 或者 315° 轴交点
        /// </summary>
        /// <returns></returns>
        // private static Vector3 _Get45Or315Point(Vector3 curPos, float radius, List<Actor> refActors, PointType type)
        // {
        //     var returnPos = curPos;
        //     var astarData = Battle.Instance.misc.astarPath.data;
        //
        //     var sideLength = radius / AstarMathUtil.Square2;//三角形边长
        //     Vector2 tempRight = Vector2.zero;
        //     Vector2 tempLeft = Vector2.zero;
        //
        //     if (type == PointType.Point45)
        //     {
        //         tempRight = new Vector2(curPos.x + sideLength, curPos.z + sideLength);
        //         tempLeft = new Vector2(curPos.x - sideLength, curPos.z - sideLength); 
        //     }
        //     else
        //     {
        //         tempRight = new Vector2(curPos.x + sideLength, curPos.z - sideLength);
        //         tempLeft = new Vector2(curPos.x - sideLength, curPos.z + sideLength); 
        //     }
        //
        //
        //     //判断以圆心为中心点 45°轴为直线边 与navmesh边界边的交点
        //     _tempVec2Points.Clear();
        //     astarData.GetLinePoint(tempRight, tempLeft, ref _tempVec2Points);
        //
        //     //再计算 45°轴的线与空气墙的交点
        //     var dir = tempRight - tempLeft;
        //     _GetColliderPoint(tempLeft, dir, radius * 2, _tempVec2Points, refActors);
        //
        //     //求距离圆心最近的两个交点
        //     float yPointUp;
        //     float yPointDowm;
        //     
        //     _tempFloatPoints.Clear();
        //     for (int i = 0; i < _tempVec2Points.Count; i++)
        //     {
        //         _tempFloatPoints.Add(_tempVec2Points[i].y);
        //     }
        //
        //     _GetTwoPoints(out yPointDowm, out yPointUp, _tempFloatPoints, curPos.z);
        //     returnPos.z = _GetCenterOfCircle(yPointDowm, yPointUp, curPos.z, sideLength);
        //     
        //     float xPointUp;
        //     float xPointDowm;
        //     _tempFloatPoints.Clear();
        //     for (int i = 0; i < _tempVec2Points.Count; i++)
        //     {
        //         _tempFloatPoints.Add(_tempVec2Points[i].x);
        //     }
        //
        //     _GetTwoPoints(out xPointDowm, out xPointUp, _tempFloatPoints, curPos.x);
        //     returnPos.x = _GetCenterOfCircle(xPointDowm, xPointUp, curPos.x, sideLength);
        //
        //     return returnPos;
        // }

        private static void _GetTwoPoints(out float min, out float max, List<float> points, float curPos)
        {
            //计算X轴离圆心点最近的两个交点
            float xPointMin = float.MinValue;
            float xPointMax = float.MaxValue;
            //如果只有两个碰撞点
            if (points.Count == 2)
            {
                if (points[0] > points[1])
                {
                    xPointMax = points[0];
                    xPointMin = points[1];
                }
                else
                {
                    xPointMin = points[0];
                    xPointMax = points[1];
                }
            }
            else
            {
                for (int i = 0; i < points.Count; i++)
                {
                    if (points[i] >= curPos)
                    {
                        if (xPointMax > points[i])
                            xPointMax = points[i];
                    }
                    else if (points[i] < curPos)
                    {
                        if (xPointMin < points[i])
                            xPointMin = points[i];
                    }
                }

                //todo 如果没有选到最大 最小点 选距离curpos 最近的两个点 算法优化  
                if (points.Count > 1)
                {
                    if (xPointMin == float.MinValue || xPointMax == float.MaxValue)
                    {
                        float oneDis = Math.Abs(points[0] - curPos);
                        float one = points[0];
                        int index = 0;
                        for (int i = 0; i < points.Count; i++)
                        {
                            if (oneDis > Math.Abs(points[i] - curPos))
                            {
                                oneDis = Math.Abs(points[i] - curPos);
                                one = points[i];
                                index = i;
                            }
                        }

                        points.RemoveAt(index);

                        float twoDis = Math.Abs(points[0] - curPos);
                        float two = points[0];
                        for (int i = 0; i < points.Count; i++)
                        {
                            if (twoDis > Math.Abs(points[i] - curPos))
                            {
                                twoDis = Math.Abs(points[i] - curPos);
                                two = points[i];
                            }
                        }

                        if (one > two)
                        {
                            xPointMin = two;
                            xPointMax = one;
                        }
                        else
                        {
                            xPointMax = two;
                            xPointMin = one;
                        }
                    }
                }
            }

            min = xPointMin;
            max = xPointMax;
        }

        /// <summary>
        /// 获取碰撞点
        /// </summary>
        /// <param name="origin"></param>
        /// <param name="dir"></param>
        /// <param name="maxDis"></param>
        /// <param name="tempPoints"></param>
        /// <param name="actors"></param>
        private static void _GetColliderPoint(Vector3 origin, Vector3 dir, float maxDis, List<Vector2> tempPoints, List<Actor> actors)
        {
            //再计算Y轴的直线与空气墙的交点
            for (int i = 0; i < actors.Count; i++)
            {
                if (actors[i].obstacle == null || actors[i].obstacle.x3ActorCollider == null || actors[i].obstacle.x3ActorCollider.Collider == null)
                    continue;

                var collider = actors[i].obstacle.x3ActorCollider.Collider;

                //计算射线与空气墙的交点
                Ray xRay = new Ray(origin, dir);
                CqHit hit = new CqHit();
                if (collider.Raycast(xRay, maxDis, ref hit))
                {
                    tempPoints.Add(new Vector2(hit.point.x, hit.point.z));
                }
            }
        }

        /// <summary>
        /// 获取距离行走网格最近的点
        /// 以后获取最近点都调用这个接口
        /// </summary>
        /// <param name="position"></param>
        /// <param name="constraint"></param>
        public static NNInfo GetNearest(Vector3 position, NNConstraint constraint)
        {
            if (AStarIsActive)
            {
                return AstarData.active.GetNearestInTriangle(position, constraint, null);
            }
            else
            {
                return AstarData.active.GetNearest(position, constraint);
            }
        }
        
        public static bool IsFloatEqual(float a, float b)
        {
            if (Mathf.Abs(a - b) < _floatEqual)
            {
                return true;
            }

            return false;
        }
    }
}
