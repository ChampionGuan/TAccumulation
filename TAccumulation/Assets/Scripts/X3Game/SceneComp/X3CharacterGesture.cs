using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using PapeGames.X3;
using Cinemachine;
using DG.Tweening;
using PapeGames.Rendering;
using UnityEngine.Serialization;
using X3Game;
using Tweener = PapeGames.X3.Tweener;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    [ExecuteInEditMode]
    public class X3CharacterGesture : MonoBehaviour
    {
        [SerializeField]
        protected CamPoint m_FarCamPoint;
        [SerializeField]
        protected Transform m_FarRefTF;

        [SerializeField]
        protected CamPoint m_MiddleCamPoint;
        [SerializeField]
        protected Transform m_MiddleRefTF;

        [SerializeField]
        protected CamPoint m_NearUpCamPoint;
        [SerializeField]
        protected Transform m_NearUpRefTF;

        [SerializeField]
        protected CamPoint m_NearDownCamPoint;
        [SerializeField]
        protected Transform m_NearDownRefTF;

        [SerializeField] private AnimationCurve m_MToNCurve = AnimationCurve.Linear(0, 0, 1, 1);

        [SerializeField]
        protected Vector2 m_DragCoeffient = Vector2.one;

        [SerializeField]
        protected float m_PinchCoeffient = 1.0f;

        [SerializeField]
        protected float m_DragDamp = 0.1f;

        [SerializeField]
        protected float m_PinchDamp = 0.5f;

        [SerializeField]
        protected float m_MoveInSpeed = 5.0f;
        [SerializeField]
        protected Vector2 m_MoveInDuration = Vector2.zero;
        [SerializeField]
        protected EasingFunction.Ease m_MoveInEase = EasingFunction.Ease.EaseInSine;
        [SerializeField]
        protected AnimationCurve m_MoveInCurve = new AnimationCurve();
        [SerializeField]
        protected AnimationCurve m_MoveInFOVCurve = new AnimationCurve();

        [SerializeField]
        protected float m_MoveOutSpeed = 5.0f;
        [SerializeField]
        protected Vector2 m_MoveOutDuration = Vector2.zero;
        [SerializeField]
        protected EasingFunction.Ease m_MoveOutEase = EasingFunction.Ease.EaseInSine;
        [SerializeField]
        protected AnimationCurve m_MoveOutCurve = new AnimationCurve();
        [FormerlySerializedAs("m_MoveOutFOVCurve")]
        [SerializeField]
        protected AnimationCurve m_MoveOutScreenScale = new AnimationCurve();
        //MoveOutFOV曲线，考虑换成角色相机内大小

        [SerializeField]
        protected CinemachineVirtualCamera m_Cam;

        [SerializeField]
        protected Transform m_Target;

        [SerializeField] 
        protected Transform m_PivotTF;

        private float m_minMoveOutTime = 0.5f;
        private Transform pivotTF
        {
            get
            {
                if (m_Target && s_targetPivots.ContainsKey(m_Target) && s_targetPivots[m_Target] != null)
                    return s_targetPivots[m_Target];

                return m_Target;
            }
        }
        
        public bool Controllable { set; get; }

        #region DOF
        [SerializeField] private bool m_WithDOF = true;
        public bool WithDOF
        {
            set
            {
                if (m_WithDOF != value)
                {
                    m_WithDOF = value;
                    if (m_WithDOF)
                        ApplyDOF(m_ZProgress);
                    else
                        DisableDOF();
                }
            }
            get => m_WithDOF;
        }

        public DOFSettings m_NearDOFInfo = new DOFSettings(0.1f, 0.998f, 20, 30, 1000, 1, 1, 2);
        public DOFSettings m_FarDOFInfo = new DOFSettings(0.1f, 0.998f, 20, 100, 1000, 1, 1, 2);

        [SerializeField] private AnimationCurve m_DOFCurve = AnimationCurve.Linear(0, 0, 1, 1);
        public static PostProcessVolume PPV { set; get; }
        private static int s_DOFRefCount = 0;
        #endregion

        private CamPoint m_OriginCamPoint;
        private Vector3 m_OriginTargetRotation;
        private Vector3 m_OriginTargetPosition;
        private bool m_OriginCamPointInited = false;
        private bool m_OriginTargetRotationInited = false;
        private bool m_OriginTargetPositionInited = false;
        private Vector3 m_TargetRotationPivot;
        private Vector2 m_PrevTouch1Pos;
        private Vector2 m_Touch1Pos;
        private Vector2 m_PrevTouch2Pos;
        private Vector2 m_Touch2Pos;
        private Vector2 m_DragDelta;
        private float m_PinchDelta;
        private bool m_IsDragging = false;
        private bool m_IsPinching = false;
        private float m_PinchNearPlaneTargetY;
        private Coroutine m_DragInertial;
        private Coroutine m_PinchInertial;
        private bool m_IsMoveIn = false;
        private bool m_IsMoveOut = false;

        private bool m_IsX3AnimatorRotate = false;

        private IX3CharacterWave m_Wave = null;
        
        private static Dictionary<Transform, Transform> s_targetPivots = new Dictionary<Transform, Transform>();
        private static Dictionary<int, int> s_targets = new Dictionary<int, int>();

        #region MonoEvents
        private void Start()
        {
            m_PinchNearPlaneTargetY = m_NearUpCamPoint.Position.y;
            m_OriginCamPoint = GetCamPoint(m_Cam);
            m_OriginCamPointInited = true;
            if (m_Target != null)
            {
                if (!m_OriginTargetRotationInited)
                {
                    m_OriginTargetRotation = GetTargetLocalEulerAngles();
                }
                
                if (!m_OriginTargetPositionInited)
                {
                    m_OriginTargetPosition = GetTargetLocalPosition();
                    m_OriginTargetPositionInited = true;
                }
            }

            if (Application.isPlaying)
            {
                if (m_FarRefTF != null)
                {
                    m_FarCamPoint.Position = m_FarRefTF.position;
                    m_FarCamPoint.Rotation = m_FarRefTF.eulerAngles;
                }
                if (m_MiddleRefTF != null)
                {
                    m_MiddleCamPoint.Position = m_MiddleRefTF.position;
                    m_MiddleCamPoint.Rotation = m_MiddleRefTF.eulerAngles;
                }
                if (m_NearUpRefTF != null)
                {
                    m_NearUpCamPoint.Position = m_NearUpRefTF.position;
                    m_NearUpCamPoint.Rotation = m_NearUpRefTF.eulerAngles;
                }
                if (m_NearDownRefTF != null)
                {
                    m_NearDownCamPoint.Position = m_NearDownRefTF.position;
                    m_NearDownCamPoint.Rotation = m_NearDownRefTF.eulerAngles;
                }
                GetZProgress(out m_ZProgress, out float middleP);
                if (m_WithDOF)
                    ApplyDOF(m_ZProgress);
            }
        }

        private void Awake()
        {
            RegisterTarget();
        }

        private void Update()
        {
            Detect();
        }

        private void OnEnable()
        {
            if (m_WithDOF)
            {
                if (s_DelayDisableDofCoroutine != null)
                {
                    CoroutineProxy.StopCoroutine(s_DelayDisableDofCoroutine);
                    s_DelayDisableDofCoroutine = null;
                }
                s_DOFRefCount++;
                GetZProgress(out m_ZProgress, out float middleP);
                ApplyDOF(m_ZProgress);
            }
        }

        private static Coroutine s_DelayDisableDofCoroutine = null;
        private void OnDisable()
        {
            if (m_WithDOF)
            {
                s_DOFRefCount--;
                if (s_DOFRefCount <= 0)
                {
                    if (s_DelayDisableDofCoroutine != null)
                        CoroutineProxy.StopCoroutine(s_DelayDisableDofCoroutine);
                    // s_DelayDisableDofCoroutine = CoroutineProxy.StartCoroutine(DelayDisableDOF());
                    
                }
                DisableDOF();
            }
        }

        private void OnDestroy()
        {
            UnregisterTarget();
            m_Target = null;
            m_Cam = null;
        }
        #endregion

        void RegisterTarget()
        {
            if (m_Target == null)
                return;
            int insID = m_Target.GetInstanceID();
            if (s_targets.TryGetValue(insID, out int refCnt))
            {
                s_targets[insID] = refCnt + 1;
            }
            else
            {
                s_targets[insID] = 1;
            }

            if (m_PivotTF)
            {
                s_targetPivots[m_Target] = m_PivotTF;
            }
            else
            {
                if (s_targetPivots.ContainsKey(m_Target))
                {
                    s_targetPivots.Remove(m_Target);
                }
            }
            
        }

        void UnregisterTarget()
        {
            if (m_Target == null)
                return;
            
            int insID = m_Target.GetInstanceID();
            if (s_targets.TryGetValue(insID, out int refCnt))
            {
                if (refCnt > 1) 
                    s_targets[insID] = refCnt - 1;
                else
                {
                    s_targets.Remove(insID);
                    s_targetPivots.Remove(m_Target);
                }
            }
            else
            {
                s_targetPivots.Remove(m_Target);
            }
        }

        public void ResetPinchNearPlaneTargetY()
        {
            float zP, zMiddleP = 0;
            if (Mathf.Abs(m_MiddleCamPoint.Position.z - m_FarCamPoint.Position.z) > 0.001f)
                GetCamZProgress(out zP, out zMiddleP);
            else
                GetCamFOVProgress(out zP, out zMiddleP);
            var pos = m_Cam.transform.position;
            float p = (zP - zMiddleP) / (1.0f - zMiddleP);
            var minY = Mathf.Lerp(m_MiddleCamPoint.Position.y, m_NearDownCamPoint.Position.y, p);
            var maxY = Mathf.Lerp(m_MiddleCamPoint.Position.y, m_NearUpCamPoint.Position.y, p);
            m_PinchNearPlaneTargetY = Mathf.Lerp(m_NearDownCamPoint.Position.y, m_NearUpCamPoint.Position.y, Mathf.Abs(pos.y - minY) / Mathf.Abs(maxY - minY));
        }

        public void SetCamera(CinemachineVirtualCamera cam)
        {
            if (cam != m_Cam)
            {
                m_Cam = cam;
                m_OriginCamPoint = GetCamPoint(cam);
                m_OriginCamPointInited = true;
            }
        }

        public CinemachineVirtualCamera GetCamera()
        {
            return m_Cam;
        }

        public void RefreshCamPoint(Vector3 pos, Vector3 rot)
        {
            m_OriginCamPoint = GetCamPoint(m_Cam);
            m_OriginCamPointInited = true;
            m_OriginCamPoint.Position = pos;
            m_OriginCamPoint.Rotation = rot;
        }

        public void SetTarget(Transform tf, IX3CharacterWave wave = null)
        {
            if (tf != m_Target)
            {
                UnregisterTarget();
                m_Target = tf;
                m_OriginTargetRotation = GetTargetLocalEulerAngles();
                m_OriginTargetPosition = GetTargetLocalPosition();
                m_OriginTargetRotationInited = true;
                m_OriginTargetPositionInited = true;
                if (pivotTF != null)
                    InitRotationPivot();
            }

            m_Wave = wave;
        }
        
        public void SetPivotWithTransform(Transform tf)
        {
            if (m_Target != null)
            {
                s_targetPivots[m_Target] = tf;
                return;
                
                InitRotationPivot();
                var euler = GetTargetLocalEulerAngles();
                var posOffset = -m_TargetRotationPivot;
                posOffset.y = 0;
                posOffset = Quaternion.Euler(euler) * posOffset;
                SetTargetLocalPosition(posOffset + m_OriginTargetPosition);
            }
        }

        public void RefreshRotationAndPosition()
        {
            return;
            var euler = GetTargetLocalEulerAngles();
            if (pivotTF != null)
            {
                var posOffset = -m_TargetRotationPivot;
                posOffset.y = 0;
                posOffset = Quaternion.Euler(euler) * posOffset;
                SetTargetLocalPosition(posOffset + m_OriginTargetPosition);
            }
            else
            {
                SetTargetLocalPosition(m_OriginTargetPosition);
            }
        }

        private Tweener m_TransitionTargetPosTweener = null;
        private void TransitionTargetPos(Vector3 from, Vector3 to, float duration = 0.2f)
        {
            var originControllable = this.Controllable;
            this.Controllable = false;
            if (m_TransitionTargetPosTweener != null && m_TransitionTargetPosTweener.IsPlaying)
                m_TransitionTargetPosTweener.Kill(true);
            m_TransitionTargetPosTweener = Tweener.Create(duration, null, (p) =>
            {
                SetTargetLocalPosition(Vector3.Lerp(from, to, p));
            }, () =>
            {
                this.Controllable = originControllable;
                m_TransitionTargetPosTweener = null;
            }).Play();
        }

#if UNITY_EDITOR
        [ContextMenu("RefreshPivot")]
        private void RefreshPivot()
        {
            if (m_Target != null && pivotTF != null)
            {
                InitRotationPivot();
            }
        }
#endif

        private void InitRotationPivot()
        {
            if (pivotTF != null)
            {
                var localEuler = GetTargetLocalRotation().eulerAngles;
                SetTargetLocalRotation(Vector3.zero);
                m_TargetRotationPivot = m_Target.InverseTransformPoint(pivotTF.position);
                SetTargetLocalRotation(localEuler);
            }
            else
            {
                m_TargetRotationPivot = Vector3.zero;
            }
        }

        public void SetX3AnimatorRotate(bool isX3AnimatorRotate)
        {
            m_IsX3AnimatorRotate = isX3AnimatorRotate;
        }

        public bool GetX3AnimatorRotate()
        {
            return m_IsX3AnimatorRotate;
        }

        public void MoveIn(float speed = -1, bool controllable = true)
        {
            if (m_IsMoveIn || m_Cam == null || m_Target == null) return;
            if (m_ExeMoveOut != null)
            {
                StopCoroutine(m_ExeMoveOut);
                m_ExeMoveOut = null;
                m_IsMoveOut = false;
            }
            Controllable = false;
            m_ExeMoveIn = StartCoroutine(ExeMoveIn(speed, controllable));
        }

        public void MoveOut(float speed = -1, bool controllable = false)
        {
            if (m_IsMoveOut || m_Cam == null || m_Target == null) return;
            if (m_ExeMoveIn != null)
            {
                StopCoroutine(m_ExeMoveIn);
                m_ExeMoveIn = null;
                m_IsMoveIn = false;
            }
            Controllable = false;
            m_ExeMoveOut = StartCoroutine(ExeMoveOut(speed, controllable));
        }
        /// <summary>
        /// 强制重置相机到默认位置
        /// </summary>
        public void RestCameraPos(bool resetTarget = true)
        {
            if (m_ExeMoveIn != null)
                StopCoroutine(m_ExeMoveIn);
            if (m_ExeMoveOut != null)
                StopCoroutine(m_ExeMoveOut);
            if (m_OriginCamPointInited)
                ApplyCamPoint(m_OriginCamPoint);
            if (resetTarget && m_OriginTargetRotationInited)
                SetTargetLocalRotation(m_OriginTargetRotation);
        }

        Coroutine m_ExeMoveIn = null;
        IEnumerator ExeMoveIn(float speed = -1, bool controllable = true)
        {
            m_IsMoveIn = true;
            speed = speed < 0 ? m_MoveInSpeed : speed;
            float duration = Vector3.Distance(m_OriginCamPoint.Position, m_FarCamPoint.Position) / speed;
            if (duration <= 0)
            {
                ApplyCamPoint(m_FarCamPoint);
            }
            else
            {
                if (!Mathf.Approximately(m_MoveInDuration.x, 0) && !Mathf.Approximately(m_MoveInDuration.y, 0))
                    duration = Mathf.Clamp(duration, m_MoveInDuration.x, m_MoveInDuration.y);
                float time = 0;
                var easeFunc = EasingFunction.GetEasingFunction(m_MoveInEase);
                var originCamPoint = GetCamPoint(m_Cam);
                var originalDistance = Vector3.Dot((m_Target.position - originCamPoint.Position), m_Cam.transform.forward);
                var originalWidth = 2 * Mathf.Tan(0.5f * Mathf.Deg2Rad * originCamPoint.FieldOfView) * originalDistance;
                while (time < duration)
                {
                    yield return null;
                    time += Time.deltaTime;
                    float t = Mathf.Clamp01(time / duration);
                    float p = easeFunc(0, 1, t);
                    if (m_MoveInCurve != null && m_MoveInCurve.length > 0)
                        p = m_MoveInCurve.Evaluate(t);

                    Quaternion rot = Quaternion.Lerp(Quaternion.Euler(originCamPoint.Rotation), Quaternion.Euler(m_FarCamPoint.Rotation), p);
                    Vector3 pos = Vector3.Lerp(originCamPoint.Position, m_FarCamPoint.Position, p);
                    float distance = Vector3.Dot((m_Target.position - pos), m_Cam.transform.forward);
                    float fov = Mathf.Rad2Deg * Mathf.Atan(originalWidth / (2 * distance)) * 2;

                    m_Cam.m_Lens.FieldOfView = fov;
					m_Cam.transform.SetPositionAndRotation(pos, rot);
                }
            }
            m_ZProgress = 0;
            if (m_WithDOF)
                ApplyDOF(m_ZProgress);
            m_PinchNearPlaneTargetY = m_NearUpCamPoint.Position.y;
            m_IsMoveIn = false;
            m_ExeMoveIn = null;
            Controllable = controllable;
        }

        Coroutine m_ExeMoveOut = null;
        IEnumerator ExeMoveOut(float speed = -1, bool controllable = false)
        {
            m_IsMoveOut = true;
            speed = speed < 0 ? m_MoveOutSpeed : speed;
            float duration = Vector3.Distance(m_Cam.transform.position, m_OriginCamPoint.Position) / speed;
            float moveOutTime = Mathf.Max(duration, m_minMoveOutTime);
            if (duration <= 0)
            {
                ApplyCamPoint(m_OriginCamPoint);
                // SetTargetLocalRotation(m_OriginTargetRotation);
                // SetTargetLocalPosition(m_OriginTargetPosition);
                if (m_WithDOF)
                {
                    DisableDOF();
                }
            }
            
            {
                if (!Mathf.Approximately(m_MoveOutDuration.x, 0) && !Mathf.Approximately(m_MoveOutDuration.y, 0))
                    moveOutTime = Mathf.Clamp(moveOutTime, m_MoveOutDuration.x, m_MoveOutDuration.y);
                var curCamPoint = GetCamPoint(m_Cam);
                var curTargetRot = GetTargetLocalRotation();
                var curTargetPos = GetTargetLocalPosition();
                var easeFunc = EasingFunction.GetEasingFunction(m_MoveOutEase);

                var originalDistance = Vector3.Dot((m_Target.position - m_OriginCamPoint.Position), m_Cam.transform.forward);
                var originalWidth = 2 * Mathf.Tan(0.5f * Mathf.Deg2Rad * m_OriginCamPoint.FieldOfView) * originalDistance;
                var curDistance = Vector3.Dot((m_Target.position - curCamPoint.Position), m_Cam.transform.forward);
                var curWidth = 2 * Mathf.Tan(0.5f * Mathf.Deg2Rad * curCamPoint.FieldOfView) * curDistance;
                float time = 0;
                while (time < moveOutTime)
                {
                    yield return null;
                    time += Time.deltaTime;
                    float t = Mathf.Clamp01(time / moveOutTime);
                    float p = easeFunc(0, 1, t);
                    if (m_MoveOutCurve != null && m_MoveOutCurve.length > 0)
                        p = m_MoveOutCurve.Evaluate(t);
                    float w = easeFunc(0, 1, t);
                    if (m_MoveOutScreenScale != null && m_MoveOutScreenScale.length > 0)
                        w = m_MoveOutScreenScale.Evaluate(t);
                    
                    Quaternion tarRot = Quaternion.Lerp(curTargetRot, Quaternion.Euler(m_OriginTargetRotation), p);
                    var tarPos = Vector3.Lerp(curTargetPos, m_OriginTargetPosition, p);
                    SetTargetLocalRotation(tarRot.eulerAngles);
                    SetTargetLocalPosition(tarPos);
                    if (m_WithDOF && duration > 0)
                    {
                        Quaternion rot = Quaternion.Lerp(Quaternion.Euler(curCamPoint.Rotation), Quaternion.Euler(m_OriginCamPoint.Rotation), p);
                        Vector3 pos = Vector3.Lerp(curCamPoint.Position, m_OriginCamPoint.Position, p);
                        float width = Mathf.Lerp(curWidth, originalWidth, w);
                        float distance = Vector3.Dot((m_Target.position - pos), m_Cam.transform.forward);
                        float fov = Mathf.Rad2Deg * Mathf.Atan(width / (2 * distance)) * 2;

                        m_Cam.m_Lens.FieldOfView = fov;
                        m_Cam.transform.rotation = rot;
                        m_Cam.transform.position = pos;
                        
                        ApplyDOF(Mathf.Lerp(m_ZProgress, 0, p));    
                    }
                }

                m_ZProgress = 0;
                DisableDOF();
            }
            m_IsMoveOut = false;
            m_ExeMoveOut = null;
            Controllable = controllable;
        }
        void ApplyCamPoint(CamPoint camPoint)
        {
            if (m_Cam == null)
                return;
            m_Cam.transform.position = camPoint.Position;
            m_Cam.transform.rotation = Quaternion.Euler(camPoint.Rotation);
            m_Cam.m_Lens.FieldOfView = camPoint.FieldOfView;
        }

        void ApplyCamPointWithRef(CamPoint camPoint, Transform refTF)
        {
            if (m_Cam == null)
                return;
            if (refTF != null)
            {
                m_Cam.transform.position = refTF.transform.position;
                m_Cam.transform.rotation = refTF.transform.rotation;
            }
            else
            {
                m_Cam.transform.position = camPoint.Position;
                m_Cam.transform.rotation = Quaternion.Euler(camPoint.Rotation);
            }

            m_Cam.m_Lens.FieldOfView = camPoint.FieldOfView;
        }

        CamPoint GetCamPoint(CinemachineVirtualCamera cam)
        {
            var ret = new CamPoint();
            if (cam == null)
                return new CamPoint();
            ret.Position = cam.transform.position;
            ret.FieldOfView = cam.m_Lens.FieldOfView;
            ret.Rotation = cam.transform.eulerAngles;
            return ret;
        }
        public void Detect()
        {
            if (!InputComponent.IsGlobalTouchEnabled || !Controllable || !enabled || m_IsMoveIn || m_IsMoveOut) return;
#if UNITY_EDITOR
            DetectInEditor();
#else
            DetectOnDevice();
#endif
        }

        private void DetectInEditor()
        {
            bool isTouchOnUI = IsTouchOnUI();
            if (!isTouchOnUI && Input.GetMouseButtonDown(0))
            {
                m_PrevTouch1Pos = Input.mousePosition;
                m_Touch1Pos = m_PrevTouch1Pos;
                m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
                m_IsDragging = true;

                if (m_DragInertial != null)
                {
                    StopCoroutine(m_DragInertial);
                    m_DragInertial = null;
                }
            }

            if (m_IsDragging)
            {
                if (Input.GetMouseButton(0))
                {
                    m_PrevTouch1Pos = m_Touch1Pos;
                    m_Touch1Pos = Input.mousePosition;
                    m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
                    OnDrag(m_DragDelta, m_Touch1Pos);
                }
                //drag end
                if (Input.GetMouseButtonUp(0))
                {
                    m_IsDragging = false;
                    if (m_DragInertial != null)
                        StopCoroutine(m_DragInertial);
                    m_DragInertial = StartCoroutine(ExeDragInertial(m_DragDelta, m_Touch1Pos));
                }
            }

            if (Input.GetAxis("Mouse ScrollWheel") > 0)
            {
                m_PinchDelta = 20.0f;
                OnPinch(m_PinchDelta);
            }

            if (Input.GetAxis("Mouse ScrollWheel") < 0)
            {
                m_PinchDelta = -20.0f;
                OnPinch(m_PinchDelta);
            }
        }

        private void DetectOnDevice()
        {
            bool isTouchOnUI = IsTouchOnUI();
            //单指滑动
            if (!isTouchOnUI && Input.touchCount == 1 && Input.GetTouch(0).phase == TouchPhase.Began)
            {
                m_PrevTouch1Pos = Input.GetTouch(0).position;
                m_Touch1Pos = m_PrevTouch1Pos;
                m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
                m_IsDragging = true;
                if (m_DragInertial != null)
                {
                    StopCoroutine(m_DragInertial);
                    m_DragInertial = null;
                }
            }
            else if (m_IsDragging)
            {
                if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Moved)
                {
                    m_PrevTouch1Pos = m_Touch1Pos;
                    m_Touch1Pos = Input.GetTouch(0).position;
                    m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
                    OnDrag(m_DragDelta, m_Touch1Pos);
                }

                //drag end
                if (Input.touchCount > 1 || Input.touchCount == 0 || Input.GetTouch(0).phase == TouchPhase.Ended)
                {
                    m_IsDragging = false;
                    if (m_DragInertial != null)
                        StopCoroutine(m_DragInertial);
                    m_DragInertial = StartCoroutine(ExeDragInertial(m_DragDelta, m_Touch1Pos));
                }
            }

            if (!isTouchOnUI && Input.touchCount > 1 && (Input.GetTouch(0).phase == TouchPhase.Began || Input.GetTouch(1).phase == TouchPhase.Began))
            {
                m_PrevTouch1Pos = Input.GetTouch(0).position;
                m_Touch1Pos = m_PrevTouch1Pos;
                m_PrevTouch2Pos = Input.GetTouch(1).position;
                m_Touch2Pos = m_PrevTouch2Pos;
                m_PinchDelta = 0;

                Vector2 aveTouchPos = (Input.GetTouch(0).position + Input.GetTouch(1).position) * 0.5f;
                m_IsPinching = true;

                if (m_PinchInertial != null)
                {
                    StopCoroutine(m_PinchInertial);
                    m_PinchInertial = null;
                }
            }
            else if (m_IsPinching)
            {
                if (!isTouchOnUI && Input.touchCount > 1 && (Input.GetTouch(0).phase == TouchPhase.Moved || Input.GetTouch(1).phase == TouchPhase.Moved))
                {
                    m_PrevTouch1Pos = m_Touch1Pos;
                    m_Touch1Pos = Input.GetTouch(0).position;
                    m_PrevTouch2Pos = m_Touch2Pos;
                    m_Touch2Pos = Input.GetTouch(1).position;
                    m_PinchDelta = Vector3.Distance(m_Touch1Pos, m_Touch2Pos) - Vector3.Distance(m_PrevTouch1Pos, m_PrevTouch2Pos);
                    OnPinch(m_PinchDelta);
                }
                else if (Input.GetTouch(0).phase == TouchPhase.Ended || (Input.touchCount > 1 && Input.GetTouch(1).phase == TouchPhase.Ended))
                {
                    m_IsPinching = false;
                    if (m_PinchInertial != null)
                        StopCoroutine(m_PinchInertial);
                    m_PinchInertial = StartCoroutine(ExePinchInertial(m_PinchDelta));
                }
            }
        }

        #region Drag
        public void OnDrag(Vector2 dragDelta, Vector2 touchPos)
        {
            ExeDrag(dragDelta, touchPos);
        }

        private IEnumerator ExeDragInertial(Vector2 dragDelta, Vector2 touchPos)
        {
            while (!(m_IsMoveIn || m_IsMoveOut || !Controllable || !enabled) && Vector2.SqrMagnitude(dragDelta) > 0.01f && !m_IsDragging)
            {
                yield return null;
                dragDelta *= Mathf.Clamp01(1.0f - m_DragDamp);
                touchPos += dragDelta;
                ExeDrag(dragDelta, touchPos);
            }
            m_DragInertial = null;
        }

        public IEnumerator ExeDragInertialForExternal(Vector2 dragDelta, Vector2 touchPos)
        {
            while (Vector2.SqrMagnitude(dragDelta) > 0.01f && this.isDragInertial)
            {
                yield return null;
                dragDelta *= Mathf.Clamp01(1.0f - m_DragDamp);
                touchPos += dragDelta;
                //Debug.LogWarning("test:" + Vector2.SqrMagnitude(dragDelta));
                ExeDrag(dragDelta, touchPos, false);
            }
        }

        private bool isDragInertial = false;
        public void SetDragExternalState(bool isDragInertial)
        {
            this.isDragInertial = isDragInertial;
        }

        public void ExeDrag(Vector2 dragDelta, Vector2 touchPos, bool changePos = true)
        {
            float deltaAbsX = Mathf.Abs(dragDelta.x);
            float deltaAbsY = Mathf.Abs(dragDelta.y);

            bool dragH = true;
            bool dragV = true;
            //can drag vertically or horizontally
            if (deltaAbsX > deltaAbsY && (deltaAbsX / deltaAbsY > 2.0f))
            {
                dragH = true;
                dragV = false;
            }
            else if (deltaAbsY > deltaAbsX && (deltaAbsY / deltaAbsX > 2.0f))
            {
                dragH = false;
                dragV = true;
            }

            if (dragH)
            {
                float angle = - dragDelta.x / CameraUtility.GetScreenSize().x * 270.0f * m_DragCoeffient.x;

                if (m_Wave != null)
                {
                    m_Wave.OnTargetRotate(angle);
                }
                RotateAround(angle);
            }

            if (dragV)
            {
                float zP, zMiddleP = 0;
                if (Mathf.Abs(m_MiddleCamPoint.Position.z - m_FarCamPoint.Position.z) > 0.001f)
                    GetCamZProgress(out zP, out zMiddleP);
                else
                    GetCamFOVProgress(out zP, out zMiddleP);
                float minY = 0;
                float maxY = 0;
                Vector3 pos = m_Cam.transform.position;
                if (zP <= zMiddleP)
                {
                    minY = maxY = Mathf.Lerp(m_FarCamPoint.Position.y, m_MiddleCamPoint.Position.y, zP / zMiddleP);
                    pos.y = minY;
                }
                else
                {
                    float p = (zP - zMiddleP) / (1.0f - zMiddleP);
                    minY = Mathf.Lerp(m_MiddleCamPoint.Position.y, m_NearDownCamPoint.Position.y, p);
                    maxY = Mathf.Lerp(m_MiddleCamPoint.Position.y, m_NearUpCamPoint.Position.y, p);

                    Plane plane = new Plane(-m_Cam.transform.forward, (m_NearUpCamPoint.Position + m_NearDownCamPoint.Position) * 0.5f + m_Cam.transform.forward);

                    Vector3 worldPos = GetWorldPosOnNearPlane(touchPos, ref plane);
                    Vector3 prevWorldPos = GetWorldPosOnNearPlane(touchPos - dragDelta, ref plane);

                    float vMove = (prevWorldPos.y - worldPos.y) * (1.0f + 1.5f * p) * m_DragCoeffient.y;
                    pos.y = Mathf.Clamp(pos.y + vMove, minY, maxY);
                    m_PinchNearPlaneTargetY = Mathf.Lerp(m_NearDownCamPoint.Position.y, m_NearUpCamPoint.Position.y, Mathf.Abs(pos.y - minY) / Mathf.Max(0.001f,Mathf.Abs(maxY - minY)));
                }

                if (changePos)
                    m_Cam.transform.position = pos;
            }
        }

        private void ApplyLocalPositionWithRotation(Vector3 parentEuler)
        {
            if (pivotTF != null)
            {
                var posOffset = -m_TargetRotationPivot;
                posOffset.y = 0;
                posOffset = Quaternion.Euler(parentEuler) * posOffset;
                SetTargetLocalPosition(posOffset + m_OriginTargetPosition);
            }
        }

        private void GetCamZProgress(out float p, out float middleP)
        {
            float denominator = Mathf.Abs(m_NearUpCamPoint.Position.z - m_FarCamPoint.Position.z);
            p = Mathf.Max(0.001f, Mathf.Abs(m_Cam.transform.position.z - m_FarCamPoint.Position.z)) / denominator;
            middleP = Mathf.Max(0.001f, Mathf.Abs(m_MiddleCamPoint.Position.z - m_FarCamPoint.Position.z)) / denominator;
        }

        private void GetCamFOVProgress(out float p, out float middleP)
        {
            float denominator = Mathf.Abs(m_NearUpCamPoint.FieldOfView - m_FarCamPoint.FieldOfView);
            p = Mathf.Max(0.001f, Mathf.Abs(m_Cam.m_Lens.FieldOfView - m_FarCamPoint.FieldOfView)) / denominator;
            middleP = Mathf.Max(0.001f, Mathf.Abs(m_MiddleCamPoint.FieldOfView - m_FarCamPoint.FieldOfView)) / denominator;
        }

        private Vector3 GetWorldPosOnNearPlane(Vector2 screenPos, ref Plane plane)
        {
            Vector3 ret = Vector3.zero;
            var ray = m_Cam.ScreenPointToRay(screenPos);
            if (plane.Raycast(ray, out float t))
            {
                ret = ray.GetPoint(t);
            }
            return ret;
        }

        public void SetTargetLocalRotation(Vector3 rotation)
        {
            if (m_Target)
            {
                if (m_IsX3AnimatorRotate)
                {
                    X3AnimatorUtility.SetLocalRotation(m_Target, rotation.x, rotation.y, rotation.z);
                }
                else
                {
                    m_Target.localRotation = Quaternion.Euler(rotation);
                }
            }
        }
        
        public void RotateAround(float angle)
        {
            if (m_Target)
            {
                if (m_IsX3AnimatorRotate)
                {
                    X3AnimatorUtility.RotateAround(m_Target, pivotTF.position, m_Target.up, angle);
                }
                else
                {
                    m_Target.RotateAround(pivotTF.position, m_Target.up, angle);
                }
            }
        }

        
        public Quaternion GetTargetLocalRotation()
        {
            if (m_Target)
            {
                if (m_IsX3AnimatorRotate)
                {
                    return X3AnimatorUtility.GetLocalRotation(m_Target);
                }
                else
                {
                    return m_Target.localRotation;
                }
            }
            return Quaternion.identity;
        }

        public Vector3 GetTargetLocalEulerAngles()
        {
            if (m_Target)
            {
                if (m_IsX3AnimatorRotate)
                {
                    return X3AnimatorUtility.GetLocalEulerAngles(m_Target);
                }
                else
                {
                    return m_Target.localEulerAngles;
                }
            }
            return Vector3.zero;
        }
        
        public Vector3 GetTargetLocalPosition()
        {
            if (m_Target)
            {
                if (m_IsX3AnimatorRotate)
                {
                    return X3AnimatorUtility.GetLocalPosition(m_Target);
                }
                else
                {
                    return m_Target.localPosition;
                }
            }
            return Vector3.zero;
        }
        
        public void SetTargetLocalPosition(Vector3 pos, bool external = false)
        {
            if (external)
            {
                m_OriginTargetPosition = pos;
                m_OriginTargetPositionInited = true;
            }
                
            if (m_Target)
            {
                if (m_IsX3AnimatorRotate)
                {
                    X3AnimatorUtility.SetLocalPosition(m_Target, pos.x, pos.y, pos.z);
                }
                else
                {
                    m_Target.localPosition = pos;
                }
            }
        }
        #endregion

        #region Pinch
        private void OnPinch(float pinchDelta)
        {
            ExePinch(pinchDelta);
        }
        private IEnumerator ExePinchInertial(float pinchDelta)
        {
            while (!(m_IsMoveIn || m_IsMoveOut || !Controllable || !enabled) && pinchDelta * pinchDelta > 0.01f && !m_IsPinching)
            {
                yield return null;
                pinchDelta *= Mathf.Clamp01(1.0f - m_PinchDamp);
                ExePinch(pinchDelta);
            }
            m_PinchInertial = null;
        }

        private void GetZProgress(out float zP, out float zMiddleP)
        {
            if (Mathf.Abs(m_MiddleCamPoint.Position.z - m_FarCamPoint.Position.z) > 0.001f)
                GetCamZProgress(out zP, out zMiddleP);
            else
                GetCamFOVProgress(out zP, out zMiddleP);
        }

        private float m_ZProgress = 0;
        private void ExePinch(float pinchDelta)
        {
            float zP, zMiddleP = 0;
            GetZProgress(out zP, out zMiddleP);
            float zScale = pinchDelta / CameraUtility.GetScreenSize().x * 1.5f * m_PinchCoeffient;
            zP = Mathf.Clamp01(zP + zScale);
            m_ZProgress = zP;

            float fov = 0;
            Vector3 camRot = Vector3.zero;
            Vector3 camPos = Vector3.zero;
            float minY = 0;
            float maxY = 0;

            if (zP <= zMiddleP)
            {
                float p = zP / zMiddleP;
                fov = Mathf.Lerp(m_FarCamPoint.FieldOfView, m_MiddleCamPoint.FieldOfView, p);
                camRot = Vector3.Lerp(m_FarCamPoint.Rotation, m_MiddleCamPoint.Rotation, p);
                camPos = Vector3.Lerp(m_FarCamPoint.Position, m_MiddleCamPoint.Position, p);
                minY = maxY = camPos.y;
            }
            else
            {
                float p = (zP - zMiddleP) / (1.0f - zMiddleP);
                float fovP = m_MToNCurve.Evaluate(p);
                fov = Mathf.Lerp(m_MiddleCamPoint.FieldOfView, m_NearUpCamPoint.FieldOfView, fovP);
                camRot = Vector3.Lerp(m_MiddleCamPoint.Rotation, m_NearUpCamPoint.Rotation, p);
                Vector3 tarPos = (m_NearDownCamPoint.Position + m_NearUpCamPoint.Position) * 0.5f;
                tarPos.y = Mathf.Clamp(m_PinchNearPlaneTargetY, m_NearDownCamPoint.Position.y, m_NearUpCamPoint.Position.y);
                camPos = Vector3.Lerp(m_MiddleCamPoint.Position, tarPos, p);

                minY = Mathf.Lerp(m_MiddleCamPoint.Position.y, m_NearDownCamPoint.Position.y, p);
                maxY = Mathf.Lerp(m_MiddleCamPoint.Position.y, m_NearUpCamPoint.Position.y, p);
                camPos.y = Mathf.Clamp(camPos.y, minY, maxY);
            }

            if (m_WithDOF && PPV != null)
            {
                ApplyDOF(m_ZProgress);
            }
            
            m_Cam.transform.SetPositionAndRotation(camPos, Quaternion.Euler(camRot));
            m_Cam.m_Lens.FieldOfView = fov;
        }

        public void ApplyDOF(float t)
        {
            if (PPV == null)
                return;
            
            var dof = PPV.GetComponent<DofBfg>();
            PPV.EnableFeature(BlendableFeatureGroup.FeatureType.BFG_Dof);
            t = m_DOFCurve.Evaluate(t);
            var settings = DOFSettings.Lerp(m_FarDOFInfo, m_NearDOFInfo, t);
            dof.nearStart = settings.nearStart;
            dof.nearEnd = settings.nearEnd;
            dof.farStart = settings.farStart;
            dof.farEnd = settings.farEnd;
            dof.skyDepth = settings.skyDepth;
            dof.cocScale = settings.cocScale;
            dof.nearCOCGamma = settings.nearCOCGamma;
            dof.farCOCOffset = settings.farCOCOffset;
        }

        public void DisableDOF()
        {
            if (PPV == null)
                return;
            PPV.DeactivateFeature(BlendableFeatureGroup.FeatureType.BFG_Dof);
        }

        private IEnumerator DelayDisableDOF()
        {
            yield return null;
            DisableDOF();
            s_DelayDisableDofCoroutine = null;
        }
        #endregion
        public static bool IsTouchOnUI()
        {
            if (EventSystem.current == null) return false;
            bool ret = false;
#if UNITY_EDITOR
            ret = EventSystem.current.IsPointerOverGameObject();
#else
            ret = false;
            for (int i=0; i<Input.touchCount; i++)
            {
                if(EventSystem.current.IsPointerOverGameObject(Input.GetTouch(i).fingerId))
                {
                    ret = true;
                    break;
                }
            }
#endif
            return ret;
        }

