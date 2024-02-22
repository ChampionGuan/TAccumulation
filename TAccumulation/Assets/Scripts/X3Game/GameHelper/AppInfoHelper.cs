using System;
using Newtonsoft.Json;
using UnityEngine;
#if UNITY_EDITOR
using System.IO;
using UnityEditor;
#endif
using PapeGames.X3;

namespace X3Game
{
    public static class AppInfoHelper
    {
#if UNITY_EDITOR
        public static EditorAppInfo LoadDefaultEditorAppInfo()
        {
            if (string.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(EDITOR_DEFAULT_GAMECONFIG_FILE_PATH)))
            {
                Debug.LogErrorFormat("请确保配置文件存在：{0}", EDITOR_DEFAULT_GAMECONFIG_FILE_PATH);
                return null;
            }

            var txt = AssetDatabase.LoadAssetAtPath<TextAsset>(EDITOR_DEFAULT_GAMECONFIG_FILE_PATH).text;
            var ret = JsonConvert.DeserializeObject<EditorAppInfo>(txt);
            return ret;
        }

        public static void WriteCustomEditorAppInfo(EditorAppInfo customEditorAppInfo)
        {
            string filePath = System.IO.Path.Combine(Application.streamingAssetsPath, GameDefines.APPINFO_FILE_NAME);
            AppInfo appInfo = null;
            if (File.Exists(filePath))
            {
                try
                {
                    appInfo = AppInfo.ParseFromJson(FileUtility.ReadText(filePath, false));
                }
                catch (Exception e)
                {
                    Debug.LogErrorFormat("读取{0}文件失败：{1}", filePath, e.Message);
                }
            }

            //判断本次写入是否需要设置为默认的serverRegion
            var setDefaultServerRegion = false;
            if (appInfo == null)
            {
                appInfo = new AppInfo();
                setDefaultServerRegion = true;
            }

            var dftEditorAppInfo = LoadDefaultEditorAppInfo();
            appInfo.ServerRegionId = 0;
            //设置对应的serverRegion
            if (setDefaultServerRegion)
            {
                var serverRegion = ProjectEnvHelper.GetInstance().GetValue("SERVER_REGION");
                if (int.TryParse(serverRegion, out var serverRegionNum))
                {
                    appInfo.ServerRegionId = serverRegionNum;
                }
                else
                {
                    appInfo.ServerRegionId = customEditorAppInfo.ServerRegionId;
                }
            }

            appInfo.ServerRegionList = new int[] { customEditorAppInfo.ServerRegionId };
            appInfo.ChannelId = customEditorAppInfo.ChannelId;
            if (customEditorAppInfo.CmsEnvCustomEnable)
            {
                appInfo.CmsUrl = customEditorAppInfo.CmsUrl;
                appInfo.ClientId = customEditorAppInfo.ClientId;
                appInfo.ClientKey = customEditorAppInfo.ClientKey;
            }
            else
            {
                var cmsEnv = dftEditorAppInfo.CmsEnvList[customEditorAppInfo.CmsEnvIdx];
                appInfo.CmsUrl = cmsEnv.ServerUrl;
                appInfo.ClientId = cmsEnv.ClientId;
                appInfo.ClientKey = cmsEnv.ClientKey;
            }

            appInfo.ResUpdateEnable = customEditorAppInfo.ResUpdateEnable;
            appInfo.ResUpdateKey = customEditorAppInfo.ResUpdateKeyList[customEditorAppInfo.ResUpdateKeyIndex];
            appInfo.IsAudit = customEditorAppInfo.IsAudit;
            ResExtension.DebugForSubpackageEnable = customEditorAppInfo.OpenSubPackageCheck;
            var txt = JsonConvert.SerializeObject(appInfo);
            FileUtility.WriteText(filePath, txt);
        }

        public static bool ReadCustomEditorAppInfo(EditorAppInfo inAppInfo)
        {
            var obj = JsonConvert.DeserializeObject<EditorAppInfo>(EditorPrefs.GetString(EDITOR_CUSTOM_GAMECONFIG_KEY,
                ""));
            if (obj != null)
            {
                inAppInfo.ReadFrom(obj);
                return true;
            }

            return false;
        }

        public const string EDITOR_DEFAULT_GAMECONFIG_FILE_PATH = @"Assets/Editor/GameConfig/EditorAppInfo.json";
        const string EDITOR_CUSTOM_GAMECONFIG_KEY = @"EDITOR_CUSTOM_GAMECONFIG_KEY";
#endif

        /// <summary>
        /// 加载StreamingAssets目录下的appinfo.json文件
        /// </summary>
        /// <returns></returns>
        public static AppInfo LoadAppInfo()
        {
            AppInfo appInfo = null;
            string filePath = System.IO.Path.Combine(Application.streamingAssetsPath, GameDefines.APPINFO_FILE_NAME);
            var str = FileUtility.ReadText(filePath, false);

            if (string.IsNullOrEmpty(str))
            {
#if !UNITY_EDITOR
                X3Debug.LogErrorFormat("GameStart: Load appinfo({0}) failed.", filePath);
#endif
            }
            else
            {
                //Decrypt
                if (str[0] != '{')
                {
                    str = AESHelper.AesDecrypt(str, GameDefines.APPINFO_AES_KEY, GameDefines.APPINFO_AES_IV);
                }

                if (string.IsNullOrEmpty(str))
                {
                    X3Debug.LogFatalFormat("GameStart: Decrypt appInfo({0}) failed.", filePath);
                }

                try
                {
                    appInfo = AppInfo.ParseFromJson(str);
                }
                catch (System.Exception e)
                {
                    X3Debug.LogFatalFormat("GameStart: Parse appInfo({0}) failed. {1}", filePath, e.Message);
                }
            }

            return appInfo;
        }
    }
}