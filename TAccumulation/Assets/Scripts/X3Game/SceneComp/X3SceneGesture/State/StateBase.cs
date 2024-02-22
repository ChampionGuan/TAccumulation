using System;
using Cinemachine;
using UnityEngine;
using X3Battle;

namespace X3Game.SceneGesture
{
    public enum StateType
    {
        Static,
        AnimCtrl,
    }

    [System.Serializable]
    public struct DOFSettings
    {
        [Header("近平面开始")]
        public float NearStart;
        [Header("近平面结束")]
        public float NearEnd;
        [Header("远平面开始")]
        public float FarStart;
        [Header("远平面结束")]
        public float FarEnd;
        [Header("天空深度")]
        public float SkyDepth;
        [Header("模糊缩放")]
        public float COCScale;
        [Header("近景模糊衰减强度")]
        public float NearCOCGamma;
        [Header("远景模糊衰减强度")]
        public float FarCOCOffset;

        public DOFSettings(float nearStart, float nearEnd, float farStart, float farEnd, float skyDepth, float cocScale,
            float nearCOCGamma, float farCOCOffset)
        {
            NearStart = nearStart;
            NearEnd = nearEnd;
            FarStart = farStart;
            FarEnd = farEnd;
            SkyDepth = skyDepth;
            COCScale = cocScale;
            NearCOCGamma = nearCOCGamma;
            FarCOCOffset = farCOCOffset;
        }

        public static DOFSettings Lerp(DOFSettings a, DOFSettings b, float w)
        {
            var setting = new DOFSettings();
            setting.NearStart = Mathf.Lerp(a.NearStart, b.NearStart, w);
            setting.NearEnd = Mathf.Lerp(a.NearEnd, b.NearEnd, w);
            setting.FarStart = Mathf.Lerp(a.FarStart, b.FarStart, w);
            setting.FarEnd = Mathf.Lerp(a.FarEnd, b.FarEnd, w);
            setting.SkyDepth = Mathf.Lerp(a.SkyDepth, b.SkyDepth, w);
            setting.COCScale = Mathf.Lerp(a.COCScale, b.COCScale, w);
            setting.NearCOCGamma = Mathf.Lerp(a.NearCOCGamma, b.NearCOCGamma, w);
            setting.FarCOCOffset = Mathf.Lerp(a.FarCOCOffset, b.FarCOCOffset, w);
            return setting;
        }
    }

    [Serializable]
    public abstract class StateBase : MonoBehaviour, IDragEventHandler, IPinchEventHandler
    {
        [SerializeField] protected string m_Key;
        [SerializeField] protected Vector3 m_TargetInitPos = Vector3.zero;
        [SerializeField] protected Quaternion m_TargetInitRot = Quaternion.identity;
        [SerializeField] protected bool m_TargetControllable = true;

        #region ppv parameter

        [SerializeField] protected bool m_DOFEnable = true;
        [SerializeField] protected DOFSettings m_DOFSettings = new DOFSettings(0.1f, 0.998f, 20, 100, 1000, 1, 1, 2);

        #endregion
        
        public CinemachineBlendDefinition.Style BlendType { get; set; } = CinemachineBlendDefinition.Style.EaseInOut;
        public AnimationCurve CustomCurve { get; set; } = null;
        
        public bool IsChanging { get; protected set; } = false;
        public bool IsBlending { get; protected set; } = false;

        public string Key
        {
            get => m_Key;
            set => m_Key = value;
        }

        public abstract StateType Type { get; }
        public Vector3 TargetInitPos => m_TargetInitPos;
        public Quaternion TargetInitRot => m_TargetInitRot;
        public bool TargetControllable => m_TargetControllable;

        public bool DOFEnable => m_DOFEnable;
        public DOFSettings DOFSettings => m_DOFSettings;

        protected CinemachineVirtualCameraBase m_camera;

        protected CinemachineVirtualCameraBase camera
        {
            get
            {
                if (m_camera == null)
                    m_camera = GetComponent<CinemachineVirtualCameraBase>();

                return m_camera;
            }
        }

        public virtual float InitCamPos(float duration = 0)
        {
            return 0;
        }
        
        public virtual void SetTimeAndWeight(float time, float weight = 0)
        {
        }

        public virtual void OnDragBegin(Vector2 dragDelta)
        {
            
        }
        public virtual void OnDragUpdate(Vector2 dragDelta, Vector2 touchPos)
        {
        }

        public virtual void OnDragEnd(Vector2 touchPos)
        {
        }

        public virtual void OnPinchBegin()
        {
        }
        
        public virtual void OnPinchUpdate(float pinchDelta)
        {
        }

        public virtual void OnPinchEnd(float pinchDelta)
        {
        }

        public virtual void OnUpdate(float dt)
        {
            
        }

        public virtual void Enable(bool needInit = true)
        {
            if (needInit)
                InitCamPos();
            gameObject.SetActive(true);
        }

        public virtual void Disable()
        {
            gameObject.SetActive(false);
        }
        
        
        public void SetCameraPriority(int priority)
        {
            if (camera)
            {
                camera.Priority = priority;
            }
        }
    }
}