using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 娃娃机掉落检测器，挂在一个Collider上当娃娃与其发生碰撞时认为娃娃抓到了
    /// </summary>
    public class UFOCatcherDropTrigger : MonoBehaviour
    {
        private void OnTriggerEnter(Collider other)
        {
            DollCheckCollider collider = other.gameObject.GetComponent<DollCheckCollider>();
            if (collider == null)
            {
                return;
            }
            if (collider.isCheckCatched == false)
            {
                return;
            }
            if (collider)
            {
                EventMgr.Dispatch("UFOCatcherCatched", collider.root);
            }
        }
    }
}