namespace X3Game.GameHelper
{ 
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

/// <summary>
/// UnityWebRequest上传下载
/// 限制携程数量
/// </summary>

public static class WebRequestUtil 
{
    // private static Dictionary<string, DownCache> m_cacheDownload = new Dictionary<string, DownCache>();//下载缓存
    private static Dictionary<string, TaskInfo> m_taskCallBack = new Dictionary<string, TaskInfo>();//下载回调缓存
    
    private static List<string> m_waitDownloadTask = new List<string>();//等待下载的列表
    private static List<string> m_curDownloadTask = new List<string>();//当前正在下载的列表

    private static int m_maxDownloadNum = 3;
    private static int m_DownloadTimeOut = 5;//下载超时
    
    public static Func<UnityWebRequest, bool> DownloadCompleteFunc;

    /// <summary>
    /// 一个url对应一个TaskInfo，里面保存了该url的下载类型DownloadHandler，所有监听该url下载的回调
    /// </summary>
    private class TaskInfo 
    {
        private List<Action<TempCache>> m_callBacks = new  List<Action<TempCache>>();
        
        public string Url;
        public DownloadHandler Handle;

        public TaskInfo(string url, DownloadHandler handle) 
        {
            Url = url;
            Handle = handle;
        }

        public void AddCallBack(Action<TempCache> callBack) 
        {
            if (!m_callBacks.Contains(callBack)) {
                m_callBacks.Add(callBack);
            }
        }
        
        public void RemoveCallBack(Action<TempCache> callBack) {
            if (m_callBacks.Contains(callBack)) {
                m_callBacks.Remove(callBack);
            }
        }

        public void ClearCallBack() {
            m_callBacks.Clear();
        }

        public int Count() {
            return m_callBacks.Count;
        }

        public void DownloadEnd(TempCache cache) {
            for (int i = 0; i < m_callBacks.Count; i++) {
                if (m_callBacks[i] != null) {
                    m_callBacks[i](cache);
                }
            }

            ClearCallBack();
        }
    }
    
    public class TempCache {
        public byte[] data;
        public string text;
        public Texture2D tex;
        public string url;
        public bool success;
    }

    //下载
    public static void Download(string url, Action<TempCache> callBack, DownloadHandler handle = null) {
        if (callBack == null) return;

        TaskInfo taskInfo = null;
        if (!m_taskCallBack.TryGetValue(url, out taskInfo)) 
        {
            taskInfo = new TaskInfo(url, handle);
            m_taskCallBack.Add(url, taskInfo);
        }
        
        taskInfo.AddCallBack(callBack);

        //不在当前的下载、等待列表，加入执行队列
        if (!m_waitDownloadTask.Contains(url) && !m_curDownloadTask.Contains(url)) {
            CastTask(url);
        }
    }

    private static void CastTask(string url) 
    {
        if (string.IsNullOrEmpty(url)) 
        {
            if (m_waitDownloadTask.Count == 0) {
                return;
            }
            
            url = m_waitDownloadTask[0];
            m_waitDownloadTask.RemoveAt(0);
        }

        if (m_curDownloadTask.Count > m_maxDownloadNum) 
        {
            m_waitDownloadTask.Add(url);
        } else {
            // int taskId = TaskManager.Instance.Create(RealDownload(url));
            PapeGames.X3.CoroutineProxy.StartCoroutine(RealDownload(url));
            m_curDownloadTask.Add(url);
        }
    }

    private static IEnumerator RealDownload(string url) 
    {
        UnityWebRequest req = UnityWebRequest.Get(url);
        req.timeout = m_DownloadTimeOut;
        
        TaskInfo taskInfo = null;
        if (m_taskCallBack.TryGetValue(url, out taskInfo)) {
            req.downloadHandler = taskInfo.Handle;
        }
        
        yield return req.SendWebRequest();
        if (req.isNetworkError || req.isHttpError || req.responseCode != 200)
        {
            HandleDownload(url, null, false);
            DownloadEnd(url);
            req.Dispose();
            yield break; 
        }
        bool checkResult = true;
        if(DownloadCompleteFunc != null)
          checkResult = DownloadCompleteFunc.Invoke(req);
        
        if(checkResult)
            HandleDownload(url, req.downloadHandler);
        else
            HandleDownload(url, null, false);

        req.Dispose();

        DownloadEnd(url);
    }

