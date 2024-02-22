using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using PapeGames.X3;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(X3Game.X3CharacterGesture))]
    public class X3CharacterGestureInspector : BaseInspector<X3Game.X3CharacterGesture>
    {
        private SerializedProperty m_PropWithDOF;
        
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("机位点");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            this.DrawPF("m_FarCamPoint");
            this.DrawPF("m_FarRefTF");
            var rect = EditorGUILayout.GetControlRect(false, GUILayout.Height(30));
            rect.x = rect.width - 80;
            rect.width = 80;
            rect.height = 24;
            if (GUI.Button(rect, "应用到相机"))
            {
                m_Target.ApplyFarCamPoint();
            }

            this.DrawPF("m_MiddleCamPoint");
            this.DrawPF("m_MiddleRefTF");
            rect = EditorGUILayout.GetControlRect(false, GUILayout.Height(30));
            rect.x = rect.width - 80;
            rect.width = 80;
            rect.height = 24;
            if (GUI.Button(rect, "应用到相机"))
            {
                m_Target.ApplyMiddleCamPoint();
            }

            this.DrawPF("m_NearUpCamPoint");
            this.DrawPF("m_NearUpRefTF");
            rect = EditorGUILayout.GetControlRect(false, GUILayout.Height(30));
            rect.x = rect.width - 80;
            rect.width = 80;
            rect.height = 24;
            if (GUI.Button(rect, "应用到相机"))
            {
                m_Target.ApplyNearUpCamPoint();
            }

            this.DrawPF("m_NearDownCamPoint");
            this.DrawPF("m_NearDownRefTF");
            rect = EditorGUILayout.GetControlRect(false, GUILayout.Height(30));
            rect.x = rect.width - 80;
            rect.width = 80;
            rect.height = 24;
            if (GUI.Button(rect, "应用到相机"))
            {
                m_Target.ApplyNearDownCamPoint();
            }

            this.DrawPF("m_MToNCurve", "");
            EditorGUI.indentLevel--;

            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("拖动");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            this.DrawPF("m_DragCoeffient");
            this.DrawPF("m_DragDamp");
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("缩放");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            this.DrawPF("m_PinchCoeffient");
            this.DrawPF("m_PinchDamp");
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("入场/出场");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            this.DrawPF("m_MoveInSpeed");
            EditorGUILayout.HelpBox("MoveIn的时间区间，根据“距离/速度”后再从区间内取值", MessageType.None);
            this.DrawPF("m_MoveInDuration");
            this.DrawPF("m_MoveInEase");
            this.DrawPF("m_MoveInCurve");
            this.DrawPF("m_MoveInFOVCurve");
            this.DrawPF("m_MoveOutSpeed");
            EditorGUILayout.HelpBox("MoveOut的时间区间，根据“距离/速度”后再从区间内取值", MessageType.None);
            this.DrawPF("m_MoveOutDuration");
            this.DrawPF("m_MoveOutEase");
            this.DrawPF("m_MoveOutCurve");
            this.DrawPF("m_MoveOutScreenScale");
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("其它");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            this.DrawPF("m_Cam");
            this.DrawPF("m_Target");
            this.DrawPF("m_PivotTF");
            EditorGUILayout.Space();
            EditorGUI.indentLevel--;
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("景深");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            this.DrawPF(m_PropWithDOF);
            if (m_PropWithDOF.boolValue)
            {
                this.DrawPF("m_NearDOFInfo");
                this.DrawPF("m_FarDOFInfo");
                this.DrawPF("m_DOFCurve");
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("测试");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUILayout.BeginHorizontal();
            EditorGUI.BeginDisabledGroup(!Application.isPlaying);
            if(PapeGames.X3Editor.X3EditorGUILayout.Button("入场"))
            {
                m_Target.MoveIn();
            }

            if (PapeGames.X3Editor.X3EditorGUILayout.Button("出场"))
            {
                m_Target.MoveOut();
            }
            EditorGUI.EndDisabledGroup();
            EditorGUILayout.EndHorizontal();
            serializedObject.ApplyModifiedProperties();
        }

        protected override void Init()
        {
            m_PropWithDOF = this.GetSP("m_WithDOF");
        }
    }
}

