using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{
    /// <summary>
    ///  预留一个通用的物理碰撞未来加功能用
    /// </summary>
    public class UFOCatcherPhyxTrigger : MonoBehaviour
    {
        public string EventKey;
        public List<string> Paras = new List<string>();
        public bool TriggerEnterActive = false;
        public bool TriggerStayActive = false;
        public bool TriggerExitActive = false;
        public bool CollisionEnterActive = false;
        public bool CollisionStayActive = false;
        public bool CollisionExitActive = false;

        private void OnTriggerEnter(Collider other)
        {
            if (TriggerEnterActive)
            {
                PhyxTriggerMgr.OnTriggerEnter(other, gameObject, EventKey, Paras);
            }
        }

        private void OnTriggerStay(Collider other)
        {
            if (TriggerStayActive)
            {
                PhyxTriggerMgr.OnTriggerStay(other, gameObject, EventKey, Paras);
            }            
        }

        private void OnTriggerExit(Collider other)
        {
            if (TriggerExitActive)
            {
                PhyxTriggerMgr.OnTriggerExit(other, gameObject, EventKey, Paras);
            }
        }

        private void OnCollisionEnter(Collision collision)
        {
            if (CollisionEnterActive)
            {
                PhyxTriggerMgr.OnCollisionEnter(collision, gameObject, EventKey, Paras);
            }
        }

        private void OnCollisionStay(Collision collisionInfo)
        {
            if (CollisionStayActive)
            {
                PhyxTriggerMgr.OnCollisionStay(collisionInfo, gameObject, EventKey, Paras);
            }
        }

        private void OnCollisionExit(Collision other)
        {
            if (CollisionExitActive)
            {
                PhyxTriggerMgr.OnCollisionExit(other, gameObject, EventKey, Paras);
            }
        }
    }
}