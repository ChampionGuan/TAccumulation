using System;
using PapeGames.X3;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public class SDKMgr : Singleton<SDKMgr>
    {
        /// <summary>
        ///是否初始化 
        /// </summary>
        private bool m_IsInit;

        /// <summary>
        /// 是否已经登录
        /// </summary>
        private bool m_IsLogin;

        /// <summary>
        /// 是否是sdk模式
        /// </summary>
        private bool m_IsHaveSDK;

        /// <summary>
        ///sdk 登陆信息的json数据 
        /// </summary>
        private string m_CurLoginInfoJson;

        /// <summary>
        /// sdk 设备信息的json数据
        /// </summary>
        private string m_CurDeviceInfoJson;

        /// <summary>
        /// 初始化
        /// </summary>
        protected override void Init()
        {
            base.Init();
#if _NO_SDK_
            m_IsHaveSDK = false;
#elif _PAPER_SDK_
            m_IsHaveSDK = true;
#else
            m_IsHaveSDK = false;
#endif
        }

        /// <summary>
        /// 清理操作
        /// </summary>
        protected override void UnInit()
        {
            base.UnInit();
            Reset();
        }

        /// <summary>
        /// 重置
        /// </summary>
        public void Reset()
        {
            if (PaperSDKCallback.HasInstance())
            {
                PaperSDKCallback.GetInstance().ClearCallBack();
            }
        }

        /// <summary>
        /// sdk注冊回调接口
        /// </summary>
        /// <param name="url"></param>
        /// <param name="param"></param>
        /// <param name="isGlobal"></param>
        /// <param name="callBack"></param>
        public void Router(string url, string param, bool isGlobal = false, Action<string> callBack = null)
        {
            PaperSDKInterface.Instance.PaperRouter(url, param, callBack, isGlobal);
        }

        /// <summary>
        /// 是否已经初始化
        /// </summary>
        public bool IsInit
        {
            get => m_IsInit;
            set => m_IsInit = value;
        }

        /// <summary>
        /// 是否已登录
        /// </summary>
        public bool IsLogin
        {
            get => m_IsLogin;
            set => m_IsLogin = value;
        }

        /// <summary>
        /// 是否是sdk包
        /// </summary>
        public bool IsHaveSDK
        {
            get => m_IsHaveSDK;
        }

        /// <summary>
        ///sdk 登陆信息的json数据 
        /// </summary>
        public string CurLoginInfoJson
        {
            get => m_CurLoginInfoJson;
            set => m_CurLoginInfoJson = value;
        }

        /// <summary>
        /// sdk 设备信息的json数据
        /// </summary>
        public string CurDeviceInfoJson
        {
            get => m_CurDeviceInfoJson;
            set => m_CurDeviceInfoJson = value;
        }
    }
}