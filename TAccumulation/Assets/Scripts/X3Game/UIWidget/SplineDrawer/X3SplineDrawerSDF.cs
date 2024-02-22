using UnityEngine.UI;
using PapeGames.X3;
using UnityEngine;

namespace X3Game
{
    public class X3SplineDrawerSDF : X3SplineDrawerBase
    {
        [SerializeField] private bool m_IsWidthVariation = false;
        
        private static readonly int s_LineWidthID = Shader.PropertyToID("_CurveWidth");
        private static readonly int s_ControlPointsID = Shader.PropertyToID("_ControlPoints");
        private static readonly int s_WidthVariationFuncPointsID = Shader.PropertyToID("_WidthVariationFuncPoints");
        private static readonly int s_CurveNumID = Shader.PropertyToID("_CurveNum");
        
        public override Material defaultMaterial
        {
            get
            {
                if (m_SplineDefaultMaterial == null)
                {
                    m_SplineDefaultMaterial = new Material(Shader.Find("UI/SplineSDF"));
                }

                return m_SplineDefaultMaterial;
            }
        }

        protected override void GenerateLinearSplineMesh(VertexHelper toFill)
        {
            
        }

        protected override void GenerateCatmullRomSplineMesh(VertexHelper toFill)
        {
            
            if (m_ControlPoints.Count < 2)
            {
                LogProxy.Log("控制点数量不足");
                return;
            }

            if (m_ControlPoints.Count > s_ControlPointsNum - 2)
            {
                LogProxy.Log("控制点数量过多");
                return;
            }
            float totalSegment = 0;
            // 每两个点确定一条 Hermite Curve，根据这两个点的 AABB 生成 Mesh
            // 考虑到曲线的宽度和 Hermite Curve 的曲率，所以需要生成较大的 AABB，会有 Overdraw
            // 如果曲率过大，曲线可能会超出 AABB 的范围，因此不建议使用曲率过大的 Catmull-Rom Spline
            float offset = m_LineWidth;
            Vector4 aabb2D = new Vector4();
            for (int i = 0; i < m_ControlPoints.Count - 1; i++)
            {
                Vector2 p0 = m_ControlPoints[i];
                Vector2 p1 = m_ControlPoints[i + 1];
                aabb2D.x = Mathf.Min(p0.x, p1.x) - offset;
                aabb2D.y = Mathf.Min(p0.y, p1.y) - offset;
                aabb2D.z = Mathf.Max(p0.x, p1.x) + offset;
                aabb2D.w = Mathf.Max(p0.y, p1.y) + offset;
                AddQuad(toFill, aabb2D, color, i + 1);
                totalSegment++;
            }
            material.SetFloat(s_CurveNumID, totalSegment);
        }

        protected override void GenerateBezierSplineMesh(VertexHelper toFill)
        {
            if (m_ControlPoints.Count < 4)
            {
                LogProxy.Log("控制点数量不足");
                return;
            }
            
            // 每四个点确定一段 Bezier Curve，根据这四个点的 AABB 生成 Mesh
            float offset = m_LineWidth;
            float totalSegment = 0;
            for (int i = 0; i < m_ControlPoints.Count - 3; )
            {
                Vector4 aabb2D = new Vector4(float.MaxValue, float.MaxValue, float.MinValue, float.MinValue);
                for (int j = 0; j < 4; j++)
                {
                    Vector2 controlPoint = PixelAdjustPoint(m_ControlPoints[i + j]);
                    float offsetLeft = (i == 0) ? -offset : 0;
                    aabb2D.x = Mathf.Min(aabb2D.x, controlPoint.x) + offsetLeft;
                    aabb2D.y = Mathf.Min(aabb2D.y, controlPoint.y) - offset;
                    float offsetRight = (i == m_ControlPoints.Count - 4) ? offset : 0;
                    aabb2D.z = Mathf.Max(aabb2D.z, controlPoint.x) + offsetRight;
                    aabb2D.w = Mathf.Max(aabb2D.w, controlPoint.y) + offset;
                }
                
                AddQuad(toFill, aabb2D, color, i);
                totalSegment++;
                i += 3;
            }
            material.SetFloat(s_CurveNumID, totalSegment);
        }

