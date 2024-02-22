using UnityEngine;

namespace X3Battle
{
    public class BSCClock : BSCBase, IReset
    {
        private float _tickTime;
        private float _curPlayTime;
        private float _scale;
        public bool isWholeRepeat { get; private set; }
        private float? _leftScaleDuration;
        private float _wholeRepeatDuration;  // 完整循环时长
        private float _scaleDeltaTime;
        private bool _isManual;
        public bool isManual => _isManual;
        public float oldPlayTime { get; private set; }
        private float _maxDuration;

        public bool isThreeState { get; private set; }  // 是否三段式
        public float loopStartTime { get; private set; }  // 三段式loop阶段开始时间
        public float loopEndTime { get; private set; }  // 三段式loop阶段结束时间

        // TODO 长空 考虑换成状态枚举，维护三段式状态
        private bool _hasBrokenLoopState;  // 三段式已被打破

        public void Reset()
        {
            this._tickTime = 0; //  统计的tick时间
            this._curPlayTime = 0; //  播放时间
            this._scale = 1; //  时间缩放
            this.isWholeRepeat = false;
            this._leftScaleDuration = null; //  当前时间缩放剩余时间
            this._wholeRepeatDuration = 0;
            this._scaleDeltaTime = 0;
            oldPlayTime = 0;
            this._isManual = false;
            isThreeState = false;
            loopStartTime = 0;
            loopEndTime = 0;
            _hasBrokenLoopState = false;
        }

        protected override bool _OnBuild()
        {
            if (_battleSequencer.logicDuration != null)
            {
                _wholeRepeatDuration = _battleSequencer.logicDuration.Value;
            }
            else
            {
                _wholeRepeatDuration = _battleSequencer.artDuration;
            }

            // 最大时长
            _maxDuration = 0;
            if (_battleSequencer.logicDuration != null)
            {
                _maxDuration = Mathf.Max(_maxDuration, _battleSequencer.logicDuration.Value);
            }
            _maxDuration = Mathf.Max(_maxDuration, _battleSequencer.artDuration);
            
            // 循环效果
            var timelineExtInfo = _battleSequencer.GetComponent<BSCRes>().artTimelineExtInfo;
            if (timelineExtInfo != null)
            {
                isThreeState = timelineExtInfo.isThreeState;
                loopStartTime = timelineExtInfo.loopStartFrame * BattleConst.AnimFrameTime;
                if (loopStartTime > _maxDuration)
                {
                    loopStartTime = _maxDuration;
                }
                loopEndTime = timelineExtInfo.loopEndFrame * BattleConst.AnimFrameTime;
                if (loopEndTime > _maxDuration)
                {
                    loopEndTime = _maxDuration;
                }
            }
            return true;
        }

        // 三段式，每次播之前重置一下Cache
        public void ClearThreeStateCache()
        {
            if (isThreeState)
            {
                _hasBrokenLoopState = false;
            }
        }

        // 三段式，打断循环状态
        public void BreakLoopState()
        {
            if (isThreeState)
            {
                _hasBrokenLoopState = true;
                _curPlayTime = loopEndTime;
            }
        }
        
        protected override void _OnTick(float deltaTime)
        {
            // 手动控制由SetPlayTime设置时间，tick中不再累计时间
            if (_isManual && !(_battleSequencer.bsType == BSType.BattlePPV))
            {
                return;
            }
            oldPlayTime = _curPlayTime;
            //  计算当前播放时间
            this._scaleDeltaTime = this._scale * deltaTime;
            this._curPlayTime = this._curPlayTime + this._scaleDeltaTime;
            
            // 三段式repeat判断
            if (isThreeState && !_hasBrokenLoopState)
            {
                // 三段式，并且没有打破循环
                if (_curPlayTime >= loopEndTime)
                {
                    // 时间大于loopStateStopTime，直接拉到LoopStateStartTime
                    _curPlayTime = loopStartTime;
                }
            }
            
            //  wholeRepeat判断
            if (this.isWholeRepeat)
            {
                if (this._curPlayTime >= this._wholeRepeatDuration)
                {
                    this._curPlayTime = 0;
                }
            }

            //  ticktime添加
            this._tickTime = this._tickTime + deltaTime;
            //  剩余缩放时间处理
            if (this._leftScaleDuration != null)
            {
                this._leftScaleDuration = this._leftScaleDuration - deltaTime;
                if (this._leftScaleDuration <= 0)
                {
                    this._leftScaleDuration = null;
                    _battleSequencer.SetTimeScale(1);
                }
            }

            if (_curPlayTime > _maxDuration)
            {
                _curPlayTime = _maxDuration;
            }
        }

        // param scale float 缩放比率
        // param duration float 此缩放持续时间（每次设置都会冲掉之前的设置，null则不设限制）
        public void SetScale(float scale, float? duration)
        {
            this._scale = scale;
            this._leftScaleDuration = duration;
        }

        public float GetScale()
        {
            return this._scale;
        }

        // 设置手动模式
        public void SetManual(bool isManual)
        {
            _isManual = isManual;
        }

        //  获取缩放后的本帧delta值
        // return float
        public float GetScaleDeltaTime()
        {
            return this._scaleDeltaTime;
        }

        // return float 获取播放时间
        public float GetPlayTime()
        {
            return this._curPlayTime;
        }

        // return float 获取播放时间
        public void SetPlayTime(float time)
        {
            oldPlayTime = _curPlayTime;
            //  repeat判断
            if (this.isWholeRepeat && _wholeRepeatDuration > 0)
            {
                _curPlayTime = time % _wholeRepeatDuration;
            }
            else
            {
                this._curPlayTime = time;
            }
            
            if (_curPlayTime > _maxDuration)
            {
                _curPlayTime = _maxDuration;
            }
        }

        //  设置循环播放
        // param isRepeat boolean 是否循环播放
        public void SetRepeat(bool isRepeat)
        {
            this.isWholeRepeat = isRepeat;
        }
    }
}