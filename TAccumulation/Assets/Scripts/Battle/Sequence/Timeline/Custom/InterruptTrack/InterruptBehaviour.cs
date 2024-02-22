using System;
using Unity.Profiling;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using X3Battle;

namespace UnityEngine.Timeline
{
    // 可以被打断的Behaviour，被打断或者结束时都会调用OnStop
    [Serializable]
    public class InterruptBehaviour : PlayableBehaviour, TempFixInterface, IInterruptPlayable
    {
        public enum StopType
        {
            Normal = 0,  // 正常
            Abnormal = 1,  // 不正常
        }
        
        private bool m_interrupt = false;
        private bool m_isPlaying = false;
        private StopType _stopType = StopType.Normal; 

        private bool m_startImmediately = false; 
        public void SetStartImmediately(bool isImmediately)
        {
            m_startImmediately = isImmediately;
        }
        
        private float _startTime;
        public float startTime => _startTime;
        
        private float _curTime;
        public float curTime => _curTime;
        public StopType stopType => _stopType;
        
        private float _deltaTime;
        public float deltaTime => _deltaTime;
        
        public InterruptBehaviour()
        {
            // 创建时做好缓存
            _GetDebugStartName();
            _GetDebugStopName();
            _GetDebugUpdateName();
        }
        private ProfilerMarker _debugStartNameMarker;
        private bool _IsInitdebugStartName;
        private ProfilerMarker _GetDebugStartName()
        {
            if (_IsInitdebugStartName == false)
            {
                _debugStartNameMarker = new ProfilerMarker(this.GetType().Name + ".OnStart");
                _IsInitdebugStartName = true;
            }
            return _debugStartNameMarker;
        }
        
        private ProfilerMarker _debugStopNameMarker;
        private bool _IsInitdebugStopName;
        private ProfilerMarker _GetDebugStopName()
        {
            if (_IsInitdebugStopName == false)
            {
                _IsInitdebugStopName = true;
                _debugStopNameMarker = new ProfilerMarker(this.GetType().Name + ".OnStop");
            }
            return _debugStopNameMarker;
        }

        private ProfilerMarker _debugUpdateNameMarker;
        private bool _debugUpdateNameIsInit = false;
        private ProfilerMarker _GetDebugUpdateName()
        {
            if (_debugUpdateNameIsInit == false)
            {
                _debugUpdateNameMarker = new ProfilerMarker(this.GetType().Name + ".OnProcessFrame");
                _debugUpdateNameIsInit = true;
            }
            return _debugUpdateNameMarker;
        }

        #region 内部实现
       
        // 使用OnStart、OnProcessFrame、OnStop代替原生的PlayableBehaviour方法
        public sealed override void OnGraphStart(Playable playable)
        {
        }

        public sealed override void OnGraphStop(Playable playable)
        {
        }

        public sealed override void OnPlayableCreate(Playable playable)
        {
        }

        public sealed override void OnPlayableDestroy(Playable playable)
        {
            if (!Application.isPlaying)
            {
                OnGraphDestroyInEditor();
            }
        }

        public sealed override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            if (m_startImmediately && !m_interrupt)
            {
                Start(playable, info, null);
            }
        }

        public sealed override void PrepareData(Playable playable, FrameData info)
        {
        }

        public sealed override void PrepareFrame(Playable playable, FrameData info)
        {
        }
        
        public sealed override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (!m_interrupt)
            {
                Start(playable, info, playerData);
                _UpdateDeltaCurTimeAndDeltaTime(playable);
                
                using(_GetDebugUpdateName().Auto())
                {
                    OnProcessFrame(playable, info, playerData);
                }
            }
        }

        private void _UpdateDeltaCurTimeAndDeltaTime(Playable playable)
        {
            var newTime = (float) playable.GetTime();
            _deltaTime = newTime - _curTime;
            _curTime = newTime;   
        }

        private void Start(Playable playable, FrameData info, object playerData)
        {
            if (m_isPlaying)
            {
                return;
            }
            m_isPlaying = true;

            _stopType = StopType.Normal;
            _startTime = (float) playable.GetTime();
            _curTime = _startTime;
            _deltaTime = 0;

            using (_GetDebugStartName().Auto())
            {
                OnStart(playable, info, playerData);

            }
        }

        private void Stop()
        {
            if (!m_isPlaying)
            {
                return;
            }
            m_isPlaying = false;

            using (_GetDebugStopName().Auto())
            {
                OnStop();
            }
        }

        public sealed override void OnBehaviourPause(Playable playable, FrameData info)
        {
            Stop();
        }

        #endregion

        #region 外部接口
        // 打断运行
        public void Interrupt()
        {
            m_interrupt = true;
            _stopType = StopType.Abnormal;
            Stop();
        }

        public void ResetInterruptInfo()
        {
            m_interrupt = false;
        }

        #endregion

        #region 模板方法
        // 开始运行
        protected virtual void OnStart(Playable playable, FrameData info, object playerData)
        {
            
        }

        // 帧更新调用，肯定在OnStart之后调用，并且OnStop后不会再被调用
        protected virtual void OnProcessFrame(Playable playable, FrameData info, object playerData)
        {
            
        }
        
        // 结束时或者被打断时调用，如果没有OnStart肯定不会调用过来
        protected virtual void OnStop()
        {
            
        }

        protected virtual void OnGraphDestroyInEditor()
        {
            
        }
        
        #endregion

        // TODO 为了修复bug，临时加个脏接口，回头需要优化掉
        public void TempStop()
        {
            Stop();
        }
    }
}