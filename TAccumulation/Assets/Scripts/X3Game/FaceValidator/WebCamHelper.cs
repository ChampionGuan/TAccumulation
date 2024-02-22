using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;
using System.Runtime.InteropServices;
using PapeGames.X3UI;
using UnityEngine.UI;

#if UNITY_ANDROID
using UnityEngine.Android;
#endif

namespace X3Game
{
    [StructLayout(LayoutKind.Explicit)]
    public struct Color32Array
    {
        [FieldOffset(0)]
        public byte[] byteArray;

        [FieldOffset(0)]
        public Color32[] colors;
    }

    public struct PicBytes
    {
        public byte[] Data;
    }

    [XLua.LuaCallCSharp]
    [MonoSingletonAttr(true, "WebCamHelper")]
    public class WebCamHelper : MonoSingleton<WebCamHelper>
    {
        public WebCamTexture webCamTexture => m_webcamTexture;
        public bool isReady => webCamTexture != null && m_waitingTime == 0;
        WebCamTexture m_webcamTexture;
        private RawImage m_rawImg;
        private bool m_autoBind;
        bool m_waitingAuthorization = false;
        bool m_waitingPermission= false;

        string m_frontCam, m_backCam;
        Resolution m_pFrontResolution, m_pBackResolution;
        private int m_waitingTime = 2;

        bool m_isFront;
        bool m_fullScreen;
        static float s_ColorFixValue = 1/2.2f;

        public static float s_threshold = 0.5f;
        public static int s_MaxSize = 2000;
        protected override void Init()
        {
        }

        protected override void UnInit()
        {
            Stop();
            if (m_webcamTexture)
            {
                Destroy(m_webcamTexture);   
                m_webcamTexture = null;
            }
        }
        public bool HasAuthorization()
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            return Permission.HasUserAuthorizedPermission(Permission.Camera);
#elif UNITY_IOS
            return Application.HasUserAuthorization(UserAuthorization.WebCam);
#endif
            return true;
        }

        public bool CheckCamera()
        {
#if UNITY_EDITOR
            return true;
#endif
            return webCamTexture != null;
        }
        public void RequestAuthorization(Action onComplete)
        {
#if UNITY_ANDROID && !UNITY_EDITOR
            Permission.RequestUserPermission(Permission.Camera);
            
            if(onComplete != null)
            {
                m_waitingAuthorization = true;
                StartCoroutine(GettingAuthorization(onComplete));
            }
#elif UNITY_IOS
            StartCoroutine(GettingAuthorization(onComplete));
#else
            onComplete?.Invoke();
#endif

        }

        public bool GetWebCamTexture(float width, float height, bool isFront = true, bool fullScreen = false)
        {
            m_waitingTime = 2;
            if (m_webcamTexture != null)
            {
                m_webcamTexture.Stop();

                Destroy(m_webcamTexture);

                m_webcamTexture = null;
            }

            m_isFront = isFront;
            m_fullScreen = fullScreen;

            if (!HasAuthorization() || null == WebCamTexture.devices || WebCamTexture.devices.Length < 1)
            {
                return false;
            }

#if !UNITY_EDITOR
            if (m_frontCam == null || m_backCam == null)
            {
                WebCamDevice? front = null;
                WebCamDevice? back = null;
                var minFrontD = new Vector4(0, float.MinValue, float.MinValue, float.MinValue);
                var minBackD = new Vector4(0, float.MinValue, float.MinValue, float.MinValue);
                Resolution frontPerfectR = new Resolution();
                Resolution backPerfectR = new Resolution();
                foreach (var v in WebCamTexture.devices)
                {
                    if (GetPerfectResolution(v.availableResolutions, height, width, out var perfR))
                    {
                        var minD = GetResolutionDelta(perfR,height, width);
                        if (v.isFrontFacing && (front == null || front?.kind == WebCamKind.Telephoto || CompareDelta(minD, minFrontD)))
                        {
                            front = v;
                            frontPerfectR = perfR;
                            minFrontD = minD;
                        }
                        else if (!v.isFrontFacing && (back == null|| back?.kind == WebCamKind.Telephoto|| CompareDelta(minD, minBackD)))
                        {
                            back = v;
                            backPerfectR = perfR;
                            minBackD = minD;
                        }
                    }
                }
                
                
                if (front != null)
                {
                    m_frontCam = front.Value.name;
                    m_pFrontResolution = frontPerfectR;
                }

                if (back != null)
                {
                    m_backCam = back.Value.name;
                    m_pBackResolution = backPerfectR;
                }
            }

            if (isFront && !string.IsNullOrEmpty(m_frontCam))
            {
                m_webcamTexture =
                    new WebCamTexture(m_frontCam, m_pFrontResolution.width, m_pFrontResolution.height, 60);
                m_webcamTexture.Play();
                return true;
            }

            if (!isFront && !string.IsNullOrEmpty(m_backCam))
            {
                m_webcamTexture = new WebCamTexture(m_backCam, m_pBackResolution.width, m_pBackResolution.height, 60);
                m_webcamTexture.Play();
                return true;
            }
#else
            m_webcamTexture = new WebCamTexture();
            m_frontCam = m_webcamTexture.deviceName;
            m_backCam = m_webcamTexture.deviceName;
            m_pFrontResolution = new Resolution();
            m_pBackResolution = new Resolution();
            m_webcamTexture.Play();
            return true;
#endif
            return false;
        }

