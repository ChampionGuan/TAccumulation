using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Runtime.InteropServices;
using System;
using System.IO;
using System.Linq;
using Framework;
using OfficeOpenXml.FormulaParsing.Excel.Functions.Logical;
using UnityEngine.Android;
using PapeGames.X3;
using Object = UnityEngine.Object;

namespace X3Game.AILab
{
    //用来储存相机图片，并且传输到naitive端
    [StructLayout(LayoutKind.Explicit)]
    public struct Color32Array
    {
        [FieldOffset(0)]
        public byte[] byteArray;

        [FieldOffset(0)]
        public Color32[] colors;
    }
    //处理AR拍照过程中人脸检测
    [XLua.LuaCallCSharp]
    public class FaceDetectTool : Singleton<FaceDetectTool>
    {
        //================== 神经网络 ================
        private int PORTRAITMNET_SIZE = 128; //这是分割模型的图片输入大小（长宽）
        private string m_FilePortrait;//这个就是辅助度分割模型的，不用理
        //用来保存模型指针
        private ulong m_pPCN;
        private ulong m_pPortraitSegmentor;
        //模型运行时cpu使用数量的设置，我们这边经过测试，pcn设置2，pcntracking设置3，seg设置3的时候两个模型在安卓机上运行速度最短。（但是实际使用下怎么配置更好由客户端决定）
        private static int s_SegNumThread = 1;
        private static int s_PcnNumThread = 1;//2
        private static int s_PcnTrackNumThread = 1;//3
        private int m_AlphaWidth, m_AlphaHeight; //c#端中来接受的alpha图的长宽
        //神经网络返回结果
        private byte[] m_ResultAlpha; //分割alpha图，0~255。0表示背景，255表示人。并不是二分类，中间是有过度的。
        private float[] m_Retpoints; //人脸包围框
        private float[] m_AugLandmarks; //返回的68个人脸关键点 （目前最终会计算成14个点存到m_landmark里面）
        private float m_Scale = 0.1f; //图片丢入native端后会先做缩放（主要是为了加速），如果缩小的太小，图片会过于不清晰而无法使用，但是如果不缩放，会影响效率。当然，如果在c#端就已经很小了，就没必要缩放太多。保证缩小后的图片在256*256左右就可以。
        private int m_MinFaceSize = 30; //人脸如果小于这个大小（长宽各m_MinFaceSize像素），就会直接被丢弃。也就是说，要求人脸必须在镜头里有至少（m_MinFaceSize*m_MinFaceSize）这么大。这个值可以供客户端设置玩家人脸最小大小的限制。如果配置的太小（比如小于30），人脸检测会变得很慢。
        private const int MAX_NUM_FACE = 1; //最多允许检测到几张脸。这个数值越大，人脸检测越慢。但是对于美颜相机，我们只允许检测一张脸。所以就是1。
        
        private Color32Array m_ColorArray; //相机数据
        private int m_WebWidth, m_WebHeight;//接收到的图片的长宽
        private bool m_HasInitSize = false;
        private float[] m_Landmarks = new float[MAX_NUM_FACE * 28];
        private Texture2D m_Alpha; //存alpha的
        public static bool s_PerformanceMode = false;
        private string m_ModelPath = Application.persistentDataPath + "/";
        //引入SDK
#if UNITY_IOS
        [DllImport("__Internal")]
        private static extern ulong createPortraitSegmentor(int input_width, int input_height, int num_thead, string modelpath);
        [DllImport("__Internal")]
        private static extern void releasePortraitSegmentor(ulong ptr);
        [DllImport("__Internal")]
        private static extern ulong createAUGPCN(string modelpath, int pcnNumThread, int pcnTrackNumThread);
        [DllImport("__Internal")]
        private static extern void releaseAUGPCN(ulong ppcn);
         [DllImport("__Internal")]
        private static extern int AUGPCNdetect(ulong ppcn, byte[] data, int width, int height,
            int rotate, int flip, int iosCoordinate,
            float scale, int minfacesize, int maxnumface, int dodetect,
            float[] repoints, float[] landmarks, string saveplace);

