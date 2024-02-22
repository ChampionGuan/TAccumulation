using UnityEngine;
using UnityEditorInternal;
using UnityEditor;
using X3Game;
using PapeGames.X3Editor;
using PapeGames.X3;
using PapeGames.X3UI;

namespace X3GameEditor
{
    [CustomEditor(typeof(AnimGroup))]
    public class AnimaGroupEditor : BaseInspector<AnimGroup>
    {
        SerializedProperty m_PropAnimList;
        SerializedProperty m_PropAnimResolvedList;
        SerializedProperty m_PropLoopTimes;
        SerializedProperty m_PropProgress;
        ReorderableList m_RLAnimList;

        protected override void Init()
        {
            base.Init();
            m_PropAnimList = this.GetSP("m_AnimList");
            m_PropLoopTimes = this.GetSP("m_LoopTimes");
            m_PropProgress = this.GetSP("m_Progress");

            m_RLAnimList = new ReorderableList(serializedObject, m_PropAnimList, true, false, true, true);
            {
                m_RLAnimList.drawElementCallback = OnAnimListDrawElement;
                m_RLAnimList.onAddCallback = OnAnimListAdd;
                m_RLAnimList.drawHeaderCallback = (rect) => { DrawRLHeader(rect, "Anim List"); };
                m_RLAnimList.elementHeightCallback = AnimListItemHeight;
            }
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            if(AnimationMode.InAnimationMode())
            {
                EditorGUILayout.HelpBox("您正处于动画预览模式中！", MessageType.Warning);
            }

            EditorGUI.BeginDisabledGroup(true);
            this.DrawPF("m_UID");
            EditorGUI.EndDisabledGroup();
            this.DrawPF("m_Key");
            m_RLAnimList.DoLayoutList();
            EditorGUILayout.Space();
            this.DrawPF(m_PropLoopTimes);
            EditorGUILayout.Space();

            GUILayout.BeginHorizontal();
            if (GUILayout.Button("Refresh"))
            {
                m_Target.Refresh();
                StopPreviewMode();
            }
            if (GUILayout.Button("Play"))
            {
                StartPreviewMode();
                m_Target.Play();
            }
            if (GUILayout.Button("Stop"))
            {
                m_Target.Stop();
                StopPreviewMode();
            }
            GUILayout.EndHorizontal();
            float progress = m_PropProgress.floatValue * (float)m_Target.Duration;
            EditorGUILayout.LabelField(string.Format("Duration:{0:f3}/{1:f3}", progress, m_Target.Duration));
            EditorGUI.BeginChangeCheck();
            m_PropProgress.floatValue = GUILayout.HorizontalSlider(m_PropProgress.floatValue, 0, 1);
            if(EditorGUI.EndChangeCheck())
            {
                if (!AnimationMode.InAnimationMode())
                    StartPreviewMode();
                m_Target.Progress(m_PropProgress.floatValue);
                serializedObject.ApplyModifiedProperties();
            }

            EditorGUILayout.Space();
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("Debug Reset"))
            {
                m_Target.DebugReset();
                StopPreviewMode();
            }
            if (GUILayout.Button("Debug Play"))
            {
                StartPreviewMode();
                m_Target.DebugPlay();
            }
            if (GUILayout.Button("Debug Stop"))
            {
                m_Target.DebugStop();
                StopPreviewMode();
            }
            GUILayout.EndHorizontal();
            serializedObject.ApplyModifiedProperties();
        }

        void OnAnimListDrawElement(Rect rect, int index, bool selected, bool focused)
        {
            SerializedProperty propItem = m_PropAnimList.GetArrayElementAtIndex(index);
            SerializedProperty propType = propItem.FindPropertyRelative("Type");
            SerializedProperty propDelayType = propItem.FindPropertyRelative("DelayType");
            rect = new Rect(rect.x, rect.y + 5, rect.width, rect.height);
            if (propType.intValue == (int)AnimGroup.AnimationType.Animation)
            {
                rect = DrawRLVerticalItem(rect, index, m_PropAnimList,
                    new RLNameWidth("AC", "Clip", 100),
                    new RLNameWidth("Speed", 100),
                    new RLNameWidth("OutputTarget", 100),
                    new RLNameWidth("DelayAnchor", 100),
                    new RLNameWidth("DelayType", 100));
            }

            if (propDelayType.intValue == (int)AnimGroup.DelayType.Constant)
            {
                rect = DrawRLVerticalItem(rect, index, m_PropAnimList, new RLNameWidth("Delay", 100));
            }
            else if (propDelayType.intValue == (int)AnimGroup.DelayType.Random)
            {
                rect = DrawRLHorizontalItem(rect, index, m_PropAnimList, new RLPercentNameWidth(0.5f, "DelayMin", "Min", 40), new RLPercentNameWidth(0.5f, "DelayMax", "Max", 40));
            }

            rect = DrawRLVerticalItem(rect, index, m_PropAnimList, new RLNameWidth("PlayInLoop", 100));
        }

        void OnAnimListAdd(ReorderableList list)
        {
            ReorderableList.defaultBehaviours.DoAddButton(list);
            var item = list.serializedProperty.GetArrayElementAtIndex(list.serializedProperty.arraySize - 1);
            item.FindPropertyRelative("Type").intValue = (int)AnimGroup.AnimationType.Animation;
            item.FindPropertyRelative("Speed").floatValue = 1.0f;
            item.FindPropertyRelative("OutputTarget").objectReferenceValue = null;
            item.FindPropertyRelative("DelayAnchor").intValue = (int)AnimGroup.DelayAnchor.Last;
            item.FindPropertyRelative("AC").objectReferenceValue = null;
            item.FindPropertyRelative("PlayInLoop").boolValue = true;
        }

        float AnimListItemHeight(int index)
        {
            SerializedProperty propItem = m_PropAnimList.GetArrayElementAtIndex(index);
            SerializedProperty propType = propItem.FindPropertyRelative("Type");
            SerializedProperty propDelayType = propItem.FindPropertyRelative("DelayType");

            float height = 5;
            if (propType.intValue == (int)AnimGroup.AnimationType.Animation)
            {
                height += 140f;
            }

            if (propDelayType.intValue == (int)AnimGroup.DelayType.Constant)
            {
                height += 25f;
            }
            else if (propDelayType.intValue == (int)AnimGroup.DelayType.Random)
            {
                height += 25f;
            }
            return height;
        }

        void StartPreviewMode()
        {
            AnimationMode.StartAnimationMode();
            foreach (var info in m_Target.AnimList)
            {
                if (info.AC == null)
                    continue;
                GameObject animatedGO = info.OutputTarget == null ? m_Target.gameObject : info.OutputTarget;
                UIViewEditorHelper.CollectProperty(animatedGO, info.AC);
            }
        }

        void StopPreviewMode()
        {
            bool isIn = AnimationMode.InAnimationMode();
            AnimationMode.StopAnimationMode();
        }

        private void OnDisable()
        {
            StopPreviewMode();
        }
    }
}

