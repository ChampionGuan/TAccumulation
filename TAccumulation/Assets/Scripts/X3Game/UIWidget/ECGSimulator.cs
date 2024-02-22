using System;
using System.Collections;
using System.Collections.Generic;
using PapeGames;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Serialization;
using UnityEngine.UI;
using X3Game.PathTool;
using XLua;

namespace X3Game
{
    [LuaCallCSharp]
    public class ECGSimulator : MonoBehaviour
    {
        [SerializeField] private RectTransform m_parent;
        [SerializeField] private Material m_matrial;
        [SerializeField] private X3Image[] m_curveImage = new X3Image[2];
        [SerializeField] private X3PathToolAsset m_weakTemplate;
        [SerializeField] private X3PathToolAsset m_normalTemplate;
        [SerializeField] private X3PathToolAsset m_strongTemplate;
        [SerializeField] private float m_xSpeed = 300f;

        public enum StrengthType
        {
            Weak = 0,
            Normal,
            Strong,
        }

        private UnityAction m_onCrest = null;
        private float m_crestDistance = -1;

        private float m_x; // 当前曲线动画头部的屏幕 x 坐标
        private Vector2 m_size;
        private float m_yOffset;
        private Rect m_screenRect;

        private float[] m_defaultStartX;
        private float[] m_defaultEndX;
        private float[] m_defaultY;

        //private Material[] m_curveMats = new Material[2];

        // Shader Properties
        private readonly int m_ControlPointsXId = Shader.PropertyToID("_ControlPointsX");
        private readonly int m_ControlPointsYId = Shader.PropertyToID("_ControlPointsY");
        private readonly int m_CurvesNumId = Shader.PropertyToID("_CurvesNum");
        private readonly int m_UIImageWidthId = Shader.PropertyToID("_UIImageWidth");
        private readonly int m_CurrentXId = Shader.PropertyToID("_CurrentX");

        static readonly Vector3[] s_WorldCorners = new Vector3[4];
        static readonly Vector3[] s_ScreenCorners = new Vector3[4];

        private Canvas m_rootCanvas;

        private float xMin
        {
            get => m_screenRect.xMin;
        }

        private float xMax
        {
            get => m_screenRect.xMax;
        }
        
        private float yMin
        {
            get => m_screenRect.yMin;
        }


        private Camera m_UICamera;
        private Camera uiCam
        {
            get
            {
                if (m_UICamera == null)
                {
                    m_UICamera = RTUtility.FindUICamera(GetComponent<RectTransform>());
                }

                return m_UICamera;
            }
        }


        static Rect GetCanvasRect(RectTransform t, Camera uiCamera)
        {
            if (uiCamera == null)
                return new Rect();

            t.GetWorldCorners(s_WorldCorners);
            for (int i = 0; i < 4; ++i)
                s_ScreenCorners[i] = uiCamera.WorldToScreenPoint(s_WorldCorners[i]);

            return new Rect(s_ScreenCorners[0].x, s_ScreenCorners[0].y, s_ScreenCorners[2].x - s_ScreenCorners[0].x,
                s_ScreenCorners[2].y - s_ScreenCorners[0].y);
        }

        struct CtrlPoints
        {
            public int length;
            public float[] x;
            public float[] y;
        };

        private int m_startIdx = 0;
        private CtrlPoints[] m_paths = new CtrlPoints[2];
        private bool m_nextEditted = false;
        private CtrlPoints m_nextPath = new CtrlPoints();

        private bool isValid
        {
            get => m_parent != null && m_curveImage != null && m_curveImage.Length >= 2 && m_curveImage[0] != null &&
                   m_curveImage[1] != null && m_weakTemplate != null && m_normalTemplate != null &&
                   m_strongTemplate != null;
        }

        private bool m_isInit = false;

        void Awake()
        {
            if (!m_isInit)
            {
                Clear();
            }
        }

        void Update()
        {
            if (!isValid)
                return;
            m_x += Time.deltaTime * m_xSpeed;
            if (!Mathf.Approximately(m_crestDistance, -1) && m_onCrest != null)
            {
                m_crestDistance -= Time.deltaTime * m_xSpeed;
                if (m_crestDistance <= 0)
                {
                    m_onCrest.Invoke();
                    m_onCrest = null;
                    m_crestDistance = -1;
                }
            }

            if (m_x > xMax)
            {
                m_x = xMin;
                m_startIdx = (m_startIdx + 1) % 2;
                InitPath(m_startIdx);
            }

            m_curveImage[m_startIdx].material.SetFloat(m_CurrentXId, m_x);
            m_curveImage[(m_startIdx + 1) % 2].material.SetFloat(m_CurrentXId, m_x + m_screenRect.width);
        }

        public void Beat(int strength, UnityAction onCrest = null)
        {
            if (!isValid)
                return;
            m_onCrest = onCrest;
            AddCurve((StrengthType)strength);
        }

