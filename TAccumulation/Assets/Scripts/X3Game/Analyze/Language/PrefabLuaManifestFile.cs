using System;
using System.Collections.Generic;
using System.IO;
using ICSharpCode.SharpZipLib.Core;
using UnityEngine;

namespace X3Game
{
    [Serializable]
    public class PrefabLuaManifestFile
    {
        public static readonly string FILE_NAME = "Language_PrefabLua.json";
        public static readonly string FILE_PATH = Application.dataPath + "/../../../P4Ignore/" + FILE_NAME;

        [SerializeField] private List<PrefabLuaManifestInfo> PrefabLuaInfos = new List<PrefabLuaManifestInfo>();

        //索引
        private static Dictionary<string, PrefabLuaManifestInfo> m_PrefabLuaInfoDict =
            new Dictionary<string, PrefabLuaManifestInfo>();

        private string m_BranchName;

        public void Add(string branchName, string prefabName, string luaPath)
        {
            if (!string.IsNullOrEmpty(branchName) && m_BranchName != branchName)
            {
                m_BranchName = branchName;
            }
            foreach (var abInfo in PrefabLuaInfos)
            {
                if (abInfo.PrefabName == prefabName)
                {
                    if (!abInfo.LuaPaths.Contains(luaPath))
                    {
                        abInfo.LuaPaths.Add(luaPath);
                    }

                    return;
                }
            }

            var info = new PrefabLuaManifestInfo();
            info.PrefabName = prefabName;
            info.LuaPaths = new List<string>();
            info.LuaPaths.Add(luaPath);
            PrefabLuaInfos.Add(info);
        }

        public void Clear()
        {
            PrefabLuaInfos.Clear();
        }

        public string GetRedisName(string branchName)
        {
            return "Language_PrefabLua_" + branchName;
        }
 
        public bool TryGetLuaPaths(string prefabName, out List<string> luaPaths)
        {
            if (m_PrefabLuaInfoDict.TryGetValue(prefabName, out PrefabLuaManifestInfo info))
            {
                luaPaths = info.LuaPaths;
                return true;
            }

            luaPaths = null;
            return false;
        }

        public List<PrefabLuaManifestInfo> GetInfos()
        {
            return PrefabLuaInfos;
        }

        public static PrefabLuaManifestFile ReadFromFile(string filePath = null)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                filePath = FILE_PATH;
            }

            if (!File.Exists(filePath))
            {
                Debug.LogError("PrefabLuaManifestFile not exist, path:" + filePath);
                return null;
            }

            var strJson = File.ReadAllText(filePath);
            var manifestFile = JsonUtility.FromJson<PrefabLuaManifestFile>(strJson);
            //便于查询
            m_PrefabLuaInfoDict.Clear();
            foreach (var prefabLuaInfo in manifestFile.PrefabLuaInfos)
            {
                List<string> fixLuaPaths = new List<string>();
                foreach (var luaPath in prefabLuaInfo.LuaPaths)
                {
                    var fixLuaPath = luaPath.Replace(".", "\\");
                    fixLuaPath = fixLuaPath.Replace("Runtime", "");
                    fixLuaPaths.Add(fixLuaPath);
                }

                var info = new PrefabLuaManifestInfo();
                info.LuaPaths = fixLuaPaths;
                info.PrefabName = prefabLuaInfo.PrefabName;
                m_PrefabLuaInfoDict[prefabLuaInfo.PrefabName] = info;
            }

            return manifestFile;
        }

        public void SaveToFile(string filePath = null)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                filePath = FILE_PATH;
            }

            var directory = Path.GetDirectoryName(filePath);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }
            SaveToLocal(filePath);
            //保存到redis
            SaveToRedis(m_BranchName);
        }

        public void SaveToLocal(string filePath = null)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                filePath = FILE_PATH;
            }
            var json = JsonUtility.ToJson(this,true);
            File.WriteAllText(filePath, json);
            Debug.Log("write PrefabLuaManifestFile successfully, path : " + filePath);
        }

        public void SaveToRedis(string branchName)
        {
#if DEBUG_GM
            var redisName = GetRedisName(branchName);
            var latestOne = RedisJson.GetLogOne(redisName);
            if (!string.IsNullOrEmpty(latestOne))
            {
                var json = JsonUtility.FromJson<PrefabLuaManifestFile>(latestOne);
                Merge(ref json, this);
                latestOne = JsonUtility.ToJson(json,true);
            }
            else
            {
                latestOne = JsonUtility.ToJson(this,true);
            }
            RedisJson.StoreLogOne(redisName, latestOne);
#endif
        }

        public void GetMergedFileByRedis(string branchName, ref PrefabLuaManifestFile dstJson)
        {
#if DEBUG_GM
            var redisName = GetRedisName(branchName);
            var latestOne = RedisJson.GetLogOne(redisName);
            if (!string.IsNullOrEmpty(latestOne))
            {
                var redisJson = JsonUtility.FromJson<PrefabLuaManifestFile>(latestOne);
                Merge(ref redisJson, dstJson);
                dstJson = redisJson;
                latestOne = JsonUtility.ToJson(redisJson,true);
            }
            else
            {
                latestOne = JsonUtility.ToJson(dstJson,true);
            }
            RedisJson.StoreLogOne(redisName, latestOne);
#endif
        }

        public void Merge(ref PrefabLuaManifestFile src, PrefabLuaManifestFile dst)
        {
            if (src == null || dst == null)
                return;
            var dstDict = new Dictionary<string, List<string>>(dst.PrefabLuaInfos.Count);
            foreach (var info in dst.PrefabLuaInfos)
            {
                dstDict[info.PrefabName] = info.LuaPaths;
            }

            var srcDict = new Dictionary<string, List<string>>(src.PrefabLuaInfos.Count);
            foreach (var info in src.PrefabLuaInfos)
            {
                srcDict[info.PrefabName] = info.LuaPaths;
            }

            //更新src
            foreach (var srcInfo in src.PrefabLuaInfos)
            {
                if (dstDict.TryGetValue(srcInfo.PrefabName, out List<string> luaPaths))
                {
                    foreach (var luaPath in luaPaths)
                    {
                        if (!srcInfo.LuaPaths.Contains(luaPath))
                        {
                            srcInfo.LuaPaths.Add(luaPath);
                        }
                    }
                }
            }

            //把不在src的放在src里面
            foreach (var dstInfo in dst.PrefabLuaInfos)
            {
                if (!srcDict.ContainsKey(dstInfo.PrefabName))
                {
                    src.PrefabLuaInfos.Add(dstInfo);
                }
            }
        }

        [Serializable]
        public class PrefabLuaManifestInfo
        {
            public string PrefabName;
            public List<string> LuaPaths;
        }
    }
}