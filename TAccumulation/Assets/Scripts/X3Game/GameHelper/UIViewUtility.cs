using UnityEngine;
using System.Collections.Generic;
using System;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public static partial class UIViewUtility
    {
        static Dictionary<string, string> s_ViewTagToUIPrefabAssetPathDict = new Dictionary<string, string>(64);
        static bool s_RunScript = true;
        static bool s_Inited = false;
        static bool s_GameReboot = false;

        #region Open & Close

        public static void Open(string viewTag, bool withAnim, params object[] data)
        {
            Init();
            var viewInfo = GetViewInfo(viewTag);
            Open(viewTag, viewInfo, withAnim, data);
        }

        public static void Open(string viewTag, bool withAnim)
        {
            Init();
            var viewInfo = GetViewInfo(viewTag);
            Open(viewTag, viewInfo, withAnim);
        }

        public static void OpenAs(string viewTag, UIViewType viewType, int panelOrder, AutoCloseMode autoCloseMode,
            bool maskVisible, bool fullScreen, bool focusable, UIBlurType blurType, bool withAnim, params object[] data)
        {
            Init();
            var viewInfo = new ViewInfo()
            {
                ViewType = viewType,
                PanelOrder = panelOrder,
                AutoCloseMode = autoCloseMode,
                MaskVisible = maskVisible,
                IsFocusable = focusable,
                IsFullScreen = fullScreen,
                BlurType = blurType
            };
            Open(viewTag, viewInfo, withAnim, data);
        }

        public static void OpenWindow(string viewTag, bool withAnim, params object[] data)
        {
            Init();
            var viewInfo = GetViewInfo(viewTag);
            viewInfo.ViewType = UIViewType.UIWindow;
            Open(viewTag, viewInfo, withAnim, data);
        }

        public static void OpenPanel(string viewTag, bool withAnim, params object[] data)
        {
            Init();
            var viewInfo = GetViewInfo(viewTag);
            viewInfo.ViewType = UIViewType.UIPopup;
            Open(viewTag, viewInfo, withAnim, data);
        }

        public static void SetReferenceResolution(float x, float y)
        {
            SetReferenceResolution(new Vector2(x, y));
        }

        public static void SetReferenceResolution(Vector2 resolution)
        {
            Init();
            var rootCanvas = UIMgr.Instance.RootCanvas;
            if (!rootCanvas)
            {
                X3Debug.LogErrorFormat("Find no root canvas");
                return;
            }

            var scaler = rootCanvas.GetComponentInChildren<CanvasScaler>();
            if (scaler != null)
            {
                scaler.referenceResolution = resolution;
                UIMgr.RefreshUIResolution();
            }
        }

#if UNITY_EDITOR
        public static void SetReferenceResolutionForEditor(Vector2 resolution)
        {
            var scalerComps = Object.FindObjectsOfType<CanvasScaler>();
            foreach (var comp in scalerComps)
            {
                comp.referenceResolution = resolution;
            }

            UIMgr.RefreshUIResolution();
        }
#endif

        public static void ChangeOrientation(bool isPortraitMode)
        {
            // Screen.autorotateToPortrait = isPortraitMode;
            // Screen.autorotateToPortraitUpsideDown = isPortraitMode;
            // Screen.autorotateToLandscapeRight = !isPortraitMode;
            // Screen.autorotateToLandscapeLeft = !isPortraitMode;
            var orientation = isPortraitMode
                ? UnityEngine.ScreenOrientation.Portrait
                : UnityEngine.ScreenOrientation.Landscape;
            UIMgr.Orientation = orientation;
#if UNITY_EDITOR
            var screenSize = CameraUtility.GetScreenSize();
            if ((isPortraitMode && screenSize.x > screenSize.y) || (!isPortraitMode && screenSize.y > screenSize.x))
            {
                (screenSize.x, screenSize.y) = (screenSize.y, screenSize.x);
            }

            PapeGames.X3Editor.GameViewSizeUtility.SetSize(screenSize.x, screenSize.y);
#endif
        }

        public static void RefreshResolutionFitter()
        {
            Init();
            var rootCanvas = UIMgr.Instance.RootCanvas;
            if (!rootCanvas)
            {
                X3Debug.LogErrorFormat("Find no root canvas");
                return;
            }

            UIMgr.RefreshUIResolution();
        }

        static void Open(string viewTag, ViewInfo viewInfo, bool withAnim, params object[] data)
        {
            Init();
#if UNITY_EDITOR
            if (!X3Game.GameMgr.IsRunning)
            {
                UIMgr.RefreshUIResolution();
            }
#endif
            UIMgr.Instance.Open(viewTag, viewInfo, withAnim, data);
        }

        public static void Close(string viewTag, bool withAnim = true)
        {
            Init();
            UIMgr.Instance.Close(viewTag, withAnim);
        }

        public static void Close(int viewId, bool withAnim = true)
        {
            Init();
            UIMgr.Instance.Close(viewId, withAnim);
        }

        public static void Pop(bool withAnim = false)
        {
            Init();
            UIMgr.Instance.Pop(withAnim);
        }

        public static void CloseWindowsPanels()
        {
            Init();
            UIMgr.Instance?.CloseWindowsPanels();
        }

        public static void CloseSysPanels()
        {
            Init();
            UIMgr.Instance.CloseSysPanels();
        }

        public static void SetWhiteListWhenCloseSysPanels(List<string> whiteList)
        {
            Init();
            UIMgr.Instance.SetWhiteListWhenCloseSysPanels(whiteList);
        }

        public static void ClearWhiteListWhenCloseSysPanels()
        {
            Init();
            UIMgr.Instance.SetWhiteListWhenCloseSysPanels();
        }

        public static void CloseAll()
        {
            ClearHistory();
            CloseSysPanels();
            CloseWindowsPanels();
        }

        #endregion

        #region UIView Attrs Manipulation

        public static bool SetFullScreenMode(int viewId, bool enable)
        {
            return SetFullScreenMode(GetUIViewIns(viewId), enable);
        }

        public static bool SetFullScreenMode(string viewTag, bool enable)
        {
            return SetFullScreenMode(GetUIViewIns(viewTag), enable);
        }

        static bool SetFullScreenMode(UIView viewIns, bool enable)
        {
            if (viewIns == null)
                return false;
            viewIns.IsFullScreen = enable;
            UIMgr.Instance.ResolveVisibilityFocus(true);
            return true;
        }

        public static bool SetNeedMainCamera(int viewId, bool enable)
        {
            return SetNeedMainCamera(GetUIViewIns(viewId), enable);
        }

        public static bool SetNeedMainCamera(string viewTag, bool enable)
        {
            return SetNeedMainCamera(GetUIViewIns(viewTag), enable);
        }

        static bool SetNeedMainCamera(UIView viewIns, bool enable)
        {
            if (viewIns == null)
                return false;
            viewIns.NeedMainCamera = enable;
            UIMgr.Instance.ResolveVisibilityFocus(false);
            return true;
        }

        private static UIView GetUIViewIns(string viewTag)
        {
            Init();
            var uiComp = UIMgr.Instance.GetViewIns(viewTag);
            if (uiComp == null)
            {
                LogProxy.LogErrorFormat("UIViewUtility: find no uiview with viewTag {0}", viewTag);
            }

            return uiComp;
        }

        private static UIView GetUIViewIns(int viewId)
        {
            Init();
            var uiComp = UIMgr.Instance.GetViewIns(viewId);
            if (uiComp == null)
            {
                LogProxy.LogErrorFormat("UIViewUtility: find no uiview with viewId {0}", viewId);
            }

            return uiComp;
        }

        public static void RefreshVisibilityFocus()
        {
            if (UIMgr.HasInstance())
                UIMgr.Instance.ResolveVisibilityFocus(false);
        }

        #endregion

        #region Hide / Show

        public static void Hide(string viewTag)
        {
            if (string.IsNullOrEmpty(viewTag)) return;
            Init();
            UIMgr.Instance.Hide(viewTag);
        }

        public static void Show(string viewTag)
        {
            if (string.IsNullOrEmpty(viewTag)) return;
            Init();
            UIMgr.Instance.Show(viewTag);
        }

        public static void Hide(int viewId)
        {
            Init();
            UIMgr.Instance.Hide(viewId);
        }

        public static void Show(int viewId)
        {
            Init();
            UIMgr.Instance.Show(viewId);
        }

        #endregion

        #region MoveIn / Moveout

        public static void PlayMoveIn(string viewTag, System.Action onComplete = null)
        {
            if (string.IsNullOrEmpty(viewTag)) return;
            Init();
            var uiComp = UIMgr.Instance.GetViewIns(viewTag);
            if (uiComp == null)
            {
                LogProxy.LogErrorFormat("UIViewUtility: find no uiview with viewTag {0}", viewTag);
                return;
            }

            uiComp.PlayMoveIn(onComplete);
        }

        public static void PlayMoveIn(int viewId, System.Action onComplete = null)
        {
            Init();
            var uiComp = UIMgr.Instance.GetViewIns(viewId);
            if (uiComp == null)
            {
                LogProxy.LogErrorFormat("UIViewUtility: find no uiview with viewId {0}", viewId);
                return;
            }

            uiComp.PlayMoveIn(onComplete);
        }

        public static void PlayMoveOut(string viewTag, System.Action onComplete = null)
        {
            if (string.IsNullOrEmpty(viewTag)) return;
            Init();
            var uiComp = UIMgr.Instance.GetViewIns(viewTag);
            if (uiComp == null)
            {
                LogProxy.LogErrorFormat("UIViewUtility: find no uiview with viewTag {0}", viewTag);
                return;
            }

            uiComp.PlayMoveOut(onComplete);
        }

        public static void PlayMoveOut(int viewId, System.Action onComplete = null)
        {
            Init();
            var uiComp = UIMgr.Instance.GetViewIns(viewId);
            if (uiComp == null)
            {
                LogProxy.LogErrorFormat("UIViewUtility: find no uiview with viewId {0}", viewId);
                return;
            }

            uiComp.PlayMoveOut(onComplete);
        }

        #endregion

        #region History Manipulation

        public static void ClearHistory()
        {
            Init();
            UIMgr.Instance.ClearHistory();
        }

        public static void RestoreHistory()
        {
            Init();
            UIMgr.Instance.RestoreHistory();
        }

        /// <summary>
        /// 是否能恢复之前的堆栈
        /// </summary>
        public static void SetCanRestoreHistory(bool enabled)
        {
            Init();
            if (UIMgr.Instance)
            {
                UIMgr.Instance.CanRestoreHistory = enabled;
            }
        }

        #endregion

        #region Query

        public static bool IsOpened(string viewTag, bool includeToOpen = true)
        {
            Init();
            return UIMgr.Instance.IsOpened(viewTag, includeToOpen);
        }


        public static bool IsOpened(int viewId, bool includeToOpen = true)
        {
            Init();
            return UIMgr.Instance.IsOpened(viewId, includeToOpen);
        }


        public static bool IsInHistory(string viewTag)
        {
            Init();
            return UIMgr.Instance.IsInHistory(viewTag);
        }

        public static bool IsFocused(string viewTag)
        {
            Init();
            return UIMgr.Instance.IsFocused(viewTag);
        }

        public static bool IsVisible(string viewTag)
        {
            Init();
            return UIMgr.Instance.IsVisible(viewTag);
        }

        public static bool IsOnTop(string viewTag)
        {
            Init();
            return UIMgr.Instance.IsOnTop(viewTag);
        }

        public static UIView GetUIView(int viewId)
        {
            Init();
            return UIMgr.Instance.GetViewIns(viewId);
        }

        public static UIView GetUIView(string viewTag)
        {
            Init();
            return UIMgr.Instance.GetViewIns(viewTag);
        }

        public static string GetTopViewTag(string[] ignoreViewTags = null, bool includeTips = false)
        {
            Init();
            if (includeTips)
            {
                var sys = UIMgr.Instance.SysPanelList;
                if (sys.Count > 0)
                {
                    return sys.Top(ignoreViewTags).ViewTag;
                }
            }

            var showingViewList = UIMgr.Instance.ShowingViewList;
            if (showingViewList.Count == 0)
                return "";
            return showingViewList.Top(ignoreViewTags).ViewTag;
        }

        public static string GetWindowViewTag()
        {
            Init();
            var showingViewList = UIMgr.Instance.ShowingViewList;
            return showingViewList.Bottom().ViewTag;
        }

        public static ObjLinker GetObjLinker(int viewId)
        {
            var viewComp = GetUIView(viewId);
            if (viewComp == null)
                return null;
            var linker = viewComp.GetComponent<ObjLinker>();
            return linker;
        }

        public static Transform GetUIRoot()
        {
            Init();
            return UIMgr.Instance.UIRoot;
        }

        public static GameObject GetBasePlateRoot()
        {
            Init();
            return UIMgr.Instance.BasePlateRoot;
        }

        public static Canvas GetRootCanvas()
        {
            Init();
            return UIMgr.Instance.RootCanvas;
        }

        public static Camera GetUICamera()
        {
            Init();
            return UIMgr.Instance.UICamera;
        }

        public static PapeGames.Rendering.UIBlurController GetBlurController()
        {
            Init();
            return UIMgr.Instance.BlurController;
        }

        public static Vector3 GetRootScale()
        {
            Init();
            return UIMgr.Instance.UIRoot.lossyScale;
        }

        public static List<int> GetOpenList()
        {
            Init();
            return UIMgr.Instance.GetOpenList();
        }

        public static List<int> GetShowList()
        {
            Init();
            return UIMgr.Instance.GetOpenList();
        }

        public static List<string> GetViewTagList(bool includeInvisible = false)
        {
            Init();
            return UIMgr.Instance.GetViewTagList(includeInvisible);
        }

        public static List<UIMgr.ViewItem> TakeViewSnapShot()
        {
            Init();
            return UIMgr.Instance.TakeViewSnapShot();
        }

        #endregion

        #region ViewToggle

        public static void AddViewToggle(string[] viewToggle)
        {
            Init();
            UIMgr.Instance.AddViewToggle(viewToggle);
        }

        public static void ClearViewToggles()
        {
            Init();
            UIMgr.Instance.ClearViewToggles();
        }

        #endregion

        #region UIBlur

        /// <summary>
        /// 重新计算是否需要UIBlur（会修改BlurProgress）
        /// </summary>
        public static void RefreshBlurMask(bool forece = false)
        {
            Init();
            UIMgr.Instance.RefreshBlurMask(forece);
        }

        public static void OpenBlurMask(float duration, System.Action onComplete = null)
        {
            Init();
            UIMgr.Instance.OpenBlurMask(duration, onComplete);
        }

        public static void CloseBlurMask(float duration, System.Action onComplete = null)
        {
            Init();
            UIMgr.Instance.CloseBlurMask(duration, onComplete);
        }

        public static void SetBlurRtAutoReleaseState(bool state = true)
        {
            Init();
            UIMgr.SetBlurRtAutoReleaseState(state);
        }


        public static void SetUIBlurType(string viewTag, UIBlurType type)
        {
            LogProxy.LogFormat("SetUIBlurType: {0}, {1}", viewTag, type);
            Init();
            var uiview = UIMgr.Instance.GetViewIns(viewTag);
            if (uiview != null)
                uiview.PanelBlurType = type;
        }

        public static void SetUIBlurEnable(string viewTag, bool enabled)
        {
            Init();
            var uiview = UIMgr.Instance.GetViewIns(viewTag);
            if (uiview != null)
                uiview.PanelBlurType = enabled ? UIBlurType.Static : UIBlurType.Disable;
        }

        public static void SetUIBlurEnable(int viewId, bool enabled)
        {
            Init();
            var uiview = UIMgr.Instance.GetViewIns(viewId);
            if (uiview != null)
                uiview.PanelBlurType = enabled ? UIBlurType.Static : UIBlurType.Disable;
        }

        public static void SetBlurEnable(string viewTag, bool enabled)
        {
            Init();
            var uiview = UIMgr.Instance.GetViewIns(viewTag);
            if (uiview != null)
            {
                uiview.PanelBlurType = enabled ? UIBlurType.Static : UIBlurType.Disable;
                UIMgr.Instance.RefreshBlurMask();
            }
        }

        public static void SetBlurProgress(float progress)
        {
            Init();
            UIMgr.Instance.SetBlurProgress(progress);
        }

        public static float GetExtraBlurProgress()
        {
            Init();
            return UIMgr.Instance.ExtraBlurProgress;
        }

        public static void SetBlurTarget(UnityEngine.Object blurTarget, float duration = 0)
        {
            Init();
            UIMgr.Instance.SetBlurTarget(ComponentUtility.GetGameObject(blurTarget), duration);
        }

        public static void RemoveBlurTarget(UnityEngine.Object blurTarget, float duration = 0)
        {
            Init();
            UIMgr.Instance.RemoveBlurTarget(ComponentUtility.GetGameObject(blurTarget), duration);
        }

        public static void SetClearTarget(UnityEngine.Object clearTarget, float duration = 0)
        {
            Init();
            UIMgr.Instance.SetClearTarget(ComponentUtility.GetGameObject(clearTarget), duration);
        }

        public static void RemoveClearTarget(UnityEngine.Object clearTarget, float duration = 0)
        {
            Init();
            UIMgr.Instance.RemoveClearTarget(ComponentUtility.GetGameObject(clearTarget), duration);
        }

        #endregion

        #region Operation

        /// <summary>
        /// 刷新UIView的所有Canvas和粒子的排序
        /// </summary>
        /// <param name="viewId"></param>
        public static void RefreshSortingOrder(int viewId)
        {
            Init();
            var comp = UIMgr.Instance.GetViewIns(viewId);
            if (comp != null)
                comp.RefreshSortingOrder();
        }

        public static void RefreshSortingOrder()
        {
            Init();
            UIMgr.Instance.RefreshSortingOrder();
        }

        public static void SetMoveInAndMoveOutDuration(string viewTag, float moveInDuration, float moveOutDuration)
        {
            Init();
            var uiview = UIMgr.Instance.GetViewIns(viewTag);
        }

        public static void SetAutoCloseMode(string viewTag, AutoCloseMode mode)
        {
            Init();
            UIMgr.Instance.SetAutoCloseMode(viewTag, mode);
        }

        //public static void SetAutoCloseMode(int viewId, AutoCloseMode mode)
        //{
        //    Init();
        //    UIMgr.Instance.SetAutoCloseMode(viewId, mode);
        //}

        #endregion

        #region Log Test

        /// <summary>
        /// 是否开启UI日志打印
        /// </summary>
        public static void SetLogEnable(bool enable)
        {
            Init();
            UIMgr.LogEnable = enable;
        }

        /// <summary>
        /// 设置UI动效是否与TimeScale独立
        /// </summary>
        public static void SetTweenUpdateIndependence(bool enable)
        {
            Init();
            UIMgr.TweenUpdateIndependence = enable;
        }

        public static void LogCurViewList()
        {
            Init();
            UIMgr.Instance.LogCurViewList();
        }

        public static void LogSysPanels()
        {
            Init();
            UIMgr.Instance.LogSysPanels();
        }

        public static void LogViewStack()
        {
            Init();
            UIMgr.Instance.LogViewStack();
        }
        
        /// <summary>
        /// 向CrashSight上报当前的UIView堆栈
        /// </summary>
        public static void ReportViewTagStacks()
        {
            #if !UNITY_EDITOR
            if (!CrashSightManager.IsInitialized() || !UIMgr.HasInstance())
                return;
            #endif
            var viewStacks = UIMgr.Instance.GetViewTagList(true);
            var sb = StringUtility.GetStringBuilder();
            foreach (var it in viewStacks)
            {
                if (sb.Length != 0)
                    sb.Append("<<");
                sb.Append(it);
            }

            var str = sb.ToString();
            CrashSightManager.UploadCustomInfo(CrashSightViewTagStacksKey, sb.ToString());
            LogProxy.LogFormat("ReportViewTagStacks: {0}", str);
            StringUtility.ReleaseStringBuilder(sb);
        }
        public static string CrashSightViewTagStacksKey = "UIViewStacks";
        

        #endregion

        #region 注册帧事件

        /// <summary>
        /// 注册帧UIView事件回调
        /// </summary>
        /// <param name="cb"></param>
        public static void AddFrameUIViewEventListener(UIMgr.FrameUIViewEventAction cb)
        {
            Init();
            UIMgr.AddFrameUIViewEventListener(cb);
        }

        /// <summary>
        /// 反注册帧UIView事件回调
        /// </summary>
        /// <param name="cb"></param>
        public static void RemoveFrameUIViewEventListener(UIMgr.FrameUIViewEventAction cb)
        {
            Init();
            UIMgr.RemoveFrameUIViewEventListener(cb);
        }

        /// <summary>
        /// 清除所有帧UIView事件回调
        /// </summary>
        public static void ClearFrameUIViewEventListeners()
        {
            Init();
            UIMgr.ClearFrameUIViewEventListeners();
        }

        #endregion

        public static ViewInfo GetViewInfo(string viewTag)
        {
            //todo:这个功能需要加载Prefab，效率很低
            ViewInfo viewInfo = new ViewInfo();

            //if (string.IsNullOrEmpty(viewInfo.ViewTag))
            {
                var uiPrefab = Res.Load<GameObject>(GetUIPrefabAssetPath(viewTag));
                if (uiPrefab != null)
                    viewInfo = uiPrefab.GetComponent<UIView>().GetViewInfo();
            }
            return viewInfo;
        }

        public static void Destroy()
        {
            s_ViewTagToUIPrefabAssetPathDict.Clear();
            if (UIMgr.HasInstance())
            {
                UIMgr.Instance.CloseWindowsPanels();
                UIMgr.Instance.CloseSysPanels();
                UIMgr.DestroyInstance();
            }

            s_Inited = false;
        }

        public static void Init()
        {
            if (s_Inited)
                return;
            if (!X3Game.GameMgr.IsRunning)
            {
                UIMgr.Instance.Initialize();
            }

            UIMgr.Instance.SetResDelegate(new UIMgrSharpResDelegate());
            RTUtility.Clear();
            s_Inited = true;
        }

        public static void InitUIMgr(IUIMgrDelegate del)
        {
            Init();
            UIMgr.Instance.SetDelegate(del);
            UIMgr.Instance.Initialize();
        }


        public static void SetGameReboot(bool reboot)
        {
            s_GameReboot = reboot;
            UIView.DoNotSetActiveView = reboot;
            if (!reboot)
            {
                s_RebootInsCache.Clear();
            }
        }

        public static bool GameReboot => s_GameReboot;

        public static bool RunScript
        {
            set { s_RunScript = value; }
            get
            {
#if !UNITY_EDITOR
                return true;
#endif
                return s_RunScript;
            }
        }
    }
}