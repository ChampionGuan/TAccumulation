using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using PapeGames.X3UI;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 新手引导专用的委托事件
    /// </summary>
    [XLua.LuaCallCSharp]
    public static class GuideInputDelegate
    {
        /// <summary>
        /// 检查目标对象的点击事件是否会被新手引导所遮挡的委托
        /// </summary>
        public delegate bool GuideCheckBlockingDelegate(GameObject raycastObj);

        /// <summary>
        /// 新手引导事件白名单
        /// </summary>
        private static Dictionary<GameObject, Dictionary<EventTriggerType, UnityEvent>> m_EventWhiteList =
            new Dictionary<GameObject, Dictionary<EventTriggerType, UnityEvent>>();

        /// <summary>
        /// 引导UI默认的层级
        /// </summary>
        private static int m_GuideWndOrder = 30;

        /// <summary>
        /// 检查当前点击事件是否需要被引导所遮挡的委托
        /// </summary>
        private static GuideCheckBlockingDelegate m_CheckBlockingDelegate;

        /// <summary>
        /// 注册InputModule相关的事件(在NoviceGuideBll中调用初始化)
        /// </summary>
        public static void InitGuideInputDelegate()
        {
            X3InputModule inputModule = (X3InputModule)EventSystem.current.currentInputModule;
            if (inputModule != null)
            {
                inputModule.FilterBlockingEventCallback = FilterGuideBlockingEvent;
                inputModule.WhiteListEventCallback = InvokeWhiteListCallback;
            }
        }

        /// <summary>
        /// 注册引导相关的委托
        /// </summary>
        public static void RegisterGuideDelegate(int guideOrder = 30, GuideCheckBlockingDelegate action = null)
        {
            m_GuideWndOrder = guideOrder;
            if (action == null)
                m_CheckBlockingDelegate = FilterGuideBlockingProcess;
            else
                m_CheckBlockingDelegate = action;
        }
        
        /// <summary>
        /// 清理引导相关委托
        /// </summary>
        public static void ClearGuideDelegate()
        {
            m_CheckBlockingDelegate = null;
        }

        /// <summary>
        /// 给object添加指定类型的白名单事件
        /// </summary>
        /// <param name="obj">目标对象</param>
        /// <param name="type">触发类型</param>
        /// <param name="action">事件委托</param>
        public static void AddListener(GameObject obj, EventTriggerType type, UnityAction action)
        {
            var realGameObject = ExecuteEvents.GetEventHandler<IEventSystemHandler>(obj);

            if (!m_EventWhiteList.ContainsKey(realGameObject))
                m_EventWhiteList.Add(realGameObject, new Dictionary<EventTriggerType, UnityEvent>());

            if (!m_EventWhiteList[realGameObject].ContainsKey(type))
                m_EventWhiteList[realGameObject].Add(type, new UnityEvent());

            m_EventWhiteList[realGameObject][type].AddListener(action);
        }
        
        /// <summary>
        /// 清除白名单事件
        /// </summary>
        public static void ClearListener()
        {
            m_EventWhiteList.Clear();
        }

        /// <summary>
        /// 给object添加拖拽事件到白名单
        /// </summary>
        /// <param name="obj">目标对象</param>
        /// <param name="beginDrag">开始拖拽事件</param>
        /// <param name="drag">拖拽事件</param>
        /// <param name="endDrag">结束拖拽事件</param>
        public static void AddDragListener(GameObject obj, UnityAction beginDrag, UnityAction drag, UnityAction endDrag)
        {
            AddListener(obj, EventTriggerType.BeginDrag, beginDrag);
            AddListener(obj, EventTriggerType.Drag, drag);
            AddListener(obj, EventTriggerType.EndDrag, endDrag);
        }

        /// <summary>
        /// 执行白名单事件
        /// </summary>
        /// <param name="target">目标对象</param>
        /// <param name="type">事件类型</param>
        public static void InvokeWhiteListCallback(GameObject target, EventTriggerType type)
        {
            if (target == null)
                return;
            if (m_EventWhiteList.ContainsKey(target))
            {
                if (m_EventWhiteList[target].ContainsKey(type))
                {
                    m_EventWhiteList[target][type].Invoke();
                }
            }
        }

        /// <summary>
        /// 检查目标对象是否可以穿透新手引导的遮挡
        /// </summary>
        public static bool FilterGuideBlockingEvent(GameObject raycastObj)
        {
            bool checkResult = true;
            if (m_CheckBlockingDelegate != null)
                checkResult = m_CheckBlockingDelegate.Invoke(raycastObj);
            return checkResult;
        }


        /// <summary>
        /// 检测目标对象是否添加了新手引导白名单事件
        /// </summary>
        /// <param name="raycastObj"></param>
        /// <returns></returns>
        public static bool HasRealEventHandlerInWhiteList(GameObject raycastObj)
        {
            var realEventHandler = ExecuteEvents.GetEventHandler<IEventSystemHandler>(raycastObj);
            if (realEventHandler == null)
            {
                return false;
            }

            return m_EventWhiteList.ContainsKey(realEventHandler);
        }

        /// <summary>
        /// 检查是否可以穿透新手引导所设置的遮挡
        /// </summary>
        /// <param name="raycastObj"></param>
        /// <returns></returns>
        private static bool FilterGuideBlockingProcess(GameObject raycastObj)
        {
            /*
                Tips:
                如果进了这个函数，则一定处于新手引导过程,
                只需要检测点击的对象是否在上层，或点击的对象是否在白名单中
            */
            if (raycastObj == null)
                return false;

            // 检查层级是否高于引导UI
            bool checkLayer = FilterUIViewOrder(raycastObj);
            if (checkLayer)
                return true;
            // 检查obj是否在白名单中
            bool checkWhiteList = HasRealEventHandlerInWhiteList(raycastObj);
            if (checkWhiteList)
                return true;

            return false;
        }

        /// <summary>
        /// 检查目标对象是否是UI的节点，如果是，则检查所属UI是否高于新手引导层级
        /// </summary>
        /// <param name="raycastObj"></param>
        /// <returns></returns>
        private static bool FilterUIViewOrder(GameObject raycastObj)
        {
            UIView uiView = raycastObj.GetComponentInParent<UIView>();
            if (uiView && (uiView.PanelOrder >= m_GuideWndOrder))
                return true;
#if DEBUG_GM
            if (raycastObj.GetComponentInParent<SRDebugger.UI.DebugPanelRoot>() != null)
                return true;
#endif
            return false;
        }

        /// <summary>
        /// 设置GM包环境下是否总是开启新手引导
        /// </summary>
        public static void SetGuideAlwaysEnable()
        {
#if DEBUG_GM
            XLua.LuaTable table = X3Lua.DoRequire("Runtime.System.X3Game.Modules.ChapterStageManager")[0] as XLua.LuaTable;
            var f_SetIsOpenProStage = table.Get<XLua.LuaFunction>("SetIsOpenProStage");
            f_SetIsOpenProStage?.Call(true);
            
            XLua.LuaTable l_PlayerPrefs = X3Lua.DoRequire("Runtime.System.Framework.Engine.PlayerPrefs")[0] as XLua.LuaTable;
            var f_SetInt = l_PlayerPrefs.Get<XLua.LuaFunction>("SetInt");
            f_SetInt?.Call("GuideOpen", 1);
            f_SetInt?.Call("GuideAutoGuideOpen", 1);
            f_SetInt?.Call("GuideManualGuideOpen", 1);
#endif
        }
    }
}
