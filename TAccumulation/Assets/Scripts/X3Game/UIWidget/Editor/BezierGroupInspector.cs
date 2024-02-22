using System.Collections;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;
using X3Game.PathTool;
using X3Game;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(X3BezierGroup))]
    public class BezierGroupInspector : PapeGames.CutScene.Editor.BaseInspector<X3BezierGroup>
    {
        SerializedProperty m_PropTargets;
        ReorderableList m_RLList;
        Dictionary<string, float> m_TestTimes = new Dictionary<string, float>();

        protected override void Init()
        {
            m_PropTargets = this.GetSP("m_Targets");

            m_RLList = new ReorderableList(serializedObject, m_PropTargets, true, true, true, true);
            m_RLList.drawHeaderCallback = DrawHeaderCallback;
            m_RLList.drawElementCallback = DrawCallback;
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            
            m_RLList.DoLayoutList();

            if (GUILayout.Button("Open Editor Tool"))
            {
                GameObject editTarget = null;
                if (m_PropTargets.arraySize > 0)
                {
                    var targetProp = m_PropTargets.GetArrayElementAtIndex(0);
                    editTarget = (GameObject) targetProp.FindPropertyRelative("Target").objectReferenceValue;
                }

                X3PathToolEditorWindow.OpenWindowByBezierGroup(editTarget, m_Target.Spline, m_Target.FixZ, m_Target.SetUpdateSpline);
            }
            
            this.DrawPF("m_FixZ");
            this.DrawPF("m_Spline");
            serializedObject.ApplyModifiedProperties();
        }

        private void DrawHeaderCallback(Rect rect)
        {
            try
            {
                float w1 = (rect.width - 8) * 0.3f;
                float w2 = (rect.width - 8) * 0.3f;
                float w3 = (rect.width - 8) * 0.4f;
                EditorGUI.LabelField(new Rect(rect.x, rect.y, w1, rect.height), "Key", HeaderGUIStyle);
                EditorGUI.LabelField(new Rect(rect.x + w1 + 4, rect.y, w2, rect.height), "Target",
                    HeaderGUIStyle);
                EditorGUI.LabelField(new Rect(rect.x + w1 + w2 + 4, rect.y, w3, rect.height), "XProgress",
                    HeaderGUIStyle);
            }
            catch
            {
            }
        }
        
        private void DrawCallback(Rect rect, int index, bool selected, bool focused)
        {
            float w1 = (rect.width - 16) * 0.3f;
            float w2 = (rect.width - 16) * 0.3f;
            float w3 = (rect.width - 16) * 0.4f;

            SerializedProperty item = m_PropTargets.GetArrayElementAtIndex(index);
            var key = item.FindPropertyRelative("Key");
            var Target = item.FindPropertyRelative("Target");
            
            Rect keyRect = new Rect(rect.x, rect.y + 3, w1, rect.height);
            Rect TargetRect = new Rect(rect.x + w1 + 8, rect.y + 2, w2, rect.height - 4);
            Rect TimeRect = new Rect(rect.x + w1 + w2 + 16, rect.y + 2, w3, rect.height - 4);

            key.stringValue = EditorGUI.TextField(keyRect, key.stringValue);
            EditorGUI.PropertyField(TargetRect, Target, GUIContent.none);
            
            if (!m_TestTimes.ContainsKey(key.stringValue))
                m_TestTimes[key.stringValue] = 0;
            
            EditorGUI.BeginChangeCheck();
            m_TestTimes[key.stringValue] = EditorGUI.Slider(TimeRect, m_TestTimes[key.stringValue], 0, 1);

            var targetItem = (GameObject) Target.objectReferenceValue;
            if (EditorGUI.EndChangeCheck() && targetItem != null)
            {
                m_Target.SetTargetPosEditorOnly(key.stringValue, m_TestTimes[key.stringValue]);
            }
        }
        
        private GUIStyle m_HeaderGUIStyle;

        private GUIStyle HeaderGUIStyle
        {
            get
            {
                if (m_HeaderGUIStyle == null)
                {
                    m_HeaderGUIStyle = new GUIStyle(EditorStyles.label);
                    m_HeaderGUIStyle.alignment = TextAnchor.MiddleCenter;
                }

                return m_HeaderGUIStyle;
            }
        }
    }
}