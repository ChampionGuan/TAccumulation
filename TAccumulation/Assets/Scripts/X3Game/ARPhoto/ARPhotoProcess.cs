using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using PapeGames.X3;
using PapeGames.Rendering;
using X3Game.AILab;
using System;
using X3Game.AutoColor;
using System.Threading;
using System.Threading.Tasks;

namespace X3Game.ARPhoto
{
    //AR拍照功能对外接口
    [XLua.LuaCallCSharp]
    public class ARPhotoProcess : MonoSingleton<ARPhotoProcess>
    {
        private WebCamTexture m_CamTexture;//相机材质
        private Texture2D m_ARSessionTexture;//ARFoundation对应
        //人脸检测和跟踪的工作方式是这样的：m_FaceTrackInterval，剩余时间调用人脸跟踪。以此来提高速度和稳定性。m_FaceTrackInterval，人脸被检测到的速度会有延迟，太小则会导致运算量增加，计算速度变慢。
        private float m_FaceTrackInterval = 0.3f; //我们现在是设置10帧，但其实应该按照秒计算，设置0.3秒会比较好。区间需测试。不要太小就行。
        private float m_FaceTrackIntervalLong = 1.0f; //检测到人脸后检测间隔时间
        private float m_CurFaceTrackInterval = 0.3f;
        private float m_FramePassedFromLastCheck = 0;
        public RawImage FrontImage, BackImage;
        public Texture2D LUTTexture; //这个是预留给滤镜的
        private bool m_HumanFront = true;
        private bool m_IsShowBack = true;
        public bool IsTest = false;
        private float m_Brightness = 0;
        private Color m_Color = Color.white;
        private bool m_IsPause = false;
        private bool m_isFirstUpdate = false;
        private bool m_DoFaceDetect = true;
        private bool m_isChangeDir = false;
        private int m_FixGammaMode = 0;
        private int m_TargetWidth = 0;
        private int m_TargetHeight = 0;
        private bool m_ForbidAutoColor = false;
        private Task m_Task = null;
        private int m_FaceNum = 0;
        private bool m_IsDetectAsync = false;
        public bool PrepareARPhoto(bool isFront, int targetWidth, int targetHeight, float netScale = 1.0f, bool isPerformanceMode = false)
        {
            FaceDetectTool.s_PerformanceMode = isPerformanceMode;
            FaceDetectTool.Instance.CreatePortraitNet();
            if (netScale != 1.0f) //其实默认是0.79，方便理解1的时候不进行设置，优化时默认设置0.5
                FaceDetectTool.Instance.SetScaleFactor(netScale);
            m_TargetHeight = targetHeight;
            m_TargetWidth = targetWidth;
            m_CurFaceTrackInterval = m_FaceTrackInterval;
            bool canGetCamera = WebCamHelper.Instance.GetWebCamTexture(m_TargetWidth, m_TargetHeight, isFront,true);
            if (canGetCamera)
            {
                m_CamTexture = WebCamHelper.Instance.webCamTexture;
                Vector2Int size = WebCamHelper.Instance.GetCameraSize();
                X3Debug.LogFormat("Camera Resolution:{0}, {1}", size[0], size[1]);
                SetCamImageSize(size[0], size[1]);
                m_IsPause = false;
            }
            return canGetCamera;
        }
        
        public void SetIsFaceDetect(bool isDoFaceDetect)
        {
            m_DoFaceDetect = isDoFaceDetect;
        }

        public void SetIsFixGamma(int isFixGamma)
        {
            m_FixGammaMode = isFixGamma;
        }

        public void SetForbidAutoColor(bool isForbid)
        {
            m_ForbidAutoColor = isForbid;
        }

        public void SetDetectAsync(bool isAsync)
        {
            m_IsDetectAsync = isAsync;
        }
        
        public Vector2 GetCamResolution()
        {
            return WebCamHelper.Instance.GetCameraSize();
        }

        public void SetFaceTrackInterval(float interval, float longInterval)
        {
            m_FaceTrackInterval = interval;
            m_FaceTrackIntervalLong = longInterval;
        }
        
        private void SetCamImageSize(int width, int height)
        {
            FaceDetectTool.Instance.SetImageSize(width, height, 128, false);
            ARImageProcessingTool.Instance.ReleaseAllRT();
            ARImageProcessingTool.Instance.SetImageSize(width, height);
            if (!m_ForbidAutoColor)
                AutoColorTool.Instance.SetTexture(m_CamTexture, width, height);
        }

