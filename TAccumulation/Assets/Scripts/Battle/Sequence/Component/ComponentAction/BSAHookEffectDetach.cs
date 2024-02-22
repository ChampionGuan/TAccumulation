using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class BSAHookEffectDetach : X3Sequence.Action
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

        public void SetData(TrackExtData extData, GameObject obj)
        {
            _extData = extData;
            _trans = obj.transform;
            _detachTime = _extData.detachTime;
        }

        protected override void _OnInit()
        {
            needLateUpdate = true;
        }

        protected override void _OnEnter()
        {
            _ResetDynamicData();
        }

        private void _LateEnter()
        {
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

        protected override void _OnExit()
        {
            if (!_isLateEntered)
            {
                  return;  
            }
            _isLateEntered = false;
            
            if (_runTimeDetachParent != null)
            {
                _trans.parent = _runTimeDetachParent;
            }
        }    
    }
}