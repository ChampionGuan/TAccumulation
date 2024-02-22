using UnityEngine;
using System.Collections.Generic;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 爪子上是否有娃娃的检测脚本，并且在娃娃掉落时会发出事件
    /// </summary>
    public class UFOCatcherDollTouchedTrigger : MonoBehaviour
    {
        /// <summary>
        /// 当前碰到的娃娃列表
        /// </summary>
        public List<GameObject> triggerObjects = new List<GameObject>();

        private void OnTriggerEnter(Collider other)
        {
            DollCheckCollider collider = other.gameObject.GetComponent<DollCheckCollider>();
            if (collider)
            {
                if (collider.isCheckCatched)
                {
                    return;
                }
                if (!triggerObjects.Contains(other.gameObject))
                {
                    triggerObjects.Add(other.gameObject);
                }
                EventMgr.Dispatch("ClawTriggerCountChanged", triggerObjects.Count);
            }
        }

        private void OnTriggerExit(Collider other)
        {
            DollCheckCollider collider = other.gameObject.GetComponent<DollCheckCollider>();
            if (collider)
            {
                if (collider.isCheckCatched)
                {
                    return;
                }
                triggerObjects.Remove(other.gameObject);
                EventMgr.Dispatch("ClawTriggerCountChanged", triggerObjects.Count);
            }
        }
    }
}