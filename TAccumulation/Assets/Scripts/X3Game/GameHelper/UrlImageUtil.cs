using System.Collections.Generic;
using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.UI;
using PapeGames.X3;

namespace X3Game.GameHelper
{
    /// <summary>
    /// 避免LUA与C#反复传递参数。
    /// </summary>
    [XLua.LuaCallCSharp]
    public static class UrlImageUtil
    {
#if UNITY_EDITOR
        //触发本地加载时  biz, fullPath, 来源
        public static System.Action<Texture2D, string, string, string> LoadLocalAction;
        /// <summary>
        /// 触发删除时---bool为是否为更新
        /// </summary>
        public static System.Action<Texture2D, bool> DestroyAction;
        //触发绑定时 --tex -- go -- biz
        public static System.Action<Texture2D, Object, string> CacheAction;

#endif
        private static List<UrlImageLoading> m_LoadingCache = new List<UrlImageLoading>();
        private static List<UrlImageLoading> m_WaitRecycleList = new List<UrlImageLoading>();
        private static UnityEngine.Transform RecycleRoot; 
        private static Dictionary<UnityEngine.Object, UrlImageLoading> m_LoadingComDic = new Dictionary<Object, UrlImageLoading>();
        
        static UrlImageUtil()
        {
            if (Application.isPlaying)
            {
                RecycleRoot = new GameObject("UrlImageUtilRecycleRoot").transform;
                Object.DontDestroyOnLoad(RecycleRoot);
            }
        }

        static Dictionary<string, Texture2D> m_fileName2TexDic = new Dictionary<string, Texture2D>();
        static Dictionary<Texture2D, List<Object>> m_tex2ObjectDic = new Dictionary<Texture2D, List<Object>>();
        
        //赋值时需要记录，看下GO失效的状态
        static Dictionary<Object, Texture2D> m_go2EnableDic = new Dictionary<Object, Texture2D>();

        static List<Texture2D> m_texDelKeyList = new List<Texture2D>();
        static List<string> m_texDelKeyStringList = new List<string>();

        /// <summary>
        /// 将image组件的图赋值到另一个GO上
        /// </summary>
        /// <param name="tex"></param>
        /// <param name="go"></param>
        /// <param name="needNativeSize"></param>
        public static void SetImageWithObject(X3Image tex, Object go, bool needNativeSize = false)
        {
            UIUtility.SetImage(go, tex.sprite, needNativeSize);
        }

        /// <summary>
        /// 交换两个组件的sprite
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        public static void SwapImage(X3Image a, X3Image b)
        {
            if (a != null && b != null)
            {
                Sprite baseSprite = a.sprite;
                UIUtility.SetImage(a, b.sprite);
                UIUtility.SetImage(b, baseSprite);
            }
        }

        /// <summary>
        /// 将tex赋值到image组件上
        /// </summary>
        /// <param name="tex"></param>
        /// <param name="go"></param>
        /// <param name="needNativeSize"></param>
        public static void SetImageWithTexture(Texture2D tex, Object go, bool needNativeSize = false, bool tempBind = false)
        {
            if (tex != null && go != null)
            {
                Sprite tempSprite = TextureUtility.CreateSprite(tex);
                UIUtility.SetImage(go, tempSprite, needNativeSize);
                if (tempBind)
                {
                    ///临时做法，先解决主界面反复点击的问题，下迭代进行图片管理机制的优化 dl 12.16

                    foreach (var dicTex in m_tex2ObjectDic.Keys)
                    {
                        var goList = m_tex2ObjectDic[dicTex];
                        if (goList.Count == 1)
                        {
                            for (int i = 0; i < goList.Count; i++)
                            {
                                if (go == goList[i])
                                {
                                    m_texDelKeyList.Add(dicTex);
                                    break;
                                }
                            }
                        }
                    }
                    
                    CacheTexDic(tex, go, null, true);
                }
            }
            else
            {
                X3Debug.LogError($"SetImageWithTexture No Tex:{tex} Or Image{go}");
            }
        }

        /// <summary>
        /// 加载一个本地文件并在image组件上展现 ---确保下载的本地文件都走这里
        /// </summary>
        /// <param name="fullPath"></param>
        /// <param name="go"></param>
        public static bool SetImageWithFileName(string fileName, string fullPath, Object go, bool ignoreCache = false, string biz = null)
        {
            if (string.IsNullOrEmpty(fullPath) || go == null)
                return false;
            Texture2D tex = GetTextureFromFile(fileName, fullPath, go, ignoreCache, true, biz, true);

            if (tex != null)
            {
                SetImageWithTexture(tex, go);
                return true;
            }
            else
            {
                X3Debug.LogError($"SetImageWithFileName Error {tex} -- imageCom{go} -- file {fullPath}");
            }

            return false;
        }

