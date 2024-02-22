using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Runtime.InteropServices;
using System;
using System.Threading.Tasks;
using AOT;
using PapeGames.X3;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using X3Game.Download;

namespace X3Game.GameHelper
{
    [XLua.LuaCallCSharp]
    public static class NativeUtility
    {
#if UNITY_EDITOR || UNITY_STANDALONE ||UNITY_STANDALONE_WIN
        const string dll = "x3staticDll";
#elif UNITY_IOS
    const string dll = "__Internal";
#elif UNITY_ANDROID
        const string dll = "x3static";
#endif
        public delegate void OnProgressCallBack(float progress, int tag);

        public delegate void OnCompleteCallBack(int ret, int tag);

        [DllImport(dll)]
        public static extern void StartEncryption(string inPath, string outPath, string pwd, int tag,
            OnProgressCallBack onProgress, OnCompleteCallBack onComplete);

        [DllImport(dll)]
        static extern int ReadBytes(string filePath, ref IntPtr size, out IntPtr buffer);

        /// <summary>
        /// 读取文件字节数据并返回NativeArray对象
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="allocator"></param>
        /// <returns></returns>
        public unsafe static NativeArray<byte> ReadAllBytes(string filePath, Allocator allocator = Allocator.Persistent)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                LogProxy.LogErrorFormat("NativeUtility.ReadAllBytes failed: filePath null or empty");
                return new NativeArray<byte>();
            }

            IntPtr fileSizePtr = IntPtr.Zero;
            ReadBytes(filePath, ref fileSizePtr, out IntPtr buffer);
            int fileSize = fileSizePtr.ToInt32();
            if (fileSize <= 0 || buffer == IntPtr.Zero)
            {
                LogProxy.LogErrorFormat("NativeUtility.ReadAllBytes failed: filePath={0}", filePath);
                return new NativeArray<byte>();
            }

            NativeArray<byte> ret = new NativeArray<byte>((int)fileSize, allocator);
            UnsafeUtility.MemCpy(ret.GetPtr(), buffer.ToPointer(), fileSize);
            Marshal.FreeHGlobal(buffer);

            return ret;
        }

        /// <summary>
        /// 当前在进行加密解密操作的回调
        /// </summary>
        private static Dictionary<int, EncryCallBackData> callBackMap = new Dictionary<int, EncryCallBackData>();

        private static int callBackUid = 0;

        /// <summary>
        /// 加密解密异步
        /// </summary>
        /// <param name="inPath">加密文件路径</param>
        /// <param name="outPath">加密完成路径</param>
        /// <param name="pwd">密钥</param>
        /// <param name="onProgress">进度回调</param>
        /// <param name="onComplete">完成回调</param>
        private static void ExeEncryptionAsync(string inPath, string outPath, string pwd, int tag,
            OnProgressCallBack onProgress, OnCompleteCallBack onComplete)
        {
            Task task = new Task(() =>
            {
                Debug.Log("StartEncryption" + "inPath：" + inPath + "outPath：" + outPath + "pwd：" + pwd + "tag：" + tag);
                StartEncryption(inPath, outPath, pwd, tag, onProgress, onComplete);
            });
            task.Start();
        }

        /// <summary>
        /// 加密解密同步
        /// </summary>
        /// <param name="inPath">解密文件路径</param>
        /// <param name="outPath">解密完成文件路径</param>
        /// <param name="pwd">密钥</param>
        /// <param name="onProgress">进度回调</param>
        /// <param name="onComplete">完成回调</param>
        private static void ExeEncryption(string inPath, string outPath, string pwd, int tag,
            OnProgressCallBack onProgress, OnCompleteCallBack onComplete)
        {
            StartEncryption(inPath, outPath, pwd, tag, onProgress, onComplete);
        }


        /// <summary>
        ///  进度回调
        /// </summary>
        /// <param name="progress">1 - 100</param>
        ///  <param name="tag">传入的标记
        [MonoPInvokeCallback(typeof(OnProgressCallBack))]
        static void OnProgress(float progress, int tag)
        {
            if (callBackMap.ContainsKey(tag))
            {
                Loom.QueueOnMainThread((param) => { callBackMap[tag].onProgressCallBack?.Invoke(progress, tag); },
                    null);
            }
        }

        /// <summary>
        /// 加密解密完成回调
        /// </summary>
        /// <param name="ret">0 成功  1 inPath 路径找不到   2 outPath 路径找不到</param>
        /// <param name="tag">传入的标记
        [MonoPInvokeCallback(typeof(OnCompleteCallBack))]
        static void OnComplete(int ret, int tag)
        {
            if (callBackMap.ContainsKey(tag))
            {
                Loom.QueueOnMainThread((param) =>
                {
                    if (ret == 0)
                    {
                        VideoHelper.SaveFileCrc32(callBackMap[tag].inPath);
                        VideoHelper.SaveFileCrc32(callBackMap[tag].outPath);
                    }

                    callBackMap[tag].onCompleteCallBack?.Invoke(ret, tag);
                    ClearableObjectPool<EncryCallBackData>.Release(callBackMap[tag]);
                    callBackMap.Remove(tag);
                }, null);
            }
        }

        /// <summary>
        /// 加密解密
        /// </summary>
        /// <param name="inPath">加密文件路径</param>
        /// <param name="outPath">加密完成路径</param>
        /// <param name="pwd">密钥</param>
        /// <param name="onProgress">进度回调</param>
        /// <param name="onComplete">完成回调</param>
        public static void EncryptionAsync(string inPath, string outPath, int tag, Action<float, int> onProgress,
            Action<int, int> onComplete, string pwd = null)
        {
            pwd = X3GameSettings.videoPwd;
            EncryCallBackData callBackData = ClearableObjectPool<EncryCallBackData>.Get();
            callBackData.onProgressCallBack = onProgress;
            callBackData.onCompleteCallBack = onComplete;
            callBackData.inPath = inPath;
            callBackData.outPath = outPath;
            callBackMap[tag] = callBackData;
            ExeEncryptionAsync(inPath, outPath, pwd, tag, OnProgress, OnComplete);
        }


        /// <summary>
        /// 加密解密
        /// </summary>
        /// <param name="inPath">加密文件路径</param>
        /// <param name="outPath">加密完成路径</param>
        ///  <param name="tag">标识</param>
        /// <param name="pwd">密钥</param>
        /// <param name="onProgress">进度回调</param>
        /// <param name="onComplete">完成回调</param>
        public static void Encryption(string inPath, string outPath, int tag = -1, Action<float, int> onProgress = null,
            Action<int, int> onComplete = null, string pwd = null)
        {
            pwd = X3GameSettings.videoPwd;
            if (onComplete != null || onProgress != null)
            {
                EncryCallBackData callBackData = ClearableObjectPool<EncryCallBackData>.Get();
                callBackData.onProgressCallBack = onProgress;
                callBackData.onCompleteCallBack = onComplete;
                callBackData.inPath = inPath;
                callBackData.outPath = outPath;
                callBackMap[tag] = callBackData;
            }

            ExeEncryption(inPath, outPath, pwd, tag, OnProgress, OnComplete);
        }
    }

    public class EncryCallBackData : IClearable
    {
        public Action<float, int> onProgressCallBack;
        public Action<int, int> onCompleteCallBack;
        public string inPath;
        public string outPath;

        public void Clear()
        {
            onProgressCallBack = null;
            onCompleteCallBack = null;
            inPath = null;
            outPath = null;
        }
    }
}