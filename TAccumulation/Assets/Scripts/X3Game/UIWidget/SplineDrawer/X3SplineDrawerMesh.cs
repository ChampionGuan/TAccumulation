using System;
using System.Collections.Generic;
using UnityEngine.UI;
using PapeGames.X3;
using Unity.Collections;
using UnityEditor;
using UnityEngine;

namespace X3Game
{
    public class X3SplineDrawerMesh : X3SplineDrawerBase
    {
        #region Main Texture
        public enum MainTexFillMode
        {
            Simple,
            Loop
        }
        
        [SerializeField] private MainTexFillMode m_FillMode = MainTexFillMode.Loop;
        [SerializeField] private Texture2D m_MainTex;
        private static readonly int s_MainTexID = Shader.PropertyToID("_MainTex");
        
        public Texture2D mainTex
        {
            get { return m_MainTex; }
            set
            {
                m_MainTex = value;
                SetMaterialDirty();
            }
        }
        #endregion

        #region Time Flow
        [SerializeField] private bool m_IsTimeFlow = false;
        [SerializeField] private float m_TimeFlowSpeed = 5f;
        [SerializeField] private float m_TimeOffset = 0.01f;
        private static readonly int s_TimeFlowSpeed = Shader.PropertyToID("_TimeFlowSpeed");
        private static readonly int s_TimeOffset = Shader.PropertyToID("_TimeOffset");
        #endregion
        
        #region Vertex Wave
        public enum VertexWaveMode
        {
            Longitudinal,
            Transverse,
        }
        
        [SerializeField] private bool m_IsVertexWave = false;
        [SerializeField] private VertexWaveMode m_VertexWaveMode = VertexWaveMode.Transverse;
        
        [SerializeField] private float m_VertexWaveSpeed = 0f;
        [SerializeField] private float m_VertexWaveAmplitude = 1f;
        [SerializeField] private float m_VertexWaveFreq = 1f;
        
        private static readonly int s_VertexWaveSpeedID = Shader.PropertyToID("_VertexWaveSpeed");
        private static readonly int s_VertexWaveAmplitudeID = Shader.PropertyToID("_VertexWaveAmplitude");
        private static readonly int s_VertexWaveFreqID = Shader.PropertyToID("_VertexWaveFreq");
        #endregion

        #region Color Gradient
        [SerializeField] private bool m_IsColorGradient = false;
        
        [SerializeField] private Color32 m_ColorBegin = Color.white;
        [SerializeField] private Color32 m_ColorEnd = Color.black;
        
        private static readonly int s_ColorBeginID = Shader.PropertyToID("_ColorBegin");
        private static readonly int s_ColorEndID = Shader.PropertyToID("_ColorEnd");
        #endregion

        #region Spline Style
        [SerializeField] private bool m_IsFadeOut = true;
        
        [SerializeField] private int m_Smoothness = 16;
        [SerializeField] private Vector4 m_FadeOutDistance = Vector4.one;
        
        private int m_SegmentNum = -1;
        
        private static readonly int s_SegmentNumID = Shader.PropertyToID("_SegmentNum");
        private static readonly int s_FadoutDistanceID = Shader.PropertyToID("_FadoutDistance");
        
        /// <summary>
        /// 曲线水平和垂直两个方向的淡出区里
        /// X = Left
        /// Y = Right
        /// Z = Top
        /// W = Bottom
        /// </summary>
        public Vector4 fadeoutDistance
        {
            get { return m_FadeOutDistance; }
            set
            {
                m_FadeOutDistance = value;
                UpdateFadeOutDistance();
            }
        }
        #endregion

        #region Curve Anim
        private bool m_PlayCurveAnim = true;
        private float animProgress = 0f;
        private float animScale = 0.1f;
        #endregion

        #region Spline Material

        private Shader m_SplineMeshShader;
        public override Material defaultMaterial
        {
            get
            {
                if (m_SplineDefaultMaterial == null)
                {
                    if (!m_SplineMeshShader)
                    {
                        m_SplineMeshShader = Res.Load<Shader>("Assets/Build/Res/SourceRes/Shader/Spline/UI-SplineMesh.shader");
                    }
                    if(!m_SplineMeshShader)
                        m_SplineDefaultMaterial = Canvas.GetDefaultCanvasMaterial();
                    else
                        m_SplineDefaultMaterial = new Material(m_SplineMeshShader);
                }
                return m_SplineDefaultMaterial;
            }
        }

        #endregion

        #region Flowing Light

