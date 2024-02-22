using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using PapeGames.X3;
using ResourcesPacker.Runtime;
using UnityEngine;
using UnityEngine.Networking;
using XResVirtualFileSystem;
using Logger = UnityEngine.Logger;

namespace X3Game.GameHelper
{
    [XLua.LuaCallCSharp]
    public class ResUpdateUtility
    {
        public static void ReqResUpdate(Action<bool> action)
        {
            var serverURL = GetUrl();
            CoroutineProxy.StartCoroutine(SendWebPost(serverURL,
                result => { HandleResInfoResponse(result, action); },
                (result, isNetworkError) => { action?.Invoke(false); }));
        }

        private static IEnumerator SendWebPost(string url, Action<string> successCb, Action<string, bool> failureCb)
        {
            var req = UnityWebRequest.Post(url, "POST");
            req.SetRequestHeader("connection", "close");
            req.SetRequestHeader("Content-Type", "application/json");
            req.SetRequestHeader("Accept", "application/json");
            req.timeout = 5;
            req.certificateHandler = new X3Game.Networking.UnityWebRequestCertificator();
            req.SendWebRequest();
            while (!req.isDone)
            {
                yield return null;
            }

            DefaultProcResult(req, successCb, failureCb);
        }


        private static void DefaultProcResult(UnityWebRequest req, Action<string> successCb,
            Action<string, bool> errorCb)
        {
            if (req.isNetworkError)
            {
                errorCb?.Invoke(req.error, true);
            }

            else if (req.responseCode == 200)
            {
                successCb?.Invoke(req.downloadHandler.text);
            }
            else
            {
                errorCb?.Invoke(req.error, false);
            }
        }


        private static void HandleResInfoResponse(string responseTxt, Action<bool> action)
        {
            bool ret = HandleResInfoResponse(responseTxt);
            action?.Invoke(ret);
        }

        private static bool HandleResInfoResponse(string responseTxt)
        {
            var responseData = MiniJson.FromJson<Dictionary<string, object>>(responseTxt);
            if (responseData.ContainsKey("ret"))
            {
                var ret = int.Parse(responseData["ret"].ToString());
                if (ret > 0)
                {
                    Debug.LogError($"response error : {ret}");
                    return false;
                }
                else
                {
                    var mOldAppVersion = Application.version;
                    var mOldResVersion = PlayerPrefs.GetString("resVersion", "");
                    var isAudit = int.Parse(responseData["game_config_audit"].ToString());
                    AppInfoMgr.Instance.AppInfo.IsAudit = isAudit == 1;
                    //审核模式不需要更新
                    if (AppInfoMgr.Instance.AppInfo.IsAudit)
                    {
                        return false;
                    }

                    var result = (Dictionary<string, object>)responseData["game_config_patch"];
                    if (result == null)
                    {
                        return false;
                    }

                    var extra = (Dictionary<string, object>)result["extra"];
                    var hotfixVersion = (string)extra["hotfix_version"];
                    var apkConfig = (Dictionary<string, object>)responseData["game_config_apk"];
                    var apkVersion = (string)apkConfig["apk_version"];

                    //判断app version 是不是最新
                    if (Version.TryParse(mOldAppVersion, out var oldAppVersion) == false)
                        oldAppVersion = new System.Version(0, 0);
                    if (Version.TryParse(apkVersion, out var newAppVersion) == false)
                        newAppVersion = new System.Version(0, 0);
                    if (newAppVersion > oldAppVersion)
                    {
                        return true;
                    }
                    else
                    {
                        //资源是不是最新
                        if (Version.TryParse(mOldResVersion, out var oldResVersion) == false)
                            oldResVersion = new System.Version(0, 0);
                        if (Version.TryParse(hotfixVersion, out var newResVersion) == false)
                            newResVersion = new System.Version(0, 0);
                        return newResVersion > oldResVersion;
                    }
                }
            }
            else
            {
                return false;
            }
        }

        public static async Task<bool> ReqResUpdateAsync()
        {
            var serverURL = GetUrl();
            var req = UnityWebRequest.Post(serverURL, "POST");
            req.SetRequestHeader("connection", "close");
            req.SetRequestHeader("Content-Type", "application/json");
            req.SetRequestHeader("Accept", "application/json");
            req.timeout = 5;
            req.certificateHandler = new X3Game.Networking.UnityWebRequestCertificator();
            await req.SendWebRequest();
            if (req.isNetworkError)
            {
                return false;
            }

            else if (req.responseCode == 200)
            {
                return HandleResInfoResponse(req.downloadHandler.text);
            }
            else
            {
                return false;
            }
        }

        static string GetUrl()
        {
            var appInfo = AppInfoMgr.Instance.AppInfo;
            var timeStamp = ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString();
            var sig = PaperSDKSigUtil.Md5Sum(appInfo.ClientKey + timeStamp);
            var serverURL = string.Format(
                "{0}/{1}?clientid={2}&sig={3}&timestamp={4}&channel={5}&role={6}&build={7}&apkversion={8}&region={9}",
                X3ResPatchWebRequest.ResPatchInfoUrl, "v1/gameconfig/patchlist", appInfo.ClientId, sig, timeStamp,
                appInfo.ChannelId,
                appInfo.RoleAuthority,
                appInfo.BuildNum,
                Application.version,
                appInfo.ServerRegionId);
            return serverURL;
        }
    }

    public static class ExtensionMethods
    {
        public static TaskAwaiter GetAwaiter(this AsyncOperation asyncOp)
        {
            var tcs = new TaskCompletionSource<object>();
            asyncOp.completed += obj => { tcs.SetResult(null); };
            return ((Task)tcs.Task).GetAwaiter();
        }
    }
}