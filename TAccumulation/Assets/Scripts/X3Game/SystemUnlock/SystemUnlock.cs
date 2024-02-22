// Name：SystemUnlock
// Created by jiaozhu
// Created Time：2021-13-03 15:13
using System;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using PapeGames.X3UI;
using PapeGames.X3;

namespace X3Game
{
    [DisallowMultipleComponent]
    [LuaCallCSharp]
    public class SystemUnlock:MonoBehaviour
    {
        static Dictionary<int,List<SystemUnlock>> s_Systems = new Dictionary<int, List<SystemUnlock>>();
        # region 公有属性
        public enum ELockEffect
        {
            None = 0,
            Hide = 1,
            Gray = 2,
        }
        public ELockEffect LockType;

        ELockEffect ShowLockType
        {
            get
            {
                if (IsForceHide)
                {
                    return ELockEffect.Hide;
                }
                else
                {
                    return LockType;
                }
            }
        }
        [HideInInspector]
        public int SystemId;
        [HideInInspector]
        public string ViewTag;
        public GameObject Target;
        #endregion
        # region 私有属性
        
        private X3Button m_Btn;
        private StyleEnum m_Selectable;
        private bool m_IsUnlock = false;
        public bool IsUnlock
        {
            set {
                if (value != m_IsUnlock)
                {
                    m_IsUnlock = value;
                    Refresh();
                }
                else if(IsForceHide)
                {
                    Refresh();
                }
            }
            get { return !IsForceHide && m_IsUnlock; }
        }

        public bool IsForceHide;
        #endregion
        #region 静态私有属性
        private static Action<int,string,bool> s_SystemClick;
        private static Action<int> s_CheckSystem;
        #endregion
        #region 静态公共接口
        public static void SetSystemIsUnlock(int sysId, bool isUnlock=false,bool isForceHide=false)
        {
            List<SystemUnlock> list;
            if (s_Systems.TryGetValue(sysId, out list))
            {
                for (int i = 0; i < list.Count; i++)
                {
                    var item = list[i];
                    item.IsForceHide = isForceHide;
                    item.IsUnlock = isUnlock;
                }
            }
        }

        public static void AddListener(Action<int,string,bool> sysClick,Action<int> sysCheck)
        {
            s_SystemClick = sysClick;
            s_CheckSystem = sysCheck;
        }

        public static void RemoveListener()
        {
            s_SystemClick = null;
            s_CheckSystem = null;
        }
        public static bool IsSysInCheckList(int sysId,SystemUnlock sys)
        {
#if UNITY_EDITOR
            List<SystemUnlock> list;
            if (s_Systems.TryGetValue(sysId, out list))
            {
                return list.Contains(sys);
            }

            return false;
#else
            return false;
#endif
        }
        #endregion
        # region 私有方法
        private void OnEnable()
        {
            if (m_Btn != null)
            {
                m_Btn.OnClick.RemoveListener(OnClick);
                m_Btn.OnClick.AddListener(OnClick);
            }
        }

        void Refresh()
        {
            if (m_Selectable != null) m_Selectable.IsOn = IsUnlock;
            switch (ShowLockType)
            {
                case ELockEffect.Gray:
                    if (m_Btn != null) m_Btn.ButtonEnabled = IsUnlock;
                    
                    break;
                case ELockEffect.Hide:
                    if(Target!=null)
                        UIUtility.SetActive(Target, IsUnlock);
                    break;
                case ELockEffect.None:
                    break;
                default:
                        break;
            }
        }
        
        private void Awake()
        {
            if (Target == null)
            {
                Target = gameObject;
            }

            m_Btn = m_Btn == null ? Target.GetComponent<X3Button>() : null;
            m_Selectable = Target.GetComponent<StyleEnum>();
            Refresh();
            AddSystemUnlock(SystemId,this);
        }


        private void OnDestroy()
        {
            RemoveSystemUnlock(SystemId,this);
        }

        void OnClick(GameObject obj)
        {
            s_SystemClick?.Invoke(SystemId,ViewTag,IsUnlock);
        }
        #endregion
        #region 静态私有方法

        static bool IsSysUnlock(int sysId)
        {
            List<SystemUnlock> list;
            if (s_Systems.TryGetValue(sysId, out list))
            {
                for (int i = 0; i < list.Count; i++)
                {
                    if (list[i].IsUnlock)
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        public static void AddSystemUnlock(int sysId, SystemUnlock sys)
        {
            bool isCreate = false;
            List<SystemUnlock> list;
            if (!s_Systems.TryGetValue(sysId, out list))
            {
                isCreate = true;
                list= ListPool<SystemUnlock>.Get();
                s_Systems.Add(sysId,list);
            }
#if UNITY_EDITOR
            if (!list.Contains(sys))
#endif
            {
                list.Add(sys);
            }

            if (isCreate)
            {
                s_CheckSystem?.Invoke(sysId);
            }
            else
            {
                sys.IsUnlock = IsSysUnlock(sysId);
            }
        }

        public static void RemoveSystemUnlock(int sysId, SystemUnlock sys)
        {
            List<SystemUnlock> list;
            if (s_Systems.TryGetValue(sysId, out list))
            {
#if UNITY_EDITOR
                if (list.Contains(sys))
#endif
                {
                    list.Remove(sys);
                    if (list.Count == 0)
                    {
                        s_Systems.Remove(sysId);
                        ListPool<SystemUnlock>.Release(list);
                    }
                }
            }
        }
#if UNITY_EDITOR
        private void OnValidate()
        {
            if (!Application.isPlaying || UnityEditor.Timeline.ObjectExtension.IsPrefab(this)) return;
            Refresh();
        }
#endif 

        #endregion
    }
}