        [SerializeField] private bool m_IsFlowingLight = false;
        [SerializeField] private Color32 m_LightColor = Color.white;
        [SerializeField] private float m_LightLength = 0.6f;
        [SerializeField] private float m_LightSharpness = 0.02f;
        
        
        private static readonly int s_LightColor = Shader.PropertyToID("_LightColor");
        private static readonly int s_LightLength = Shader.PropertyToID("_LightLength");
        private static readonly int s_LightSharpness = Shader.PropertyToID("_LightSharpness");
        

        #endregion

        private List<Vector3> m_AnimPath = new List<Vector3>();

        protected override void GenerateLinearSplineMesh(VertexHelper toFill)
        {
            m_SegmentNum = m_ControlPoints.Count - 1;
            GenerateTriangleStrip(toFill, m_ControlPoints);
        }

        protected override void GenerateCatmullRomSplineMesh(VertexHelper toFill)
        {
            m_AnimPath.Clear();
            SplineHelper.DrawCatmullRomSpline(m_AnimPath, m_ControlPoints, m_Smoothness);
            m_SegmentNum = m_AnimPath.Count - 1;
            GenerateTriangleStrip(toFill, m_AnimPath);
        }

        protected override void GenerateBezierSplineMesh(VertexHelper toFill)
        {
            m_AnimPath.Clear();
            SplineHelper.DrawBezierSpline(m_AnimPath, m_ControlPoints, m_Smoothness);
            m_SegmentNum = m_AnimPath.Count - 1;
            GenerateTriangleStrip(toFill, m_AnimPath);
        }

        protected override void GenerateBSplineSplineMesh(VertexHelper toFill)
        {
            m_AnimPath.Clear();
            SplineHelper.DrawBSpline(m_AnimPath, m_ControlPoints, m_Smoothness);
            m_SegmentNum = m_AnimPath.Count - 1;
            GenerateTriangleStrip(toFill, m_AnimPath);
        }

        private void GenerateTriangleStrip(VertexHelper toFill, List<Vector3> path)
        {
            Vector3[] vertices = new Vector3[4];
            Vector2[] uvs = new Vector2[4];
            Vector4[] tangents = new Vector4[4];

            for (int i = 1; i < path.Count; i++)
            {
                float time1 = (i - 1) / (float)(path.Count - 1);
                float time2 = i / (float)(path.Count - 1);
                
                Vector3 line = path[i] - path[i - 1];
                if(line.magnitude < 0.001)
                    continue;
                line = line.normalized;
                float lineWidth = m_LineWidthCurve.Evaluate(time1) * m_LineWidth;
                
                Vector3 lineNormal = Vector3.Cross(line, Vector3.forward).normalized;
                Vector3 quadTangent0 = lineNormal;
                Vector3 quadTangent1 = lineNormal;

                if (i == 1) // 第一段
                {
                    if (path.Count >= 3)
                    {
                        Vector3 v1 = (path[i + 1] - path[i]).normalized;
                        quadTangent1 = (v1 - line).normalized;
                    }
                }
                else if (i == path.Count - 1)  // 最后一段
                {
                    if (path.Count >= 3)
                    {
                        Vector3 v0 = (path[i - 2] - path[i - 1]).normalized;
                        quadTangent0 = (line + v0).normalized;
                    }
                }
                else
                {
                    if (path.Count >= 4)
                    {
                        Vector3 v0 = (path[i - 2] - path[i - 1]).normalized;
                        Vector3 v1 = (path[i + 1] - path[i]).normalized;
                        quadTangent0 = (v0 + line).normalized;
                        quadTangent1 = (v1 - line).normalized;
                    }
                }

                if (quadTangent0.magnitude < 0.001) quadTangent0 = lineNormal;
                if (quadTangent1.magnitude < 0.001) quadTangent1 = lineNormal;
                
                
                float offset0 = lineWidth, offset1 = lineWidth;
                float theta0 = Vector3.Dot(quadTangent0, lineNormal);
                float theta1 = Vector3.Dot(quadTangent1, lineNormal);
                if (Mathf.Abs(theta0) - 0.01f > 0)
                {
                    offset0 = lineWidth / theta0;
                }

                if (Mathf.Abs(theta1) - 0.01f > 0)
                {
                    offset1 = lineWidth / theta1;
                }

                vertices[0] = path[i - 1] + quadTangent0 * offset0;
                vertices[3] = path[i - 1] - quadTangent0 * offset0;
                vertices[1] = path[i] + quadTangent1 * offset1;
                vertices[2] = path[i] - quadTangent1 * offset1;
                
                tangents[0] = (quadTangent0 * offset0).normalized;
                tangents[3] = -(quadTangent0 * offset0).normalized;
                tangents[1] = (quadTangent1 * offset1).normalized;
                tangents[2] = -(quadTangent1 * offset1).normalized;
                
                tangents[0].w = 1;
                tangents[3].w = -1;
                tangents[1].w = 1;
                tangents[2].w = -1;
                
                uvs[0] = new Vector2(0, time1);
                uvs[1] = new Vector2(0, time2);
                uvs[2] = new Vector2(1, time2);
                uvs[3] = new Vector2(1, time1);
                AddQuad(toFill, vertices, color, uvs, tangents);
            }
        }

