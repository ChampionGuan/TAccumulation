using System;
using System.IO;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.UI;
using X3Game.AILab;
using X3Game.ARPhoto;
using X3Game.Platform;

namespace X3Game.AIFace
{
    [XLua.LuaCallCSharp]
    public class AIFaceProcess : MonoSingleton<AIFaceProcess>
    {
        private RawImage m_cameraImg;
        private GameObject m_deco;
        private WebCamTexture m_CamTexture;
        private Texture2D m_lutTexture = null;
        private float m_filterSigma = 0.02f;
        private float m_eyeDelta = 0.15f;
        private float m_faceDelta = 0.1f;
        private float m_boneWeight = 0.6f;
        private Texture2D m_lutTextureLive = null;
        private float m_filterSigmaLive = 0f;
        private float m_eyeDeltaLive = 0f;
        private float m_faceDeltaLive = 0f;
        private int[] m_whiteIds;
        private int[] m_whiteTypes;

        private Color32[] m_Colors = null;
        private const int M_FACE_TRACK_INTERVAL = 10; //我们现在是设置10帧，但其实应该按照秒计算，设置0.3秒会比较好。区间需测试。不要太小就行。
        private int m_FramePassedFromLastCheck = 0;
        private bool m_IsPause = false;
        private float m_width;
        private float m_height;
        private ARImageProcessingTool.FixGammaMode m_liveGammaMode;

        protected override void Init()
        {
            FaceDetectTool.s_PerformanceMode = false;
#if UNITY_IOS
            m_liveGammaMode = ARImageProcessingTool.FixGammaMode.NoFix;
#else
            m_liveGammaMode = ARImageProcessingTool.FixGammaMode.Fix;
#endif
        }

        protected override void UnInit()
        {
            WebCamHelper.DestroyInstance();
            FaceDetectTool.DestroyInstance();
            ARImageProcessingTool.DestroyInstance();
            AIFaceBridge.DestroyInstance();
            FaceValidationUtility.Release();
        }

        #region webCamera

        private void Update()
        {
            UpdateImage();
        }

        private void UpdateImage()
        {
            if (m_CamTexture != null && m_CamTexture.didUpdateThisFrame && m_CamTexture.isPlaying && !m_IsPause)
            {
                if (WebCamHelper.Instance.isReady)
                {
                    if (m_deco && !m_deco.activeSelf)
                        m_deco.SetActive(true);
                    m_cameraImg.texture = ARImageProcessingTool.Instance.GetFullImage();
                    m_CamTexture.GetPixels32(m_Colors);
                    var camTexture = m_CamTexture;
                    m_FramePassedFromLastCheck++;
                    int num = FaceDetectTool.Instance.DoFaceDetect(m_Colors,
                        m_FramePassedFromLastCheck >= M_FACE_TRACK_INTERVAL);

                    if (num > 0)
                    {
                        float[] landMarks = FaceDetectTool.Instance.GetLandMarks();
                        float[] retpoints = FaceDetectTool.Instance.GetRetPoint();
                        ARImageProcessingTool.Instance.BeautyImage(landMarks, retpoints, Texture2D.whiteTexture,
                            camTexture, num, m_liveGammaMode);
                        ARImageProcessingTool.Instance.UpdateFullImage();
                    }
                    else
                    {
                        ARImageProcessingTool.Instance.UpdateBaseImage(camTexture, m_liveGammaMode);
                    }
                }
                else
                {
                    if (m_deco && m_deco.activeSelf)
                        m_deco.SetActive(false);
                }
            }
        }

        public bool StartWebCamera(RawImage rawImage, GameObject deco, Texture2D lutTexture, float filterSigma,
            float eyeDelta,
            float faceDelta, float width, float height)
        {
            m_lutTextureLive = lutTexture;
            m_filterSigmaLive = filterSigma;
            m_eyeDeltaLive = eyeDelta;
            m_faceDeltaLive = faceDelta;

            m_width = width;
            m_height = height;
            if (!WebCamHelper.Instance.GetWebCamTexture(m_width, m_height, true))
                return false;
            m_IsPause = false;
            m_CamTexture = WebCamHelper.Instance.webCamTexture;
            m_cameraImg = rawImage;
            m_deco = deco;
            if (m_cameraImg)
            {
                m_cameraImg.texture = Texture2D.blackTexture;
                WebCamHelper.Instance.SetCameraRawImage(m_cameraImg, width, height);

                var size = WebCamHelper.Instance.GetCameraSize();
                var realW = size.x;
                var realH = size.y;
                ARImageProcessingTool.Instance.ReleaseAllRT();
                ARImageProcessingTool.Instance.SetImageSize(realW, realH);
                FaceDetectTool.Instance.SetImageSize(realW, realH);
                m_Colors = new Color32[realW * realH];

                ARImageProcessingTool.Instance.LUTTexture = m_lutTextureLive;
                ARImageProcessingTool.Instance.SetBeautyDelta(Mathf.Max(1e-4f, m_filterSigmaLive), m_eyeDeltaLive,
                    m_faceDeltaLive);
                UpdateImage();
                ResetDecoSize();
            }

            return true;
        }

