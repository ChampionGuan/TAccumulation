using System;
using System.Collections.Generic;
using PapeGames;
using UnityEngine;
using UnityEditor;
using PapeGames.X3;
using PapeGames.X3Editor;

namespace X3Game.SceneGesture
{
    [CustomEditor(typeof(AnimCtrlCamState))]
    public class AnimCtrlCamStateInspector : BaseInspector<AnimCtrlCamState>
    {
        private SerializedProperty m_PropWithDOF;
        private SerializedProperty m_PropClipDefault;
        private SerializedProperty m_PropClipUp;
        private SerializedProperty m_PropClipDown;
        private SerializedProperty m_PropSeperateTime;

        private SerializedProperty m_DragUpMagnification;
        private SerializedProperty m_DragDownMagnification;
        private SerializedProperty m_DragType;

        private bool m_IsClipChanged = false;

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            m_IsClipChanged = false;
            DrawBasicInfo();
            DrawAnimInfo();
            DragGestureInfo();
            DrawDOFInfo();

            serializedObject.ApplyModifiedProperties();
            if (m_IsClipChanged)
            {
                m_Target.OnClipChanged();
            }
        }

        protected override void Init()
        {
            m_PropWithDOF = this.GetSP("m_DOFEnable");
            m_PropClipDefault = this.GetSP("m_ClipDefault");
            m_PropClipUp = this.GetSP("m_ClipUp");
            m_PropClipDown = this.GetSP("m_ClipDown");
            m_PropSeperateTime = this.GetSP("m_SeparateTime");
            m_DragUpMagnification = this.GetSP("m_DragUpMagnification");
            m_DragDownMagnification = this.GetSP("m_DragDownMagnification");
            m_DragType = this.GetSP("m_DragType");
        }

        void DrawBasicInfo()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("基本信息");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;

            this.DrawPF("m_EditMode");
            this.DrawPF("m_Key");
            this.DrawPF("m_TargetInitPos");
            this.DrawPF("m_TargetInitRot");
            this.DrawPF("m_TargetControllable");
            
            this.DrawPF("m_MinRestoreSpeedWeight");
            this.DrawPF("m_MinRestoreSpeedTime");
            
            this.DrawPF(m_DragType);
            if (m_DragType.enumValueIndex == (int)AnimCtrlCamState.DragType.CustomCurve)
            {
                this.DrawPF("m_CustomDragCurve");
            }

            if (m_DragType.enumValueIndex == (int)AnimCtrlCamState.DragType.Elastic)
            {
                this.DrawPF("m_WeightBounds");
            }

