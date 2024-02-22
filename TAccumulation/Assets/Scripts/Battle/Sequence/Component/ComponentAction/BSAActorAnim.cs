using System;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class BSAActorAnim: X3Sequence.Action
    {
        private Actor _actor;
        private string _animName;
        private BattleSequencer _battleSequencer;
        private bool _isDelayAnim;
        private Action<ECEventDataBase> _actionStartDelayAnim;

        public void SetData(Actor actor, BattleSequencer battleSequencer, string animName)
        {
            _actor = actor;
            _animName = animName;
            _battleSequencer = battleSequencer;
            _actionStartDelayAnim = _OnEventStartDelayAnim;
        }

        public void ActiveDelay( bool isDelayAnim = false)
        {
            _isDelayAnim = isDelayAnim;
        }

        protected override void _OnEnter()
        {
            if (_isDelayAnim)
            {
                if (_actor != null)
                {
                    _actor.eventMgr.AddListener(EventType.StartDelayAnim, _actionStartDelayAnim, "BSAActorAnim._OnEventStartDelayAnim");
                }
            }
            else
            {
                _PlayAnim();
            }
        }

        protected override void _OnExit()
        {
            if (_isDelayAnim && _actor != null)
            {
                _actor.eventMgr.RemoveListener(EventType.StartDelayAnim, _actionStartDelayAnim);
            }
        }
        
        private void _OnEventStartDelayAnim(ECEventDataBase arg)
        {
            _PlayAnim();
        }
        
        private void _PlayAnim()
        {
            if (_actor != null && !string.IsNullOrEmpty(_animName))
            {
                PapeGames.X3.LogProxy.LogFormat("timeline尝试播放Animator动画 {0}", _animName);
                using (ProfilerDefine.BSAActorAnimGetSpeedMarker.Auto())
                {
                    var speed = _battleSequencer.GetComponent<BSCClock>().GetScale();
                    _actor.animator?.PlayAnim(_animName, startOffsetTime, 0, stateSpeed: speed * _actor.animator.GetAnimatorStateInfo(0, _animName).defaultSpeed);
                }
            }
        }
    }
}