        bool CompareDelta(Vector4 deltaA, Vector4 deltaB)
        {
            if (deltaA.x < s_threshold || deltaB.x < s_threshold)
            {
                if (deltaA.x > deltaB.x)
                {
                    return true;
                }
            }
            else
            {
                var mA = Mathf.Max(deltaA.z, deltaA.w);
                var mB = Mathf.Max(deltaB.z, deltaB.w);
                if (mA > s_MaxSize || mB > s_MaxSize)
                {
                    if (mA < mB)
                    {
                        return true;
                    }
                }
                else
                {
                    // if (m_fullScreen)
                    // {
                    //     if ( deltaB.y < 0 && deltaA.y > 0)
                    //     {
                    //         return true;
                    //     }
                    //     if (deltaB.y * deltaA.y > 0 && (Mathf.Abs(deltaA.y) < Mathf.Abs(deltaB.y) ||
                    //                                     Mathf.Approximately(Mathf.Abs(deltaA.y), Mathf.Abs(deltaB.y)) &&
                    //                                     deltaA.x > deltaB.x))
                    //     {
                    //         return true;
                    //     }
                    // }
                    // else
                    // {
                    if (Mathf.Abs(deltaA.y) < Mathf.Abs(deltaB.y) ||
                        Mathf.Approximately(Mathf.Abs(deltaA.y), Mathf.Abs(deltaB.y)) && deltaA.x > deltaB.x)
                    {
                        return true;
                    }
                    //}
                }
            }

            return false;
        }

        bool GetPerfectResolution(Resolution[] resolutions, float width, float height,  out Resolution perfectR)
        {
            Vector4 minD = new Vector4(0, float.MinValue, float.MinValue, float.MinValue);
            if (resolutions == null || resolutions.Length==0)
            {
                perfectR = new Resolution();
                return false;
            }
            perfectR = resolutions[0];

            foreach (Resolution r in resolutions)
            {
                var d = GetResolutionDelta(r, width, height);

                if (CompareDelta(d, minD))
                {
                    minD = d;
                    perfectR = r;
                }
            }

            return true;
        }

        Vector4 GetResolutionDelta(Resolution r, float width, float height)
        {
            var result = new Vector4(0,0, r.width, r.height);
            result.x = m_fullScreen ?  Mathf.Pow(Mathf.Min(r.width / width, r.height / height), 2) :
                Mathf.Pow(Mathf.Max(r.width / width, r.height / height), 2);
            result.y = r.height * width / (r.width * height) - 1;
        
            return result;
        }

        public void Play(bool needReset = false)
        {
            m_webcamTexture?.Play();
            if (needReset)
            {
                m_waitingTime = 2;
            }
        }

        public void Stop()
        {
            m_webcamTexture?.Stop();
        }

        public void Pause()
        {
            m_webcamTexture?.Pause();
        }

        public Texture2D CaptureCurTexture()
        {
            if (m_webcamTexture != null && m_webcamTexture.isPlaying)
            {
                Texture2D tex2d = new Texture2D(webCamTexture.width, webCamTexture.height);
                tex2d.SetPixels(webCamTexture.GetPixels());
                tex2d.Apply();
                return tex2d;
            }
            return null;
        }
        
