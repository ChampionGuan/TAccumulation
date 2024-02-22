using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 当绑定脚本和娃娃的掉落检测部分发生了碰撞则停止绳子伸长
    /// </summary>
    public class UFOCatcherCheckRopeStop : MonoBehaviour
    {
        public void OnTriggerStay(Collider other)
        {
            DollCheckCollider checkCollider = other.gameObject.GetComponentInChildren<DollCheckCollider>();
            if (checkCollider)
            {
                EventMgr.Dispatch("GoingDownStop", true);
            }
        }

        public void OnTriggerExit(Collider other)
        {
            DollCheckCollider checkCollider = other.gameObject.GetComponentInChildren<DollCheckCollider>();
            if (checkCollider)
            {
                EventMgr.Dispatch("GoingDownStop", false);
            }
        }

        public void OnCollisionStay(Collision other)
        {
            DollCheckCollider checkCollider = other.gameObject.GetComponentInChildren<DollCheckCollider>();
            if (checkCollider)
            {
                EventMgr.Dispatch("GoingDownStop", true);
            }
        }

        public void OnCollisionExit(Collision other)
        {
            DollCheckCollider checkCollider = other.gameObject.GetComponentInChildren<DollCheckCollider>();
            if (checkCollider)
            {
                EventMgr.Dispatch("GoingDownStop", false);
            }
        }
    }
}