using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using UnityEngine;
using XDownloadSystem;

namespace X3Game.Download
{
    public static class DownloadUtils
    {
        public static long GetFileLength(string filePath)
        {
            if (File.Exists(filePath) == false)
                return 0;

            FileInfo info = new FileInfo(filePath);
            return info.Length;
        }

        public static bool FileIsWhole(string filePath, HashCheckParameter hashCheck, long fileSize)
        {
            switch (hashCheck.HashType)
            {
                case HashType.MD5:
                    return FileIsWholeByMD5(filePath, hashCheck.Hashstring, fileSize);
                case HashType.Crc32:
                    return FileIsWholeByCrc32(filePath, hashCheck.HashNumber, fileSize);
            }

            return false;
        }

        public static bool CheckFile(string filePath, HashCheckParameter hashCheck)
        {
            switch (hashCheck.HashType)
            {
                case HashType.MD5:
                    return CheckFileMD5(filePath, hashCheck.Hashstring);
                case HashType.Crc32:
                    return CheckFileCrc32(filePath, hashCheck.HashNumber);
            }

            return true;
        }

        #region MD5

        public static bool FileIsWholeByMD5(string filePath, string checkMD5, long fileSize)
        {
            if (string.IsNullOrEmpty(filePath) || string.IsNullOrEmpty(checkMD5))
                return false;

            if (File.Exists(filePath) == false)
                return false;

            var fileInfo = new FileInfo(filePath);
            if (fileSize > 0 && fileInfo.Length != fileSize)
                return false;

            var md5 = GetFileMD5(filePath);
            return md5.Equals(checkMD5, StringComparison.CurrentCultureIgnoreCase);
        }


        public static bool CheckFileMD5(string filePath, string checkMD5)
        {
            //如果没有需要检查的md5，那么默认成功
            if (string.IsNullOrEmpty(checkMD5))
                return true;

            var srcMD5 = GetFileMD5(filePath);
            if (srcMD5 == null)
                return false;
            return srcMD5.Equals(checkMD5, StringComparison.OrdinalIgnoreCase);
        }

