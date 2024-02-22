using PapeGames.X3;
using UnityEngine.Profiling;
using X3.PlayableAnimator;
using X3Battle.Timeline;

namespace X3Battle
{
    public class TimelineMotion : AnimationClipMotion
    {
        private int _moduleID;
        private string _enterLog;
        private string _extLog;
        private BattleSequencer _battleSequencer;
        private Actor _actor;
        public float duration => _duration;

        public TimelineMotion(int moduleID, Actor actor, bool isLoop) : base(isLoop)
        {
            this._moduleID = moduleID;
            _battleSequencer = null;
            _actor = actor;
            _CreateTimeline();
            _enterLog = string.Format("TimelineMotion.OnPreEnter {0} {1}", moduleID, _battleSequencer?.name);
            _extLog = string.Format("TimelineMotion.OnPreExit {0} {1}", moduleID, _battleSequencer?.name);
        }

        public TimelineMotion(int moduleID, Actor actor, bool isLoop, BattleSequencer battleSequencer) : base(isLoop)
        {
            this._moduleID = moduleID;
            _battleSequencer = battleSequencer;
            _actor = actor;
            _enterLog = string.Format("TimelineMotion.OnPreEnter {0} {1}", moduleID, _battleSequencer?.name);
            _extLog = string.Format("TimelineMotion.OnPreExit {0} {1}", moduleID, _battleSequencer?.name);
            _duration = _battleSequencer?.logicDuration ?? _battleSequencer?.artDuration ?? 0f;
        }

        public override IConcurrent DeepCopy()
        {
            return new TimelineMotion(this._moduleID, this._actor, this._isLoop, this._battleSequencer);
        }
        protected override void _OnDestroy()
        {
            _DeleteTimeline();
        }

        protected override void _OnSetTime()
        {
            using (ProfilerDefine.TimelineMotionSetTimePMarker.Auto())
            {
                if (_battleSequencer != null && _battleSequencer.GetComponent<BSCClock>().isManual)
                {
                    _battleSequencer.SetTime(_curTime);
                    _battleSequencer.Evaluate(true);
                }
            }
        }

        protected override void _OnPrepEnter()
        {
            // 目前OnEnter中什么都不用做
            if (_battleSequencer != null)
            {
                _battleSequencer.SetManual(true);
                if (_isLoop)
                {
                    _battleSequencer.SetRepeat(true);
                }
                _battleSequencer?.Play();
            }
            LogProxy.Log(_enterLog);
        }

        protected override void _OnPrepExit(MotionEndType endType)
        {
            using (ProfilerDefine.TimelineMotionOnExitPMarker.Auto())
            {

                if (_battleSequencer != null)
                {
                    if (endType == MotionEndType.Interrupt)
                    {
                        // DONE: 将手动模式切换成自动模式.
                        _battleSequencer.SetManual(false);
                        // DONE: 如果是循环模式, 则关闭循环模式.
                        if (_isLoop)
                        {
                            _battleSequencer.SetRepeat(false);
                        }

                        _battleSequencer.Interrupt();
                    }
                    else
                    {
                        _battleSequencer.Stop();
                    }

                    _battleSequencer.artTimelinePlayable?.TempFixStop();
                }
            }

            LogProxy.Log(_extLog);
        }

        private void _CreateTimeline()
        {
            if (_battleSequencer == null && _moduleID > 0 && _actor != null)
            {
                _duration = 0;
                _battleSequencer = _actor.sequencePlayer.PlayAnimatorTimeline(_moduleID, this);
                if (_battleSequencer != null)
                {
                    _duration = _battleSequencer.logicDuration ?? _battleSequencer.artDuration;
                    _battleSequencer.SetRepeat(_isLoop);
                }
            }
        }

        private void _DeleteTimeline()
        {
            if (_battleSequencer != null)
            {
                _battleSequencer.Destroy();
                _battleSequencer = null;
            }
        }
    }
}