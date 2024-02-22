using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XAssetsManager;

namespace X3Game
{
    /// <summary>
    /// 仅在测试中使用
    /// </summary>
    [Serializable]
    public class TestMarkABfestFile
    {
        public static readonly string FILE_NAME = "SubPackageRule_MarkAB.json";
        private static string s_FILE_PATH;
        /// <summary>
        /// InjetFix那边会报错,不可直接赋值
        /// </summary>
        public static string FILE_PATH
        {
            get
            {
                if (s_FILE_PATH == null)
                {
                    s_FILE_PATH = Application.persistentDataPath + "/" + FILE_NAME;
                }

                return s_FILE_PATH;
            }
        }

        [SerializeField] private long StartTime;
        [SerializeField] private long EndTime;
        [SerializeField] private List<TestMarkABManifestInfo> ListABInfos = new List<TestMarkABManifestInfo>();

        public void Add(string abName, ResourceLoadType loadType)
        {
            foreach (var abInfo in ListABInfos)
            {
                if (abInfo.ABName == abName)
                    return;
            }

            var info = new TestMarkABManifestInfo();
            info.ABName = abName;
            info.LoadType = loadType.ToString();
            info.StartTime = DateTime.Now.TimeOfDay.ToString();
            ListABInfos.Add(info);
        }
        
        public void Clear()
        {
            StartTime = DateTime.Now.Ticks;
            ListABInfos.Clear();
        }

        public List<TestMarkABManifestInfo> GetInfos()
        {
            return ListABInfos;
        }

        public static MarkABManifestFile ReadFromFile(string filePath = null)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                filePath = FILE_PATH;
            }

            if (!File.Exists(filePath))
            {
                var file = new MarkABManifestFile();
                file.SaveToFile();
                return null;
            }

            var strJson = File.ReadAllText(filePath);
            var manifestFile = JsonUtility.FromJson<MarkABManifestFile>(strJson);
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
            EndTime = DateTime.Now.Ticks;
            var strJson = JsonUtility.ToJson(this, true);
            File.WriteAllText(filePath, strJson);
            Debug.Log("write MarkABManifestFile successfully, path : " + filePath);
        }
 
        [Serializable]
        public class TestMarkABManifestInfo
        {
            public string ABName;
            public string LoadType;
            public string StartTime;
            public long EndTime;

            public List<string> AssetPaths;
        }
    }
}