        [DllImport("__Internal")]
        private static extern int PCNSegment(ulong ppcn, ulong ptrSegment, long data, int width, int height,
            int rotate, int flip, int iosCoordinate,
            float scale, int minfacesize, int maxnumface, int dodetect, int dosegment2,
             float[] repoints, float[] landmarks, byte[] retalpha, string saveplace);
        [DllImport("__Internal")]
        private static extern void AUGPCNsetScaleFactor(ulong ppcn,float value);
        [DllImport("__Internal")]
        private static extern ulong createPortraitSegmentorLow(int input_width, int input_height, int num_thead, string modelpath);
        [DllImport("__Internal")]
        private static extern ulong createAUGPCNLow(string modelpath, int pcnNumThread, int pcnTrackNumThread);
#elif UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
        [DllImport("ailab")]
        private static extern ulong createPortraitSegmentor(int input_width, int input_height, int num_thead, string modelpath);
        [DllImport("ailab")]
        private static extern void releasePortraitSegmentor(ulong ptr);
        [DllImport("ailab")]
        private static extern ulong createAUGPCN(string modelpath, int pcnNumThread, int pcnTrackNumThread);
        [DllImport("ailab")]
        private static extern void releaseAUGPCN(ulong ppcn);
        [DllImport("ailab")]
        private static extern int PCNSegment(ulong ppcn, ulong ptrSegment, long data, int width, int height,
            int rotate, int flip, int iosCoordinate,
            float scale, int minfacesize, int maxnumface, int dodetect,int dosegment,
            float[] repoints, float[] landmarks, byte[] retalpha, string saveplace);
        [DllImport("ailab")]
        private static extern int AUGPCNdetect(ulong ppcn, byte[] data, int width, int height,
            int rotate, int flip, int iosCoordinate,
            float scale, int minfacesize, int maxnumface, int dodetect,
            float[] repoints, float[] landmarks, string saveplace);
        [DllImport("ailab")]
        private static extern void AUGPCNsetScaleFactor(ulong ppcn,float value);
        [DllImport("ailab")]
        private static extern ulong createPortraitSegmentorLow(int input_width, int input_height, int num_thead, string modelpath);
        [DllImport("ailab")]
        private static extern ulong createAUGPCNLow(string modelpath, int pcnNumThread, int pcnTrackNumThread);
#else
        [DllImport("ailab")]
        private static extern ulong createPortraitSegmentor(int input_width, int input_height, int num_thead, string modelpath);
        [DllImport("ailab")]
        private static extern void releasePortraitSegmentor(ulong ptr);
        [DllImport("ailab")]
        private static extern ulong createAUGPCN(string modelpath, int pcnNumThread, int pcnTrackNumThread);
        [DllImport("ailab")]
        private static extern void releaseAUGPCN(ulong ppcn);
        [DllImport("ailab")]
        private static extern int PCNSegment(ulong ppcn, ulong ptrSegment, long data, int width, int height,
            int rotate, int flip, int iosCoordinate,
            float scale, int minfacesize, int maxnumface, int dodetect, int dosegment,
             float[] repoints, float[] landmarks, byte[] retalpha, string saveplace);

        [DllImport("ailab")]
        private static extern int AUGPCNdetect(ulong ppcn, byte[] data, int width, int height,
            int rotate, int flip, int iosCoordinate,
            float scale, int minfacesize, int maxnumface, int dodetect,
            float[] repoints, float[] landmarks, string saveplace);
        [DllImport("ailab")]
        private static extern void AUGPCNsetScaleFactor(ulong ppcn,float value);
        [DllImport("ailab")]
        private static extern ulong createPortraitSegmentorLow(int input_width, int input_height, int num_thead, string modelpath);
        [DllImport("ailab")]
        private static extern ulong createAUGPCNLow(string modelpath, int pcnNumThread, int pcnTrackNumThread);
#endif
        