        public bool SwitchCamera(float width, float height)
        {
            m_waitingTime = 2;
            if (m_webcamTexture == null)
                return false;

            bool success = false;

            if (!m_isFront && !string.IsNullOrEmpty(m_frontCam))
            {
                m_webcamTexture.Stop();
                m_webcamTexture.deviceName = m_frontCam;
                m_webcamTexture.requestedWidth = m_pFrontResolution.width;
                m_webcamTexture.requestedHeight = m_pFrontResolution.height;
                m_webcamTexture.Play();

                m_isFront = !m_isFront;
                success = true;
            }

            if (!success && m_isFront && !string.IsNullOrEmpty(m_backCam))
            {
                m_webcamTexture.Stop();
                m_webcamTexture.deviceName = m_backCam;
                m_webcamTexture.requestedWidth = m_pBackResolution.width;
                m_webcamTexture.requestedHeight = m_pBackResolution.height;
                m_webcamTexture.Play();

                m_isFront = !m_isFront;
                success = true;
            }

            if (success && m_rawImg != null)
            {
                AdjustRawImg(m_rawImg.rectTransform, width, height);
            }

            return success;
        }

        public void SetCameraRawImage(RawImage rawImage, float width, float height, bool needBind = false)
        {
            if(m_webcamTexture != null)
            {
                m_rawImg = rawImage;
                m_autoBind = needBind;
                if (m_autoBind)
                {
                    rawImage.texture = m_webcamTexture;
                    rawImage.enabled = true;
                }

                AdjustRawImg(rawImage.rectTransform, width, height);
            }
        }

        void AdjustRawImg(RectTransform rectTf, float width, float height)
        {
#if UNITY_EDITOR
            rectTf.localRotation = Quaternion.Euler(0, 180, 0);
            ResetSize(rectTf, width, height);
#elif UNITY_IOS
            rectTf.localRotation = Quaternion.Euler(0, m_isFront ? 0 : 180, -m_webcamTexture.videoRotationAngle);
            ResetSize(rectTf, height, width);
#else
            rectTf.localRotation = Quaternion.Euler(0, m_isFront ? 180 : 0, -m_webcamTexture.videoRotationAngle);
            ResetSize(rectTf, height, width);
#endif
            for (int i = 0; i < rectTf.childCount; i++)
            {
                rectTf.GetChild(i).rotation = Quaternion.Euler(0,0,0);
            }   
        }

        public Vector2Int GetCameraSize()
        {
#if UNITY_EDITOR
            int camWidth = m_webcamTexture.width;
            int camHeight = m_webcamTexture.height;
#else
            int camWidth = m_isFront ? m_pFrontResolution.width : m_pBackResolution.width;
            int camHeight = m_isFront ? m_pFrontResolution.height : m_pBackResolution.height;
#endif

            return new Vector2Int(camWidth, camHeight);
        }

        void ResetSize(RectTransform rectTf,  float width, float height)
        {
#if UNITY_EDITOR
            int camWidth = m_webcamTexture.width;
            int camHeight = m_webcamTexture.height;
#else
            int camWidth = m_isFront ? m_pFrontResolution.width : m_pBackResolution.width;
            int camHeight = m_isFront ? m_pFrontResolution.height : m_pBackResolution.height;
#endif
            float showHeight, showWidth;

            if ((height / camHeight < width / camWidth && m_fullScreen) 
                || (height / camHeight > width / camWidth && !m_fullScreen))
            {
                showHeight = camHeight * width/camWidth;
                showWidth = width;
            }
            else
            {
                showHeight = height;
                showWidth = camWidth * height/camHeight;
            }

            rectTf.sizeDelta = new Vector2(showWidth, showHeight);
            X3Debug.Log($"CameraSize:{camWidth}-{camHeight};AimSize:{width}-{height};Result:{showWidth}-{showHeight}");
        }

#if UNITY_ANDROID && !UNITY_EDITOR
        private IEnumerator GettingAuthorization(Action onComplete)
        {
            yield return new WaitWhile(CheckWaiting);
            onComplete?.Invoke();
        }

        private bool CheckWaiting()
        {
            return m_waitingAuthorization;
        }
#elif UNITY_IOS
         private IEnumerator GettingAuthorization(Action onComplete)
         {
             yield return Application.RequestUserAuthorization(UserAuthorization.WebCam);
             onComplete?.Invoke();
         }
#endif

        private void LateUpdate()
        {
            if (m_webcamTexture && m_webcamTexture.didUpdateThisFrame && m_waitingTime > 0)
            {
                m_waitingTime--;
                if (isReady && m_rawImg && m_autoBind)
                {
                    m_rawImg.texture = webCamTexture;
                }
            }
        }

        private void OnApplicationFocus(bool focus)
        {
            if (m_rawImg && m_autoBind)
            {
                m_rawImg.texture = Texture2D.blackTexture;
            }
            m_waitingTime = 2;
            if(m_waitingAuthorization && focus)
            {
                m_waitingAuthorization = false;
            }
        }
    }
}

