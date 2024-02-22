using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEditorInternal;
using PapeGames.X3Editor;
using PapeGames.X3;
using X3Game;

namespace X3GameEditor
{
    [CustomEditor(typeof(X3AnimatorAsset))]
    public class X3AnimatorAssetInspector : BaseInspector<X3AnimatorAsset>
    {
        SerializedProperty m_PropStateList;
        SerializedProperty m_PropDefaultStateName;
        string[] m_StateNames;

        void DrawStateItem(SerializedProperty prop, int index)
        {
            SerializedProperty propItem = prop.GetArrayElementAtIndex(index);
            SerializedProperty propType = propItem.FindPropertyRelative("m_StateType");
            SerializedProperty propKeyFrameList = propItem.FindPropertyRelative("KeyFrameList");
            this.DrawPF(propType);
            this.DrawPF(propItem.FindPropertyRelative("m_StateName"));
            if (propType.intValue == (int)X3Animator.StateType.AnimationClip)
            {
                this.DrawPF(propItem.FindPropertyRelative("m_AnimationClip"));
            }
            else if (propType.intValue == (int)X3Animator.StateType.ProceduralAnimationClip)
            {
                this.DrawPF(propItem.FindPropertyRelative("m_ProceduralAnimationClip"));
            }
            else if (propType.intValue == (int)X3Animator.StateType.CutScene)
            {
                this.DrawPF(propItem.FindPropertyRelative("m_CutSceneName"));
                this.DrawPF(propItem.FindPropertyRelative("m_InheritTransform"));
            }

            this.DrawPF(propItem.FindPropertyRelative("m_Loopable"));
            this.DrawPF(propItem.FindPropertyRelative("KeyFrameList"));
            EditorGUILayout.BeginHorizontal(HorizontalSytle);
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("删除", GUILayout.ExpandWidth(false)))
            {
                if (EditorUtility.DisplayDialog("警告", "确定要删除此项吗？", "Okay", "Cancel"))
                {
                    prop.DeleteArrayElementAtIndex(index);
                }
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.Space();
        }

        void ExeAddStateItem()
        {
            m_PropStateList.InsertArrayElementAtIndex(m_PropStateList.arraySize);
            SerializedProperty propItem = m_PropStateList.GetArrayElementAtIndex(m_PropStateList.arraySize - 1);

            propItem.FindPropertyRelative("KeyFrameList").ClearArray();
            propItem.FindPropertyRelative("m_StateName").stringValue = "";
            propItem.FindPropertyRelative("m_AnimationClip").objectReferenceValue = null;
            propItem.FindPropertyRelative("m_ProceduralAnimationClip").objectReferenceValue = null;
            propItem.FindPropertyRelative("m_CutSceneName").stringValue = "";
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            this.DrawPF("RootBoneName");
            this.DrawPF("AssetId");
            if (m_StateNames != null && m_StateNames.Length > 0)
                this.DrawStringPopup(m_PropDefaultStateName, m_StateNames, "没有任何状态");
            else
                this.DrawPF(m_PropDefaultStateName);
            
            this.DrawPF("DefaultTransitionDuration");
            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("状态列表");
            if (GUILayout.Button("+添加新状态"))
            {
                ExeAddStateItem();
                UpdateStateNames();
            }
            EditorGUILayout.EndHorizontal();
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            EditorGUI.indentLevel++;
            EditorGUI.BeginChangeCheck();
            for (int i = 0; i < m_PropStateList.arraySize; i++)
            {
                DrawStateItem(m_PropStateList, i);
            }
            if(EditorGUI.EndChangeCheck())
            {
                UpdateStateNames();
            }
            EditorGUI.indentLevel--;

            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            EditorGUILayout.Space();
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("ControlRig");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            this.DrawPF("ControlRigAsset");
            this.DrawPF("ControlRigTargetBoneName");

            serializedObject.ApplyModifiedProperties();
        }

        protected override void Init()
        {
            base.Init();
            m_PropStateList = this.GetSP("EmbeddedStateList");
            m_PropDefaultStateName = this.GetSP("DefaultStateName");
            UpdateStateNames();
        }

        private void UpdateStateNames()
        {
            m_StateNames = new string[Target.EmbeddedStateList.Count];
            for (int i = 0; i < Target.EmbeddedStateList.Count; i++)
            {
                m_StateNames[i] = Target.EmbeddedStateList[i].StateName;
            }
        }

        static GUIStyle s_HorizontalSytle;
        static GUIStyle HorizontalSytle
        {
            get
            {
                if (s_HorizontalSytle == null)
                {
                    s_HorizontalSytle = new GUIStyle(EditorStyles.inspectorDefaultMargins);
                    s_HorizontalSytle.alignment = TextAnchor.MiddleRight;
                }
                return s_HorizontalSytle;
            }
        }
    }
}