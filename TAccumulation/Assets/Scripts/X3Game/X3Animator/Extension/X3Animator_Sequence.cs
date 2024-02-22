using System.Collections.Generic;


namespace X3Game
{
    public partial class X3Animator
    {
        private List<string> m_SequenceStates = new List<string>();
        private float m_SequenceTransitionDuration = -1;
        private int m_CurSequenceIdx;
        private bool m_IsWaitingForEnter;
        private bool m_IsSequencePlaying;

        /// <summary>
        /// 序列播放
        /// </summary>
        /// <param name="states">状态列表</param>
        /// <param name="transitionDuration">序列播放过渡时间，<0时使用状态默认过渡时间</param>
        public void PlaySequence(string[] states, float transitionDuration = -1)
        {
            if (states != null)
            {
                m_SequenceStates.Clear();
                for (int i = 0; i < states.Length; i++)
                {
                    if (HasState(states[i]))
                    {
                        m_SequenceStates.Add(states[i]);
                    }
                }
                m_SequenceTransitionDuration = transitionDuration;

                if (m_SequenceStates.Count > 0)
                {
                    m_IsSequencePlaying = true;
                    m_CurSequenceIdx = -1;
                    PlayNext();
                }   
            }
        }

        /// <summary>
        /// 停止序列播放
        /// </summary>
        /// <param name="stopCurAnim">是否停止当前动画</param>
        public void StopSequence(bool stopCurAnim = true)
        {
            m_SequenceStates.Clear();
            m_SequenceTransitionDuration = -1;
            m_CurSequenceIdx = -1;
            m_IsWaitingForEnter = false;
            m_IsSequencePlaying = false;
            if (stopCurAnim)
            {
                Stop();
            }
        }

        void PlayNext()
        {
            m_CurSequenceIdx++;
            if (m_CurSequenceIdx < m_SequenceStates.Count)
            {
                m_IsWaitingForEnter = true;
                if (m_CurSequenceIdx == 0)
                {
                    Play(m_SequenceStates[m_CurSequenceIdx]);
                }
                else
                {
                    Crossfade(m_SequenceStates[m_CurSequenceIdx], m_SequenceTransitionDuration);
                }
            }
            else
            {
                StopSequence(false);
                PlayDefault();
            }
        }

        void SequenceCheck()
        {
            if (m_IsSequencePlaying)
            {
                var duration = m_SequenceTransitionDuration;
                if (duration < 0)
                {
                    if (m_CurSequenceIdx < m_SequenceStates.Count)
                    {
                        var state = GetState(m_SequenceStates[m_CurSequenceIdx]);
                        if (state != null)
                        {
                            duration = state.DefaultTransitionDuration < 0
                                ? m_DefaultTransitionDuration
                                : state.DefaultTransitionDuration;
                        }
                    }
                    else
                    {
                        duration = 0;
                    }
                }

                if (CurStateLength - duration <= CurStateTime)
                {
                    PlayNext();
                }
            }
        }

        void OnStateEnterForSequence(string stateName)
        {
            if (m_IsSequencePlaying)
            {
                if (m_IsWaitingForEnter && stateName == m_SequenceStates[m_CurSequenceIdx])
                {
                    m_IsWaitingForEnter = false;
                }
                else
                {
                    StopSequence(false);
                }
            }
        }
    }
}