        void ResetDecoSize()
        {
            var aimSize = m_cameraImg.GetComponent<RectTransform>().sizeDelta;
            float camWidth, camHeight;
#if UNITY_EDITOR
            camWidth = aimSize.x;
            camHeight = aimSize.y;
#else
            camWidth = aimSize.y;
            camHeight = aimSize.x;
#endif
            var rectTf = m_deco.GetComponent<RectTransform>();
            var rect = rectTf.rect;
            var width = rect.width;
            var height = rect.height;


            if (camHeight / height > camWidth / width)
            {
                rectTf.localScale = new Vector3(camWidth / width, camWidth / width, 1f);
                ;
            }
            else
            {
                rectTf.localScale = new Vector3(camHeight / height, camHeight / height, 1f);
                ;
            }
        }

        public void ResetBeautyCam()
        {
            m_cameraImg.texture = Texture2D.blackTexture;
            ARImageProcessingTool.Instance.LUTTexture = m_lutTextureLive;
            ARImageProcessingTool.Instance.SetBeautyDelta(Mathf.Max(1e-4f, m_filterSigmaLive), m_eyeDeltaLive,
                m_faceDeltaLive);
            var size = WebCamHelper.Instance.GetCameraSize();
            var width = size.x;
            var height = size.y;
            ARImageProcessingTool.Instance.ReleaseAllRT();
            ARImageProcessingTool.Instance.SetImageSize(width, height);
            FaceDetectTool.Instance.SetImageSize(width, height);
            m_Colors = new Color32[width * height];

            ResumeWebCamera();
            ResetDecoSize();
        }

        public void PauseWebCamera()
        {
            WebCamHelper.Instance.Pause();
            m_IsPause = true;
        }

        public void ResumeWebCamera()
        {
            WebCamHelper.Instance.Play(true);
            m_IsPause = false;
        }

        public void StopWebCamera()
        {
            WebCamHelper.Instance.Stop();
        }

        public void SwitchWebCamera()
        {
            m_cameraImg.texture = Texture2D.blackTexture;
            WebCamHelper.Instance.SwitchCamera(m_width, m_height);
            if (m_cameraImg)
            {
                var size = WebCamHelper.Instance.GetCameraSize();
                var width = size.x;
                var height = size.y;
                ARImageProcessingTool.Instance.ReleaseAllRT();
                ARImageProcessingTool.Instance.SetImageSize(width, height);
                FaceDetectTool.Instance.SetImageSize(width, height);
                m_Colors = new Color32[width * height];

                UpdateImage();
                ResetDecoSize();
            }
        }

        #endregion

        #region BeautyCam & AIFace

        public void InitFaceValidator(float threshold, float[][] faceCodes)
        {
            FaceValidationUtility.InitFaceValidator(threshold, faceCodes);
        }

        public void TakePhotoAndProcess(Action<int, int[], int[], float[]> onComplete)
        {
            if (!m_IsPause)
            {
                var tex = WebCamHelper.Instance.CaptureCurTexture();
                if (tex)
                {
                    PauseWebCamera();
#if UNITY_EDITOR
                    SavePng(tex, "AIFaceTest", "origin");
#endif
                    Process(tex, onComplete, true);
                    Destroy(tex);
                }
                else
                {
                    X3Debug.LogWarning("Captured tex is null");
                }
            }
            else
            {
                X3Debug.LogWarning("Camera is Pause");
            }
        }

        public void SetMakeupBlack(int[] whiteIds, int[] whiteTypes)
        {
            m_whiteIds = whiteIds;
            m_whiteTypes = whiteTypes;
        }