        protected override void Init()
        {
            m_Retpoints = new float[MAX_NUM_FACE * 8];
            m_Landmarks = new float[MAX_NUM_FACE * 28];
            m_AugLandmarks = new float[MAX_NUM_FACE * 136];
            GETAlphaWH();
            m_ResultAlpha = new byte[m_AlphaWidth * m_AlphaHeight];
            m_Alpha = new Texture2D(m_AlphaWidth, m_AlphaHeight, TextureFormat.R8, false);
            m_Alpha.wrapMode = TextureWrapMode.Clamp;
            m_Alpha.filterMode = FilterMode.Bilinear;
            createNet();
        }
        protected override void UnInit()
        {
            if (m_pPCN != 0)
            {
                releaseAUGPCN(m_pPCN);
                m_pPCN = 0;
            }
            if (m_pPortraitSegmentor != null)
                releasePortraitSegmentor(m_pPortraitSegmentor);
            m_Retpoints = null;
            m_Landmarks = null;
            m_AugLandmarks = null;
            m_ResultAlpha = null;
            Object.Destroy(m_Alpha);
            m_Alpha = null;
        }
        void GETAlphaWH()
        {
            m_AlphaHeight = PORTRAITMNET_SIZE;
            m_AlphaWidth = PORTRAITMNET_SIZE;
        }
        private void createNet()
        {
            var modelPath = Path.Combine(AILabHelper.RootPath, AILabHelper.FolderPath, AILabHelper.ModelPath);
            
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
            
            if(!s_PerformanceMode)
                m_pPCN = createAUGPCN(modelPath, s_PcnNumThread, s_PcnTrackNumThread);
            else
                m_pPCN = createAUGPCNLow(modelPath, s_PcnNumThread, s_PcnTrackNumThread);
        }
        
        public void CreatePortraitNet()
        {
            var modelPath = Path.Combine(AILabHelper.RootPath, AILabHelper.FolderPath, AILabHelper.ModelPath);
            
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
            
            if(!s_PerformanceMode)
                m_pPortraitSegmentor = createPortraitSegmentor(PORTRAITMNET_SIZE, PORTRAITMNET_SIZE, s_SegNumThread, modelPath);
            else
                m_pPortraitSegmentor = createPortraitSegmentorLow(PORTRAITMNET_SIZE, PORTRAITMNET_SIZE, s_SegNumThread, modelPath);
        }

        public static void SetThreadNum(int pcnNum, int pcnTrackNum, int segNum)
        {
            s_PcnNumThread = pcnNum;
            s_PcnTrackNumThread = pcnTrackNum;
            s_SegNumThread = segNum;
        }
        //设置模型运算参数
        public void SetScaleFactor(float rate)
        {
            if (m_pPCN == 0)
            {
                X3Debug.LogFatal("FaceDetect pPCN is not init");
                return;
            }
#if !UNITY_STANDALONE_WIN && !UNITY_EDITOR_WIN
            AUGPCNsetScaleFactor(m_pPCN, rate);
#endif
        }
        
        public float[] GetLandMarks()
        {
            Convert68to14();
            return m_Landmarks;
        }
        //获得分割模型的结果
        public Texture2D GetDetectAlpha()
        {
            PrepareAlpha();
            return m_Alpha;
        }
        public float[] GetRetPoint()
        {
            return m_Retpoints;
        }
        
        private void PrepareAlpha()
        {
            m_Alpha.LoadRawTextureData(m_ResultAlpha);
            m_Alpha.Apply();
        }

        private void Convert68to14()
        {
            //calculate the left eyes
            float leftEyeX = 0, leftEyeY = 0, rightEyeX = 0, rightEyeY = 0;
            for (int i = 36; i < 42; i++)
            {
                leftEyeX += m_AugLandmarks[2 * i + 0];
                leftEyeY += m_AugLandmarks[2 * i + 1];
            }
            leftEyeX = leftEyeX / 6.0f;
            leftEyeY = leftEyeY / 6.0f;

            //calculate the right eyes
            for (int i = 42; i < 48; i++)
            {
                rightEyeX += m_AugLandmarks[2 * i + 0];
                rightEyeY += m_AugLandmarks[2 * i + 1];
            }
            rightEyeX = rightEyeX / 6.0f;
            rightEyeY = rightEyeY / 6.0f;

            //计算脸颊的landmark
            int j = 0;
            for (int i = 0; i < 17; i = i + 2)
            {
                m_Landmarks[2 * j + 0] = m_AugLandmarks[2 * i + 0];
                m_Landmarks[2 * j + 1] = m_AugLandmarks[2 * i + 1];
                j++;
            }

            //计算鼻子
            m_Landmarks[2 * j + 0] = m_AugLandmarks[2 * 30 + 0];
            m_Landmarks[2 * j + 1] = m_AugLandmarks[2 * 30 + 1];
            j++;
            //计算左右眼睛
            m_Landmarks[2 * j + 0] = leftEyeX;
            m_Landmarks[2 * j + 1] = leftEyeY;
            j++;
            m_Landmarks[2 * j + 0] = rightEyeX;
            m_Landmarks[2 * j + 1] = rightEyeY;
            j++;

            //计算嘴巴
            m_Landmarks[2 * j + 0] = m_AugLandmarks[2 * 48 + 0];
            m_Landmarks[2 * j + 1] = m_AugLandmarks[2 * 48 + 1];
            j++;
            m_Landmarks[2 * j + 0] = m_AugLandmarks[2 * 54 + 0];
            m_Landmarks[2 * j + 1] = m_AugLandmarks[2 * 54 + 1];
        }

        

