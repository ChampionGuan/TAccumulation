using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace PapeGames
{
    public class HookPositionRotation:MountPlayableBehaviourBase
    {
        private const float frameTime = 0.033f;
        
        // 构造时的静态数据
        private TrackExtData _extData;
        private bool _isFollowPos;
        private bool _isFollowRotation;
        private float _detachTime;  // 不跟随时的分离时间，包括位置和旋转
        private Transform _trans;
        
        // 运行中动态数据
        private Transform _parent;
        private Vector3 _detachWorldPos;
        private Quaternion _detachWorldRotation;
        private Vector3 _detachParentWorldPos;
        private Quaternion _detachParentWorldRotation;
        private float _curTime;
        private float _startTime;
        private float _clipInTime;
        private bool _hasDetach;  // 是否已经经过分离时间点
        private bool _saveOnStop;  // 结束时是否需要Save
        private Transform _runTimeRecordParent;

        // 标记一下结束时需要保存
        public void MarkSaveOnStop()
        {
            _saveOnStop = true;
        }
        
        private bool isBegin;

        public HookPositionRotation(TrackExtData extData, GameObject obj, float clipInTime)
        {
            _extData = extData;
            _trans = obj.transform;
            _clipInTime = clipInTime;
            
            if (_extData.isFollowActor)
            {
                // 跟随Actor时，必定跟随位置，但是旋转可以设置，分离时间为0
                _isFollowPos = true;
                _isFollowRotation = _extData.isFollowRotate;
                _detachTime = 0;
            }
            else
            {
                // 不跟随Actor时，位置和旋转都强行不跟随，分离时间随参数
                _isFollowPos = false;
                _isFollowRotation = false;
                _detachTime = _extData.detachTime;
            }
        }

        private void _ResetDynamicData()
        {
            _saveOnStop = false;
             _parent = _trans.parent;
            _detachWorldPos = Vector3.zero;
            _detachWorldRotation = Quaternion.identity;
            _detachParentWorldPos = Vector3.zero;
            _detachParentWorldRotation = Quaternion.identity;
            _curTime = 0;
            _hasDetach = false;
        }

        private void _ResetParent()
        {
            if (_parent != null && _extData != null && _trans != null)
            {
                var newParent = _parent.Find(_extData.HookName);
                if (newParent != null)
                {
                    _parent = newParent;
                    _trans.parent = _parent;
                    // 设置parent成功需要重设一下
                    _SyncPositionAndRotation();
                }
            }   
        }

        protected override void OnBehaviourPlay(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            if (isBegin)
            {
                return;   
            }
            isBegin = true;
            
            _ResetDynamicData();
            
            if (_parent == null)
            {
                return;
            }

            _curTime = (float) playable.GetTime();
            _startTime = _curTime;
            _ResetParent();
            _ResetPosAndRotation();
            _TryRecordDetachInfo();
        }

        private void _ResetPosAndRotation()
        {
            if (!Application.isPlaying && _isFollowPos && _isFollowRotation)
            {
                // 美术编辑的时候，不用每次都重设位置，不然美术不好编辑（位置的设置在初始化时会设置）
                return;
            }
            _SyncPositionAndRotation();
        }
        private void _SyncPositionAndRotation()
        {
            if (_trans != null)
            {
                // 位置
                _trans.localPosition = _extData.localPosition;
                // 旋转 
                _trans.localEulerAngles = _extData.localRotation;  
            }
        }

        private void _TryRecordDetachInfo()
        {
            if (_hasDetach)
            {
                return;   
            }

            if (_curTime - _clipInTime >= _detachTime)
            {
                _detachWorldPos = _trans.position;
                _detachWorldRotation = _trans.rotation;
                _detachParentWorldPos = _parent.position;
                _detachParentWorldRotation = _parent.rotation;
                _hasDetach = true;
                
                // 运行时分离之后直接parent置空即可
                if (_InRuntimeDetach())
                {
                    _runTimeRecordParent = _trans.parent;
                    _trans.parent = null;
                }
            }
        }

        protected override void OnProcessFrame(PlayableBehaviour behaviour, Playable playable, FrameData info, object userData)
        {
            if (!isBegin)
            {
                return;   
            }
            
            if (_parent == null)
            {
                return;
            }

            if (_startTime - _clipInTime > frameTime)
            {
                return;   
            }
            
            _curTime = (float) playable.GetTime();
            
            _TryRecordDetachInfo();
            _TrySyncPosAndRotation();
        }

        // 在runtime的detach
        private bool _InRuntimeDetach()
        {
            if (!_isFollowPos && !_isFollowRotation && Application.isPlaying)
            {
                return true;
            }
            return false;
        }

        private void _TrySyncPosAndRotation()
        {
            // 运行时分离之后直接parent置空即可
            if (_InRuntimeDetach())
            {
                return;   
            }
            
            // 分离时间已到的情况（非跳帧进入才会分离）
            if (_hasDetach)
            {
                // 不跟随位置，就同步世界位置
                if (!_isFollowPos)
                {
                    _trans.position = _detachWorldPos;
                }

                // 不跟随旋转，就同步世界旋转
                if (!_isFollowRotation)
                {
                    _trans.rotation = _detachWorldRotation;
                }
            }  
        }

        protected override void OnBehaviourPause(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            if (!isBegin)
            {
                return;    
            }
            isBegin = false;
            
            // 运行时分离之后直接parent设回来即可
            if (_InRuntimeDetach())
            {
                if (_runTimeRecordParent != null)
                {
                    _trans.parent = _runTimeRecordParent;
                }
                return;   
            }
            
            if (_startTime - _clipInTime > frameTime)
            {
                return;
            }

            if (!_isFollowPos || !_isFollowRotation)
            {
                // 位置或者旋转任一个不跟随
                if (_saveOnStop && (_trans.position != _detachWorldPos || _trans.rotation != _detachWorldRotation))
                {
#if UNITY_EDITOR
                    if (Application.isEditor && !Application.isPlaying)
                    {
                        var tempTrans = new GameObject().transform;
                        tempTrans.position = _detachParentWorldPos;
                        tempTrans.rotation = _detachParentWorldRotation;
                        
                        _trans.parent = tempTrans;
                        var pos = _trans.localPosition;
                        var rotation = _trans.localRotation;
                        
                        _trans.parent = _parent;
                        _trans.localPosition = pos;
                        _trans.localRotation = rotation;
                        
                        GameObject.DestroyImmediate(tempTrans.gameObject);
                    }
#endif
                }
                else
                {
                    // 如果不需要记录，则复位
                    _ResetPosAndRotation();    
                }
            }
            // PapeGames.X3.LogProxy.LogError("时序测试、时许测试");
        }
    }
}
































