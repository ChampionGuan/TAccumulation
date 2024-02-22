using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;
namespace X3Game.ARPhoto
{
    [XLua.LuaCallCSharp]
    public class ARImageProcessingTool : Singleton<ARImageProcessingTool>
    {
        public enum FixGammaMode  
        {
            NoFix = 0,
            Fix = 1,
            ReverseFix = 2,
        }
        int m_WebHeight = 0;
        int m_WebWidth = 0;
        public Texture2D LUTTexture; //这个是预留给滤镜的
        //===================== shader相关 =============================
        private Material m_FaceBoxMaterial, m_DefaultProcessMaterial, m_RoleProcessMaterial;
        private RenderTextureDescriptor m_Desc;
        private RenderTexture m_OutRT, m_TempRT, m_TempRT2; //rt申请尽量少
        private RenderTexture m_HumanRT, m_FullRT;

        private Texture2D m_Alpha; //存alpha的
        private float[] m_Landmarks; //最终使用的14个人脸关键点
        private float[] m_RetPoints; //人脸包围框
        //-----------------美颜参数----------------
        private float m_EyeDelta;
        private float m_FaceDelta = 0.03f;
        private float m_RadiusCoef = 1.0f;

        //默认的瘦脸参数第一组，精调是在默认上
        //private float[] DEFAULT_DELTA_COEF_SET1 = { 0.0f, 0.3f, 0.0f, 0.0f, 0.0f, 0.4f, 1.0f, 0.3f, 0.0f, 1.0f, 0.0f, 0.02f };
        //private float[] DEFAULT_RADIUS_COEF_SET1 = { 2.5f, 2.5f, 2.5f, 2.5f, 2.5f, 2.75f, 6.0f, 2.75f, 2.5f, 1.0f, 1.5f, 0.45f };
        private float[] DEFAULT_DELTA_COEF_SET1 = { 0.0f, 0.3f, 0.0f, 0.0f, 0.0f, 0.4f, 1.0f, 0.3f, 0.0f, 1.0f, 0.0f, 0.02f };
        private float[] DEFAULT_RADIUS_COEF_SET1 = { 2.5f, 10.0f, 2.5f, 2.5f, 2.5f, 2.75f, 6.0f, 2.75f, 4.0f, 1.0f, 1.5f, 0.45f };
        private float[] DEFAULT_DELTA_ADD_SET1 = { 0.0f, 0.05f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.03f, 0.03f, 0.08f, 0.0f, 0.05f };

        private float[] DEFAULT_DELTA_COEF_SET2 = { 0.0f, 0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 0.02f };
        private float[] DEFAULT_RADIUS_COEF_SET2 = { 2.5f, 2.5f, 2.5f, 2.5f, 2.5f, 2.75f, 3.8f, 2.0f, 2.5f, 1.0f, 1.5f, 0.45f };



        private List<float[]> DEFAULT_DELTA_COEFS;
        private List<float[]> DEFAULT_RADIUS_COEFS;
        private const int CURRENT_DEFAULT_SET = 0; //以后如果有更多的就可能是别的 

        private float[] m_RadiusCoefs;
        private float[] m_Distances;
        private float m_FilterMultiple = 1.59f;//局部均值方差滤波半径
        private float m_FilterSigma = 0.007f;//局部均值方差滤波Sigma
        private float m_SurfaceIteration = 3.0f;//表面模糊迭代次数
        private float m_SurfaceMultiple = 3.06f;//表面模糊半径
        private float m_SurfaceSigmaS = 0.21f;//表面模糊SigmaS
        private float m_SurfaceSigmaC = 1.0f;//表面模糊SigmaC
        private float m_SharpStrength = 0.06f;//锐化

        private const float ECX = 1.6f;
        private const float ECY = 2.41f;
        private const float CX = 110.0f;
        private const float CY = 150.0f;

