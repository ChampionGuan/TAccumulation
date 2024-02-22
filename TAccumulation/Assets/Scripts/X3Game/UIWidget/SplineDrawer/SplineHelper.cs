using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Game
{
    public static class SplineHelper
    {
        /// <summary>
        /// 线性插值
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <returns>t 点的坐标</returns>
        public static Vector3 LinearInterpolation(float t, Vector3 p0, Vector3 p1)
        {
            return (1 - t) * p0 + t * p1;
        }
        
        /// <summary>
        /// 三次 Herimite 插值
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="tangent0">控制点 0 处的切向量</param>
        /// <param name="tangent1">控制点 1 处的切向量</param>
        /// <returns>t 点的坐标</returns>
        public static Vector3 CubicHermiteInterpolation(float t, Vector3 p0, Vector3 p1, Vector3 tangent0, Vector3 tangent1)
        {
            float t2 = t * t;
            float t3 = t * t * t;
            return (2 * t3 - 3 * t2 + 1) * p0 +
                   (t3 - 2 * t2 + t) * tangent0 +
                   (-2 * t3 + 3 * t2) * p1 +
                   (t3 - t2) * tangent1;
        }

        /// <summary>
        /// 三次 Herimite 多项式函数的导函数
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="tangent0">控制点 0 处的切向量</param>
        /// <param name="tangent1">控制点 1 处的切向量</param>
        /// <returns>t 点的切向量</returns>
        public static Vector3 CubicHermitePolyTangentVector(float t, Vector3 p0, Vector3 p1, Vector3 tangent0, Vector3 tangent1)
        {
            float t2 = t * t;
            return 6 * (t2 - t) * (p0 - p1) +
                   (3 * t2 - 4 * t + 1) * tangent0 +
                   (3 * t2 - 2 * t) * tangent1;
        }

        /// <summary>
        /// 二次贝塞尔曲线插值
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="p2">控制点 2</param>
        /// <returns>t 点的坐标</returns>
        public static Vector3 QuadraticBezierInterpolation(float t, Vector3 p0, Vector3 p1, Vector3 p2)
        {
            float oneMinusT = 1 - t;
            return oneMinusT * oneMinusT * p0 +
                   2 * t * oneMinusT * p1 +
                   t * t * p2;
        }
        
        /// <summary>
        /// 二次贝塞尔曲线的导函数
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="p2">控制点 2</param>
        /// <returns>t 点的切向量</returns>
        public static Vector3 QuadraticBezierTangentVector(float t, Vector3 p0, Vector3 p1, Vector3 p2)
        {
            return 2 * (1 - t) * (p1 - p0) +
                   2 * t * (p2 - p1);
        }

        /// <summary>
        /// 三次贝塞尔曲线插值
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="p2">控制点 2</param>
        /// <param name="p3">控制点 3</param>
        /// <returns>t 点的坐标</returns>
        public static Vector3 CubicBezierInterpolation(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
        {
            float t3 = t * t * t;
            float t2 = t * t;
            float oneMinusT = 1 - t;
            float oneMinusT2 = oneMinusT * oneMinusT;
            float oneMinusT3 = oneMinusT * oneMinusT * oneMinusT;
            return oneMinusT3 * p0 +
                   3 * t * oneMinusT2 * p1 +
                   3 * t2 * oneMinusT * p2 +
                   t3 * p3;
        }

        /// <summary>
        /// 三次贝塞尔曲线的导函数
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="p2">控制点 2</param>
        /// <param name="p3">控制点 3</param>
        /// <returns>t 点的切向量</returns>
        public static Vector3 CubicBezierTangentVector(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
        {
            float oneMinusT = 1 - t;
            return 3 * oneMinusT * oneMinusT * (p1 - p0) +
                   6 * oneMinusT * t * (p2 - p1) +
                   3 * t * t * (p3 - p2);
        }
        
        /// <summary>
        /// 二次 B 样条插值
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="p2">控制点 2</param>
        /// <returns>t 点的坐标</returns>
        public static Vector3 QuadraticBSplineInterpolation(float t, Vector3 p0, Vector3 p1, Vector3 p2)
        {
            float oneMinusT = 1 - t;
            return 0.5f * oneMinusT * oneMinusT * p0 +
                   0.5f * (-2 * t * t + 2 * t + 1) * p1 +
                   0.5f * t * t * p2;
        }
        
        /// <summary>
        /// 三次 B 样条插值
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="p0">控制点 0</param>
        /// <param name="p1">控制点 1</param>
        /// <param name="p2">控制点 2</param>
        /// <param name="p3">控制点 3</param>
        /// <returns>t 点的坐标</returns>
        public static Vector3 CubicBSplineInterpolation(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
        {
            float t3 = t * t * t;
            float t2 = t * t;
            float inverseSix = 1.0f / 6.0f;
            return (-t3 + 3*t2 - 3*t + 1) * inverseSix * p0 +
                   (3*t3 - 6*t2 + 4) * inverseSix * p1 +
                   (-3*t3 + 3*t2 + 3*t + 1) * inverseSix * p2 +
                   t3 * inverseSix * p3;
        }

        /// <summary>
        /// NURBS 插值
        /// </summary>
        /// <param name="t">参数</param>
        /// <param name="order">曲线的次数</param>
        /// <param name="controlPoints">控制点</param>
        /// <param name="knots">节点向量</param>
        /// <param name="weights">控制点权重</param>
        /// <returns>t 点的坐标</returns>
        public static Vector3 NonUniformRationalBasicSplineInterpolation(float t, int order, List<Vector3> controlPoints, List<float> knots = null, List<float> weights = null)
        {
            if (order < 2 || order > controlPoints.Count)
            {
                LogProxy.LogError("曲线的次数不能小于 2 或者大于控制点数");
                return Vector3.zero;
            }
                
            if (weights == null || weights.Count == 0)
            {
                weights = new List<float>();
                for (int i = 0; i < controlPoints.Count; i++)
                {
                    weights.Add(1);
                }
            }

            if (knots == null || knots.Count == 0)
            {
                knots = new List<float>();
                for (int i = 0; i < controlPoints.Count + order; i++)
                {
                    knots.Add(i);
                }
            }
            else if(knots.Count != controlPoints.Count + order)
            {
                LogProxy.LogError("节点向量的维度必须等于控制点数 + 曲线次数");
                return Vector3.zero;
            }

            int[] domain = new[] {order - 1, knots.Count - 1 - (order - 1)};
            float low = knots[domain[0]];
            float high = knots[domain[1]];

            t = t * (high - low) + low;

            if (t < low || t > high)
            {
                LogProxy.LogError("t 的取值范围需要在 [0,1] 之间");
                return Vector3.zero;
            }

            int segment = domain[0];
            for (;segment < domain[1]; segment++)
            {
                if (t >= knots[segment] && t <= knots[segment + 1])
                    break;
            }
            
            var homoControlPosition = new List<Vector4>(controlPoints.Count);
            for (int i = 0; i < controlPoints.Count; i++)
            {
                Vector4 point = controlPoints[i] * weights[i];
                point.w = weights[i];
                homoControlPosition.Add(point);
            }

            for (int l = 1; l <= order; l++)
            {
                for (int i = segment; i > segment - order + l; i--)
                {
                    float a = (t - knots[i]) / (knots[i + order - l] - knots[i]);
                    homoControlPosition[i] = (1 - a) * homoControlPosition[i - 1] + a * homoControlPosition[i];
                }
            }

            float inverseWeight = 1 / homoControlPosition[segment].w;
            return homoControlPosition[segment] * inverseWeight;
        }

        /// <summary>
        /// 绘制 Catmull-Rom Spline
        /// </summary>
        /// <param name="path">曲线的路径（输出）</param>
        /// <param name="controlPoints">控制点</param>
        /// <param name="lineSegment">线段数</param>
        public static void DrawCatmullRomSpline(List<Vector3> path, List<Vector3> controlPoints, int lineSegment = 16)
        {
            path.Clear();
            if (controlPoints.Count < 2)
                return;
            
            Vector3[] vector3s = new Vector3[controlPoints.Count + 2];
            controlPoints.CopyTo(0, vector3s, 1, controlPoints.Count);

            // 在首尾添加辅助节点
            if (vector3s[1] == vector3s[vector3s.Length - 2])
            {
                // 处理循环的情况
                vector3s[0] = vector3s[vector3s.Length - 3];
                vector3s[vector3s.Length - 1] = vector3s[2];
            }
            else
            {
                vector3s[0] = vector3s[1] + (vector3s[1] - vector3s[2]);
                vector3s[vector3s.Length - 1] = vector3s[vector3s.Length - 2] + (vector3s[vector3s.Length - 2] - vector3s[vector3s.Length - 3]);
            }
            for (int i = 1; i <= vector3s.Length - 3; i++)
            {
                Vector3 pl = vector3s[i-1];
                Vector3 p0 = vector3s[i];
                Vector3 p1 = vector3s[i + 1];
                Vector3 pr = vector3s[i + 2];
                Vector3 tangent0 = 0.5f * (p1 - pl);
                Vector3 tangent1 = 0.5f * (pr - p0);

                if (i == vector3s.Length - 3)
                {
                    for (int j = 0; j <= lineSegment; j++)
                    {
                        float t = (float) j / (float) lineSegment;
                        path.Add(CubicHermiteInterpolation(t, p0, p1, tangent0, tangent1));
                    }
                }
                else
                {
                    for (int j = 0; j < lineSegment; j++)
                    {
                        float t = (float) j / (float) lineSegment;
                        path.Add(CubicHermiteInterpolation(t, p0, p1, tangent0, tangent1));
                    }
                }
            }
        }
        
        /// <summary>
        /// 绘制三次贝塞尔样条线
        /// </summary>
        /// <param name="path">曲线的路径（输出）</param>
        /// <param name="controlPoints">控制点</param>
        /// <param name="lineSegment">线段数</param>
        public static void DrawBezierSpline(List<Vector3> path, List<Vector3> controlPoints, int lineSegment = 16)
        {
            path.Clear();
            if (controlPoints.Count < 4)
                return;
            Vector3 p0 = Vector3.zero;
            Vector3 p1 = Vector3.zero;
            Vector3 p2 = Vector3.zero;
            Vector3 p3 = Vector3.zero;
            for (int i = 0; i < controlPoints.Count - 3; i+=3)
            {
                p0 = controlPoints[i];
                p1 = controlPoints[i + 1];
                p2 = controlPoints[i + 2];
                p3 = controlPoints[i + 3];

                if (i + 6 > controlPoints.Count)
                {
                    for (int j = 0; j <= lineSegment; j++)
                    {
                        float t = (float) j / (float) lineSegment;
                        path.Add(CubicBezierInterpolation(t, p0, p1, p2, p3));
                    }
                }
                else
                {
                    for (int j = 0; j < lineSegment; j++)
                    {
                        float t = (float) j / (float) lineSegment;
                        path.Add(CubicBezierInterpolation(t, p0, p1, p2, p3));
                    }
                }
            }
        }
        
        /// <summary>
        /// 绘制三次的 BSpline，三次 BSpline 曲线的起点和终点默认与控制点的起点与终点不重合，如果希望与起点或终点重合，需要在首尾各添加两个与起点和终点重合的控制节点
        /// </summary>
        /// <param name="path">曲线的路径（输出）</param>
        /// <param name="controlPoints">控制点</param>
        /// <param name="lineSegment">线段数</param>
        public static void DrawBSpline(List<Vector3> path, List<Vector3> controlPoints, int lineSegment = 16)
        {
            path.Clear();
            if (controlPoints.Count < 4)
                return;
            Vector3 p0 = controlPoints[0];
            Vector3 p1 = Vector3.zero;
            Vector3 p2 = Vector3.zero;
            Vector3 p3 = Vector3.zero;
            for (int i = 0; i < controlPoints.Count - 3; i++)
            {
                p0 = controlPoints[i];
                p1 = controlPoints[i + 1];
                p2 = controlPoints[i + 2];
                p3 = controlPoints[i + 3];
                
                for (int j = 0; j <= lineSegment; j++)
                {
                    if (i < controlPoints.Count - 4 && j == lineSegment)  continue;
                    float t = (float) j / (float) lineSegment;
                    path.Add(CubicBSplineInterpolation(t, p0, p1, p2, p3));
                }
            }
        }

        /// <summary>
        /// 绘制 NURBS 曲线，三次 NURBS 曲线的起点和终点默认与控制点的起点与终点不重合，如果希望与起点或终点重合，需要在首尾各添加两个与起点和终点重合的控制节点
        /// </summary>
        /// <param name="path">曲线的路径（输出）</param>
        /// <param name="controlPoints">控制点</param>
        /// <param name="lineSegment">线段数</param>
        public static void DrawNurbs(List<Vector3> path, List<Vector3> controlPoints, int lineSegment = 1024)
        {
            path.Clear();
            if (controlPoints.Count < 4)
                return;
            for (int j = 0; j <= lineSegment; j++)
            {
                float t = (float) j / (float) lineSegment;
                path.Add(NonUniformRationalBasicSplineInterpolation(t, 3, controlPoints));
            }
        }
    }
}