        protected override void ApplyLinearSplineProp()
        {
            ApplyMatProp();
        }

        protected override void ApplyCatmullRomSplineProp()
        {
            ApplyMatProp();
        }

        protected override void ApplyBezierSplineProp()
        {
            ApplyMatProp();
        }

        protected override void ApplyBSplineSplineProp()
        {
            ApplyMatProp();
        }
        
        protected X3SplineDrawerMesh()
        {
            useLegacyMeshGeneration = false;
        }

        private void ApplyMatProp()
        {
            if (m_Material == null)
            {
                if (m_SegmentNum < 2)
                {
                    LogProxy.LogError("样条线路径节点不足");
                    return;
                }
                material.SetFloat(s_SegmentNumID, m_SegmentNum);
                UpdateMainTex();
                UpdateFadeOutDistance();
                UpdateGradientColor();
                UpdateVertexWave();
                UpdateTimeFlow();
                UpdateFlowingLight();
            }
        }

        public void UpdateMainTex()
        {
            if (m_FillMode == MainTexFillMode.Loop)
            {
                if(m_MainTex != null)
                    m_MainTex.wrapMode = TextureWrapMode.Repeat;
                material.EnableKeyword("MAIN_TEX_LOOP");
            }
            else
            {
                material.DisableKeyword("MAIN_TEX_LOOP");
            }
            material.SetTexture(s_MainTexID, m_MainTex);
        }

        public void UpdateFadeOutDistance()
        {
            if (m_IsFadeOut)
            {
                material.EnableKeyword("FADE_OUT_ON");
                material.SetVector(s_FadoutDistanceID, m_FadeOutDistance);
            }
            else
            {
                material.DisableKeyword("FADE_OUT_ON");
            }
        }

        public void UpdateGradientColor()
        {
            if (m_IsColorGradient)
            {
                material.EnableKeyword("COLOR_GRADIENT");
                material.SetColor(s_ColorBeginID, m_ColorBegin);
                material.SetColor(s_ColorEndID, m_ColorEnd);
            }
            else
            {
                material.DisableKeyword("COLOR_GRADIENT");
            }
        }

        public void UpdateVertexWave()
        {
            if (m_IsVertexWave)
            {
                material.EnableKeyword("VERTEX_WAVE");
                if (m_VertexWaveMode == VertexWaveMode.Longitudinal)
                {
                    material.EnableKeyword("VERTEX_LONGITUDINAL_WAVE");
                }
                else
                {
                    material.DisableKeyword("VERTEX_LONGITUDINAL_WAVE");
                }
                material.SetFloat(s_VertexWaveSpeedID, m_VertexWaveSpeed);
                material.SetFloat(s_VertexWaveAmplitudeID, m_VertexWaveAmplitude);
                material.SetFloat(s_VertexWaveFreqID, m_VertexWaveFreq);
            }
            else
            {
                material.DisableKeyword("VERTEX_WAVE");
            }
        }

        public void UpdateTimeFlow()
        {
            if (m_IsTimeFlow)
            {
                material.EnableKeyword("TIME_FLOW");
                material.SetFloat(s_TimeFlowSpeed, m_TimeFlowSpeed);
                material.SetFloat(s_TimeOffset, m_TimeOffset);
            }
            else
            {
                material.DisableKeyword("TIME_FLOW");
            }
        }

        public void UpdateFlowingLight()
        {
            if (m_IsTimeFlow && m_IsFlowingLight)
            {
                material.EnableKeyword("FLOWING_LIGHT");
                material.SetColor(s_LightColor, m_LightColor);
                material.SetFloat(s_LightLength, m_LightLength);
                material.SetFloat(s_LightSharpness, m_LightSharpness);
               
            }
            else
            {
                material.DisableKeyword("FLOWING_LIGHT");
            }
        }

        public void SetSplineMeshMaterial(Material mat)
        {
            material = mat;
        }
    }
}