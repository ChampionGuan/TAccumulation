using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEditorInternal;
using PapeGames.X3Editor;

namespace X3Game.SceneGesture
{
    [CustomEditor(typeof(X3SceneCharacterGesture))]
    public class X3SceneCharacterGestureInspector : BaseInspector<X3SceneCharacterGesture>
    {
        SerializedProperty m_PropStaticStateList;
        SerializedProperty m_PropAnimCtrlStateList;
        SerializedProperty m_PropDefaultState;
        ReorderableList m_StaticStateRLList;
        ReorderableList m_AnimCtrlStateRLList;

        private string m_StateName = "";
        private bool m_InitCamera = true;
        private bool m_InitPos = true;
        private float m_Duration = 3f;

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            DrawGestureSetting();
            DrawTargetSetting();
            DrawStatesTransition();
            DrawStates();
            DrawSwitchStateTest();
            serializedObject.ApplyModifiedProperties();
        }

        void DrawTargetSetting()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("Target设置");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;

            this.DrawPF("m_TargetRoot");
            this.DrawPF("m_Pivot");
            this.DrawPF("m_RotateType");
            this.DrawPF("m_TargetDragCoefficient");
            this.DrawPF("m_TargetDragDamp");
            this.DrawPF("m_TargetMaxSpeed");
            this.DrawPF("m_TargetMinRestoreSpeed");

