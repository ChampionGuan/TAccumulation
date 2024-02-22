using System;
using PapeGames.X3;
using UnityEditor;
using UnityEngine;

namespace X3Game
{
    [System.Serializable]
    [XLua.LuaCallCSharp]
    public class AppInfo
    {
        #region 区域与语言

        /// <summary>
        /// 区域
        /// </summary>
        public int Region = (int)RegionType.ChinaMainland;

        /// <summary>
        /// 语言
        /// </summary>
        public int Lang = (int)Locale.Language.ZH_CN;

        /// <summary>
        /// 音频语言
        /// </summary>
        public int SoundLang = (int)Locale.Language.ZH_CN;

        #endregion

        #region 包体版本信息

        public string BundleId = "com.paper.X3Test";
        public string BranchInfo = "default";

        /// <summary>
        /// 引擎版本号，1.4.7开始不支持运行时获取，所以在构建时写入这里
        /// </summary>
        public string TcVersion = "";

        /// <summary>
        /// 包体版本号
        /// </summary>
        public string AppVer = "0.0.1";

        /// <summary>
        /// 包体资源版本号
        /// </summary>
        public string ResVer = "0.0.1";

        public string p4Ver = "";

        public int BuildNum = 10;

        #endregion

        #region 服务器信息

        public int ChannelId = 1001;
        public int[] ServerRegionList;

        public int ServerRegionId
        {
            get
            {
                if (ServerRegionList != null && ServerRegionList.Length > 0)
                    return ServerRegionList[ServerRegionList.Length - 1];
                return 1;
            }
            set
            {
                if (ServerRegionList == null || ServerRegionList.Length == 0)
                {
                    ServerRegionList = new int[1] { value };
                }
                else
                {
                    ServerRegionList[ServerRegionList.Length - 1] = value;
                }
            }
        }

        #endregion

        #region Cms信息

        public string CmsUrl = "https://api-test.papegames.com:12101";
        public string ClientId = "";
        public string ClientKey = "";

        #endregion

        #region 其它

        /// <summary>
        /// 本包体用户登录的权限
        /// </summary>
        public int RoleAuthority = 0;

        public bool ResUpdateEnable = false;

        /// <summary>
        /// Editor下使用，用来指定要下载那份资源
        /// </summary>
        public string ResUpdateKey;

        public string SdkUrl = "https://nnsecuretesting.papegames.com:12111";

        public string supportUrl = "https://support-x3.papegames.com/?";

        public string reportUrl = "https://cspro-api-test.papegames.com";

        /// <summary>
        /// 是否是审核模式
        /// </summary>
        public bool IsAudit = false;

        #endregion

        public static AppInfo ParseFromJson(string json)
        {
            if (string.IsNullOrEmpty(json))
                return null;
            var info = JsonUtility.FromJson<AppInfo>(json);
            return info;
        }

        public bool CopyFrom(AppInfo other)
        {
            if (other == null)
                return false;
            this.Region = other.Region;
            this.Lang = other.Lang;
            this.SoundLang = other.SoundLang;
            this.BundleId = other.BundleId;
            this.BranchInfo = other.BranchInfo;
            this.AppVer = other.AppVer;
            this.ResVer = other.ResVer;
            this.BuildNum = other.BuildNum;
            this.ChannelId = other.ChannelId;
            this.ServerRegionId = other.ServerRegionId;
            this.CmsUrl = other.CmsUrl;
            this.ClientId = other.ClientId;
            this.ClientKey = other.ClientKey;
            this.RoleAuthority = other.RoleAuthority;
            this.ResUpdateEnable = other.ResUpdateEnable;
            this.SdkUrl = other.SdkUrl;
            this.p4Ver = other.p4Ver;
            this.supportUrl = other.supportUrl;
            this.IsAudit = other.IsAudit;
            this.reportUrl = other.reportUrl;
            this.TcVersion = other.TcVersion;
            return true;
        }

#if UNITY_EDITOR
        //[MenuItem("Test/TestParse")]
        static void TestParse()
        {
            var str = FileUtility.ReadText(System.IO.Path.Combine(Application.streamingAssetsPath, "AppInfo.json"));
            var obj = AppInfo.ParseFromJson(str);
        }
#endif
    }

