using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using PapeGames.X3;
using UnityEngine;

namespace X3Game.AILab
{
    public class AIFaceBridge : Singleton<AIFaceBridge>
    {
#if UNITY_STANDALONE_WIN
        private const string AILABNAME = "AILab.dll";
#elif UNITY_IOS
        private const string AILABNAME = "__Internal";
#elif UNITY_ANDROID
        private const string AILABNAME = "ailab";
#elif UNITY_STANDALONE_OSX
        private const string AILABNAME = "ailab";
#endif
        protected override void Init()
        {
           
        }

        protected override void UnInit()
        {
            if (m_aiface != 0)
            {
                ReleaseAIFace(m_aiface);
                m_aiface = 0;
            }
        }

        //------------资产的文件路径------------
        private string m_cfgFolderName = "makeup_cfg.json";
        private string m_dataFolderName = "data";


        //---------------模型路径-----------------------
        private ulong m_aiface;
        StreamReader m_streamReader;

        // -------------------创造网络------------------
        private void CreateNet()
        {
            //----------捏脸创造网络---------------------

            var modelPath = Path.Combine(AILabHelper.RootPath, AILabHelper.FolderPath, AILabHelper.ModelPath);
            var dataPath = Path.Combine(AILabHelper.RootPath, AILabHelper.FolderPath, m_dataFolderName);

            if (!Directory.Exists(modelPath))
            {
                X3Debug.LogFatal($"AI模型文件夹不存在：{modelPath}");
                return;
            }
            
            if (!Directory.EnumerateFileSystemEntries(modelPath).Any())
            {
                X3Debug.LogFatal($"AI模型文件夹为空：{modelPath}");
                return;
            }
            
            if (!Directory.Exists(dataPath))
            {
                X3Debug.LogFatal($"AI捏脸数据文件夹不存在：{dataPath}");
                return;
            }

            if (!Directory.EnumerateFileSystemEntries(dataPath).Any())
            {
                X3Debug.LogFatal($"AI捏脸数据文件夹为空：{dataPath}");
                return;
            }

            X3Debug.Log($"modelPath:{modelPath}");
            X3Debug.Log($"dataPath{dataPath}");
            m_aiface = CreateAIFace(modelPath, dataPath);
            X3Debug.Log("finish create");
        }

        public async void Process(Texture2D input, Texture2D beautyInput, int[] whiteIds, int[] whiteTypes, float boneWeight, Action<int, int[], int[], float[]> onComplete,  bool isCamera)
        {
            Color32Array midgroundColorArray = new Color32Array();
            Color32Array beautyColorArray = new Color32Array();
            midgroundColorArray.colors = input.GetPixels32();
            beautyColorArray.colors = beautyInput.GetPixels32();
            var width = input.width;
            var height = input.height;

            var task = await Task.Run(() => AIFaceTask(midgroundColorArray.byteArray, beautyColorArray.byteArray, whiteIds,
                whiteTypes, width, height, boneWeight, isCamera));
            onComplete?.Invoke(task.Item1, task.Item2, task.Item3, task.Item4);
        }

        async Task<(int, int[], int[], float[])> AIFaceTask(byte[] input, byte[] beautyInput, int[] whiteIds,
            int[] whiteTypes, int width, int height, float boneWeight, bool isCamera)
        {
            if (m_aiface == 0)
            {
                CreateNet();
            }
            
            var makeup_val_output = new int[12];
            var density_val_output = new int[12];
            var continuous_val_output = new float[123];
            bool ios;
            int rotate, flip;
            
            if (m_aiface == 0)
            {
                X3Debug.LogFatal("AI捏脸初始化失败");
                return (0, makeup_val_output, density_val_output, continuous_val_output);
            }

            if (!isCamera)
            {
                ios = true;
                rotate = 0;
                flip = 0;
            }
            else
            {
#if UNITY_IOS
                ios = true;
                rotate = 1;
                flip = 1;
#elif UNITY_EDITOR
                ios = false;
                rotate = 0;
                flip = 0;
#else
                ios = false;
                rotate = -1;
                flip = -2;
#endif
            }

            int numFace = GetAIFaceParm(m_aiface, input, beautyInput,
                width, height, rotate, flip, ios,
                makeup_val_output, density_val_output, continuous_val_output, whiteIds, whiteTypes,
                whiteTypes?.Length ?? 0);

            if (numFace > 0)
            {
                for (int i = 0; i < continuous_val_output.Length; i++)
                {
                    continuous_val_output[i] *= boneWeight;
                }
            }

            return (numFace, makeup_val_output, density_val_output, continuous_val_output);
        }

