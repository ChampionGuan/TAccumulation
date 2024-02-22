using System;
using System.Collections.Generic;
using Cinemachine;
using PapeGames;
using PapeGames.Rendering;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.EventSystems;

namespace X3Game.SceneGesture
{
    [XLua.LuaCallCSharp]
    [ExecuteInEditMode]
    public class X3SceneCharacterGesture : MonoBehaviour
    {
        private const float DRAG_THRESHOLD = 0.2f;

        #region SerializeField

        [SerializeField] private Transform m_TargetRoot;

        [SerializeField] private Transform m_Pivot;

        [SerializeField] private List<StaticCamState> m_StaticStates;
        [SerializeField] private List<AnimCtrlCamState> m_AnimCtrlStates;
        
        [SerializeField] private RotateType m_RotateType = RotateType.LockX;
        [SerializeField] private float m_TargetDragCoefficient = 1;
        [SerializeField] private float m_TargetDragDamp = 0.1f;

        [SerializeField] private float m_TargetMaxSpeed = 720;
        [SerializeField] private float m_TargetMinRestoreSpeed = 30;
        [SerializeField] private string m_DefaultStateKey;

        [SerializeField]
        private CinemachineBlendDefinition.Style m_BlendType = CinemachineBlendDefinition.Style.EaseInOut;

        [SerializeField] private AnimationCurve m_CustomCurve = null;

        [SerializeField] private bool m_DetectGesture = true;
        
        [SerializeField] private float m_DefaultSwitchDuration = 0.5f;

        #endregion

        private bool m_IsInit;
        private int m_BrainCtrlId = -1;

        private int brainCtrlId
        {
            get
            {
                if (m_BrainCtrlId == -1)
                {
                    m_BrainCtrlId = CinemachineUtility.GetMainCamDefaultBlendId();
                }

                return m_BrainCtrlId;
            }

            set => m_BrainCtrlId = value;
        }
        private TransformCtrl m_TransformCtrl = new TransformCtrl();
        private Transform m_TargetParent;
        private Transform TargetRoot => m_TargetRoot == null ? transform : m_TargetRoot;
        
        private Dictionary<string, StateBase> m_StateDict;

        private StateBase m_CurrentState;

        public bool DetectGesture { set => m_DetectGesture = value; get => m_DetectGesture; }

        private PPVCtrl m_PPVCtrl = new PPVCtrl();

        public static PostProcessVolume PPV
        {
            set => PPVCtrl.PPV = value;
            get => PPVCtrl.PPV;
        }

        #region Gesture Parameters

        private Vector2 m_PrevTouch1Pos;
        private Vector2 m_Touch1Pos;
        private Vector2 m_PrevTouch2Pos;
        private Vector2 m_Touch2Pos;
        private Vector2 m_DragDelta;
        private float m_PinchDelta;
        private bool m_IsDragging;
        private bool m_IsPinching;

        #endregion

        private Action<string> m_BlendComplete;
        private bool m_IsBlending = false;
        private float m_BlendTime;
        private void Init()
        {
            if (m_IsInit)
                return;
            
            m_PPVCtrl.BlendType = m_BlendType;
            m_PPVCtrl.CustomCurve = m_CustomCurve;
#if UNITY_EDITOR
            if (Application.isPlaying)
            {
#endif
                m_TargetParent = new GameObject("TargetParent").transform;
                m_TargetParent.SetParent(TargetRoot);
                m_TargetParent.localPosition = Vector3.zero;
                m_TargetParent.localRotation = Quaternion.identity;
                m_TargetParent.localScale = Vector3.one;

                m_TransformCtrl.SetTarget(m_TargetParent);
                m_TransformCtrl.SetPivot(m_Pivot, 0);
                m_TransformCtrl.RotateType = m_RotateType;
                m_TransformCtrl.DragCoefficient = m_TargetDragCoefficient;
                m_TransformCtrl.DragDamp = m_TargetDragDamp;
                m_TransformCtrl.MaxSpeed = m_TargetMaxSpeed;
                m_TransformCtrl.MinRestoreSpeed = m_TargetMinRestoreSpeed;
                m_TransformCtrl.BlendType = m_BlendType;
                m_TransformCtrl.CustomCurve = m_CustomCurve;
#if UNITY_EDITOR
            }
#endif
            RefreshStatesDict();
            if (m_StateDict != null && m_StateDict.Count > 0)
            {
                foreach (var state in m_StateDict.Values)
                {
                    state.Disable();
                }

                m_CurrentState = null;
            }
            m_IsInit = true;
        }

