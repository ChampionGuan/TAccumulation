using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using PapeGames.X3;

namespace X3Game
{
    public enum AnimGroupEventType
    {
        Start,
        Loop,
        Complete,
    }
    [SerializeField]
    public class AnimGroupEvent : UnityEngine.Events.UnityEvent<string, AnimGroupEventType> { }

    [AddComponentMenu("TinaUI/Comp/AnimGroup")]
    [ExecuteInEditMode]
    public class AnimGroup : MonoBehaviour, IMotion
    {
        [SerializeField]
        string m_Key;
        public string Key { get { return m_Key; } }

        [SerializeField]
        int m_UID;

        [SerializeField]
        List<AnimInfo> m_AnimList = new List<AnimInfo>();

        public List<AnimInfo> AnimList { get { return m_AnimList; } }

        [SerializeField]
        List<MotionResolvedInfo> m_AnimResolvedList = new List<MotionResolvedInfo>();

        [SerializeField]
        int m_LoopTimes = 1;

        [SerializeField, HideInInspector]
        float m_Progress = 0;

        public AnimGroupEvent OnAnimationEvent = new AnimGroupEvent();

        PlayableGraph m_Graph;
        double m_Time = 0;
        int m_PlayedCount = 0;
        double m_Duration = 0;

        Dictionary<GameObject, List<AnimationPlayableInfo>> m_AnimationPlayableDict = new Dictionary<GameObject, List<AnimationPlayableInfo>>();

        [IMotionAttr()]
        public void Play()
        {
            if (m_AnimList.Count == 0)
                return;
            m_PlayedCount = 0;
            ExePlay(0);
        }

        public void Pause()
        {

        }

        public void Resume()
        {

        }

        [IMotionAttr()]
        public void Stop()
        {
            if (m_Graph.IsValid())
                m_Graph.Destroy();
        }

        public void Reset()
        {
            m_PlayedCount = 0;
        }

        public void Refresh()
        {
            m_PlayedCount = 0;
            ResolvePlayableInfo();
            GenerateGraph();
        }

        public void Progress(float t)
        {
            if(!m_Graph.IsValid())
            {
                Refresh();
            }

            PlayableGraphUtility.SetGraphTime(ref m_Graph, t * m_Duration);
        }

        void ExePlay(double t = 0)
        {
            bool isLoop = m_PlayedCount > 0;
            ResolvePlayableInfo(isLoop);
            GenerateGraph();
            if (m_Graph.IsValid())
            {
                PlayableGraphUtility.ResetGraph(ref m_Graph);
                m_Graph.Play();
                m_Graph.Evaluate((t == 0) ? 0.001f : (float)t);
                m_PlayedCount++;
            }
        }

        #region IAnimator
        public double Duration { get { return m_Duration; } }

        public bool TimeControlable { get { return true; } }

        public void OnControlTimeStart()
        {
            ResolvePlayableInfo();
            GenerateGraph();
        }

        public void OnControlTimeStop()
        {
            if (m_Graph.IsValid())
                m_Graph.Destroy();
        }

        public void SetTime(double t)
        {
            if (!m_Graph.IsValid())
            {
                ResolvePlayableInfo();
                GenerateGraph();
            }

            if(m_Graph.IsValid())
            {
                m_Time = t;
                PlayableGraphUtility.SetGraphTime(ref m_Graph, t);
            }
        }

        public GameObject GameObject { get { return gameObject; } }

        public bool IsNull { get { return this == null; } }

        public int UID { get { return m_UID; } }

        public bool IsPlaying { get { return m_Graph.IsValid() ? m_Graph.IsPlaying() : false; } }

        public System.Type GetActualType()
        {
            return typeof(AnimGroup);
        }

        public void GatherProperties(IPropertyCollector driver)
        {
            foreach(var info in m_AnimList)
            {
                if (info.AC == null)
                    continue;
                driver.AddFromClip(info.OutputTarget == null ? gameObject : info.OutputTarget, info.AC);
            }
        }

        #endregion

        void ResolvePlayableInfo(bool isLoop = false)
        {
            if (this == null)
                return;
            m_AnimationPlayableDict.Clear();
            m_AnimResolvedList.Clear();
            m_Duration = 0;
            double lastDelay = 0;
            for (int i = 0; i < m_AnimList.Count; i++)
            {
                var info = m_AnimList[i];
                if (!info.PlayInLoop && isLoop)
                    continue;

                MotionResolvedInfo reslovedInfo = new MotionResolvedInfo();
                GameObject outputTarget = info.OutputTarget == null ? gameObject : info.OutputTarget;

                double thisDelay = 0;
                {
                    if (info.DelayType == DelayType.Random)
                        thisDelay = Random.Range(info.DelayMin, info.DelayMax);
                    else if(info.DelayType == DelayType.Constant)
                        thisDelay = info.Delay;
                    if (info.DelayAnchor == DelayAnchor.Last)
                    {
                        thisDelay += lastDelay;
                    }
                }
                reslovedInfo.Start = (float)thisDelay;

                if (info.Type == AnimationType.Animation)
                {
                    reslovedInfo.Duration = info.AC != null ? info.AC.length : 0;
                }

                reslovedInfo.Duration /= info.Speed;
                reslovedInfo.End = reslovedInfo.Start + reslovedInfo.Duration;
                lastDelay = reslovedInfo.End;

                m_AnimResolvedList.Add(reslovedInfo);

                if (info.Type == AnimationType.Animation)
                {
                    List<AnimationPlayableInfo> list;
                    if(!m_AnimationPlayableDict.TryGetValue(outputTarget, out list))
                    {
                        list = new List<AnimationPlayableInfo>();
                        m_AnimationPlayableDict.Add(outputTarget, list);
                    }

                    AnimationPlayableInfo playableInfo = new AnimationPlayableInfo()
                    {
                        OutputTarget = outputTarget,
                        AC = info.AC,
                        Speed = info.Speed,
                        ResolvedInfo = reslovedInfo
                    };
                    list.Add(playableInfo);
                }

                if (lastDelay > m_Duration)
                    m_Duration = lastDelay;
            }
        }

