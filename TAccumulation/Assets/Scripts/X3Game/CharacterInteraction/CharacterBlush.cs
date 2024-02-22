using System.Collections.Generic;
using Framework;
using PapeAnimation;
using PapeGames.X3;
using UnityEditor;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Game
{
    public interface ICharacterBlushDelegate
    {
        void OnMoveinCpl(int playId);
        void OnMoveoutCpl(int playId);
    }

    public class CharacterBlush : MonoBehaviour
    {
        /// <summary>
        /// 自++的PlayId
        /// </summary>
        public static int playId = 0;
        
        /// <summary>
        /// CrossFadeTime
        /// </summary>
        public float crossFadeTime = 0.3f;

        /// <summary>
        /// 根据PlayableGraph自动Tick
        /// </summary>
        public bool autoTick = true;

        ///
        public bool needDestroy = false;

        /// <summary>
        /// 角色身上的Animator
        /// </summary>
        private Animator m_Animator;
        
        /// <summary>
        /// 用来控制CrossFade的Mixer
        /// </summary>
        private GenericAnimationTree m_Mixer;

        /// <summary>
        /// State字典
        /// </summary>
        private Dictionary<int, CharacterBlushState> m_StateDict = new Dictionary<int, CharacterBlushState>();
        
        /// <summary>
        /// 权重，用来做CrossFade用
        /// </summary>
        private float m_Weight = 1;
        private CharacterBlushState m_CurrentState;
        private CharacterBlushState m_LastState;
        private ICharacterBlushDelegate m_Delegate;

        public void Init()
        {
            m_Mixer = GenericAnimationTree.Create(MixerType.Mixer);
            m_Animator = GetComponent<Animator>();
            PlayableAnimationManager.Instance().AddDynamicNode(m_Animator, m_Mixer, MixerType.LayerMixer);
        }

        public void SetDelegate(ICharacterBlushDelegate del)
        {
            m_Delegate = del;
        }

        public void RemoveDelegate()
        {
            m_Delegate = null;
        }

        /// <summary>
        /// 新创建一个State
        /// </summary>
        public int CreateState(AnimationClip moveinClip, AnimationClip moveoutClip, AnimationClip loopClip)
        {
            needDestroy = false;
            var state = new CharacterBlushState(m_Mixer, ++playId);
            state.SetAnimationClips(moveinClip, moveoutClip, loopClip);
            state.SetAutoTick(autoTick);
            state.SetCallback(OnMoveinCpl, OnMoveoutCpl);
            m_StateDict[playId] = state;
            return playId;
        }

        /// <summary>
        /// 设置Tick模式
        /// </summary>
        /// <param name="value"></param>
        public void SetAutoTick(bool value)
        {
            autoTick = value;
            foreach (var state in m_StateDict)
            {
                if (state.Value != null)
                {
                    state.Value.SetAutoTick(autoTick);
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="playId"></param>
        public void CrossFade(int playId)
        {
            needDestroy = false;
            if (m_StateDict.ContainsKey(playId))
            {
                var state = m_StateDict[playId];
                if (m_LastState != null)
                {
                    DestroyState(m_LastState);
                    m_LastState = null;
                }

                bool needCrossFade = false;
                if (m_CurrentState != null)
                {
                    m_LastState = m_CurrentState;
                    needCrossFade = true;
                }
               
                m_CurrentState = state;
                if (needCrossFade)
                {
                    m_Weight = 0;
                    m_CurrentState.SetBlushLoop();
                }
                else
                {
                    m_Weight = 1;
                    m_CurrentState.Play();
                }
            }
            else
            {
                X3Debug.LogFormat("CharacterBlush-没有找到对应的State{0}", playId);
            }
        }

        /*private void CheckDestroyMixer()
        {
            if (m_CurrentState == null && m_LastState == null && m_Mixer.IsValid())
            {
                m_Output.SetSourcePlayable(Playable.Null);
                m_Mixer.Destroy();
                m_Mixer = AnimationMixerPlayable.Create(m_GraphBlush, 2);
                m_Output.SetSourcePlayable(m_Mixer);
                m_GraphBlush.Evaluate();
            }
        }*/

        /// <summary>
        /// 设置进度
        /// </summary>
        /// <param name="progress"></param>
        public void SetProgress(float progress)
        {
            if (m_CurrentState != null)
            {
                m_CurrentState.SetProgress(progress);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public void Play()
        {
            if (m_CurrentState != null)
            {
                m_CurrentState.Play();
            }
        }

        /// <summary>
        /// 直接开始循环
        /// </summary>
        public void Loop()
        {
            if (m_CurrentState != null)
            {
                m_CurrentState.SetBlushLoop();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="playId"></param>
        public void Stop()
        {
            if (m_CurrentState != null)
            {
                m_CurrentState.Stop();
            }
        }

        private void OnMoveinCpl(int playId)
        {
            m_Delegate?.OnMoveinCpl(playId);
        }

        private void OnMoveoutCpl(int playId)
        {
            m_Delegate?.OnMoveoutCpl(playId);
        }

        public void DestroyState(CharacterBlushState state)
        {
            m_StateDict[state.playId] = null;
            state.Destroy();
        }
        
        public void PlayGraph()
        {
            m_Mixer.SetWeight(1);
        }

        public void StopGraph()
        {
            m_Mixer.SetWeight(0);
        }

        public void CleanUp()
        {
            if (m_CurrentState != null)
            {
                m_CurrentState.CleanUp();
            }
            needDestroy = true;
        }

        private void Update()
        {
            if (m_CurrentState != null && m_CurrentState.IsFinish())
            {
                DestroyState(m_CurrentState);
                m_CurrentState = null;
            }

            if (m_LastState != null && m_LastState.IsFinish())
            {
                DestroyState(m_LastState);
                m_LastState = null;
            }

            if (m_CurrentState == null && m_LastState == null)
            {
                m_Mixer.SetWeight(0);
            }
            else
            {
                m_Mixer.SetWeight(1);
            }
        }
        
        private void LateUpdate()
        {
            if (needDestroy)
            {
                Destroy(this);
                return;
            }
            if (m_Mixer != null)
            {
                if (m_Weight < 1)
                {
                    m_Weight += Time.deltaTime / crossFadeTime;
                    m_Weight = Mathf.Min(m_Weight, 1);
                    if (m_Weight == 1 && m_LastState != null)
                    {
                        m_LastState.Finish();
                    }
                }
                if (m_CurrentState != null)
                {
                    m_CurrentState.LateUpdate();
                    m_CurrentState.GetTreeRoot().SetWeight(m_Weight);
                }

                if (m_LastState != null)
                {
                    m_LastState.LateUpdate();
                    m_CurrentState.GetTreeRoot().SetWeight(1 - m_Weight);
                }
            }
        }
        
        public void OnDestroy()
        {
            foreach (var state in m_StateDict)
            {
                if (state.Value != null)
                {
                    state.Value.Destroy();
                }
            }
            m_StateDict.Clear();
            PlayableAnimationManager.Instance().RemoveDynamicNode(m_Mixer, true);
            m_Mixer = null;
        }
    }
}

