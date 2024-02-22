using System;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public class ResExtension : IResExtensionDelegate
    {
#if UNITY_EDITOR
        public static bool DebugForSubpackageEnable = false;
#endif

        public void OnExtensionInit()
        {
            
        }

        public void OnLoadTaskStart(string assetPath)
        {
        }

        public void OnLoadTaskComplete(string assetPath, float timeCosts)
        {
            
        }

        public float OnGetResLoadTime(string assetPath)
        {
            return 0;
        }

        private int m_ErrorCount = 0;

        public bool OnWillLoad(string assetPath)
        {
#if UNITY_EDITOR
            if (!DebugForSubpackageEnable)
                return true;
            if (m_AssetInPackageDict == null)
            {
                var debugAssetPath = "Library/ResourcesPacker/DebugAssetFeat.json";
                var absPath = System.IO.Path.Combine(Application.dataPath, "../", debugAssetPath);
                if (!File.Exists(absPath))
                {
                    if (m_ErrorCount < 1)
                        Debug.LogErrorFormat("Asset Debug使用的资产不存在:{0}", absPath);
                    m_ErrorCount++;
                    return true;
                }

                var jsonStr = FileUtility.ReadText(absPath);
                var asset = JsonConvert.DeserializeObject<ResSubpackageAsset>(jsonStr);
                if (asset == null)
                {
                    if (m_ErrorCount < 1)
                        Debug.LogErrorFormat("Load asset failed from path:{0}", absPath);
                    m_ErrorCount++;
                    return true;
                }

                m_AssetInPackageDict = new Dictionary<string, bool>(asset.FileList.Length);
                foreach (var p in asset.FileList)
                {
                    m_AssetInPackageDict[p.AssetPath] = true;
                }
            }

            var ret = m_AssetInPackageDict.ContainsKey(assetPath);
            if (!ret)
            {
                Debug.LogErrorFormat("如下资源不在分包内，加载失败：{0}", assetPath);
            }

            return ret;
#endif
            return true;
        }

        public void OnInstantiate(string assetPath, float timeCosts)
        {
        }

#if UNITY_EDITOR
        private Dictionary<string, bool> m_AssetInPackageDict;

        [System.Serializable]
        public class ResSubpackageAsset
        {
            public FileInfo[] FileList;

            public struct FileInfo
            {
                public string AssetPath;
            }
        }
#endif
    }
}