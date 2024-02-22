using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class BattleVirtualCamera : VirtualCamera
    {
        public X3VirtualCamera x3VirCamera { get; private set; }

        public Actor follow1st { get; private set; } // 跟随的目标
        public Actor lookAt1st { get; private set; } // 看向的目标

        public Vector3 rawPosition => cinemachineVirtualCamera.State.RawPosition;
        public Quaternion rawOrientation => cinemachineVirtualCamera.State.RawOrientation;
        public CameraModeType currMode { get; private set; }


        private X3VirtualCamera[] _x3VirCameraParams = new X3VirtualCamera[(int)CameraModeType.Num];
        private List<GameObject> _virCameraParamGos = new List<GameObject>();
        private string _followDummyType;

        public string followDummyType
        {
            get { return _followDummyType; }
            set
            {
                if (_followDummyType != value)
                {
                    x3VirCamera.SetFollow(follow1st?.GetDummy(value));
                    _followDummyType = value;
                }
            }
        }

        // 跟随目标的面向方向
        public Vector3 follow1stForward
        {
            get
            {
                if (follow1st != null)
                    return follow1st.GetDummy(_followDummyType).forward;
                else
                    return Vector3.forward;
            }
        }

        public Vector3 follow1stPos
        {
            get
            {
                if (follow1st != null)
                    return follow1st.GetDummy(_followDummyType).position;
                else
                    return Vector3.zero;
            }
        }

        public BattleVirtualCamera(string name, CameraPriorityType priority) : base(name, priority)
        {

        }

        public override void OnAwake()
        {
            base.OnAwake();
            x3VirCamera = cinemachineVirtualCamera.GetComponent<X3VirtualCamera>();
            x3VirCamera.Init();
            _LoadCameraParam();
        }

        public override void Destroy()
        {
            base.Destroy();
            foreach(var go in _virCameraParamGos)
            {
                BattleResMgr.Instance.Unload(go);
            }
            x3VirCamera = null;
            follow1st = null;
            lookAt1st = null;
        }

        public void SetFollowTgt(Actor follow1st)
        {
            if (follow1st == null)
                return;
            this.follow1st = follow1st;
            x3VirCamera?.SetFollow(follow1st?.GetDummy(_followDummyType));
        }

        public void SetLockTgt(Actor target)
        {
            var transform = target == null ? null : target?.GetDummy(ActorDummyType.PointCamera);
            x3VirCamera?.SetLock(transform);
        }
        
        public void SetLookAtTgt(Actor lookAt1st)
        {
            this.lookAt1st = lookAt1st;
            if (lookAt1st != null)
            {
                x3VirCamera?.SetLookAt(lookAt1st?.GetDummy(ActorDummyType.PointCamera));
            }
            else
            {
                x3VirCamera?.SetLookAt(null);
            }
        }

        public void OnActorRecycle(Actor actor)
        {
            if (actor == follow1st && x3VirCamera != null)
            {
                x3VirCamera.m_CameraMutateEnable = false;
            }

            if (actor == lookAt1st)
            {
                SetLookAtTgt(null);
            }
        }

        public void SetCameraMode(CameraModeType targetType, bool blend = true)
        {
            X3VirtualCamera formCam = _x3VirCameraParams[(int)currMode];
            X3VirtualCamera toCam = _x3VirCameraParams[(int)targetType];
            if (formCam == null || toCam == null)
            {
                currMode = targetType;
                return;
            }

            if (targetType == CameraModeType.BoyDead)
            {
                x3VirCamera?.m_AutoAdjust.SetSwitch(false);
            }
            else
            {
                x3VirCamera?.m_AutoAdjust.SetSwitch(true);
            }

            if (currMode == CameraModeType.StartBattle)
            {
                x3VirCamera?.SetBlend(toCam, blend, formCam.m_Transition.m_SetBlendTime);
            }
            else
            {
                x3VirCamera?.SetBlend(toCam, blend, toCam.m_Transition.m_SetBlendTime);
            }
            currMode = targetType;
        }

        public void ChangeCameraParam(X3VirtualCamera cameraParam, CameraModeType modeType)
        {
            if (cameraParam == null)
            {
                return;
            }
            //设置的模式是当前模式时，自动切换一下
            if (modeType == currMode)
            {

                X3VirtualCamera formCam = _x3VirCameraParams[(int)currMode];
                X3VirtualCamera toCam = cameraParam;
                if (formCam == null || toCam == null)
                {
                    return;
                }

                if (modeType == CameraModeType.BoyDead)
                {
                    x3VirCamera?.m_AutoAdjust.SetSwitch(false);
                }
                else
                {
                    x3VirCamera?.m_AutoAdjust.SetSwitch(true);
                }

                if (currMode == CameraModeType.StartBattle)
                {
                    x3VirCamera?.SetBlend(toCam, true, formCam.m_Transition.m_SetBlendTime);
                }
                else
                {
                    x3VirCamera?.SetBlend(toCam, true, toCam.m_Transition.m_SetBlendTime);
                }
            }
            _x3VirCameraParams[(int)modeType] = cameraParam;
        }

        public void OnCameraBlend(Actor virCamOwner, Actor boySkillTarget, ArtCameraType cameraSkillType, float artYawOffset)
        {
            Vector3 virtualCameraForward = Vector3.forward;
            if (virCamOwner != null && virCamOwner.IsGirl())
            {
                // 如果是女主播的美术镜头
                virtualCameraForward = follow1stForward;
                x3VirCamera?.SetPitchAndYaw(x3VirCamera.m_Viewport.m_DefaultPitch, virtualCameraForward);
            }
            else if (virCamOwner != null && virCamOwner.IsBoy())
            {
                // 如果是男主播的美术镜头
                virtualCameraForward = virCamOwner.GetDummy(ActorDummyType.PointCamera).forward;
                if (cameraSkillType == ArtCameraType.SupportSkill)
                {
                    // 男主援护技
                    virtualCameraForward = Quaternion.AngleAxis(artYawOffset, Vector3.up) * virtualCameraForward;
                    // 镜头朝向向男主的面向
                    x3VirCamera?.SetPitchAndYaw(x3VirCamera.m_Viewport.m_DefaultPitch, virtualCameraForward);
                }
                else if (cameraSkillType == ArtCameraType.EXMaleActive && boySkillTarget != null)
                {
                    // 男主QTE
                    Vector3 forward = Vector3.forward;
                    if (boySkillTarget.IsGirl())
                    {
                        forward = follow1stPos - virCamOwner.GetDummy(ActorDummyType.PointCamera).position;
                    }
                    else if (boySkillTarget.type == ActorType.Monster)
                    {
                        var vecGirlMonster = boySkillTarget.GetDummy(ActorDummyType.PointCamera).position - follow1stPos;
                        vecGirlMonster.y = 0;
                        vecGirlMonster = vecGirlMonster.normalized;
                        var vecGirlBoy = virCamOwner.GetDummy(ActorDummyType.PointCamera).position - follow1stPos;
                        vecGirlBoy.y = 0;
                        vecGirlBoy = vecGirlBoy.normalized;

                        var angleMGB = Vector3.Angle(vecGirlMonster, vecGirlBoy);
                        if (angleMGB < x3VirCamera.m_QTEAngleThreshold)
                            forward = vecGirlBoy;
                        else
                            forward = vecGirlMonster;
                    }

                    x3VirCamera?.SetPitchAndYaw(x3VirCamera.m_Viewport.m_DefaultPitch, forward.normalized);
                }
                else
                {
                    // 否则镜头朝向向男主的面向
                    x3VirCamera?.SetPitchAndYaw(x3VirCamera.m_Viewport.m_DefaultPitch, virtualCameraForward);
                }
            }
            else if (virCamOwner != null && virCamOwner.type == ActorType.Monster)
            {
                // 如果是怪物播的美术镜头，则取主角到怪物的方向作为战斗镜头最终朝向
                Vector3 forward = virCamOwner.GetDummy(ActorDummyType.PointCamera).position - follow1stPos;
                forward.y = 0;
                x3VirCamera?.SetPitchAndYaw(x3VirCamera.m_Viewport.m_DefaultPitch, forward.normalized);
            }
            else
            {
                virtualCameraForward = follow1stForward;
                x3VirCamera?.SetPitchAndYaw(x3VirCamera.m_Viewport.m_DefaultPitch, virtualCameraForward);
            }
        }

        private void _LoadCameraParam()
        {
            _x3VirCameraParams[(int)CameraModeType.NotBattle] = _LoadCameraParam(CameraTrace.camearModes[(int)CameraModeType.NotBattle]);
            _x3VirCameraParams[(int)CameraModeType.Battle] = _LoadCameraParam(CameraTrace.camearModes[(int)CameraModeType.Battle]);
            _x3VirCameraParams[(int)CameraModeType.BossBattle] = _LoadCameraParam(CameraTrace.camearModes[(int)CameraModeType.BossBattle]);
            _x3VirCameraParams[(int)CameraModeType.StartBattle] = _LoadCameraParam(CameraTrace.camearModes[(int)CameraModeType.StartBattle]);
            _x3VirCameraParams[(int)CameraModeType.BoyDead] = _LoadCameraParam(CameraTrace.camearModes[(int)CameraModeType.BoyDead]);
        }

        private X3VirtualCamera _LoadCameraParam(string name)
        {
            var go = BattleResMgr.Instance.Load<GameObject>(name, BattleResType.Camera, name);
            _virCameraParamGos.Add(go);
            return go.GetComponent<X3VirtualCamera>();
        }
    }
}
