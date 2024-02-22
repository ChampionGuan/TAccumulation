using PapeGames.X3;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using PapeGames.X3Editor;
using X3Game;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(X3SplineDrawerMesh))]
    public class X3SplineDrawerMeshInspector : BaseInspector<X3SplineDrawerMesh>
    {
        private bool m_IsShowControlPos = false;
        
        private List<Vector3> m_Path = new List<Vector3>();
        private List<Vector3> m_ControlPoints = new List<Vector3>();

        private GUIContent m_SplineTypeContent;
        private GUIContent m_MainTexFillModeContent;
        private GUIContent m_MainTexContent;
        private GUIContent m_LineWidthContent;
        private GUIContent m_LineColorContent;
        private GUIContent m_LineWidthCurveContent;
        private GUIContent m_IsFadeOutContent;
        private GUIContent m_FadeoutDistanceContent;
        private GUIContent m_SmoothnessContent;
        private GUIContent m_IsColorGradientContent;
        private GUIContent m_ColorBeginContent;
        private GUIContent m_ColorEndContent;
        private GUIContent m_IsVertexWaveContent;
        private GUIContent m_VertexWaveModeContent;
        private GUIContent m_VertexWaveSpeedConent;
        private GUIContent m_VertexWaveAmplitudeConent;
        private GUIContent m_VertexWaveFreqConent;
        private GUIContent m_IsTimeFlowContent;
        private GUIContent m_TimeFlowSpeedContent;
        private GUIContent m_MaterialContent;
        
        private SerializedProperty m_SplineType;
        
        private SerializedProperty m_MainTex;
        private SerializedProperty m_MainTexFillMode;

        private SerializedProperty m_IsTimeFlow;
        private SerializedProperty m_TimeFlowSpeed;
        private SerializedProperty m_TimeOffset;

        private SerializedProperty m_IsVertexWave;
        private SerializedProperty m_VertexWaveMode;
        private SerializedProperty m_VertexWaveSpeed;
        private SerializedProperty m_VertexWaveAmplitude;
        private SerializedProperty m_VertexWaveFreq;

        private SerializedProperty m_IsColorGradient;
        private SerializedProperty m_ColorBegin;
        private SerializedProperty m_ColorEnd;
        
        private X3SplineDrawerMesh m_Drawer;
        private SerializedProperty m_Positions;
        private X3SplinePositionsView m_PositionsView;
        
        private SerializedProperty m_LineWidth;
        private SerializedProperty m_LineColor;
        private SerializedProperty m_LineWidthFunction;
        private SerializedProperty m_IsFadeOut;
        private SerializedProperty m_FadeoutDistance;
        private SerializedProperty m_Smoothness;

        private SerializedProperty m_Material;

        private SerializedProperty m_IsFlowingLight;
        private SerializedProperty m_LightColor;
        private SerializedProperty m_LightLength;
        private SerializedProperty m_LightSharpness;

        private SerializedProperty m_Maskable;
        
        
        private X3SplineDrawerMesh drawer
        {
            get
            {
                if(m_Drawer == null)
                {
                    m_Drawer = target as X3SplineDrawerMesh;
                }
                return m_Drawer;
            }
        }
        
        protected override void OnEnable()
        {
            m_SplineType = serializedObject.FindProperty("m_SplineType");
            
            m_MainTex = serializedObject.FindProperty("m_MainTex");
            m_MainTexFillMode = serializedObject.FindProperty("m_FillMode");

            m_IsTimeFlow = serializedObject.FindProperty("m_IsTimeFlow");
            m_TimeFlowSpeed = serializedObject.FindProperty("m_TimeFlowSpeed");
            m_TimeOffset = serializedObject.FindProperty("m_TimeOffset");

            m_IsVertexWave = serializedObject.FindProperty("m_IsVertexWave");
            m_VertexWaveMode = serializedObject.FindProperty("m_VertexWaveMode");
            m_VertexWaveSpeed = serializedObject.FindProperty("m_VertexWaveSpeed");
            m_VertexWaveAmplitude = serializedObject.FindProperty("m_VertexWaveAmplitude");
            m_VertexWaveFreq = serializedObject.FindProperty("m_VertexWaveFreq");

            m_IsColorGradient = serializedObject.FindProperty("m_IsColorGradient");
            m_ColorBegin = serializedObject.FindProperty("m_ColorBegin");
            m_ColorEnd = serializedObject.FindProperty("m_ColorEnd");
            
            m_Positions = serializedObject.FindProperty("m_ControlPoints");
            m_PositionsView = new X3SplinePositionsView(m_Positions);
            m_PositionsView.splineDrawer = drawer;
            
            m_LineWidth = serializedObject.FindProperty("m_LineWidth");
            m_LineColor = serializedObject.FindProperty("m_LineColor");
            m_LineWidthFunction = serializedObject.FindProperty("m_LineWidthCurve");
            m_IsFadeOut = serializedObject.FindProperty("m_IsFadeOut");
            m_FadeoutDistance = serializedObject.FindProperty("m_FadeOutDistance");
            m_Smoothness = serializedObject.FindProperty("m_Smoothness");

            m_Material = serializedObject.FindProperty("m_Material");

            m_IsFlowingLight = serializedObject.FindProperty("m_IsFlowingLight");
            m_LightColor = serializedObject.FindProperty("m_LightColor");
            m_LightLength = serializedObject.FindProperty("m_LightLength");
            m_LightSharpness = serializedObject.FindProperty("m_LightSharpness");

            m_Maskable = serializedObject.FindProperty("m_Maskable");

            m_MaterialContent = EditorGUIUtility.TrTextContent("曲线材质");
            m_SplineTypeContent = EditorGUIUtility.TrTextContent("曲线类型");
            m_MainTexFillModeContent = EditorGUIUtility.TrTextContent("曲线贴图填充模式");
            m_MainTexContent = EditorGUIUtility.TrTextContent("曲线贴图");
            m_LineWidthContent = EditorGUIUtility.TrTextContent("曲线宽度");
            m_LineColorContent = EditorGUIUtility.TrTextContent("曲线颜色");
            m_LineWidthCurveContent = EditorGUIUtility.TrTextContent("曲线线宽函数", "time 取值范围 [0,1], value 取值范围 (0,+inf)");
            m_IsFadeOutContent = EditorGUIUtility.TrTextContent("是否开启曲线边缘模糊");
            m_FadeoutDistanceContent = EditorGUIUtility.TrTextContent("曲线边缘模糊距离");
            m_SmoothnessContent = EditorGUIUtility.TrTextContent("曲线平滑程度");
            m_IsColorGradientContent = EditorGUIUtility.TrTextContent("曲线颜色渐变");
            m_ColorBeginContent = EditorGUIUtility.TrTextContent("曲线渐变起始颜色");
            m_ColorEndContent = EditorGUIUtility.TrTextContent("曲线终止起始颜色");
            m_IsVertexWaveContent = EditorGUIUtility.TrTextContent("曲线波动动画");
            m_VertexWaveModeContent = EditorGUIUtility.TrTextContent("曲线波动模式");
            m_VertexWaveSpeedConent = EditorGUIUtility.TrTextContent("曲线波动速度");
            m_VertexWaveAmplitudeConent = EditorGUIUtility.TrTextContent("曲线波动振幅");
            m_VertexWaveFreqConent = EditorGUIUtility.TrTextContent("曲线波动频率");
            m_IsTimeFlowContent = EditorGUIUtility.TrTextContent("曲线流动");
            m_TimeFlowSpeedContent = EditorGUIUtility.TrTextContent("曲线流速");
            
        }

        public override void OnInspectorGUI()
        {
            DoSplineTypeGUI();
            DoLineStyleGUI();
            DoMaterialGUI();
            if (m_Material.objectReferenceValue == null)
            {
                DoMainTextureGUI();
                DoFadeoutGUI();
                DOColorGradientGUI();
                DoVertexWaveGUI();
                DoTimeFlowGUI();
            }
            
            DoDebugGUI();
            serializedObject.ApplyModifiedProperties();
        }

        void DoPositionView()
        {
            if (m_Positions.arraySize != m_PositionsView.GetRows().Count)
            {
                m_PositionsView.Reload();
            }
            m_PositionsView.OnGUI(EditorGUILayout.GetControlRect(false, m_PositionsView.totalHeight));
        }

        private void OnSceneGUI()
        {
            if (m_Path.Count > 2)
            {
                for (int i = 0; i < m_Path.Count - 1; i++)
                {
                    Handles.color = Color.cyan;
                    Handles.DrawLine(m_Path[i], m_Path[i + 1]);
                }
            }
        }

        private void DoSplineTypeGUI()
        {
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_SplineType, m_SplineTypeContent);
            if (EditorGUI.EndChangeCheck())
            {
                drawer.SetAllDirty();
            }
        }
        
        private void DoMainTextureGUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_MainTex, m_MainTexContent);
            EditorGUILayout.PropertyField(m_MainTexFillMode, m_MainTexFillModeContent);
            if (EditorGUI.EndChangeCheck())
            {
                //drawer.UpdateMainTex();
            }
            
            EditorGUILayout.EndVertical();
        }

        private void DoLineStyleGUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_LineWidth, m_LineWidthContent);
            EditorGUILayout.PropertyField(m_LineWidthFunction);
            EditorGUILayout.PropertyField(m_LineColor, m_LineColorContent);
            EditorGUILayout.PropertyField(m_Smoothness, m_SmoothnessContent);
            if (EditorGUI.EndChangeCheck())
            {
                //drawer.SetVerticesDirty();
            }
            EditorGUILayout.EndVertical();
        }

        private void DoFadeoutGUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_IsFadeOut, m_IsFadeOutContent);
            if(m_IsFadeOut.boolValue)
                EditorGUILayout.PropertyField(m_FadeoutDistance, m_FadeoutDistanceContent);
            if (EditorGUI.EndChangeCheck())
            {
                //drawer.UpdateFadeOutDistance();
            }
            EditorGUILayout.EndVertical();
        }

        private void DOColorGradientGUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.PropertyField(m_IsColorGradient, m_IsColorGradientContent);
            if (m_IsColorGradient.boolValue)
            {
                EditorGUILayout.PropertyField(m_ColorBegin, m_ColorBeginContent);
                EditorGUILayout.PropertyField(m_ColorEnd, m_ColorEndContent);
            }
            EditorGUILayout.EndVertical();
        }

        private void DoVertexWaveGUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.PropertyField(m_IsVertexWave, m_IsVertexWaveContent);
            if (m_IsVertexWave.boolValue)
            {
                EditorGUILayout.PropertyField(m_VertexWaveMode, m_VertexWaveModeContent);
                EditorGUILayout.PropertyField(m_VertexWaveSpeed, m_VertexWaveSpeedConent);
                EditorGUILayout.PropertyField(m_VertexWaveAmplitude, m_VertexWaveAmplitudeConent);
                EditorGUILayout.PropertyField(m_VertexWaveFreq, m_VertexWaveFreqConent);
            }
            EditorGUILayout.EndVertical();
        }

        private void DoTimeFlowGUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.PropertyField(m_IsTimeFlow, m_IsTimeFlowContent);
            if (m_IsTimeFlow.boolValue)
            {
                EditorGUILayout.PropertyField(m_TimeFlowSpeed, m_TimeFlowSpeedContent);
                EditorGUILayout.PropertyField(m_TimeOffset);
                EditorGUILayout.PropertyField(m_IsFlowingLight);
                if (m_IsFlowingLight.boolValue)
                {
                    EditorGUILayout.PropertyField(m_LightColor);
                    EditorGUILayout.PropertyField(m_LightLength);
                    EditorGUILayout.PropertyField(m_LightSharpness);
                }
            }
            EditorGUILayout.EndVertical();
        }

        private void DoMaterialGUI()
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUI.BeginChangeCheck();
            // EditorGUILayout.PropertyField(m_IsCustomMaterial, m_IsCustomMaterialContent);
            EditorGUILayout.PropertyField(m_Material, m_MaterialContent);
            EditorGUILayout.PropertyField(m_Maskable);
            EditorGUILayout.EndVertical();
        }

        private void DoDebugGUI()
        {
            m_IsShowControlPos = EditorGUILayout.Toggle("显示曲线控制节点", m_IsShowControlPos);
            if (m_IsShowControlPos)
            {
                DoPositionView();
            }
            if (GUILayout.Button("绘制曲线"))
            {
                drawer.FillControlPointsFromeChildren();
                drawer.SetAllDirty();
            }
            GUILayout.Label("绘制参考线");
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("Catmull-Rom Spline"))
            {
                drawer.FillControlPointsFromChildren(m_ControlPoints);
                SplineHelper.DrawCatmullRomSpline(m_Path, m_ControlPoints);
            }
            if (GUILayout.Button("Bezier Spline"))
            {
                drawer.FillControlPointsFromChildren(m_ControlPoints);
                SplineHelper.DrawBezierSpline(m_Path, m_ControlPoints);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("B Spline"))
            {
                drawer.FillControlPointsFromChildren(m_ControlPoints);
                SplineHelper.DrawBSpline(m_Path, m_ControlPoints);
            }
            if (GUILayout.Button("NURBS"))
            {
                drawer.FillControlPointsFromChildren(m_ControlPoints);
                SplineHelper.DrawNurbs(m_Path, m_ControlPoints);
            }
            GUILayout.EndHorizontal();
        }
    }
}