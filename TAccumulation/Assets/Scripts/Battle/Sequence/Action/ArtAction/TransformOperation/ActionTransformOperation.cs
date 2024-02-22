using System;
using PapeGames;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionTransformOperation: BSAction
    {
        private Transform _target;
        private Vector3? _oldPos;
        private Quaternion? _oldRotation;
        private TransformOperationData _operationData;
        private Func<GameObject> _dynamicTransGetter;
        
        protected override void _OnInit()
        {
            var clip = GetClipAsset<TransformOperationClip>();
            _dynamicTransGetter = clip.dynamicGetter;
            _operationData = clip.operationData;
        }

        protected override void _OnEnter()
        {
            if (_dynamicTransGetter != null)
            {
                _target = _dynamicTransGetter()?.transform;
            }
            else if (GetTrackBindObj<GameObject>() != null)
            {
                _target = GetTrackBindObj<GameObject>().transform;
            }

            if (_operationData != null && _target != null)
            {
                if (_operationData.isEndResume)
                {
                    // 结束需要复原
                    _oldPos = _target.position;
                    _oldRotation = _target.rotation;
                }
                
                _target.localPosition = _operationData.position;
                _target.localEulerAngles = _operationData.rotation;
            }
        }

        protected override void _OnExit()
        {
            if (_target != null && _operationData != null && _operationData.isEndResume)
            {
                _target.localPosition = _oldPos.Value;
                _target.localRotation = _oldRotation.Value;
            }   
        }
    }
}