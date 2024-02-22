using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace X3Battle
{
    [CreateAssetMenu(fileName = "ModelInfoCommonAsset", menuName = "Battle/ModelInfoCommonAsset", order = 1)]
    public class ModelInfoCommonAsset : ScriptableObject
    {
        public static readonly string ASSET_NAME = "ModelInfoCommonAsset";
        [SerializeField] public AnimationCurve approachDissolveCurve = AnimationCurve.EaseInOut(0f, 1f, 1f, 0f);
    }
}