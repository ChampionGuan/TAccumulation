using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class TimeScaler : ECComponent
    {
        /// <summary>
        /// 持有者
        /// </summary>
        public IUnscaledDeltaTime owner { get; }

        /// <summary>
        /// 未缩放累计时间
        /// </summary>
        public float unscaledTime { get; private set; }

        /// <summary>
        /// 缩放后的累计时间
        /// </summary>
        public float time { get; private set; }

        /// <summary>
        /// 当前scale值
        /// </summary>
        public float scale { get; private set; } = 1;

        /// <summary>
        /// 当前deltaTime值
        /// </summary>
        public float deltaTime { get; private set; }

        /// <summary>
        /// 当前unscaledDeltaTime值
        /// </summary>
        public float unscaledDeltaTime { get; private set; }

        protected readonly ScaleData[] _scaleDatas;
        protected Dictionary<int, float> _changeDatas;

        public TimeScaler(IUnscaledDeltaTime owner, int length, int type, Func<int, ScaleData> createInstance = null) : base(type)
        {
            this.owner = owner;
            _scaleDatas = new ScaleData[length];
            for (var i = 0; i < length; i++) _scaleDatas[i] = null != createInstance ? createInstance(i) : new ScaleData();
            _changeDatas = new Dictionary<int, float>(length);
        }

        /// <summary>
        /// 重置
        /// </summary>
        public void Reset()
        {
            unscaledTime = 0;
            time = 0;
            scale = 1;
            deltaTime = 0;
            for (var i = 0; i < _scaleDatas.Length; i++) _scaleDatas[i].Reset();
        }

        /// <summary>
        /// 获取某种类型的ScaleData
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public ScaleData GetScaleData(int type)
        {
            if (!_VerifyType(type))
            {
                return null;
            }

            return _scaleDatas[type];
        }

        /// <summary>
        /// 获取某种类型的Scale值
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public float GetScale(int type)
        {
            if (!_VerifyType(type))
            {
                return 1;
            }

            return _scaleDatas[type].timeScale;
        }

        /// <summary>
        /// 设置某种类型的scale值
        /// </summary>
        /// <param name="type">ActorTimeScaleType|LevelTimeScaleType</param>
        /// <param name="timeScale">缩放值</param>
        /// <param name="duration">持续时间，null则一直持续</param>
        public void SetScale(float timeScale, float? duration = null, int type = 0, float fadeinDuration = 0, float fadeoutDuration = 0)
        {
            if (timeScale < 0 || float.IsNaN(timeScale))
            {
                PapeGames.X3.LogProxy.LogError("时间缩放设置负数没有意义！相关程序查看堆栈解决一下错误传参！");
                return;
            }

            if (!_VerifyType(type))
            {
                return;
            }

            float? endTime = null;
            if (duration >= 0)
            {
                endTime = unscaledTime + duration;
            }

            _scaleDatas[type].SetValue(timeScale, unscaledTime, endTime, fadeinDuration, fadeoutDuration);
            _EvalScale(unscaledTime);
        }

        /// <summary>
        /// 重置某种类型的scale值
        /// </summary>
        /// <param name="type"></param>
        public void ResetScale(int type = 0)
        {
            if (!_VerifyType(type))
            {
                return;
            }

            _scaleDatas[type].Reset();
            _EvalScale(unscaledTime);
        }

        /// <summary>
        /// 获取某种类型的scale是否禁用
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public bool GetDisabled(int type)
        {
            if (!_VerifyType(type))
            {
                return false;
            }

            return _scaleDatas[type].disabled;
        }

        /// <summary>
        /// 设置是否禁用
        /// </summary>
        /// <param name="type"></param>
        /// <param name="disabled"></param>
        public void SetDisable(int type, bool disabled)
        {
            if (!_VerifyType(type))
            {
                return;
            }

            var scaleData = _scaleDatas[type];
            if (scaleData.disabled == disabled) return;
            scaleData.SetDisable(disabled);
            _EvalScale(unscaledTime);
        }

        /// <summary>
        /// 上层调用，驱动更新
        /// </summary>
        protected override void OnUpdate()
        {
            unscaledDeltaTime = owner.unscaledDeltaTime;
            unscaledTime += unscaledDeltaTime;
            var changed = _EvalScale(unscaledTime, false);
            deltaTime = unscaledDeltaTime * scale;
            time += deltaTime;
            if (changed) _DispatchChangedEvent();
        }

        /// <summary>
        /// 更新Scale
        /// </summary>
        /// <param name="time"></param>
        /// <param name="autoDispatchChangedEvent"></param>
        /// <returns></returns>
        private bool _EvalScale(float time, bool autoDispatchChangedEvent = true)
        {
            scale = 1f;
            _changeDatas.Clear();
            for (var i = 0; i < _scaleDatas.Length; i++)
            {
                var scaleData = _scaleDatas[i];
                var changed = scaleData.EvalScale(time);
                scale *= scaleData.timeScale;
                if (!changed) continue;
                _changeDatas.Add(i, scaleData.timeScale);
            }

            if (_changeDatas.Count <= 0) return false;
            _OnScaleChange();
            if (autoDispatchChangedEvent) _DispatchChangedEvent();
            return true;
        }

        private bool _VerifyType(int type)
        {
            return type >= 0 && type < _scaleDatas.Length;
        }

        protected virtual void _DispatchChangedEvent()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventScalerChange>();
            eventData.Init(owner, scale, _changeDatas);
            Battle.Instance.eventMgr.Dispatch(EventType.OnScalerChange, eventData);
        }

        protected virtual void _OnScaleChange()
        {
        }

        public class ScaleData
        {
            public float timeScale => disabled ? 1 : _timeScale;
            public float? leftTime => _endTime - _currTime;
            public float fadeinDuration => _fadeinDuration;
            public float fadeoutDuration => _fadeoutDuration;
            public bool disabled => _disabled;

            protected float _timeScale = 1;
            protected float _cacheScale = 1;
            protected float _tgtScale = 1;
            protected float _startTime;
            protected float _currTime;
            protected float? _endTime;
            protected float _fadeinDuration;
            protected float _fadeoutDuration;
            protected bool _disabled;

            public virtual void Reset()
            {
                _timeScale = 1;
                _cacheScale = 1;
                _tgtScale = 1;
                _startTime = 0;
                _endTime = null;
                _fadeinDuration = 0;
                _fadeoutDuration = 0;
                _disabled = false;
            }

            public virtual void SetDisable(bool disabled)
            {
                _disabled = disabled;
            }

            public virtual void SetValue(float tgtScale, float startTime, float? endTime, float fadeInDuration, float fadeOutDuration)
            {
                _tgtScale = tgtScale < 0 ? 0 : tgtScale;
                _startTime = _currTime = startTime;
                _endTime = endTime;

                // 参数校正
                // 1、淡入淡出时长，不允许小于0
                // 2、淡出时长>总时长，淡出时长=总时长，淡入时长=0
                // 3、淡出+淡入时长>总时长，淡出时长=淡出时长，淡入时长=总时长-淡出时长
                // 4、结束时间不为空的情况下，不允许小于当前时间
                _fadeinDuration = fadeInDuration < 0 ? 0 : fadeInDuration;
                _fadeoutDuration = fadeOutDuration < 0 ? 0 : fadeOutDuration;
                if (null == _endTime)
                {
                    return;
                }

                _endTime = _endTime < _currTime ? _currTime : _endTime;

                var duration = _endTime.Value - _currTime;
                if (_fadeoutDuration > duration)
                {
                    _fadeoutDuration = duration;
                    _fadeinDuration = 0;
                }
                else if (_fadeoutDuration + _fadeinDuration > duration)
                {
                    _fadeinDuration = duration - _fadeoutDuration;
                }
            }

            // 返回值，是否改变
            public virtual bool EvalScale(float currTime)
            {
                var cacheScale = _cacheScale;
                _EvalScale(currTime);
                _cacheScale = timeScale;
                return cacheScale != timeScale;
            }

            private void _EvalScale(float currTime)
            {
                _currTime = currTime;
                if (_endTime == null)
                {
                    // 一直持续情况，全程等于target
                    _timeScale = _tgtScale;
                    return;
                }

                if (currTime >= _endTime)
                {
                    // 非一直持续，时间超出，恢复
                    _timeScale = _tgtScale = 1;
                    return;
                }

                // 非一直持续时间没超出
                if (_fadeinDuration == 0 && _fadeoutDuration == 0)
                {
                    // 非一直持续时间没超出，没有变化，直接等于target
                    _timeScale = _tgtScale;
                    return;
                }

                // 非一直持续时间没超出，有变化，需要计算fadein和fadeout
                if (_fadeinDuration > 0)
                {
                    var fadeinProcess = (currTime - _startTime) / _fadeinDuration;
                    if (0 <= fadeinProcess && fadeinProcess <= 1)
                    {
                        _timeScale = Mathf.Lerp(1, _tgtScale, fadeinProcess);
                        return;
                    }
                }

                if (_fadeoutDuration > 0)
                {
                    var fadeoutProcess = (_endTime.Value - currTime) / _fadeoutDuration;
                    if (0 < fadeoutProcess && fadeoutProcess <= 1)
                    {
                        _timeScale = Mathf.Lerp(1, _tgtScale, fadeoutProcess);
                        return;
                    }
                }

                _timeScale = _tgtScale;
            }
        }
    }
}