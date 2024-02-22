using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Game
{
    /// <summary>
    /// 目前PPV动画直接使用的X3Animator播放，预留一个可以播放多个效果的PPVCtrl
    /// </summary>
    [XLua.LuaCallCSharp]
    [RequireComponent(typeof(Animator))]
    public class PPVAnimCtrl : MonoBehaviour
    {
        public static int MaxPortCnt = 10;
        private PlayableGraph m_Graph;
        private AnimationPlayableOutput m_Output;
        private AnimationMixerPlayable m_Mixer;
        private Dictionary<string, PPVAnimData> m_AnimDict = new Dictionary<string, PPVAnimData>();
        private Dictionary<int, bool> m_SlotUsed = new Dictionary<int, bool>();

        public void OnEnable()
        {
            InitPlayableGraph();
        }

        public void OnDisable()
        {
            DestroyPlayableGraph();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="stateName"></param>
        /// <param name="clip"></param>
        public void AddState(string stateName, AnimationClip clip, DirectorWrapMode wrapMode = DirectorWrapMode.None,
            DirectorUpdateMode updateMode = DirectorUpdateMode.GameTime)
        {
            if (m_AnimDict.ContainsKey(stateName))
            {
                RemoveState(stateName);
            }

            var playable = AnimationClipPlayable.Create(m_Graph, clip);
            playable.SetDuration(clip.length);
            var idleSlotIndex = GetIdleSlot();
            m_SlotUsed[idleSlotIndex] = true;
            m_Mixer.ConnectInput(idleSlotIndex, playable, 0, 1f);
            PPVAnimData animData = new PPVAnimData();
            animData.Name = stateName;
            animData.Clip = clip;
            animData.Playable = playable;
            animData.WrapMode = wrapMode;
            animData.UpdateMode = updateMode;
            animData.SlotIndex = idleSlotIndex;
            m_AnimDict[stateName] = animData;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="stateName"></param>
        public void RemoveState(string stateName)
        {
            if (m_AnimDict.ContainsKey(stateName))
            {
                var animData = m_AnimDict[stateName];
                animData.Clip = null;
                m_Mixer.DisconnectInput(animData.SlotIndex);
                //必须调用这个才能使得Clip没有残留，这是为什么？
                m_Mixer.ConnectInput(animData.SlotIndex, Playable.Null, 0, 0);
                animData.Playable.Destroy();
                m_SlotUsed[animData.SlotIndex] = false;
                m_AnimDict.Remove(stateName);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="stateName"></param>
        /// <param name="progress"></param>
        public void ManualEvaluate(string stateName, float progress)
        {
            if (m_AnimDict.ContainsKey(stateName))
            {
                var playable = m_AnimDict[stateName].Playable;
                if (playable.IsValid())
                {
                    playable.SetTime(progress * playable.GetDuration());
                }
            }
        }

        /// <summary>
        /// 初始化PlayableGraph
        /// </summary>
        private void InitPlayableGraph()
        {
            var animator = GetComponent<Animator>();
            animator.runtimeAnimatorController = null;
            m_Graph = PlayableGraph.Create(name);
            m_Graph.SetTimeUpdateMode(DirectorUpdateMode.Manual);
            m_Output = AnimationPlayableOutput.Create(m_Graph, "Animation", GetComponent<Animator>());
            m_Mixer = AnimationMixerPlayable.Create(m_Graph, MaxPortCnt);
            for (int i = 0; i < MaxPortCnt; i++)
            {
                m_SlotUsed[i] = false;
            }

            m_Output.SetSourcePlayable(m_Mixer);
            foreach (var kvPair in m_AnimDict)
            {
                var playable = AnimationClipPlayable.Create(m_Graph, kvPair.Value.Clip);
                playable.SetDuration(kvPair.Value.Clip.length);
                m_Mixer.ConnectInput(kvPair.Value.SlotIndex, playable, 0, 1f);
                var animData = m_AnimDict[kvPair.Key];
                animData.Playable = playable;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private int GetIdleSlot()
        {
            foreach (var kvPair in m_SlotUsed)
            {
                if (kvPair.Value == false)
                {
                    return kvPair.Key;
                }
            }

            return -1;
        }

        /// <summary>
        /// 
        /// </summary>
        public void LateUpdate()
        {
            if (!m_Graph.IsValid())
                return;

            foreach (var kvPair in m_AnimDict)
            {
                var animData = kvPair.Value;
                if (animData.Playable.IsValid())
                {
                    switch (animData.UpdateMode)
                    {
                        case DirectorUpdateMode.GameTime:
                            var playableTime = animData.Playable.GetTime() + Time.deltaTime;
                            if (animData.WrapMode == DirectorWrapMode.Hold)
                            {
                                playableTime = math.min(playableTime, animData.Playable.GetDuration());
                            }

                            animData.Playable.SetTime(playableTime);
                            break;
                        case DirectorUpdateMode.UnscaledGameTime:
                            playableTime = animData.Playable.GetTime() + Time.unscaledDeltaTime;
                            if (animData.WrapMode == DirectorWrapMode.Hold)
                            {
                                playableTime = math.min(playableTime, animData.Playable.GetDuration());
                            }

                            animData.Playable.SetTime(playableTime);
                            break;
                        case DirectorUpdateMode.Manual:
                            //ManualTick
                            break;
                    }
                }
            }

            m_Graph.Evaluate();
        }

        /// <summary>
        /// 销毁PlayableGraph
        /// </summary>
        private void DestroyPlayableGraph()
        {
            if (m_Graph.IsValid())
            {
                var keys = new List<string>(m_AnimDict.Keys);
                foreach (var key in keys)
                {
                    RemoveState(key);
                }                
                m_AnimDict.Clear();
                m_Graph.DestroyPlayable(m_Mixer);
                m_Graph.DestroyOutput(m_Output);
                m_Graph.Destroy();
            }
        }

        struct PPVAnimData
        {
            public string Name;
            public AnimationClip Clip;
            public AnimationClipPlayable Playable;
            public DirectorWrapMode WrapMode;
            public DirectorUpdateMode UpdateMode;
            public int SlotIndex;
        }
    }
}