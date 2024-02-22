using System;
using PapeGames.X3;
using UnityEngine;
using System.Collections.Generic;
using UnityEngine.Playables;

namespace X3Game
{
    public partial class X3RuntimeStateController
    {
        [System.Serializable]
        public class Layer : IClearable
        {
            public ILayerEventReceiver EventReceiver { set; get; }
            private List<State> m_StateList;
            private Dictionary<int, State> m_StateDict;
            private string[] m_StateNames;
            private State m_Default;
            private State m_PrevPrevState;
            private State m_PrevState;
            private State m_CurState;
            private float m_DefaultTransitionDuration = 0.2f;
            private TransitionInfo m_TransitionInfo = new TransitionInfo();
            private readonly TransitionWorkHorse m_TransitionWorkHorse = new TransitionWorkHorse();
            private bool m_IsPaused = false;
            private bool m_IsPlaying = false;
            private readonly Queue<EventInfo> m_ToFireEventList = new Queue<EventInfo>();
            private int m_PlayedCount = 0;
            private bool m_EvaluateGuard = false;

            #region State Manipulation
            public State GetState(int nameHash)
            {
                if (nameHash == 0 || m_StateDict == null || !m_StateDict.TryGetValue(nameHash, out State state))
                {
                    string stateName = HashToStateName(nameHash);
                    return null;
                }
                return state;
            }
            
            public State GetState(string stateName)
            {
                int nameHash = StateNameToHash(stateName);
                return GetState(nameHash);
            }

            public bool StateExists(int nameHash)
            {
                if (nameHash == 0 || m_StateDict == null || !m_StateDict.ContainsKey(nameHash))
                    return false;
                return true;
            }
            
            public bool StateExists(string stateName)
            {
                int nameHash = StateNameToHash(stateName);
                return StateExists(nameHash);
            }
            
            public bool AddState(State state, bool setDefault = false)
            {
                if (state == null)
                {
                    X3Debug.LogErrorFormat("try to add a null state");
                    return false;
                }
                
                if (string.IsNullOrEmpty(state.Name))
                {
                    X3Debug.LogErrorFormat("try to add a state with invalid state name");
                    return false;
                }
                
                state.Layer = this;

                if (m_StateList == null || m_StateDict == null)
                {
                    m_StateList = new List<State>();
                    m_StateDict = new Dictionary<int, State>();
                }

                if (m_StateList.Contains(state))
                {
                    if (setDefault)
                        m_Default = state;
                    return true;
                }

                if (m_StateDict.ContainsKey(state.NameHash))
                {
                    X3Debug.LogErrorFormat("Alread existing state with same name: {0}", state.Name);
                    return false;
                }

                m_StateDict[state.NameHash] = state;
                m_StateList.Add(state);
                if (setDefault)
                    m_Default = state;

                if (LogEnabled)
                    X3Debug.LogFormat("Layer: {0}, AddState: {1}, defualt: {2}", this.Tag, state.Name, setDefault);
                UpdateStateNames();
                return true;
            }

            public bool RemoveState(string stateName)
            {
                int nameHash = StateNameToHash(stateName);
                return RemoveState(nameHash);
            }
            
            public bool RemoveState(int nameHash)
            {
                if (m_EvaluateGuard)
                {
                    X3Debug.LogErrorFormat("Layer: {0}, Cannot remove state in update call stack.", this.Tag);
                    return false;
                }
                if (nameHash == 0 || m_StateDict == null || m_StateList == null)
                    return false;
                if (m_StateDict.TryGetValue(nameHash, out State state))
                {
                    string stateName = state.Name;
                    m_StateList.Remove(state);
                    m_StateDict.Remove(nameHash);
                    if (m_TransitionInfo.NextState == state)
                        m_TransitionInfo.Clear();
                    if (m_Default == state)
                        m_Default = null;
                    if (m_PrevPrevState == state)
                        m_PrevPrevState = null;
                    if (m_PrevState == state)
                        m_PrevState = null;
                    if (m_CurState == state)
                    {
                        m_CurState = null;
                        if (!InternalPlayDefault())
                        {
                            //remove current state and have no default state equals to "STOP"
                            m_IsPlaying = false;
                            if (m_TransitionWorkHorse.IsValid())
                            {
                                m_TransitionWorkHorse.Stop();
                                m_PrevState?.ExternalExit();
                                foreach (var oState in m_StateList)
                                {
                                    oState.ExternalStop();
                                }
                            }
                        }
                    }
                    state.Destroy();
                    if (LogEnabled)
                        X3Debug.LogFormat("Layer: {0}, RemoveState: {1}", this.Tag, stateName);
                    UpdateStateNames();
                    return true;
                }
                return false;
            }