#if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            Gizmos.color = Color.black;
            Gizmos.DrawLine(m_FarCamPoint.Position, m_MiddleCamPoint.Position);
            Gizmos.DrawLine(m_MiddleCamPoint.Position, m_NearUpCamPoint.Position);
            Gizmos.DrawLine(m_MiddleCamPoint.Position, m_NearDownCamPoint.Position);

            Gizmos.color = Color.blue;
            Gizmos.DrawSphere(m_FarCamPoint.Position, 0.1f);
            Gizmos.DrawRay(m_FarCamPoint.Position, Quaternion.Euler(m_FarCamPoint.Rotation) * Vector3.forward * 0.5f);

            Gizmos.DrawSphere(m_MiddleCamPoint.Position, 0.1f);
            Gizmos.DrawRay(m_MiddleCamPoint.Position, Quaternion.Euler(m_MiddleCamPoint.Rotation) * Vector3.forward * 0.5f);

            Gizmos.DrawSphere(m_NearUpCamPoint.Position, 0.1f);
            Gizmos.DrawRay(m_NearUpCamPoint.Position, Quaternion.Euler(m_NearUpCamPoint.Rotation) * Vector3.forward * 0.5f);

            Gizmos.DrawSphere(m_NearDownCamPoint.Position, 0.1f);
            Gizmos.DrawRay(m_NearDownCamPoint.Position, Quaternion.Euler(m_NearDownCamPoint.Rotation) * Vector3.forward * 0.5f);

            Gizmos.color = Color.red;
            Vector3 pos = (m_NearDownCamPoint.Position + m_NearUpCamPoint.Position) * 0.5f;
            pos.y = m_PinchNearPlaneTargetY;
            Gizmos.DrawSphere(pos, 0.1f);
        }

        [ContextMenu("Move In")]
        void ContextMenuMoveIn()
        {
            MoveIn();
        }

        [ContextMenu("Move Out")]
        void ContextMenuMoveOut()
        {
            MoveOut();
        }