        private bool m_IsInit = false;
        protected override void Init()
        {
            DEFAULT_DELTA_COEFS = new List<float[]>();
            DEFAULT_RADIUS_COEFS = new List<float[]>();

            DEFAULT_DELTA_COEFS.Add(DEFAULT_DELTA_COEF_SET1);
            DEFAULT_RADIUS_COEFS.Add(DEFAULT_RADIUS_COEF_SET1);
            DEFAULT_DELTA_COEFS.Add(DEFAULT_DELTA_COEF_SET2);
            DEFAULT_RADIUS_COEFS.Add(DEFAULT_RADIUS_COEF_SET2);

            //m_DeltaCoefs = new float[DEFAULT_DELTA_COEFS[CURRENT_DEFAULT_SET].Length];
            m_RadiusCoefs = (float[])DEFAULT_RADIUS_COEFS[CURRENT_DEFAULT_SET].Clone();
            m_Distances = new float[17];
            LoadMaterial();
        }
        protected override void UnInit()
        {
            if (!m_IsInit)
                return;
            ReleaseAllRT();
            Res.Unload(m_DefaultProcessMaterial);
            Res.Unload(m_FaceBoxMaterial);
            Res.Unload(m_RoleProcessMaterial);
            m_Distances = null;
            m_RadiusCoefs = null;
        }
        //切换摄像头用
        public void ReleaseAllRT()
        {
            ReleaseFaceRT(ref m_OutRT);
            ReleaseFaceRT(ref m_TempRT);
            ReleaseFaceRT(ref m_TempRT2);
            ReleaseFaceRT(ref m_HumanRT);
            ReleaseFaceRT(ref m_FullRT);
        }
        public void SetImageSize(int width, int height)
        {
            m_WebWidth = width;
            m_WebHeight = height;
            setupTextureProcess();
            m_IsInit = true;
        }
        private void CreateFaceRT(ref RenderTexture rt, RenderTextureDescriptor desc)
        {
            if (rt == null)
            {
                rt = RenderTexture.GetTemporary(desc);
            }
        }

        private void ReleaseFaceRT(ref RenderTexture rt)
        {
            if (rt != null)
            {
                RenderTexture.ReleaseTemporary(rt);
                rt = null;
            }
        }
        //设置美颜参数
        public void SetBeautyDelta(float sigma, float eye, float face)
        {
            m_FilterSigma = sigma;
            m_EyeDelta = eye;
            m_FaceDelta = face;
        }
        //进行美颜处理
        public RenderTexture BeautyImage(float[] landmarks, float[] retpoints, Texture2D alphaInfo, Texture camTextrue, int numface, FixGammaMode fixGammaMode = FixGammaMode.Fix, bool useExtraSetting = false)
        {
            if (!m_IsInit)
                return null;
            m_Alpha = alphaInfo;
            m_Landmarks = landmarks;
            m_RetPoints = retpoints;
            bool isSigle = false;
            for (int j = 0; j < m_Landmarks.Length; j++)
            {
                if (!isSigle)
                    m_Landmarks[j] /= m_WebWidth;
                else
                    m_Landmarks[j] /= m_WebHeight;
                isSigle = !isSigle;
            }

            FaceBoxProcess(camTextrue, m_TempRT, m_TempRT2, m_OutRT, numface, fixGammaMode, useExtraSetting);
            return m_OutRT;
        }

        public void UpdateHumanImage()
        {
            SetHumanImage(m_OutRT, m_HumanRT);
        }
        public void UpdateFullImage()
        {
            SetFullImage(m_OutRT, m_FullRT);
        }
        public void UpdateBaseImage(Texture texture, FixGammaMode fixGammaMode = FixGammaMode.Fix)
        {
            DefaultProcess(texture, m_FullRT, fixGammaMode);
        }
        public RenderTexture GetHumanImage()
        {
            return m_HumanRT;
        }

        public RenderTexture GetFullImage()
        {
            return m_FullRT;
        }
        
        private void LoadMaterial()
        {
            m_FaceBoxMaterial = Res.Load<Material>("Assets/Build/Res/GameObjectRes/UI/Materials/BeautycamMaterials/Hidden_BeautycamProcess.mat", Res.AutoReleaseMode.None);
            m_DefaultProcessMaterial = Res.Load<Material>("Assets/Build/Res/GameObjectRes/UI/Materials/BeautycamMaterials/Hidden_Defaultprocess.mat", Res.AutoReleaseMode.None);
            m_RoleProcessMaterial = Res.Load<Material>("Assets/Build/Res/GameObjectRes/UI/Materials/BeautycamMaterials/Hidden_Role.mat", Res.AutoReleaseMode.None);
        }

