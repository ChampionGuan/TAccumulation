using System;
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.EventSystems;
using XLua;


namespace X3Game
{
    /// <summary>
    /// 响应手机返回按键功能
    /// </summary>
    [LuaCallCSharp]
    public class EscapeKeyHandler : MonoBehaviour
    {
        private List<string> SpecialViewTagList = new List<string>();


        [NonSerialized] private List<EscapeKeyReceiver> m_EscapeKeyReceiverList = new List<EscapeKeyReceiver>();
        private PointerEventData m_EventData;

        private Action m_SpecialViewCallBack;

        private bool m_TriggerGuideEvent = false;
        private GameObject m_TriggerGuideObj;

        #region UnityEvent

        private void Update()
        {
#if UNITY_ANDROID || UNITY_EDITOR
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                //返回键响应
                ExeBackEvent();
            }
#endif
        }

        #endregion

        #region public

        public static EscapeKeyHandler Attach(GameObject ins = null)
        {
            if (!GameMgr.Instance)
            {
                return null;
            }

            var obj = ins == null ? GameMgr.Instance.gameObject : ins;
            return obj.GetOrAddComponent<EscapeKeyHandler>();
        }

        public void AddSpecialViewTag(string tag)
        {
            SpecialViewTagList.Add(tag);
        }

        public void ClearSpecialViewList()
        {
            SpecialViewTagList.Clear();
        }

        public void AddSpecialViewCallBack(Action callback)
        {
            m_SpecialViewCallBack = callback;
        }

        #endregion

        // ReSharper disable Unity.PerformanceAnalysis
        private void ExeBackEvent()
        {
            m_TriggerGuideEvent = false;
            m_TriggerGuideObj = null;
            m_EscapeKeyReceiverList.Clear();
            var viewList = ListPool<UIMgr.ViewItem>.Get();
            GetTopViewList(viewList);
            GetBackFlag(viewList, m_EscapeKeyReceiverList);

            // 如果有引导，则直接触发引导相关的事件，不走后面的逻辑
            if (m_TriggerGuideEvent)
            {
                GuideInputDelegate.InvokeWhiteListCallback(m_TriggerGuideObj, EventTriggerType.PointerClick);
                return;
            }

            if (m_EscapeKeyReceiverList.Count > 0 && X3InputModule.IsTouchEnable)
            {
                m_EscapeKeyReceiverList.Sort(RaycastComparer);
                var ins = m_EscapeKeyReceiverList[m_EscapeKeyReceiverList.Count - 1].gameObject;
                var screenPos =
                    RectTransformUtility.WorldToScreenPoint(UIMgr.Instance.UICamera, ins.transform.position);
                if (m_EventData == null)
                {
                    m_EventData = new PointerEventData(EventSystem.current);
                }

                m_EventData.pressPosition = screenPos;
                m_EventData.position = screenPos;
                // backFlag排序执行
                m_EscapeKeyReceiverList[m_EscapeKeyReceiverList.Count - 1].InvokeClick(m_EventData);
                if (UIMgr.PanelGlobalEventMask.gameObject.visibleInHierarchy)
                {
                    UIMgr.PanelGlobalEventMask.OnGlobalInputEvent(m_EventData, ins, EventTriggerType.PointerClick);
                }

                return;
            }

            //panelMask处理
            UIPanelMask currPaneMask = null;
            if (UIMgr.PanelDarkMask.gameObject.visibleInHierarchy)
            {
                if (CanRayCast(UIMgr.PanelDarkMask.gameObject))
                {
                    currPaneMask = UIMgr.PanelDarkMask;
                }
            }

            if (UIMgr.PanelTransparentMask.gameObject.visibleInHierarchy)
            {
                if (CanRayCast(UIMgr.PanelTransparentMask.gameObject))
                {
                    if (currPaneMask == null)
                    {
                        currPaneMask = UIMgr.PanelTransparentMask;
                    }
                    else
                    {
                        currPaneMask =
                            UIMgr.PanelTransparentMask.AssociatedView.SortingOrder >
                            currPaneMask.AssociatedView.SortingOrder
                                ? UIMgr.PanelTransparentMask
                                : currPaneMask;
                    }
                }
            }


            if (currPaneMask != null && X3InputModule.IsTouchEnable)
            {
                currPaneMask.ExternalOnClick();
                if (UIMgr.PanelGlobalEventMask.GetSortingOrder() >= currPaneMask.GetSortingOrder())
                {
                    UIMgr.PanelGlobalEventMask.ExternalOnClick();
                }

                return;
            }

            //特殊UI退出弹窗处理
            foreach (var viewTag in SpecialViewTagList)
            {
                if (UIMgr.Instance.IsFocused(viewTag))
                {
                    m_SpecialViewCallBack?.Invoke();
                    break;
                }
            }
        }


