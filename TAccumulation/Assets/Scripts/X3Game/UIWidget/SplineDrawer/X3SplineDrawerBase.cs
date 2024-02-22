using System;
using System.Collections.Generic;
using System.Text;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.UI;

namespace X3Game
{
    public enum SplineType
    {
        LinearSpline,
        CatmullRomSpline,
        BerzierSpline,
        BSpline,
        // NURBS,
    }
    
    public abstract class X3SplineDrawerBase : MaskableGraphic
    {
        
        public readonly static int s_ControlPointsNum = 64;
        [SerializeField] protected SplineType m_SplineType = SplineType.BerzierSpline;
        [SerializeField] protected List<Vector3> m_ControlPoints = new List<Vector3>(s_ControlPointsNum);
        [SerializeField] protected Color m_LineColor = Color.white;
        [SerializeField] protected float m_LineWidth = 8;
        [SerializeField] protected AnimationCurve m_LineWidthCurve = AnimationCurve.Linear(0, 1, 1, 1);

        protected Material m_SplineDefaultMaterial;
        
        private Canvas m_RootCanvas;
        public Canvas rootCanvas
        {
            get
            {
                if (m_RootCanvas == null)
                    m_RootCanvas = RTUtility.FindRootCanvas(rectTransform);
                return m_RootCanvas;
            }
        }
        
        public SplineType splineType
        {
            get => m_SplineType;
            set
            {
                m_SplineType = value;
                SetVerticesDirty();
                SetMaterialDirty();
            }
        }

        public float LineWidth
        {
            get => m_LineWidth;
            set
            {
                m_LineWidth = value;
            }
        }

        public Color color
        {
            get => m_LineColor;
            set
            {
                m_LineColor = value;
            }
        }

        public AnimationCurve lineWidthCurve
        {
            get => m_LineWidthCurve;
            set
            {
                m_LineWidthCurve = value;
                SetVerticesDirty();
            }
        }
        
        /// <summary>
        /// 绘制曲线
        /// </summary>
        public void DrawSpline()
        {
            if (m_ControlPoints.Count < 2)
            {
                LogProxy.LogError("控制点数量不足");
                return;
            }

            if (m_ControlPoints.Count > s_ControlPointsNum)
            {
                LogProxy.LogError("控制点数量超出上限");
                return;
            }
            SetVerticesDirty();
            SetMaterialDirty(); 
        }

        /// <summary>
        /// 全量更新控制点，绘制曲线
        /// </summary>
        /// <param name="controlPoints"></param>
        public void DrawSpline(List<Vector2> controlPoints)
        {
            if (controlPoints.Count < 2)
            {
                LogProxy.LogError("控制点数量不足");
                return;
            }

            if (controlPoints.Count > s_ControlPointsNum)
            {
                LogProxy.LogError("控制点数量超出上限");
                return;
            }
            
            m_ControlPoints.Clear();

            foreach (var p in controlPoints)
            {
                m_ControlPoints.Add(p);
            }
                
            SetVerticesDirty();
            SetMaterialDirty(); 
        }

        /// <summary>
        /// 更新控制点
        /// </summary>
        /// <param name="controlPoints"></param>
        public void UpdateControlPoint(int index, Vector2 pos)
        {
            if (index < 0 || index >= m_ControlPoints.Count)
            {
                LogProxy.LogError("非法索引");
                return;
            }

            m_ControlPoints[index] = pos;
            SetVerticesDirty();
            // SetMaterialDirty();
        }
        
        protected override void UpdateMaterial()
        {
            if (!IsActive())
                return;
            switch (m_SplineType)
            {
                case SplineType.LinearSpline:
                    ApplyLinearSplineProp();
                    break;
                case SplineType.CatmullRomSpline:
                    ApplyCatmullRomSplineProp();
                    break;
                case SplineType.BerzierSpline:
                    ApplyBezierSplineProp();
                    break;
                case SplineType.BSpline:
                    ApplyBSplineSplineProp();
                    break;
            }
            canvasRenderer.materialCount = 1;
            canvasRenderer.SetMaterial(materialForRendering, 0);
        }
        
        protected override void OnPopulateMesh(VertexHelper toFill)
        {
            toFill.Clear();
            switch (m_SplineType)
            {
                case SplineType.LinearSpline:
                    GenerateLinearSplineMesh(toFill);
                    break;
                case SplineType.CatmullRomSpline:
                    GenerateCatmullRomSplineMesh(toFill);
                    break;
                case SplineType.BerzierSpline:
                    GenerateBezierSplineMesh(toFill);
                    break;
                case SplineType.BSpline:
                    GenerateBSplineSplineMesh(toFill);
                    break;
            }
        }

        protected abstract void GenerateLinearSplineMesh(VertexHelper toFill);
        protected abstract void GenerateCatmullRomSplineMesh(VertexHelper toFill);
        protected abstract void GenerateBezierSplineMesh(VertexHelper toFill);
        protected abstract void GenerateBSplineSplineMesh(VertexHelper toFill);

        protected abstract void ApplyLinearSplineProp();
        protected abstract void ApplyCatmullRomSplineProp();
        protected abstract void ApplyBezierSplineProp();
        protected abstract void ApplyBSplineSplineProp();
        
