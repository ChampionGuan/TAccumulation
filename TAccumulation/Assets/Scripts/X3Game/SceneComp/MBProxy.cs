using System.Collections.Generic;
using UnityEngine;
using System;

namespace X3Game
{
    /// <summary>
    /// 此组件只能用于极少数情况，绝大部分情况下不应使用此组件
    /// </summary>
    [DisallowMultipleComponent]
    [XLua.LuaCallCSharp]
    [ExecuteInEditMode]
    public class MBProxy : MonoBehaviour
    {
        public delegate void MBEventAction(int instanceID, int eventID, System.Object param);
        public bool UpdateEnabled = false;
        static  MBEventAction s_OnMBEvent;
        private int m_InstanceID;

        #region Base Events
        private void Awake()
        {
            m_InstanceID = GetInstanceID();
            InvokeMBEvent(MBEvent.Awake);
        }
        
        private void Start()
        {
            InvokeMBEvent(MBEvent.Start);
        }
        
        private void FixedUpdate()
        {
            if (!UpdateEnabled)
                return;
            InvokeMBEvent(MBEvent.FixedUpdate);
        }
        
        private void Update()
        {
            if (!UpdateEnabled)
                return;
            InvokeMBEvent(MBEvent.Update);
        }
        
        private void LateUpdate()
        {
            if (!UpdateEnabled)
                return;
            InvokeMBEvent(MBEvent.LateUpdate);
        }

        private void OnEnable()
        {
            InvokeMBEvent(MBEvent.OnEnable);
        }
        
        private void OnDisable()
        {
            InvokeMBEvent(MBEvent.OnDisable);
        }
        
        private void OnDestroy()
        {
            InvokeMBEvent(MBEvent.OnDestroy);
        }
        #endregion

        #region Collision Events
        void OnCollisionEnter(Collision collision)
        {
            InvokeMBEvent(MBEvent.OnCollisionEnter, collision);
        }
        
        void OnCollisionStay(Collision collision)
        {
            InvokeMBEvent(MBEvent.OnCollisionStay, collision);
        }
        
        void OnCollisionExit(Collision collision)
        {
            InvokeMBEvent(MBEvent.OnCollisionExit, collision);
        }
        
        void OnCollisionEnter2D(Collision2D collision)
        {
            InvokeMBEvent(MBEvent.OnCollisionEnter2D, collision);
        }
        
        void OnCollisionStay2D(Collision2D collision)
        {
            InvokeMBEvent(MBEvent.OnCollisionStay2D, collision);
        }
        
        void OnCollisionExit2D(Collision2D collision)
        {
            InvokeMBEvent(MBEvent.OnCollisionExit2D, collision);
        }
        
        void OnTriggerEnter(Collider other)
        {
            InvokeMBEvent(MBEvent.OnTriggerEnter, other);
        }
        
        void OnTriggerStay(Collider other)
        {
            InvokeMBEvent(MBEvent.OnTriggerStay, other);
        }
        
        void OnTriggerExit(Collider other)
        {
            InvokeMBEvent(MBEvent.OnTriggerExit, other);
        }
        
        void OnTriggerEnter2D(Collider2D other)
        {
            InvokeMBEvent(MBEvent.OnTriggerEnter2D, other);
        }
        
        void OnTriggerStay2D(Collider2D other)
        {
            InvokeMBEvent(MBEvent.OnTriggerStay2D, other);
        }
        
        void OnTriggerExit2D(Collider2D other)
        {
            InvokeMBEvent(MBEvent.OnTriggerExit2D, other);
        }
        
        void OnControllerColliderHit(ControllerColliderHit hit)
        {
            InvokeMBEvent(MBEvent.OnControllerColliderHit, hit);
        }
        #endregion

        #region Animator Events

        private void OnAnimatorMove()
        {
            InvokeMBEvent(MBEvent.OnAnimatorMove);
        }
        
        private void OnAnimatorIK(int layerIndex)
        {
            InvokeMBEvent(MBEvent.OnAnimatorIK, layerIndex);
        }

        #endregion

        #region Hierachy Events

        private void OnTransformChildrenChanged()
        {
            InvokeMBEvent(MBEvent.OnTransformChildrenChanged);
        }
        
        private void OnTransformParentChanged()
        {
            InvokeMBEvent(MBEvent.OnTransformParentChanged);
        }

        #endregion
        
        /// <summary>
        /// 设置回调
        /// </summary>
        /// <param name="callback"></param>
        public static void SetCallback(MBEventAction callback)
        {
            s_OnMBEvent = callback;
        }
        
        private void InvokeMBEvent(MBEvent eventID, System.Object param = null)
        {
            s_OnMBEvent?.Invoke(m_InstanceID, (int)eventID, param);
        }
        
        public enum MBEvent
        {
            Awake,
            Start,
            FixedUpdate,
            Update,
            LateUpdate,
            OnAnimatorIK,
            OnAnimatorMove,
            OnTriggerEnter,
            OnTriggerStay,
            OnTriggerExit,
            OnTriggerEnter2D,
            OnTriggerStay2D,
            OnTriggerExit2D,
            OnCollisionEnter,
            OnCollisionStay,
            OnCollisionExit,
            OnCollisionEnter2D,
            OnCollisionStay2D,
            OnCollisionExit2D,
            OnControllerColliderHit,
            OnEnable,
            OnDisable,
            OnDestroy,
            OnTransformChildrenChanged,
            OnTransformParentChanged,
        }
        
        [XLua.CSharpCallLua] public static List<Type> CSCallLuaTypes = new List<Type>()
        {
            typeof(MBEventAction)
        };
    }
}