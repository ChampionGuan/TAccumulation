using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using Unity.Profiling;
using UnityEngine;
using UnityEngine.Profiling;
using X3.Impulse;

namespace X3Battle
{
    public class CameraTrace : BattleComponent
    {
        public static string battleTrackCameraName = "DefaultBattleTrackCamera";
        public static string blendSettingName = "CinemachineBlenderSettings";
        public static string fpsCameraName = "FPSCamera";
        public static string levelCameraGroupName = "LevelCameraGroup-";
        public static readonly string[] camearModes = new string[(int)CameraModeType.Num]
        {
            "TrackCameraSetting_NormalBattle",
            "BattleFreeCamera",
            "TrackCameraSetting_NotBatlle",
            "TrackCameraSetting_BossBattle",
            "TrackCameraSetting_StartBattle",
            "TrackCameraSetting_BoyDead"
        };

        public CameraModeType currMode { get; private set; }

        private BattleVirtualCamera _battleVirCam = null; // 战斗虚拟相机
        private X3VirtualCamera _x3VirCamera => _battleVirCam.x3VirCamera; // X3virtualcamera脚本

        //  自由镜头
        private FreeLookVirtualCamera _freeVirCam = null; // 自由镜头相机
        private X3FreeVirtualCamera _x3FreeVirCamera => _freeVirCam?.x3FreeVirtualCamera; // FreeVirtualCamera脚本
        private Dictionary<int, X3LevelCamera> _levelCameraConfigs = new Dictionary<int, X3LevelCamera>();

        private VirtualCamera _fpsVirCam = null;

        private CinemachineBrain _cameraBrain = null;
        private Dictionary<int, KeyValuePair<Actor, ICinemachineCamera>> _virCamActor = new Dictionary<int, KeyValuePair<Actor, ICinemachineCamera>>();

        private SkillType _boySkillType = SkillType.Attack;
        private SkillType _girlSkillType = SkillType.Attack;
        
        private float _artYawOffset = 0;

        private ArtCameraType _cameraSkillType = ArtCameraType.None; // 美术镜头的技能类型
        private Actor _boySkillTarget;
        private Actor _artCamSkillTarget;
        private CinemachineBrain.UpdateMethod _formerUpdateMethod;

        private Coroutine _blendingCoroutine;
        public bool rotateEnable { get; private set; }
#if UNITY_EDITOR
        public float DragScale = 850;
#endif

        public CameraTrace() : base(BattleComponentType.CameraTrace)
        {
            _InitCameraBrain();
        }

        protected override void OnAwake()
        {
            base.OnAwake();
            var relativePath = levelCameraGroupName + battle.config.StageID;
            if(BattleResMgr.Instance.IsExists(relativePath, BattleResType.LevelMaker))
            {
                var levelCameraGroup = BattleResMgr.Instance.Load<GameObject>(relativePath, BattleResType.LevelMaker);

                for (int i = 0; i < levelCameraGroup.transform.childCount; i++)
                {
                    var cam = levelCameraGroup.transform.GetChild(i);
                    var levelCamera = cam.GetComponent<X3LevelCamera>();
                    if (levelCamera != null)
                    {
                        _levelCameraConfigs[levelCamera.ID] = levelCamera;
                    }
                }

                BattleResMgr.Instance.Unload<GameObject>(levelCameraGroup);
            }

            _battleVirCam = VirtualCamera.CreateVirtualCamera(CameraMode.Battle, battleTrackCameraName, CameraPriorityType.ProgrammingMiddle) as BattleVirtualCamera;
            _battleVirCam.OnAwake();
            _battleVirCam.followDummyType = ActorDummyType.PointCamera;
            
            _fpsVirCam = VirtualCamera.CreateVirtualCamera(CameraMode.FPS, fpsCameraName, CameraPriorityType.ProgrammingHigh);
            _fpsVirCam.OnAwake();
            _fpsVirCam.SetDisable();
            
            _x3VirCamera.m_GetMainCamera = GetMainCamera;
            SetCameraMode(CameraModeType.StartBattle, false);

            battle.eventMgr.AddListener<EventActorStateChange>(EventType.ActorStateChange, _OnActorStateChange, "CameraTrace._OnActorStateChange");
            battle.eventMgr.AddListener<EventTimeLineWithVirCam>(EventType.TimelineWithVirCam, _OnTimelineChange, "CameraTrace._OnTimelineChange");
            battle.eventMgr.AddListener<EventScalerChange>(EventType.OnScalerChange, _OnTimeScaleChange, "CameraTrace._OnTimeScaleChange");
            battle.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _OnCastSkill, "CameraTrace._OnCastSkill");
            battle.eventMgr.AddListener<EventChangeLevelState>(EventType.ChangeLevelState, _OnLevelStateChange, "CameraTrace._OnLevelStateChange");
            battle.eventMgr.AddListener<EventChangeLockTarget>(EventType.ChangeLockTarget, _OnChangeLockTarget, "CameraTrace._OnChangeLockTarget");
            