            public void ClearStates()
            {
                if (m_StateDict == null || m_StateList == null)
                    return;
                for (int i = m_StateList.Count - 1; i >= 0; i--)
                {
                    m_StateList[i].Destroy();
                }
                m_StateList.Clear();
                m_StateDict.Clear();
                m_StateNames = null;
                m_PrevPrevState = null;
                m_PrevState = null;
                m_CurState = null;
                m_Default = null;
                m_TransitionInfo.Clear();
                m_ToFireEventList.Clear();
                m_TransitionWorkHorse.Stop();
            }
            
            public bool SetDefault(string stateName)
            {
                int nameHash = StateNameToHash(stateName);
                return SetDefault(nameHash);
            }
            
            public bool SetDefault(int nameHash)
            {
                var state = GetState(nameHash);
                if (state == null)
                    return false;
                if (state == m_Default)
                    return true;
                var lastDefault = m_Default;
                lastDefault?.ExternalUpdateWrapMode(lastDefault.DefaultWrapMode);
                m_Default = state;
                if (LogEnabled)
                    X3Debug.LogFormat("Layer: {0}, SetDefault: {1}", this.Tag, state.Name);
                return true;
            }
            
            public void ClearDefault()
            {
                if (m_TransitionInfo.NextState == m_Default)
                    m_TransitionInfo.Clear();
                m_Default = null;
            }
            
            public string DefaultStateName
            {
                get => m_Default != null ? m_Default.Name : string.Empty;
            }

            public float DefaultTransitionDuration
            {
                set { m_DefaultTransitionDuration = Mathf.Max(0, value); }
                get { return m_DefaultTransitionDuration; }
            }

            public State PrevState
            {
                get => m_PrevState;
            }
            
            public State PrevPrevState
            {
                get => m_PrevPrevState;
            }
            
            public State CurState
            {
                get => m_CurState;
            }

            public int StateCount
            {
                get
                {
                    if (m_StateList == null)
                        return 0;
                    return m_StateList.Count;
                }
            }

            public string[] StateNames
            {
                get => m_StateNames;
            }

            public void Clear()
            {
                ClearStates();
                EventReceiver = null;
                m_PlayedCount = 0;
            }

            public void TraverseStates(System.Action<State> func)
            {
                if (func == null || m_StateList == null || m_StateList.Count == 0)
                    return;
                foreach (var state in m_StateList)
                {
                    func(state);
                }
            }

            private void UpdateStateNames()
            {
#if UNITY_EDITOR
                int count = StateCount;
                m_StateNames = new string[count];
                if (count > 0)
                {
                    for (int i=0; i< m_StateList.Count; i++)
                    {
                        m_StateNames[i] = m_StateList[i].Name;
                    }
                }
#endif
            }
            #endregion

            public bool PlayInFixedTime(string stateName, float initialTime, float transitionDuration, DirectorWrapMode? wrapMode)
            {
                if (string.IsNullOrEmpty(stateName))
                    return false;
                int nameHash = StateNameToHash(stateName);
                return InternalPlayInFixedTime(nameHash, initialTime, transitionDuration, wrapMode);
            }
            
            public bool Play(string stateName, float normalizedTimeOffset, float transitionDuration, DirectorWrapMode? wrapMode)
            {
                if (string.IsNullOrEmpty(stateName))
                    return false;
                var state = GetState(stateName);
                if (state == null)
                {
                    X3Debug.LogErrorFormat("find no state({0})", stateName);
                    return false;
                }
                float initialTime = normalizedTimeOffset;
                if (normalizedTimeOffset > 0)
                    initialTime = state.Length * normalizedTimeOffset;
                return InternalPlayInFixedTime(state.NameHash, initialTime, transitionDuration, wrapMode);
            }

            public bool PlayDefault()
            {
                if (m_Default == null)
                    return false;
                InternalPlayDefault();
                return true;
            }

            public void Pause()
            {
                if (!m_IsPlaying || m_IsPaused)
                    return;
                m_IsPaused = true;
                if (m_TransitionWorkHorse.IsValid())
                    m_PrevState?.ExternalPauseOrResume(true);
                m_CurState?.ExternalPauseOrResume(true);
            }
            