        public void RefreshStatesDict()
        {
            m_StateDict = new Dictionary<string, StateBase>();

            if (m_StaticStates != null && m_StaticStates.Count > 0)
            {
                foreach (var state in m_StaticStates)
                {
                    if (state != null)
                    {
                        m_StateDict[state.Key] = state;
                    }
                }
            }

            if (m_AnimCtrlStates != null && m_AnimCtrlStates.Count > 0)
            {
                foreach (var state in m_AnimCtrlStates)
                {
                    if (state != null)
                    {
                        m_StateDict[state.Key] = state;
                    }
                }
            }
        }


        #region GestureDetect

        private void AdjustDragDelta()
        {
            var absX = Mathf.Abs(m_DragDelta.x);
            var absY = Mathf.Abs(m_DragDelta.y);
            m_DragDelta.x = absY * DRAG_THRESHOLD > absX ? 0 : m_DragDelta.x;
            m_DragDelta.y = absX * DRAG_THRESHOLD > absY ? 0 : m_DragDelta.y;
        }

        private void OnDragBegin()
        {
            if (m_CurrentState != null)
            {
                m_CurrentState.OnDragBegin(m_Touch1Pos);
                if (m_CurrentState.TargetControllable)
                {
                    m_TransformCtrl.OnDragBegin(m_Touch1Pos);
                }
            }
        }


        private void OnDragUpdate()
        {
            AdjustDragDelta();
            if (m_CurrentState != null)
            {
                m_CurrentState.OnDragUpdate(m_DragDelta, m_Touch1Pos);
                if (m_CurrentState.TargetControllable)
                {
                    m_TransformCtrl.OnDragUpdate(m_DragDelta, m_Touch1Pos);
                }
            }
        }

        private void OnDragEnd()
        {
            AdjustDragDelta();
            m_IsDragging = false;
            if (m_CurrentState != null)
            {
                m_CurrentState.OnDragEnd(m_Touch1Pos);
                if (m_CurrentState.TargetControllable)
                {
                    m_TransformCtrl.OnDragEnd(m_Touch1Pos);
                }
            }
        }

        private void OnPinchBegin()
        {
            if (m_CurrentState != null)
                m_CurrentState.OnPinchBegin();
        }

        private void OnPinchUpdate()
        {
            if (m_CurrentState != null)
                m_CurrentState.OnPinchUpdate(m_PinchDelta);
        }

        private void OnPinchEnd()
        {
            m_IsPinching = false;
            if (m_CurrentState != null)
                m_CurrentState.OnPinchEnd(m_PinchDelta);
        }

        private void DetectInEditor()
        {
            bool isTouchOnUI = IsTouchOnUI();
            if (!isTouchOnUI && Input.GetMouseButtonDown(0))
            {
                m_PrevTouch1Pos = Input.mousePosition;
                m_Touch1Pos = m_PrevTouch1Pos;
                m_DragDelta = Vector2.zero;
                m_IsDragging = true;
                OnDragBegin();
            }

            if (m_IsDragging)
            {
                if (Input.GetMouseButton(0))
                {
                    m_PrevTouch1Pos = m_Touch1Pos;
                    m_Touch1Pos = Input.mousePosition;
                    m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;

                    OnDragUpdate();
                }

                //drag end
                if (Input.GetMouseButtonUp(0))
                {
                    OnDragEnd();
                }
            }

            if (Input.GetAxis("Mouse ScrollWheel") > 0)
            {
                m_IsPinching = true;
                m_PinchDelta = 20.0f;
                OnPinchBegin();
                OnPinchUpdate();
            }

            if (Input.GetAxis("Mouse ScrollWheel") < 0)
            {
                m_IsPinching = true;
                m_PinchDelta = -20.0f;
                OnPinchBegin();
                OnPinchUpdate();
            }

            if (m_IsPinching && Input.GetAxis("Mouse ScrollWheel") == 0)
            {
                OnPinchEnd();
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
                m_DragDelta = Vector2.zero;
                m_IsDragging = true;
                OnDragBegin();
            }
            else if (m_IsDragging)
            {
                if (Input.touchCount > 0 && (Input.GetTouch(0).phase == TouchPhase.Moved ||
                                             Input.GetTouch(0).phase == TouchPhase.Stationary))
                {
                    m_PrevTouch1Pos = m_Touch1Pos;
                    m_Touch1Pos = Input.GetTouch(0).position;
                    m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;

                    OnDragUpdate();
                }

                //drag end
                if (Input.touchCount > 1 || Input.touchCount == 0 || Input.GetTouch(0).phase == TouchPhase.Ended)
                {
                    OnDragEnd();
                }
            }

            if (!isTouchOnUI && Input.touchCount > 1 &&
                (Input.GetTouch(0).phase == TouchPhase.Began || Input.GetTouch(1).phase == TouchPhase.Began))
            {
                m_PrevTouch1Pos = Input.GetTouch(0).position;
                m_Touch1Pos = m_PrevTouch1Pos;
                m_PrevTouch2Pos = Input.GetTouch(1).position;
                m_Touch2Pos = m_PrevTouch2Pos;
                m_PinchDelta = 0;
                m_IsPinching = true;
                OnPinchBegin();
            }
            else if (m_IsPinching)
            {
                if (!isTouchOnUI && Input.touchCount > 1 &&
                    (Input.GetTouch(0).phase == TouchPhase.Moved || Input.GetTouch(1).phase == TouchPhase.Moved))
                {
                    m_PrevTouch1Pos = m_Touch1Pos;
                    m_Touch1Pos = Input.GetTouch(0).position;
                    m_PrevTouch2Pos = m_Touch2Pos;
                    m_Touch2Pos = Input.GetTouch(1).position;
                    m_PinchDelta = Vector3.Distance(m_Touch1Pos, m_Touch2Pos) -
                                   Vector3.Distance(m_PrevTouch1Pos, m_PrevTouch2Pos);
                    OnPinchUpdate();
                }
                else if (Input.touchCount == 0 || Input.GetTouch(0).phase == TouchPhase.Ended ||
                         (Input.touchCount > 1 && Input.GetTouch(1).phase == TouchPhase.Ended))
                {
                    OnPinchEnd();
                }
            }
        }

