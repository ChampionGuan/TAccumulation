using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Animations;
using System.Collections.Generic;

namespace X3.PlayableAnimator
{
    public enum StateMotionType
    {
        Clip = 0,
        BlendTree,
        External
    }

    public struct AnimatorStateInfo
    {
        public string name { get; }
        public string tag { get; }
        public bool isLooping { get; }
        public float length { get; }
        public double normalizedTime { get; }
        public float speed { get; }
        public float defaultSpeed { get; }
        public float weight { get; }

        public AnimatorStateInfo(string name, string tag, bool isLooping, float length, double normalizedTime, float speed, float defaultSpeed, float weight)
        {
            this.name = name;
            this.tag = tag;
            this.isLooping = isLooping;
            this.length = length;
            this.normalizedTime = normalizedTime;
            this.speed = speed;
            this.defaultSpeed = defaultSpeed;
            this.weight = weight;
        }
    }

    [Serializable]
    public class StateMotion : StatePlayable
    {
        [HideInInspector] [SerializeField] private int m_HashID;
        [SerializeField] private float m_DefaultSpeed = 1;
        [SerializeField] private string m_SpeedParameterName;
        [SerializeField] private bool m_SpeedParameterActive;
        [SerializeField] private bool m_FootIK;
        [SerializeField] private bool m_WriteDefaultValues;
        [SerializeField] private StateMotionType m_MotionType;
        [SerializeField] private BlendTree m_BlendTree;
        [SerializeField] private ClipMotion m_ClipMotion;
        [SerializeField] private Motion m_ExternalMotion;

        public string speedParameterName => m_SpeedParameterName;
        public bool speedParameterActive => m_SpeedParameterActive;
        public bool footIK => m_FootIK;
        public bool writeDefaultValues => m_WriteDefaultValues;
        public bool isBlendTree => m_MotionType == StateMotionType.BlendTree;
        public override int internalHashID => m_HashID;

        public AnimatorController animCtrl => m_AnimLayer?.animCtrl;
        public virtual BonePrevMixer.BonePrevMixerPlayable layerPlayable => m_AnimLayer.playable;
        public virtual int internalIndex => m_InternalIndex;
        public override bool isValid => m_IsValid;
        public override bool isRunning => m_Status != InternalStatusType.Exit;
        public override bool isLooping => motion.isLooping;
        public override float speed => m_Speed ?? 1;
        public override float length => motion.length > 0 ? motion.length : 1;
        public override float weight => m_Weight;
        public override double normalizedTime => motion.normalizedTime;
        public override float defaultSpeed => m_DefaultSpeed;
        public override bool hasEmptyClip => motion.hasEmptyClip;

        [NonSerialized] protected AnimatorControllerLayer m_AnimLayer;
        [NonSerialized] private Action<string, Transition, float, float> m_ToDestinationStateAction;
        [NonSerialized] private Action<StateNotifyType, string> m_StateNotifyEvent;
        [NonSerialized] private List<StateGroup> m_StateGroups = new List<StateGroup>(4);
        [NonSerialized] private InternalStatusType m_Status = InternalStatusType.Exit;
        [NonSerialized] private StatePlayable m_PrevState;
        [NonSerialized] private StatePlayable m_NextState;
        [NonSerialized] private bool m_IsValid;
        [NonSerialized] private int m_InternalIndex;
        [NonSerialized] private float m_InternalSpeed;
        [NonSerialized] private float m_InternalLength;

        [NonSerialized] private float m_EnteredTime;
        [NonSerialized] private float m_EnteredTimeOffset;
        [NonSerialized] private float m_RunningTime;
        [NonSerialized] private float m_RunningPrevTime;
        [NonSerialized] private float m_Weight;
        [NonSerialized] private float? m_Speed;

        public override Motion motion
        {
            get
            {
                switch (m_MotionType)
                {
                    case StateMotionType.Clip:
                        return m_ClipMotion;
                    case StateMotionType.BlendTree:
                        return m_BlendTree;
                    case StateMotionType.External:
                        return m_ExternalMotion;
                    default:
                        return null;
                }
            }
        }

        public StateMotion(Vector2 position, string name, string tag) : base(position, name, tag)
        {
            m_HashID = GetHashCode();
        }