        public void AddCurveTest()
        {
            if (!isValid)
                return;
            for (int i = 6; i < 9; i++)
            {
                m_paths[m_startIdx].x[i] = m_paths[m_startIdx].x[i - 3];
                m_paths[m_startIdx].y[i] = m_paths[m_startIdx].y[i - 3];
            }

            m_paths[m_startIdx].x[3] = 0.5f * m_screenRect.width - 1;
            m_paths[m_startIdx].x[4] = 0.5f * m_screenRect.width;
            m_paths[m_startIdx].x[5] = 0.5f * m_screenRect.width + 1;
            m_paths[m_startIdx].y[3] = 0.75f * m_screenRect.height;
            m_paths[m_startIdx].y[4] = 0.75f * m_screenRect.height;
            m_paths[m_startIdx].y[5] = 0.75f * m_screenRect.height;

            m_paths[m_startIdx].length = 9;
            ApplyPath(m_startIdx);
        }

        void AddCurve(StrengthType strength)
        {
            if (!isValid)
                return;
            BezierSpline spline;

            switch (strength)
            {
                case StrengthType.Weak:
                    spline = m_weakTemplate.Spline;
                    break;
                case StrengthType.Strong:
                    spline = m_strongTemplate.Spline;
                    break;
                default:
                    spline = m_normalTemplate.Spline;
                    break;
            }

            int insertPos = 0;
            int crestX = 0;

            for (;
                insertPos * 3 < m_paths[m_startIdx].length && m_paths[m_startIdx].x[insertPos * 3 + 1] <= m_x;
                insertPos++) ;

            int overflowIdx = -1;
            float maxY = 0;
            m_nextEditted = false;
            for (int i = 0; i < spline.PointCount; i++)
            {
                var p = spline.GetControlPoint(i);
                m_paths[m_startIdx].x[insertPos * 3 + i * 3] = GetPointX(p.InPoint.x);
                m_paths[m_startIdx].y[insertPos * 3 + i * 3] = GetPointY(p.InPoint.y);
                m_paths[m_startIdx].x[insertPos * 3 + i * 3 + 1] = GetPointX(p.Position.x);
                m_paths[m_startIdx].y[insertPos * 3 + i * 3 + 1] = GetPointY(p.Position.y);
                m_paths[m_startIdx].x[insertPos * 3 + i * 3 + 2] = GetPointX(p.OutPoint.x);
                m_paths[m_startIdx].y[insertPos * 3 + i * 3 + 2] = GetPointY(p.OutPoint.y);

                if (m_paths[m_startIdx].y[insertPos * 3 + i * 3] > maxY)
                {
                    maxY = m_paths[m_startIdx].y[insertPos * 3 + i * 3 + 1];
                    m_crestDistance = p.Position.x;
                }

                if (overflowIdx == -1 && m_paths[m_startIdx].x[insertPos * 3 + i * 3 + 1] > xMax)
                {
                    overflowIdx = i;
                }
            }

            m_paths[m_startIdx].length = (insertPos + spline.PointCount) * 3 + 3;

            m_paths[m_startIdx].x[m_paths[m_startIdx].length - 2] =
                Mathf.Max(xMax, m_paths[m_startIdx].x[m_paths[m_startIdx].length - 5]) + 1;
            m_paths[m_startIdx].x[m_paths[m_startIdx].length - 3] =
                m_paths[m_startIdx].x[m_paths[m_startIdx].length - 2] - 1;
            m_paths[m_startIdx].x[m_paths[m_startIdx].length - 1] =
                m_paths[m_startIdx].x[m_paths[m_startIdx].length - 2] + 1;

            m_paths[m_startIdx].y[m_paths[m_startIdx].length - 3] = m_yOffset;
            m_paths[m_startIdx].y[m_paths[m_startIdx].length - 2] = m_yOffset;
            m_paths[m_startIdx].y[m_paths[m_startIdx].length - 1] = m_yOffset;

            ApplyPath(m_startIdx);

            if (overflowIdx != -1)
            {
                m_nextPath.length = (spline.PointCount - overflowIdx) * 3 + 6;

                for (int i = 0; i < spline.PointCount - overflowIdx; i++)
                {
                    m_nextPath.x[3 * (i + 1)] =
                        m_paths[m_startIdx].x[(overflowIdx + insertPos + i) * 3] - m_screenRect.width;
                    m_nextPath.x[3 * (i + 1) + 1] =
                        m_paths[m_startIdx].x[(overflowIdx + insertPos + i) * 3 + 1] - m_screenRect.width;
                    m_nextPath.x[3 * (i + 1) + 2] =
                        m_paths[m_startIdx].x[(overflowIdx + insertPos + i) * 3 + 2] - m_screenRect.width;

                    m_nextPath.y[3 * (i + 1)] = m_paths[m_startIdx].y[(overflowIdx + insertPos + i) * 3];
                    m_nextPath.y[3 * (i + 1) + 1] = m_paths[m_startIdx].y[(overflowIdx + insertPos + i) * 3 + 1];
                    m_nextPath.y[3 * (i + 1) + 2] = m_paths[m_startIdx].y[(overflowIdx + insertPos + i) * 3 + 2];
                }

                m_nextPath.x[m_nextPath.length - 2] = Mathf.Max(xMax, m_nextPath.x[m_nextPath.length - 5]) + 1;
                m_nextPath.x[m_nextPath.length - 1] = m_nextPath.x[m_nextPath.length - 2] + 1;
                m_nextPath.x[m_nextPath.length - 3] = m_nextPath.x[m_nextPath.length - 2] - 1;

                m_nextPath.y[m_nextPath.length - 1] = m_yOffset;
                m_nextPath.y[m_nextPath.length - 2] = m_yOffset;
                m_nextPath.y[m_nextPath.length - 3] = m_yOffset;

                m_nextEditted = true;
            }
        }