        public static string GetFileMD5(string filePath)
        {
            if (File.Exists(filePath) == false)
                return null;

            try
            {
                using (MD5 md5 = MD5.Create())
                {
                    using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Write))
                    {
                        var datas = md5.ComputeHash(stream);
                        StringBuilder sBuilder = new StringBuilder();
                        for (int i = 0; i < datas.Length; i++)
                        {
                            sBuilder.Append(datas[i].ToString("x2"));
                        }

                        return sBuilder.ToString();
                    }
                }
            }
            catch (Exception e)
            {
                XLog.LogException(e);
                return null;
            }
        }

        public static string GetStringMD5(string content)
        {
            if (string.IsNullOrEmpty(content))
                return null;

            try
            {
                var datas = Encoding.UTF8.GetBytes(content);
                using (MD5 md5 = MD5.Create())
                {
                    var hash = md5.ComputeHash(datas);
                    StringBuilder sBuilder = new StringBuilder();
                    for (int i = 0; i < hash.Length; i++)
                    {
                        sBuilder.Append(hash[i].ToString("x2"));
                    }

                    return sBuilder.ToString();
                }
            }
            catch (Exception e)
            {
                Debug.LogException(e);
                return null;
            }
        }

        #endregion

        #region Crc32

        public static bool FileIsWholeByCrc32(string filePath, uint checkCrc32, long fileSize)
        {
            if (string.IsNullOrEmpty(filePath) || checkCrc32 == 0)
                return false;

            if (File.Exists(filePath) == false)
                return false;

            var fileInfo = new FileInfo(filePath);
            if (fileSize > 0 && fileInfo.Length != fileSize)
                return false;

            var crc32 = GetFileCrc32(filePath);
            return crc32 == checkCrc32;
        }

        public static bool CheckFileCrc32(string filePath, uint checkCrc32)
        {
            //如果没有需要检查的Crc32，那么默认成功
            if (checkCrc32 == 0)
                return true;

            var srcCrc32 = GetFileCrc32(filePath);
            if (srcCrc32 == 0)
                return false;
            return srcCrc32 == checkCrc32;
        }

        public static uint GetFileCrc32(string filePath)
        {
            if (File.Exists(filePath) == false)
                return 0;

            try
            {
                uint initialCrc = 0;
                using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read))
                {
                    byte[] array = new byte[4096];
                    int readSize;
                    do
                    {
                        readSize = stream.Read(array, 0, 4096);
                        if (readSize > 0)
                        {
                            initialCrc = Crc32Helper.Append(initialCrc, array, 0, readSize);
                        }
                    } while (readSize > 0);

                    //return initialCrc.ToString("x2");
                }
                return initialCrc;
            }
            catch (Exception e)
            {
                XLog.LogException(e);
                return 0;
            }
        }

        #endregion


        public static bool Move(string srcFilePath, string descFilePath, bool deleteSrcFile = true)
        {
            if (string.IsNullOrEmpty(srcFilePath) || string.IsNullOrEmpty(descFilePath))
            {
                XLog.LogError(
                    $"move file error, parameters has null or empty, srcFilePath:{srcFilePath}, descFilePath:{descFilePath}");
                return false;
            }

            if (File.Exists(srcFilePath) == false)
            {
                XLog.LogError($"move file error, {srcFilePath} is not exist");
                return false;
            }

            try
            {
                if (File.Exists(descFilePath))
                {
                    File.Delete(descFilePath);
                }
                else
                {
                    var dir = Path.GetDirectoryName(descFilePath);
                    if (Directory.Exists(dir) == false)
                        Directory.CreateDirectory(dir);
                }

                File.Copy(srcFilePath, descFilePath);

                if (deleteSrcFile)
                    File.Delete(srcFilePath);

                return true;
            }
            catch (Exception e)
            {
                XLog.LogException(e);
                return false;
            }
        }

        public static bool DeleteFile(string filePath)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                XLog.LogError($"delete file error, parameters has null or empty, filePath:{filePath}");
                return false;
            }

            try
            {
                if (File.Exists(filePath))
                    File.Delete(filePath);

                return true;
            }
            catch (Exception e)
            {
                XLog.LogException(e);
                return false;
            }
        }

        public static void FormatBytes(long size, out float number, out string unit)
        {
            number = 0;
            unit = "b";
            if (size < 1024)
            {
                number = size;
                unit = "B";
            }
            else if (size < 1048576) // 1024 * 1024
            {
                number = size / 1024.0f;
                unit = "KB";
            }
            else if (size < 1073741824) // 1024 * 1024 * 1024
            {
                number = size / 1048576.0f;
                unit = "MB";
            }
            else
            {
                number = size / 1073741824.0f;
                unit = "G";
            }
        }

        /// <summary>
        /// 获取文件已经下载的大小，已经下载好的文件，size=文件大小，断线续传的是已经下载的部分的大小，
        /// 由于检查文件的完整性是比较耗时的操作，所以可以设置moveFileWhenIsWhole为true来避免额外的检查移动开销。
        /// </summary>
        /// <param name="parameter"></param>
        /// <param name="downloadedSize"></param>
        /// <param name="moveFileWhenIsWhole"></param>
        /// <returns>是否操作成功</returns>
        public static bool GetDownloadedSize(DownloadParameter parameter, out long downloadedSize,
            bool moveFileWhenIsWhole = false)
        {
            downloadedSize = 0;
            try
            {
                //如果目标地址的文件是完整的，那么不需要下载
                if (DownloadUtils.FileIsWhole(parameter.SavedPath, parameter.HashCheck, parameter.FileSize) == false)
                {
                    //如果缓存地址的文件是完整的，也认为不需要下载，只是一个拷贝
                    if (DownloadUtils.FileIsWhole(parameter.TempSavedPath, parameter.HashCheck, parameter.FileSize) ==
                        false)
                    {
                        //如果都不是完整的，那么获取缓存文件的信息，获取已经下载的大小
                        if (File.Exists(parameter.TempSavedPath))
                        {
                            var fileInfo = new FileInfo(parameter.TempSavedPath);
                            downloadedSize = fileInfo.Length;
                        }
                        else
                        {
                            downloadedSize = 0;
                        }
                    }
                    else
                    {
                        if (moveFileWhenIsWhole)
                            DownloadUtils.Move(parameter.TempSavedPath, parameter.SavedPath);
                        downloadedSize = parameter.FileSize;
                    }
                }
                else
                {
                    downloadedSize = parameter.FileSize;
                }
            }
            catch (Exception e)
            {
                XLog.LogRed($"exception {e.Message}");
                return false;
            }

            return true;
        }

        #region Disk

        /// <summary>
        /// 获取磁盘的剩余容量
        /// </summary>
        /// <returns>剩余容量，单位MB.</returns>
        public static int GetDiskFreeSpace()
        {
            return SimpleDiskUtils.DiskUtils.CheckAvailableSpace();
        }

        /// <summary>
        /// 检查磁盘的剩余容量是否足够
        /// </summary>
        /// <param name="checkSpace">检查容量，单位MB</param>
        /// <returns></returns>
        public static bool CheckDiskFreeSpaceWithMB(int checkMBSize)
        {
            return GetDiskFreeSpace() > checkMBSize;
        }

        public static bool CheckDiskFreeSpaceWithByte(long checkBytesSize)
        {
            //convert byte to mb
            return GetDiskFreeSpace() > (checkBytesSize / 1048576);
        }

        #endregion
    }
}