#endif

        public void ApplyFarCamPoint()
        {
            if (m_Cam == null)
                return;
            ApplyCamPointWithRef(m_FarCamPoint, m_FarRefTF);
        }

        public void ApplyMiddleCamPoint()
        {
            if (m_Cam == null)
                return;
            ApplyCamPointWithRef(m_MiddleCamPoint, m_MiddleRefTF);
        }

        public void ApplyNearUpCamPoint()
        {
            if (m_Cam == null)
                return;
            ApplyCamPointWithRef(m_NearUpCamPoint, m_NearUpRefTF);
        }

        public void ApplyNearDownCamPoint()
        {
            if (m_Cam == null)
                return;
            ApplyCamPointWithRef(m_NearDownCamPoint, m_NearDownRefTF);
        }

        [System.Serializable]
        public struct CamPoint
        {
            public Vector3 Position;
            public Vector3 Rotation;
            public float FieldOfView;
        }
        
        [System.Serializable]
        public struct DOFSettings
        {
            public float nearStart;
            public float nearEnd;
            public float farStart;
            public float farEnd;
            public float skyDepth;
            public float cocScale;
            public float nearCOCGamma;
            public float farCOCOffset;

            public DOFSettings(float _nearStart, float _nearEnd, float _farStart, float _farEnd, float _skyDepth, float _cocScale, float _nearCOCGamma, float _farCOCOffset)
            {
                this.nearStart = _nearStart;
                this.nearEnd = _nearEnd;
                this.farStart = _farStart;
                this.farEnd = _farEnd;
                this.skyDepth = _skyDepth;
                this.cocScale = _cocScale;
                this.nearCOCGamma = _nearCOCGamma;
                this.farCOCOffset = _farCOCOffset;
            }

            public static DOFSettings Lerp(DOFSettings a, DOFSettings b, float t)
            {
                var setting = new DOFSettings();
                setting.nearStart = Mathf.Lerp(a.nearStart, b.nearStart, t);
                setting.nearEnd = Mathf.Lerp(a.nearEnd, b.nearEnd, t);
                setting.farStart = Mathf.Lerp(a.farStart, b.farStart, t);
                setting.farEnd = Mathf.Lerp(a.farEnd, b.farEnd, t);
                setting.skyDepth = Mathf.Lerp(a.skyDepth, b.skyDepth, t);
                setting.cocScale = Mathf.Lerp(a.cocScale, b.cocScale, t);
                setting.nearCOCGamma = Mathf.Lerp(a.nearCOCGamma, b.nearCOCGamma, t);
                setting.farCOCOffset = Mathf.Lerp(a.farCOCOffset, b.farCOCOffset, t);
                return setting;
            }
        }
    }
}