        public StateMotion(Vector2 position, string name, string tag, float defaultSpeed, string speedParameterName, bool speedParameterActive, bool footIK, bool writeDefaultValues, Motion motion, List<Transition> transitions) : base(position, name, tag)
        {
            switch (motion)
            {
                case ClipMotion clipMotion:
                    m_ClipMotion = clipMotion;
                    m_MotionType = StateMotionType.Clip;
                    break;
                case BlendTree blendTree:
                    m_BlendTree = blendTree;
                    m_MotionType = StateMotionType.BlendTree;
                    break;
                default:
                    m_ExternalMotion = motion;
                    m_MotionType = StateMotionType.External;
                    break;
            }

            m_DefaultSpeed = defaultSpeed;
            m_SpeedParameterName = speedParameterName;
            m_SpeedParameterActive = speedParameterActive;
            m_FootIK = footIK;
            m_WriteDefaultValues = writeDefaultValues;
            m_Transitions = transitions ?? new List<Transition>();
            m_HashID = GetHashCode();
        }

        public override void OnEnter(float startTime, StatePlayable prevState)
        {
            if (isRunning)
            {
                return;
            }

            m_Weight = 0;
            m_InternalLength = length;
            m_InternalSpeed = speed;
            m_PrevState = prevState;
            m_EnteredTimeOffset = 0;
            m_EnteredTime = m_RunningTime = m_RunningPrevTime = startTime;
            m_Status = InternalStatusType.PrepEnter;

            m_StateNotifyEvent?.Invoke(StateNotifyType.PrepEnter, name);
            m_AnimLayer.GetGroups(name, ref m_StateGroups);
            motion?.OnPrepEnter(prevState?.motion);
        }

        public override void OnUpdate(float deltaTime, float lifeTime = float.MaxValue)
        {
            if (!isRunning)
            {
                return;
            }

            var isReady = false;
            m_InternalSpeed = speed;

            if (m_Status == InternalStatusType.PrepEnter)
            {
                OnEnterComplete();
            }
            else
            {
                isReady = true;
            }

            TickTime(deltaTime);
            if (m_Status == InternalStatusType.PrepExit && lifeTime <= 0)
            {
                OnExitComplete();
            }

            if (AnimatorController.IsReachingThreshold(m_RunningTime, m_RunningPrevTime, length, length, out _))
            {
                m_StateNotifyEvent?.Invoke(StateNotifyType.Complete, name);
            }

            if (isReady && isRunning)
            {
                CheckToDestinationState();
            }
        }

        public override void OnExit(float lifeTime, StatePlayable nextState)
        {
            if (!isRunning)
            {
                return;
            }

            m_NextState = nextState;
            m_Status = InternalStatusType.PrepExit;
            m_StateNotifyEvent?.Invoke(StateNotifyType.PrepExit, name);
            motion?.OnPrepExit(nextState?.motion);
            if (lifeTime <= 0) OnExitComplete();
        }

        private void OnEnterComplete()
        {
            if (null != motion)
            {
                motion.OnEnter(m_PrevState?.motion);
                motion.SetTime(m_EnteredTime);
                motion.SetTime(m_EnteredTime);
            }
    
            m_Status = InternalStatusType.Enter;
            m_StateNotifyEvent?.Invoke(StateNotifyType.Enter, name);
        }

        private void OnExitComplete()
        {
            SetWeight(0);
            m_Status = InternalStatusType.Exit;
            m_StateNotifyEvent?.Invoke(StateNotifyType.Exit, name);
            motion?.OnExit(m_NextState?.motion);
        }

        public override void OnDestroy()
        {
            motion?.OnDestroy();
        }

        public override void TickTime(float deltaTime)
        {
            if (!isRunning) return;
            if (m_InternalLength != length)
            {
                m_EnteredTimeOffset = (m_EnteredTime + m_EnteredTimeOffset) / m_InternalLength * length - m_EnteredTime;
                m_InternalLength = length;
            }

            deltaTime *= m_InternalSpeed;
            m_EnteredTime += deltaTime;
            m_RunningPrevTime = m_RunningTime;
            m_RunningTime = m_EnteredTime + m_EnteredTimeOffset;
            if (deltaTime != 0) motion?.SetTime(m_RunningTime);
        }

        public override void SetWeight(float weight)
        {
            if (!isValid || !isRunning) return;
            m_Weight = weight;
            layerPlayable.SetInputWeight(internalIndex, this.weight);
            motion?.SetWeight(this.weight);
        }

        public override void SetSpeed(float speed)
        {
            m_Speed = speed;
            m_SpeedParameterActive = false;
        }

