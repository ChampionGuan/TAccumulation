using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public class PhyxTriggerMgr
    {
        static IPhyxTriggerDelegate s_IPhyxTriggerDelegate;
        public static void SetDelegate(IPhyxTriggerDelegate iDelegate)
        {
            s_IPhyxTriggerDelegate = iDelegate;
        }

        public static IPhyxTriggerDelegate PhyxTriggerDelegate
        {
            get { return s_IPhyxTriggerDelegate; }
        }
        
        public static void OnTriggerEnter(Collider other, GameObject obj, string key, List<string> paras)
        {
            s_IPhyxTriggerDelegate?.OnTriggerEnter(other, obj, key, paras);
        }
        
        public static void OnTriggerStay(Collider other, GameObject obj, string key, List<string> paras)
        {
            s_IPhyxTriggerDelegate?.OnTriggerStay(other, obj, key, paras);
        }
        
        public static void OnTriggerExit(Collider other, GameObject obj, string key, List<string> paras)
        {
            s_IPhyxTriggerDelegate?.OnTriggerExit(other, obj, key, paras);
        }
        
        public static void OnCollisionEnter(Collision collision, GameObject obj, string key, List<string> paras)
        {
            s_IPhyxTriggerDelegate?.OnCollisionEnter(collision, obj, key, paras);
        }
        
        public static void OnCollisionStay(Collision collision, GameObject obj, string key, List<string> paras)
        {
            s_IPhyxTriggerDelegate?.OnCollisionStay(collision, obj, key, paras);
        }
        
        public static void OnCollisionExit(Collision collision, GameObject obj, string key, List<string> paras)
        {
            s_IPhyxTriggerDelegate?.OnCollisionExit(collision, obj, key, paras);
        }
    }

    [XLua.CSharpCallLua]
    public interface IPhyxTriggerDelegate
    {
        void OnTriggerEnter(Collider other, GameObject obj, string key, List<string> paras);
        void OnTriggerStay(Collider other, GameObject obj, string key, List<string> paras);
        void OnTriggerExit(Collider other, GameObject obj, string key, List<string> paras);
        void OnCollisionEnter(Collision collision, GameObject obj, string key, List<string> paras);
        void OnCollisionStay(Collision collisionInfo, GameObject obj, string key, List<string> paras);
        void OnCollisionExit(Collision other, GameObject obj, string key, List<string> paras);
    }
}