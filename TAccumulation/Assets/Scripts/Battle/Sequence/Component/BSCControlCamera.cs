using System.Collections.Generic;
using Cinemachine;
using UnityEngine.Timeline;
using X3Sequence;

namespace X3Battle
{
    public class BSCControlCamera : BSCBase, IReset
    {
        private const string _cameraGroupName = "Camera Group";
        private bool? _enableSettingCache = null;
        
        private CinemachineVirtualCamera[] _cinemachines;
        private List<Action> _cameraGroupActions;
        
        public void RecordInfo()
        {
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            var artObj = resCom.artObject;
            if (artObj == null)
            {
                return;
            }
            
            // 相机比较特殊有可能不绑定任何轨道，需要单独处理
            _cinemachines = artObj.GetComponentsInChildren<CinemachineVirtualCamera>();

            // 找到CameraGroup下的Action
            var artSequencer = _battleSequencer.artSequencer;
            if (artSequencer != null)
            {
                foreach (Track track in artSequencer.tracks)
                {
                    bool? isCameraGroupChild = null;  // 记录一下这条轨道是否为cameraChild
                    foreach (var action in track.actions)
                    {
                        if (action is BSAction bsAction)
                        {
                            if (isCameraGroupChild == null)
                            {
                                isCameraGroupChild = _IsCameraGroupChild(bsAction.trackAsset);
                            }
                            if (isCameraGroupChild.Value)
                            {
                                _EnsureCameraGroupActions();
                                _cameraGroupActions.Add(bsAction);   
                            }
                        }
                    }
                }
            }
        }

        // 确保_cameraGroupActions对象存在
        private void _EnsureCameraGroupActions()
        {
            if (_cameraGroupActions == null)
            {
                _cameraGroupActions = new List<Action>();
            }
        }

        // 某个轨道是不是_cameraGroup子节点
        private bool _IsCameraGroupChild(TrackAsset trackAsset)
        {
            if (trackAsset.parent != null && trackAsset.parent.name == _cameraGroupName)
            {
                return true;
            }
            return false;
        }

        // 设置CameraGroupEnable状态（需要在每次RePlay之前设置）
        public void SetCameraGroupEnable(bool enable)
        {
            _enableSettingCache = enable;
        }

        public void Replay()
        {
            if (_enableSettingCache != null)
            {
                _EvalCameraGroupEnable(_enableSettingCache.Value);
                _enableSettingCache = null;
            }  
        }

        private void _EvalCameraGroupEnable(bool enable)
        {
            if (_cinemachines != null && _cinemachines.Length > 0)
            {
                for (int i = 0; i < _cinemachines.Length; i++)
                {
                    _cinemachines[i].enabled = enable;
                }
            }

            if (_cameraGroupActions != null)
            {
                foreach (var action in _cameraGroupActions)
                {
                    action.SetEnable(enable);
                }   
            }
        }

        public void Reset()
        {
            _cameraGroupActions = null;
            _cinemachines = null;
            _enableSettingCache = null;
        }
    }
}