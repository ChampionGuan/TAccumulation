using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;
using PapeGames.X3;
using PapeGames.X3Editor;

namespace X3GameEditor
{
    [CustomEditor(typeof(X3Game.X3Animator))]
    public class X3AnimatorInspector : BaseInspector<X3Game.X3Animator>
    {
        SerializedProperty m_PropStateList;

        SerializedProperty m_PropWrapMode;
        SerializedProperty m_PropDefaultStateName;

        void DrawStateItem(SerializedProperty prop, int index)
        {
            SerializedProperty propItem = prop.GetArrayElementAtIndex(index);
            SerializedProperty propType = propItem.FindPropertyRelative("m_StateType");
            SerializedProperty propKeyFrameList = propItem.FindPropertyRelative("KeyFrameList");
            this.DrawPF(propType);
            this.DrawPF(propItem.FindPropertyRelative("m_StateName"));
            if (propType.intValue == (int)X3Game.X3Animator.StateType.AnimationClip)
            {
                this.DrawPF(propItem.FindPropertyRelative("m_AnimationClip"));
            }
            else if (propType.intValue == (int)X3Game.X3Animator.StateType.ProceduralAnimationClip)
            {
                this.DrawPF(propItem.FindPropertyRelative("m_ProceduralAnimationClip"));
            }
            else if (propType.intValue == (int)X3Game.X3Animator.StateType.CutScene)
            {
                this.DrawPF(propItem.FindPropertyRelative("m_CutSceneName"));
                this.DrawPF(propItem.FindPropertyRelative("m_InheritTransform"));
            }
            this.DrawPF(propItem.FindPropertyRelative("m_Loopable"));
            this.DrawPF(propItem.FindPropertyRelative("KeyFrameList"));
            EditorGUILayout.BeginHorizontal(HorizontalSytle);
            GUILayout.FlexibleSpace();
            if(GUILayout.Button("删除", GUILayout.ExpandWidth(false)))
            {
                if(EditorUtility.DisplayDialog("警告", "确定要删除此项吗？", "Okay", "Cancel"))
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
            this.DrawPF("m_Animator");
            this.DrawPF("m_RootBone");
            this.DrawPF("m_AssetId");
            if(Target.EmbededStateNames != null && Target.EmbededStateNames.Length > 0)
                this.DrawStringPopup(m_PropDefaultStateName, Target.EmbededStateNames, "没有任何状态");
            else
                this.DrawPF(m_PropDefaultStateName);
            
            this.DrawPF("m_DefaultTransitionDuration");
            this.DrawPF("m_DataProviderEnabled");
            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("状态列表");
            if (GUILayout.Button("+添加新状态"))
            {
                ExeAddStateItem();
            }
            EditorGUILayout.EndHorizontal();
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            EditorGUI.indentLevel++;
            for (int i=0; i< m_PropStateList.arraySize; i++)
            {
                DrawStateItem(m_PropStateList, i);
            }
            EditorGUI.indentLevel--;

            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            //m_RLStateList.DoLayoutList();
            EditorGUILayout.Space();
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("ControlRig");
            this.DrawPF("controlRigAsset");
            this.DrawPF("controlRigTarget");
            EditorGUILayout.Space();
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1.0f, Color.gray);
            EditorGUILayout.Space();

            serializedObject.ApplyModifiedProperties();
        }

        protected override void Init()
        {
            base.Init();
            m_PropStateList = this.GetSP("m_EmbeddedStateList");
            m_PropDefaultStateName = this.GetSP("m_DefaultStateName");
        }
        

        static GUIStyle s_HorizontalSytle;
        static GUIStyle HorizontalSytle
        {
            get
            {
                if(s_HorizontalSytle == null)
                {
                    s_HorizontalSytle = new GUIStyle(EditorStyles.inspectorDefaultMargins);
                    s_HorizontalSytle.alignment = TextAnchor.MiddleRight;
                }
                return s_HorizontalSytle;
            }
        }
    }
}