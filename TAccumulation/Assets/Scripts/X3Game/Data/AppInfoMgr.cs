using System;
using Newtonsoft.Json;
using PapeGames.X3;
using UnityEngine;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public class AppInfoMgr : Singleton<AppInfoMgr>
    {
        private AppInfo m_AppInfo;
        private UserAppInfo m_UserAppInfo;

        public AppInfo AppInfo => m_AppInfo;

        #region UserAppInfo

        #region Lang

        public Locale.Language Lang => (Locale.Language)m_UserAppInfo.Lang;
        public Locale.Language SoundLang => (Locale.Language)m_UserAppInfo.SoundLang;
        public Locale.RegionType Region => (Locale.RegionType)m_AppInfo.Region;

        public void SetLang(int lang)
        {
            if (m_UserAppInfo.Lang == lang)
                return;
            m_UserAppInfo.Lang = lang;
        }

        public void SetSoundLang(int lang)
        {
            if (m_UserAppInfo.SoundLang == lang)
                return;
            m_UserAppInfo.SoundLang = lang;
        }

        public void SetLang(Locale.Language lang)
        {
            SetLang((int)lang);
        }

        public void SetSoundLang(Locale.Language lang)
        {
            SetSoundLang((int)lang);
        }

        #endregion

        public void SetResVer(string ver)
        {
            m_UserAppInfo.ResVer = ver;
        }

        public void SetResUpdateUrl(string url)
        {
            m_UserAppInfo.ResUpdateUrl = url;
        }

        /// <summary>
        /// 保存UserAppInfo
        /// </summary>
        public void SaveUserAppInfo()
        {
            if (m_UserAppInfo == null)
            {
                X3Debug.LogErrorFormat("AppInfoMgr.Save failed: not inited.");
                return;
            }

            var str = JsonConvert.SerializeObject(m_UserAppInfo);
            PlayerPrefs.SetString(USER_APP_INFO_KEY, str);
            PlayerPrefs.Save();
        }

        #endregion

        protected override void Init()
        {
            base.Init();
            InitAppInfo();
        }

        /// <summary>
        /// 初始化AppInfo
        /// </summary>
        public void InitAppInfo()
        {
            AppInfo appInfo = AppInfoHelper.LoadAppInfo();

#if UNITY_EDITOR
            if (appInfo == null)
            {
                EditorAppInfo defaultEditorAppInfo = AppInfoHelper.LoadDefaultEditorAppInfo();
                appInfo = new AppInfo();
                var serverRegion = ProjectEnvHelper.GetInstance().GetValue("SERVER_REGION");
                if (defaultEditorAppInfo != null)
                {
                    if (int.TryParse(serverRegion, out int serverRegionNum))
                    {
                        appInfo.ServerRegionId = serverRegionNum;
                    }
                    else
                    {
                        appInfo.ServerRegionId = defaultEditorAppInfo.ServerRegionId;
                    }
                    appInfo.ChannelId = defaultEditorAppInfo.ChannelId;
                    appInfo.CmsUrl = defaultEditorAppInfo.ResolvedCmsUrl;
                    appInfo.ClientId = defaultEditorAppInfo.ResolvedClientId;
                    appInfo.ClientKey = defaultEditorAppInfo.ResolvedClientKey;
                    appInfo.ResUpdateEnable = defaultEditorAppInfo.ResUpdateEnable;
                    appInfo.ResUpdateKey =
                        defaultEditorAppInfo.ResUpdateKeyList[defaultEditorAppInfo.ResUpdateKeyIndex];
                    appInfo.IsAudit = defaultEditorAppInfo.IsAudit;
                    ResExtension.DebugForSubpackageEnable = defaultEditorAppInfo.OpenSubPackageCheck;
                }
            }
#endif

            m_AppInfo = appInfo;
            string userAppInfoStr = PlayerPrefs.GetString(USER_APP_INFO_KEY, "");
            m_UserAppInfo = JsonConvert.DeserializeObject<UserAppInfo>(userAppInfoStr);
            if (m_UserAppInfo == null)
            {
                m_UserAppInfo = new UserAppInfo();
                m_UserAppInfo.Lang = m_AppInfo.Lang;
                m_UserAppInfo.SoundLang = m_AppInfo.SoundLang;
                m_UserAppInfo.ResVer = m_AppInfo.ResVer;
                SaveUserAppInfo();
            }
            else
            {
                if (string.IsNullOrEmpty(m_UserAppInfo.ResVer))
                    m_UserAppInfo.ResVer = m_AppInfo.ResVer;
            }

            if (m_UserAppInfo.Lang == 0)
            {
                m_UserAppInfo.Lang = (int)Locale.Language.ZH_CN;
            }

            if (m_UserAppInfo.SoundLang == 0)
            {
                m_UserAppInfo.SoundLang = (int)Locale.Language.ZH_CN;
            }
        }

        private const string USER_APP_INFO_KEY = "X3GAME_USER_APP_INFO_KEY";
    }
}