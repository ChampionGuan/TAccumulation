using System;
using System.IO;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Video;
using X3Game.Download;

namespace X3Game.GameHelper
{
    [XLua.LuaCallCSharp]
    public class VideoHelper
    {
        private static int s_DefaultTag = 1;

        public const string VIDEO_CRC32_TAG = "_crc";

        public const string VIDEO_FILE_LENGTH = "_length";

        public const string VideoPath = "Video";

        /// <summary>
        /// 解密视频
        /// </summary>
        /// <param name="videoName">video的名字</param>
        /// <param name="tag">标识</param>
        /// <param name="onProgress">进度回调</param>
        /// <param name="onComplete">结束回调</param>
        /// <param name="videoFolderPath">视频文件夹相对路径</param>
        public static void DecryptVideo(string videoName, int tag, Action<float, int> onProgress,
            Action<int, int> onComplete, string videoFolderPath = null, bool isCheckExists = true)
        {
            string inPath = GetVideoInPath(videoName, videoFolderPath);
            string outPath = GetVideoOutPath(inPath);
            string directoryPath = Path.GetDirectoryName(outPath);
            if (!Directory.Exists(directoryPath))
            {
                Directory.CreateDirectory(directoryPath);
            }

            if (isCheckExists)
            {
                if (!CheckFileIsNeedEncryption(inPath, outPath))
                {
                    onProgress?.Invoke(1f, tag);
                    onComplete?.Invoke(0, tag);
                    return;
                }
            }

            NativeUtility.EncryptionAsync(inPath, outPath, tag, onProgress, onComplete);
        }

        /// <summary>
        /// 获取视频解密后放置的路径
        /// </summary>
        /// <param name="inPath">加密文件的路径</param>
        /// <returns>解密后的路径</returns>
        public static string GetVideoOutPath(string inPath)
        {
            string outPath = inPath.Replace("Encryption", "Real");
            outPath = Path.ChangeExtension(outPath, ".mp4");
#if UNITY_EDITOR
            outPath = outPath.Substring(outPath.IndexOf("Video"));
            outPath = Path.Combine(Application.persistentDataPath, outPath);
#endif
            return outPath;
        }

        /// <summary>
        /// 根据视频名字获取 加密前后路径
        /// </summary>
        /// <param name="videoName">视频名字</param>
        /// <param name="videoFolderPath">视频文件的文件夹相对路径</param>
        public static string GetVideoInPath(string videoName, string videoFolderPath = null)
        {
            string videoPath = null;
#if UNITY_EDITOR
            if (string.IsNullOrEmpty(videoFolderPath))
            {
                videoFolderPath = "../Video/Encryption";
            }

            videoPath = Path.Combine(Application.dataPath, videoFolderPath, videoName);
            return Res.FindLocalePersistentDataPath(videoPath, (int)Res.PathPrefixTag.Video);
#else
            if (string.IsNullOrEmpty(videoFolderPath))
            {
                videoFolderPath = "Video/Encryption";
               
            }
            videoPath = Path.Combine(Application.persistentDataPath,videoFolderPath,videoName); 
            return Res.FindLocalePersistentDataPath(videoPath,(int)Res.PathPrefixTag.Video);
#endif
        }

        /// <summary>
        /// 根据视频名称获取输出路径 
        /// </summary>
        /// <param name="videoName">视频名称</param>
        /// <returns>绝对路径 </returns>
        public static string GetVideoOutPathByVideoName(string videoName)
        {
            string intPath = GetVideoInPath(videoName);
            return GetVideoOutPath(intPath);
        }

