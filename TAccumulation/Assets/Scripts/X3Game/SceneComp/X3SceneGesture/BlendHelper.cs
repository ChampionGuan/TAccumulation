using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

namespace X3Game.SceneGesture
{
    public static class BlendHelper
    {
        static AnimationCurve[] s_StandardCurves;

        static void CreateStandardCurves()
        {
            s_StandardCurves = new AnimationCurve[(int) CinemachineBlendDefinition.Style.Custom];

            s_StandardCurves[(int) CinemachineBlendDefinition.Style.Cut] = null;
            s_StandardCurves[(int) CinemachineBlendDefinition.Style.EaseInOut] =
                AnimationCurve.EaseInOut(0f, 0f, 1, 1f);

            s_StandardCurves[(int) CinemachineBlendDefinition.Style.EaseIn] = AnimationCurve.Linear(0f, 0f, 1, 1f);
            Keyframe[] keys = s_StandardCurves[(int) CinemachineBlendDefinition.Style.EaseIn].keys;
            keys[1].inTangent = 0;
            s_StandardCurves[(int) CinemachineBlendDefinition.Style.EaseIn].keys = keys;

            s_StandardCurves[(int) CinemachineBlendDefinition.Style.EaseOut] = AnimationCurve.Linear(0f, 0f, 1, 1f);
            keys = s_StandardCurves[(int) CinemachineBlendDefinition.Style.EaseOut].keys;
            keys[0].outTangent = 0;
            s_StandardCurves[(int) CinemachineBlendDefinition.Style.EaseOut].keys = keys;

            s_StandardCurves[(int) CinemachineBlendDefinition.Style.HardIn] = AnimationCurve.Linear(0f, 0f, 1, 1f);
            keys = s_StandardCurves[(int) CinemachineBlendDefinition.Style.HardIn].keys;
            keys[0].outTangent = 0;
            keys[1].inTangent = 1.5708f; // pi/2 = up
            s_StandardCurves[(int) CinemachineBlendDefinition.Style.HardIn].keys = keys;

            s_StandardCurves[(int) CinemachineBlendDefinition.Style.HardOut] = AnimationCurve.Linear(0f, 0f, 1, 1f);
            keys = s_StandardCurves[(int) CinemachineBlendDefinition.Style.HardOut].keys;
            keys[0].outTangent = 1.5708f; // pi/2 = up
            keys[1].inTangent = 0;
            s_StandardCurves[(int) CinemachineBlendDefinition.Style.HardOut].keys = keys;

            s_StandardCurves[(int) CinemachineBlendDefinition.Style.Linear] = AnimationCurve.Linear(0f, 0f, 1, 1f);
        }

        static AnimationCurve GetBlendCurve(CinemachineBlendDefinition.Style style, AnimationCurve customCurve = null)
        {
            AnimationCurve curve = null;
            if (style == CinemachineBlendDefinition.Style.Custom)
            {
                if (customCurve == null)
                    return AnimationCurve.EaseInOut(0f, 0f, 1, 1f);
            }

            if (s_StandardCurves == null)
                CreateStandardCurves();
            return s_StandardCurves[(int) style];
        }

        public static float GetBlendWeight(float normalizedTime, CinemachineBlendDefinition.Style style,
            AnimationCurve customCurve = null)
        {
            var curve = GetBlendCurve(style, customCurve);
            if (curve == null || curve.length < 2)
                return 1;
            return Mathf.Clamp01(curve.Evaluate(normalizedTime));
        }
    }
}