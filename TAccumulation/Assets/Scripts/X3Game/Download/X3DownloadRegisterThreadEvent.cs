using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using PapeGames.X3;
using ResourcesPacker.Runtime;
using UnityEngine;
using XLua;
using Object = System.Object;

namespace X3Game.Download
{
    /// <summary>
    /// 注册下载器线程事件接口，后台下载会通知
    /// </summary>
    [LuaCallCSharp]
    public class X3DownloadRegisterThreadEvent
    {
        #region IOS事件

        public delegate int GetProgress();


#if (UNITY_IOS || UNITY_IPHONE) && _PAPER_SDK_
    [DllImport("__Internal")]
    private static extern int getProgressCallback(GetProgress debugEvent);
#endif

        #endregion


        #region Android事件

#if UNITY_ANDROID && _PAPER_SDK_
    public AndroidJavaClass nativeInstance;
    public DownloadHandler downloadHandler;

    private const string IDOWNLOADNAME = "com.papegames.gamelib.utils.download.IDownload";
    private const string DOWNLOADCLASSNAME = "com.papegames.gamelib.utils.download.DownloadService";

    
    public class DownloadHandler : AndroidJavaProxy
    {

        private GetProgress m_getProgress;
        
        public DownloadHandler() : base(IDOWNLOADNAME)
        {
            
        }

        public void SetProgressCallBack(GetProgress callBack)
        {
            m_getProgress = callBack;
        }

        int getProgress()
        {
            // ReSharper disable once PossibleInvalidOperationException
            return (int) m_getProgress?.Invoke();
        }
    }
#endif

        #endregion

        private static X3DownloadRegisterThreadEvent _x3DownloadRegisterThreadEvent;

        public static X3DownloadRegisterThreadEvent Instance =>
            _x3DownloadRegisterThreadEvent ??
            (_x3DownloadRegisterThreadEvent = new X3DownloadRegisterThreadEvent());

        /// <summary>
        /// 下载的大小 单位b
        /// </summary>
        public static long downloadSize = 0;

        /// <summary>
        /// 总大小 单位 b
        /// </summary>
        public static long totalSize = 0;

        public static float progress = 0;

        public bool canDownloadInMobile = false;


        private int m_curProgress = 0;

        private RuntimePlatform m_playform;

        private int netWorkState = 0;

        private bool m_InBackGround = false;

        private bool m_NetWorkChange = false;
        private int m_networkState = 0;
        private Action<AlertResultType> m_pauseEvent;
        private Action<AlertResultType> m_continueEvent;

        public X3DownloadRegisterThreadEvent()
        {
            m_playform = Application.platform;
            m_InBackGround = false;
            //注册多线程事件
            ResPatchEventSystem.Instance.RegisterThreadedEvent(OnEventNotification);
        }

        public void Close()
        {
            ResPatchEventSystem.Instance.UnregisterThreadedEvent(OnEventNotification);
        }

        public void Tick()
        {
            if (!m_NetWorkChange) return;
            Debug.Log($"Tick EventMgr.Dispatch RESUPDATE_NETWORK_CHANGE {m_networkState}");
            m_NetWorkChange = false;
            EventMgr.Dispatch("RESUPDATE_NETWORK_CHANGE",
                new List<object>() { m_networkState, m_pauseEvent, m_continueEvent });
        }

        public void OnFocusSendEventMessage()
        {
            if (m_pauseEvent == null)
                return;
            Debug.Log($"OnFocusSendEventMessage EventMgr.Dispatch RESUPDATE_NETWORK_CHANGE {m_networkState}");
            EventMgr.Dispatch("RESUPDATE_NETWORK_CHANGE",
                new List<object>() { m_networkState, m_pauseEvent, m_continueEvent });
        }

        public void RegisterThreadedEvent()
        {
            m_InBackGround = true;
#if (UNITY_IOS || UNITY_IPHONE) && _PAPER_SDK_
        getProgressCallback(GetDownloadProgress);
#elif UNITY_ANDROID && _PAPER_SDK_
        if (nativeInstance == null)
        {
            nativeInstance = new AndroidJavaClass(DOWNLOADCLASSNAME);
        }

        if (downloadHandler == null)
        {
            downloadHandler = new DownloadHandler();
            downloadHandler.SetProgressCallBack(GetDownloadProgress);
        }
             nativeInstance.CallStatic("registerDownloadCallback",downloadHandler);
#endif
        }

        public void UnregisterThreadedEvent()
        {
            m_InBackGround = false;
#if UNITY_ANDROID && _PAPER_SDK_
        if (nativeInstance == null)
        {
            nativeInstance = new AndroidJavaClass(DOWNLOADCLASSNAME);
        }

        if (downloadHandler == null)
        {
            downloadHandler = new DownloadHandler();
            downloadHandler.SetProgressCallBack(GetDownloadProgress);
        }
            nativeInstance.CallStatic("unregisterDownloadCallback");
#endif
        }

        [AOT.MonoPInvokeCallback(typeof(GetProgress))]
        private static int GetDownloadProgress()
        {
            Debug.Log($"downloadSize {downloadSize} totalSize {totalSize} progress{progress}");
            return (int)progress;
        }

        private void OnEventNotification(ResPatchStateType stateType, OperationType opType, EventParameter arg1,
            EventParameter arg2, EventParameter arg3)
        {
            //后台情况只需要关注下载状态，设置下本地的下载大小
            if (opType == OperationType.DownloadProgressChanged)
            {
                //下载进度
                downloadSize = arg1.LongValue;
                totalSize = arg2.LongValue;
                progress = (1.0f * downloadSize / totalSize) * 100;
            }
            else if (opType == OperationType.NetworkStateChanged)
            {
                // --- 网络状态变化的通知，-1 = 无效状态，0 = 无网络，1 = 流量， 2 = wifi, 参数和unity提供NetworkReachability对应
                // ---@param arg1 = long parameter (网络状态)
                // ---@param arg2 = action parameter (网络变化是否暂停，confirm表示暂停下载，cancel表示不暂停，
                // --- 如果要暂停，正常情况，会有弹窗提示，需要第三个参数来控制)
                // ---@param arg3 = action parameter (网络变化提示，需要玩家同意，或者view自动同意，直接回调)
                var netWorkState = (int)arg1.LongValue;
                Debug.Log(
                    $"X3DownloadRegisterThreadEvent OnEventNotification  OperationType.NetworkStateChanged  netWorkState {netWorkState}  m_InBackGround{m_InBackGround}");
                //前台事件处理，转到子线程，进行事件转发
                m_networkState = netWorkState;
                m_pauseEvent = arg2.AlterActionValue;
                m_continueEvent = arg3.AlterActionValue;
                if (m_InBackGround)
                {
                    //后台状态 网络状态， 无网，流量状态 暂停下载， wifi状态恢复
                    if (netWorkState == 1)
                    {
                        //移动流程判断是否同意，如果不同意就暂停，如果同意的话就继续下载
                        if (!canDownloadInMobile)
                        {
                            arg2.AlterActionValue.Invoke(AlertResultType.Confirm);
                        }
                        else
                        {
                            arg3.AlterActionValue?.Invoke(AlertResultType.Confirm);
                        }
                    }
                    else if (netWorkState == 0)
                    {
                        arg2.AlterActionValue.Invoke(AlertResultType.Confirm);
                    }
                    else if (netWorkState == 2)
                    {
                        arg3.AlterActionValue?.Invoke(AlertResultType.Confirm);
                    }
                }
                else
                {
                    m_NetWorkChange = true;
                }
            }
        }
    }
}