        /// <summary>
        /// 根据视频名称获取视频文件路径
        /// </summary>
        /// <param name="videoName">视频名称</param>
        /// <returns>绝对路径</returns>
        public static string GetVideoPathByVideoName(string videoName, string videoFolderPath = null)
        {
            string videoPath = null;
#if UNITY_EDITOR
            if (string.IsNullOrEmpty(videoFolderPath))
            {
                videoFolderPath = "../Video/Real";
            }

            videoPath = Path.Combine(Application.dataPath, videoFolderPath, videoName);
            videoPath = Path.ChangeExtension(videoPath, ".mp4");
            return Res.FindLocalePersistentDataPath(videoPath, (int)Res.PathPrefixTag.Video);
#else
            if (string.IsNullOrEmpty(videoFolderPath))
            {
                videoFolderPath = "Video/Real";
               
            }
            videoPath = Path.Combine(Application.persistentDataPath,videoFolderPath,videoName); 
            videoPath = Path.ChangeExtension(videoPath, ".mp4");
            return Res.FindLocalePersistentDataPath(videoPath,(int)Res.PathPrefixTag.Video);
#endif
        }

        /// <summary>
        /// 播放视频
        /// </summary>
        /// <param name="videoName"></param>
        /// <param name="videoPlayer"></param>
        public static void PlayVideo(string videoName, VideoPlayer videoPlayer, string videoFolderPath = null,
            bool isCheckExists = true)
        {
            string inPath = GetVideoInPath(videoName, videoFolderPath);
            string outPath = GetVideoOutPath(inPath);
            string directoryPath = Path.GetDirectoryName(outPath);
            if (!Directory.Exists(directoryPath))
            {
                Directory.CreateDirectory(directoryPath);
            }

            if (isCheckExists)
            {
                if (!CheckFileIsNeedEncryption(inPath, outPath))
                {
                    videoPlayer.waitForFirstFrame = true;
                    videoPlayer.source = VideoSource.Url;
                    videoPlayer.url = outPath;
                    videoPlayer.Play();
                    return;
                }
            }

            NativeUtility.EncryptionAsync(inPath, outPath, s_DefaultTag, null, (ret, tga) =>
            {
                if (ret == 0)
                {
                    videoPlayer.waitForFirstFrame = true;
                    videoPlayer.source = VideoSource.Url;
                    videoPlayer.url = outPath;
                    videoPlayer.Play();
                }
            });
        }

        /// <summary>
        /// 检测是否需要重新解密
        /// </summary>
        /// <param name="inPath"></param>
        /// <param name="outPath"></param>
        /// <returns>是否需要重新解密</returns>
        private static bool CheckFileIsNeedEncryption(string inPath, string outPath)
        {
            FileInfo outFileInfo = new FileInfo(outPath);
            FileInfo inFileInfo = new FileInfo(inPath);
            if (outFileInfo.Exists && inFileInfo.Exists)
            {
                if (CheckFile(inPath) && CheckFile(outPath))
                {
                    return false;
                }
            }

            return true;
        }

        private static bool CheckFile(string filePath)
        {
            string fileName = Path.GetFileName(filePath);
            string tempLength = PlayerPrefs.GetString(string.Concat(fileName, VIDEO_FILE_LENGTH), string.Empty);
            int tempCrc32 = PlayerPrefs.GetInt(string.Concat(fileName, VIDEO_CRC32_TAG), 0);
            long tempLongLength = 0;
            FileInfo fileInfo = new FileInfo(filePath);
            long.TryParse(tempLength, out tempLongLength);
            if (string.IsNullOrEmpty(tempLength) || tempLongLength != fileInfo.Length)
            {
                return false;
            }

            if (!DownloadUtils.CheckFileCrc32(filePath, (uint)tempCrc32))
            {
                return false;
            }

            return true;
        }

        public static void SaveFileCrc32(string filePath)
        {
            string fileName = Path.GetFileName(filePath);
            FileInfo fileInfo = new FileInfo(filePath);
            if (fileInfo.Exists)
            {
                uint crc32 = DownloadUtils.GetFileCrc32(filePath);
                PlayerPrefs.SetString(string.Concat(fileName, VideoHelper.VIDEO_FILE_LENGTH),
                    fileInfo.Length.ToString());
                PlayerPrefs.SetInt(string.Concat(fileName, VideoHelper.VIDEO_CRC32_TAG), (int)crc32);
                PlayerPrefs.Save();
            }
        }
    }
}