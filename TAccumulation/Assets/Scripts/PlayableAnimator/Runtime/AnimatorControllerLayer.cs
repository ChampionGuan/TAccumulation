using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3.PlayableAnimator
{
    public enum AnimatorControllerLayerBlendingType
    {
        Override = 0,
        Additive = 1
    }

    [Serializable]
    public class AnimatorControllerLayer
    {
        [SerializeField] private string m_Name;
        [SerializeField] private float m_DefaultSpeed = 1;
        [SerializeField] private float m_DefaultWeight;
        [SerializeField] private bool m_IKPass;
        [SerializeField] private bool m_SyncedLayerAffectsTiming;
        [SerializeField] private int m_SyncedLayerIndex;
        [SerializeField] private string m_DefaultStateName;
        [SerializeField] private AvatarMask m_AvatarMask;
        [SerializeField] private AnimatorControllerLayerBlendingType m_BlendingType;
        [SerializeField] private List<StateMotion> m_States = new List<StateMotion>();
        [SerializeField] private List<StateGroup> m_Groups = new List<StateGroup>();
        [SerializeField] private int m_TimeScaleType;

        public string name => m_Name;
        public bool ikPass => m_IKPass;
        public bool syncedLayerAffectsTiming => m_SyncedLayerAffectsTiming;
        public int syncedLayerIndex => m_SyncedLayerIndex;
        public string defaultStateName => m_DefaultStateName;
        public float defaultSpeed => m_DefaultSpeed;
        public float speed => m_Speed ?? defaultSpeed;
        public float defaultWeight => m_DefaultWeight;
        public float weight => m_Weight ?? defaultWeight;
        public int timeScaleType => m_TimeScaleType;

        public AvatarMask avatarMask => m_AvatarMask;
        public AnimatorControllerLayerBlendingType blendingType => m_BlendingType;
        public int statesCount => m_States.Count;
        public int groupsCount => m_Groups.Count;

        public AnimatorController animCtrl => m_AnimCtrl;
        public BonePrevMixer.BonePrevMixerPlayable playable => m_Playable;
        public BoneLayerMixer.BoneLayerMixerPlayable ctrlPlayable => animCtrl.playable;
        public int internalIndex => m_InternalIndex;
        public bool isValid => m_IsValid;

        public StatePlayable oldestState { get; private set; }
        public StatePlayable prevState { get; private set; }
        public StatePlayable currState { get; private set; }

        [NonSerialized] protected AnimatorController m_AnimCtrl;
        [NonSerialized] private BonePrevMixer.BonePrevMixerPlayable m_Playable;
        [NonSerialized] private bool m_IsValid;
        [NonSerialized] private int m_InternalIndex;
        [NonSerialized] private List<StateMotion> m_DynamicStates;
        [NonSerialized] private List<StateGroup> m_CurrStateGroups;
        [NonSerialized] private List<StateGroup> m_DestStateGroups;
        [NonSerialized] private Action<StateNotifyType, string> m_StateNotifyEvent;
        [NonSerialized] private Action<string, Transition, float, float> m_ToDestinationStateAction;
        [NonSerialized] private TransitionInterruptionSource m_InterruptionSource;
        [NonSerialized] private StatePose m_StatePose;
        [NonSerialized] private ToState m_StateNext;
        [NonSerialized] private float m_BlendTime;
        [NonSerialized] private float m_BlendTick;
        [NonSerialized] private int m_InputCount;
        [NonSerialized] private float? m_Weight;
        [NonSerialized] private float? m_Speed;
        [NonSerialized] private Transform[] m_PrevBone; // 在过渡过程中特殊处理的骨骼：如果过渡的前一个动画K了该骨骼，后一个动画没K，则在过渡过程中，该骨骼会直接设为前一个动画第一帧K的值。

        public AnimatorControllerLayer(string name, float defaultWeight, AnimatorControllerLayerBlendingType blendingType)
        {
            m_Name = name;
            m_DefaultWeight = defaultWeight;
            m_BlendingType = blendingType;
        }

        public AnimatorControllerLayer(string name, float defaultSpeed, float defaultWeight, bool iKPass, bool syncedLayerAffectsTiming, int syncedLayerIndex, string defaultStateName, AvatarMask avatarMask, AnimatorControllerLayerBlendingType blendingType, List<StateMotion> states, List<StateGroup> groups)
        {
            m_Name = name;
            m_DefaultSpeed = defaultSpeed;
            m_DefaultWeight = defaultWeight;
            m_IKPass = iKPass;
            m_SyncedLayerAffectsTiming = syncedLayerAffectsTiming;
            m_SyncedLayerIndex = syncedLayerIndex;
            m_DefaultStateName = defaultStateName;
            m_AvatarMask = avatarMask;
            m_BlendingType = blendingType;
            m_States = states ?? new List<StateMotion>();
            m_Groups = groups ?? new List<StateGroup>();
        }

        public void OnStart()
        {
            if (null != currState)
            {
                return;
            }

            SwitchStateInFixedTime(new ToState.Info { destState = GetState(defaultStateName, m_States) });
        }

        public void SetPrevBone(Transform[] overwriteBone)
        {
            m_PrevBone = overwriteBone;
            RebuildPlayable(m_AnimCtrl, internalIndex, m_StateNotifyEvent);
        }

#if UNITY_EDITOR
        private Dictionary<int, bool> m_LastMaskActive;
        void ResetMask()
        {
            if (m_LastMaskActive == null)
                m_LastMaskActive = new Dictionary<int, bool>();
            else
                m_LastMaskActive.Clear();

            for (int i = 0; i < avatarMask.transformCount; i++)
                m_LastMaskActive[i] = avatarMask.GetTransformActive(i);
        }
        void CheckMaskChange()
        {
            if (avatarMask == null)
                return;

            if (m_LastMaskActive == null)
                ResetMask();

            if (avatarMask.transformCount != m_LastMaskActive.Count)
            {
                Debug.LogError("[Animator Editor]修改了MaskCount, Rebuild Layer");
                ResetMask();
                RebuildPlayable(m_AnimCtrl, internalIndex, m_StateNotifyEvent);
            }
            else
            {
                for (int i = 0; i < avatarMask.transformCount; i++)
                {
                    if (m_LastMaskActive[i] == avatarMask.GetTransformActive(i))
                        continue;

                    Debug.LogError("[Animator Editor]修改了Mask Active, Rebuild Layer");
                    ResetMask();
                    RebuildPlayable(m_AnimCtrl, internalIndex, m_StateNotifyEvent);
                    break;
                }
            }
        }
#endif

        public void OnUpdate(float deltaTime)
        {
            deltaTime *= speed;
            if (m_StateNext.Switch())
            {
                BlendState(deltaTime, 0, deltaTime);
            }
            else
            {
                BlendState(deltaTime, deltaTime, deltaTime);
            }
#if UNITY_EDITOR
            CheckMaskChange();
#endif
        }

        public void OnDestroy()
        {
            for (var i = 0; i < m_States.Count; i++)
            {
                m_States[i].OnDestroy();
            }

            for (var i = 0; null != m_DynamicStates && i < m_DynamicStates.Count; i++)
            {
                m_DynamicStates[i].OnDestroy();
            }
        }

        public void SetSpeed(float speed)
        {
            m_Speed = speed;
        }

        public void SetWeight(float weight)
        {
            m_Weight = weight;
            ctrlPlayable.SetInputWeight(internalIndex, weight);
        }

        public void Play(string stateName, float normalizedTime)
        {
            if (!CanToState(stateName, normalizedTime))
            {
                return;
            }

            m_StateNext.SetValue(true, null, stateName, 0, normalizedTime, 0);
        }

        public void PlayInFixedTime(string stateName, float fixedTime)
        {
            if (!CanToState(stateName, fixedTime))
            {
                return;
            }

            m_StateNext.SetValue(false, null, stateName, 0, fixedTime, 0);
        }

        public void CrossFade(string stateName, float normalizedOffsetTime, float stepValue)
        {
            if (!CanToState(stateName, normalizedOffsetTime))
            {
                return;
            }

            var normalizedTransitionTime = 0f;
            var interruptionSource = TransitionInterruptionSource.None;
            var transition = GetFadeInTransition(stateName);
            if (null != transition)
            {
                normalizedTransitionTime = GetFadeInTransitionDuration(currState, transition, true);
                interruptionSource = transition.interruptionSource;
            }

            m_StateNext.SetValue(true, null, stateName, stepValue, normalizedOffsetTime, normalizedTransitionTime, interruptionSource);
        }

        public void CrossFade(string stateName, float normalizedOffsetTime, float normalizedTransitionTime, float stepValue)
        {
            if (!CanToState(stateName, normalizedOffsetTime))
            {
                return;
            }

            m_StateNext.SetValue(true, null, stateName, stepValue, normalizedOffsetTime, normalizedTransitionTime);
        }

        public void CrossFadeInFixedTime(string stateName, float fixedOffsetTime, float stepValue)
        {
            if (!CanToState(stateName, fixedOffsetTime))
            {
                return;
            }

            var fixedTransitionTime = 0f;
            var interruptionSource = TransitionInterruptionSource.None;
            var transition = GetFadeInTransition(stateName);
            if (null != transition)
            {
                fixedTransitionTime = GetFadeInTransitionDuration(currState, transition, false);
                interruptionSource = transition.interruptionSource;
            }
            else if(HasAutoTransition(stateName, out var transitionTime))
            {
                fixedTransitionTime = transitionTime;
                interruptionSource = TransitionInterruptionSource.Destination;
            }

            m_StateNext.SetValue(false, currState?.name, stateName, stepValue, fixedOffsetTime, fixedTransitionTime, interruptionSource);
        }

        public void CrossFadeInFixedTime(string stateName, float fixedOffsetTime, float fixedTransitionTime, float stepValue)
        {
            if (!CanToState(stateName, fixedOffsetTime))
            {
                return;
            }

            m_StateNext.SetValue(false, null, stateName, stepValue, fixedOffsetTime, fixedTransitionTime);
        }

        private void InternalCrossFade(string fromStateName, Transition transition, float deltaTime, float stepValue)
        {
            if (m_BlendTick > 0)
            {
                switch (m_InterruptionSource)
                {
                    case TransitionInterruptionSource.None:
                        // Debug.Log($"[playable animator][frameCount:{Time.frameCount}][正在过渡状态，请稍候...]");
                        return;
                    case TransitionInterruptionSource.Source when prevState.name != fromStateName:
                    case TransitionInterruptionSource.Destination when currState.name != fromStateName:
                        return;
                }
            }

            var length = currState != null && currState.name == fromStateName ? currState.length : prevState.length;
            var normalizedTransitionTime = transition.hasFixedDuration ? transition.duration / length : transition.duration;

            m_StateNext.SetValue(true, fromStateName, deltaTime, stepValue, normalizedTransitionTime, transition.offset, transition);
            m_StateNext.Switch();
            // OnUpdate(0);
        }

        public float GetFadeInTransitionDuration(StatePlayable fromState, string destStateName, bool isNormalizedTime)
        {
            var transition = GetFadeInTransition(destStateName);
            return GetFadeInTransitionDuration(fromState, transition, isNormalizedTime);
        }

        public float GetFadeInTransitionDuration(StatePlayable fromState, Transition transition, bool isNormalizedTime)
        {
            if (null == transition || null == fromState || fromState.length <= 0)
            {
                return 0;
            }

            if (transition.hasFixedDuration)
            {
                return isNormalizedTime ? transition.duration / fromState.length : transition.duration;
            }

            return isNormalizedTime ? transition.duration : transition.duration * fromState.length;
        }

        public Transition GetFadeInTransition(string destStateName)
        {
            if (null == currState)
            {
                
                return null;
            }

            var state = GetState(destStateName, m_States);
            if (null == state)
            {
                return null;
            }

            if (HasFadeTransition(currState, destStateName, out var transition))
            {
                return transition;
            }

            GetGroups(currState.name, ref m_CurrStateGroups);
            GetGroups(destStateName, ref m_DestStateGroups);
            for (var i = 0; i < m_DestStateGroups.Count; i++)
            {
                var destGroup = m_DestStateGroups[i];
                if (HasFadeTransition(currState, destGroup.name, out transition))
                {
                    return transition;
                }
            }

            for (var index = 0; index < m_CurrStateGroups.Count; index++)
            {
                var currGroup = m_CurrStateGroups[index];
                if (HasFadeTransition(currGroup, destStateName, out transition))
                {
                    return transition;
                }

                for (var i = 0; i < m_DestStateGroups.Count; i++)
                {
                    var destGroup = m_DestStateGroups[i];
                    if (HasFadeTransition(currGroup, destGroup.name, out transition))
                    {
                        return transition;
                    }
                }
            }

            return null;
        }

        private bool HasFadeTransition(State state, string destStateName, out Transition transition)
        {
            if (currState is StateMotion fromState)
            {
                for (var i = state.transitionsCount - 1; i >= 0; i--)
                {
                    transition = state.transitions[i];
                    if (transition.IsForDestinationStateFade(fromState, destStateName))
                    {
                        return true;
                    }
                }
            }

            transition = null;
            return false;
        }

        public bool HasAutoTransition(string destStateName, out float duration)
        {
            duration = 0;
            for(int i = 0; i < groupsCount; i ++)
            {
                var group = GetState<StateGroup>(i);
                if(group.autoTransition && group.HasChild(currState.name) && group.HasChild(destStateName))
                {
                    duration = group.autoDuration;
                    return true;
                }
            }
            return false;
        }

        public void GetGroups(string stateName, ref List<StateGroup> groups)
        {
            if (null == groups)
            {
                groups = new List<StateGroup>();
            }
            else
            {
                groups.Clear();
            }

            if (string.IsNullOrEmpty(stateName))
            {
                return;
            }

            for (var index = 0; index < m_Groups.Count; index++)
            {
                var group = m_Groups[index];
                if (group.HasChild(stateName))
                {
                    groups.Add(group);
                }
            }
        }

        public T GetState<T>(string name) where T : State
        {
            if (typeof(T) == typeof(StateMotion))
            {
                return GetState(name, m_States) as T;
            }

            if (typeof(T) == typeof(StateGroup))
            {
                return GetState(name, m_Groups) as T;
            }

            return null;
        }

        public T GetState<T>(int index) where T : State
        {
            if (typeof(T) == typeof(StateMotion))
            {
                return GetState(index, m_States) as T;
            }

            if (typeof(T) == typeof(StateGroup))
            {
                return GetState(index, m_Groups) as T;
            }

            return null;
        }

        public bool AddState<T>(T state) where T : State
        {
            if (state is StateMotion motionState)
            {
                return AddState(motionState, m_States);
            }

            if (state is StateGroup groupState)
            {
                AddState(groupState, m_Groups);
            }

            return false;
        }

        public void AddState<T>(List<T> states) where T : State
        {
            if (null == states)
            {
                return;
            }

            for (var index = 0; index < states.Count; index++)
            {
                AddState(states[index]);
            }
        }

        public bool HasMotionState(string stateName)
        {
            return null != GetState(stateName, m_States);
        }

        public bool HasGroupState(string stateName)
        {
            return null != GetState(stateName, m_Groups);
        }

        public bool HasState<T>(string stateName) where T : State
        {
            if (typeof(T) == typeof(StateMotion))
            {
                return null != GetState(stateName, m_States);
            }

            if (typeof(T) == typeof(StateGroup))
            {
                return null != GetState(stateName, m_Groups);
            }

            return false;
        }

        public bool HasState(string stateName)
        {
            if (null != GetState(stateName, m_States))
            {
                return true;
            }

            return null != GetState(stateName, m_Groups);
        }

        public bool RemoveState(string stateName)
        {
            return RemoveState(stateName, m_States) || RemoveState(stateName, m_Groups);
        }

        public bool AddState(string stateName, Motion motion)
        {
            return AddState(new StateMotion(Vector3.zero, stateName, null, 1, null, false, false, false, motion, null), m_States);
        }

        public void SetStateSpeed(string stateName, float speed)
        {
            GetState(stateName, m_States)?.SetSpeed(speed);
        }

        public AnimatorStateInfo GetPreviousStateInfo()
        {
            return GetStateInfo(prevState);
        }

        public AnimatorStateInfo GetCurrentStateInfo()
        {
            return GetStateInfo(currState);
        }

        public AnimatorStateInfo GetStateInfo(string stateName)
        {
            return GetStateInfo(GetState<StateMotion>(stateName));
        }

        public BlendTreeInfo GetBlendTreeInfo(string stateName)
        {
            return GetBlendTreeInfo(GetState<StateMotion>(stateName));
        }

        public float GetBlendTick()
        {
            return m_BlendTick;
        }

        public void GetAnimationClips(List<AnimationClip> clips)
        {
            if (null == clips)
            {
                return;
            }

            for (var index = 0; index < m_States.Count; index++)
            {
                m_States[index].GetAnimationClips(clips);
            }
        }

        public void Reset()
        {
            m_IsValid = false;
            m_AnimCtrl = null;
            m_StateNotifyEvent = null;
        }

        public void RebuildPlayable(AnimatorController ctrl, int inputIndex, Action<StateNotifyType, string> stateNotify)
        {
            m_IsValid = true;
            m_AnimCtrl = ctrl;
            m_InternalIndex = inputIndex;

            m_InputCount = 0;
            m_StateNotifyEvent = stateNotify;
            m_StatePose = m_StatePose ?? new StatePose(this);
            m_StateNext = m_StateNext ?? new ToState(SwitchStateInNormalizedTime, stateName => GetState(stateName, m_States));
            m_DynamicStates = m_DynamicStates ?? new List<StateMotion>(8);
            m_CurrStateGroups = m_CurrStateGroups ?? new List<StateGroup>(8);
            m_DestStateGroups = m_DestStateGroups ?? new List<StateGroup>(8);
            if (null == m_ToDestinationStateAction) m_ToDestinationStateAction = InternalCrossFade;
            
            m_Playable = BonePrevMixer.BonePrevMixerPlayable.Create(animCtrl.playableGraph, m_PrevBone, m_States.Count + m_DynamicStates.Count + Mathf.CeilToInt(m_States.Count * 0.05f));
            m_Playable.EnableOverwrite = true;
            var playableParent = animCtrl.playable;
            playableParent.DisconnectInput(internalIndex);
            playableParent.ConnectInput(internalIndex, playable, 0, weight);
            playableParent.SetLayerAdditive((uint)internalIndex, blendingType == AnimatorControllerLayerBlendingType.Additive);
            if (null != avatarMask) playableParent.SetLayerMaskFromAvatarMask((uint)internalIndex, avatarMask);

            foreach (var state in m_States)
            {
                BuildStatePlayable(state);
            }

            foreach (var state in m_DynamicStates)
            {
                BuildStatePlayable(state);
            }
        }

        public AnimatorControllerLayer DeepCopy()
        {
            var layer = new AnimatorControllerLayer(m_Name, m_DefaultWeight, m_BlendingType)
            {
                m_DefaultSpeed = m_DefaultSpeed,
                m_IKPass = m_IKPass,
                m_SyncedLayerAffectsTiming = m_SyncedLayerAffectsTiming,
                m_SyncedLayerIndex = m_SyncedLayerIndex,
                m_DefaultStateName = m_DefaultStateName,
                m_AvatarMask = m_AvatarMask,
                m_States = new List<StateMotion>(),
                m_Groups = new List<StateGroup>()
            };

            for (var i = 0; i < statesCount; i++)
            {
                layer.m_States.Add(m_States[i].DeepCopy() as StateMotion);
            }

            for (var i = 0; i < groupsCount; i++)
            {
                layer.m_Groups.Add(m_Groups[i].DeepCopy());
            }

            return layer;
        }

        private bool CanToState(string stateName, float offsetTime)
        {
            if (float.IsNegativeInfinity(offsetTime) && null != currState && currState.name == stateName)
            {
                // Debug.Log($"[playable animator][frameCount:{Time.frameCount}][当前状态正在播放][{currState.name}]");
                m_StateNext.Clear();
                return false;
            }

            return true;
        }

        private AnimatorStateInfo GetStateInfo(StatePlayable state)
        {
            return null != state ? new AnimatorStateInfo(state.name, state.tag, state.isLooping, state.length, state.normalizedTime, state.speed, state.defaultSpeed, state.weight) : new AnimatorStateInfo();
        }

        private BlendTreeInfo GetBlendTreeInfo(StateMotion state)
        {
            if (state != null && state.isBlendTree)
            {
                var blendTree = state.motion as BlendTree;
                return new BlendTreeInfo(blendTree.minThreshold, blendTree.maxThreshold, blendTree.outSpeed, blendTree.outSpeedNorm);
            }

            return new BlendTreeInfo(0, 0, 0, 0);
        }

        private T GetState<T>(string name, List<T> states) where T : State
        {
            if (string.IsNullOrEmpty(name) || null == states)
            {
                return default;
            }

            for (var index = 0; index < states.Count; index++)
            {
                var state = states[index];
                if (state.name == name)
                {
                    return state;
                }
            }

            return default;
        }

        private T GetState<T>(int index, List<T> states) where T : State
        {
            if (index < 0 || null == states || index >= states.Count)
            {
                return null;
            }

            return states[index];
        }

        private bool AddState<T>(T state, List<T> states) where T : State
        {
            if (null == state || null == states || null != GetState<T>(state.name))
            {
                return false;
            }

            state.Reset();
            states.Add(state);
            return true;
        }

        private bool RemoveState<T>(string name, List<T> states) where T : State
        {
            var state = GetState(name, states);
            if (null == state)
            {
                return false;
            }

            states.Remove(state);
            return true;
        }

        private void SwitchStateInNormalizedTime(ToState.Info info)
        {
            if (null == info.destState)
            {
                return;
            }

            if (!info.isNormalizedTime)
            {
                SwitchStateInFixedTime(info);
                return;
            }

            info.offsetTime *= info.destState.length;
            info.transitionTime = info.transitionTime * currState?.length ?? 0f;
            info.isNormalizedTime = false;
            SwitchStateInFixedTime(info);
        }

        private void SwitchStateInFixedTime(ToState.Info info)
        {
            if (null == info.destState)
            {
                return;
            }

            if (info.isNormalizedTime)
            {
                SwitchStateInNormalizedTime(info);
                return;
            }

            if (m_BlendTick > 0 && !string.IsNullOrEmpty(info.fromName))
            {
                if (info.fromName == currState.name)
                {
                    m_StatePose.Enter(currState as StateMotion, prevState, currState);
                }
                else if (info.fromName == prevState.name)
                {
                    m_StatePose.Enter(prevState as StateMotion, prevState, currState);
                }
                else
                {
                    // Debug.LogError($"[playable animator][frameCount:{Time.frameCount}][切换状态异常！][状态非法：{info.fromName},请检查!!]");
                }

                prevState = null;
                currState = m_StatePose;
            }

            animCtrl.context.ModifyTransition(internalIndex, info.destState.name, info.destState.length, ref info.offsetTime);
            // Debug.LogError($"name: {state.name}, offsetTime: {info.offsetTime/ state.length}");
            if (info.transitionTime > 0 && info.destState.isRunning)
            {
                foreach (var dynamicState in m_DynamicStates)
                {
                    if (dynamicState.isRunning || dynamicState.internalHashID != info.destState.internalHashID) continue;
                    info.destState = dynamicState;
                    break;
                }

                if (info.destState.isRunning)
                {
                    if (!(info.destState.DeepCopy() is StateMotion state))
                    {
                        return;
                    }

                    info.destState = state;
                    m_DynamicStates.Add(state);
                }
            }

            if (!info.destState.isValid)
            {
                BuildStatePlayable(info.destState);
            }

            // var currStepValue = info.stepValue;
            // var offsetCorrection = 0f;
            var currStepValue = info.deltaTime;
            var offsetCorrection = info.deltaTime - info.stepValue;

            // Debug.Log($"[playable animator][frameCount:{Time.frameCount}][播放状态][{state.name}][stepValue:{info.stepValue}]");
            m_BlendTime = m_BlendTick = info.transitionTime;
            m_InterruptionSource = info.interruptionSource;

            oldestState = prevState;
            prevState?.OnExit(0, info.destState);

            prevState = currState;
            prevState?.OnExit(info.transitionTime - info.stepValue, info.destState);

            currState = info.destState;
            var cacheSpeed = info.destState.speed;
            currState.OnEnter(info.offsetTime - offsetCorrection * cacheSpeed, prevState);
            m_Playable.PrevInputIndex = (currState as StateMotion).internalIndex;
            var latestSpeed = currState.speed;
            prevState = prevState == currState ? oldestState : prevState;
            info.transition?.OnTransitioned();

            BlendState(info.stepValue, currStepValue * cacheSpeed / latestSpeed, 0);
        }

        private void BlendState(float deltaTime, float currStep, float prevStep)
        {
            var prevStateWeight = 0f;
            var currStateWeight = 1f;
            if (m_BlendTick > 0)
            {
                m_BlendTick -= deltaTime;
                prevStateWeight = Mathf.Clamp01(m_BlendTick / m_BlendTime);
                currStateWeight = 1 - prevStateWeight;
            }
            else if (m_BlendTick == 0)
            {
                m_BlendTick -= deltaTime;
                prevStateWeight = 0;
                currStateWeight = 1 - prevStateWeight;
            }

            BlendWeight(prevStateWeight, currStateWeight);

            if (m_InterruptionSource == TransitionInterruptionSource.None || m_InterruptionSource == TransitionInterruptionSource.DestinationThenSource)
            {
                var state = currState;
                var hashID = currState?.internalHashID;
                prevState?.OnUpdate(prevStep, m_BlendTick);
                if (state == null || state != currState || hashID != currState.internalHashID) return;
                currState.OnUpdate(currStep);
            }
            else
            {
                var state = prevState;
                var hashID = prevState?.internalHashID;
                currState?.OnUpdate(currStep);
                if (state == null || state != prevState || hashID != prevState.internalHashID) return;
                prevState.OnUpdate(prevStep, m_BlendTick);
            }
        }

        private void BlendWeight(float prevWeight, float currWeight)
        {
            if (internalIndex == 0)
            {
                prevState?.SetWeight(prevWeight);
                currState?.SetWeight(currWeight);
            }
            else
            {
                if (prevState != null && currState != null && prevState.hasEmptyClip && currState.hasEmptyClip)
                {
                    // 当prevState和currState都不为null，且都含有空clip时，layer权重设为0
                    ctrlPlayable.SetInputWeight(internalIndex, 0);
                }
                else if (prevState != null && currState != null && prevState.hasEmptyClip && !currState.hasEmptyClip)
                {
                    // 当prevState和currState都不为null，且只有prevState含有空clip时，currState的权重直接设为1，同时把currWeight设到layer上
                    currState.SetWeight(1);
                    prevState.SetWeight(0);
                    ctrlPlayable.SetInputWeight(internalIndex, currWeight * weight);
                }
                else if (currState != null && currState.hasEmptyClip)
                {
                    // 当currState不为null，且含有空clip时，直接设置layer的权重为prevWeight
                    ctrlPlayable.SetInputWeight(internalIndex, prevWeight * weight);
                }
                else
                {
                    prevState?.SetWeight(prevWeight);
                    currState?.SetWeight(currWeight);
                    ctrlPlayable.SetInputWeight(internalIndex, weight);
                }
            }
        }

        private void BuildStatePlayable(StateMotion state)
        {
            if (null == state)
            {
                return;
            }

            if (m_InputCount > playable.GetInputCount() - 1)
            {
                RebuildPlayable(animCtrl, internalIndex, m_StateNotifyEvent);
            }
            else
            {
                state.RebuildPlayable(this, m_InputCount++, m_ToDestinationStateAction, m_StateNotifyEvent);
            }
        }

        private class ToState
        {
            private Action<Info> m_ToSwitch;
            private Func<string, StateMotion> m_GetState;

            private string m_FromName;
            private string m_DestName;
            private float m_DeltaTime;
            private float m_StepValue;
            private float m_OffsetTime;
            private float m_TransitionTime;
            private bool m_IsNormalizedTime;
            private TransitionInterruptionSource m_InterruptionSource;
            private Transition m_Transition;

            public ToState(Action<Info> toSwitch, Func<string, StateMotion> getState)
            {
                m_ToSwitch = toSwitch;
                m_GetState = getState;
            }

            public void Clear()
            {
                m_FromName = null;
                m_DestName = null;
                m_StepValue = 0;
                m_OffsetTime = 0;
                m_TransitionTime = 0;
                m_InterruptionSource = TransitionInterruptionSource.None;
                m_Transition = null;
            }

            public void SetValue(bool isNormalizedTime, string fromName, string destName, float stepValue, float offsetTime, float transitionTime, TransitionInterruptionSource interruptionSource = TransitionInterruptionSource.None)
            {
                m_FromName = fromName;
                m_DestName = destName;
                m_DeltaTime = m_StepValue = stepValue;
                m_OffsetTime = offsetTime;
                m_TransitionTime = transitionTime;
                m_IsNormalizedTime = isNormalizedTime;
                m_InterruptionSource = interruptionSource;
                m_Transition = null;
            }

            public void SetValue(bool isNormalizedTime, string fromState, float deltaTime, float stepValue, float transitionTime, float offsetTime, Transition transition)
            {
                m_FromName = fromState;
                m_DestName = transition.destinationStateName;
                m_DeltaTime = deltaTime;
                m_StepValue = stepValue;
                m_OffsetTime = offsetTime;
                m_TransitionTime = transitionTime;
                m_IsNormalizedTime = isNormalizedTime;
                m_InterruptionSource = transition.interruptionSource;
                m_Transition = transition;
            }

            public bool Switch()
            {
                if (null == m_ToSwitch || null == m_GetState)
                {
                    return false;
                }

                var destState = m_GetState(m_DestName);
                if (null == destState)
                {
                    return false;
                }

                var info = new Info
                {
                    isNormalizedTime = m_IsNormalizedTime,
                    fromName = m_FromName,
                    destState = destState,
                    deltaTime = m_DeltaTime,
                    stepValue = m_StepValue,
                    offsetTime = float.IsNaN(m_OffsetTime) || float.IsNegativeInfinity(m_OffsetTime) ? 0 : m_OffsetTime,
                    transitionTime = m_TransitionTime,
                    interruptionSource = m_InterruptionSource,
                    transition = m_Transition,
                };
                Clear();
                m_ToSwitch(info);
                return true;
            }

            public struct Info
            {
                public StateMotion destState;
                public string fromName;
                public float deltaTime;
                public float stepValue;
                public float offsetTime;
                public float transitionTime;
                public bool isNormalizedTime;
                public bool requestTickPoseTime;
                public TransitionInterruptionSource interruptionSource;
                public Transition transition;
            }
        }
    }
}