using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Game
{
    /// <summary>
    /// 单人娃娃机控制器
    /// </summary>
    public class UFOCatcherConfig : MonoBehaviour
    {
        /// <summary>
        /// 爪子的控制器
        /// </summary>
        [FormerlySerializedAs("clawController")] 
        public ClawConfig clawConfig;
        
        /// <summary>
        /// 娃娃的初始化位置
        /// </summary>
        public List<Transform> dollPosition;

        /// <summary>
        /// 中心位置，旋转娃娃机用，用来给AI做预测使用
        /// </summary>
        public Transform center;

        /// <summary>
        /// 娃娃初始化父容器
        /// </summary>
        public GameObject dollParent;
    }
}