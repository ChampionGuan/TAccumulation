using PapeGames.X3;
using System.Collections.Generic;
using UnityEngine.Profiling;
using UnityEngine.UIElements;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class BlendTreeMotion : IConcurrent
    {
        protected List<TimelineMotion> _timelineMotions;
        protected float _weightOffset = 0.5f;
        protected float _length = 1;
        private bool _isPlaying;
        protected BlendTree _blendTree { get => owner as BlendTree; }

        public BlendTreeMotion(List<TimelineMotion> timelineMotions)
        {
            _timelineMotions = timelineMotions;
            _isPlaying = false;
        }

        public Motion owner { get; set; }

        public IConcurrent DeepCopy()
        {
            var copyTimelineMotions = new List<TimelineMotion>();

            foreach(var motion in _timelineMotions)
            {
                copyTimelineMotions.Add(motion.DeepCopy() as TimelineMotion);
            }
            return new BlendTreeMotion(copyTimelineMotions);
        }

        public void OnDestroy()
        {
            foreach(var motion in _timelineMotions)
            {
                motion.OnDestroy();
            }
        }

        public void OnEnter()
        {

        }

        public void OnExit()
        {

        }

        public void OnPrepEnter()
        {
            _isPlaying = true;
            for (int i = 0; i < _timelineMotions.Count; i++)
            {
                float weight = _blendTree.GetChildWeight(i);
                if (weight > _weightOffset)
                {
                    _timelineMotions[i].OnPrepEnter();
                    return;
                }
            }
        }

        public void OnPrepExit()
        {
            _isPlaying = false;
            for (int i = 0; i < _timelineMotions.Count; i++)
            {
                float weight = _blendTree.GetChildWeight(i);
                if (weight > _weightOffset)
                {
                    _timelineMotions[i].OnPrepExit();
                    return;
                }
            }
        }

        public void SetTime(double time)
        {
            if (!_isPlaying)
            {
                return;
            }
            for (int i = 0; i < _timelineMotions.Count; i ++)
            {
                float weight = _blendTree.GetChildWeight(i);
                if (weight > _weightOffset)
                {
                    if (!_timelineMotions[i].isPlaying)
                        _timelineMotions[i].OnPrepEnter();
                    _timelineMotions[i].SetTime(_timelineMotions[i].duration * _blendTree.normalizedTime);
                }
                else
                {
                    if (_timelineMotions[i].isPlaying)
                        _timelineMotions[i].OnPrepExit();
                }
            }
        }

        public void SetWeight(float weight)
        {
        }
    }
}
