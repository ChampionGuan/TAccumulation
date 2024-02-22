#if UNITY_EDITOR
    using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.Playables;

namespace X3Battle.Timeline.Preview.Sequence
{
    public class PreviewSequencer
    {
        private static double _frameTime = 1.0 / 30.0;
        public GameObject artObj { get; private set; }
        public TimelineExtInfo artExtInfo { get; private set; }
        public PlayableDirector artDirector { get; private set; }
        
        public double duration { get; private set; }
        public bool isThreeState { get; private set; }  // 是否三段式
        public double loopStartTime { get; private set; }  // 三段式loop阶段开始时间
        public double loopEndTime { get; private set; }  // 三段式loop阶段结束时间
        
        private bool _hasBrokenLoopState;  // 三段式已被打破
        private double _playTime;
        private bool _isPlaying;
        
            // 使用美术Timeline创建
        public PreviewSequencer(string artTimeline)
        {
            var fullPath = $"Assets/Build/Art/Timeline/Prefabs/{artTimeline}.prefab";
#if UNITY_EDITOR
            var timelineObj = AssetDatabase.LoadAssetAtPath<GameObject>(fullPath);
            if (timelineObj != null)
            {
                artObj = GameObject.Instantiate(timelineObj);
                artExtInfo = artObj.GetComponent<TimelineExtInfo>();
                artDirector = artObj.GetComponent<PlayableDirector>();
                duration = artDirector.duration;
                if (artExtInfo != null && artExtInfo.isThreeState)
                {
                    isThreeState = true;
                    loopStartTime = artExtInfo.loopStartFrame * _frameTime;
                    loopEndTime = artExtInfo.loopEndFrame * _frameTime;
                    if (loopEndTime > duration)
                    {
                        loopEndTime = duration;
                    }
                }
            }
#endif
        }
        
        public void Play()
        {
            if (!artDirector)
            {
                return;
            }

            if (_isPlaying)
            {
                return;
            }
            _isPlaying = true;
            _playTime = 0;
            _hasBrokenLoopState = false;
            artDirector.timeUpdateMode = DirectorUpdateMode.Manual;
            artDirector.Play();
        }

        public void Update(float deltaTime)
        {
            if (!artDirector)
            {
                return;
            }

            if (!_isPlaying)
            {
                return;
            }

            _playTime += deltaTime;
            
            if (isThreeState && !_hasBrokenLoopState)  // 三段式
            {
                if (_playTime >= loopEndTime)
                {
                    _playTime = loopStartTime;
                }
            }

            if (_playTime < duration)
            {
                artDirector.time = _playTime;
                artDirector.DeferredEvaluate();
            }
            else
            {
                Stop();
            }
        }
        
        public void StopLoopState()
        {
            if (!artDirector)
            {
                return;
            }
            _hasBrokenLoopState = true;
            if (isThreeState)
            {
                _playTime = loopEndTime;
            }
            else
            {
                Stop();
            }
        }

        public void Stop()
        {
            if (!artDirector)
            {
                return;
            }

            if (!_isPlaying)
            {
                return;
            }
            _isPlaying = false;
            
            artDirector.Stop();
        }

        public void Destroy()
        {
            Stop();
            if (artObj == null)
            {
                return;
            }  
            GameObject.DestroyImmediate(artObj);
        }
    }
}