        /// <summary>
        /// 获取当前需要进行组件选择的UIViewList
        /// </summary>
        /// <returns></returns>
        private void GetTopViewList(List<UIMgr.ViewItem> viewList)
        {
            if (viewList == null) return;
            var showViewList = UIMgr.Instance.ShowingViewList;
            var sysViewList = UIMgr.Instance.SysPanelList;
            var allViewList = ListPool<UIMgr.ViewItem>.Get();
            allViewList.AddRange(showViewList.ViewList);
            allViewList.AddRange(sysViewList.ViewList);
            for (var i = allViewList.Count - 1; i >= 0; i--)
            {
                var viewItem = allViewList[i];
                viewList.Add(viewItem);
                //如果存在背景点击的UI，或者 静态模糊的UI 那么他就是最底层的UI
                if ((viewItem.View.AutoCloseMode == AutoCloseMode.ClickOutter &&
                     !viewItem.View.AutoCloseAndForwardEvent) ||
                    viewItem.View.PanelBlurType == UIBlurType.Static)
                {
                    break;
                }
            }

            ListPool<UIMgr.ViewItem>.Release(allViewList);
        }


        // ReSharper disable Unity.PerformanceAnalysis
        private void GetBackFlag(IEnumerable<UIMgr.ViewItem> viewList, List<EscapeKeyReceiver> escapeKeyReceiverList)
        {
            if (escapeKeyReceiverList == null) return;
            escapeKeyReceiverList.Clear();
            foreach (var viewItem in viewList)
            {
                var escapeKeyReceiverArr = viewItem.View.transform.GetComponentsInChildren<EscapeKeyReceiver>();
                foreach (var escapeKeyReceiver in escapeKeyReceiverArr)
                {
                    if (escapeKeyReceiver.IsVaild() && CanRayCast(escapeKeyReceiver.gameObject))
                    {
                        escapeKeyReceiverList.Add(escapeKeyReceiver);
                    }
                }
            }
        }


        /// <summary>
        /// 以当前位置做射线检测，判断能否点击
        /// </summary>
        /// <param name="ins"></param>
        /// <returns></returns>
        public bool CanRayCast(GameObject ins)
        {
            var screenPos =
                RectTransformUtility.WorldToScreenPoint(UIMgr.Instance.UICamera, ins.transform.position);
            if (m_EventData == null)
            {
                m_EventData = new PointerEventData(EventSystem.current);
            }

            m_EventData.pressPosition = screenPos;
            m_EventData.position = screenPos;
            var list = ListPool<RaycastResult>.Get();
            EventSystem.current.RaycastAll(m_EventData, list);

            var maxWidth = 0f;
            var maxHeight = 0f;
            var isCanRayCast = false;
            foreach (var result in list)
            {
                // 如果不能通过引导层级的遮挡，则不能执行，表示当前正被新手引导挡住
                if (!GuideInputDelegate.FilterGuideBlockingEvent(result.gameObject))
                    continue;
                // 如果射线检测到的控件中，涉及到新手引导层级相关的obj，则认为点击到了新手引导区域
                if (GuideInputDelegate.HasRealEventHandlerInWhiteList(result.gameObject))
                {
                    m_TriggerGuideEvent = true;
                    m_TriggerGuideObj = result.gameObject;
                    isCanRayCast = true;
                }

                var rect = ((RectTransform)result.gameObject.transform).rect;
                var curClickHandlerIns = GetClickHandler(result.gameObject);
                if (curClickHandlerIns == ins.gameObject)
                {
                    isCanRayCast = Mathf.Min(Screen.width, rect.width) > maxWidth ||
                                   Mathf.Min(Screen.height, rect.height) > maxHeight;
                    break;
                }

                maxWidth = maxWidth > rect.width ? maxWidth : rect.width;
                maxHeight = maxHeight > rect.height ? maxHeight : rect.height;
            }

            ListPool<RaycastResult>.Release(list);
            return isCanRayCast;
        }

        private static GameObject GetClickHandler(GameObject ins)
        {
            var clickHandler = ExecuteEvents.GetEventHandler<IPointerClickHandler>(ins);
            return clickHandler;
        }


        /// <summary>
        /// 排序函数
        /// </summary>
        /// <param name="lhs"></param>
        /// <param name="rhs"></param>
        /// <returns></returns>
        private static int RaycastComparer(EscapeKeyReceiver lhs, EscapeKeyReceiver rhs)
        {
            if (lhs.Caster != rhs.Caster)
            {
                var lhsEventCamera = lhs.Caster.eventCamera;
                var rhsEventCamera = rhs.Caster.eventCamera;
                if (lhsEventCamera != null && rhsEventCamera != null && lhsEventCamera.depth != rhsEventCamera.depth)
                {
                    // need to reverse the standard compareTo
                    if (lhsEventCamera.depth < rhsEventCamera.depth)
                        return 1;
                    if (lhsEventCamera.depth == rhsEventCamera.depth)
                        return 0;

                    return -1;
                }

                if (lhs.Caster.sortOrderPriority != rhs.Caster.sortOrderPriority)
                    return rhs.Caster.sortOrderPriority.CompareTo(lhs.Caster.sortOrderPriority);

                if (lhs.Caster.renderOrderPriority != rhs.Caster.renderOrderPriority)
                    return rhs.Caster.renderOrderPriority.CompareTo(lhs.Caster.renderOrderPriority);
            }

            if (lhs.SortingLayer == rhs.SortingLayer) return rhs.SortingOrder.CompareTo(lhs.SortingOrder);
            // Uses the layer value to properly compare the relative order of the layers.
            var rid = SortingLayer.GetLayerValueFromID(rhs.SortingLayer);
            var lid = SortingLayer.GetLayerValueFromID(lhs.SortingLayer);
            return rid.CompareTo(lid);
        }
    }
}