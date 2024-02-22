using UnityEngine;

namespace X3Game
{
    /// <summary>
    /// 每个娃娃都需要绑定的一个脚本，用来检测掉落用
    /// </summary>
    public class DollCheckCollider : MonoBehaviour
    {
        /// <summary>
        /// 隶属于的娃娃根节点
        /// </summary>
        public GameObject root;

        /// <summary>
        /// 是否已抓到
        /// </summary>
        [HideInInspector]
        public bool isCheckCatched = true;
    }
}