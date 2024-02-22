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
    public class MBRenderProxy : MonoBehaviour
    {
        private static MBProxy.MBEventAction s_OnMBEvent;
        private int m_InstanceID;

        #region Mono Events
        private void Awake()
        {
            m_InstanceID = GetInstanceID();
        }
        #endregion
        
        #region Render Events
        private void OnBecameVisible()
        {
            InvokeMBEvent(MBEvent.OnBecomeVisible);
        }
        
        private void OnBecameInvisible()
        {
            InvokeMBEvent(MBEvent.OnBecomeInvisible);
        }
        
        private void OnPostRender()
        {
            InvokeMBEvent(MBEvent.OnPostRender);
        }
        
        private void OnPreCull()
        {
            InvokeMBEvent(MBEvent.OnPreCull);
        }
        
        private void OnPreRender()
        {
            InvokeMBEvent(MBEvent.OnPreRender);
        }
        
        private void OnRenderObject()
        {
            InvokeMBEvent(MBEvent.OnRenderObject);
        }
        
        private void OnWillRenderObject()
        {
            InvokeMBEvent(MBEvent.OnWillRenderObject);
        }
        #endregion
        
        
        /// <summary>
        /// 设置回调
        /// </summary>
        /// <param name="callback"></param>
        public static void SetCallback(MBProxy.MBEventAction callback)
        {
            s_OnMBEvent = callback;
        }
        
        private void InvokeMBEvent(MBEvent eventID, System.Object param = null)
        {
            s_OnMBEvent?.Invoke(m_InstanceID, (int)eventID, param);
        }
        
        public enum MBEvent
        {
            OnBecomeVisible = 200,
            OnBecomeInvisible,
            OnPostRender,
            OnPreCull,
            OnPreRender,
            OnRenderImage,
            OnRenderObject,
            OnWillRenderObject,
        }
    }
}