        public override void Reset()
        {
            m_Status = InternalStatusType.Exit;
            m_ToDestinationStateAction = null;
            m_StateNotifyEvent = null;
            if (null != m_AnimLayer) layerPlayable.DisconnectInput(internalIndex);
            m_AnimLayer = null;
            m_IsValid = false;
        }

        public void CheckToDestinationState()
        {
            if (CheckToDestinationState(this))
            {
                return;
            }

            for (var index = 0; index < m_StateGroups.Count; index++)
            {
                if (CheckToDestinationState(m_StateGroups[index]))
                {
                    return;
                }
            }
        }

        public StatePlayable DeepCopy()
        {
            var state = new StateMotion(m_Position, m_Name, m_Tag)
            {
                m_HashID = m_HashID,
                m_DefaultSpeed = m_DefaultSpeed,
                m_SpeedParameterName = m_SpeedParameterName,
                m_SpeedParameterActive = m_SpeedParameterActive,
                m_FootIK = m_FootIK,
                m_WriteDefaultValues = m_WriteDefaultValues,
                m_MotionType = m_MotionType,
                m_ClipMotion = m_ClipMotion?.DeepCopy() as ClipMotion,
                m_BlendTree = m_BlendTree?.DeepCopy() as BlendTree,
                m_ExternalMotion = m_ExternalMotion?.DeepCopy(),
                m_Transitions = new List<Transition>()
            };

            for (var i = 0; i < transitionsCount; i++)
            {
                state.m_Transitions.Add(m_Transitions[i].DeepCopy());
            }

            return state;
        }

        public void GetAnimationClips(List<AnimationClip> clips)
        {
            if (null == clips)
            {
                return;
            }

            if (m_MotionType == StateMotionType.Clip)
            {
                var clip = m_ClipMotion?.clip;
                if (null != clip && !clips.Contains(clip))
                {
                    clips.Add(clip);
                }
            }
            else if (m_MotionType == StateMotionType.BlendTree)
            {
                m_BlendTree.GetAnimationClips(clips);
            }
        }

        public virtual void RebuildPlayable(AnimatorControllerLayer layer, int inputIndex, Action<string, Transition, float, float> toDestinationStateInvoke, Action<StateNotifyType, string> stateNotify)
        {
            m_IsValid = true;
            m_AnimLayer = layer;
            m_InternalIndex = inputIndex;
            m_StateNotifyEvent = stateNotify;
            m_ToDestinationStateAction = toDestinationStateInvoke;
            m_StateGroups = m_StateGroups ?? new List<StateGroup>(4);
            if (null == m_Speed)
            {
                m_Speed = m_DefaultSpeed;
            }

            if (null != motion)
            {
                motion.RebuildPlayable(animCtrl, layerPlayable, m_InternalIndex, m_Weight);
                motion.SetTime(m_RunningTime);
                motion.SetTime(m_RunningTime);
            }

            if (!m_SpeedParameterActive) return;
            var parameter = animCtrl.GetParameter(m_SpeedParameterName);
            if (null != parameter)
            {
                parameter.m_OnValueChanged -= OnParameterValueChanged;
                parameter.m_OnValueChanged += OnParameterValueChanged;
                m_Speed *= parameter.defaultFloat;
            }
            else
            {
                // Debug.Log($"[playable animator][frameCount:{Time.frameCount}][parameter not found, please check!!][parameterName:{m_SpeedParameterName}]");
            }
        }

        private bool CheckToDestinationState(State state)
        {
            var onlySolo = false;
            for (var index = 0; index < state.transitions.Count; index++)
            {
                if (state.transitions[index].solo)
                {
                    onlySolo = true;
                    break;
                }
            }

            for (var index = 0; index < state.transitions.Count; index++)
            {
                var transition = state.transitions[index];
                if (!transition.CanToDestinationState(this, onlySolo, m_RunningTime, m_RunningPrevTime, length, out var stepValue))
                {
                    continue;
                }

                if (!m_AnimLayer.HasMotionState(transition.destinationStateName))
                {
                    continue;
                }

                m_ToDestinationStateAction?.Invoke(name, transition, (m_RunningTime - m_RunningPrevTime) / m_InternalSpeed, stepValue / m_InternalSpeed);
                return true;
            }

            return false;
        }

        private void OnParameterValueChanged(AnimatorControllerParameter parameter)
        {
            if (!m_SpeedParameterActive || null == parameter || m_SpeedParameterName != parameter.name)
            {
                return;
            }

            m_Speed = m_DefaultSpeed * parameter.defaultFloat;
        }
    }
}