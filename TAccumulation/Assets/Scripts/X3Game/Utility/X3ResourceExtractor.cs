using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using PapeGames.X3;
using UnityEngine;
using X3Game;
using XZipLib;

namespace X3Game
{
    /// <summary>
    /// 资源提取器，
    /// 从StreamingAssets目录将文件释放到persistent目录，
    /// 注意：在android平台下，如果不存在aab的情况下，就从StreamingAssets目录提取，如果存在aab的情况下，默认从第一个split apk中提取
    /// </summary>
    public static class X3ResourceExtractor
    {
        private struct ExtractFile : IEquatable<ExtractFile>
        {
            /// <summary>
            /// 相对路径
            /// </summary>
            public string RelativePath;
            /// <summary>
            /// 在apk中时为apk中的相对路径，在其他文件系统中为全路径
            /// </summary>
            public string PathInContainer;
            /// <summary>
            /// 在apk中是为apk的路径，在其他文件系统中为文件夹路径
            /// </summary>
            public string ContainerFolder;

            public bool Equals(ExtractFile other)
            {
                return RelativePath == other.RelativePath;
            }

            public override bool Equals(object obj)
            {
                return obj is ExtractFile other && Equals(other);
            }

            public override int GetHashCode()
            {
                return HashCode.Combine(RelativePath);
            }
        }
        
        /// <summary>
        /// 记录提取版本号，用来快速对比是否需要提取
        /// </summary>
        private const string s_versionFileName = "app_extract.ver";


