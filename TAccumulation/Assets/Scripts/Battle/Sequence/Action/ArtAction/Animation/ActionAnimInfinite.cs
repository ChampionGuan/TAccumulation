using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionAnimInfinite: X3Sequence.Action
    {
        private Playable _playable;
        private Playable _parentMixer;

        public ActionAnimInfinite(Playable clipPlayable, Playable parentMixer)
        {
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
            _EvaluateAnim(curOffsetTime);
        }

        protected override void _OnUpdate()
        {
            _EvaluateAnim(curOffsetTime);
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
            _playable.SetTime(localTime);
        }
    }
}