using PapeGames;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Game.SceneGesture
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Animator))]
    public class AnimCtrlCamState : StateBase
    {
        enum DragState
        {
            None,
            Dragging,
            Inertial,
        }

        enum PinchState
        {
            None,
            Pinching,
            Inertial,
        }
        
        public enum DragType
        {
            Clamped,
            Elastic,
            CustomCurve,
        }

        [SerializeField] public bool m_EditMode;
        [SerializeField] private AnimationClip m_ClipDefault;
        [SerializeField] private AnimationClip m_ClipUp;
        [SerializeField] private AnimationClip m_ClipDown;
        [Range(0, 1)] [SerializeField] private float m_InitTime = 0f;
        [SerializeField] private float m_SeparateTime = 0;
        [SerializeField] private float m_DragCoefficient = 1f;
        [SerializeField] private float m_DragUpMagnification = 1f;
        [SerializeField] private float m_DragDownMagnification = 1f;
        [SerializeField] private float m_PinchCoefficient = 1f;
        [SerializeField] private float m_DragDamp = 0.1f;
        [SerializeField] private float m_PinchDamp = 0.1f;
        
        [SerializeField] private float m_MinRestoreSpeedWeight = 0;
        [SerializeField] private float m_MinRestoreSpeedTime = 0;
        [SerializeField] private DragType m_DragType = DragType.Clamped;
        [SerializeField] private AnimationCurve m_CustomDragCurve;
        [SerializeField] private Vector2 m_WeightBounds = new Vector2(-1, 1);

        private float m_Time;
        private float m_Weight;

        private PlayableGraph m_Graph;
        private AnimationPlayableOutput m_Output;
        private AnimationMixerPlayable m_Mixer;
        private AnimationClipPlayable m_PlayableDefault;
        private AnimationClipPlayable m_PlayableUp;
        private AnimationClipPlayable m_PlayableDown;

        private float m_ClipLength;
        private bool m_ClipDefaultValid = false;
        private bool m_ClipUpValid = false;
        private bool m_ClipDownValid = false;

        private DragState m_DragState = DragState.None;
        private PinchState m_PinchState = PinchState.None;
        private Vector2 m_DragStartPos = Vector2.zero;
        private Vector2 m_DragDelta = Vector2.zero;
        private Vector2 m_TouchPos = Vector2.zero;
        private float m_PinchDelta = 0;
        private float m_DragStartWeight = 0;

        private float m_StartTime = 0;
        private float m_StartWeight = 0;
        private float m_BlendTime = 0;
        private float m_BlendDuration = 0;

        public override StateType Type => StateType.AnimCtrl;
        public bool IsValid => m_ClipDefaultValid;

        #region MonoBehaviour Event

#if UNITY_EDITOR
        public AnimationClip ClipDefault
        {
            get => m_ClipDefault;
            set
            {
                m_ClipDefault = value;
                Rebuild();
            }
        }

        public AnimationClip ClipUp
        {
            get => m_ClipUp;
            set
            {
                m_ClipUp = value;
                Rebuild();
            }
          
        }

        public AnimationClip ClipDown
        {
            get => m_ClipDown;
            set
            {
                m_ClipDown = value;
                Rebuild();
            }
        }
#endif

        public void Awake()
        {
            m_ClipDefaultValid = m_ClipDefault != null;
            m_ClipUpValid = m_ClipUp != null;
            m_ClipDownValid = m_ClipDown != null;
            InitCamPos();
        }

        public void OnEnable()
        {
            InitPlayableGraph();
        }

        public void OnDisable()
        {
            DestroyPlayableGraph();
        }

        #endregion

        #region public input

        public override float InitCamPos(float duration = 0)
        {
            m_InitTime = Mathf.Clamp01(m_InitTime);
            if (duration > Mathf.Epsilon && IsValid)
            {
                IsBlending = true;
                m_StartTime = m_Time;
                m_StartWeight = m_Weight;

                m_BlendTime = 0;
                var timeRestoreDuration = m_MinRestoreSpeedTime > Mathf.Epsilon ? Mathf.Abs(m_Time - m_InitTime)/m_MinRestoreSpeedTime : duration;
                float weightRestoreDuration = 0;
                if (m_Weight > 0)
                {
                    weightRestoreDuration = m_MinRestoreSpeedWeight > Mathf.Epsilon
                        ? m_Weight / (2 * m_MinRestoreSpeedWeight * m_DragUpMagnification /
                                      (m_DragUpMagnification + m_DragDownMagnification))
                        : duration;
                }
                else if (m_Weight < 0)
                {
                    weightRestoreDuration = m_MinRestoreSpeedWeight > Mathf.Epsilon
                        ? Mathf.Abs(m_Weight) / (2 * m_MinRestoreSpeedWeight * m_DragDownMagnification /
                                                 (m_DragUpMagnification + m_DragDownMagnification))
                        : duration;
                }
                
                m_BlendDuration = Mathf.Min(duration, Mathf.Max(timeRestoreDuration, weightRestoreDuration));

                //强制停止手势
                m_DragState = DragState.None;
                m_PinchState = PinchState.None;
                return m_BlendDuration;
            }
            
            IsBlending = false;
            m_Time = m_InitTime;
            m_Weight = 0;
            Evaluate();
            return 0;
        }

        public override void SetTimeAndWeight(float time, float weight = 0)
        {
            m_Time = time;
            m_Weight = Mathf.Clamp(weight, m_ClipDownValid ? -1 : 0, m_ClipUpValid ? 1 : 0);
            Evaluate();
        }

        public override void OnDragBegin(Vector2 touchPos)
        {
            if (!IsValid)
                return;

            m_DragDelta = Vector2.zero;
            m_TouchPos = touchPos;
            m_DragStartPos = touchPos;
            m_DragState = DragState.Dragging;
            m_DragStartWeight = Mathf.Clamp(m_Weight, -1, 1);
        }

        public override void OnDragUpdate(Vector2 dragDelta, Vector2 touchPos)
        {
            if (!IsValid)
                return;

            m_DragDelta = dragDelta;
            m_TouchPos = touchPos;
        }

        public override void OnDragEnd(Vector2 touchPos)
        {
            if (!IsValid)
                return;

            m_TouchPos = touchPos;
            m_DragState = DragState.Inertial;
        }

        public override void OnPinchBegin()
        {
            m_PinchState = PinchState.Pinching;
        }

        public override void OnPinchUpdate(float pinchDelta)
        {
            if (!IsValid)
                return;

            m_PinchDelta = pinchDelta;
        }

        public override void OnPinchEnd(float pinchDelta)
        {
            if (!IsValid)
                return;
            m_PinchDelta = pinchDelta;
            m_PinchState = PinchState.Inertial;
        }

        public override void OnUpdate(float dt)
        {
            if (!IsValid)
                return;

            //融合过程重有手势操作输入则打断融合
            if (m_DragState != DragState.None || m_PinchState != PinchState.None)
                IsBlending = false;

            //融合与手势只会相应一种，所以放在if else里
            if (IsBlending)
            {
                m_BlendTime += Time.deltaTime;

                if (m_BlendTime >= m_BlendDuration)
                {
                    m_Time = m_InitTime;
                    m_Weight = 0;

                    IsBlending = false;
                    m_BlendDuration = 0;
                    m_BlendTime = 0;
                }
                else
                {
                    m_Time = Mathf.Lerp(m_StartTime, m_InitTime,
                        BlendHelper.GetBlendWeight(Mathf.Clamp01(m_BlendTime / m_BlendDuration), BlendType,
                            CustomCurve));
                    m_Weight = Mathf.Lerp(m_StartWeight, 0,
                        BlendHelper.GetBlendWeight(Mathf.Clamp01(m_BlendTime / m_BlendDuration), BlendType,
                            CustomCurve));
                }
            }
            else
            {
                switch (m_PinchState)
                {
                    case PinchState.Pinching:
                        ExePinch();
                        break;
                    case PinchState.Inertial:
                        if (Mathf.Abs(m_PinchDelta) > 0.01f)
                        {
                            m_PinchDelta *= Mathf.Clamp01(1.0f - m_PinchDamp);
                            ExePinch();
                        }
                        else
                        {
                            m_PinchState = PinchState.None;
                        }

                        break;
                }

                switch (m_DragState)
                {
                    case DragState.Dragging:
                        ExeDrag();
                        break;
                    case DragState.Inertial:
                        if (Mathf.Abs(m_DragDelta.y) > 0.01f)
                        {
                            m_DragDelta *= Mathf.Clamp01(1.0f - m_DragDamp);
                            m_TouchPos += m_DragDelta;
                            ExeDrag();
                        }
                        else
                        {
                            m_DragState = DragState.None;
                        }

                        break;
                }
            }

            //有变化则evaluate graph
            if (IsBlending || m_DragState != DragState.None || m_PinchState != PinchState.None)
            {
                Evaluate();
            }

            IsChanging = IsBlending || m_DragState != DragState.None || m_PinchState != PinchState.None;
        }

        #endregion

        #region Execute functions

        private void ExeDrag()
        {
            if (m_Time * m_ClipLength < m_SeparateTime || Mathf.Abs(m_DragDelta.y) < Mathf.Epsilon)
                return;

            var dragDelta = m_TouchPos.y - m_DragStartPos.y;
            var dragCoefficient = dragDelta < 0
                ? m_DragCoefficient * m_DragUpMagnification
                : m_DragCoefficient * m_DragDownMagnification;
            if (!Mathf.Approximately(dragDelta / CameraUtility.GetScreenSize().y * dragCoefficient, 0))
            {
                m_Weight = m_DragStartWeight - dragDelta / CameraUtility.GetScreenSize().y * dragCoefficient;
            }
        }

        private void ExePinch()
        {
            m_Time = Mathf.Clamp(m_Time + m_PinchDelta / CameraUtility.GetScreenSize().x * m_PinchCoefficient, 0, 1);
        }

        #endregion

        #region playable garph

        public void Rebuild()
        {
            DestroyPlayableGraph();
            InitPlayableGraph();
        }

        private void InitPlayableGraph()
        {
            if (!IsValid || m_EditMode && !Application.isPlaying)
                return;

            var animator = GetComponent<Animator>();
            animator.runtimeAnimatorController = null;

            m_Graph = PlayableGraph.Create(name);
            m_Graph.SetTimeUpdateMode(DirectorUpdateMode.Manual);
            m_Output = AnimationPlayableOutput.Create(m_Graph, "Animation", GetComponent<Animator>());
            m_PlayableDefault = AnimationClipPlayable.Create(m_Graph, m_ClipDefault);
            m_PlayableUp = AnimationClipPlayable.Create(m_Graph, m_ClipUp);
            m_PlayableDown = AnimationClipPlayable.Create(m_Graph, m_ClipDown);
            m_Mixer = AnimationMixerPlayable.Create(m_Graph, 3);
            m_Output.SetSourcePlayable(m_Mixer);
            m_Graph.Connect(m_PlayableDefault, 0, m_Mixer, 0);
            m_Graph.Connect(m_PlayableUp, 0, m_Mixer, 1);
            m_Graph.Connect(m_PlayableDown, 0, m_Mixer, 2);

            m_ClipLength = m_ClipDefault.length;
            Evaluate();
        }

        private void Evaluate()
        {
            if (!IsValid || !m_Graph.IsValid())
                return;

            var realWeight = m_Weight;

            if ( m_DragType == DragType.CustomCurve && m_CustomDragCurve != null)
            {
                m_Weight = Mathf.Clamp(m_Weight, -1, 1);
                realWeight = m_CustomDragCurve.Evaluate((m_Weight + 1) / 2) * 2 - 1;
            }
            else
            {
                if (m_DragType == DragType.Elastic)
                {
                    m_WeightBounds.x = Mathf.Clamp(m_WeightBounds.x, -1, 0);
                    m_WeightBounds.y = Mathf.Clamp01(m_WeightBounds.y);
                    var dampSize = m_Weight < 0 ? m_WeightBounds.x + 1 : 1- m_WeightBounds.y;
                    var overStretching = m_Weight < m_WeightBounds.x ? m_Weight - m_WeightBounds.x : 
                        (m_Weight > m_WeightBounds.y ? m_Weight - m_WeightBounds.y: 0);
                    if (dampSize > 0)
                    {
                        realWeight -= (1 - (1 / ((Mathf.Abs(overStretching) * 0.55f / dampSize) + 1))) * dampSize * Mathf.Sign(overStretching);
                    }
                }
            }
            realWeight = Mathf.Clamp(realWeight, -1, 1);
            m_Mixer.SetInputWeight(0, 1 - Mathf.Abs(realWeight));
            m_Mixer.SetInputWeight(1, realWeight > 0 ? realWeight : 0);
            m_Mixer.SetInputWeight(2, realWeight < 0 ? -realWeight : 0);

            var realTime = m_Time * m_ClipLength;
            m_PlayableDefault.SetTime(realTime);
            m_PlayableUp.SetTime(realTime);
            m_PlayableDown.SetTime(realTime);
            m_Graph.Evaluate();
        }

        private void DestroyPlayableGraph()
        {
            if (m_Graph.IsValid())
            {
                m_Graph.DestroyPlayable(m_PlayableDefault);
                m_Graph.DestroyPlayable(m_PlayableUp);
                m_Graph.DestroyPlayable(m_PlayableDown);
                m_Graph.DestroyPlayable(m_Mixer);
                m_Graph.DestroyOutput(m_Output);
                m_Graph.Destroy();
            }

            m_DragState = DragState.None;
            m_PinchState = PinchState.None;
        }

        #endregion

#if UNITY_EDITOR
        public void OnClipChanged()
        {
            m_ClipDefaultValid = m_ClipDefault != null;
            m_ClipUpValid = m_ClipUp != null;
            m_ClipDownValid = m_ClipDown != null;
        }
#endif
    }
}