        /// <summary>
        /// 检查版本是否匹配，如果不匹配，默认全量提取，如果匹配，需要检查文件是否都存在
        /// </summary>
        /// <returns></returns>
        private static bool CheckVersion(string persistentDataPath)
        {
            //如果版本文件不存在，直接释放文件
            var versionFilePath = Path.Combine(persistentDataPath, s_versionFileName);
            if (File.Exists(versionFilePath) == false)
                return true;

            try
            {
                //读取老版本号失败，只需要释放缺失文件
                var recordVersion = File.ReadAllText(versionFilePath);
                if (Version.TryParse(recordVersion, out var oldVersion) == false)
                    return false;
                //读取新版本号失败，只需要释放缺失文件
                var resVersion = AppInfoMgr.Instance.AppInfo.ResVer;
                if (Version.TryParse(resVersion, out var newVersion) == false)
                    return false;
                //如果包内版本号大于本地版本号，直接释放
                //其他情况只需要释放缺失文件
                return newVersion > oldVersion;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        private static void WriteVersion(string persistentDataPath)
        {
            var versionFilePath = Path.Combine(persistentDataPath, s_versionFileName);
            var resVersion = AppInfoMgr.Instance.AppInfo.ResVer;
            File.WriteAllText(versionFilePath, resVersion);
        }

    #if UNITY_ANDROID && !UNITY_EDITOR
        /// <summary>
        /// aab配置，如果存在这个文件，表示是aab模式，需要从aab中提取。
        /// !!!  注意：这个需要和XResVirtualFileSystem.AABSplitConfig.FileName 同步 !!!
        /// </summary>
        [Serializable]
        internal class AABSplitConfig
        {
            public const string FileName = "aab_split_configs.json";
            public List<string> SplitNames;
        }


        /// <summary>
        /// 读取aab的配置信息
        /// </summary>
        /// <returns></returns>
        private static AABSplitConfig ReadAABSplitConfig(string tempPath, string dataPath)
        {
            var tempSavePath = Path.Combine(tempPath, AABSplitConfig.FileName);
            if (File.Exists(tempSavePath))
                File.Delete(tempSavePath);
            //extract aab split config file to temp file
            var aabSplitConfigPath = $"assets/{AABSplitConfig.FileName}";
            using (XZip zip = new XZip(dataPath, XZip.Mode.Open))
            {
                if (zip.ExtractFile(aabSplitConfigPath, tempSavePath) == false)
                {
                    if (File.Exists(tempSavePath))
                        File.Delete(tempSavePath); 
                }
            }
                
            if (File.Exists(tempSavePath))
            {
                LogProxy.Log("get aab split config");
                var json = File.ReadAllText(tempSavePath);
                File.Delete(tempSavePath);
                    
                var config = JsonUtility.FromJson<AABSplitConfig>(json);
                return config;
            }
                
            return null;
        }

        /// <summary>
        /// 获取apk中对应文件信息
        /// </summary>
        /// <param name="appDataPath"></param>
        /// <param name="tempPath"></param>
        /// <param name="folders"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        private static HashSet<ExtractFile> GetAPKFiles(string appDataPath, string tempPath, List<string> folders)
        {
            HashSet<ExtractFile> validFiles = new HashSet<ExtractFile>();
            if (folders == null || folders.Count <= 0)
                return validFiles;
            
            const string assetsPrefix = "assets/";
            //获取apk中目录中的文件
            void CheckFilesInAPK(string apkPath)
            {
                LogProxy.Log($"CheckFilesInAPK, apk path : {apkPath}");
                using (XZip zip = new XZip(apkPath, XZip.Mode.Open))
                {
                    var prefixLength = assetsPrefix.Length;
                    string[] prefix = new string[folders.Count];
                    //根据folder创建前缀过滤
                    for (int i = 0; i < folders.Count; i++)
                    {
                        var folder = folders[i];
                        var folderInAPK = $"{assetsPrefix}{folder}/";
                        /*  在android打包apk中文件夹没有记录在里面，没法提前判断
                        if (zip.CheckDirectoryExist(folderInAPK) == false)
                        {
                            throw new Exception($"check directory exist error, {folderInAPK}");
                        }
                        */

                        prefix[i] = folderInAPK;
                    }
                
                    if (zip.GetEntitiesInfo((name, method, offset, length) =>
                        {
                            var relativeName = name.Substring(prefixLength);
                            //key为相对assets/下的路径，value为在apk下相对路径，也就是带assets/开头的路径
                            validFiles.Add(new ExtractFile()
                                { RelativePath = relativeName, PathInContainer = name, ContainerFolder = apkPath });
                        }, prefix, null))
                    {
                        LogProxy.Log($"get entities from apk successfully, {validFiles.Count}");
                    }
                    else
                    {
                        throw new Exception($"get entry info error, {apkPath}");
                    }
                }
            }
            
            CheckFilesInAPK(appDataPath);
            
            //检查是否aab模式
            var aabSplitConfig = ReadAABSplitConfig(tempPath, appDataPath);
            if (aabSplitConfig != null)
            {
                var apkInstallFolder = Path.GetDirectoryName(appDataPath);
                var splitName = aabSplitConfig.SplitNames[0];
                var apkPath = Path.Combine(apkInstallFolder, $"split_{splitName}.apk");
                CheckFilesInAPK(apkPath);
            }
            
            return validFiles;
        }
    #endif

        /// <summary>
        /// 获取对应目录的文件清单
        /// </summary>
        /// <param name="parentFolder"></param>
        /// <param name="folders"></param>
        /// <param name="mustExist"></param>
        /// <returns></returns>
        /// <exception cref="DirectoryNotFoundException"></exception>
        /// <exception cref="FileNotFoundException"></exception>
        private static HashSet<ExtractFile> GetFiles(string parentFolder, List<string> folders,
            bool mustExist)
        {
            var fileContainer = parentFolder;
    #if UNITY_EDITOR_WIN || UNITY_STANDALONE_WIN
            fileContainer = fileContainer.Replace("\\", "/");
    #endif
            if (fileContainer[fileContainer.Length - 1] != '/')
                fileContainer = parentFolder + "/";
            HashSet<ExtractFile> validFiles = new HashSet<ExtractFile>();
            //1. 遍历文件夹中文件
            if (folders != null && folders.Count > 0)
            {
                foreach (var folder in folders)
                {
                    var folderDir = Path.Combine(fileContainer, folder);
                    if (Directory.Exists(folderDir) == false)
                    {
                        if (mustExist)
                            throw new DirectoryNotFoundException(folder);

                        continue;
                    }

                    var filesInFolder = Directory.GetFiles(folderDir, "*.*", SearchOption.AllDirectories);
                    if (filesInFolder.Length <= 0)
                        continue;
                    foreach (var file in filesInFolder)
                    {
                        var relativePath = file.Replace(fileContainer, "");
    #if UNITY_EDITOR_WIN || UNITY_STANDALONE_WIN
                        relativePath = relativePath.Replace("\\", "/");
    #endif
                        validFiles.Add(new ExtractFile()
                            { RelativePath = relativePath, PathInContainer = file, ContainerFolder = folderDir });
                    }
                }
            }

            LogProxy.Log($"get files from {parentFolder}, count : {validFiles.Count}");
            return validFiles;
        }


        /// <summary>
        /// 查找丢失的文件，也就是在StreamingAssets目录下存在，但是不在persistent目录中
        /// </summary>
        /// <param name="streamingAssetsPath"></param>
        /// <param name="folders"></param>
        /// <param name="appDataPath"></param>
        /// <param name="tempPath"></param>
        /// <param name="persistentDataPath"></param>
        /// <returns>key为相对路径，value为绝对路径</returns>
        private static HashSet<ExtractFile> FindMissingFiles(string appDataPath, string tempPath, 
            string persistentDataPath, string streamingAssetsPath, List<string> folders)
        {
            //1. 先获取StreamingAssets目录下的文件
    #if UNITY_ANDROID && !UNITY_EDITOR
            var preExtractedFiles = GetAPKFiles(appDataPath, tempPath, folders);
    #else
            var preExtractedFiles = GetFiles(streamingAssetsPath, folders, true);
    #endif
            if (preExtractedFiles == null || preExtractedFiles.Count <= 0)
            {
                LogProxy.Log("no pre extracted files");
                return null;
            }

            //2. 获取persistent目录下的文件
            var filesInPersistentFolder = GetFiles(persistentDataPath, folders, false);
            if (filesInPersistentFolder == null)
            {
                LogProxy.Log("no files in persistent folder, use pre extracted files");
                return preExtractedFiles;
            }

            //3. 获取丢失的文件
            foreach (var file in filesInPersistentFolder)
            {
                preExtractedFiles.Remove(file);
            }

            LogProxy.Log($"get missing files : {preExtractedFiles.Count}");
            return preExtractedFiles;
        }

    #if UNITY_ANDROID && !UNITY_EDITOR
        private static void ExtractFolderAndroid(string persistentDataPath, IEnumerable<ExtractFile> preExtractedFiles)
        {
            Dictionary<string, List<ExtractFile>> filesByAPK = new Dictionary<string, List<ExtractFile>>();
            foreach (var file in preExtractedFiles)
            {
                var apkPath = file.ContainerFolder;
                if (filesByAPK.TryGetValue(apkPath, out var files) == false)
                {
                    files = new List<ExtractFile>();
                    filesByAPK.Add(apkPath, files);
                }
                files.Add(file);
            }

            foreach (var kv in filesByAPK)
            {
                var apkPath = kv.Key;
                var files = kv.Value;
                using (XZip zip = new XZip(apkPath, XZip.Mode.Open))
                {
                    foreach (var file in files)
                    {
                        var relativePath = file.RelativePath;
                        var pathInAPK = file.PathInContainer;
                        var pathInPersistentFolder = Path.Combine(persistentDataPath, relativePath);
                        if (zip.ExtractFile(pathInAPK, pathInPersistentFolder) == false)
                        {
                            throw new Exception($"extract file error, {relativePath}");
                        }
                    }
                }
            }
        }
    #else
        private static void ExtractFolderOther(string persistentDataPath, IEnumerable<ExtractFile> preExtractedFiles)
        {
            var persistentFolder = persistentDataPath;
            foreach (var file in preExtractedFiles)
            {
                var relativePath = file.RelativePath;
                var fullPath = file.PathInContainer;
                var pathInPersistentFolder = Path.Combine(persistentFolder, relativePath);
                var dir = Path.GetDirectoryName(pathInPersistentFolder);
                if (Directory.Exists(dir) == false)
                    Directory.CreateDirectory(dir);

                File.Copy(fullPath, pathInPersistentFolder, true);
            }
        }
    #endif


        public static bool CheckHaveExtractFiles(List<string> folders)
        {
            var dataPath = Application.dataPath;
            var tempPath = Application.temporaryCachePath;
            var streamingAssets = Application.streamingAssetsPath;
            var persistentDataPath = Application.persistentDataPath;
            //1. 先检查版本是否匹配
            var extractAll = CheckVersion(persistentDataPath);
            HashSet<ExtractFile> preExtractedFiles = null;
            //2.1 版本匹配或者安全模式就直接查找缺失的文件清单
            if (extractAll == false)
            {
                LogProxy.Log("begin check missing files");
                preExtractedFiles = FindMissingFiles(dataPath, tempPath, persistentDataPath, streamingAssets, folders);
            }
            else
            {
                LogProxy.Log("version of pkg is higher, extract all files");
                //2.2 版本不匹配，需要全部释放一次
    #if UNITY_ANDROID && !UNITY_EDITOR
                preExtractedFiles = GetAPKFiles(dataPath, tempPath, folders);
    #else
                preExtractedFiles = GetFiles(streamingAssets, folders, true);
    #endif
            }

            if (preExtractedFiles == null || preExtractedFiles.Count <= 0)
            {
                LogProxy.Log("no files to extract");
                WriteVersion(persistentDataPath);
                return false;
            }

            return true;
        }

        /// <summary>
        /// 提前释放逻辑
        /// </summary>
        /// <param name="folders"></param>
        /// <param name="multiThread"></param>
        /// <returns>是否有提前释放</returns>
        public static bool ExtractFiles(List<string> folders, bool multiThread = true)
        {
            var dataPath = Application.dataPath;
            var tempPath = Application.temporaryCachePath;
            var streamingAssets = Application.streamingAssetsPath;
            var persistentDataPath = Application.persistentDataPath;

            Stopwatch stopwatch = Stopwatch.StartNew();

            //1. 先检查版本是否匹配
            var extractAll = CheckVersion(persistentDataPath);
            HashSet<ExtractFile> preExtractedFiles = null;
            //2.1 版本匹配或者安全模式就直接查找缺失的文件清单
            if (extractAll == false)
            {
                preExtractedFiles = FindMissingFiles(dataPath, tempPath, persistentDataPath, streamingAssets, folders);
            }
            else
            {
                //2.2 版本不匹配，需要全部释放一次
    #if UNITY_ANDROID && !UNITY_EDITOR
                preExtractedFiles = GetAPKFiles(dataPath, tempPath, folders);
    #else
                preExtractedFiles = GetFiles(streamingAssets, folders, true);
    #endif
            }

            if (preExtractedFiles == null || preExtractedFiles.Count <= 0)
            {
                LogProxy.Log("no files to extract");
                WriteVersion(persistentDataPath);
                return false;
            }

            //3. 开始释放文件，默认4个线程释放，这里因为都是io操作，线程也不是越多越好，所以这个数字可以按照实际测试来调整
            int threadCount = 4;
            if (multiThread && preExtractedFiles.Count > threadCount)
            {
                //将任务分批
                int countPerThread = preExtractedFiles.Count / threadCount;
                List<List<ExtractFile>>
                    extractedFilesPerThread = new List<List<ExtractFile>>(threadCount);
                List<ExtractFile> tmpFiles = new List<ExtractFile>(countPerThread);
                foreach (var file in preExtractedFiles)
                {
                    if (tmpFiles.Count < countPerThread || extractedFilesPerThread.Count == threadCount - 1)
                        tmpFiles.Add(file);
                    if (tmpFiles.Count == countPerThread && extractedFilesPerThread.Count < threadCount - 1)
                    {
                        extractedFilesPerThread.Add(tmpFiles);
                        tmpFiles = new List<ExtractFile>(countPerThread);
                    }
                }

                if (tmpFiles.Count > 0)
                    extractedFilesPerThread.Add(tmpFiles);
                Task[] tasks = new Task[extractedFilesPerThread.Count];
                for (int i = 0; i < extractedFilesPerThread.Count; i++)
                {
                    var tmpExtractFiles = extractedFilesPerThread[i];
                    var t = Task.Run(() =>
                    {
    #if UNITY_ANDROID && !UNITY_EDITOR
                        ExtractFolderAndroid(persistentDataPath, tmpExtractFiles);
    #else
                        ExtractFolderOther(persistentDataPath, tmpExtractFiles);
    #endif
                    });
                    tasks[i] = t;
                }

                Task.WaitAll(tasks);
            }
            else
            {
    #if UNITY_ANDROID && !UNITY_EDITOR
                ExtractFolderAndroid(persistentDataPath, preExtractedFiles);
    #else
                ExtractFolderOther(persistentDataPath, preExtractedFiles);
    #endif
            }

            WriteVersion(persistentDataPath);

            stopwatch.Stop();

            LogProxy.Log($"ExtractFiles finished, cost time : {stopwatch.ElapsedMilliseconds} ms");
            return true;
        }
    }
}