        /// <summary>
        /// 通过本地路径加载一张贴图
        /// </summary>
        /// <param name="fullPath"></param>
        /// <param name="bindingObj"></param>
        /// <returns></returns>
        public static Texture2D GetTextureFromFile(string fileName, string fullPath, Object bindingObj = null,
            bool ignoreCache = false, bool linear = true, string biz = null, bool singleBind = false)
        {
            Texture2D tex = null;
            //存在缓存时
            if (!ignoreCache && m_fileName2TexDic.ContainsKey(fileName))
            {
                tex = m_fileName2TexDic[fileName];
                if (bindingObj)
                    CacheTexDic(tex, bindingObj, biz, singleBind);
                return tex;
            }

            //无视缓存或未加载过时
            if (System.IO.File.Exists(fullPath))
                tex = TextureUtility.ReadToTexture2D(fullPath, linear);

            //如果是8*8的图，认为是空图（unity显示为问号）， 2*2的图，认为是下载失败（unity显示为白色）
            if (tex != null && ((tex.width == 8 && tex.height == 8) || (tex.width == 2 && tex.height == 2)))
                tex = null;
            
            if (tex != null)
            {
                //销毁同名旧文件
                if (m_fileName2TexDic.ContainsKey(fileName))
                {
                    Texture2D oldTex = m_fileName2TexDic[fileName];
                    m_fileName2TexDic.Remove(fileName);
                    m_tex2ObjectDic.Remove(oldTex);
                    Object.Destroy(oldTex);
#if UNITY_EDITOR
                    DestroyAction?.Invoke(oldTex, true);
#endif
                }
                
#if UNITY_EDITOR
                LoadLocalAction?.Invoke(tex, biz, fullPath, "本地加载");
#endif
                m_fileName2TexDic[fileName] = tex;
                if (bindingObj)
                    CacheTexDic(tex, bindingObj, biz, singleBind);
            }

            return tex;
        }
        
        /// <summary>
        /// 检测texture是否可用
        /// </summary>
        /// <param name="tex"></param>
        /// <returns></returns>
        public static bool CheckTextureAvailable(Texture tex)
        {
            if (tex == null)
                return false;
            return !(tex.width == 8 && tex.height == 8);
        }
    

        //临时处理复制文件需求
        public static void CopyTexTemp(string fromPath, string toPath)
        {
            if(System.IO.File.Exists(fromPath))
                System.IO.File.Copy(fromPath, toPath, true);
            else
            {
                X3Debug.LogError($"CopyTexTemp Error, no from file {fromPath}");
            }
        }

        public static void UpdateTexCache(string filePath, Object bindingObj, bool linear = true)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                X3Debug.LogError($"UpdateTexCache Path error{filePath}");
                return;
            }
            string fileName = System.IO.Path.GetFileName(filePath);

            if (bindingObj == null && !m_fileName2TexDic.ContainsKey(fileName))
            {
                return;
            }


            Texture2D tex = null;
            if (System.IO.File.Exists(filePath))
            {
                tex = TextureUtility.ReadToTexture2D(filePath, linear);
                if (tex != null && (tex.width == 8 && tex.height == 8))
                {
                    tex = null;
                    X3Debug.LogError($"UpdateTexCache load error {filePath}");
                    return;
                }
            }
            else
            {
                X3Debug.LogError($"UpdateTexCache no this file {filePath}");
                return;
            }

