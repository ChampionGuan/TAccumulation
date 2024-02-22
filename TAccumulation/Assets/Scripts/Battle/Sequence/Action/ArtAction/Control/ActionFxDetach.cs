using FlowCanvas.Nodes;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionFxDetach : BSAction
    {
        // 构造时的静态数据
        private TrackExtData _extData;
        private float _detachTime;  // 不跟随时的分离时间，包括位置和旋转
        private Transform _trans;
        // 运行中动态数据
        private Transform _parent;
        private bool _hasDetach;  // 是否已经经过分离时间点
        private Transform _runTimeDetachParent;
        private bool _isLateEntered = false;

        private bool _needDetach = false;
        
        private bool _needWorldRotation = false;
        private Quaternion? _worldRotation = null;
        
        protected override void _OnInit()
        {
            var track = GetTrackAsset<ControlTrack>();
            var clip = GetClipAsset<ControlPlayableAsset>();
            
            var go = GetExposedValue(clip.sourceGameObject);
            if (go == null)
                return;
            
            _extData = track.extData;
            _trans = go.transform;
            _detachTime = _extData.detachTime;

            if (_extData.trackType == TrackExtType.HookEffect)
            {
                // 跟随人物但是不跟随旋转, 需要lateUpdate和旋转同步
                if (_extData.isFollowActor)
                {
                    if (!_extData.isFollowRotate)
                    {
                        needLateUpdate = true;
                        _needWorldRotation = true;
                    }
                }
                else
                {
                    // 不跟随人物需要分离
                    needLateUpdate = true;
                    _needDetach = true;
                }
            }
        }

        protected override void _OnEnter()
        {
            if (!_needDetach)
            {
                return;
            }
            _ResetDynamicData();
        }

        private void _LateEnter()
        {
            if (!_needDetach)
            {
                return;
            }
            
            if (_isLateEntered)
            {
                return;
            }
            _isLateEntered = true;
            
            if (_parent == null)
            {
                return;
            }
            
            _ResetParent();
            _ResetPosAndRotation();
            _TryDetachAndRecord();   
        }
        
        private void _ResetDynamicData()
        {
            _parent = _trans.parent;
            _hasDetach = false;
            _isLateEntered = false;
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
                }
            }   
        }
        
        private void _ResetPosAndRotation()
        {
            // 位置
            _trans.localPosition = _extData.localPosition;
            // 旋转 
            _trans.localEulerAngles = _extData.localRotation;
            // 缩放
            _trans.localScale = _extData.localScale;
        }

        private void _TryDetachAndRecord()
        {
            if (_hasDetach)
            {
                return;   
            }

            if (_parent == null)
            {
                return;
            }

            if (curOffsetTime >= _detachTime)
            {
                _hasDetach = true;
                _runTimeDetachParent = _trans.parent;
                _trans.parent = null;
            }
        }

        protected override void _OnLateUpdate()
        {
            if (_needDetach) // 父节点分离的分支
            {
                if (_isLateEntered)
                {
                    // 已经进入过了，尝试分离
                    _TryDetachAndRecord();    
                }
                else
                {
                    // 还没有进入，就进入
                    _LateEnter();
                }
            }
            else if (_needWorldRotation) // 世界空间旋转不变的分支
            {
                if (_isLateEntered)
                {
                    _trans.rotation = _worldRotation.Value;
                }
                else
                {
                    _isLateEntered = true;
                    _worldRotation = _trans.rotation;
                }
            }
        }

        protected override void _OnExit()
        {
            if (!_isLateEntered)
            {
                  return;  
            }
            _isLateEntered = false;

            if (_needWorldRotation)
            {
                // 恢复原始旋转
                _trans.localRotation = Quaternion.Euler(_extData.localRotation);
            }
            
            if (_runTimeDetachParent != null)
            {
                _trans.parent = _runTimeDetachParent;
            }
        }    
    }
}