        public int AIFace(Texture2D inputTex, Texture2D beautyTex, int[] whiteIds,
            int[] whiteTypes,out int[] makeup_val_output,
            out int[] density_val_output, out float[] continuous_val_output)
        {
            if (m_aiface == 0)
            {
                CreateNet();
            }
            Color32Array input = new Color32Array();
            Color32Array beautyInput = new Color32Array();
            input.colors = inputTex.GetPixels32();
            beautyInput.colors = beautyTex.GetPixels32();
            var width = inputTex.width;
            var height = inputTex.height;
            
            makeup_val_output = new int[12];
            density_val_output = new int[12];
            continuous_val_output = new float[123];
            
            if (m_aiface == 0)
            {
                X3Debug.LogFatal("AI捏脸初始化失败");
                return 0;
            }

#if UNITY_IOS
            var ios = true;
            var rotate = 1;
            var flip = -2;
#elif UNITY_EDITOR
            var ios = false;
            var rotate = 0;
            var flip = 0;
#else
            var ios = false;
            var rotate = -1;
            var flip = -2;
#endif

            int numFace = GetAIFaceParm(m_aiface, input.byteArray, beautyInput.byteArray,
                width, height, rotate, flip, ios,
                makeup_val_output, density_val_output, continuous_val_output, whiteIds, whiteTypes,
                whiteTypes?.Length ?? 0);

            return numFace;
        }

        //-----------------windows上的Dll API接口，注意！！！！！！！
        // -----------------CreateAIFace (初始化捏脸接口)-------------
        // modelPath: 模型路径
        // cfgpath: makeup_cfg 文件路径
        // dataPath: data路径

        [DllImport(AILABNAME)]
        private static extern ulong CreateAIFace(string modelPath, string data_path);

        // 析构函数
        [DllImport(AILABNAME)]
        private static extern void ReleaseAIFace(ulong ptr);

        // ---------------------获取捏脸参数接口-------------------------
        // ptrAIface 模型字节
        // inputData: 输入的图像数据，这里是字节流 Color32Array byteArray
        // width: 输入图像的宽
        // height： 输入图像的高
        // rotateIndex: 旋转参数，请默认0
        // flipIndex：反转参数，请默认 0
        // iosCoordinate: 是否是IOS设备标志，默认False
        // makeup_val_output: 妆容参数，数量11个,输出的标志如此排列，["eyeId","eyebrowId","eyeLinerId","eyeShadowId","skinId","blushId","decorateId","eyelashId","hairId","lip_id","lip_overrideGlossId"]
        // continuous_val_output: 面补连续参数，122个
        // template_id_output: 风格脸id，请默认[]
        // template_val_output:风格脸参数，请默认[]

        [DllImport(AILABNAME)]
        private static extern int GetAIFaceParm(ulong ptrAIface, byte[] inputData, byte[] beautyInputData, int width,
            int height,
            int rotateIndex, int flipIndex, bool iosCoordinate,
            int[] makeup_val_output, int[] density_val_output, float[] continuous_val_output,
            int[] makeup_whitelist_id, int[] makeup_whitelist_type, int makeup_whitelist_len);
    }
}