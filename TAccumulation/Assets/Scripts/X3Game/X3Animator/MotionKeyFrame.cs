using System;
using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    [System.Serializable]
    public class KeyFrame
    {
        public KeyFrameType Type;
        public int FrameIdx;
        public string EventName;
        public string SoundName;
        public float FrameTime { set; get; }
        public float LastFireTime { set; get; }
    }

    public enum KeyFrameType
    {
        Default,
        Sound
    }
    
    public class MotionKeyFrame : IDisposable
    {
        const float KEYFRAME_TRIGGER_TOLERANCE = 0.03333f * 4;
        protected List<KeyFrame> m_KeyFrames;
        public virtual void ProcKeyFrame(float time, float duration)
        {
            if (m_KeyFrames == null || m_KeyFrames.Count == 0)
                return;

            float now = UnityEngine.Time.realtimeSinceStartup;
            float stateTime = time;
            for (int i = 0; i < m_KeyFrames.Count; i++)
            {
                var kf = m_KeyFrames[i];
                float delta = stateTime - kf.FrameTime;
                if (delta >= 0 && delta < KEYFRAME_TRIGGER_TOLERANCE && (now - kf.LastFireTime > duration - 0.001f))
                {
                    kf.LastFireTime = now;

                    X3Debug.LogFormat("X3Animator.InternalProcKeyFrame: frameIdx:{0}, frameTime:{1}, stateTime:{2}, eventName:{3}, soundName:{4}", kf.FrameIdx, kf.FrameTime, stateTime, kf.EventName, kf.SoundName);

                    if (kf.Type == KeyFrameType.Sound && !string.IsNullOrEmpty(kf.SoundName))
                    {
                        WwiseManager.Instance.LoadBankWithEventName(kf.SoundName);
                        WwiseManager.Instance.PlaySound(kf.SoundName);
                    }

                    if (!string.IsNullOrEmpty(kf.EventName))
                    {
                        EventMgr.Dispatch(kf.EventName, null);
                    }
                }
            }
        }
        public void ClearKeyFrameFireTime()
        {
            if (m_KeyFrames != null)
            {
                for (int i = 0; i < m_KeyFrames.Count; i++)
                {
                    m_KeyFrames[i].LastFireTime = 0;
                }
            }
        }
        public virtual void AddFrameKeys(IList<KeyFrame> kfList, float frameRate, float duration)
        {
            if(m_KeyFrames == null)
            {
                m_KeyFrames = new List<KeyFrame>();
            }

            if (kfList != null && kfList.Count > 0)
            {
                m_KeyFrames.Clear();
                foreach (var it in kfList)
                {
                    var kf = it;
                    kf.FrameTime = FrameIdxToTime(it.FrameIdx, frameRate, duration);
                    m_KeyFrames.Add(kf);
                }
            }
        }

        protected virtual float FrameIdxToTime(int frameIdx, float frameRate, float duration)
        {
            if (frameIdx <= 0 || frameRate <=0 || duration <= 0)
                return 0;

            float time = frameIdx / frameRate;
            time = Mathf.Clamp(time, 0, duration);

            return time;
        }

        public void Dispose()
        {
            m_KeyFrames?.Clear();
            m_KeyFrames = null;
        }
    }
}