        bool GenerateGraph()
        {
            if (m_Graph.IsValid())
                m_Graph.Destroy();

            if (m_Duration <= 0 || m_AnimationPlayableDict.Count == 0)
                return false;

            m_Graph = PlayableGraph.Create(gameObject.name);
            ProgressPlayable.Create(m_Graph, 0, gameObject, m_Duration, OnInternalComplete, OnInternalStart, OnInternalUpdate, ProgressPlayable.PlayMode.Graph);
            foreach (var it in m_AnimationPlayableDict)
            {
                //AnimGroupMixerPlayable.Create(m_Graph, it.Value, m_Duration);
            }

            return true;
        }

        bool HasRandomDelay()
        {
            foreach(var it in m_AnimList)
            {
                if (it.DelayType == DelayType.Random)
                    return true;
            }
            return false;
        }

        void Start()
        {
            Animator animator = GetComponent<Animator>();
            if (animator && Application.isPlaying)
                animator.runtimeAnimatorController = null;
        }

        #region Events
        public void OnAnimStart()
        {
            //Debug.LogFormat("OnAnimStart");
            OnAnimationEvent.Invoke(Key, AnimGroupEventType.Start);
        }

        public void OnAnimLoop()
        {
            //Debug.LogFormat("OnAnimLoop");
            OnAnimationEvent.Invoke(Key, AnimGroupEventType.Loop);
        }

        public void OnAnimComplete()
        {
            //Debug.LogFormat("OnAnimComplete");
            OnAnimationEvent.Invoke(Key, AnimGroupEventType.Complete);
        }

        void OnInternalComplete(ProgressInfo info, bool completed)
        {
            if (m_Graph.IsValid())
                m_Graph.Stop();

            if (m_LoopTimes > 0 && m_PlayedCount >= m_LoopTimes)
            {
                OnAnimComplete();
            }
            else
            {
                //Debug.LogFormat("m_LoopTimes == 0");
                OnAnimLoop();
                ExePlay();
            }
        }

        void OnInternalStart(ProgressInfo info)
        {
            if(m_PlayedCount < 2)
                OnAnimStart();
        }

        void OnInternalUpdate(ProgressInfo info)
        {
            m_Progress = (float)info.Progress;
        }

        #endregion

#if UNITY_EDITOR
        private void OnValidate()
        {
            if (!gameObject.scene.IsValid())
                return;

            if (m_UID == 0)
                m_UID = GetInstanceID();
        }

        public void DebugReset()
        {
            if (m_Graph.IsValid())
                PlayableGraphUtility.ResetGraph(ref m_Graph);
        }

        public void DebugPlay()
        {
            if (m_Graph.IsValid())
                m_Graph.Play();
        }

        public void DebugStop()
        {
            if (m_Graph.IsValid())
                m_Graph.Stop();
        }
#endif

        private void OnDisable()
        {
            if (m_Graph.IsValid())
                m_Graph.Destroy();
        }

        private void OnDestroy()
        {
            if (m_Graph.IsValid())
                m_Graph.Destroy();
            m_AnimationPlayableDict.Clear();
            OnAnimationEvent.RemoveAllListeners();
        }

        public enum DelayType
        {
            None,
            Constant,
            Random
        }

        public enum DelayAnchor
        {
            Start,
            Last
        }

        [System.Serializable]
        public struct AnimInfo
        {
            public AnimationType Type;
            public float Speed;
            public GameObject OutputTarget;

            public float Delay;
            public float DelayMin;
            public float DelayMax;
            public DelayType DelayType;
            public DelayAnchor DelayAnchor;

            public AnimationClip AC;
            public MoveData MoveData;
            public ScaleData ScaleData;
            public AlphaData AlphaData;
            public ColorData ColorData;

            public bool PlayInLoop;
        }

        public struct AnimationPlayableInfo
        {
            public AnimationType Type;
            public float Speed;
            public MotionResolvedInfo ResolvedInfo;
            public GameObject OutputTarget;
            public AnimationClip AC;
        }

        public enum AnimationType
        {
            None = 0,
            Animation = 1,
            Move = 2,
            Scale = 3,
            Alpha = 4,
            Color = 5
        }

        [System.Serializable]
        public struct MoveData
        {
        }

        [System.Serializable]
        public struct ScaleData
        {
        }

        [System.Serializable]
        public struct AlphaData
        {
        }

        [System.Serializable]
        public struct ColorData
        {
        }
    }
}