    //下载错误、下载结束都清掉这个url任务
    private static void DownloadEnd(string url) {
        m_taskCallBack.Remove(url);
        m_curDownloadTask.Remove(url);
        CastTask(null);
    }

    //处理下载handle
    private static void HandleDownload(string url, DownloadHandler handle, bool result = true) {

        TempCache cacheHandle = new TempCache();//执行完callBack就会销毁
        // cacheHandle.data = handle.data;
        // cacheHandle.text = handle.text;
        cacheHandle.url = url;
        cacheHandle.success = result;
        // Debug.LogError($"handle.data {handle.data.Length}--- handle.text{ handle.text}---url{url}");
        
        // if(!m_cacheDownload.ContainsKey(url))
        //     m_cacheDownload.Add(url,cacheHandle);
        
        TaskInfo taskInfo = null;
        if (m_taskCallBack.TryGetValue(url, out taskInfo)) 
        {
            taskInfo.DownloadEnd(cacheHandle);
            m_taskCallBack.Remove(url);
        }
        // cacheHandle.tex = null;
        cacheHandle = null;
    }
    
    //移除某个链接下载
    public static void RemoveHandle(string url) 
    {
        m_taskCallBack.Remove(url);
        if (m_waitDownloadTask.Contains(url))
            m_waitDownloadTask.Remove(url);
    }
    
    //移除单个下载任务
    public static void RemoveHandle(string url, Action<TempCache> callBack) 
    {
        TaskInfo taskInfo = null;
        if (m_taskCallBack.TryGetValue(url, out taskInfo)) {
            taskInfo.RemoveCallBack(callBack);

            if (taskInfo.Count() == 0) {
                m_taskCallBack.Remove(url);
            }
        }
    }

    #region 贴图下载封装
    private class TextureTaskInfo 
    {
        private List<Action<bool, string>> m_callBacks = new List<Action<bool, string>>();
        
        public void AddCallBack(Action<bool, string> callBack) 
        {
            if (!m_callBacks.Contains(callBack)) {
                m_callBacks.Add(callBack);
            }
        }
        
        public void RemoveCallBack(Action<bool, string> callBack) {
            if (m_callBacks.Contains(callBack)) {
                m_callBacks.Remove(callBack);
            }
        }

        public void ClearCallBack() {
            m_callBacks.Clear();
        }

        public int Count() {
            return m_callBacks.Count;
        }

        public void DownloadEnd(TempCache cache) {
            for (int i = 0; i < m_callBacks.Count; i++) {
                m_callBacks[i](cache.success, cache.url);
            }
            ClearCallBack();
        }
    }
    
    private static Dictionary<string, TextureTaskInfo> m_texCallBack = 
        new Dictionary<string, TextureTaskInfo>();//下载回调缓存
    
    //下载贴图
    public static void DownloadTexture(string url, Action<bool, string> callBack, string localPath) {
        TextureTaskInfo texCallBack = null;
        if (!m_texCallBack.TryGetValue(url, out texCallBack)) {
            texCallBack = new TextureTaskInfo();
            m_texCallBack.Add(url, texCallBack);
        }

        texCallBack.AddCallBack(callBack);
        
        Download(url, (cacheHandle) => 
        {
            TextureTaskInfo finalCallBack = null;
            if (!m_texCallBack.TryGetValue(cacheHandle.url, out finalCallBack)) {
                return;
            }
            
            finalCallBack.DownloadEnd(cacheHandle);
            m_texCallBack.Remove(cacheHandle.url);
        }, new DownloadHandlerFile(localPath));
    }

    public static void RemoveTexTask(string url, Action<bool, string> callBack) {
        TextureTaskInfo callBackList = null;
        if (m_texCallBack.TryGetValue(url, out callBackList)) {
            callBackList.RemoveCallBack(callBack);
            if (callBackList.Count() == 0) {
                m_texCallBack.Remove(url);
            }
        }
    }
    
    public static void RemoveTexTask(string url) {
        m_texCallBack.Remove(url);
    }

    #endregion
}
}