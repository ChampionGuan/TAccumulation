using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    // 美术配置参数
    [CreateAssetMenu(fileName = "ShadowDataAsset", menuName = "创建残影资源")]
    public class ShadowDataAsset : ScriptableObject
    {
        public ShadowData shadowData;
        [HideInInspector]
        public GhostShaderData ghostShaderData;
    }
}