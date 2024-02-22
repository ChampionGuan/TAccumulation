using System;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    public class TransformOperationPlayable : InterruptBehaviour
    {
        private Transform _target;
        private Vector3? _oldPos;
        private Quaternion? _oldRotation;
        
        private TransformOperationData _operationData;
        
        // TODO 二测性能优化临时做法
        private Func<GameObject> _dynamicTransGetter;
        public void SetDynamicTransGetter(Func<GameObject> getter)
        {
            _dynamicTransGetter = getter;
        }
        
        public void SetData(TransformOperationData otherData)
        {
            _operationData = otherData;
        }

        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            if (_dynamicTransGetter != null)
            {
                _target = _dynamicTransGetter()?.transform;
            }
            else if (playerData is GameObject obj)
            {
                _target = obj.transform;
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

        protected override void OnStop()
        {
            if (_target != null && _operationData != null && _operationData.isEndResume)
            {
                _target.localPosition = _oldPos.Value;
                _target.localRotation = _oldRotation.Value;
            }   
        }
    }
}