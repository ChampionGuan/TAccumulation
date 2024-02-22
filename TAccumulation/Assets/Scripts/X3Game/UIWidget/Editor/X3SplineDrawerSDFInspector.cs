using PapeGames.X3;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using X3Game;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(X3SplineDrawerSDF))]
    public class X3SplineDrawerSDFInspector : BaseInspector<X3SplineDrawerSDF>
    {
        private List<Vector3> m_Path = new List<Vector3>();
        private List<Vector3> m_ControlPoints = new List<Vector3>();
        private X3SplineDrawerSDF m_Drawer;
        private X3SplineDrawerSDF drawer
        {
            get
            {
                if(m_Drawer == null)
                {
                    m_Drawer = target as X3SplineDrawerSDF;
                }
                return m_Drawer;
            }
        }

        public override void OnInspectorGUI()
        {
            drawer.splineType = (SplineType)EditorGUILayout.EnumPopup("曲线类型", drawer.splineType);

            drawer.LineWidth = EditorGUILayout.FloatField("曲线宽度", drawer.LineWidth);

            drawer.color = EditorGUILayout.ColorField("曲线颜色", drawer.color);

            drawer.lineWidthCurve = EditorGUILayout.CurveField("曲线线宽函数", drawer.lineWidthCurve);
            
            if (GUILayout.Button("绘制曲线"))
            {
                drawer.FillControlPointsFromeChildren();
                // drawer.DrawSpline();
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