            EditorGUI.indentLevel--;
        }

        void DrawAnimInfo()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("动画配置");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;

            EditorGUI.BeginChangeCheck();
            this.DrawPF(m_PropClipDefault);
            this.DrawPF(m_PropClipUp);
            this.DrawPF(m_PropClipDown);

            var clipDefault = (AnimationClip) m_PropClipDefault.objectReferenceValue;
            var clipUp = (AnimationClip) m_PropClipUp.objectReferenceValue;
            var clipDown = (AnimationClip) m_PropClipDown.objectReferenceValue;
            if (EditorGUI.EndChangeCheck())
            {
                m_PropSeperateTime.floatValue = GetSeparateTime(clipDefault, clipUp, clipDown);
                m_IsClipChanged = true;
                UpdateDragMagnification(clipDefault, clipUp, clipDown);
                m_Target.Rebuild();
            }

            if (clipDefault == null)
            {
                EditorGUILayout.HelpBox("请设置默认相机移动动画或改用静态机位", MessageType.Error);
            }

            if (clipDefault != null && clipUp != null && !clipDefault.length.Equals(clipUp.length))
            {
                EditorGUILayout.HelpBox("ClipUp长度与默认相机移动动画长度不一致，请检查", MessageType.Warning);
            }

            if (clipDefault != null && clipDown != null && !clipDefault.length.Equals(clipDown.length))
            {
                EditorGUILayout.HelpBox("ClipDown长度与默认相机移动动画长度不一致，请检查", MessageType.Warning);
            }

            if (clipDefault != null && clipDefault.isLooping)
            {
                EditorGUILayout.HelpBox("请将ClipUp设置为非循环", MessageType.Warning);
            }

            if (clipUp != null && clipUp.isLooping)
            {
                EditorGUILayout.HelpBox("请将ClipUp设置为非循环", MessageType.Warning);
            }

            if (clipDown != null && clipDown.isLooping)
            {
                EditorGUILayout.HelpBox("请将ClipDown设置为非循环", MessageType.Warning);
            }

            EditorGUI.BeginChangeCheck();
            EditorGUI.BeginDisabledGroup(clipDefault == null);
            this.DrawPF("m_InitTime", "Init Time[Normalized]");
            EditorGUI.EndDisabledGroup();

            if (EditorGUI.EndChangeCheck())
            {
                if (clipDefault != null)
                {
                    m_Target.InitCamPos();
                }
            }

            EditorGUI.BeginDisabledGroup(clipDefault == null || clipUp == null && clipDown == null);
            this.DrawPF(m_PropSeperateTime);
            EditorGUI.EndDisabledGroup();

            EditorGUI.indentLevel--;
        }

        void DragGestureInfo()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("手势灵敏度");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;

            this.DrawPF("m_DragCoefficient");
            this.DrawPF(m_DragUpMagnification);
            this.DrawPF(m_DragDownMagnification);
            this.DrawPF("m_PinchCoefficient");
            this.DrawPF("m_DragDamp");
            this.DrawPF("m_PinchDamp");

            EditorGUI.indentLevel--;
        }

        void DrawDOFInfo()
        {
            PapeGames.X3Editor.X3EditorGUILayout.BigLabel("DOF相关");
            PapeGames.X3Editor.X3EditorGUILayout.HLine(1, Color.gray);
            EditorGUI.indentLevel++;

            this.DrawPF(m_PropWithDOF);
            if (m_PropWithDOF.boolValue)
            {
                this.DrawPF("m_DOFSettings");
            }

            EditorGUI.indentLevel--;
        }

        int TryAddCurveToList(List<AnimationCurve> list, AnimationCurve curve, int minKeyCount)
        {
            if (curve != null)
            {
                list.Add(curve);
                return Mathf.Min(minKeyCount, curve.keys.Length);
            }

            return minKeyCount;
        }

        bool IsKeyFrameEquals(List<Keyframe> keys)
        {
            if (keys.Count > 1)
            {
                var k0 = keys[0];
                for (int i = 1; i < keys.Count; ++i)
                {
                    var k = keys[i];
                    if (!k0.time.Approximately(k.time)
                        || !k0.value.Approximately(k.value))
                        return false;
                }
            }

            return true;
        }

        float GetSeparateTime(AnimationClip animDefault, AnimationClip animUp, AnimationClip animDown)
        {
            if (animDefault == null || animUp == null && animDown == null)
                return 0;

            foreach (var binding in AnimationUtility.GetCurveBindings(animDefault))
            {
                AnimationCurve curveDefault = AnimationUtility.GetEditorCurve(animDefault, binding);
                AnimationCurve curveUp = animUp != null ? AnimationUtility.GetEditorCurve(animUp, binding) : null;
                AnimationCurve curveDown = animDown != null ? AnimationUtility.GetEditorCurve(animDown, binding) : null;

                List<AnimationCurve> curves = new List<AnimationCurve>();
                int minKeyCount = Int32.MaxValue;
                minKeyCount = TryAddCurveToList(curves, curveDefault, minKeyCount);
                minKeyCount = TryAddCurveToList(curves, curveUp, minKeyCount);
                minKeyCount = TryAddCurveToList(curves, curveDown, minKeyCount);

                float preTime = 0;
                List<Keyframe> keys = new List<Keyframe>();
                if (curves.Count > 1)
                {
                    for (int i = 0; i < minKeyCount; i++)
                    {
                        if (keys.Count > 0)
                            preTime = keys[0].time;
                        keys.Clear();

                        for (int j = 0; j < curves.Count; j++)
                            keys.Add(curves[j].keys[i]);

                        if (!IsKeyFrameEquals(keys))
                        {
                            if (i > 0)
                            {
                                return preTime;
                            }

                            return 0;
                        }
                    }
                }
            }

            return animUp.length;
        }

        void UpdateDragMagnification(AnimationClip animDefault, AnimationClip animUp, AnimationClip animDown)
        {
            m_DragUpMagnification.floatValue = 1;
            m_DragDownMagnification.floatValue = 1;
            if (animDefault == null || animUp == null || animDown == null)
            {
                return;
            }

            var bindingY = EditorCurveBinding.FloatCurve(string.Empty, typeof(Transform), "m_LocalPosition.y");

            AnimationCurve curveDefault = AnimationUtility.GetEditorCurve(animDefault, bindingY);
            AnimationCurve curveUp = AnimationUtility.GetEditorCurve(animUp, bindingY);
            AnimationCurve curveDown = AnimationUtility.GetEditorCurve(animDown, bindingY);

            if (curveDefault.keys.Length > 0 && curveUp.keys.Length > 0 && curveDown.keys.Length > 0)
            {
                var defaultLastKey = curveDefault.keys[curveDefault.keys.Length - 1];
                var upLastKey = curveUp.keys[curveUp.keys.Length - 1];
                var downLastKey = curveDown.keys[curveDown.keys.Length - 1];

                var disUp = Mathf.Abs(defaultLastKey.value - upLastKey.value);
                var disDown = Mathf.Abs(defaultLastKey.value - downLastKey.value);

                m_DragUpMagnification.floatValue = disUp.Approximately(0) ? 1 : (disUp + disDown) / disUp;
                m_DragDownMagnification.floatValue = disDown.Approximately(0) ? 1 : (disUp + disDown) / disDown;
            }
        }
    }
}