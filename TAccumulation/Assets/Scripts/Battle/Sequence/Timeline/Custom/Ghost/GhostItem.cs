

using System;
using Framework;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class GhostItem
    {
        private GameObject _obj;
        private AnimationClip _clip;
        private bool _useTemplate = false;
        private bool _isPauseAnimation;

        private float _startTime = 0;
        private float _stopTime = 0;
        private bool _isPlaying = false;
        private GhostActionItem _owner;
        private SkinnedMeshRenderer[] _meshs;
        private float _suspendTime = -1;  // 定帧时间与开始播放动画时间的offset值
        // 持续时间
        private float _duration;
        // 是否使用采样区间
        private Vector2Int? _animSectionTime;
        // 此item执行时间
        private float _elapseTime;
        // 定位置
        private bool _isPausePosition;
        // 主体动画开启时间
        private float _actorAnimStartTime = 0f;

        private GhostAnimPlayable _ghostAnimPlayable;
        private GhostObjectPool _objPool;
        private GhostParam _ghostParam;
        
#if UNITY_EDITOR
        private float _lastSampleTime;
        private static event Action _RefreshEvent;
        public static void RefreshGhostInEditor()
        {
            _RefreshEvent?.Invoke();
        }

        private void _OnRefreshGhost()
        {
            if (_isPlaying && _owner != null)
            {
                if (_meshs != null)
                {
                    _owner.SetShaderDataToMeshes(_meshs);
                }
                _SampleColorAndScale(_lastSampleTime);
            }
        }
#endif

        public void Init(GameObject template, AnimationClip clip, GhostActionItem owner, bool useTemplate = false, GhostObjectPool objPool = null)
        {
            _ghostParam = owner.ghostParam;
            var actorAnimStartTime = _ghostParam.actorAnimStartTime;
            var isPausePositionParam = _ghostParam.isPausePosition;
            Vector2Int? sectionTime = null;
            if (_ghostParam.useAnimSection)
            {
                sectionTime = _ghostParam.animSectionTime;
            }
            var animSectionTimeParam = sectionTime;
            if (_ghostParam.isCloneBone)
            {
                clip = null;  // 如果通过拷贝骨骼实现，clip置空
                isPausePositionParam = true;  // 拷贝骨骼实现动画，肯定不跟随主体位置
            }
            
            _actorAnimStartTime = actorAnimStartTime;
            this._owner = owner;
            _isPausePosition = isPausePositionParam;
            _animSectionTime = animSectionTimeParam;
            this._clip = clip;
            _objPool = objPool;
            
            if (_objPool == null)
            {
                // 池是空的，现场创建
                if (useTemplate)
                {
                    this._obj = template;    
                }
                else
                {
                    this._obj = GameObject.Instantiate(template, template.transform.parent);
                }   
                this._useTemplate = useTemplate;
                _ghostAnimPlayable = new GhostAnimPlayable(_obj, clip);
            }
            else
            {
                // 池不是空的，从池中拿
                _ghostAnimPlayable = _objPool.Get(clip);
                this._obj = _ghostAnimPlayable.gameObject;
            }
            
            _ghostAnimPlayable.syncComp.ResetData(owner.boneSrc, this._obj);
            
            _ghostAnimPlayable.SetTime(-1);
            this._obj.transform.localPosition = Vector3.zero;
            this._obj.transform.localRotation = Quaternion.identity;
            this._obj.transform.localScale = Vector3.one;
            
            _meshs = _ghostAnimPlayable.meshs;
            owner.SetShaderDataToMeshes(_meshs);
            this._obj.SetVisible(false);
        }

        public void Reset()
        {
            _obj = null;
            _clip= null;
            _useTemplate = false;
            _isPauseAnimation = false;
            _startTime = 0;
            _stopTime = 0;
            _isPlaying = false;
            _owner = null;
            _meshs = null;
            _suspendTime = -1;  // 定帧时间与开始播放动画时间的offset值
            // 持续时间
            _duration = 0;
            // 是否使用采样区间
            _animSectionTime = null;
            // 此item执行时间
            _elapseTime = 0;
            // 定位置
            _isPausePosition = false;
            _ghostAnimPlayable = null;
            _objPool = null;
            _actorAnimStartTime = 0f;
        }

        // 开始
        public void Start(float curTime, bool isPauseAnim, float playPreTime, float durationParam)
        {
            _elapseTime = 0;
            _startTime = curTime;
            this._obj.SetVisible(true);

            _duration = durationParam;
            _isPauseAnimation = isPauseAnim;
            // this.preTime = playPreTime;
            if (durationParam == -1)
            {
                _stopTime = float.MaxValue;
            }
            else
            {
                _stopTime = durationParam + curTime;
            }
            _isPlaying = true;
            _SampleColorAndScale(0);
            
            if (_ghostParam.isCloneBone)
            {
                _ghostAnimPlayable?.syncComp?.TrySync();
            }
            else
            { 
                var sampleTime = _GetSampleTime(_startTime);
                _SampleAnimation(sampleTime);
                // 运行时先走这个逻辑再更新动画没问题，编辑器下动画逻辑更新时机不确定这里刷一下
                if (!Application.isPlaying)
                {
                    var graph = PlayableAnimationManager.Instance().FindPlayGraph(_obj);
                    if (graph != null)
                    {
                        graph.Update();
                        graph.LateUpdate();
                    }
                }
                _SampleGhostPos(sampleTime);
            }

#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                _RefreshEvent += _OnRefreshGhost;
            }
#endif
        }
        
        public void Update(float curTime, bool isBeginAnim)
        {
            // 判断是否结束
            if (_isPlaying)
            {
                _isPlaying = curTime < _stopTime;
            }    
            
            // 更新动画
            if (isBeginAnim)
            {
                if (_suspendTime == -1)
                {
                    _suspendTime = curTime - _startTime;
                }
                var playTime = curTime - _suspendTime;  // suspend是第一次Update和startTime之间的差值，即悬停时间
                _elapseTime = playTime - _startTime;
                _SampleColorAndScale(curTime - _startTime);
                
                // 非骨骼位置拷贝，使用sample进行动画模拟
                if (!_ghostParam.isCloneBone)
                {
                    var sampleTime = _GetSampleTime(playTime);
                    if (!_isPauseAnimation)
                    {
                        _SampleAnimation(sampleTime);
                    }
                    if (!_isPausePosition)
                    {
                        _SampleGhostPos(sampleTime); 
                    }
                }
            }
            else
            {
                _elapseTime = 0;
                _SampleColorAndScale(curTime - _startTime);
                
                // 非骨骼位置拷贝，使用sample进行动画模拟
                if (!_ghostParam.isCloneBone)
                {
                    var sampleTime = _GetSampleTime(_startTime);
                    _SampleGhostPos(sampleTime);
                }
            }
        }

        // 对颜色进行采样, 使用item运行时间
        private void _SampleColorAndScale(float runTime)
        {
#if UNITY_EDITOR
            _lastSampleTime = runTime;
#endif
            if (_duration == -1)
            {
                // 持续时长无限，取初始值
                _owner.SetMatColorByPercent(_meshs, 0);
            }
            else
            {
                // 持续时长有限，取插值
                var percent = runTime / _duration;
                percent = percent < 0 ? 0 : percent;
                percent = percent > 1.0f ? 1.0f : percent;
                _owner.SetMatColorByPercent(_meshs, percent);
                
                // 设置scale值
                if (_obj != null && _owner != null && _owner.fadeScale != null)
                {
                    var x = _owner.fadeScale.Evaluate(percent);
                    _obj.transform.localScale = new Vector3(x, x, x);
                }
                
            }
        }

        /// <summary>
        /// 获取最终的采样时间
        /// </summary>
        private float _GetSampleTime(float trackPlayTime)
        {
            float finalTime = trackPlayTime - _actorAnimStartTime;
            if (_animSectionTime != null)
            {
                // 区间截取, 动画时间使用elapse执行时间
                finalTime = _animSectionTime.Value.x / _clip.frameRate + _elapseTime;
                var maxTime = _animSectionTime.Value.y / _clip.frameRate;
                finalTime = finalTime > maxTime ? maxTime : finalTime;
            }
            
            // 超过区间或者length长度的时间定帧
            var animLength = _clip.length;
            finalTime = finalTime > animLength ? animLength : finalTime;
            return finalTime;
        }
        
        /// <summary>
        /// 对人物位置采样
        /// </summary>
        /// <param name="sampleTime">轨道播放时间减去悬停时间</param>
        private void _SampleGhostPos(float sampleTime)
        {
            if (!_isPausePosition)
            {
                _owner.SetGhostPos(_obj, sampleTime);
            }
        }
        
        /// <summary>
        /// 对动画采样
        /// </summary>
        /// <param name="sampleTime">轨道播放时间减去悬停时间</param>
        private void _SampleAnimation(float sampleTime)
        {
            if (_ghostAnimPlayable != null)
            {
                _ghostAnimPlayable.SetTime(sampleTime);
                // clip.SampleAnimation(obj, sampleTime);   
            }
        }

        // 停止（之后可能重新Start）
        public void Stop()
        {          
            this._obj.SetVisible(false);
            _isPlaying = false;
            _suspendTime = -1;
            if (_ghostAnimPlayable != null)
            {
                _ghostAnimPlayable.SetTime(-1);
            }
            this._obj.transform.localPosition = Vector3.zero;
            this._obj.transform.localRotation = Quaternion.identity;
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                _RefreshEvent -= _OnRefreshGhost;
            }
#endif
        }
        
        // 是否播放完毕
        public bool IsEnd()
        {
            return !_isPlaying;
        }
        
        // 销毁
        public void Destroy()
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                _RefreshEvent = null;
            }
#endif
            if (_objPool == null)
            {
                // 没有池，走老逻辑
                if (_ghostAnimPlayable != null)
                {
                    _ghostAnimPlayable.Destroy();
                    _ghostAnimPlayable = null;
                }
                if (!_useTemplate)
                {
                    if (Application.isPlaying)
                    {
                        GameObject.Destroy(_obj); 
                    }
                    else
                    {
                        GameObject.DestroyImmediate(_obj);
                    }
                }  
            }
            else
            {
                // 有池，回池
                _objPool.Release(_clip, _ghostAnimPlayable);
            }
        }
    }
}