        public void SwitchCamera(bool isFront)
        {
            WebCamHelper.Instance.Stop();
            bool canGetCamera = WebCamHelper.Instance.SwitchCamera(m_TargetWidth, m_TargetHeight);
            if (canGetCamera)
            {
                m_CamTexture = WebCamHelper.Instance.webCamTexture;
                Vector2Int size = WebCamHelper.Instance.GetCameraSize();
                X3Debug.LogFormat("Camera Resolution:{0}, {1}", size[0], size[1]);
                SetCamImageSize(size[0], size[1]);
                //SetImage(FrontImage, BackImage);
            }
            m_isChangeDir = true;
        }
        public void SetImage(RawImage frontImage, RawImage backImage)
        {
            FrontImage = frontImage;
            BackImage = backImage;
            if (!m_IsShowBack && !m_HumanFront)
            {
                BackImage.texture = ARImageProcessingTool.Instance.GetHumanImage();
            }
            else
            {
                BackImage.texture = ARImageProcessingTool.Instance.GetFullImage();
            }
            FrontImage.texture = ARImageProcessingTool.Instance.GetHumanImage();
        }
        public void SetBeautyDelta(float sigma, float eye, float face)
        {
            ARImageProcessingTool.Instance.SetBeautyDelta(Mathf.Max(1e-4f, sigma), eye, face);
        }
        public void SetHumanFront(bool isFront)
        {
            m_HumanFront = isFront;
            FrontImage.gameObject.SetActive(isFront);
            if (!m_IsShowBack && !m_HumanFront)
            {
                BackImage.texture = ARImageProcessingTool.Instance.GetHumanImage();
                BackImage.gameObject.SetActive(true);
            }
            else
            {
                BackImage.texture = ARImageProcessingTool.Instance.GetFullImage();
                BackImage.gameObject.SetActive(m_IsShowBack);
            }
        }

        public void SetShowBackImage(bool isShow)
        {
            m_IsShowBack = isShow;
            if (!m_IsShowBack && !m_HumanFront)
            {
                BackImage.texture = ARImageProcessingTool.Instance.GetHumanImage();
                BackImage.gameObject.SetActive(true);
            }
            else
            {
                BackImage.texture = ARImageProcessingTool.Instance.GetFullImage();
                BackImage.gameObject.SetActive(m_IsShowBack);
            }
        }

        public void SetLUTTexture(Texture2D texture)
        {
            ARImageProcessingTool.Instance.LUTTexture = texture;
        }

        private unsafe void UpdateImage()
        {
            if (m_IsPause)
                return;
            if (m_isChangeDir)
            {
                SetImage(FrontImage, BackImage);
                EventMgr.Dispatch("OnARPhotoCamChanged");
                m_isChangeDir = false;
            }

            if (FrontImage == null || BackImage == null)
            {
                return;
            }

            if (m_CamTexture == null)
                return;

            m_FramePassedFromLastCheck = m_FramePassedFromLastCheck + Time.deltaTime;

            if (m_IsDetectAsync)
            {
                if (m_Task == null || m_Task.Status == TaskStatus.RanToCompletion)
                {
                    m_Task = Task.Run(() =>
                    {
                        if (m_CamTexture == null)
                            return;
# if UNITY_IOS          
                        m_CamTexture.Lock();
# endif
                        IntPtr colorPtr = m_CamTexture.GetRawTextureData();
                        byte* buffer = (byte*)colorPtr.ToPointer();
                        if (buffer == null)
                        {
                            X3Debug.Log("ARPhoto ColorPtr is null");
#if UNITY_IOS
                            m_CamTexture.Unlock();
#endif
                            return;
                        }
                            
                        if (m_DoFaceDetect)
                            m_FaceNum = FaceDetectTool.Instance.DoFaceDetectWithPtr(colorPtr,
                                m_FramePassedFromLastCheck >= m_CurFaceTrackInterval);
                        m_FramePassedFromLastCheck = m_FramePassedFromLastCheck % m_CurFaceTrackInterval;
#if UNITY_IOS
                        m_CamTexture.Unlock();
#endif
                    });
                }
            }
            else
            {
# if UNITY_IOS
                m_CamTexture.Lock();
# endif
                IntPtr colorPtr = m_CamTexture.GetRawTextureData();
                byte* buffer = (byte*)colorPtr.ToPointer();
                if (buffer == null)
                {
                    X3Debug.Log("ARPhoto ColorPtr is null");
#if UNITY_IOS
                    m_CamTexture.Unlock();
#endif
                    return;
                }
                if(m_DoFaceDetect)
                    m_FaceNum = FaceDetectTool.Instance.DoFaceDetectWithPtr(colorPtr, m_FramePassedFromLastCheck >= m_CurFaceTrackInterval);
                m_FramePassedFromLastCheck = m_FramePassedFromLastCheck % m_CurFaceTrackInterval;
#if UNITY_IOS
                m_CamTexture.Unlock();
#endif
            }
            int num = m_FaceNum;
            
            if (num > 0)
            {
                float[] landMarks = FaceDetectTool.Instance.GetLandMarks();
                float[] retpoints = FaceDetectTool.Instance.GetRetPoint();
                Texture2D texture = FaceDetectTool.Instance.GetDetectAlpha();
                ARImageProcessingTool.Instance.BeautyImage(landMarks, retpoints, texture, m_CamTexture, num, (ARImageProcessingTool.FixGammaMode)m_FixGammaMode);
                if(m_IsShowBack)
                    ARImageProcessingTool.Instance.UpdateFullImage();
                if (m_HumanFront || (!m_IsShowBack && !m_HumanFront))
                    ARImageProcessingTool.Instance.UpdateHumanImage();
                if (m_HumanFront && !FrontImage.gameObject.activeSelf)
                    FrontImage.gameObject.SetActive(true);
                if ((m_IsShowBack || !m_HumanFront) && !BackImage.gameObject.activeSelf)
                    BackImage.gameObject.SetActive(true);
                if (m_CurFaceTrackInterval != m_FaceTrackIntervalLong)
                {
                    m_CurFaceTrackInterval = m_FaceTrackIntervalLong;
                    m_FramePassedFromLastCheck = 0;
                }
            }   
            else
            {
                if (FrontImage.gameObject.activeSelf)
                    FrontImage.gameObject.SetActive(false);
                if (m_IsShowBack)
                {
                    ARImageProcessingTool.Instance.UpdateBaseImage(m_CamTexture, (ARImageProcessingTool.FixGammaMode)m_FixGammaMode);
                }
                else if(BackImage.gameObject.activeSelf)
                    BackImage.gameObject.SetActive(false);

                if (m_CurFaceTrackInterval != m_FaceTrackInterval)
                {
                    m_CurFaceTrackInterval = m_FaceTrackInterval;
                    m_FramePassedFromLastCheck = 0;
                }
            }
        }
        
       

