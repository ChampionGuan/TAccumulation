using UnityEngine;
using System.Collections.Generic;
using System;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class AEProxy : MonoBehaviour
    {
        public delegate void AEEventAction(int instanceId, int tag, string eventName);
        private static AEEventAction s_OnAEEvent;
        public int Tag;
        
        public static void SetCallback(AEEventAction callback)
        {
            s_OnAEEvent = callback;
        }
        
        public void AnimEvent(string eventName)
        {
            s_OnAEEvent?.Invoke(gameObject.GetInstanceID(), Tag, eventName);
        }
        
        [XLua.CSharpCallLua] public static List<Type> CSCallLuaTypes = new List<Type>()
        {
            typeof(AEEventAction)
        };
    }
}