        public void SetBeautySetting(Texture2D lut, float filterSigma, float eyeDelta, float faceDelta,
            float boneWeight)
        {
            m_lutTexture = lut;
            m_filterSigma = filterSigma;
            m_eyeDelta = eyeDelta;
            m_faceDelta = faceDelta;
            m_boneWeight = boneWeight;
        }
#if UNITY_EDITOR
        string SavePng(Texture2D png, string contents, string pngName, bool scale = false)
        {
            byte[] bytes;
            png.Apply();
            bytes = png.EncodeToPNG();

            if (!Directory.Exists(contents))
                Directory.CreateDirectory(contents);
            FileStream file = File.Open(contents + "/" + pngName + ".png", FileMode.Create);
            BinaryWriter writer = new BinaryWriter(file);
            writer.Write(bytes);
            file.Close();

            return contents + "/" + pngName + ".png";
        }
#endif

        private Texture2D ProcessBeautyCam(Texture2D input, bool isCamera = true)
        {
            FaceDetectTool.Instance.SetImageSize(input.width, input.height, 2048);
            var colors = input.GetPixels32();

            Texture2D output = null;

            int num = FaceDetectTool.Instance.DoFaceDetect(colors, true, 100, isCamera);

            if (num > 0)
            {
                float[] landMarks = FaceDetectTool.Instance.GetLandMarks();
                float[] retpoints = FaceDetectTool.Instance.GetRetPoint();
                ARImageProcessingTool.Instance.ReleaseAllRT();
                ARImageProcessingTool.Instance.SetImageSize(input.width, input.height);
                ARImageProcessingTool.Instance.LUTTexture = m_lutTexture;
                ARImageProcessingTool.Instance.SetBeautyDelta(Mathf.Max(1e-4f, m_filterSigma), m_eyeDelta,
                    m_faceDelta);

                Profiler.BeginSample("BeautyCamera");
                var rt = ARImageProcessingTool.Instance.BeautyImage(landMarks, retpoints, Texture2D.whiteTexture,
                    input, num, ARImageProcessingTool.FixGammaMode.Fix, true);

                Profiler.EndSample();
                if (rt != null)
                {
                    output = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);
                    RenderTexture prev = RenderTexture.active;
                    RenderTexture.active = rt;

                    output.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
                    output.Apply();

                    RenderTexture.active = prev;
                }
            }

            return output;
        }

        public void Process(Texture2D input, Action<int, int[], int[], float[]> onComplete, bool isCamera = false)
        {
            switch (FaceValidationUtility.CheckFace(input, isCamera))
            {
                case CheckFaceResult.Detected:
                    onComplete(-2, null, null, null);
                    return;
                case CheckFaceResult.NoFace:
                    onComplete(0, null, null, null);
                    return;
            }
            
            Texture2D processTex;
            bool compressed = false;
            float scale = 2000.0f/Mathf.Min(input.width, input.height);
            if (!isCamera && scale < 1)
            {
                compressed = true;
                processTex = TextureUtility.CompressTextureNew(input, Mathf.CeilToInt(scale * 100), out int w, out int h);
            }
            else
            {
                processTex = input;
            }
            
            var beautyTex = ProcessBeautyCam(processTex, isCamera);
            var newBeauty = beautyTex != null;
            if (beautyTex == null)
            {
                X3Debug.LogError($"未检测到人脸【美颜】【{processTex}】");
                beautyTex = newBeauty ? beautyTex : processTex;
            }
            else
            {
#if DEBUG && !ProfilerEnable
#if UNITY_EDITOR
                SavePng(beautyTex, "AIFaceTest", "beauty");
#else
                var bytesInput = input.EncodeToPNG();
                var bytesBeauty = beautyTex.EncodeToPNG();
                PFAlbumUtility.AddPhotoToAlbum(bytesInput, $"input{((DateTimeOffset)DateTime.Now).ToUnixTimeSeconds()}", "AIFaceDebugInput");
                PFAlbumUtility.AddPhotoToAlbum(bytesBeauty, $"beauty{((DateTimeOffset)DateTime.Now).ToUnixTimeSeconds()}", "AIFaceDebugBeautyInput");
#endif
#endif
            }

            AIFaceBridge.Instance.Process(processTex, beautyTex, m_whiteIds, m_whiteTypes, m_boneWeight, onComplete,
                isCamera);
            if (newBeauty)
            {
                Destroy(beautyTex);
            }

            if (compressed)
            {
                Destroy(processTex);
            }
        }

#if UNITY_EDITOR
        public void TestProcess(string imgPath, Action<int, int[], int[], float[]> onComplete)
        {
            if (File.Exists(imgPath))
            {
                var fileData = File.ReadAllBytes(imgPath);
                var tex2D = new Texture2D(2, 2, TextureFormat.RGBA32, false);
                if (tex2D.LoadImage(fileData))
                {
                    tex2D.Apply();
                    Process(tex2D, onComplete);
                    Destroy(tex2D);
                }
            }
        }
#endif

        #endregion
    }
}