using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;


namespace X3Battle
{

    public class VirtualCamera
    {
        // 包含mode以及effect
        protected CameraPriorityType _defaultPriority;
        protected Animator _animator=null;
        protected GameObject _rootG;
        protected CameraStatusType _status;

        public Cinemachine.CinemachineVirtualCamera cinemachineVirtualCamera;

        public static VirtualCamera CreateVirtualCamera(CameraMode mode, string name, CameraPriorityType priority)
        {
            switch(mode)
            {
                case CameraMode.Battle:
                    return new BattleVirtualCamera(name, priority);
                case CameraMode.Free:
                    return new FreeLookVirtualCamera(name, priority);
                case CameraMode.FPS:
                    return new VirtualCamera(name, priority);
                default:
                    return new VirtualCamera(name, priority);
            }
        }

        public VirtualCamera(string name, CameraPriorityType priority)
        {
            _rootG = BattleResMgr.Instance.Load<GameObject>(name, BattleResType.Camera, name);
            if (_rootG != null)
            {
                _rootG.name = name;
                cinemachineVirtualCamera = _rootG.GetComponent<Cinemachine.CinemachineVirtualCamera>();
            }
            _defaultPriority = priority;
        }

        public virtual void Destroy()
        {
            BattleResMgr.Instance.Unload(_rootG);
            _rootG = null;
        }

        public virtual void OnAwake()
        {
            _rootG.SetActive(true);
            //mode.OnAwake();
            cinemachineVirtualCamera.Priority = (int)_defaultPriority;
        }

        public virtual void OnEnter()
        {
            _status = CameraStatusType.Live;
        }

        public virtual void OnExit()
        {
        }

        public GameObject GetRoot()
        {
            return _rootG;
        }

        public Animator GetAnimator()
        {
            if(_animator==null)
            {
                var t = _rootG.GetComponent<Animator>();
                if(t==null)
                {
                    t = _rootG.AddComponent<Animator>();
                }
                _animator = t;
            }
            return _animator;
        }

        public void SetDisable()
        {
            _rootG.SetActive(false);
        }

        public void SetEnable()
        {
            if (_status == CameraStatusType.Destroyed)
            {
                return;
            }
            _rootG.SetActive(true);
            if (_status == CameraStatusType.Live)
            {
                return;
            }
            cinemachineVirtualCamera.MoveToTopOfPrioritySubqueue();
        }
        public bool IsLiving()
        {
            return _status == CameraStatusType.Live;
        }

        public void SyncParam(CinemachineVirtualCamera source)
        {
            _rootG.transform.position = source.transform.position;
            _rootG.transform.rotation = source.transform.rotation;
            cinemachineVirtualCamera.m_Lens = source.m_Lens;
        }
    }
}