        private void setupTextureProcess()
        {
            m_Desc = new RenderTextureDescriptor(m_WebWidth, m_WebHeight, RenderTextureFormat.ARGB32, 0);
            m_Desc.autoGenerateMips = false;
            m_Desc.bindMS = false;

            m_Desc.dimension = UnityEngine.Rendering.TextureDimension.Tex2D;
            m_Desc.enableRandomWrite = false;

            m_Desc.msaaSamples = 1;
            m_Desc.sRGB = false; // setting
            m_Desc.useMipMap = false;
            m_Desc.volumeDepth = 1;

            CreateFaceRT(ref m_OutRT, m_Desc);
            CreateFaceRT(ref m_TempRT, m_Desc);
            CreateFaceRT(ref m_TempRT2, m_Desc);
            CreateFaceRT(ref m_HumanRT, m_Desc);
            CreateFaceRT(ref m_FullRT, m_Desc);

            m_OutRT.wrapMode = TextureWrapMode.Clamp;
            m_TempRT.wrapMode = TextureWrapMode.Clamp;
            m_TempRT2.wrapMode = TextureWrapMode.Clamp;
            m_HumanRT.wrapMode = TextureWrapMode.Clamp;
            m_FullRT.wrapMode = TextureWrapMode.Clamp;
        }
        //美颜
        private void FaceBoxProcess(Texture camTextrue, RenderTexture faceRT, RenderTexture faceRT2, RenderTexture destination, int numface, FixGammaMode fixGammaMode, bool useExtraSetting = false)
        {
            if (!m_IsInit)
                return;
            int maxSize = Mathf.Max(m_WebWidth, m_WebHeight);

            float radius = maxSize / 512f; //每个radius需要乘上这个系数，以适应不同分辨率

            m_FaceBoxMaterial.SetTexture("_LutTex", LUTTexture);
            m_FaceBoxMaterial.SetTexture("_AlphaTex", m_Alpha);
            float fixGammaValue = 1;
            if (fixGammaMode == FixGammaMode.Fix)
                fixGammaValue = 1/2.2f;
            else if (fixGammaMode == FixGammaMode.ReverseFix)
                fixGammaValue = 2.2f;
            m_FaceBoxMaterial.SetFloat("_FixGamma", fixGammaValue);
            Graphics.Blit(camTextrue, faceRT, m_FaceBoxMaterial, 12); //lut

            //m_FaceBoxMaterial.SetFloat("_FilterRadius", 2);
            m_FaceBoxMaterial.SetFloat("_FilterMultiple", m_SurfaceMultiple * radius * (3.0f / 2.0f));
            m_FaceBoxMaterial.SetFloat("_SigmaS", m_SurfaceSigmaS);
            m_FaceBoxMaterial.SetFloat("_SigmaC", m_SurfaceSigmaC);

            m_FaceBoxMaterial.SetFloat("_ECX", ECX);
            m_FaceBoxMaterial.SetFloat("_ECY", ECY);
            m_FaceBoxMaterial.SetFloat("_CX", CX);
            m_FaceBoxMaterial.SetFloat("_CY", CY);

            Graphics.Blit(faceRT, faceRT2, m_FaceBoxMaterial, 10);
            Graphics.Blit(faceRT2, destination, m_FaceBoxMaterial, 11);


            m_FaceBoxMaterial.SetTexture("_BlurTex", destination);
            m_FaceBoxMaterial.SetFloat("_SigmaS", m_FilterSigma);
            //m_FaceBoxMaterial.SetFloat("_FilterRadius", 2);
            m_FaceBoxMaterial.SetFloat("_FilterMultiple", m_FilterMultiple);
            Graphics.Blit(faceRT, faceRT2, m_FaceBoxMaterial, 18); //局部均值方差滤波

            m_FaceBoxMaterial.SetFloat("_SharpStrength", m_SharpStrength * radius);
            if (numface > 0)
            {
                Graphics.Blit(faceRT2, faceRT, m_FaceBoxMaterial, 9); //sharp

                //eye face
                m_FaceBoxMaterial.SetVector("_Eyes", new Vector4(m_Landmarks[2 * 10], m_Landmarks[2 * 10 + 1], m_Landmarks[2 * 11], m_Landmarks[2 * 11 + 1]));
                m_FaceBoxMaterial.SetVector("_LeftEyes", new Vector4(m_Landmarks[2 * 10], m_Landmarks[2 * 10 + 1], m_RetPoints[2 * 0] / m_WebWidth, m_RetPoints[2 * 0 + 1] / m_WebHeight));
                m_FaceBoxMaterial.SetVector("_RightEyes", new Vector4(m_Landmarks[2 * 11], m_Landmarks[2 * 11 + 1], m_RetPoints[2 * 3] / m_WebWidth, m_RetPoints[2 * 3 + 1] / m_WebHeight));
                //nose后面两个点是下巴
                m_FaceBoxMaterial.SetVector("_Nose", new Vector4(m_Landmarks[2 * 9], m_Landmarks[2 * 9 + 1], m_Landmarks[2 * 4], m_Landmarks[2 * 4 + 1]));

                // 实际是11个,包括下巴
                Vector2[] used_points = new Vector2[17];
                for (int i = 0; i < used_points.Length; ++i)
                {
                    if (i % 2 == 1)
                    {
                        //都是中心点
                        int begin_index = (i / 2);
                        int end_index = (i / 2) + 1;
                        used_points[i].x = (m_Landmarks[begin_index * 2] + m_Landmarks[end_index * 2]) / 2.0f;
                        used_points[i].y = (m_Landmarks[begin_index * 2 + 1] + m_Landmarks[end_index * 2 + 1]) / 2.0f;
                    }
                    else
                    {
                        //都是正点
                        int index = (i / 2);
                        used_points[i].x = m_Landmarks[index * 2];
                        used_points[i].y = m_Landmarks[index * 2 + 1];
                    }
                    if ((i != 0 && i < 9) || i == used_points.Length - 1)
                    {
                        //左边是与上各点的距离
                        m_Distances[i] = Vector2.Distance(used_points[i - 1], used_points[i]);
                        if (i == used_points.Length - 1)
                        {
                            m_Distances[i - 1] = Vector2.Distance(used_points[i - 1], used_points[i]);
                        }
                    }
                    else if (i >= 10)
                    {
                        //右边是与下个点的距离
                        m_Distances[i - 1] = Vector2.Distance(used_points[i - 1], used_points[i]);

                    }
                }
                m_Distances[0] = Vector2.Distance(used_points[0], used_points[1]);

                //之前那样肯定不行，点太少了
                //点1.5和2
                m_FaceBoxMaterial.SetVector("_Face1", new Vector4(used_points[0].x, used_points[0].y, used_points[16].x, used_points[16].y));
                //2.5和3
                m_FaceBoxMaterial.SetVector("_Face2", new Vector4(used_points[1].x, used_points[1].y, used_points[15].x, used_points[15].y));
                //3.5 4
                m_FaceBoxMaterial.SetVector("_Face3", new Vector4(used_points[2].x, used_points[2].y, used_points[14].x, used_points[14].y));
                //4.5 5
                m_FaceBoxMaterial.SetVector("_Face4", new Vector4(used_points[3].x, used_points[3].y, used_points[13].x, used_points[13].y));
                //5.5 6
                m_FaceBoxMaterial.SetVector("_Face5", new Vector4(used_points[4].x, used_points[4].y, used_points[12].x, used_points[12].y));
                //6.5 7, 
                m_FaceBoxMaterial.SetVector("_Face6", new Vector4(used_points[5].x, used_points[5].y, used_points[11].x, used_points[11].y));
                m_FaceBoxMaterial.SetVector("_Face7", new Vector4(used_points[6].x, used_points[6].y, used_points[10].x, used_points[10].y));
                m_FaceBoxMaterial.SetVector("_Face8", new Vector4(used_points[7].x, used_points[7].y, used_points[9].x, used_points[9].y));
                // 后两个是嘴巴的中心
                m_FaceBoxMaterial.SetVector("_Face9", new Vector4(used_points[8].x, used_points[8].y, (m_Landmarks[24] + m_Landmarks[26]) / 2.0f, (m_Landmarks[25] + m_Landmarks[27]) / 2.0f));

                //鼻子，猜测值
                Vector4 point3 = new Vector4(m_Landmarks[2], m_Landmarks[3], m_Landmarks[14], m_Landmarks[15]);
                Vector4 point4 = new Vector4(m_Landmarks[18], m_Landmarks[19], m_Landmarks[18], m_Landmarks[19]);
                m_FaceBoxMaterial.SetVector("_Face10", new Vector4(point3.x + (point4.x - point3.x) * 2.0f / 3.0f, point3.y + (point4.y - point3.y) * 2.0f / 3.0f, point4.z + (point3.z - point4.z) * 1.0f / 3.0f, point4.w + (point3.w - point4.w) * 1.0f / 3.0f));
                //嘴巴
                m_FaceBoxMaterial.SetVector("_Face11", new Vector4(m_Landmarks[24], m_Landmarks[25], m_Landmarks[26], m_Landmarks[27]));

                //对下巴脸颊等选取不同的radius
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef1", new Vector4(m_RadiusCoef * m_RadiusCoefs[0] * m_Distances[0], m_RadiusCoef * m_RadiusCoefs[0] * m_Distances[16], 0, 0));
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef2", new Vector4(m_RadiusCoef * m_RadiusCoefs[1] * m_Distances[1], m_RadiusCoef * m_RadiusCoefs[1] * m_Distances[15], 0, 0));
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef3", new Vector4(m_RadiusCoef * m_RadiusCoefs[2] * m_Distances[2], m_RadiusCoef * m_RadiusCoefs[2] * m_Distances[14], 0, 0));
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef4", new Vector4(m_RadiusCoef * m_RadiusCoefs[3] * m_Distances[3], m_RadiusCoef * m_RadiusCoefs[3] * m_Distances[13], 0, 0));
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef5", new Vector4(m_RadiusCoef * m_RadiusCoefs[4] * m_Distances[4], m_RadiusCoef * m_RadiusCoefs[4] * m_Distances[12], 0, 0));
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef6", new Vector4(m_RadiusCoef * m_RadiusCoefs[5] * m_Distances[5], m_RadiusCoef * m_RadiusCoefs[5] * m_Distances[11], 0, 0));
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef7", new Vector4(m_RadiusCoef * m_RadiusCoefs[6] * m_Distances[6], m_RadiusCoef * m_RadiusCoefs[6] * m_Distances[10], 0, 0));
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef8", new Vector4(m_RadiusCoef * m_RadiusCoefs[7] * m_Distances[7], m_RadiusCoef * m_RadiusCoefs[7] * m_Distances[9], 0, 0));
                //第二个是嘴巴
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef9", new Vector4(m_RadiusCoef * m_RadiusCoefs[8] * m_Distances[8], m_RadiusCoef * m_RadiusCoefs[11], 0, 0));
                //鼻子,v
                m_FaceBoxMaterial.SetVector("_FaceRadiusCoef10", new Vector4(m_RadiusCoef * m_RadiusCoefs[9], m_RadiusCoef * m_RadiusCoefs[9], m_RadiusCoef * m_RadiusCoefs[10] * m_Distances[6], m_RadiusCoef * m_RadiusCoefs[10] * m_Distances[10]));

                float[] default_set = DEFAULT_DELTA_COEFS[CURRENT_DEFAULT_SET];
                m_FaceBoxMaterial.SetFloat("_EyesDelta", m_EyeDelta);
                if (useExtraSetting)
                {
                    m_FaceBoxMaterial.SetVector("_FaceDelta1",
                        new Vector4(m_FaceDelta * default_set[0] + DEFAULT_DELTA_ADD_SET1[0],
                            m_FaceDelta * default_set[1] + DEFAULT_DELTA_ADD_SET1[1],
                            m_FaceDelta * default_set[2] + DEFAULT_DELTA_ADD_SET1[2],
                            m_FaceDelta * default_set[3] + DEFAULT_DELTA_ADD_SET1[3]));
                    m_FaceBoxMaterial.SetVector("_FaceDelta2",
                        new Vector4(m_FaceDelta * default_set[4] + DEFAULT_DELTA_ADD_SET1[4],
                            m_FaceDelta * default_set[5] + DEFAULT_DELTA_ADD_SET1[5],
                            m_FaceDelta * default_set[6] + DEFAULT_DELTA_ADD_SET1[6],
                            m_FaceDelta * default_set[7] + DEFAULT_DELTA_ADD_SET1[7]));
                    m_FaceBoxMaterial.SetVector("_FaceDelta3",
                        new Vector4(m_FaceDelta * default_set[8] + DEFAULT_DELTA_ADD_SET1[8],
                            m_FaceDelta * default_set[9] + DEFAULT_DELTA_ADD_SET1[9],
                            m_FaceDelta * default_set[10] + DEFAULT_DELTA_ADD_SET1[10],
                            m_FaceDelta * default_set[11] + DEFAULT_DELTA_ADD_SET1[11]));
                }
                else
                {
                    m_FaceBoxMaterial.SetVector("_FaceDelta1",
                        new Vector4(m_FaceDelta * default_set[0], m_FaceDelta * default_set[1],
                            m_FaceDelta * default_set[2], m_FaceDelta * default_set[3]));
                    m_FaceBoxMaterial.SetVector("_FaceDelta2",
                        new Vector4(m_FaceDelta * default_set[4], m_FaceDelta * default_set[5],
                            m_FaceDelta * default_set[6], m_FaceDelta * default_set[7]));
                    m_FaceBoxMaterial.SetVector("_FaceDelta3",
                        new Vector4(m_FaceDelta * default_set[8], m_FaceDelta * default_set[9],
                            m_FaceDelta * default_set[10], m_FaceDelta * default_set[11]));
                }

                //m_FaceBoxMaterial.SetVector("_FaceDelta", new Vector4(m_FaceDelta, m_FaceDelta, m_FaceDelta, 0));


                m_FaceBoxMaterial.SetVector("_xyup1", new Vector4(m_RetPoints[0], m_RetPoints[1], m_RetPoints[6], m_RetPoints[7]));
                m_FaceBoxMaterial.SetVector("_xydown1", new Vector4(m_RetPoints[2], m_RetPoints[3], m_RetPoints[4], m_RetPoints[5]));
                m_FaceBoxMaterial.SetVector("_eyes1", new Vector4(m_Landmarks[20], m_Landmarks[21], m_Landmarks[22], m_Landmarks[23]));
                //m_FaceBoxMaterial.SetVector("_eyes1", new Vector4(point3.x + (point4.x - point3.x) * 2.0f / 3.0f, point3.y + (point4.y - point3.y) * 2.0f / 3.0f, point4.z + (point3.z - point4.z) * 1.0f / 3.0f, point4.w + (point3.w - point4.w) * 1.0f / 3.0f));
                m_FaceBoxMaterial.SetVector("_eyes1", new Vector4(m_Landmarks[24], m_Landmarks[25], m_Landmarks[26], m_Landmarks[27]));

                m_FaceBoxMaterial.SetVector("_nose1", new Vector4(m_Landmarks[18], m_Landmarks[19], 0, 0));
                m_FaceBoxMaterial.SetVector("_face11", new Vector4(m_Landmarks[0], m_Landmarks[1], m_Landmarks[2], m_Landmarks[3]));
                m_FaceBoxMaterial.SetVector("_face12", new Vector4(m_Landmarks[4], m_Landmarks[5], m_Landmarks[6], m_Landmarks[7]));
                m_FaceBoxMaterial.SetVector("_face13", new Vector4(m_Landmarks[8], m_Landmarks[9], m_Landmarks[10], m_Landmarks[11]));

                m_FaceBoxMaterial.SetVector("_face14", new Vector4(m_Landmarks[12], m_Landmarks[13], m_Landmarks[14], m_Landmarks[15]));
                m_FaceBoxMaterial.SetVector("_face15", new Vector4(m_Landmarks[16], m_Landmarks[17], 0, 0));
#if UNITY_STANDALONE_WIN || UNITY_IOS
                    //这个目前纯粹为了适配win
                    m_FaceBoxMaterial.SetFloat("_PC_RT_flip", 1);
#else
                m_FaceBoxMaterial.SetFloat("_PC_RT_flip", 0);
#endif

                Graphics.Blit(faceRT, destination, m_FaceBoxMaterial, 8); //mix
            }
        }