        private float GetPointX(float x)
        {
            return m_x + x;
        }

        private float GetPointY(float y)
        {
            return m_yOffset + y;
        }

        public void Clear()
        {
            if (!isValid)
                return;
            
            m_onCrest = null;
            
            m_curveImage[0].material =new Material(m_matrial);
            m_curveImage[1].material = new Material(m_matrial);

            m_screenRect = GetCanvasRect(m_parent, uiCam);

            m_yOffset = yMin + 0.5f * m_screenRect.height;
            m_startIdx = 0;
            m_x = xMin;
            
            m_paths[0].x = new float[300];
            m_paths[0].y = new float[300];
            m_paths[1].x = new float[300];
            m_paths[1].y = new float[300];
            m_nextPath.x = new float[300];
            m_nextPath.y = new float[300];

            m_nextPath.x[0] = xMin - 1;
            m_nextPath.x[1] = xMin;
            m_nextPath.x[2] = xMin + 1;
            for (int i = 0; i < 3; i++)
            {
                m_nextPath.y[i] = m_yOffset;
            }

            InitPath();
            m_isInit = true;
        }

        void InitPath(int idx = -1)
        {
            if (!isValid)
                return;
            
            if (idx == -1 || idx == m_startIdx)
            {
                if (m_nextEditted)
                {
                    m_nextPath.x.CopyTo(m_paths[m_startIdx].x, 0);
                    m_nextPath.y.CopyTo(m_paths[m_startIdx].y, 0);
                    m_paths[m_startIdx].length = m_nextPath.length;

                    m_nextEditted = false;
                    m_nextPath.length = 0;
                }
                else
                {
                    m_paths[m_startIdx].x[0] = xMin - 1;
                    m_paths[m_startIdx].x[1] = xMin;
                    m_paths[m_startIdx].x[2] = xMin + 1;
                    m_paths[m_startIdx].x[3] = xMax - 1;
                    m_paths[m_startIdx].x[4] = xMax;
                    m_paths[m_startIdx].x[5] = xMax + 1;

                    for (int i = 0; i < 6; i++)
                    {
                        m_paths[m_startIdx].y[i] = m_yOffset;
                    }

                    m_paths[m_startIdx].length = 6;
                }
            }

            if (idx == -1 || idx == (m_startIdx + 1) % 2)
            {
                m_paths[(m_startIdx + 1) % 2].x[0] = xMax;
                m_paths[(m_startIdx + 1) % 2].x[1] = xMax + 1;
                m_paths[(m_startIdx + 1) % 2].x[2] = xMax + 2;
                m_paths[(m_startIdx + 1) % 2].x[3] = xMax + 3;
                m_paths[(m_startIdx + 1) % 2].x[4] = xMax + 4;
                m_paths[(m_startIdx + 1) % 2].x[5] = xMax + 5;
                for (int i = 0; i < 6; i++)
                {
                    m_paths[(m_startIdx + 1) % 2].y[i] = m_yOffset;
                }

                m_paths[(m_startIdx + 1) % 2].length = 6;
            }

            ApplyPath(idx);
        }

        void ApplyPath(int idx = -1)
        {
            if (!isValid)
                return;
            if (idx == -1 || idx == m_startIdx)
            {
                var mat = m_curveImage[m_startIdx].material;
                mat.SetFloatArray(m_ControlPointsXId, m_paths[m_startIdx].x);
                mat.SetFloatArray(m_ControlPointsYId, m_paths[m_startIdx].y);
                mat.SetInt(m_CurvesNumId, m_paths[m_startIdx].length / 3 - 1);
                mat.SetFloat(m_UIImageWidthId, m_screenRect.width * 2);
            }

            if (idx == -1 || idx == (m_startIdx + 1) % 2)
            {
                var mat = m_curveImage[(m_startIdx + 1) % 2].material;
                mat.SetFloatArray(m_ControlPointsXId, m_paths[(m_startIdx + 1) % 2].x);
                mat.SetFloatArray(m_ControlPointsYId, m_paths[(m_startIdx + 1) % 2].y);
                mat.SetInt(m_CurvesNumId, m_paths[(m_startIdx + 1) % 2].length / 3 - 1);
                mat.SetFloat(m_UIImageWidthId, m_screenRect.width * 2);
            }
        }
    }
}