        #endregion

        #region MonoEvents

        private void Awake()
        {
            Init();
        }

        private void Start()
        {
            ToDefault(false);
        }

        private void Update()
        {
            var dt = Time.deltaTime;
            if (InputComponent.IsGlobalTouchEnabled && m_DetectGesture)
            {
#if UNITY_STANDALONE_WIN || UNITY_EDITOR
                DetectInEditor();
#endif
#if !UNITY_EDITOR && (UNITY_ANDROID || UNITY_IOS)
                DetectOnDevice();
#endif
            }

            if (InputComponent.IsGlobalTouchEnabled && m_DetectGesture || m_TransformCtrl.IsBlending)
            {
                m_TransformCtrl.OnUpdate(dt);
            }

            if (m_CurrentState)
            {
                m_CurrentState.OnUpdate(dt);
            }

            if (m_IsBlending)
            {
                m_BlendTime -= dt;
                if (m_BlendTime <= 0)
                {
                    BlendFinish();
                }
            }
        }

        private void LateUpdate()
        {
            if (m_CurrentState == null)
            {
                return;
            }

            var dt = Time.deltaTime;
            m_PPVCtrl.OnLateUpdate(dt);
            m_TransformCtrl.OnLateUpdate(dt);
            if (m_CurrentState.IsChanging || m_PPVCtrl.IsBlending)
            {
                m_PPVCtrl.ApplyPPVSettings();
            }
        }

        private void OnEnable()
        {
            m_PPVCtrl.EnableDOF();
        }

        private void OnDisable()
        {
            if (m_BrainCtrlId != -1)
            {
                CinemachineUtility.ReleaseMainCamDefaultBlendSetting(m_BrainCtrlId);
                m_BrainCtrlId = -1;
            }
            m_PPVCtrl.DisableDOF();
        }

        private void OnDestroy()
        {
            if (m_TargetParent)
            {
#if UNITY_EDITOR
                if (Application.isPlaying)
                    Destroy(m_TargetParent.gameObject);
                else
                    DestroyImmediate(m_TargetParent.gameObject);
#else
            Destroy(m_TargetParent.gameObject);
#endif
            }
        }

        #endregion

        #region State Ctrl

        /// <summary>
        /// 重置到默认状态
        /// </summary>
        public void ToDefault(bool force = true)
        {
            Init();

            if (m_CurrentState != null && !force)
                return;
            
            SwitchState(m_DefaultStateKey);
        }

        /// <summary>
        /// 重置角色旋转
        /// </summary>
        /// <param name="duration">重置过渡时常</param>
        public void ResetPosAndRot(float duration = -1)
        {
            if (Mathf.Approximately(duration, -1))
                duration = m_DefaultSwitchDuration;
            if (m_CurrentState != null)
                m_TransformCtrl.InitPosAndRot(duration);
        }

