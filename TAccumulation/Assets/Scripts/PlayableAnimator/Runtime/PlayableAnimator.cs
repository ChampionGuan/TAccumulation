using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Animations;

namespace X3.PlayableAnimator
{
    [DisallowMultipleComponent]
    public class PlayableAnimator : MonoBehaviour
    {
        [SerializeField] private AnimatorController m_DefaultAnimatorController;
        [SerializeField] private Avatar m_Avatar;
        [SerializeField] private bool m_ApplyRootMotion;
        [SerializeField] private AnimatorCullingMode m_CullingMode = AnimatorCullingMode.AlwaysAnimate;
        [SerializeField] private UpdateMode m_UpdateMode = UpdateMode.Normal;
        [SerializeField] private float m_Speed = 1;

        private PlayableGraph m_Graph;
        private AnimationMixerPlayable m_Mixer;

        [NonSerialized] private Animator m_Animator;
        [NonSerialized] private AnimatorController m_RuntimeAnimatorController;
        [NonSerialized] private StateNotifyEvent m_StateNotifyEvent = new StateNotifyEvent();

        public bool isRunning => null != runtimeAnimatorController && enabled;
        public StateNotifyEvent stateNotify => m_StateNotifyEvent;

        public float speed
        {
            get => m_Speed;
            set => m_Speed = value;
        }

        public bool applyRootMotion
        {
            get
            {
                m_ApplyRootMotion = animator.applyRootMotion;
                return m_ApplyRootMotion;
            }
            set
            {
                m_ApplyRootMotion = value;
                animator.applyRootMotion = value;
            }
        }

        public AnimatorCullingMode cullingMode
        {
            get
            {
                m_CullingMode = animator.cullingMode;
                return m_CullingMode;
            }
            set
            {
                m_CullingMode = value;
                animator.cullingMode = value;
            }
        }

        public UpdateMode updateMode
        {
            get => m_UpdateMode;
            set => m_UpdateMode = value;
        }

        public Avatar avatar
        {
            get
            {
                m_Avatar = animator.avatar;
                return m_Avatar;
            }
            set
            {
                m_Avatar = value;
                animator.avatar = value;
            }
        }

        public Animator animator
        {
            get
            {
                if (null != m_Animator) return m_Animator;
                m_Animator = GetComponent<Animator>();
                if (null == m_Animator) m_Animator = gameObject.AddComponent<Animator>();
                m_Animator.applyRootMotion = m_ApplyRootMotion;
                m_Animator.cullingMode = m_CullingMode;
                m_Animator.hideFlags = HideFlags.HideInInspector;
                if (null != m_Avatar) m_Animator.avatar = m_Avatar;
                else m_Avatar = m_Animator.avatar;
                return m_Animator;
            }
        }

        public AnimatorController runtimeAnimatorController
        {
            get => m_RuntimeAnimatorController;
            set
            {
                if (null != m_RuntimeAnimatorController && (m_RuntimeAnimatorController == value || m_DefaultAnimatorController == value))
                {
                    return;
                }

                m_DefaultAnimatorController = value;
                if (null != value)
                {
                    m_RuntimeAnimatorController = AnimatorController.ContainInstance(value) ? value : AnimatorController.CopyInstance(value);
                }
                else
                {
                    m_RuntimeAnimatorController = null;
                }

                m_RuntimeAnimatorController?.Reset();
                RebuildPlayable();
            }
        }

        protected virtual void Awake()
        {
            runtimeAnimatorController = m_DefaultAnimatorController;
        }

        protected virtual void Start()
        {
            Update(0);
        }

        protected virtual void Update()
        {
            if (updateMode == UpdateMode.Manual)
            {
                return;
            }

            Update(Time.deltaTime);
        }

        public virtual void Update(float deltaTime, bool withEvaluate = true)
        {
            if (!isRunning)
            {
                return;
            }

            runtimeAnimatorController.OnUpdate(deltaTime * speed);
            if (withEvaluate)
            {
                m_Graph.Evaluate();
            }
        }

        protected virtual void OnEnable()
        {
            animator.enabled = true;
            SetCtrlWeight(1);
        }

        protected virtual void OnDisable()
        {
            animator.enabled = false;
            SetCtrlWeight(0);
        }

        protected virtual void OnDestroy()
        {
            if (m_Graph.IsValid())
            {
                m_Graph.Destroy();
            }

            stateNotify.Clear();
            AnimatorController.DestroyInstance(runtimeAnimatorController);
            runtimeAnimatorController = null;
        }

        public void Play(string stateName, int layerIndex = 0, float normalizedTime = float.NegativeInfinity)
        {
            runtimeAnimatorController?.Play(stateName, layerIndex, normalizedTime);
        }

        public void PlayInFixedTime(string stateName, int layerIndex = 0, float fixedTime = float.NegativeInfinity)
        {
            runtimeAnimatorController?.PlayInFixedTime(stateName, layerIndex, fixedTime);
        }

        public void CrossFade(string stateName, int layerIndex = 0, float normalizedOffsetTime = 0, float dValue = 0)
        {
            runtimeAnimatorController?.CrossFade(stateName, layerIndex, normalizedOffsetTime, dValue);
        }