        void Start()
        {
            /*
            if (IsTest)
            {
                PrepareARPhoto(true);
                BackImage.texture = ARImageProcessingTool.Instance.GetFullImage();
                FrontImage.texture = ARImageProcessingTool.Instance.GetHumanImage();
                ARImageProcessingTool.Instance.LUTTexture = LUTTexture;
            }
            */
        }

        void Update()
        {
            UpdateImage();
        }
        
        protected override void Init()
        {
            base.Init();
        }

        public void Pause()
        {
            if (!m_IsPause)
            {
                m_IsPause = true;
                WebCamHelper.Instance.Pause();
            }
        }

        public void Restart()
        {
            if (m_IsPause)
            {
                m_IsPause = false;
                WebCamHelper.Instance.Play();
            }
        }

        protected override void UnInit()
        {
            if (m_Task != null)
            {
                m_Task.Wait();
                m_Task.Dispose();
            }
            FaceDetectTool.DestroyInstance();
            ARImageProcessingTool.DestroyInstance();
            WebCamHelper.Instance.Stop();
            WebCamHelper.DestroyInstance();
            if (!m_ForbidAutoColor)
                AutoColorTool.DestroyInstance();
        }
        public void EndARPhoto()
        {
            DestroyInstance();
        }
        public Color GetLightColor()
        {
            if (!m_ForbidAutoColor)
                m_Color = AutoColorTool.Instance.GetAutoColor();
            return m_Color;
        }
        
        public float GetLightIntensity()
        {
            return m_Brightness;
        }

        public void CheckLightColor()
        {
            if (!m_ForbidAutoColor)
                AutoColorTool.Instance.DoColorDetectionAsync();
        }
        
        public void UpdateLightColor(CharacterLightingRuntimeData lightAsset, float intensity, float maxColor)
        {
            if (!m_ForbidAutoColor)
                m_Color = AutoColorTool.Instance.GetAutoColor();
            lightAsset.mainLightColor.r = Mathf.Min(intensity * m_Color.r, maxColor);
            lightAsset.mainLightColor.g = Mathf.Min(intensity * m_Color.g, maxColor);
            lightAsset.mainLightColor.b = Mathf.Min(intensity * m_Color.b, maxColor);
        }

        public void SetLightColor(CharacterLightingRuntimeData lightAsset, float r, float g, float b)
        {
            lightAsset.mainLightColor.r = r;
            lightAsset.mainLightColor.g = g;
            lightAsset.mainLightColor.b = b;
        }
    }
}