    [System.Serializable]
    [XLua.LuaCallCSharp]
    public class UserAppInfo
    {
        /// <summary>
        /// 语言
        /// </summary>
        public int Lang = (int)Locale.Language.ZH_CN;

        /// <summary>
        /// 语音
        /// </summary>
        public int SoundLang = (int)Locale.Language.ZH_CN;

#if UNITY_EDITOR
        /// <summary>
        /// 地区
        /// </summary>
        public int Region = (int)Locale.RegionType.ChinaMainland;
#endif

        public string ResVer = "0.0.1";
        public string ResUpdateUrl = "";
        public string SdkUrl = "";
    }

#if UNITY_EDITOR
    [System.Serializable]
    public class EditorAppInfo
    {
        public int CmsEnvIdx;
        public bool CmsEnvCustomEnable;
        public string CmsUrl;
        public string ClientId;
        public string ClientKey;
        public int ServerRegionId;
        public int[] ServerRegionList;
        public int ChannelId;
        public bool ResUpdateEnable;
        public CmsEnv[] CmsEnvList;
        public string[] ResUpdateKeyList;
        public int ResUpdateKeyIndex;
        public int version;
        public bool OpenSubPackageCheck;
        public bool IsAudit;

        public string ResolvedCmsUrl
        {
            get
            {
                if (CmsEnvCustomEnable)
                    return CmsUrl;
                if (CmsEnvList != null && CmsEnvList.Length > 0)
                    return CmsEnvList[CmsEnvIdx].ServerUrl;
                return "";
            }
        }

        public string ResolvedClientId
        {
            get
            {
                if (CmsEnvCustomEnable)
                    return ClientId;
                if (CmsEnvList != null && CmsEnvList.Length > 0)
                    return CmsEnvList[CmsEnvIdx].ClientId;
                return "";
            }
        }

        public string ResolvedClientKey
        {
            get
            {
                if (CmsEnvCustomEnable)
                    return ClientKey;
                if (CmsEnvList != null && CmsEnvList.Length > 0)
                    return CmsEnvList[CmsEnvIdx].ClientKey;
                return "";
            }
        }

        public void ReadFrom(EditorAppInfo other)
        {
            if (other == null)
                return;
            this.CmsEnvIdx = other.CmsEnvIdx;
            this.CmsEnvCustomEnable = other.CmsEnvCustomEnable;
            this.CmsUrl = other.CmsUrl;
            this.ClientId = other.ClientId;
            this.ClientKey = other.ClientKey;
            this.ServerRegionId = other.ServerRegionId;
            this.ServerRegionList = other.ServerRegionList;
            this.ChannelId = other.ChannelId;
            this.ResUpdateEnable = other.ResUpdateEnable;
            this.ResUpdateKeyList = other.ResUpdateKeyList;
            this.ResUpdateKeyIndex = other.ResUpdateKeyIndex;
            this.version = other.version;
            this.OpenSubPackageCheck = other.OpenSubPackageCheck;
        }

        public void ReadFrom(AppInfo other)
        {
            if (other == null)
                return;
            var defaultEditorAppInfo = AppInfoHelper.LoadDefaultEditorAppInfo();

            this.ServerRegionId = other.ServerRegionId;
            this.ServerRegionList = other.ServerRegionList;
            this.ChannelId = other.ChannelId;
            this.ResUpdateEnable = other.ResUpdateEnable;
            for (int i = 0; i < defaultEditorAppInfo.ResUpdateKeyList.Length; i++)
            {
                if (defaultEditorAppInfo.ResUpdateKeyList[i] == other.ResUpdateKey)
                {
                    this.ResUpdateKeyIndex = i;
                    break;
                }
            }

            int idx = 0;
            foreach (var env in defaultEditorAppInfo.CmsEnvList)
            {
                if (env.ClientId == other.ClientId && env.ClientKey == other.ClientKey && env.ServerUrl == other.CmsUrl)
                {
                    this.CmsEnvIdx = idx;
                    break;
                }

                idx++;
            }
        }

        [System.Serializable]
        public class CmsEnv
        {
            public string Name;
            public string ServerUrl;
            public string ClientId;
            public string ClientKey;
        }
    }
#endif
}