        public void SetImageSize(int width, int height, int minSize = 128, bool needArray = true)
        {
            m_HasInitSize = true;
            m_WebWidth = width;
            m_WebHeight = height;
            if (needArray)
            {
                m_ColorArray = new Color32Array();
                m_ColorArray.colors = new Color32[m_WebWidth * m_WebHeight];
            }

            m_Scale = Mathf.Min(1.0f,(float)minSize / Math.Min(m_WebWidth, m_WebHeight));
        }

        public unsafe int DoFaceDetectWithPtr(IntPtr imageColorPtr, bool doDetect)
        {
            if (!m_HasInitSize || m_pPCN == 0)
                return 0;

            //m_ColorArray.colors = imageColor;
            int numfaces = 0;

            if (m_Retpoints.Length != MAX_NUM_FACE * 8)
            {
                m_Retpoints = new float[MAX_NUM_FACE * 8];
                m_Landmarks = new float[MAX_NUM_FACE * 28];
                m_AugLandmarks = new float[MAX_NUM_FACE * 136];
            }
            
#if UNITY_EDITOR_WIN
            numfaces = PCNSegment(m_pPCN, m_pPortraitSegmentor,
                (long)imageColorPtr, m_WebWidth, m_WebHeight,
                0, 0, 0,
                m_Scale, m_MinFaceSize, MAX_NUM_FACE, Convert.ToInt32(doDetect), Convert.ToInt32(true),
                m_Retpoints, m_AugLandmarks, m_ResultAlpha, m_ModelPath);
#elif UNITY_IOS
            numfaces = PCNSegment(m_pPCN, m_pPortraitSegmentor,
                imageColorPtr.ToInt64(), m_WebWidth, m_WebHeight,
                1, 1, 0,
                m_Scale, m_MinFaceSize, MAX_NUM_FACE, Convert.ToInt32(doDetect), Convert.ToInt32(true),
                m_Retpoints, m_AugLandmarks, m_ResultAlpha, m_ModelPath);
#elif UNITY_ANDROID
            numfaces = PCNSegment(m_pPCN, m_pPortraitSegmentor,
                (long)imageColorPtr, m_WebWidth, m_WebHeight,
                -1, -2, 0,
                m_Scale, m_MinFaceSize, MAX_NUM_FACE, Convert.ToInt32(doDetect), Convert.ToInt32(true),
                m_Retpoints, m_AugLandmarks, m_ResultAlpha, m_ModelPath);
#endif
            return numfaces;
        }

        public unsafe int DoFaceDetect(Color32[] imageColor, bool doDetect, int overrideMaxFace = -1, bool isCamera = true)
        {
            if (!m_HasInitSize)
                return 0;
            
            m_ColorArray.colors = imageColor;
            int numfaces = 0;
            
            bool ios;
            int rotate, flip;

            if (!isCamera)
            {
                ios = false;
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

            var maxFaceNum = overrideMaxFace == -1 ? MAX_NUM_FACE : overrideMaxFace;
            if (m_Retpoints.Length != maxFaceNum * 8)
            {
                m_Retpoints = new float[maxFaceNum * 8];
                m_Landmarks = new float[maxFaceNum * 28];
                m_AugLandmarks = new float[maxFaceNum * 136];
            }

            numfaces = AUGPCNdetect(m_pPCN, m_ColorArray.byteArray, m_WebWidth, m_WebHeight,
                rotate, flip, ios ? 1 : 0,
                m_Scale, m_MinFaceSize, maxFaceNum, doDetect ? 1 : 0,
                m_Retpoints, m_AugLandmarks, m_ModelPath);

            return numfaces;
        }
    }
    
}