        public void CrossFade(string stateName, float normalizedTransitionTime = 0, int layerIndex = 0, float normalizedOffsetTime = 0, float dValue = 0)
        {
            runtimeAnimatorController?.CrossFade(stateName, normalizedTransitionTime, layerIndex, normalizedOffsetTime, dValue);
        }

        public void CrossFadeInFixedTime(string stateName, int layerIndex = 0, float fixedOffsetTime = 0, float dValue = 0)
        {
            runtimeAnimatorController?.CrossFadeInFixedTime(stateName, layerIndex, fixedOffsetTime, dValue);
        }

        public void CrossFadeInFixedTime(string stateName, float fixedTransitionTime = 0, int layerIndex = 0, float fixedOffsetTime = 0, float dValue = 0)
        {
            runtimeAnimatorController?.CrossFadeInFixedTime(stateName, fixedTransitionTime, layerIndex, fixedOffsetTime, dValue);
        }

        public bool AddState(string stateName, AnimationClip clip, int layerIndex = 0)
        {
            return null != runtimeAnimatorController && runtimeAnimatorController.AddState(stateName, clip, layerIndex);
        }

        public bool AddState(string stateName, Motion motion, int layerIndex = 0)
        {
            return null != runtimeAnimatorController && runtimeAnimatorController.AddState(stateName, motion, layerIndex);
        }

        public bool HasState(string stateName, int layerIndex = 0)
        {
            return null != runtimeAnimatorController && runtimeAnimatorController.HasState(stateName, layerIndex);
        }

        public void SetStateSpeed(string stateName, float speed, int layerIndex = 0)
        {
            runtimeAnimatorController?.SetStateSpeed(stateName, speed, layerIndex);
        }

        public int GetLayerIndex(string layerName)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetLayerIndex(layerName) : -1;
        }

        public float? GetAnimatorStateLength(string stateName, int layerIndex)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetAnimatorStateLength(stateName, layerIndex) : null;
        }

        public AnimatorStateInfo GetPreviousAnimatorStateInfo(int layerIndex)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetPreviousStateInfo(layerIndex) : new AnimatorStateInfo();
        }
        
        public AnimatorStateInfo GetCurrentAnimatorStateInfo(int layerIndex)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetCurrentStateInfo(layerIndex) : new AnimatorStateInfo();
        }

        public AnimatorStateInfo GetAnimatorStateInfo(int layerIndex, string stateName)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetStateInfo(layerIndex, stateName) : new AnimatorStateInfo();
        }

        public BlendTreeInfo GetBlendTreeInfo(string stateName, int layerIndex)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetBlendTreeInfo(stateName, layerIndex) : new BlendTreeInfo();
        }

        public float GetBlendTick(int layerIndex)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetBlendTick(layerIndex) : 0;
        }

        public void SetCtrlWeight(float weight)
        {
            runtimeAnimatorController?.SetWeight(weight);
        }

        public void SetLayerWeight(int layerIndex, float weight)
        {
            runtimeAnimatorController?.SetLayerWeight(layerIndex, weight);
        }

        public void SetLayerSpeed(int layerIndex, float speed)
        {
            runtimeAnimatorController?.SetLayerSpeed(layerIndex, speed);
        }

        public void SetPrevBone(int layerIndex, Transform[] bones)
        {
            runtimeAnimatorController?.SetPrevBone(layerIndex, bones);
        }

        public bool GetBool(string parameterName)
        {
            return null != runtimeAnimatorController && runtimeAnimatorController.GetBool(parameterName);
        }

        public int GetInteger(string parameterName)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetInteger(parameterName) : 0;
        }

        public float GetFloat(string parameterName)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetFloat(parameterName) : 0;
        }

        public bool HasParam(string parameterName)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.HasParam(parameterName) : false;
        }

        public void SetBool(string parameterName, bool value)
        {
            runtimeAnimatorController?.SetBool(parameterName, value);
        }

        public void SetInteger(string parameterName, int value)
        {
            runtimeAnimatorController?.SetInteger(parameterName, value);
        }

        public void SetFloat(string parameterName, float value, float time = 0)
        {
            runtimeAnimatorController?.SetFloat(parameterName, value, time);
        }

        protected virtual void RebuildPlayable()
        {
            if (m_Graph.IsValid())
            {
                m_Graph.Destroy();
            }

            if (null == runtimeAnimatorController)
            {
                return;
            }

            m_Graph = PlayableGraph.Create(name);
            m_Graph.SetTimeUpdateMode(DirectorUpdateMode.Manual);
            m_Mixer = AnimationMixerPlayable.Create(m_Graph, 1);
            m_Mixer.SetInputWeight(0, 1);
            AnimationPlayableOutput.Create(m_Graph, name, animator).SetSourcePlayable(m_Mixer);
            runtimeAnimatorController.RebuildPlayable(null, this, m_Mixer, 0);
            m_Graph.Play();
            m_Graph.Evaluate();

            runtimeAnimatorController.OnStart();
        }

        public enum UpdateMode
        {
            Normal = 0,
            Manual,
        }
    }
}