            public void Resume()
            {
                if (!m_IsPlaying || !m_IsPaused)
                    return;
                m_IsPaused = false;
                if (m_TransitionWorkHorse.IsValid())
                    m_PrevState?.ExternalPauseOrResume(false);
                m_CurState?.ExternalPauseOrResume(false);
            }

            public void Stop()
            {
                if (!m_IsPlaying)
                    return;
                
                if (m_TransitionWorkHorse.IsValid())
                {
                    m_PrevState?.ExternalExit();
                    m_TransitionWorkHorse.Stop();
                }
                m_CurState?.ExternalExit();
                    
                foreach (var state in m_StateList)
                {
                    state.ExternalStop();
                }

                m_PrevPrevState = null;
                m_PrevState = null;
                m_CurState = null;
                
                m_IsPlaying = false;
                m_IsPaused = false;
                m_TransitionInfo.Clear();
                if (LogEnabled)
                    X3Debug.LogFormat("Layer: {0}, Stop", this.Tag);
            }
            
            public bool IsPlaying
            {
                get => m_IsPlaying;
            }
            
            public bool IsPaused
            {
                get => m_IsPaused;
            }
            
            public int PlayedCount
            {
                get => m_PlayedCount;
            }

            private bool InternalPlayInFixedTime(int nameHash, float initialTime, float transitionDuration, DirectorWrapMode? wrapMode)
            {
                var nextState = GetState(nameHash);
                if (nextState == null)
                {
                    X3Debug.LogErrorFormat("find no state({0})", nameHash);
                    return false;
                }

                //todo:XTBUG-19615，A-B-B时会导致动作会有突变，暂时的处理方案为忽略后一个B。
                if (m_TransitionWorkHorse.IsValid() && m_CurState.NameHash == nameHash)
                {
                    //X3Debug.LogErrorFormat("already transition to state({0})", m_CurState.Name);
                    return false;
                }
                
                m_TransitionInfo.NextState = nextState;
                m_TransitionInfo.TransitionDuration = transitionDuration;
                m_TransitionInfo.InitialTime = initialTime;
                m_TransitionInfo.WrapMode = wrapMode;
                m_IsPlaying = true;
                m_IsPaused = false;
                m_PlayedCount++;
                return true;
            }

            private bool InternalPlayDefault()
            {
                if (m_Default == null)
                    return false;
                InternalPlayInFixedTime(m_Default.NameHash, 0, m_Default.DefaultTransitionDuration, DirectorWrapMode.Loop);
                m_TransitionInfo.IsPlayDefault = true;
                return true;
            }
            