        public void RestoreState(float duration = -1, Action<string> onComplete = null)
        {
            if (!m_CurrentState)
                return;
            
            m_CurrentState.BlendType = m_BlendType;
            m_CurrentState.CustomCurve = m_CustomCurve;
            var camDuration = m_CurrentState.InitCamPos(duration);
            var transDuration = m_TransformCtrl.InitPosAndRot(duration);
            
            BlendFinish();
            StartBlend(Mathf.Max(camDuration, transDuration), onComplete);
        }

        /// <summary>
        /// 状态切换
        /// </summary>
        /// <param name="key">状态名，key == null则跳转到默认状态</param>
        /// <param name="duration">切换时间，curState == null时duration = 0</param>
        /// <param name="initTarget">是否需要初始化Target位置旋转，包括同状态切换时</param>
        /// <param name="initCamera">是否需要初始化相机位置到该机位下初始位置，包括同状态切换时，
        /// <param name="initCamera">是否需要初始化相机位置到该机位下初始位置，包括同状态切换时，
        /// 非同状态切换时新机位瞬切到默认机位，同状态切换时回初始机位的时间位duration</param>
        public void SwitchState(string key, float duration = -1, bool initTarget = true,
            bool initCamera = true, Action<string> onComplete = null)
        {

            if (!isActiveAndEnabled)
            {
                X3Debug.LogWarning("SceneCharacterGesture:Try switch state when component is not active and enable");
                return;
            }
            Init();
            if (Mathf.Approximately(duration, -1))
                duration = m_DefaultSwitchDuration;
            if (key == null)
                key = m_DefaultStateKey;
            duration = m_CurrentState != null ? duration : 0;
            BlendFinish();
            if (m_StateDict.TryGetValue(key, out StateBase state))
            {
                if (state != m_CurrentState)
                {
                    if (m_CurrentState)
                    {
                        m_CurrentState.Disable();
                    }

                    CinemachineUtility.SetMainCamDefaultBlend(m_BlendType, duration, m_CustomCurve, brainCtrlId);

                    m_CurrentState = state;
                    m_CurrentState.BlendType = m_BlendType;
                    m_CurrentState.CustomCurve = m_CustomCurve;
                    m_CurrentState.Enable(initCamera);
                    m_PPVCtrl.SwitchState(m_CurrentState, duration);
                    m_TransformCtrl.SetInitPosAndRot(m_CurrentState.TargetInitPos, m_CurrentState.TargetInitRot,
                        duration, initTarget);
                    StartBlend(duration, onComplete);
                }
                else
                {
                    var camDuration = 0f;
                    var transDuration = 0f;
                    if (initCamera)
                    {
                        m_CurrentState.BlendType = m_BlendType;
                        m_CurrentState.CustomCurve = m_CustomCurve;
                        camDuration = m_CurrentState.InitCamPos(duration);
                    }

                    if (initTarget)
                    {
                        transDuration = m_TransformCtrl.InitPosAndRot(duration);
                    }
                    
                    
                    StartBlend(Mathf.Max(camDuration, transDuration), onComplete);
                }
            }
        }
        
        /// <summary>
        /// 外部设置相机动画进度
        /// </summary>
        public void ClearState()
        {
            if (m_StateDict != null && m_StateDict.Count > 0)
            {
                foreach (var state in m_StateDict.Values)
                {
                    state.Disable();
                }

                m_CurrentState = null;
            }
        }
        
        /// <summary>
        /// 外部设置相机动画进度
        /// </summary>
        /// <param name="time">时间（Normalized）</param>
        /// <param name="weight">权重（-1 ~ 1）</param>
        public void ExternalSetWeightAndTime(float time, float weight)
        {
            if (m_CurrentState)
            {
                m_CurrentState.SetTimeAndWeight(time, weight);
            }
        }
        #endregion
        
        #region Camera Ctrl

        public void SetCameraPriority(int priority)
        {
            Init();
            foreach (var state in m_StateDict.Values)
            {
                state.SetCameraPriority(priority);
            }
        }
        #endregion

        #region TransformCtrl