            rotateEnable = true;
        }

        protected void _OnPostPhysicalJobRunning()
        {
            using (new ProfilerMarker("_cameraBrain.Tick").Auto())
            {
                _cameraBrain.Tick();
            }
        }

        protected override void OnDestroy()
        {
            _cameraBrain.m_UpdateMethod = _formerUpdateMethod;
            battle.eventMgr.RemoveListener<EventChangeLevelState>(EventType.ChangeLevelState, _OnLevelStateChange);
            battle.eventMgr.RemoveListener<EventChangeLockTarget>(EventType.ChangeLockTarget, _OnChangeLockTarget);
            battle.eventMgr.RemoveListener<EventActorStateChange>(EventType.ActorStateChange, _OnActorStateChange); 
            battle.eventMgr.RemoveListener<EventTimeLineWithVirCam>(EventType.TimelineWithVirCam, _OnTimelineChange);
            battle.eventMgr.RemoveListener<EventScalerChange>(EventType.OnScalerChange, _OnTimeScaleChange);
            battle.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, _OnCastSkill);
            BattleClient.Instance.onPostPhysicalJobRunning.RemoveListener(OnPhysicalJobRunning);

            //note:UnityEvent有缺陷，移除回调后，内部依旧会持有一份缓存，目前调用如下代码可以解决！！
            _cameraBrain.m_CameraActivatedEvent.Invoke(null, null);

            _cameraBrain.m_CameraPreActivatedEvent.RemoveListener(_OnVirtualCameraPreActivated);
            _cameraBrain.m_CameraPreActivatedEvent.Invoke(null, null);

            _cameraBrain.m_CustomBlends = null;
            _levelCameraConfigs.Clear();

            _battleVirCam.Destroy();
            _freeVirCam?.Destroy();
            _fpsVirCam?.Destroy();