            public void OnUpdate(float dt)
            {
                if (!m_IsPlaying || m_IsPaused)
                    return;
                m_EvaluateGuard = true;
                //需要切到下一个State
                if (m_TransitionInfo.NextState != null)
                {
                    //存在前一个crossfade
                    if (m_TransitionWorkHorse.IsValid())
                    {
                        m_PrevState?.ExternalSetWeight(0);
                        m_PrevState?.ExternalUpdate(dt);
                        m_PrevState?.ExternalExit();
                        m_CurState?.ExternalPostEnter();
                        m_TransitionWorkHorse.Stop();
                    }
                    
                    m_PrevPrevState = m_PrevState;
                    m_PrevState = m_CurState;
                    m_CurState = m_TransitionInfo.NextState;
                    m_CurState.ExternalWillEnter();
                    bool hasStateChanged = m_PrevState != m_CurState;

                    Tuple<float, DirectorWrapMode> nextStateInfo = GetStateInfoFromTransitionInfo(m_CurState);
                    float transitionDuration = m_TransitionInfo.TransitionDuration;
                    {
                        if (transitionDuration < 0)
                            transitionDuration = m_CurState.DefaultTransitionDuration >= 0 ? m_CurState.DefaultTransitionDuration : DefaultTransitionDuration;
                        if (transitionDuration > VADLID_DURATION)
                        {
                            float maxFadeOutDuration = (m_PrevState != null) ? m_PrevState.GetMaxFadeOutDuration() : 0;
                            float maxFadeInDuration = m_CurState.GetMaxFadeInDuration(nextStateInfo.Item1);
                            transitionDuration = Mathf.Min(transitionDuration, maxFadeOutDuration, maxFadeInDuration);
                            if (LogEnabled)
                                X3Debug.LogFormat(
                                    "X3Animator: final transition duration: {0}, maxFadeOut: {1}, maxFadeInt: {2}, origin: {3}",
                                    transitionDuration, maxFadeOutDuration, maxFadeInDuration,
                                    m_TransitionInfo.TransitionDuration);
                        }
                        else
                            transitionDuration = 0;
                    }

                    //transition does not equal to crossfade
                    bool transitionEligible = hasStateChanged && m_PrevState != null;
                    bool hasCrossfade = false;
                    if (transitionEligible)
                    {
                        float transitionProgress = 0;
                        if (transitionDuration > 0)
                        {
                            m_TransitionWorkHorse.Begin(transitionDuration);
                            transitionProgress = m_TransitionWorkHorse.Progress;
                            hasCrossfade = true;
                        }
                        else
                        {
                            transitionProgress = 1;
                        }
                        
                        m_PrevState.ExternalPreExit(transitionDuration);
                        m_PrevState.ExternalSetWeight(1 - transitionProgress);
                        m_PrevState.ExternalUpdate(dt);
                        if (!hasCrossfade)
                            m_PrevState.ExternalExit();
                        
                        m_CurState.ExternalInitStateInfo(nextStateInfo.Item1, nextStateInfo.Item2);
                        m_CurState.ExternalEnter(transitionDuration);
                        m_CurState.ExternalSetWeight(transitionProgress);
                        m_CurState.ExternalUpdate(0);
                        if (!hasCrossfade)
                            m_CurState.ExternalPostEnter();
                        m_ToFireEventList.Enqueue(new EventInfo(EventType.OnStateBegin, m_CurState.Name));
                    }
                    else
                    {
                        bool isReEnter = m_CurState == m_PrevState;
                        m_CurState.ExternalInitStateInfo(nextStateInfo.Item1, nextStateInfo.Item2);
                        m_CurState.ExternalEnter(0, isReEnter);
                        m_CurState.ExternalSetWeight(1);
                        m_CurState.ExternalUpdate(0);
                        if (!isReEnter)
                        {
                            m_CurState.ExternalPostEnter();
                            m_ToFireEventList.Enqueue(new EventInfo(EventType.OnStateBegin, m_CurState.Name));
                        }
                    }
                    
                    m_TransitionInfo.Clear();
                    if (hasStateChanged)
                        m_ToFireEventList.Enqueue(new EventInfo(EventType.OnStateChanged, m_PrevState != null ? m_PrevState.Name : string.Empty, m_CurState.Name));
                }
                else if (m_CurState != null)
                {
                    //正在crossfading
                    if (m_TransitionWorkHorse.IsValid())
                    {
                        m_TransitionWorkHorse.Tick(dt);
                        float p = m_TransitionWorkHorse.Progress;
                        if (m_PrevState == null)
                        {
                            p = 1;
                            m_TransitionWorkHorse.Stop();
                        }
                        bool hasTransitionCompleted = m_TransitionWorkHorse.IsCompleted() || !m_TransitionWorkHorse.IsValid();
                        m_PrevState?.ExternalSetWeight(1 - p);
                        m_PrevState?.ExternalUpdate(dt);
                        if (hasTransitionCompleted)
                            m_PrevState?.ExternalExit();
                        
                        m_CurState.ExternalSetWeight(p);
                        m_CurState.ExternalUpdate(dt);
                        if (hasTransitionCompleted)
                            m_CurState.ExternalPostEnter();
                        
                        if (hasTransitionCompleted)
                            m_TransitionWorkHorse.Stop();
                    }
                    else
                    {
                        if (m_CurState.WrapMode == DirectorWrapMode.None && m_Default == null && m_CurState.Length - m_CurState.Time < 0.0001) //不能用大于等于判断，MUMU模拟器上出现差了千分之二毫秒导致完不成
                        {
                            m_CurState.ExternalPreExit(0);
                            m_CurState.ExternalExit();
                            m_CurState.ExternalStop();
                            m_ToFireEventList.Enqueue(new EventInfo(EventType.OnStateEnd, m_CurState.Name));
                            m_CurState = null;
                            m_IsPlaying = false;
                        }
                        else
                        {
                            m_CurState.ExternalUpdate(dt);
                        }
                    }

                    //need transition to default
                    if (m_CurState != null)
                    {
                        if (m_CurState.WrapMode == DirectorWrapMode.None && m_Default != null &&
                            m_CurState.FixedExitTime - m_CurState.Time < 0.0001) //不能用大于等于判断，MUMU模拟器上出现差了千分之二毫秒导致完不成
                        {
                            m_ToFireEventList.Enqueue(new EventInfo(EventType.OnStateEnd, m_CurState.Name));
                            InternalPlayDefault();
                        }
                        else if (m_CurState.WrapMode != DirectorWrapMode.None && m_CurState.HasCrossedEnd)
                        {
                            m_ToFireEventList.Enqueue(new EventInfo(EventType.OnStateEnd, m_CurState.Name));
                        }
                    }
                }
                m_EvaluateGuard = false;
            }