        protected override void GenerateBSplineSplineMesh(VertexHelper toFill)
        {
            // Not Support
            // if (m_ControlPoints.Count < 4)
            // {
            //     LogProxy.Log("控制点数量不足");
            //     return;
            // }
            // float offset = m_LineWidth;
            // float totalSegment = 0;
            // for (int i = 0; i < m_ControlPoints.Count - 3; )
            // {
            //     Vector4 aabb2D = new Vector4(float.MaxValue, float.MaxValue, float.MinValue, float.MinValue);
            //     for (int j = 0; j < 4; j++)
            //     {
            //         Vector2 controlPoint = PixelAdjustPoint(m_ControlPoints[i + j]);
            //         float offsetLeft = (i == 0) ? -offset : 0;
            //         aabb2D.x = Mathf.Min(aabb2D.x, controlPoint.x) + offsetLeft;
            //         aabb2D.y = Mathf.Min(aabb2D.y, controlPoint.y) - offset;
            //         float offsetRight = (i == m_ControlPoints.Count - 4) ? offset : 0;
            //         aabb2D.z = Mathf.Max(aabb2D.z, controlPoint.x) + offsetRight;
            //         aabb2D.w = Mathf.Max(aabb2D.w, controlPoint.y) + offset;
            //     }
            //     
            //     AddQuad(toFill, aabb2D, color, i);
            //     totalSegment++;
            //     i ++;
            // }
            // material.SetFloat(s_CurveNumID, totalSegment);
        }

        protected override void ApplyLinearSplineProp()
        {
            
        }

        protected override void ApplyCatmullRomSplineProp()
        {
            material.DisableKeyword("BEZIER_SPLINE");
            material.EnableKeyword("CATMULL_ROM_SPLINE");
            if (m_ControlPoints.Count < 2)
            {
                LogProxy.Log("控制点数量不足");
                return;
            }

            if (m_ControlPoints.Count > s_ControlPointsNum - 2)
            {
                LogProxy.Log("控制点数量过多");
                return;
            }

            int count = m_ControlPoints.Count + 2;
            Vector4[] vector3s = new Vector4[s_ControlPointsNum];
            // m_ControlPoints.CopyTo(0, vector3s, 1, m_ControlPoints.Count);

            for (int i = 0; i < m_ControlPoints.Count; i++)
            {
                vector3s[i + 1] = TransformLocalToCanvasSpace(m_ControlPoints[i]);
            }

            
            if (vector3s[1] == vector3s[count - 2])
            {
                // 处理循环的情况
                vector3s[0] = vector3s[count - 3];
                vector3s[count - 1] = vector3s[2];
            }
            else
            {
                vector3s[0] = vector3s[1] + (vector3s[1] - vector3s[2]);
                vector3s[count - 1] = vector3s[count - 2] + (vector3s[count - 2] - vector3s[count - 3]);
            }
            
            material.SetVectorArray(s_ControlPointsID, vector3s);
            ApplyWidthVariationFuncProp();
        }

        protected override void ApplyBezierSplineProp()
        {
            material.DisableKeyword("CATMULL_ROM_SPLINE");
            material.EnableKeyword("BEZIER_SPLINE");
            if (m_ControlPoints.Count < 4)
            {
                LogProxy.Log("控制点数量不足");
                return;
            }

            if (m_ControlPoints.Count > s_ControlPointsNum )
            {
                LogProxy.Log("控制点数量过多");
                return;
            }

            Vector4[] vector3s = new Vector4[s_ControlPointsNum];
            for (int i = 0; i < m_ControlPoints.Count; i++)
            {
                vector3s[i] = TransformLocalToCanvasSpace(m_ControlPoints[i]);
            }
            
            material.SetVectorArray(s_ControlPointsID, vector3s);
            
            ApplyWidthVariationFuncProp();
        }

        protected override void ApplyBSplineSplineProp()
        {
            // Not Support
            // material.DisableKeyword("BEZIER_SPLINE");
            // material.DisableKeyword("CATMULL_ROM_SPLINE");
        }

        private void ApplyWidthVariationFuncProp()
        {
            if (m_IsWidthVariation)
            {
                material.EnableKeyword("WIDTH_VARIATION_FUNCTION");
                int smoothness = 32;
                float[] widthVariationFunc = new float[smoothness];
                for (int i = 0; i < smoothness; i++)
                {
                    float t = i / (float) (smoothness - 1);
                    widthVariationFunc[i] = lineWidthCurve.Evaluate(t);
                }
                material.SetFloatArray(s_WidthVariationFuncPointsID, widthVariationFunc);
            }
            else
            {
                material.DisableKeyword("WIDTH_VARIATION_FUNCTION");
            }
        }
    }
}