            _battleVirCam = null;
            _freeVirCam = null;
        }

        public Transform GetCameraTransform()
        {
            return Framework.GlobalMainCameraManager.Instance.MainCamera.transform;
        }

        public static Camera GetMainCamera()
        {
            return Framework.GlobalMainCameraManager.Instance.MainCamera;
        }

        public void SetEnable(bool enable)
        {
            _x3VirCamera.m_CameraMutateEnable = enable;
        }

        public void EnableLevelCamera(int ID)
        {
            _fpsVirCam.SetEnable();
            if (_levelCameraConfigs.TryGetValue(ID, out X3LevelCamera levelCamera))
            {
                _fpsVirCam.SyncParam(levelCamera.virCam);
            }
        }

        public void DisableLevelCamera()
        {
            _fpsVirCam.SetDisable();
        }

        /// <summary>
        /// 是否在相机视野内
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public bool IsInSight(Actor actor, bool isAccurate = true, float offsetX_L = 0,  float offsetY = 0, float offsetZ = 0, float offsetX_R = 1)
        {
            using (ProfilerDefine.CameraTraceIsInSight.Auto())
            {
                if (isAccurate)
                {
                    if (actor == null)
                        return false;
                    var pos = actor.GetDummy(ActorDummyType.PointCamera).position;
                    bool isInsight = IsInSight(pos, offsetX_L, offsetY, offsetZ, offsetX_R);

                    return isInsight;
                }
                else
                {
                    var _factorPos = actor.GetDummy().position;
                    var _camTrans = GetCameraTransform();
                    var _camPos = _camTrans.position;
                    var _camForward = _camTrans.forward;

                    Vector3 _fDirection = (_factorPos - _camPos).normalized;
                    float _angle = Vector3.Angle(_fDirection, _camForward);
                    float _FOV = GetMainCamera().fieldOfView * 0.5f;

                    return _angle < _FOV;
                }
            }
        }

        public bool IsInSight(Vector3 pos, float offsetX_L = 0,  float offsetY = 0, float offsetZ = 0, float offsetX_R = 1)
        {
            var viewPos = GetMainCamera().WorldToViewportPoint(pos);
            return viewPos.x > offsetX_L && viewPos.x < offsetX_R && viewPos.y > offsetY && viewPos.y < 1 - offsetY && viewPos.z > offsetZ;

        }

        public CinemachineVirtualCamera GetVirtualCamera()
        {
            return _battleVirCam != null ? _battleVirCam.cinemachineVirtualCamera : null;
        }

        public CinemachineBrain GetCameraBrain()
        {
            return _cameraBrain;
        }

        public void SetFov(int fov)
        {
            if (_x3VirCamera != null)
                _x3VirCamera.m_Lens.m_FieldOfView = fov;
            if (_x3FreeVirCamera != null)
                _x3FreeVirCamera.SetFov(fov);
        }

        public void SetDistanceFactor(float factor)
        {
            if (_x3VirCamera != null)
                _x3VirCamera.m_Distance.m_Factor = factor;
        }

        public void SetFollowTgt(bool isSmooth, Actor follow1st)
        {
            _battleVirCam.SetFollowTgt(follow1st);
        }

        /// <summary>
        /// 设置跟随Actor的挂点
        /// </summary>
        /// <param name="dummyType"></param>
        public void SetFollowDummyType(string dummyType)
        {
            _battleVirCam.followDummyType = dummyType;
        }
        
        public float GetDistanceFactor()
        {
            if (_x3VirCamera != null)
                return _x3VirCamera.m_Distance.m_Factor;
            return 1;
        }
        
        public int GetFov()
        {
            if (_x3VirCamera != null)
                return _x3VirCamera.m_Lens.m_FieldOfView;
            return 50;
        }

        /// <summary>
        /// 调用男主镜头
        /// </summary>
        public void UseBoyCameraAdjust(Actor target)
        {
            if (target != null)
            {
                _x3VirCamera?.SetLookAt2nd(battle.actorMgr.boy?.GetDummy(ActorDummyType.PointCamera));
                _x3VirCamera.CheckLookAtsAdjust(target.GetDummy(ActorDummyType.PointCamera));
            }
        }

        /// UI 拖动/Up/Down
        public void Down()
        {
            _x3VirCamera.Press();
        }
        public void Up()
        {
            _x3VirCamera.PressEnd();
        }

        public void Rotate(float x, float y, bool isDrag)
        {
            if (!rotateEnable )
                return;

            if (battle.actorMgr.boy != null && battle.actorMgr.boy.isDead)
                return;

            Vector2 delta = new Vector2(x, y);

            _x3FreeVirCamera?.AxisInput(delta, isDrag);

            if (!battle.enabled || _battleVirCam.follow1st == null)
            {
                return;
            }

            // 若处于虚拟相机过渡状态，就禁止拖动屏幕
            // 仅适用于目前战斗中仅有美术虚拟相机和战斗虚拟相机的情况
            if (_cameraBrain.IsBlending)
                return;

            _x3VirCamera.AxisInput(delta, isDrag);
        }

        public override void OnActorBorn(Actor actor)
        {
            if (actor == battle.player)
            {               
                _battleVirCam.SetFollowTgt(actor);
                _x3VirCamera.SetPitchAndYaw(_x3VirCamera.m_Viewport.m_DefaultPitch, actor.GetDummy(ActorDummyType.PointCamera).forward);
                _x3VirCamera.m_CameraMutateEnable = true;
                ImpulseMgr.Instance.ImpulseListener = battle.actorMgr.player.GetDummy().gameObject;
            }
        }

        public void SetCameraMode(CameraModeType targetType, bool blend = true)
        {
            if (targetType == CameraModeType.FreeLook)
            {
                if (_freeVirCam == null)
                {
                    _freeVirCam = VirtualCamera.CreateVirtualCamera(CameraMode.Free, camearModes[(int)CameraModeType.FreeLook], CameraPriorityType.ProgrammingHigh) as FreeLookVirtualCamera;
                    _freeVirCam.OnAwake();
                }
                _freeVirCam.EnableFreeCamera(_battleVirCam.rawPosition, _battleVirCam.rawOrientation, _x3VirCamera.m_Lens.m_FieldOfView);
            }
            else
            {
                _freeVirCam?.DisableFreeCamera();
                _battleVirCam.SetCameraMode(targetType, blend);
                
            }

            currMode = targetType;
        }

        public void PullIn()
        {
            _x3VirCamera.m_Target.cameraOffset.z += 0.2f;
        }
        public void PullOnt()
        {
            _x3VirCamera.m_Target.cameraOffset.z -= 0.2f;
        }

        public void MoveForward()
        {
            _x3FreeVirCamera?.MoveForward(battle.deltaTime);
        }

        public void MoveBack()
        {
            _x3FreeVirCamera?.MoveBack(battle.deltaTime);
        }

        public void MoveRight()
        {
            _x3FreeVirCamera?.MoveRight(battle.deltaTime);
        }

        public void MoveLeft()
        {
            _x3FreeVirCamera?.MoveLeft(battle.deltaTime);
        }

        public override void OnActorRecycle(Actor actor)
        {
            base.OnActorRecycle(actor);
            if (actor == null)
            {
                return;
            }

            _battleVirCam.OnActorRecycle(actor);

            if (actor == battle.actorMgr.player)
            {
                _battleVirCam.SetLockTgt(null);
            }
            else if (actor == battle.actorMgr.boy)
            {
                _battleVirCam.SetLockTgt(null);//男主回收
                _x3VirCamera.m_AutoLookAt.SetEnable(false);
            }
        }

        private void _InitCameraBrain()
        {
            var mainCamera = GetMainCamera();
            _cameraBrain = mainCamera.GetComponent<CinemachineBrain>();
            _formerUpdateMethod = _cameraBrain.m_UpdateMethod;
            _cameraBrain.m_UpdateMethod = CinemachineBrain.UpdateMethod.Manual;
            _cameraBrain.m_CameraPreActivatedEvent.RemoveListener(_OnVirtualCameraPreActivated);
            _cameraBrain.m_CameraPreActivatedEvent.AddListener(_OnVirtualCameraPreActivated);
            BattleClient.Instance.onPostPhysicalJobRunning.AddListener(_OnPostPhysicalJobRunning);

            var blenderSetting = BattleResMgr.Instance.Load<CinemachineBlenderSettings>(blendSettingName, BattleResType.CameraAsset);
            _cameraBrain.m_CustomBlends = blenderSetting;
            BattleResMgr.Instance.Unload<CinemachineBlenderSettings>(blenderSetting);
        }

        public static void SetDefaultBlend(CinemachineBlendDefinition.Style style, float time)
        {
            var camBrain = GetMainCamera().GetComponent<CinemachineBrain>();
            var defaultBlend = camBrain.m_DefaultBlend;
            defaultBlend.m_Style = style;
            defaultBlend.m_Time = time;

            camBrain.m_DefaultBlend = defaultBlend;
        }

        public void SetArtYawOffset(float offset)
        {
            _artYawOffset = offset;
        }

        private void _OnVirtualCameraPreActivated(ICinemachineCamera toVirtualCamera, ICinemachineCamera fromVirtualCamera)
        {
            if (_x3VirCamera == null)
                return;
            // CamTo是否为有效镜头
            var validCamTo = null != toVirtualCamera && toVirtualCamera.IsValid;
            if (!validCamTo)
            {
                return;
            }

            // CamFrom是否为有效镜头
            var validCamFrom = null != fromVirtualCamera && fromVirtualCamera.IsValid;
            if (!validCamFrom)
                return;

            if(_IsArtVirCamera(toVirtualCamera))
            {
                _x3VirCamera.m_AutoLookAt.SetEnable(false);
                rotateEnable = false;
                // 如果从战斗相机切到美术相机, 或从美术镜头切到美术镜头    
                if (_blendingCoroutine != null)
                    PapeGames.X3.CoroutineProxy.StopCoroutine(_blendingCoroutine);
                _blendingCoroutine = PapeGames.X3.CoroutineProxy.StartCoroutine(_OnCameraBlend(toVirtualCamera, fromVirtualCamera));

                var virCamOwner = _GetVirCamOwner(toVirtualCamera); // 该美术镜头所属timeLine的主角
                _cameraSkillType = ArtCameraType.None;
                if (virCamOwner != null)
                {
                    // 如果是男女主播的美术镜头，则只打开对应角色的虚化功能，如果是怪物播的美术镜头，则把男女主的都关掉
                    if (virCamOwner.IsBoy())
                    {
                        battle.actorMgr?.girl?.model.OcclusionSourceModifierEnable(false);
                        battle.actorMgr?.boy?.model.OcclusionSourceModifierEnable(true);
                    }
                    else if(virCamOwner.IsGirl())
                    {
                        battle.actorMgr?.girl?.model.OcclusionSourceModifierEnable(true);
                        battle.actorMgr?.boy?.model.OcclusionSourceModifierEnable(false);
                    }
                    else if (virCamOwner.IsMonster())
                    {
                        battle.actorMgr?.girl?.model.OcclusionSourceModifierEnable(false);
                        battle.actorMgr?.boy?.model.OcclusionSourceModifierEnable(false);
                    }

                    //美术镜头时关闭角色近距离虚化
                    //男主或女主美术镜头同时关闭男女主近距离虚化 基本都是共同表演 并且关闭技能目标虚化
                    if (virCamOwner.IsBoy() || virCamOwner.IsGirl())
                    {
                        battle.actorMgr.boy.model.SetApproachDissolveEnable(false);
                        battle.actorMgr.girl.model.SetApproachDissolveEnable(false);
                        _artCamSkillTarget = virCamOwner.targetSelector?.GetTarget();
                        if (_artCamSkillTarget != null && _artCamSkillTarget.model != null)
                            _artCamSkillTarget.model.SetApproachDissolveEnable(false);
                    }
                    else if (virCamOwner.type == ActorType.Monster)
                    {
                        virCamOwner.model.SetApproachDissolveEnable(false);
                    }

                    if (virCamOwner.IsBoy() && _boySkillType == SkillType.Coop)
                    {
                        // 如果是男主
                        _cameraSkillType = ArtCameraType.CoopSkill;
                    }
                    else if (virCamOwner.IsGirl() && _girlSkillType == SkillType.Coop)
                    {
                        // 如果是女主
                        _cameraSkillType = ArtCameraType.CoopSkill;
                    }
                    else if(virCamOwner.IsBoy() && _boySkillType == SkillType.Support)
                    {
                        _cameraSkillType = ArtCameraType.SupportSkill;
                    }
                    else if (virCamOwner.IsBoy() && _boySkillType == SkillType.EXMaleActive)
                    {
                        _cameraSkillType = ArtCameraType.EXMaleActive;
                    }
                }
            }
            else if (!_IsArtVirCamera(toVirtualCamera))
            {
                _x3VirCamera.m_AutoLookAt.SetEnable(true);
                rotateEnable = true;
                // 如果从美术镜头切到战斗镜头
                var virCamOwner = _GetVirCamOwner(fromVirtualCamera); // 该美术镜头所属timeLine的主角
                if (virCamOwner != null )
                {
                    if (_cameraSkillType== ArtCameraType.CoopSkill || _cameraSkillType == ArtCameraType.EXMaleActive)
                    {
                        // 如果是共鸣技 或者 EXMaleActive 美术镜头切回战斗镜头需要有过渡
                        _StartStateTransition(fromVirtualCamera);
                    }
                }
                
                battle.actorMgr?.girl?.model?.OcclusionSourceModifierEnable(true);
                battle.actorMgr?.boy?.model?.OcclusionSourceModifierEnable(false);
                //只要是到战斗镜头 都恢复所有近距离虚化 因为中间可能有穿插(如先女主共鸣技接怪物出生)或者没有owner(爆发技)
                battle.actorMgr?.boy?.model?.SetApproachDissolveEnable(true);
                battle.actorMgr?.girl?.model?.SetApproachDissolveEnable(true);
                virCamOwner?.model?.SetApproachDissolveEnable(true);
                _artCamSkillTarget?.model?.SetApproachDissolveEnable(true);
                _cameraSkillType = ArtCameraType.None;
            }
        }

        private IEnumerator _OnCameraBlend(ICinemachineCamera toVirtualCamera, ICinemachineCamera fromVirtualCamera)
        {
            yield return null;
            while (_cameraBrain.IsBlending && _cameraBrain.ActiveBlend.CamA == fromVirtualCamera && _cameraBrain.ActiveBlend.CamB == toVirtualCamera)
            {
                // 处于过渡中
                yield return null;
            }
            // camA是否为有效镜头
            var validCamTo = null != toVirtualCamera && toVirtualCamera.IsValid;

            // camB是否为有效镜头
            var validCamFrom = null != fromVirtualCamera && fromVirtualCamera.IsValid;
            if (validCamTo && validCamFrom && _cameraBrain.ActiveVirtualCamera == toVirtualCamera && _battleVirCam.follow1st!=null)
            {
                _battleVirCam.OnCameraBlend(_GetVirCamOwner(toVirtualCamera), _boySkillTarget, _cameraSkillType,_artYawOffset);
            }
            PapeGames.X3.CoroutineProxy.StopCoroutine(_blendingCoroutine);
            _blendingCoroutine = null;
        }

        public void SetPitchAndYawToTarget(Actor target)
        {
            Vector3 forward = target.GetDummy(ActorDummyType.PointCamera).position - _battleVirCam.follow1stPos;
            forward.y = 0;
            _x3VirCamera?.SetPitchAndYaw(_x3VirCamera.m_Viewport.m_DefaultPitch, forward.normalized);
        }

        private void _StartStateTransition(ICinemachineCamera artVirCam)
        {
            _x3VirCamera?.StartStateTransition(artVirCam.State.CorrectedPosition, artVirCam.State.CorrectedOrientation, artVirCam.State.Lens.FieldOfView, _x3VirCamera.m_StateTransitionTime);
        }

        private bool _IsArtVirCamera(ICinemachineCamera virCam)
        {
            var name = virCam.Name;
            return name != battleTrackCameraName && name!= camearModes[(int)CameraModeType.FreeLook];
        }

        private Actor _GetVirCamOwner(ICinemachineCamera virCam)
        {
            foreach (var v in _virCamActor.Values)
            {
                if (v.Value == virCam)
                {
                    return v.Key;
                }
            }

            return null;
        }

        private void _OnCastSkill(EventCastSkill arg)
        {
            if (arg.skill.actor.IsBoy())
            {
                // 男主放的技能记录下技能类型
                _boySkillType = arg.skill.config.Type;
            }
            else if (arg.skill.actor.IsGirl())
            {
                _girlSkillType = arg.skill.config.Type;
            }

            X3VirtualCamera.CameraOutViewAdjustPriority type;

            Actor cameraLookTarget;
            if (arg.skill.actor == _battleVirCam.follow1st)
            {
                cameraLookTarget = arg.skillTarget;
                type = X3VirtualCamera.CameraOutViewAdjustPriority.GirlSkill;
                if (!_x3VirCamera.m_GirlSkillAdjustEnable)
                    return;
            }
            else if (arg.skill.actor.IsBoy() && (_boySkillType == SkillType.MaleActive || _boySkillType == SkillType.EXMaleActive))
            {
                // 如果是男主放的主动技能，就看向男主
                cameraLookTarget = arg.skill.actor;
                _boySkillTarget = arg.skillTarget;

                type = X3VirtualCamera.CameraOutViewAdjustPriority.BoySkill;

                if (!_x3VirCamera.m_BoySkillAdjustEnable)
                    return;
            }
            else 
                return;
            if (cameraLookTarget == null)
            {
                _battleVirCam.SetLookAtTgt(null);
            }
            else
            {
                _battleVirCam.SetLookAtTgt(cameraLookTarget);
                _battleVirCam.x3VirCamera.CheckAutoAdjust(cameraLookTarget.GetDummy(ActorDummyType.PointCamera).position, type);
            }
        }

        private void _OnLevelStateChange(EventChangeLevelState arg)
        {
            if (currMode == CameraModeType.BoyDead)
                return;

            if (arg.curLevelBattleState == LevelBattleState.None)
                SetCameraMode(CameraModeType.NotBattle);
            else if (arg.curLevelBattleState == LevelBattleState.Normal)
                SetCameraMode(CameraModeType.Battle);
            else if (arg.curLevelBattleState == LevelBattleState.Boss)
                SetCameraMode(CameraModeType.BossBattle);
        }

        private void _OnChangeLockTarget(EventChangeLockTarget arg)
        {
            if (arg.actor == battle.player && currMode != CameraModeType.BoyDead)
            {
                _battleVirCam.SetLockTgt(arg.target);//目标
            }
        }

        private void _OnActorStateChange(EventActorStateChange arg)
        {
            if (arg.actor.IsBoy())
            {
                if (arg.toStateName == ActorMainStateType.Dead)
                {
                    _OnBoyDead(arg.actor);
                }
            }
        }

        public void _OnBoyDead(Actor target)
        {
            _battleVirCam.SetLockTgt(target);//男主死亡
            SetCameraMode(CameraModeType.BoyDead);
        }

        private void _OnTimelineChange(EventTimeLineWithVirCam arg)
        {
            ICinemachineCamera cam = arg.virCam?.GetComponent<CinemachineVirtualCamera>();
            if (cam == null)
                return;
            // Timeline开始
            if (arg.isStart)
            {
                _virCamActor[arg.owner] = new KeyValuePair<Actor, ICinemachineCamera>(arg.actor, cam);
            }
            else
            {
                if (_virCamActor.ContainsKey(arg.owner))
                    _virCamActor.Remove(arg.owner);
            }
        }

        private void _OnTimeScaleChange(EventScalerChange arg)
        {
            if (_x3VirCamera == null)
            {
                return;
            }

            if (!(arg.timeScalerOwner is Battle))
                return;

            // 只接受全局时间变化
            _x3VirCamera.m_TimeScale = arg.timeScale;
        }

        //调试器中途修改镜头参数模板
        public void SetCameraParam(X3VirtualCamera cameraParam, CameraModeType modeType)
        {
            if (cameraParam == null)
            {
                return;
            }
            //设置的模式是当前模式时，自动切换一下
            _battleVirCam.ChangeCameraParam(cameraParam, modeType);
        }
    }
}