        //获取切割的人
        private void SetHumanImage(RenderTexture fromtexture, RenderTexture destination)
        {
            m_RoleProcessMaterial.SetFloat("_CameraBG", 0);
            m_RoleProcessMaterial.DisableKeyword("ROLE_MODE");
            Graphics.Blit(fromtexture, destination, m_RoleProcessMaterial, 0);
        }

        //获取完整的图像
        private void SetFullImage(RenderTexture fromtexture, RenderTexture destination)
        {
            m_RoleProcessMaterial.SetFloat("_CameraBG", 1);
            m_RoleProcessMaterial.DisableKeyword("ROLE_MODE");
            Graphics.Blit(fromtexture, destination, m_RoleProcessMaterial, 0);
        }

        private void DefaultProcess(Texture fromtexture, RenderTexture destination, FixGammaMode fixGammaMode)
        {
            float fixGammaValue = 1;
            if (fixGammaMode == FixGammaMode.Fix)
                fixGammaValue = 1/2.2f;
            else if (fixGammaMode == FixGammaMode.ReverseFix)
                fixGammaValue = 2.2f;
            m_DefaultProcessMaterial.SetFloat("_FixGamma", fixGammaValue);
            Graphics.Blit(fromtexture, destination, m_DefaultProcessMaterial);
        }
    }
}