        /// <summary>
        ///设置目标GameObject
        /// </summary>
        /// <param name="target">目标GameObject</param>
        /// <param name="wave">角色水波纹</param>
        /// <param name="posOffset">初始位置偏移</param>
        /// <param name="rotOffset">初始旋转偏移</param>
        public void AddTarget(GameObject target, IX3CharacterWave wave = null, Vector3? posOffset = null, Vector3? rotOffset = null)
        {
            if (target == null)
                return;

            AddTarget(target.transform, wave);
            if (posOffset.HasValue)
                m_TransformCtrl.PosOffset = posOffset.Value;
            if (rotOffset.HasValue)
                m_TransformCtrl.RotOffset = rotOffset.Value;
            
            if (posOffset.HasValue || rotOffset.HasValue)
                m_TransformCtrl.InitPosAndRot(0);
        }

        /// <summary>
        ///设置目标GameObject
        /// </summary>
        /// <param name="target">目标GameObject</param>
        /// <param name="wave">角色水波纹</param>
        public void AddTarget(Transform target, IX3CharacterWave wave = null)
        {
            if (target == null)
                return;

            Init();
            target.SetParent(m_TargetParent);
            target.localPosition = Vector3.zero;
            target.localRotation = Quaternion.identity;
            target.localScale = Vector3.one;

            var x3Animator = target.GetComponent<X3Animator>();
            if (x3Animator != null)
                x3Animator.KeepParent = true;

            m_TransformCtrl.SetTargetWave(wave);
        }

        /// <summary>
        /// 设置旋转中心并重置角色旋转及位移
        /// </summary>
        /// <param name="pivot">旋转中心</param>
        /// <param name="duration">重置过渡时长</param>
        /// <param name="forceUpdate">当pivot与当前相同时是否强制复位角色旋转位移</param>
        public void SetPivot(Transform pivot, float duration = -1, bool forceUpdate = true)
        {
            Init();
            if (Mathf.Approximately(duration, -1))
                duration = m_DefaultSwitchDuration;
            m_TransformCtrl.SetPivot(pivot, duration, forceUpdate);
        }
        
        /// <summary>
        /// 设置目标旋转，可以有过渡
        /// </summary>
        /// <param name="euler">目标角度（Normalized）</param>
        /// <param name="duration">过渡时间</param>
        public void SetInitRot(Vector3 euler, float duration)
        {
            m_TransformCtrl.RotOffset = euler;
            m_TransformCtrl.InitPosAndRot(duration);
        }

        void StartBlend(float duration, Action<string> onComplete)
        {
            m_BlendTime = duration;
            if (m_BlendTime > 0)
            {
                m_IsBlending = true;
                m_BlendComplete = onComplete;
            }
            else
            {
                m_IsBlending = false;
                onComplete?.Invoke(m_CurrentState.Key);
            }
        }
        void BlendFinish()
        {
            m_BlendComplete?.Invoke(m_CurrentState ? m_CurrentState.Key : "");
            m_BlendComplete = null;
            m_IsBlending = false;
        }
        #endregion

        private static bool IsTouchOnUI()
        {
            return CommonUtility.IsPointerOverGameObject(LayerMask.NameToLayer("IgnoreCollision"));
        }

#if UNITY_EDITOR
        public StateBase GetDefaultState()
        {
            if (string.IsNullOrEmpty(m_DefaultStateKey))
            {
                return null;
            }

            if (m_AnimCtrlStates != null && m_AnimCtrlStates.Count > 0)
            {
                foreach (var state in m_AnimCtrlStates)
                {
                    if (state != null && state.Key == m_DefaultStateKey)
                    {
                        return state;
                    }
                }
            }

            if (m_StaticStates != null && m_StaticStates.Count > 0)
            {
                foreach (var state in m_StaticStates)
                {
                    if (state != null && state.Key == m_DefaultStateKey)
                    {
                        return state;
                    }
                }
            }

            return null;
        }

        private void OnValidate()
        {
            if (m_TransformCtrl != null)
            {
                m_TransformCtrl.RotateType = m_RotateType;
                m_TransformCtrl.DragCoefficient = m_TargetDragCoefficient;
                m_TransformCtrl.DragDamp = m_TargetDragDamp;
                m_TransformCtrl.MaxSpeed = m_TargetMaxSpeed;
                m_TransformCtrl.MinRestoreSpeed = m_TargetMinRestoreSpeed;
                m_TransformCtrl.BlendType = m_BlendType;
                m_TransformCtrl.CustomCurve = m_CustomCurve;
            }

            if (m_PPVCtrl != null)
            {
                m_PPVCtrl.BlendType = m_BlendType;
                m_PPVCtrl.CustomCurve = m_CustomCurve;
            }
        }
#endif
    }
}