            EditorGUI.indentLevel--;
        }

        void DrawStatesTransition()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("过渡设置");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;

            this.DrawPF("m_BlendType");
            this.DrawPF("m_CustomCurve");
            this.DrawPF("m_DefaultSwitchDuration");

            EditorGUI.indentLevel--;
        }

        void DrawStates()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("状态列表");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            PapeGames.X3Editor.X3EditorGUILayout.Label("静态机位列表");
            m_StaticStateRLList.DoLayoutList();
            PapeGames.X3Editor.X3EditorGUILayout.Label("动画机位列表");
            m_AnimCtrlStateRLList.DoLayoutList();
            if (GUILayout.Button("刷新状态"))
            {
                RefreshStates();
            }

            this.DrawPF(m_PropDefaultState);

            EditorGUI.indentLevel--;
        }

        void RefreshStates()
        {
            m_PropStaticStateList.ClearArray();
            m_PropAnimCtrlStateList.ClearArray();
            
            var staticStates = m_Target.gameObject.GetComponentsInChildren<StaticCamState>(true);
            if (staticStates != null)
            {
                foreach (var state in staticStates)
                {
                    m_PropStaticStateList.arraySize++;
                    m_PropStaticStateList.GetArrayElementAtIndex(m_PropStaticStateList.arraySize - 1)
                        .objectReferenceValue = state;
                }
            }
            
            var animCtrlStates = m_Target.gameObject.GetComponentsInChildren<AnimCtrlCamState>(true);
            if (animCtrlStates != null)
            {
                foreach (var state in animCtrlStates)
                {
                    m_PropAnimCtrlStateList.arraySize++;
                    m_PropAnimCtrlStateList.GetArrayElementAtIndex(m_PropAnimCtrlStateList.arraySize - 1)
                        .objectReferenceValue = state;
                }
            }
        }

        void DrawGestureSetting()
        { 
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("是否接收手势");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            this.DrawPF("m_DetectGesture");
            EditorGUI.indentLevel--;
        }
        void DrawSwitchStateTest()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("状态切换测试");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;
            m_StateName = PapeGames.X3Editor.X3EditorGUILayout.TextField("StateName", m_StateName);
            m_InitCamera = PapeGames.X3Editor.X3EditorGUILayout.Toggle("InitCamera", m_InitCamera);
            m_InitPos = PapeGames.X3Editor.X3EditorGUILayout.Toggle("InitPos", m_InitPos);
            m_Duration = PapeGames.X3Editor.X3EditorGUILayout.FloatField("Duration", m_Duration);

            if (GUILayout.Button("状态切换"))
            {
                m_Target.SwitchState(m_StateName, m_Duration, m_InitPos, m_InitCamera);
            }

            EditorGUI.indentLevel--;
        }

        protected override void Init()
        {
            m_PropStaticStateList = this.GetSP("m_StaticStates");
            m_PropAnimCtrlStateList = this.GetSP("m_AnimCtrlStates");
            m_PropDefaultState = this.GetSP("m_DefaultStateKey");
            m_StaticStateRLList = new ReorderableList(serializedObject, m_PropStaticStateList, true, true, true, true);
            m_StaticStateRLList.drawHeaderCallback = DrawHeaderCallback;
            m_StaticStateRLList.drawElementCallback = StaticStateDrawCallback;
            m_StaticStateRLList.onAddCallback = StaticStateOnAddCallback;
            m_StaticStateRLList.onRemoveCallback = OnRemoveCallback;

            m_AnimCtrlStateRLList =
                new ReorderableList(serializedObject, m_PropAnimCtrlStateList, true, true, true, true);
            m_AnimCtrlStateRLList.drawHeaderCallback = DrawHeaderCallback;
            m_AnimCtrlStateRLList.drawElementCallback = AnimCtrlStateDrawCallback;
            m_AnimCtrlStateRLList.onAddCallback = AnimCtrlStateOnAddCallback;
            m_AnimCtrlStateRLList.onRemoveCallback = OnRemoveCallback;
        }

        private void DrawHeaderCallback(Rect rect)
        {
            try
            {
                float w1 = (rect.width - 8) * 0.3f;
                float w2 = (rect.width - 8) * 0.5f;
                float w3 = (rect.width - 8) * 0.2f;
                EditorGUI.LabelField(new Rect(rect.x, rect.y, w1, rect.height), "Key", HeaderGUIStyle);
                EditorGUI.LabelField(new Rect(rect.x + w1 + 4, rect.y, w2, rect.height), "State",
                    HeaderGUIStyle);
                EditorGUI.LabelField(new Rect(rect.x + w1 + w2 + 4, rect.y, w3, rect.height), "IsDefault",
                    HeaderGUIStyle);
            }
            catch
            {
            }
        }

        private void StaticStateDrawCallback(Rect rect, int index, bool selected, bool focused)
        {
            DrawElementCallback(m_PropStaticStateList, rect, index, selected, focused);
        }

        private void AnimCtrlStateDrawCallback(Rect rect, int index, bool selected, bool focused)
        {
            DrawElementCallback(m_PropAnimCtrlStateList, rect, index, selected, focused);
        }

        private void DrawElementCallback(SerializedProperty stateList, Rect rect, int index, bool selected,
            bool focused)
        {
            float w1 = (rect.width - 8) * 0.3f;
            float w2 = (rect.width - 8) * 0.5f;
            float w3 = (rect.width - 8) * 0.2f;

            SerializedProperty item = stateList.GetArrayElementAtIndex(index);
            StateBase state = (StateBase) item.objectReferenceValue;
            Rect keyRect = new Rect(rect.x, rect.y + 3, w1, rect.height);
            Rect stateRect = new Rect(rect.x + w1 + 4, rect.y + 2, w2, rect.height - 4);
            Rect toggleRect = new Rect(rect.x + w1 + w2 + 4, rect.y + 2, w3, rect.height - 4);

            if (state != null)
            {
                state.Key = EditorGUI.TextField(keyRect, state.Key);
                EditorGUI.PropertyField(stateRect, item, GUIContent.none);
                var toggle = EditorGUI.Toggle(toggleRect, m_PropDefaultState.stringValue == state.Key);
                if (toggle)
                {
                    m_PropDefaultState.stringValue = state.Key;
                }
            }
            else
            {
                EditorGUI.BeginDisabledGroup(true);
                EditorGUI.TextField(keyRect, "");
                EditorGUI.EndDisabledGroup();
                EditorGUI.PropertyField(stateRect, item, GUIContent.none);
                EditorGUI.BeginDisabledGroup(true);
                EditorGUI.Toggle(toggleRect, false);
                EditorGUI.EndDisabledGroup();
            }
        }
        
        private void StaticStateOnAddCallback(ReorderableList list)
        {
            ReorderableList.defaultBehaviours.DoAddButton(list);
            SerializedProperty property =
                list.serializedProperty.GetArrayElementAtIndex(list.serializedProperty.arraySize - 1);
            property.objectReferenceValue = X3SceneCharacterGestureEditorHelper.CreateStaticCamera(m_Target.transform);
        }

        private void AnimCtrlStateOnAddCallback(ReorderableList list)
        {
            ReorderableList.defaultBehaviours.DoAddButton(list);
            SerializedProperty property =
                list.serializedProperty.GetArrayElementAtIndex(list.serializedProperty.arraySize - 1);
            property.objectReferenceValue = X3SceneCharacterGestureEditorHelper.CreateAnimCtrlCamera(m_Target.transform);
        }

        private void OnRemoveCallback(ReorderableList list)
        {
            SerializedProperty property = list.serializedProperty.GetArrayElementAtIndex(list.index);
            var state = (StateBase) property.objectReferenceValue;
            if (state != null)
            {
                DestroyImmediate(state.gameObject);
            }
            property.objectReferenceValue = null;
            ReorderableList.defaultBehaviours.DoRemoveButton(list);
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