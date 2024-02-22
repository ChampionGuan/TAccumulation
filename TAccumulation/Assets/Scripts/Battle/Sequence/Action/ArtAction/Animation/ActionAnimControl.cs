using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionAnimControl: X3Sequence.Action
    {
        private TimelineClip _timelineClip;
        private Playable _playable;
        private Playable _parentMixer;

        public ActionAnimControl(TimelineClip timelineClip, Playable clipPlayable, Playable parentMixer)
        {
            _timelineClip = timelineClip;
            _playable = clipPlayable;
            _parentMixer = parentMixer;
        }

        protected override void _OnInit()
        {
            _playable.Pause();
            _playable.SetDuration(duration);
            _parentMixer.SetInputWeight(_playable, 0.0f);
        }

        protected override void _OnEnter()
        {
            if (_parentMixer.IsValid())
            {
                _parentMixer.SetInputWeight(_playable, 1f);
            }
            _playable.Play();
            _EvaluateAnim(track.curTime);
        }

        protected override void _OnUpdate()
        {
            _EvaluateAnim(track.curTime);
        }

        protected override void _OnExit()
        {
            if (_parentMixer.IsValid())
            {
                _parentMixer.SetInputWeight(_playable, 0.0f);
            }
            _playable.Pause();
        }

        private void _EvaluateAnim(float localTime)
        {
            float weight = 1.0f;
            if (_timelineClip.IsPreExtrapolatedTime(localTime))
                weight = _timelineClip.EvaluateMixIn((float)_timelineClip.start);
            else if (_timelineClip.IsPostExtrapolatedTime(localTime))
                weight = _timelineClip.EvaluateMixOut((float)_timelineClip.end);
            else
                weight = _timelineClip.EvaluateMixIn(localTime) * _timelineClip.EvaluateMixOut(localTime);
            
            if (_parentMixer.IsValid())
                _parentMixer.SetInputWeight(_playable, weight);
            
            
            double clipTime = _timelineClip.ToLocalTime(localTime);
            if (clipTime.CompareTo(0.0) >= 0)
            {
                _playable.SetTime(clipTime);
            }
        }
    }
}