using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    [CreateAssetMenu(fileName = "LocomotionRatioAsset", menuName = "LocomotionAsset", order = 1)]
    public class LocomotionRatioAsset : ScriptableObject
    {
        [SerializeField] public AnimationCurve turnSpeedRatio;
        [SerializeField] public AnimationCurve inclineRatio;
        [SerializeField] public AnimationCurve moveSpeedRatio;
    }
}