        /*    Quad
         *    2 ----- 1
         *      | \ |
         *    3 ----- 0
         */
        protected void AddQuad(VertexHelper toFill, Vector3[] vertices, Color32 color32, int i)
        {
            int startIndex = toFill.currentVertCount;
            
            toFill.AddVert(vertices[0], color32, new Vector2(i, i));
            toFill.AddVert(vertices[1], color32, new Vector2(i, i));
            toFill.AddVert(vertices[2], color32, new Vector2(i, i));
            toFill.AddVert(vertices[3], color32, new Vector2(i, i));
            
            toFill.AddTriangle(startIndex, startIndex + 1, startIndex + 2);
            toFill.AddTriangle(startIndex + 2, startIndex + 3, startIndex);
        }
        
        
        protected void AddQuad(VertexHelper toFill, Vector4 aabb2D, Color32 color32, int i)
        {
            int startIndex = toFill.currentVertCount;
            
            toFill.AddVert(new Vector3(aabb2D.x, aabb2D.y), color32, new Vector2(i, i));
            toFill.AddVert(new Vector3(aabb2D.x, aabb2D.w), color32, new Vector2(i, i));
            toFill.AddVert(new Vector3(aabb2D.z, aabb2D.w), color32, new Vector2(i, i));
            toFill.AddVert(new Vector3(aabb2D.z, aabb2D.y), color32, new Vector2(i, i));
            
            toFill.AddTriangle(startIndex, startIndex + 1, startIndex + 2);
            toFill.AddTriangle(startIndex + 2, startIndex + 3, startIndex);
        }

        protected void AddQuad(VertexHelper toFill, Vector3[] vertices, Color32 color32, Vector2[] uvs)
        {
            int startIndex = toFill.currentVertCount;
            
            toFill.AddVert(vertices[0], color32, uvs[0]);
            toFill.AddVert(vertices[1], color32, uvs[1]);
            toFill.AddVert(vertices[2], color32, uvs[2]);
            toFill.AddVert(vertices[3], color32, uvs[3]);
            
            toFill.AddTriangle(startIndex, startIndex + 1, startIndex + 2);
            toFill.AddTriangle(startIndex + 2, startIndex + 3, startIndex);
        }

        protected void AddQuad(VertexHelper toFill, Vector3[] vertices, Color32 color32, Vector2[] uvs, Vector4[] tangents)
        {
            int startIndex = toFill.currentVertCount;
            toFill.AddVert(vertices[0], color32, uvs[0],Vector2.zero, Vector2.zero, tangents[0]);
            toFill.AddVert(vertices[1], color32, uvs[1],Vector2.zero, Vector2.zero, tangents[1]);
            toFill.AddVert(vertices[2], color32, uvs[2],Vector2.zero, Vector2.zero, tangents[2]);
            toFill.AddVert(vertices[3], color32, uvs[3],Vector2.zero, Vector2.zero, tangents[3]);
            
            toFill.AddTriangle(startIndex, startIndex + 1, startIndex + 2);
            toFill.AddTriangle(startIndex + 2, startIndex + 3, startIndex);
        }
        
        protected Vector4 TransformLocalToCanvasSpace(Vector3 localPos)
        {
            var worlPos = transform.TransformPoint(localPos);
            return rootCanvas.transform.InverseTransformPoint(worlPos);
        }

#if UNITY_EDITOR
        
        /// <summary>
        /// 从子级中 GameObject 坐标填充控制点
        /// </summary>
        public void FillControlPointsFromeChildren()
        {
            var dots = ListPool<RectTransform>.Get();
            m_ControlPoints.Clear();
            GetComponentsInChildren(dots);
            for (int i = 0; i < dots.Count; i++)
            {
                if (dots[i] != this.rectTransform)
                {
                    var pos = dots[i].localPosition;
                    m_ControlPoints.Add(pos);
                }
            }
            ListPool<RectTransform>.Release(dots);
        }

        /// <summary>
        /// 从子级中 GameObject 获取控制点，用于参考线的绘制
        /// </summary>
        public void FillControlPointsFromChildren(List<Vector3> controlPoints)
        {
            controlPoints.Clear();
            var dots = ListPool<RectTransform>.Get();
            GetComponentsInChildren(dots);
            for (int i = 0; i < dots.Count; i++)
            {
                if (dots[i] != this.rectTransform)
                {
                    controlPoints.Add(dots[i].position);
                }
            }
        }

        StringBuilder builder = new StringBuilder();
        public String GetControlPointsInfo()
        {
            builder.Clear();

            if (m_ControlPoints.Count < 1)
            {
                builder.AppendLine("Empty");
            }
            else
            {
                for (int i = 0; i < m_ControlPoints.Count; i++)
                {
                    var p = m_ControlPoints[i];
                    var p1 = TransformLocalToCanvasSpace(p);
                    builder.AppendLine($"(x={p.x}, y={p.y})-->(x={p1.x}, y={p1.y})");
                }
            }
            return builder.ToString();
        }
#endif
    }
}