            public void LateUpdate()
            {
                if (!m_IsPlaying || m_IsPaused)
                    return;
                if (m_TransitionWorkHorse.IsValid())
                    m_PrevState?.ExternalLateUpdate();
                m_CurState?.ExternalLateUpdate();
            }

            public void FireEvents()
            {
                while (m_ToFireEventList.Count > 0)
                {
                    var eventInfo = m_ToFireEventList.Dequeue();
                    switch (eventInfo.EventType)
                    {
                        case EventType.OnStateBegin:
                            EventReceiver?.OnStateBegin(this, (string)eventInfo.Param1);
                            break;
                        case EventType.OnStateEnd:
                            EventReceiver?.OnStateEnd(this, (string)eventInfo.Param1);
                            break;
                        case EventType.OnStateChanged:
                            EventReceiver?.OnStateChanged(this, (string)eventInfo.Param1, (string)eventInfo.Param2);
                            break;
                    }
                }
            }

            #region Context Atrrs
            public string Name { set; get; }
            public int Tag { set; get; }
            #endregion
            
            private System.Tuple<float, DirectorWrapMode> GetStateInfoFromTransitionInfo(State state)
            {
                DirectorWrapMode wrapMode = state.DefaultWrapMode;
                if(m_Default == state)
                    wrapMode = DirectorWrapMode.Loop;
                else if (m_TransitionInfo.WrapMode != null)
                    wrapMode = m_TransitionInfo.WrapMode.Value;
                float initialTime = m_TransitionInfo.InitialTime;
                if (initialTime < 0)
                    initialTime = state.WrapTime;
                if (wrapMode == DirectorWrapMode.None && initialTime >= state.Length)
                    initialTime = 0;
                return new Tuple<float, DirectorWrapMode>(initialTime, wrapMode);
            }
            
            private struct EventInfo
            {
                public EventType EventType;
                public System.Object Param1;
                public System.Object Param2;

                public EventInfo(EventType evtType, System.Object param1, System.Object param2 = null)
                {
                    EventType = evtType;
                    Param1 = param1;
                    Param2 = param2;
                }
            }
            
            private enum EventType
            {
                OnStateBegin,
                OnStateEnd,
                OnStateChanged
            }
        }
        [System.Serializable]
        public class TransitionWorkHorse
        {
            private float m_Duration = 0;
            private float m_Time = 0;

            public void Begin(float duration)
            {
                m_Duration = duration;
                m_Time = 0;
            }

            public void Tick(float dt)
            {
                if (!IsValid())
                    return;
                m_Time += dt;
            }

            public void Stop()
            {
                m_Duration = 0;
            }

            public float Progress
            {
                get
                {
                    if (!IsValid())
                        return 0;
                    return Mathf.Clamp01(m_Time / m_Duration);
                }
            }

            public bool IsCompleted()
            {
                if (!IsValid())
                    return false;
                return m_Time > m_Duration;
            }

            public bool IsValid()
            {
                return m_Duration > 0.00001f;
            }
        }
        [System.Serializable]
        public struct TransitionInfo
        {
            public State NextState;
            public float TransitionDuration;
            public float InitialTime;
            public DirectorWrapMode? WrapMode;
            public bool IsPlayDefault;

            public void Clear()
            {
                NextState = null;
                TransitionDuration = 0;
                InitialTime = -1;
                WrapMode = null;
                IsPlayDefault = false;
            }
        }

        public interface ILayerEventReceiver
        {
            void OnStateBegin(Layer layer, string stateName);
            void OnStateEnd(Layer layer, string stateName);
            void OnStateChanged(Layer layer, string prevStateName, string nextStateName);
        }
    }
}