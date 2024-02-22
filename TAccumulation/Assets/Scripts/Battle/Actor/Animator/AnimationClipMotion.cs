using X3.PlayableAnimator;

namespace X3Battle
{
    public enum MotionEndType
    {
        Interrupt,
        Complete,
    }
    
    public abstract class AnimationClipMotion : IConcurrent
    {
        public bool isPlaying => _isPlaying;
        protected bool _isLoop;
        protected bool _isPlaying;
        protected float _duration;
        protected float _curTime;

        public Motion owner { get; set; }

        public AnimationClipMotion(bool isLoop)
        {
            this._isLoop = isLoop;
        }
        
        public void OnDestroy()
        {
            _OnDestroy();
        }

        public void SetTime(double time)
        {
            if (!_isPlaying)
            {
                return;
            }
            
            // 非loop只播一次的动画，超时不再更新
            if (!_isLoop && time > _duration)
            {
                return;
            }

            _curTime = (float)time;
            
            _OnSetTime();
        }

        public void OnEnter()
        {
            _OnEnter();
        }

        public void OnExit()
        {
            _OnExit();
        }
        
        public void OnPrepEnter()
        {
            if (_isPlaying)
            {
                return;
            }

            _isPlaying = true;
            
            _OnPrepEnter();
        }

        public void OnPrepExit()
        {
            if (!_isPlaying)
            {
                return;
            }

            _isPlaying = false;

            // DONE: 处理结束原因.
            MotionEndType motionEndType = MotionEndType.Interrupt;
            if (!_isLoop)
            {
                if (_curTime >= _duration)
                {
                    motionEndType = MotionEndType.Complete;
                }
            }
            
            _OnPrepExit(motionEndType);
        }

        public abstract IConcurrent DeepCopy();
        
        public virtual void SetWeight(float weight)
        {
            
        }

        protected virtual void _OnSetTime()
        {
            
        }

        protected virtual void _OnEnter()
        {
            
        }

        protected virtual void _OnExit()
        {
            
        }

        protected virtual void _OnPrepEnter()
        {
            
        }

        protected virtual void _OnPrepExit(MotionEndType endType)
        {
            
        }

        protected virtual void _OnDestroy()
        {
            
        }
    }
}