using UnityEngine;
using UnityEngine.Serialization;

namespace X3Game
{
    /// <summary>
    /// 双人娃娃机控制器，绑定在机器Prefab的根节点上
    /// </summary>
    public class CoupleUFOCatcherController : MonoBehaviour
    {
        /// <summary>
        /// 玩家的爪子
        /// </summary>
        [FormerlySerializedAs("playerController")] public ThreeClawConfig playerConfig;
        
        /// <summary>
        /// 男主的爪子
        /// </summary>
        [FormerlySerializedAs("aiController")] public ThreeClawConfig aiConfig;

        /// <summary>
        /// 娃娃初始化位置配置
        /// </summary>
        public Vector3 dollInitPosition = new Vector3(0, 1.16f, 0);

        /// <summary>
        /// 娃娃初始化父容器
        /// </summary>
        public GameObject dollParent;
    }
}