            if (m_fileName2TexDic.ContainsKey(fileName))
            {
                Texture2D oldTex = m_fileName2TexDic[fileName];
                m_fileName2TexDic.Remove(fileName);
                List<Object> bindingList = m_tex2ObjectDic[oldTex];
                for (int i = 0; i < bindingList.Count; i++)
                {
                    SetImageWithTexture(tex, bindingList[i]);
                    CacheTexDic(tex, bindingList[i]);
                }
                m_tex2ObjectDic.Remove(oldTex);
                Object.Destroy(oldTex);
#if UNITY_EDITOR
                DestroyAction?.Invoke(oldTex, true);
#endif
            }
            m_fileName2TexDic[fileName] = tex;
            if(bindingObj != null)
                CacheTexDic(tex, bindingObj);
        }

        /// <summary>
        /// 通过大图生成缩略图并赋值到组件上
        /// </summary>
        /// <param name="baseFileName"></param>
        /// <param name="go"></param>
        public static bool SetThumbImage(string baseFilePath, string savePath, Object go, string biz = null)
        {
            if (string.IsNullOrEmpty(baseFilePath) || go == null || string.IsNullOrEmpty(savePath))
                return false;
            string baseFileName = System.IO.Path.GetFileName(baseFilePath);
            string saveName = System.IO.Path.GetFileName(savePath);

            Texture2D tex = null;
            //检测缓存或从本地加载
            if (m_fileName2TexDic.ContainsKey(saveName) || System.IO.File.Exists(savePath))
            {
                tex = GetTextureFromFile(saveName, savePath, go, false, true, biz);
                if (tex != null)
                {
                    SetImageWithTexture(tex, go);
                    return true;
                }
                else
                {
                    return false;
                }

            }
            else
            {
                //从大图加载
                tex = GetTextureFromFile(baseFileName, baseFilePath, go, false, true, biz);
                if (tex != null)
                {
                    Texture2D thumbTexture = TextureUtility.SaveTextureThumbToPNG(tex, savePath, 30);
                    m_fileName2TexDic.Add(saveName, thumbTexture);
                    CacheTexDic(thumbTexture, go, biz, true);
                    SetImageWithTexture(thumbTexture, go);
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 通过字节转换为图
        /// </summary>
        /// <param name="picBytes"></param>
        /// <param name="go"></param>
        public static void SetImageWithBytes(byte[] picBytes, Object go)
        {
            if (picBytes != null && go != null)
            {
                Sprite tempSp = TextureUtility.CreateSprite(picBytes);
                UIUtility.SetImage(go, tempSp); 
                //这里感觉也应CacheTexDic，再确认下。
            }
            else
            {
                X3Debug.LogError($"SetImageWithBytes Error {picBytes} -- {go}");
            }
        }

        /// <summary>
        /// 设置图片滤镜
        /// </summary>
        /// <param name="lutTexture"></param>
        /// <param name="x3ImageCom"></param>
        public static void SetImageFilter(Texture2D lutTexture, X3Image x3ImageCom)
        {
            if (lutTexture != null && x3ImageCom != null)
            {
                Texture2D curTex = x3ImageCom.sprite.texture;
                Texture2D newTexture = ColorGradingFilterTool.ColorGradingTexture(curTex, lutTexture);
                UIUtility.SetImage(x3ImageCom, TextureUtility.CreateSprite(newTexture));
            }
            else
            {
                X3Debug.LogError($"SetImageFilter Error {lutTexture} -- {x3ImageCom}");
            }
        }

        //当GO被重复绑定时，需要去除旧的绑定(即，普遍情况下，一个GO只能绑定一个tex，特殊情况除外（捏脸本地加载）
        public static void CheckRemoveSingleGo(Object go, Texture2D texture2D)
        {
            //假如go可用，且有绑定的tex,移除相关的绑定
            if (go != null && texture2D != null)
            {
                if (m_go2EnableDic.ContainsKey(go) && texture2D != m_go2EnableDic[go])
                {
                    var  lastBindTex = m_go2EnableDic[go];
                    if (lastBindTex != null && m_tex2ObjectDic.ContainsKey(lastBindTex))
                    {
                        //清除之前的绑定，并记录新的对应关系
                        List<Object> bindingList = m_tex2ObjectDic[lastBindTex];
                        for (int i = 0; i < bindingList.Count; i++)
                        {
                            if (bindingList[i] == go)
                            {
                                bindingList.RemoveAt(i);
                                break;
                            }
                        }
                    }
                }
                m_go2EnableDic[go] = texture2D;
            }
        }

        public static void CacheTexDic(Texture2D tex, Object go, string biz = "unknow", bool singleBind = false)
        {
            if (tex != null && go != null)
            {
                if (singleBind)
                {
                    CheckRemoveSingleGo(go, tex);
                }
                if (m_tex2ObjectDic.ContainsKey(tex))
                {
                    bool needAdd = true;
                    foreach (var cacheGo in m_tex2ObjectDic[tex])
                    {
                        if (go == cacheGo)
                            needAdd = false;
                    }

                    if (needAdd)
                    {
                        // X3Debug.LogError(" success Addcache");
                        m_tex2ObjectDic[tex].Add(go);
                    }
                }
                else
                {
                    m_tex2ObjectDic.Add(tex, new List<Object>() {go});
                    // X3Debug.LogError(" success Addcache");
                }
#if UNITY_EDITOR
                CacheAction?.Invoke(tex, go, biz);
#endif
            }
        }

        public static void CheckRemoveTexDic()
        {
            foreach (var item in m_tex2ObjectDic)
            {
                if (item.Value == null || item.Value.Count == 0)
                {
                    m_texDelKeyList.Add(item.Key);
                }
                else
                {
                    bool needDel = true;
                    for (int i = 0; i < item.Value.Count; i++)
                    {
                        Object o = item.Value[i];
                        if (!(o == null || ReferenceEquals(o, null)))
                        {
                            needDel = false;
                            break;
                        }
                        else
                        {
                            if(m_go2EnableDic.ContainsKey(o))
                            {
                                m_go2EnableDic.Remove(o);
                            }
                        }
                    }

                    if (needDel)
                    {
                        m_texDelKeyList.Add(item.Key);
                    }
                }
            }

            //销毁无用的tex
            for (int i = m_texDelKeyList.Count - 1; i >= 0; i--)
            {
                Texture2D tex = m_texDelKeyList[i];
                m_tex2ObjectDic.Remove(tex);
                foreach (string tempName in m_fileName2TexDic.Keys)
                {
                    Texture2D tempTex = m_fileName2TexDic[tempName];
                    if (tempTex == tex)
                    {
                        m_texDelKeyStringList.Add(tempName);
                    }
                }

                Object.Destroy(tex);
#if UNITY_EDITOR
                DestroyAction?.Invoke(tex, false);
#endif
                // X3Debug.LogError(" success Remove");
            }

            //移除索引
            foreach (string key in m_texDelKeyStringList)
            {
                m_fileName2TexDic.Remove(key);
            }

            m_texDelKeyList.Clear();
            m_texDelKeyStringList.Clear();
        }

        public static string Test(string t)
        {
            return System.Text.RegularExpressions.Regex.Replace(t, @"\p{C}+", ""); // \p{C} 匹配所有控制字符
        }

        public static void OnLateUpdate()
        {
            CheckRemoveTexDic();
            CheckRecycle();
        }

        public static void CheckRecycle()
        {
            if (m_WaitRecycleList.Count > 0)
            {
                for (int i = m_WaitRecycleList.Count - 1; i > 0; i--)
                {
                    var com = m_WaitRecycleList[i];
                    System.Object o = com ? com.gameObject : null;
                    if (!(o == null || ReferenceEquals(o, null)))
                    {
                        m_WaitRecycleList[i].gameObject.transform.SetParent(RecycleRoot);
                    }
                    m_LoadingCache.Add(com);
                    m_WaitRecycleList.RemoveAt(i);
                }
            }
        }

        public static void AddLoadingCom(UnityEngine.Object o, string imageName)
        {
            if(o == null)
                return;
            
            if (m_LoadingComDic.ContainsKey(o))
            {
                // X3Debug.LogError("AddLoadingCom Repeat");
                return;
            }

            var go = (o is GameObject) ? o as GameObject : (o as Component).gameObject;

            UrlImageLoading com = null;
            if (m_LoadingCache.Count > 0)
            {
                int index = m_LoadingCache.Count - 1;
                com = m_LoadingCache[index];
                m_LoadingCache.RemoveAt( index);
                //保底保护下
                if(com.transform.parent && com.transform.parent != RecycleRoot)
                    com.RestoreParentImage();
            }
            else
            {
                com = new GameObject("ImageLoadingCom").AddComponent<UrlImageLoading>();
            }
            com.SetParent(go, imageName);
            m_LoadingComDic.Add(o, com);
        }
        public static void RemoveLoadingCom(UnityEngine.Object o)
        {
            if(o == null)
                return;
            
            if (m_LoadingComDic.ContainsKey(o))
            {
                var com = m_LoadingComDic[o];
                if (com != null && com.transform.parent != RecycleRoot)
                {
                    com.ReadyRecycle();
                }
            }
        }

        public static void ReadyRecycle(UrlImageLoading com, Object o = null)
        {
            m_WaitRecycleList.Add(com);
            if (o != null && m_LoadingComDic.ContainsKey(o))
            {
                m_LoadingComDic.Remove(o);
            }
        }

        public static void DownLoadTexture2D(string localFileName, string url, string localPath,
            System.Action successCb = null, System.Action failCb = null, System.Action progress = null)
        {
            WebRequestUtil.DownloadTexture(url,
                (result, s) =>
                {
                    if(result)
                        successCb?.Invoke();
                    else
                    {
                        failCb?.Invoke();
                    }

                }, localPath);
        }
    }
}