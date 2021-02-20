using System.Collections;
using System.Collections.Generic;
//using UnityEngine.Rendering.Papegame;
using UnityEngine;
using System;

public class CameraTrace : MonoBehaviour
{
    #region entry
    public const string LOOKAT_TARGET_CHANGED = "LOOKAT_TARGET_CHANGED";
    public static CameraTrace Instance { get; private set; }

    [Header("过渡参数")]
    public CLerp Lerp;
    [Header("拖拽参数")]
    public CDrag Drag;
    [Header("入场模式")]
    public CEnter EnterMode;
    [Header("自由模式")]
    public CFree FreeMode;
    [Header("双看向模式")]
    public CDoubleLookatTrace DoubleLookatMode;
    [Header("双主控模式")]
    public CDoubleCtrlTrace DoubleFollwMode;
    [Header("瞄准特写模式")]
    public CTakeAimTrace TakeAimMode;
    [Header("特写镜头")]
    public CCloseup Closeup;
    //[Header("淡入淡出")]
    //public CFade Fade;
    //public CShake Shake = new CShake();
    //public CCamEffect CamEffect = new CCamEffect();
    //public CSceneEffect SceneEffect = new CSceneEffect();
    public CCamera Camera = new CCamera();
    public CTarget Target = new CTarget();
    public CPostProcessing PostProcessing = new CPostProcessing();

    public GameObject RootO { get; private set; }
    public Transform RootT { get; private set; }
    public Transform FollowT { get; private set; }
    public Transform TargetT { get; private set; }
    public Transform LookAtT { get; private set; }
    public Transform LookAtDefaultT { get; private set; }
    public Transform CDockT { get; private set; }
    public Transform FDockT { get; private set; }
    public Transform CamRootT { get; private set; }
    public Transform ShakeT { get; private set; }

    public ECamMode CurrCamMode { get; private set; }
    public ETraceMode CurrTrackMode { get; private set; }
    public ECamMode PrevCamMode { get; private set; }
    public ETraceMode PrevTrackMode { get; private set; }
    public Action OnLookAtTgtLose { get; private set; }
    public bool IsCloseuping { get; private set; }
    public bool IsPauseFOV { get; private set; }
    public bool IsPause { get; private set; }

    private IEnumerator m_doubleCtrl_IEnumerator;
    private IEnumerator m_takeAim_IEnumerator;
    private IEnumerator m_dummyLookat_IEnumerator;

    public Camera MainCamera
    {
        get { return Camera.Cam; }
    }
    public Transform MainCameraT
    {
        get { return Camera.CamT; }
    }
    public Vector3 CameraPosition
    {
        get { return FDockT.position; }
    }
    public float CameraHorizontalFov
    {
        get { return Target.m_angle_fov_H; }
    }
    public float CameraVerticalFov
    {
        get { return Target.m_angle_fov_V; }
    }
    public Vector3 CameraForward
    {
        get { return Target.m_normalized_CO; }
    }

    public Transform LookAtTgt
    {
        get
        {
            if (null == Target)
            {
                return null;
            }
            return Target.m_lookAtTgt.Target;
        }
    }
    public Transform LookAt2ndTgt
    {
        get
        {
            if (null == Target)
            {
                return null;
            }
            return Target.m_lookAt2ndTgt.Target;
        }
    }
    public Transform FollowTgt
    {
        get
        {
            if (null == Target)
            {
                return null;
            }
            return Target.m_followTgt.Target;
        }
    }
    public Transform Follow2ndTgt
    {
        get
        {
            if (null == Target)
            {
                return null;
            }
            return Target.m_follow2ndTgt.Target;
        }
    }
    public void Enter(Action _onLookatTgtLost = null, float dragFactor = 1)
    {
        if (null == RootO)
        {
            return;
        }
        RootO.SetActive(true);
        IsCloseuping = false;
        IsPauseFOV = false;
        IsPause = false;
        Drag.Setup(dragFactor);
        CamRootT.SetParent(FDockT, false);
        OnLookAtTgtLose = _onLookatTgtLost;
        FDockT.localPosition = Vector3.zero;
        FDockT.localRotation = Quaternion.identity;
        RootT.position = Vector3.zero;
        RootT.rotation = Quaternion.identity;
        CurrTrackMode = ETraceMode.DoubleLookAt;
        Camera.Enter();
        Lerp.Enter();
        Drag.Enter();
        Target.Enter();
        //Shake.Enter();
        //CamEffect.Enter();
        //SceneEffect.Enter();
        Closeup.Enter();
        //Fade.Enter();
        PostProcessing.Enter();
    }
    public void Exit()
    {
        if (null == RootO)
        {
            return;
        }
        Lerp.Exit();
        Drag.Exit();
        Target.Exit();
        //Shake.Exit();
        //CamEffect.Exit();
        //SceneEffect.Exit();
        Closeup.Exit();
        //Fade.Exit();
        PostProcessing.Exit();
        DoubleLookatMode.Exit();
        DoubleFollwMode.Exit();
        TakeAimMode.Exit();
        FreeMode.Exit();
        EnterMode.Exit();
        Camera.Exit();
        CamRootT.SetParent(RootT, false);
        CurrCamMode = ECamMode.None;
        CurrTrackMode = ETraceMode.None;
        PrevCamMode = ECamMode.None;
        PrevTrackMode = ETraceMode.None;
        OnLookAtTgtLose = null;
        StopAllCoroutines();
        GameObject.Destroy(RootO);
        Instance = null;
    }

    void Awake()
    {
        Instance = this;
        RootO = gameObject;
        RootT = transform;
        FollowT = RootT.Find("Follow");
        TargetT = RootT.Find("Target");
        LookAtT = RootT.Find("LookAt");
        CDockT = RootT.Find("CDock");
        FDockT = RootT.Find("FDock");
        LookAtDefaultT = RootT.Find("LookAtDefault");
        CamRootT = RootT.Find("CamRoot");
        ShakeT = CamRootT.Find("Shake");

        Lerp.Awake();
        Drag.Awake();
        Target.Awake();
        //Shake.Awake();
        //CamEffect.Awake();
        //SceneEffect.Awake();
        Camera.Awake();
        Closeup.Awake();
        //Fade.Awake();
        PostProcessing.Awake();
        DoubleLookatMode.Awake();
        DoubleFollwMode.Awake();
        TakeAimMode.Awake();
        FreeMode.Awake();
        EnterMode.Awake();
    }

#if UNITY_EDITOR
    //void Update()
    //{
    //    if (Input.GetKeyDown(KeyCode.U))
    //    {
    //        PostProcessing.Play("FxPP_radialr", 10);
    //    }
    //    if (Input.GetKeyDown(KeyCode.Home))
    //    {
    //        SetDoubleFollowMode(Target.m_lookAtTgtTrans, Target.m_lookAt2ndTgtTrans, 15);
    //    }
    //    if (Input.GetKeyDown(KeyCode.U))
    //    {
    //        Effect.Play("fx_cha_YS_Camera_02", 5, EEffectType.ScreenShotRT);
    //    }
    //    if (Input.GetKeyDown(KeyCode.PageUp))
    //    {
    //        BattleTrackCameraControl.Track();
    //    }
    //    if (Input.GetKeyDown(KeyCode.K))
    //    {
    //        Fade.Play(2, 2, 2);
    //    }
    //    if (Input.GetKeyDown(KeyCode.T))
    //    {
    //        Closeup.Play("ToMap_ST", Vector3.zero, Vector3.zero, EPlayType.BlendStart2BlendEnd);
    //    }
    //    if (Input.GetKeyDown(KeyCode.T))
    //    {
    //        TakeAimMode.SetExternalSetup("PL_RY_Skill");
    //        SetTakeAimMode(false, Target.m_lookAtTgtTrans, null, 15, EPlayType.BlendStart2BlendEnd);
    //    }
    //    if (Input.GetKeyDown(KeyCode.R))
    //    {
    //        TakeAimMode.SetExternalSetup("PL_YS_CoopSkill");
    //        SetTakeAimMode(false, Target.m_lookAtTgtTrans, null, 15, EPlayType.BlendStart2BlendEnd);
    //    }
    //    if (Input.GetKeyDown(KeyCode.Home))
    //    {
    //        SetTakeAimMode(false, Target.m_lookAtTgtTrans, null, 15, EPlayType.BlendStart2BlendEnd);
    //    }
    //    if (Input.GetKeyDown(KeyCode.Home))
    //    {
    //        StandardAngle(false);
    //    }
    //    if (Input.GetKeyDown(KeyCode.Space))
    //    {
    //        Stretch(1, 10, 0, 5, 1);
    //    }
    //    if (Input.GetKeyDown(KeyCode.O))
    //    {
    //        StretchIn(1, 10, 5);
    //    }
    //    if (Input.GetKeyDown(KeyCode.P))
    //    {
    //        StretchOut(0);
    //    }
    //    if (Input.GetKeyDown(KeyCode.P))
    //    {
    //        Closeup.Play(Vector3.zero, Vector3.zero, 60, EPlayType.BlendStart2BlendEnd, 10);
    //    }
    //    if (Input.GetKeyDown(KeyCode.O))
    //    {
    //        Closeup.Play(Vector3.one, Vector3.zero, 60, EPlayType.BlinkStart2BlinkEnd, 10);
    //    }
    //    if (Input.GetKeyDown(KeyCode.Space))
    //    {
    //        SetDummyLookat(Vector3.one, 10, EPlayType.BlendStart2BlendEnd);
    //    }
    //}
    public void Init()
    {
        Awake();
    }
    public void Tick()
    {
        LateUpdate();
    }
#endif
    void LateUpdate()
    {
        if (IsPause || null == FollowTgt)
        {
            return;
        }
        // 索敌模式
        if (CurrCamMode == ECamMode.Trace)
        {
            if (Target.VerifyNoLookatTgt())
            {
                if (null != OnLookAtTgtLose)
                {
                    OnLookAtTgtLose.Invoke();
                }
                else
                {
                    SetLookAtTgt(null, null, true, ECamMode.Free);
                }
                return;
            }
            if (CurrTrackMode == ETraceMode.DoubleFollow && Target.VerifyNoFollow2ndTgt())
            {
                SetDoubleLookAtMode(Target.m_lookAtTgt, Target.m_lookAt2ndTgt);
                return;
            }
            if (CurrTrackMode == ETraceMode.TakeAim && Target.m_doubleFollowMode && Target.VerifyNoFollow2ndTgt())
            {
                SetDoubleLookAtMode(Target.m_lookAtTgt, Target.m_lookAt2ndTgt);
                return;
            }
        }

        //Fade.LateUpdate();
        //Shake.LateUpdate();
        //CamEffect.LateUpdate();
        //SceneEffect.LateUpdate();
        Closeup.LateUpdate();
        PostProcessing.LateUpdate();
        Target.LateUpdate();
        switch (CurrCamMode)
        {
            case ECamMode.Trace:
                switch (CurrTrackMode)
                {
                    case ETraceMode.DoubleLookAt:
                        DoubleLookatMode.LateUpdate();
                        break;
                    case ETraceMode.DoubleFollow:
                        DoubleFollwMode.LateUpdate();
                        break;
                    case ETraceMode.TakeAim:
                        TakeAimMode.LateUpdate();
                        break;
                    default: break;
                }
                break;
            case ECamMode.Enter:
                EnterMode.LateUpdate();
                break;
            case ECamMode.Free:
                FreeMode.LateUpdate();
                break;
            default: break;
        }
    }
    /// <summary>
    /// 暂停镜头逻辑
    /// </summary>
    public void Pause(bool isPause)
    {
        if (!isPause)
        {
            Camera.Reset();
        }
        IsPause = isPause;
    }
    /// <summary>
    /// 暂停镜头Fov的计算
    /// </summary>
    public void PauseFov(bool isPause)
    {
        IsPauseFOV = isPause;
    }
    /// <summary>
    /// 强制瞬跟
    /// </summary>
    public void ForceBlink()
    {
        Lerp.SetLerp(false);
    }
    /// <summary>
    /// 拖拽旋转
    /// </summary>
    /// <param name="_delta"></param>
    /// <param name="_draging"></param>
    public void Rotate(Vector2 _delta, bool _draging)
    {
        if (IsCloseuping)
        {
            return;
        }

        if (CurrCamMode != ECamMode.Free)
        {
            SetLookAtTgt(null, null, true, ECamMode.Free);
        }

        if (CurrCamMode == ECamMode.Free)
        {
            FreeMode.m_currSetup.RotateInput(_delta, _draging);
        }
    }
    /// <summary>
    /// 镜头看向
    /// </summary>
    /// <param name="_dir"></param>
    /// <param name="_speed"></param>
    public void ForwardByDir(Vector3 _dir, float _speed)
    {
        if (CurrCamMode == ECamMode.Free)
        {
            FreeMode.m_currSetup.ForwardByDir(_dir, _speed);
        }
    }
    /// <summary>
    /// 镜头看向
    /// </summary>
    /// <param name="_point"></param>
    /// <param name="_speed"></param>
    public void ForwardByPoint(Vector3 _point, float _speed)
    {
        if (CurrCamMode == ECamMode.Free)
        {
            FreeMode.m_currSetup.ForwardByPoint(_point, _speed);
        }
    }
    /// <summary>
    /// 点在视野内
    /// </summary>
    /// <param name="_point"></param>
    /// <returns></returns>
    public bool VerifyPointInTheViewport(Vector3 _point)
    {
        if (null == MainCamera)
        {
            return false;
        }

        _point = MainCamera.WorldToViewportPoint(_point);
        return !(_point.x < 0 || _point.x > 1 || _point.y < 0 || _point.y > 1);
    }
    /// <summary>
    /// 获取视野边缘位置
    /// </summary>
    /// 圆环角度=(FOV-边界冗余量)*竖屏分辨率/横屏分辨率
    /// 圆环内圈半径 = cp(相机与跟随者距离)
    /// 圆环外圈半径 = cm(相机与看向者距离) + cmSurplus; cmSurplus = k * cp / cm (k可配置)
    /// <param name="_fromPos"></param>
    /// <param name="_hFovOffset">边界冗余量</param>
    /// <param name="_factor">k</param>
    /// <returns></returns>
    public Vector3 GetEdgePointInTheViewport(Vector3 _fromPos, float _hFovOffset, float _factor)
    {
        _fromPos.y = 0;

        float _disCM = Vector3.Distance(Target.m_pointM, Target.m_pointC);
        float _disCP = Vector3.Distance(Target.m_pointP, Target.m_pointC);
        float _disCF = Vector3.Distance(_fromPos, Target.m_pointC);

        float _angle = Vector3.Angle((_fromPos - Target.m_pointC).normalized, Target.m_normalized_CO) - (Target.m_angle_fov_H - _hFovOffset) * 0.5f;

        Vector3 _dirCF = (_fromPos - Target.m_pointC).normalized;
        bool _right = Vector3.Cross(Target.m_normalized_CO, _dirCF).y >= 0;
        Vector3 _dirCT = Quaternion.AngleAxis(_right ? -_angle : _angle, Vector3.up) * _dirCF;

        float _dis = MathfCos(_angle) * _disCF;
        float _max = _disCM + _factor * _disCP / _disCM;
        float _min = _disCP;
        _dis = _dis > _max ? _max : (_dis < _min ? _min : _dis);

        return Target.m_pointC + _dirCT * _dis;
    }
    /// <summary>
    /// 固定在一侧的标准角度，角MCP_Best
    /// </summary>
    /// <param name="_onTheLeft"></param>
    public void StickToEdgeOfTheViewport(bool _onTheLeft)
    {
        if (CurrCamMode == ECamMode.Trace)
        {
            switch (CurrTrackMode)
            {
                case ETraceMode.DoubleFollow:
                    DoubleFollwMode.m_currSetup.m_nearFar.m_far.EdgeOfViewport(_onTheLeft, 1);
                    break;
                case ETraceMode.DoubleLookAt:
                    DoubleLookatMode.m_currSetup.m_nearFar.m_far.EdgeOfViewport(_onTheLeft, 1);
                    break;
                default: break;
            }
        }
    }
    /// <summary>
    /// 镜头拉伸
    /// </summary>
    /// <param name="_ratio"></param>
    /// <param name="_absolute"></param>
    /// <param name="_durationIn"></param>
    /// <param name="_durationKeep"></param>
    /// <param name="_durationOut"></param>
    public void Stretch(float _ratio, float _absolute, float _durationIn, float _durationKeep, float _durationOut, Action _cb = null)
    {
        switch (CurrCamMode)
        {
            case ECamMode.Free:
                FreeMode.m_currSetup.m_track.Stretch(_ratio, _absolute, _durationIn, _durationKeep, _durationOut, _cb);
                break;
            case ECamMode.Trace:
                switch (CurrTrackMode)
                {
                    case ETraceMode.DoubleFollow:
                        DoubleFollwMode.m_currSetup.m_nearFar.m_far.Stretch(_ratio, _absolute, _durationIn, _durationKeep, _durationOut, _cb);
                        break;
                    case ETraceMode.DoubleLookAt:
                        DoubleLookatMode.m_currSetup.m_nearFar.m_far.Stretch(_ratio, _absolute, _durationIn, _durationKeep, _durationOut, _cb);
                        break;
                    default: break;
                }
                break;
        }
    }
    /// <summary>
    /// 镜头拉伸
    /// </summary>
    /// <param name="_ratio"></param>
    /// <param name="_absolute"></param>
    /// <param name="_duration"></param>
    public void StretchIn(float _ratio, float _absolute, float _duration)
    {
        switch (CurrCamMode)
        {
            case ECamMode.Free:
                FreeMode.m_currSetup.m_track.StretchIn(_ratio, _absolute, _duration);
                break;
            case ECamMode.Trace:
                switch (CurrTrackMode)
                {
                    case ETraceMode.DoubleFollow:
                        DoubleFollwMode.m_currSetup.m_nearFar.m_far.StretchIn(_ratio, _absolute, _duration);
                        break;
                    case ETraceMode.DoubleLookAt:
                        DoubleLookatMode.m_currSetup.m_nearFar.m_far.StretchIn(_ratio, _absolute, _duration);
                        break;
                    default: break;
                }
                break;
        }
    }
    /// <summary>
    /// 镜头拉伸
    /// </summary>
    /// <param name="_duration"></param>
    public void StretchOut(float? _duration = null)
    {
        switch (CurrCamMode)
        {
            case ECamMode.Free:
                FreeMode.m_currSetup.m_track.StretchOut(_duration);
                break;
            case ECamMode.Trace:
                switch (CurrTrackMode)
                {
                    case ETraceMode.DoubleFollow:
                        DoubleFollwMode.m_currSetup.m_nearFar.m_far.StretchOut(_duration);
                        break;
                    case ETraceMode.DoubleLookAt:
                        DoubleLookatMode.m_currSetup.m_nearFar.m_far.StretchOut(_duration);
                        break;
                    default: break;
                }
                break;
        }
    }
    public void RecoverPrevMode()
    {
        switch (PrevCamMode)
        {
            case ECamMode.Free:
                SetLookAtTgt(null, null, true, ECamMode.Free);
                break;
            case ECamMode.Enter:
                SetLookAtTgt(null, null, true, ECamMode.Enter);
                break;
            case ECamMode.Trace:
                switch (PrevTrackMode)
                {
                    case ETraceMode.DoubleFollow:
                    case ETraceMode.DoubleLookAt:
                    case ETraceMode.TakeAim:
                        SetDoubleLookAtMode(Target.m_lookAtTgt, Target.m_lookAt2ndTgt);
                        break;
                    default: break;
                }
                break;
            default: break;
        }
    }
    public void SetLookAtPoint(Vector3 _lookatPoint, float _time, EPlayType _type)
    {
        if (_time < 0)
        {
            return;
        }
        if (null != m_dummyLookat_IEnumerator)
        {
            StopCoroutine(m_dummyLookat_IEnumerator);
            m_dummyLookat_IEnumerator = null;
        }

        bool _lerp = _type == EPlayType.None || _type == EPlayType.BlendStart2BlendEnd || _type == EPlayType.BlendStart2BlinkEnd || _type == EPlayType.BlendStart2NoEnd;
        LookAtDefaultT.position = _lookatPoint;
        SetLookAtTgt(new CTarget.CTgtArg(LookAtDefaultT, LookAtDefaultT, Vector2.zero), null, _lerp, ECamMode.Trace, ETraceMode.DoubleLookAt);

#if UNITY_EDITOR
        Debug.Log("[CameraTrace][设置看向点][当前帧：" + Time.frameCount + "][是否插值：" + _lerp + "]" + "[看向点位置：" + _lookatPoint + "]");
#endif

        m_dummyLookat_IEnumerator = TimeWait(_time, (Action)(() =>
        {
            if (Target.m_lookAtTgt.Target != LookAtDefaultT)
            {
                return;
            }
            if (null != OnLookAtTgtLose)
            {
                OnLookAtTgtLose.Invoke();
            }
            else
            {
                _lerp = _type == EPlayType.None || _type == EPlayType.BlendStart2BlendEnd || _type == EPlayType.BlinkStart2BlendEnd;
                SetLookAtTgt(null, null, _lerp, ECamMode.Free);
            }
        }));
        StartCoroutine(m_dummyLookat_IEnumerator);
    }
    public void SetTakeAimMode(bool _doubleFollow, CTarget.CTgtArg _lookat, CTarget.CTgtArg _follow, float _time, EPlayType _type)
    {
        if (null != m_takeAim_IEnumerator)
        {
            StopCoroutine(m_takeAim_IEnumerator);
            m_takeAim_IEnumerator = null;
        }

        bool _lerp = _type == EPlayType.None || _type == EPlayType.BlendStart2BlendEnd || _type == EPlayType.BlendStart2BlinkEnd || _type == EPlayType.BlendStart2NoEnd;
        SetFollowTgt(Target.m_followTgt, _follow, false);
        SetLookAtTgt(_lookat, Target.m_lookAt2ndTgt, _lerp, ECamMode.Trace, ETraceMode.TakeAim);
        Target.SetDoubleFollowMode(_doubleFollow);

#if UNITY_EDITOR
        Debug.Log("[CameraTrace][设置瞄准模式][当前帧：" + Time.frameCount + "][是否插值：" + _lerp + "]");
#endif

        m_takeAim_IEnumerator = TimeWait(_time, () =>
        {
            _lerp = _type == EPlayType.None || _type == EPlayType.BlendStart2BlendEnd || _type == EPlayType.BlinkStart2BlendEnd;
            SetDoubleLookAtMode(Target.m_lookAtTgt, Target.m_lookAt2ndTgt, _lerp);
        });
        StartCoroutine(m_takeAim_IEnumerator);
    }
    public void SetDoubleFollowMode(CTarget.CTgtArg _lookat, CTarget.CTgtArg _follow, float _time, EPlayType _type)
    {
        if (null != m_doubleCtrl_IEnumerator)
        {
            StopCoroutine(m_doubleCtrl_IEnumerator);
            m_doubleCtrl_IEnumerator = null;
        }
        bool _lerp = _type == EPlayType.None || _type == EPlayType.BlendStart2BlendEnd || _type == EPlayType.BlendStart2BlinkEnd || _type == EPlayType.BlendStart2NoEnd;
        SetFollowTgt(Target.m_followTgt, _follow, false);
        SetLookAtTgt(_lookat, Target.m_lookAt2ndTgt, _lerp, ECamMode.Trace, ETraceMode.DoubleFollow);
        Target.SetDoubleFollowMode(true);

#if UNITY_EDITOR
        Debug.Log("[CameraTrace][设置双跟随模式][当前帧：" + Time.frameCount + "][是否插值：" + _lerp + "]");
#endif

        m_doubleCtrl_IEnumerator = TimeWait(_time, () =>
        {
            _lerp = _type == EPlayType.None || _type == EPlayType.BlendStart2BlendEnd || _type == EPlayType.BlinkStart2BlendEnd;
            SetDoubleLookAtMode(Target.m_lookAtTgt, Target.m_lookAt2ndTgt, _lerp);
        });
        StartCoroutine(m_doubleCtrl_IEnumerator);
    }
    public void SetDoubleLookAtMode(CTarget.CTgtArg _lookat, CTarget.CTgtArg _loookat2nd, bool _lerp = true)
    {
        if (null != m_doubleCtrl_IEnumerator)
        {
            StopCoroutine(m_doubleCtrl_IEnumerator);
            m_doubleCtrl_IEnumerator = null;
        }
        if (null != m_takeAim_IEnumerator)
        {
            StopCoroutine(m_takeAim_IEnumerator);
            m_takeAim_IEnumerator = null;
        }

#if UNITY_EDITOR
        Debug.Log("[CameraTrace][设置双看向模式][当前帧：" + Time.frameCount + "][是否插值：" + _lerp + "]");
#endif

        Target.SetDoubleFollowMode(false);
        SetFollowTgt(Target.m_followTgt, null, false);
        SetLookAtTgt(_lookat, _loookat2nd, _lerp, ECamMode.Trace, ETraceMode.DoubleLookAt);
    }
    public void SetFreeMode(bool _lerp = true)
    {
        if (null != m_doubleCtrl_IEnumerator)
        {
            StopCoroutine(m_doubleCtrl_IEnumerator);
            m_doubleCtrl_IEnumerator = null;
        }
        if (null != m_takeAim_IEnumerator)
        {
            StopCoroutine(m_takeAim_IEnumerator);
            m_takeAim_IEnumerator = null;
        }
        if (null != m_dummyLookat_IEnumerator)
        {
            StopCoroutine(m_dummyLookat_IEnumerator);
            m_dummyLookat_IEnumerator = null;
        }

        Target.SetDoubleFollowMode(false);
        SetFollowTgt(Target.m_followTgt, null, false);
        SetLookAtTgt(null, null, _lerp, ECamMode.Free);
    }
    public void SetFollowTgt(CTarget.CTgtArg _t, CTarget.CTgtArg _t2nd, bool _lerp)
    {
        bool _result = false;
        if (Target.SetFollowTgt(_t))
        {
            _result = true;
        }
        if (Target.SetFollow2ndTgt(_t2nd))
        {
            _result = true;
        }
        if (_result)
        {
            Lerp.SetLerp(_lerp);
        }
        if (CurrCamMode == ECamMode.None)
        {
            CurrCamMode = ECamMode.Free;
        }
    }
    public void SetLookAtTgt(CTarget.CTgtArg _t, CTarget.CTgtArg _t2nd, bool _lerp, ECamMode _mode, ETraceMode _traceMode = ETraceMode.None)
    {
        bool _result = false;
        if (Target.SetLookAtTgt(_t))
        {
            _result = true;
        }
        if (Target.SetLookAt2ndTgt(_t2nd))
        {
            _result = true;
        }
        if (ChangeMode(_mode, _traceMode))
        {
            _result = true;
        }
        if (_result)
        {
            Lerp.SetLerp(_lerp);
        }
        //EventDispatcher.Instance.DispatchEvent(LOOKAT_TARGET_CHANGED, Target.m_lookAtTgt.Target);
    }
    private bool ChangeMode(ECamMode _mode, ETraceMode _traceMode)
    {
        if (_traceMode == ETraceMode.None)
        {
            _traceMode = CurrTrackMode;
        }
        if (CurrCamMode == _mode && CurrTrackMode == _traceMode)
        {
            return false;
        }

        PrevCamMode = CurrCamMode;
        PrevTrackMode = CurrTrackMode;
        switch (CurrCamMode)
        {
            case ECamMode.Trace:
                switch (CurrTrackMode)
                {
                    case ETraceMode.DoubleLookAt:
                        DoubleLookatMode.Exit();
                        break;
                    case ETraceMode.DoubleFollow:
                        DoubleFollwMode.Exit();
                        break;
                    case ETraceMode.TakeAim:
                        TakeAimMode.Exit();
                        break;
                }
                break;
            case ECamMode.Free:
                FreeMode.Exit();
                break;
            case ECamMode.Enter:
                EnterMode.Exit();
                break;
            default: break;
        }

        CurrCamMode = _mode;
        CurrTrackMode = _traceMode;
        switch (CurrCamMode)
        {
            case ECamMode.Trace:
                switch (CurrTrackMode)
                {
                    case ETraceMode.DoubleLookAt:
                        DoubleLookatMode.Enter();
                        break;
                    case ETraceMode.DoubleFollow:
                        DoubleFollwMode.Enter();
                        break;
                    case ETraceMode.TakeAim:
                        TakeAimMode.Enter();
                        break;
                    default: break;
                }
                break;
            case ECamMode.Free:
                FreeMode.Enter();
                break;
            case ECamMode.Enter:
                EnterMode.Enter();
                break;
            default: break;
        }
        return true;
    }

    public T AddMissingComponent<T>(GameObject _tgt) where T : Component
    {
        if (null == _tgt)
        {
            return null;
        }
        T t = _tgt.GetComponent<T>();
        if (null == t)
        {
            t = _tgt.AddComponent<T>();
        }
        return t;
    }
    public T AddMissingComponent<T>(Transform _tgt) where T : Component
    {
        return AddMissingComponent<T>(_tgt.gameObject);
    }
    public IEnumerator TimeWait(float _time, Action _cb)
    {
        yield return new WaitForSeconds(_time);
        _cb?.Invoke();
    }
    public IEnumerator TimeWait(float _time, string _key, Action<string> _cb)
    {
        yield return new WaitForSeconds(_time);
        _cb?.Invoke(_key);
    }
    public IEnumerator FrameWait(int _frame, Action _cb)
    {
        while (true)
        {
            if (_frame <= 0)
            {
                break;
            }
            _frame--;
            yield return null;
        }
        _cb?.Invoke();
    }
    public IEnumerator FrameWait(int _frame, string _key, Action<string> _cb)
    {
        while (true)
        {
            if (_frame <= 0)
            {
                break;
            }
            _frame--;
            yield return null;
        }
        _cb?.Invoke(_key);
    }
    private static float MathfCos(float angle)
    {
        // return CosCalculate.CalcCosByDeg(angle);
        return UnityEngine.Mathf.Cos(angle * UnityEngine.Mathf.Deg2Rad);
    }
    private static float MathfSin(float angle)
    {
        // return SinCalculate.CalcSinByDeg(angle);
        return UnityEngine.Mathf.Sin(angle * UnityEngine.Mathf.Deg2Rad);
    }
    private static float MathfTan(float angle)
    {
        return Mathf.Tan(angle * UnityEngine.Mathf.Deg2Rad);
    }
    private static float MathfAsin(float value)
    {
        return Mathf.Asin(value);
    }
    private static float MathfAtan(float value)
    {
        return Mathf.Atan(value);
    }
    private static float HorizontalFov(float _verticallyFov, float _aspect)
    {
        return 2 * Mathf.Rad2Deg * MathfAtan(MathfTan(_verticallyFov * 0.5f) * _aspect);
    }
    #endregion

    #region camera
    // [System.Serializable]
    public class CCamera
    {
        public Transform Root { get; private set; }
        public Transform CamP { get; private set; }
        public Transform CamT { get; private set; }
        public Animator CamA { get; private set; }
        public Camera Cam { get; private set; }
        //public PapeGameAdditionalCameraData Additional { get; private set; }

        private Transform m_defaultCamT;

        public void Awake()
        {
            Root = Instance.ShakeT;
            m_defaultCamT = Root.Find("Camera");
            if (null != m_defaultCamT)
            {
                m_defaultCamT.gameObject.SetActive(false);
            }
        }

        public void Enter()
        {
            Camera cam = UnityEngine.Camera.main;
            if (null != cam)
            {
                Load(cam.transform);
            }
            else
            {
                Load(m_defaultCamT);
            }
            CamT.gameObject.SetActive(true);
        }

        public void Exit()
        {
            if (CamT != m_defaultCamT)
            {
                CamT.parent = CamP;
            }
            Cam = null;
            CamA = null;
            //Additional = null;
        }
        public void Reset()
        {
            if (null != CamT)
            {
                CamT.localPosition = Vector3.zero;
                CamT.localRotation = Quaternion.identity;
                CamT.localScale = Vector3.one;
            }
        }
        private void Load(Transform _camera)
        {
            if (null == _camera)
            {
                return;
            }
            CamT = _camera;
            CamP = CamT.parent;
            CamT.parent = Root;
            Cam = Instance.AddMissingComponent<Camera>(CamT);
            CamA = Instance.AddMissingComponent<Animator>(CamT);
            //Additional = Root.GetComponent<PapeGameAdditionalCameraData>();
            CamA.enabled = false;
            Cam.enabled = true;
            Reset();
        }
    }
    #endregion

    #region target
    // [System.Serializable]
    public class CTarget : IDefine
    {
        public const string CONST_Dummy_Ccamera = "camera";

        private Transform m_dockT;
        private Transform m_lookAtT;
        private CLerp m_lerp;

        // 点M 怪点
        public Vector3 m_pointM { get; private set; }
        // 点P 玩家点
        public Vector3 m_pointP { get; private set; }
        // 点M 怪点高度
        public float m_pointM_Height { get; private set; }
        // 点P 玩家点高度
        public float m_pointP_Height { get; private set; }
        // 点C 相机点
        public Vector3 m_pointC { get; private set; }
        // 点O 看向点
        public Vector3 m_pointO { get; private set; }
        // 向量CO
        public Vector3 m_normalized_CO { get; private set; }
        // 向量CP
        public Vector3 m_normalized_CP { get; private set; }
        // 向量MP
        public Vector3 m_normalized_MP { get; private set; }
        // 向量CM
        public Vector3 m_normalized_CM { get; private set; }
        // 长度MP
        public float m_line_MP_L { get; private set; }

        // 横向比例 （m_angle_PCO_Cur/m_angle_fov_H）
        public float m_radio_horizontally { get; private set; }
        // 纵向比例
        public float m_radio_vertically { get; private set; }

        // 横向比例
        public float m_radio_lookat_horizontally { get; private set; }
        // 纵向比例
        public float m_radio_lookat_vertically { get; private set; }

        // 角度MCP 当前
        public float m_angle_MCP_Cur { get; private set; }
        // 角度PCO 当前
        public float m_angle_PCO_Cur { get; private set; }

        // 横向fov
        public float m_angle_fov_H { get; private set; }
        // 纵向fov
        public float m_angle_fov_V { get; private set; }

        public CTgtArg m_followTgt { get; private set; }
        public CTgtArg m_follow2ndTgt { get; private set; }
        public CTgtArg m_lookAtTgt { get; private set; }
        public CTgtArg m_lookAt2ndTgt { get; private set; }

        public bool m_doubleLookatMode { get; private set; }
        public bool m_doubleFollowMode { get; private set; }

        private bool m_blink;
        private CValue m_lookatHeight;
        private CValue m_followHeight;

        private Vector3 m_posTemp;

        public void Awake()
        {
            m_dockT = Instance.FDockT;
            m_lookAtT = Instance.LookAtT;
            m_lerp = Instance.Lerp;
            m_lookatHeight = new CValue(8);
            m_followHeight = new CValue(8);
            m_followTgt = new CTgtArg();
            m_follow2ndTgt = new CTgtArg();
            m_lookAtTgt = new CTgtArg();
            m_lookAt2ndTgt = new CTgtArg();
        }
        public void Enter()
        {

        }
        public void Exit()
        {
            m_doubleLookatMode = false;
            m_doubleFollowMode = false;
            m_followTgt.Clear();
            m_follow2ndTgt.Clear();
            m_lookAtTgt.Clear();
            m_lookAt2ndTgt.Clear();
            m_radio_horizontally = 0;
            m_radio_vertically = 0;
            m_radio_lookat_horizontally = 0;
            m_radio_lookat_vertically = 0;
            m_lookatHeight.Reset();
            m_followHeight.Reset();
        }
        public void LateUpdate()
        {
            m_angle_fov_V = Instance.MainCamera.fieldOfView;
            m_angle_fov_H = HorizontalFov(m_angle_fov_V, Instance.MainCamera.aspect);

            m_blink = m_lerp.m_speed_pickup.Blink;
            m_lerp.CalcPickupSpeed();
            if (!VerifyNoFollowTgt())
            {
                CalcFollow();
            }
            if (!VerifyNoLookatTgt())
            {
                CalcLookat();
            }
        }
        private void CalcFollow()
        {
            m_posTemp = GetFollowTgtPosition();
            m_pointP_Height = Mathf.Lerp(m_pointP_Height, m_followHeight.CalcValue(m_posTemp.y, m_blink), m_blink ? 1 : Time.smoothDeltaTime);

            m_posTemp = !m_doubleFollowMode || VerifyNoFollow2ndTgt() ? m_posTemp : Vector3.Lerp(m_posTemp, GetFollow2ndTgtPosition(), 0.5f);
            m_posTemp.y = 0;
            m_pointP = Vector3.Lerp(m_pointP, m_posTemp, m_lerp.m_speed_pickup.m_speed_cur);

            m_posTemp = m_dockT.position;
            m_posTemp.y = 0;
            m_pointC = m_posTemp;
            m_posTemp = m_lookAtT.position;
            m_posTemp.y = 0;
            m_pointO = m_posTemp;

            m_normalized_CO = (m_pointO - m_pointC).normalized;
            m_normalized_CP = (m_pointP - m_pointC).normalized;
            m_angle_PCO_Cur = Vector3.Angle(m_normalized_CP, m_normalized_CO);
            m_radio_horizontally = Mathf.Clamp(m_angle_PCO_Cur / (m_angle_fov_H * 0.5f), 0, 1);
        }
        private void CalcLookat()
        {
            m_posTemp = GetLookAtTgtPosition();
            m_pointM_Height = Mathf.Lerp(m_pointM_Height, m_lookatHeight.CalcValue(m_posTemp.y, m_blink), m_blink ? 1 : Time.smoothDeltaTime * 20);

            m_posTemp = !m_doubleLookatMode || VerifyNoLookat2ndTgt() ? m_posTemp : Vector3.Lerp(m_posTemp, GetLookAt2ndTgtPosition(), 0.5f);
            m_posTemp.y = 0;
            m_pointM = Vector3.Lerp(m_pointM, m_posTemp, m_lerp.m_speed_pickup.m_speed_cur);

            m_normalized_MP = (m_pointP - m_pointM).normalized;
            m_normalized_CM = (m_pointM - m_pointC).normalized;
            m_angle_MCP_Cur = Vector3.Angle(m_normalized_CM, m_normalized_CP);
            m_line_MP_L = Vector3.Distance(m_pointM, m_pointP);
            m_radio_lookat_horizontally = Mathf.Clamp((m_angle_MCP_Cur - m_angle_PCO_Cur) / (m_angle_fov_H * 0.5f), 0, 1);
        }
        public void SetDoubleLookatMode(bool _m)
        {
            m_doubleLookatMode = _m;
            if (_m)
            {
                if (null != m_follow2ndTgt.Target && m_follow2ndTgt.Target == m_lookAt2ndTgt.Target)
                {
                    m_doubleFollowMode = false;
                }
            }
        }
        public void SetDoubleFollowMode(bool _m)
        {
            m_doubleFollowMode = _m;
            if (_m)
            {
                if (null != m_lookAt2ndTgt.Target && m_lookAt2ndTgt.Target == m_follow2ndTgt.Target)
                {
                    m_doubleLookatMode = false;
                }
            }
        }
        public bool SetFollowTgt(CTgtArg _t)
        {
            if (null == _t)
            {
                if (null != m_followTgt.Target)
                {
                    m_followTgt.Clear();
                    return true;
                }
                return false;
            }
            if (_t.Target == m_followTgt.Target)
            {
                return false;
            }
            if (_t.Target == m_lookAtTgt.Target)
            {
                m_lookAtTgt.Clear();
            }
            m_followTgt.SetTarget(_t.Target, _t.Root, _t.JumpInterval);
            m_followHeight.SetJumpInterval(_t.JumpInterval);
            return true;
        }
        public bool SetFollow2ndTgt(CTgtArg _t)
        {
            if (null == _t)
            {
                if (null != m_follow2ndTgt.Target)
                {
                    m_follow2ndTgt.Clear();
                    return true;
                }
                return false;
            }
            if (_t.Target == m_followTgt.Target || _t.Target == m_follow2ndTgt.Target)
            {
                return false;
            }
            m_follow2ndTgt.SetTarget(_t.Target, _t.Root, _t.JumpInterval);
            return true;
        }
        public bool SetLookAtTgt(CTgtArg _t)
        {
            if (null == _t)
            {
                if (null != m_lookAtTgt.Target)
                {
                    m_lookAtTgt.Clear();
                    return true;
                }
                return false;
            }
            if ((null != m_followTgt.Target && _t.Target == m_followTgt.Target) || (null != m_follow2ndTgt.Target && _t.Target == m_follow2ndTgt.Target) || _t.Target == m_lookAtTgt.Target)
            {
                return false;
            }
            m_lookAtTgt.SetTarget(_t.Target, _t.Root, _t.JumpInterval);
            m_lookatHeight.SetJumpInterval(_t.JumpInterval);
            return true;
        }
        public bool SetLookAt2ndTgt(CTgtArg _t)
        {
            if (null == _t)
            {
                if (null != m_lookAt2ndTgt.Target)
                {
                    m_lookAt2ndTgt.Clear();
                    return true;
                }
                return false;
            }
            if ((null != m_followTgt.Target && _t.Target == m_followTgt.Target) || (null != m_follow2ndTgt.Target && _t.Target == m_follow2ndTgt.Target) || _t.Target == m_lookAtTgt.Target || _t.Target == m_lookAt2ndTgt.Target)
            {
                return false;
            }
            m_lookAt2ndTgt.SetTarget(_t.Target, _t.Root, _t.JumpInterval);
            return true;
        }
        public bool VerifyNoFollowTgt()
        {
            return null == m_followTgt.Target;
        }
        public bool VerifyNoFollow2ndTgt()
        {
            return null == m_follow2ndTgt.Target;
        }
        public bool VerifyNoLookatTgt()
        {
            return null == m_lookAtTgt.Target;
        }
        public bool VerifyNoLookat2ndTgt()
        {
            return null == m_lookAt2ndTgt.Target;
        }
        public Vector3 GetFollowTgtEulerAngles()
        {
            if (null != m_followTgt.Target)
            {
                return m_followTgt.Target.eulerAngles;
            }
            return Vector3.zero;
        }
        public Vector3 GetFollowRootEulerAngles()
        {
            if (null != m_followTgt.Root)
            {
                return m_followTgt.Root.eulerAngles;
            }
            return Vector3.zero;
        }
        public Vector3 GetFollowTgtPosition()
        {
            if (null != m_followTgt.Target)
            {
                return m_followTgt.Target.position;
            }
            return Vector3.zero;
        }
        public Vector3 GetFollowRootPosition()
        {
            if (null != m_followTgt.Root)
            {
                return m_followTgt.Root.position;
            }
            return Vector3.zero;
        }
        public Vector3 GetFollow2ndTgtForward()
        {
            if (null != m_follow2ndTgt.Target)
            {
                return m_follow2ndTgt.Target.eulerAngles;
            }
            return Vector3.zero;
        }
        public Vector3 GetFollow2ndTgtPosition()
        {
            if (null != m_follow2ndTgt.Target)
            {
                return m_follow2ndTgt.Target.position;
            }
            return Vector3.zero;
        }
        public Vector3 GetLookAtTgtEulerAngles()
        {
            if (null != m_lookAtTgt.Target)
            {
                return m_lookAtTgt.Target.eulerAngles;
            }
            return Vector3.zero;
        }
        public Vector3 GetLookAtRootEulerAngles()
        {
            if (null != m_lookAtTgt.Root)
            {
                return m_lookAtTgt.Root.eulerAngles;
            }
            return Vector3.zero;
        }
        public Vector3 GetLookAtRootPosition()
        {
            if (null != m_lookAtTgt.Root)
            {
                return m_lookAtTgt.Root.position;
            }
            return Vector3.zero;
        }
        public Vector3 GetLookAtTgtPosition()
        {
            if (null != m_lookAtTgt.Target)
            {
                return m_lookAtTgt.Target.position;
            }
            return Vector3.zero;
        }
        public Vector3 GetLookAt2ndTgtEulerAngles()
        {
            if (null != m_lookAt2ndTgt.Target)
            {
                return m_lookAt2ndTgt.Target.eulerAngles;
            }
            return Vector3.zero;
        }
        public Vector3 GetLookAt2ndTgtPosition()
        {
            if (null != m_lookAt2ndTgt.Target)
            {
                return m_lookAt2ndTgt.Target.position;
            }
            return Vector3.zero;
        }

        public class CTgtArg
        {
            public bool IsCS { get; private set; }
            public Transform Root { get; private set; }
            public Transform Target { get; private set; }
            public Vector2 JumpInterval { get; private set; }
            public CTgtArg()
            {
                IsCS = true;
            }
            public CTgtArg(Transform tgt, Transform root, Vector2 jumpInterval)
            {
                IsCS = true;
                Target = tgt;
                Root = root ?? tgt;
                JumpInterval = jumpInterval;
            }
            public void SetTarget(Transform tgt, Transform root, Vector2 jumpInterval)
            {
                Target = tgt;
                Root = root ?? tgt;
                JumpInterval = jumpInterval;
            }
            public void Clear()
            {
                Target = null;
                JumpInterval = Vector2.zero;
            }
        }
        public class CValue
        {
            /*
            值在小范围抖动时，让它处于默认值，防止镜头晃动频繁
            x表示：看向点在这个高度以下运动时，读取y【默认看向点】
            y表示：默认看向点的高度
            */
            private Vector2 m_jumpInterval = Vector2.zero;
            private List<float> m_array;
            private int m_lengthMax;
            private int m_nextIndex;
            private float m_tempV;

            public CValue(int length)
            {
                m_lengthMax = length;
                m_array = new List<float>();
            }

            public void Reset()
            {
                m_array.Clear();
                m_nextIndex = 0;
            }

            public void SetJumpInterval(Vector2 value)
            {
                m_jumpInterval = value;
            }

            public float CalcValue(float newValue, bool reset = false)
            {
                if (reset)
                {
                    Reset();
                }

                if (newValue < m_jumpInterval.x)
                {
                    newValue = m_jumpInterval.y;
                }

                if (m_array.Count <= m_nextIndex)
                {
                    m_array.Add(newValue);
                }
                else
                {
                    m_array[m_nextIndex] = newValue;
                }
                m_nextIndex++;
                m_nextIndex = m_nextIndex >= m_lengthMax ? 0 : m_nextIndex;

                m_tempV = 0;
                foreach (var v in m_array)
                {
                    m_tempV += v;
                }
                m_tempV = m_tempV / (m_array.Count * 1.0f);

                return m_tempV;
            }
        }
    }
    #endregion

    #region track speed calc
    [System.Serializable]
    public class CSpeed : IDefine
    {
        private CTarget m_target;

        [Header("平滑过渡曲线")]
        public AnimationCurve m_transitionCurve = AnimationCurve.Linear(0, 0, 1, 1);
        [Header("平滑过渡时间")]
        public float m_transitionTime = 2;

        [Header("跟随速率最大值")]
        public AnimationCurve m_speedMax = AnimationCurve.Linear(0, 15, 1, 50);
        [Header("跟随速率最小值")]
        public AnimationCurve m_speedMin = AnimationCurve.Linear(0, 0, 1, 10);

        [Header("跟随速率当前值")]
        public float m_speed_cur = 30;

        // 瞬间
        public bool Blink
        {
            get
            {
                return m_isBlink;
            }
        }
        private bool m_isBlink = false;
        private bool m_isLerp = false;

        private float m_tick = 0.1f;
        private float m_speed_max = 0.1f;
        private float m_speed_min = 0.1f;

        public void Awake()
        {
            m_target = Instance.Target;
        }
        public void Enter()
        {
        }
        public void Exit()
        {
            m_isBlink = false;
            m_isLerp = false;
        }
        public void LateUpdate()
        {
        }
        public void CalcSpeed()
        {
            if (m_isBlink || m_transitionTime <= 0)
            {
                m_isBlink = false;
                m_speed_cur = 1;
                return;
            }

            if (m_isLerp)
            {
                m_isLerp = false;
                m_tick = 0;
            }

            m_tick += Time.deltaTime;
            m_tick = m_tick > m_transitionTime ? m_transitionTime : m_tick;

            m_speed_max = m_speedMax.Evaluate(m_target.m_radio_horizontally);
            m_speed_min = m_speedMin.Evaluate(m_target.m_radio_horizontally);
            m_speed_cur = Time.smoothDeltaTime * Mathf.Lerp(m_speed_min, m_speed_max, m_transitionCurve.Evaluate(m_tick / m_transitionTime));
        }
        public void SetLerp(bool _lerp)
        {
            m_isLerp = _lerp;
            m_isBlink = !_lerp;
        }
        public void SetLerpTime(float _duration)
        {
            m_transitionTime = _duration;
        }
    }
    #endregion

    #region track lerp assembly
    [System.Serializable]
    public class CLerp : IDefine
    {
        [Header("平滑取点速率")]
        public CSpeed m_speed_pickup;
        [Header("追踪跟随速率")]
        public CSpeed m_speed_track;
        [Header("自由跟随速率")]
        public CSpeed m_speed_free;

        public bool m_isLerp { get; private set; }

        public void Awake()
        {
            m_speed_free.Awake();
            m_speed_track.Awake();
            m_speed_pickup.Awake();
        }
        public void Enter()
        {
        }
        public void Exit()
        {
            m_speed_track.Exit();
            m_speed_free.Exit();
            m_speed_pickup.Exit();
        }
        public void LateUpdate()
        {
        }
        public void CalcTrackSpeed()
        {
            m_speed_track.CalcSpeed();
            m_speed_free.CalcSpeed();
        }
        public void CalcPickupSpeed()
        {
            m_speed_pickup.CalcSpeed();
        }
        public void SetLerp(bool _lerp)
        {
            m_isLerp = _lerp;
            m_speed_pickup.SetLerp(_lerp);
            m_speed_track.SetLerp(_lerp);
            m_speed_free.SetLerp(_lerp);

#if UNITY_EDITOR
            Debug.Log("[CameraTrace][speed][当前帧：" + Time.frameCount + "][是否插值：" + _lerp + "]");
#endif
        }
        public void SetLerpTime(float _druation)
        {
            m_speed_track.SetLerpTime(_druation);
            m_speed_free.SetLerpTime(_druation);
        }
    }
    #endregion

    #region enter mode
    [System.Serializable]
    public class CEnterSetup : CDefine, IDefine
    {
        [Header("跟随参数")]
        public CTraceNoLookat m_track;
        [Header("入场持续时间")]
        public float m_enter_Duration = 2f;

        private IEnumerator m_duration_IEnumerator;

        public void Awake()
        {
            m_track.Awake();
        }
        public void Enter()
        {
            m_track.Enter();
            if (null != m_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_duration_IEnumerator);
            }
            m_duration_IEnumerator = Instance.TimeWait(m_enter_Duration, (Action)(() =>
            {
                if (Instance.CurrCamMode == ECamMode.Enter)
                {
                    Instance.SetLookAtTgt(null, null, (bool)true, (ECamMode)ECamMode.Free);
                }
            }));
            Instance.StartCoroutine(m_duration_IEnumerator);
        }
        public void Exit()
        {
            m_track.Exit();
            if (null != m_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_duration_IEnumerator);
                m_duration_IEnumerator = null;
            }
        }
        public void LateUpdate()
        {
            m_track.LateUpdate();
        }
    }
    [System.Serializable]
    public class CEnter : IMode<CEnterSetup>
    {
    }
    #endregion

    #region free mode
    [System.Serializable]
    public class CFreeSetup : CDefine, IDefine
    {
        [Header("跟随参数")]
        public CTraceNoLookat m_track;

        [Header("拖拽后的复位时间")]
        public float m_reset_time_after_drag = 3;

        private CDrag m_drag;
        private IEnumerator m_reset_duration_IEnumerator;

        public void Awake()
        {
            m_drag = Instance.Drag;
            m_track.Awake();
        }
        public void Enter()
        {
            m_track.Enter();
            m_drag.Enter();
            m_drag.m_drag_output = RotateOutput;
        }
        public void Exit()
        {
            m_track.Exit();
            m_drag.Exit();
            m_drag.m_drag_output = null;

            if (null != m_reset_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_reset_duration_IEnumerator);
                m_reset_duration_IEnumerator = null;
            }
        }
        public void LateUpdate()
        {
            m_track.LateUpdate();
            m_drag.LateUpdate();
        }
        public void ForwardByDir(Vector3 _dir, float _speed)
        {
            m_track.ForwardByDir(_dir, _speed);
        }
        public void ForwardByPoint(Vector3 _point, float _speed)
        {
            m_track.ForwardByDir(_point, _speed);
        }
        public void RotateInput(Vector2 _delta, bool _rotating)
        {
            m_drag.Rotate(_delta, _rotating);
        }
        private void RotateOutput(Vector2 _delta, bool _rotating)
        {
            if (Instance.IsCloseuping)
            {
                m_drag.Stop();
                m_track.ResetAngleOfPitch();
                return;
            }

            m_track.Rotate(_delta, _rotating);

            if (null != m_reset_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_reset_duration_IEnumerator);
                m_reset_duration_IEnumerator = null;
            }
            if (!_rotating)
            {
                m_reset_duration_IEnumerator = Instance.TimeWait(m_reset_time_after_drag, m_track.ResetAngleOfPitch);
                Instance.StartCoroutine(m_reset_duration_IEnumerator);
            }
        }
    }
    [System.Serializable]
    public class CFree : IMode<CFreeSetup>
    {
    }
    #endregion

    #region double lookat mode
    [System.Serializable]
    public class CDoubleLookatTraceSetup : CDefine, IDefine
    {
        [Header("近远距离判断")]
        public CNearFarTrace m_nearFar;
        [Header("单双目标判断")]
        public CMultiple m_multiple;

        public virtual void Awake()
        {
            m_multiple.Awake();
            m_nearFar.Awake();
        }
        public virtual void Enter()
        {
            m_multiple.Awake();
            m_nearFar.Awake();
        }
        public virtual void Exit()
        {
            m_multiple.Exit();
            m_nearFar.Exit();
        }
        public virtual void LateUpdate()
        {
            m_nearFar.ChangeFarMode();
            m_nearFar.SetLinePCEvalute();

            if (m_nearFar.m_farMode == 2)
            {
                m_multiple.ChangeMulitMode();
            }
            if (m_nearFar.m_farMode == 1)
            {
                m_nearFar.m_near.LateUpdate();
            }
            else if (m_nearFar.m_farMode == 2)
            {
                m_nearFar.m_far.LateUpdate();
            }
        }
    }
    [System.Serializable]
    public class CDoubleLookatTrace : IMode<CDoubleLookatTraceSetup>
    {
    }
    #endregion

    #region double ctrl mode
    [System.Serializable]
    public class CDoubleCtrlTraceSetup : CDefine, IDefine
    {
        protected CTarget m_target;

        [Header("近远距离判断")]
        public CNearFarTrace m_nearFar;

        public virtual void Awake()
        {
            m_target = Instance.Target;
            m_nearFar.Awake();
        }
        public virtual void Enter()
        {
            m_nearFar.Awake();
        }
        public virtual void Exit()
        {
            m_nearFar.Exit();
        }
        public virtual void LateUpdate()
        {
            if (!m_target.VerifyNoFollow2ndTgt())
            {
                m_nearFar.SetLinePCEvalute(Vector3.Distance(m_target.GetFollowTgtPosition(), m_target.GetFollow2ndTgtPosition()));
            }
            m_nearFar.LateUpdate();
        }
    }
    [System.Serializable]
    public class CDoubleCtrlTrace : IMode<CDoubleCtrlTraceSetup>
    {
    }
    #endregion

    #region take aim mode
    [System.Serializable]
    public class CTakeAimTraceSetup : CDefine, IDefine
    {
        [Header("近远距离判断")]
        public CNearFarTraceWithCloseup m_nearFar;

        public virtual void Awake()
        {
            m_nearFar.Awake();
        }
        public virtual void Enter()
        {
        }
        public virtual void Exit()
        {
            m_nearFar.Exit();
        }
        public virtual void LateUpdate()
        {
            m_nearFar.SetLinePCEvalute();
            m_nearFar.LateUpdate();
        }
    }
    [System.Serializable]
    public class CTakeAimTrace : IMode<CTakeAimTraceSetup>
    {
    }
    #endregion

    #region mulitiple target logic
    [System.Serializable]
    public class CMultiple : IDefine
    {
        protected CTarget m_target;
        protected CLerp m_lerp;


        [Header("单双目标分界线")]
        public float m_line_single_multi = 6;
        [Header("双单目标分界线")]
        public float m_line_mulit_single = 6;
        [Header("单双目标切换过渡时间")]
        public float m_single_mulit_transition_time = 2;

        // 目标模式 1为单 2为双
        public int m_multipleMode { get; private set; }
        // 双目标距离
        private float m_dis_MM;

        public virtual void Awake()
        {
            m_target = Instance.Target;
            m_lerp = Instance.Lerp;
            m_line_mulit_single = m_line_mulit_single < m_line_single_multi ? m_line_single_multi : m_line_mulit_single;
        }
        public virtual void Enter()
        {
        }
        public virtual void Exit()
        {
            m_multipleMode = 0;
        }
        public virtual void LateUpdate()
        {
            ChangeMulitMode();
        }
        public void ChangeMulitMode()
        {
#if UNITY_EDITOR
            m_line_mulit_single = m_line_mulit_single < m_line_single_multi ? m_line_single_multi : m_line_mulit_single;
#endif
            if (m_target.VerifyNoLookat2ndTgt())
            {
                ChangeMulitMode(1, m_multipleMode == 0 ? m_lerp.m_isLerp : true);
            }
            else
            {
                m_dis_MM = Vector3.Distance(m_target.GetLookAt2ndTgtPosition(), m_target.GetLookAtTgtPosition());
                if (m_multipleMode == 1 && m_dis_MM < m_line_single_multi)
                {
                    ChangeMulitMode(2);
                }
                else if (m_multipleMode == 2 && m_dis_MM > m_line_mulit_single)
                {
                    ChangeMulitMode(1);
                }
                else if (m_multipleMode == 0)
                {
                    ChangeMulitMode(1, m_lerp.m_isLerp);
                }
            }
        }
        private void ChangeMulitMode(int _v, bool _lerp = true)
        {
            if (_v == m_multipleMode)
            {
                return;
            }
            m_multipleMode = _v;
            m_target.SetDoubleLookatMode(_v == 2);
            m_lerp.SetLerp(_lerp);
            m_lerp.SetLerpTime(m_single_mulit_transition_time);
        }
    }
    #endregion

    #region near far logic
    // [System.Serializable]
    public abstract class CNearFar : IDefine
    {
        protected CTarget m_target;
        protected CLerp m_lerp;

        protected virtual CTraceNoLookat Near { get; }
        protected virtual CTraceWithLookat Far { get; }

        [Tooltip("当超过此值时，使用此模式下的近距离设置！！！")]
        [Header("最大追踪距离")]
        public float m_dis_trace_max = 100;
        [Header("远近分界线")]
        public float m_line_far_near = 6;
        [Header("近远分界线")]
        public float m_line_near_far = 6;

        // 跟随模式 1为近 2为远
        public int m_farMode { get; protected set; }
        // 目标和跟随距离
        private float m_dis_MP;

        public virtual void Awake()
        {
            m_target = Instance.Target;
            m_lerp = Instance.Lerp;
            Near.Awake();
            Far.Awake();
        }
        public virtual void Enter()
        {
        }
        public virtual void Exit()
        {
            Near.Exit();
            Far.Exit();
            m_farMode = 0;
        }
        public virtual void LateUpdate()
        {
            ChangeFarMode();

            if (m_farMode == 1)
            {
                Near.LateUpdate();
            }
            else if (m_farMode == 2)
            {
                Far.LateUpdate();
            }
        }
        public void SetLinePCEvalute(float? _value = null)
        {
            if (null == _value)
            {
                _value = m_target.m_line_MP_L;
            }
            Far.m_line_PC_S_Evaluate = _value.Value;
        }
        public void ChangeFarMode()
        {
            m_dis_MP = Vector3.Distance(m_target.GetFollowTgtPosition(), m_target.GetLookAtTgtPosition());
            if (m_farMode == 2 && m_dis_MP < m_line_far_near)
            {
                ChangeFarMode(1);
            }
            else if (m_farMode == 1 && m_dis_MP < m_dis_trace_max && m_dis_MP > m_line_near_far)
            {
                ChangeFarMode(2);
            }
            else if (m_farMode == 0)
            {
                if ((m_dis_MP > m_dis_trace_max || m_dis_MP < m_line_far_near))
                {
                    ChangeFarMode(1, m_lerp.m_isLerp);
                }
                else
                {
                    ChangeFarMode(2, m_lerp.m_isLerp);
                }
            }
        }
        private void ChangeFarMode(int _v, bool _lerp = true)
        {
            if (_v == m_farMode)
            {
                return;
            }
            switch (m_farMode)
            {
                case 1:
                    Near.Exit();
                    break;
                case 2:
                    Far.Exit();
                    break;
                default: break;
            }
            m_farMode = _v;
            m_lerp.SetLerp(_lerp);
            switch (m_farMode)
            {
                case 1:
                    Near.Enter();
                    break;
                case 2:
                    Far.Enter();
                    break;
                default: break;
            }
        }
    }
    #endregion

    #region drag calc logic

    [System.Serializable]
    public class CDrag : IDefine
    {
        [Header("拖拽转换：传入值")]
        public float m_factor_outside = 1f;
        [Header("拖拽转换：加系数")]
        public float m_factor_add = 0.5f;
        [Header("拖拽转换：乘系数")]
        public float m_factor_multiply = 1.5f;

        [Header("x轴：拖拽delta值限制")]
        public float m_drag_rotate_delta_x_limit = 200;
        [Header("x轴：拖拽旋转速度幂")]
        public float m_drag_rotate_delta_x_pow = 1.36f;
        [Header("x轴：拖拽旋转速度因子")]
        public float m_drag_rotate_delta_x_factor = 0.04f;

        [Header("y轴：拖拽delta值限制")]
        public float m_drag_rotate_delta_y_limit = 100;
        [Header("y轴：拖拽旋转速度幂")]
        public float m_drag_rotate_delta_y_pow = 1.36f;
        [Header("y轴：拖拽旋转速度因子")]
        public float m_drag_rotate_delta_y_factor = 0.015f;

        [Header("y轴：横向值与纵向值比率")]
        public float m_drag_rotate_x_divide_y_ratio = 0.8f;

        [Header("拖拽旋转结束时的阻尼")]
        public float m_drag_rotate_damp = 20;

        public Action<Vector2, bool> m_drag_output { private get; set; }

        private IEnumerator m_damp_IEnumerator;
        private int m_temp = 1;

        public void Awake()
        {
        }
        public void Setup(float dragFactor = 1)
        {
            float factor = (dragFactor * m_factor_multiply) + m_factor_add;
            m_factor_outside = dragFactor;

            m_drag_rotate_delta_x_limit *= factor;
            m_drag_rotate_delta_x_pow *= factor;
            m_drag_rotate_delta_x_factor *= factor;

            m_drag_rotate_delta_y_limit *= factor;
            m_drag_rotate_delta_y_pow *= factor;
            m_drag_rotate_delta_y_factor *= factor;

            m_drag_rotate_damp *= factor;
        }
        public void Enter()
        {
        }
        public void Exit()
        {
            Stop();
        }
        public void LateUpdate()
        {
        }
        public void Stop()
        {
            if (null != m_damp_IEnumerator)
            {
                Instance.StopCoroutine(m_damp_IEnumerator);
                m_damp_IEnumerator = null;
            }
        }
        public void Rotate(Vector2 _delta, bool _rotating)
        {
            if (_delta != Vector2.zero && !_rotating)
            {
                if (null != m_damp_IEnumerator) Instance.StopCoroutine(m_damp_IEnumerator);
                m_damp_IEnumerator = Damp(_delta);
                Instance.StartCoroutine(m_damp_IEnumerator);
                return;
            }

            if (null != m_damp_IEnumerator)
            {
                Instance.StopCoroutine(m_damp_IEnumerator);
                m_damp_IEnumerator = null;
            }
            m_drag_output?.Invoke(Convert(_delta), _rotating);
        }
        private IEnumerator Damp(Vector2 _delta)
        {
            while (Vector2.SqrMagnitude(_delta) > 0.1f)
            {
                _delta = Vector2.Lerp(_delta, Vector2.zero, Time.smoothDeltaTime * m_drag_rotate_damp);
                m_drag_output?.Invoke(Convert(_delta), true);

                yield return null;
            }
            m_drag_output?.Invoke(Vector2.zero, false);
        }
        private Vector2 Convert(Vector2 _delta)
        {
            Vector2 _result = Vector2.zero;
            if (_delta.x != 0)
            {
                _delta.x = _delta.x > m_drag_rotate_delta_x_limit ? m_drag_rotate_delta_x_limit : _delta.x;
                _delta.x = _delta.x < -m_drag_rotate_delta_x_limit ? -m_drag_rotate_delta_x_limit : _delta.x;
                m_temp = _delta.x > 0 ? 1 : -1;
                _result.x = m_temp * Mathf.Pow(m_temp * _delta.x, m_drag_rotate_delta_x_pow) * m_drag_rotate_delta_x_factor;
            }
            if (_delta.y != 0 && Mathf.Abs(_delta.x / _delta.y) < m_drag_rotate_x_divide_y_ratio)
            {
                _delta.y = _delta.y > m_drag_rotate_delta_y_limit ? m_drag_rotate_delta_y_limit : _delta.y;
                _delta.y = _delta.y < -m_drag_rotate_delta_y_limit ? -m_drag_rotate_delta_y_limit : _delta.y;
                m_temp = _delta.y > 0 ? 1 : -1;
                _result.y = (-m_temp * Mathf.Pow(m_temp * _delta.y, m_drag_rotate_delta_y_pow) * m_drag_rotate_delta_y_factor);
            }
            return _result;
        }
    }
    #endregion

    #region far lookat and near free logic
    [System.Serializable]
    public class CNearFarTrace : CNearFar
    {
        [Header("近距离参数")]
        public CTraceNoLookat m_near;
        [Header("远距离参数")]
        public CTraceWithLookat m_far;

        protected override CTraceNoLookat Near { get { return m_near; } }
        protected override CTraceWithLookat Far { get { return m_far; } }
    }
    #endregion

    #region far lookat and near free and closeup logic
    [System.Serializable]
    public class CNearFarTraceWithCloseup : CNearFar
    {
        [Header("近距离参数")]
        public CTraceNoLookat m_near;
        [Header("远距离参数")]
        public CTraceWithLookat2Closeup m_far;

        protected override CTraceNoLookat Near { get { return m_near; } }
        protected override CTraceWithLookat Far { get { return m_far; } }
    }
    #endregion

    #region follow track without lookat logic
    [System.Serializable]
    public class CTraceNoLookat : IDefine
    {
        [Header("过渡时间")]
        public float m_transition_time = 2;
        [Header("角度：相机fov")]
        public float m_fov = 50;
        [Header("自由区域夹角比例：玩家-相机-中线")]
        [Range(0, 0.5f)]
        public float m_angleRatio_free_PCO = 0.4f;

        [Header("距离：玩家-相机")]
        public float m_line_PC_SCurve = 6;

        [Header("距离：看向点偏移标准值")]
        public Vector3 m_look_positionOffset_template = new Vector3(0, 1.2f, 0);

        [Header("角度：相机俯仰角当前值")]
        public float m_dock_angleOfPitch_curr = 20;
        [Header("角度：相机俯仰角标准值")]
        public float m_dock_angleOfPitch_template = 20;
        [Header("角度：相机俯仰角区间")]
        public Vector2 m_dock_angleOfPitch_zone = new Vector2(0, 60);

        protected Transform m_rootT;
        protected Transform m_followT;
        protected Transform m_targetT;
        protected Transform m_lookAtT;
        protected Transform m_dockT;
        protected CTarget m_target;
        protected CLerp m_lerp;

        // 相机点高度偏移
        protected Vector3 m_dockHeightOffset = new Vector3(0, 0, 0);

        // 角度PCO 当前
        protected float m_angle_PCO_Cur;
        // 角度PCO 最大
        protected float m_angle_PCO_Max;

        // 点O
        protected Vector3 m_point_O;
        // 点C
        protected Vector3 m_point_C;
        // 点Temp
        protected Vector3 m_point_Temp;

        // 玩家-相机距离
        protected float m_line_PC_S_3D = 4;
        protected float m_line_PC_S_2D = 4;

        // lerp
        protected Vector3 m_dockLerp;
        protected Vector3 m_lookatLerp;

        // 旋转中
        protected bool m_rotating;
        private float? m_rootRotateAngle;
        private IEnumerator m_ienumerator_forward;

        // 拉伸中
        protected bool m_stretching;
        protected bool m_stretching_in;
        protected bool m_stretching_out;
        protected float m_stretchInSpeed;
        protected float m_stretchOutSpeed;
        protected float m_stretchOutDuration;
        private IEnumerator m_ienumerator_stretch;

        public virtual void Awake()
        {
            m_rootT = Instance.RootT;
            m_followT = Instance.FollowT;
            m_targetT = Instance.TargetT;
            m_lookAtT = Instance.LookAtT;
            m_dockT = Instance.FDockT;
            m_lerp = Instance.Lerp;
            m_target = Instance.Target;
            m_line_PC_S_3D = m_line_PC_SCurve;
        }
        public virtual void Enter()
        {
            m_dock_angleOfPitch_curr = m_dock_angleOfPitch_template;
            m_lerp.SetLerpTime(m_transition_time);
            m_line_PC_S_3D = m_line_PC_SCurve;
        }
        public virtual void Exit()
        {
            m_rotating = false;
            if (null != m_ienumerator_forward)
            {
                Instance.StopCoroutine(m_ienumerator_forward);
                m_ienumerator_forward = null;
            }
            m_stretching = false;
            m_stretching_in = false;
            m_stretching_out = false;
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }
        }
        public virtual void LateUpdate()
        {
            if (CalcCheck())
            {
                m_lerp.CalcTrackSpeed();
                ShowPoint();
                CalcAngle();
                CalcLineS(m_lerp.m_speed_free.m_speed_cur);
                CalcCamOffset();
                CalcCamPos(m_lerp.m_speed_free.m_speed_cur);
                CalcLookatPos(m_lerp.m_speed_free.m_speed_cur);
                CalcCamFov(m_lerp.m_speed_free.m_speed_cur);
                CalcRootPos();
            }
        }
        public virtual void Rotate(Vector2 _delta, bool _rotating)
        {
            if (null != m_ienumerator_forward)
            {
                Instance.StopCoroutine(m_ienumerator_forward);
                m_ienumerator_forward = null;
            }

            if (_delta.x != 0)
            {
                m_rootRotateAngle = _delta.x;
            }
            if (_delta.y != 0)
            {
                m_dock_angleOfPitch_curr += _delta.y;
                m_dock_angleOfPitch_curr = Mathf.Clamp(m_dock_angleOfPitch_curr, m_dock_angleOfPitch_zone.x, m_dock_angleOfPitch_zone.y);
            }
            m_rotating = _rotating;
        }
        public virtual void ForwardByDir(Vector3 _dir, float _speed)
        {
            if (null != m_ienumerator_forward)
            {
                Instance.StopCoroutine(m_ienumerator_forward);
                m_ienumerator_forward = null;
            }
            if (_speed <= 0)
            {
                m_lerp.SetLerp(false);
                _speed = 1;
            }
            else
            {
                _speed *= Time.smoothDeltaTime;
            }
            _dir.y = 0;
            _dir = _dir.normalized;
            m_ienumerator_forward = Forward(m_target.m_normalized_CO, _dir, _speed);
            Instance.StartCoroutine(m_ienumerator_forward);
        }
        public virtual void ForwardByPoint(Vector3 _point, float _speed)
        {
            if (m_target.VerifyNoFollowTgt())
            {
                return;
            }
            Vector3 _fPos = m_target.GetFollowTgtPosition();
            _fPos.y = 0;
            _point.y = 0;
            ForwardByDir((_point - _fPos).normalized, _speed);
        }
        public virtual void ResetAngleOfPitch()
        {
            if (Mathf.Approximately(m_dock_angleOfPitch_curr, m_dock_angleOfPitch_template))
            {
                return;
            }
            m_dock_angleOfPitch_curr = m_dock_angleOfPitch_template;
            m_lerp.SetLerp(true);
        }
        public virtual void Stretch(float _ratio, float _absolute, float _durationIn, float _durationKeep, float _durationOut, Action _cb = null)
        {
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }

            m_stretching = true;
            m_stretchOutDuration = _durationOut;
            StretchIn(_ratio, _absolute, _durationIn, () =>
            {
                m_ienumerator_stretch = Instance.TimeWait(_durationKeep, () =>
                {
                    StretchOut(_durationOut, () => { m_stretching = false; _cb?.Invoke(); });
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            });
        }
        public virtual void StretchIn(float _ratio, float _absolute, float _duration, Action _cb = null)
        {
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }

            m_stretching = true;
            var _dis = m_line_PC_S_3D * _ratio + _absolute;
            if (_duration <= 0)
            {
                m_line_PC_S_3D = _dis;
                m_lerp.SetLerp(false);
                m_ienumerator_stretch = Instance.FrameWait(1, () =>
                {
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
            else
            {
                m_stretching_in = true;
                m_stretchInSpeed = (_dis - m_line_PC_S_3D) / _duration;
                m_ienumerator_stretch = Instance.TimeWait(_duration, () =>
                {
                    m_stretching_in = false;
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
        }
        public virtual void StretchOut(float? _duration = null, Action _cb = null)
        {
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }
            if (null == _duration)
            {
                _duration = m_stretchOutDuration;
            }

            m_stretching = true;
            var _dis = m_line_PC_SCurve;
            if (_duration.Value <= 0)
            {
                m_line_PC_S_3D = _dis;
                m_lerp.SetLerp(false);
                m_ienumerator_stretch = Instance.FrameWait(1, () =>
                {
                    m_stretching = false;
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
            else
            {
                m_stretching_out = true;
                m_stretchOutSpeed = (m_line_PC_S_3D - _dis) / _duration.Value;
                m_ienumerator_stretch = Instance.TimeWait(_duration.Value, () =>
                {
                    m_stretching = false;
                    m_stretching_out = false;
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
        }
        protected virtual bool CalcCheck()
        {
            if (m_target.VerifyNoFollowTgt())
            {
                return false;
            }
            return true;
        }
        protected virtual void ShowPoint()
        {
            m_point_Temp = m_target.m_pointP;
            m_point_Temp.y = m_target.m_pointP_Height;
            m_followT.position = m_point_Temp;

            m_point_Temp = m_target.m_pointM;
            m_point_Temp.y = m_target.m_pointM_Height;
            m_targetT.position = m_point_Temp;
        }
        protected virtual void CalcAngle()
        {
            m_angle_PCO_Cur = m_target.m_angle_PCO_Cur;
            m_angle_PCO_Max = m_fov * Screen.width / Screen.height * m_angleRatio_free_PCO;
            m_angle_PCO_Cur = m_angle_PCO_Cur > m_angle_PCO_Max ? m_angle_PCO_Max : m_angle_PCO_Cur;
        }
        protected virtual void CalcLineS(float speed)
        {
            if (m_stretching)
            {
                if (m_stretching_in)
                {
                    m_line_PC_S_3D += (Time.deltaTime * m_stretchInSpeed);
                }
                else if (m_stretching_out)
                {
                    m_line_PC_S_3D -= (Time.deltaTime * m_stretchOutSpeed);
                    if (Mathf.Approximately(m_line_PC_S_3D, m_line_PC_SCurve))
                    {
                        m_stretching_in = false;
                        m_stretching_out = false;
                    }
                }
            }
            else
            {
                m_line_PC_S_3D = Mathf.Lerp(m_line_PC_S_3D, m_line_PC_SCurve, speed);
            }
        }
        protected virtual void CalcCamOffset()
        {
#if UNITY_EDITOR
            m_dock_angleOfPitch_curr = Mathf.Clamp(m_dock_angleOfPitch_curr, m_dock_angleOfPitch_zone.x, m_dock_angleOfPitch_zone.y);
#endif
            m_line_PC_S_2D = MathfCos(m_dock_angleOfPitch_curr) * m_line_PC_S_3D;
            m_dockHeightOffset.y = MathfSin(m_dock_angleOfPitch_curr) * m_line_PC_S_3D + m_look_positionOffset_template.y;
        }
        protected virtual void CalcCamPos(float speed)
        {
            m_point_C = m_rotating ? m_target.m_pointP + Quaternion.AngleAxis(Vector3.Cross(m_target.m_normalized_CO, m_target.m_normalized_CP).y >= 0 ? m_angle_PCO_Cur : -m_angle_PCO_Cur, Vector3.up) * -m_target.m_normalized_CO * m_line_PC_S_2D : m_target.m_pointP + -m_target.m_normalized_CP * m_line_PC_S_2D;
            m_dockLerp = m_point_C + m_dockHeightOffset;
            m_dockT.position = Vector3.Lerp(m_dockT.position, m_dockLerp, speed);
        }
        protected virtual void CalcLookatPos(float speed)
        {
            m_point_O = m_rotating ? m_point_C + m_target.m_normalized_CO * MathfCos(m_angle_PCO_Cur) * m_line_PC_S_2D : m_point_C + Quaternion.AngleAxis(Vector3.Cross(m_target.m_normalized_CO, m_target.m_normalized_CP).y >= 0 ? -m_angle_PCO_Cur : m_angle_PCO_Cur, Vector3.up) * m_target.m_normalized_CP * MathfCos(m_angle_PCO_Cur) * m_line_PC_S_2D; // 判断左侧还是右侧
            m_lookatLerp = m_point_O + m_look_positionOffset_template;
            m_lookAtT.position = Vector3.Lerp(m_lookAtT.position, m_lookatLerp, speed);

            m_dockT.LookAt(m_lookAtT.position);
        }
        protected virtual void CalcCamFov(float speed)
        {
            if (Instance.IsCloseuping || Instance.IsPauseFOV)
            {
                return;
            }
            Instance.MainCamera.fieldOfView = Mathf.Lerp(Instance.MainCamera.fieldOfView, m_fov, speed);
        }
        protected virtual void CalcRootPos()
        {
            if (Instance.IsCloseuping)
            {
                if (null != m_ienumerator_forward)
                {
                    Instance.StopCoroutine(m_ienumerator_forward);
                    m_ienumerator_forward = null;
                }
                m_rootRotateAngle = null;
            }
            if (null == m_rootRotateAngle)
            {
                return;
            }
            m_rootT.RotateAround(m_followT.position, Vector3.up, m_rootRotateAngle.Value);
            m_rootRotateAngle = null;
        }
        private IEnumerator Forward(Vector3 _from, Vector3 _to, float _speed)
        {
            Vector3 _fromPrev;
            int _assist = Vector3.Cross(_from, _to).y < 0 ? -1 : 1;
            while (!Mathf.Approximately(_from.x, _to.x) || !Mathf.Approximately(_from.z, _to.z))
            {
                _fromPrev = _from;
                _from = Vector3.Lerp(_fromPrev, _to, _speed);
                m_rootRotateAngle = _assist * Vector3.Angle(_from, _fromPrev);
                m_rotating = true;
                yield return null;
            }
            m_rotating = false;
        }
    }
    #endregion

    #region follow track with lookat logic
    [System.Serializable]
    public class CTraceWithLookat : IDefine
    {
        protected Transform m_followT;
        protected Transform m_targetT;
        protected Transform m_lookAtT;
        protected Transform m_dockT;
        protected CLerp m_lerp;
        protected CTarget m_target;

        [Header("过渡时间")]
        public float m_transition_time = 2;
        [Header("角度：相机fov")]
        public float m_fov = 65;

        [Header("横面：夹角比例 怪-相机-中线 α值")]
        [Range(0, 0.5f)]
        public float m_angleRatio_horizontal_M1C1O1 = 0.25f;
        [Header("横面：夹角比例 玩家-相机-中线 β值")]
        [Range(0, 0.5f)]
        public float m_angleRatio_horizontal_P1C1O1 = 0.25f;
        [Header("纵面：夹角比例 怪-相机-中线 γ值")]
        [Range(0, 0.5f)]
        public float m_angleRatio_vertical_M2CO = 0.25f;
        [Header("纵面：夹角比例 玩家-相机-中线 δ值")]
        [Range(0, 0.5f)]
        public float m_angleRatio_vertical_P2CO = 0.25f;
        [Header("纵面：夹角范围")]
        public Vector2 m_angle_CP2G_clamp = new Vector2(0, 30f);

        [Header("曲线：玩家-相机")]
        public AnimationCurve m_line_PC_SCurve = AnimationCurve.Linear(0, 3, 100, 3);
        [Header("当前：玩家-相机")]
        public float m_line_PC_S = 4;

        public float m_line_PC_S_Evaluate { protected get; set; }

        // 角度M1C1P1 最佳
        protected float m_angle_M1C1P1_Max;
        // 角度M1C1P1 当前
        protected float m_angle_M1C1P1_Cur;
        // 角度M1C1P1 最大
        protected float m_angle_M2CP2_Max;
        // 角度M2CP2 当前
        protected float m_angle_M2CP2_Cur;
        // 夹角M1C1O1与P1C1O1比例
        protected float m_angleRatio_M1C1O1_P1C1O1;
        // 夹角M2CO与P2CO比例
        protected float m_angleRatio_M2CO_P2CO;

        protected float m_line_O1E;
        protected float m_line_O1F;
        protected float m_line_O1C1;
        protected float m_line_O1P1;
        protected float m_line_C1P1;
        protected float m_line_P2C;
        protected float m_line_M2P2;
        protected float m_angle_M1C1O1;
        protected float m_angle_P1C1O1;
        protected float m_angle_C1O1P1;
        protected float m_angle_C1M1P1;
        protected float m_angle_M2CO;
        protected float m_angle_P2CO;
        protected float m_angle_CM2P2;
        protected float m_angle_CP2G;

        protected Vector3 m_point_O;
        protected Vector3 m_point_C;
        protected Vector3 m_point_P2;
        protected Vector3 m_point_M2;
        protected Vector3 m_point_Temp;
        protected Vector3 m_normalized_O1C1;

        // 标准角度中
        protected bool m_angle_standard = false;
        protected bool m_angle_standard_onTheLeft = false;
        private IEnumerator m_ienumerator_standard;

        // 拉伸中
        protected bool m_stretching;
        protected bool m_stretching_in;
        protected bool m_stretching_out;
        protected float m_stretchInSpeed;
        protected float m_stretchOutSpeed;
        protected float m_stretchOutDuration;
        private IEnumerator m_ienumerator_stretch;

        public virtual void Awake()
        {
            m_followT = Instance.FollowT;
            m_targetT = Instance.TargetT;
            m_lookAtT = Instance.LookAtT;
            m_dockT = Instance.FDockT;
            m_lerp = Instance.Lerp;
            m_target = Instance.Target;
            m_angle_standard = false;
            m_angle_standard_onTheLeft = false;

            m_angleRatio_M2CO_P2CO = m_angleRatio_vertical_M2CO / (m_angleRatio_vertical_M2CO + m_angleRatio_vertical_P2CO);
            m_angle_M2CP2_Max = m_fov * (m_angleRatio_vertical_M2CO + m_angleRatio_vertical_P2CO);

            m_angleRatio_M1C1O1_P1C1O1 = m_angleRatio_horizontal_M1C1O1 / (m_angleRatio_horizontal_M1C1O1 + m_angleRatio_horizontal_P1C1O1);
            m_angle_M1C1P1_Max = m_fov * Screen.width / Screen.height * (m_angleRatio_horizontal_M1C1O1 + m_angleRatio_horizontal_P1C1O1);

            m_line_PC_S = m_line_PC_SCurve.Evaluate(0);
            m_angle_CP2G = m_angle_CP2G_clamp.y;
        }
        public virtual void Enter()
        {
            m_lerp.SetLerpTime(m_transition_time);
            m_line_PC_S = m_line_PC_SCurve.Evaluate(m_line_PC_S_Evaluate);
        }
        public virtual void Exit()
        {
            if (null != m_ienumerator_standard)
            {
                Instance.StopCoroutine(m_ienumerator_standard);
                m_ienumerator_standard = null;
            }
            m_stretching = false;
            m_stretching_in = false;
            m_stretching_out = false;
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }
        }
        public virtual void LateUpdate()
        {
            if (CalcCheck())
            {
                m_lerp.CalcTrackSpeed();
                ShowPoint();
                CalcAngle();
                CalcLineS(m_lerp.m_speed_track.m_speed_cur);
                CalcLookatPos(m_lerp.m_speed_track.m_speed_cur);
                CalcCamPos(m_lerp.m_speed_track.m_speed_cur);
                CalcHeight(m_lerp.m_speed_track.m_speed_cur);
                CalcCamFov(m_lerp.m_speed_track.m_speed_cur);
            }
        }
        public virtual void EdgeOfViewport(bool _onTheLeft, int _frameCount)
        {
            if (null != m_ienumerator_standard)
            {
                Instance.StopCoroutine(m_ienumerator_standard);
                m_ienumerator_standard = null;
            }
            if (_frameCount > 0)
            {
                bool t1 = m_angle_standard;
                bool t2 = m_angle_standard_onTheLeft;
                m_ienumerator_standard = Instance.FrameWait(_frameCount, () =>
                {
                    m_angle_standard = t1;
                    m_angle_standard_onTheLeft = t2;
                });
                Instance.StartCoroutine(m_ienumerator_standard);
            }
            m_angle_standard = true;
            m_angle_standard_onTheLeft = _onTheLeft;
            m_lerp.SetLerp(false);
        }
        public virtual void Stretch(float _ratio, float _absolute, float _durationIn, float _durationKeep, float _durationOut, Action _cb = null)
        {
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }

            m_stretching = true;
            m_stretchOutDuration = _durationOut;
            StretchIn(_ratio, _absolute, _durationIn, () =>
            {
                m_ienumerator_stretch = Instance.TimeWait(_durationKeep, () =>
                {
                    StretchOut(_durationOut, () => { m_stretching = false; _cb?.Invoke(); });
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            });
        }
        public virtual void StretchIn(float _ratio, float _absolute, float _duration, Action _cb = null)
        {
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }

            m_stretching = true;
            m_stretching_out = false;
            var _dis = m_line_PC_S * _ratio + _absolute;
            if (_duration <= 0)
            {
                m_line_PC_S = _dis;
                m_ienumerator_stretch = Instance.FrameWait(1, () =>
                {
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
            else
            {
                m_stretching_in = true;
                m_stretchInSpeed = (_dis - m_line_PC_SCurve.Evaluate(m_line_PC_S_Evaluate)) / _duration;
                m_ienumerator_stretch = Instance.TimeWait(_duration, () =>
                {
                    m_stretching_in = false;
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
        }
        public virtual void StretchOut(float? _duration = null, Action _cb = null)
        {
            if (null != m_ienumerator_stretch)
            {
                Instance.StopCoroutine(m_ienumerator_stretch);
                m_ienumerator_stretch = null;
            }
            if (null == _duration)
            {
                _duration = m_stretchOutDuration;
            }

            m_stretching = true;
            m_stretching_in = false;
            var _dis = m_line_PC_SCurve.Evaluate(m_line_PC_S_Evaluate);
            if (_duration.Value <= 0)
            {
                m_line_PC_S = _dis;
                m_ienumerator_stretch = Instance.FrameWait(1, () =>
                {
                    m_stretching = false;
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
            else
            {
                m_stretching_out = true;
                m_stretchOutSpeed = (m_line_PC_S - _dis) / _duration.Value;
                m_ienumerator_stretch = Instance.TimeWait(_duration.Value, () =>
                {
                    m_stretching = false;
                    m_stretching_out = false;
                    _cb?.Invoke();
                });
                Instance.StartCoroutine(m_ienumerator_stretch);
            }
        }
        protected virtual bool CalcCheck()
        {
            if (m_target.VerifyNoFollowTgt() || m_target.VerifyNoLookatTgt() || (m_target.m_pointP == m_target.m_pointM && m_target.m_pointP_Height == m_target.m_pointM_Height))
            {
                return false;
            }

            return m_target.m_pointM != m_target.m_pointP;
        }
        protected virtual void ShowPoint()
        {
            m_point_Temp = m_target.m_pointP;
            m_point_Temp.y = m_target.m_pointP_Height;
            m_followT.position = m_point_Temp;

            m_point_Temp = m_target.m_pointM;
            m_point_Temp.y = m_target.m_pointM_Height;
            m_targetT.position = m_point_Temp;
        }
        protected virtual void CalcAngle()
        {
#if UNITY_EDITOR
            m_angleRatio_M1C1O1_P1C1O1 = m_angleRatio_horizontal_M1C1O1 / (m_angleRatio_horizontal_M1C1O1 + m_angleRatio_horizontal_P1C1O1);
            m_angle_M1C1P1_Max = m_fov * Screen.width / Screen.height * (m_angleRatio_horizontal_M1C1O1 + m_angleRatio_horizontal_P1C1O1);
#endif
            if (m_angle_standard)
            {
                m_angle_M1C1P1_Cur = m_angle_M1C1P1_Max;
            }
            else
            {
                m_angle_M1C1P1_Cur = m_target.m_angle_MCP_Cur;
                m_angle_M1C1P1_Cur = m_angle_M1C1P1_Cur > m_angle_M1C1P1_Max ? m_angle_M1C1P1_Max : m_angle_M1C1P1_Cur;
            }

            m_angle_M1C1O1 = m_angle_M1C1P1_Cur * m_angleRatio_M1C1O1_P1C1O1;
            m_angle_P1C1O1 = m_angle_M1C1P1_Cur * (1 - m_angleRatio_M1C1O1_P1C1O1);
        }
        protected virtual void CalcLineS(float speed)
        {
            if (m_stretching)
            {
                if (m_stretching_in)
                {
                    m_line_PC_S += (Time.deltaTime * m_stretchInSpeed);
                }
                else if (m_stretching_out)
                {
                    m_line_PC_S -= (Time.deltaTime * m_stretchOutSpeed);
                    if (Mathf.Approximately(m_line_PC_S, m_line_PC_SCurve.Evaluate(m_line_PC_S_Evaluate)))
                    {
                        m_stretching_in = false;
                        m_stretching_out = false;
                    }
                }
            }
            else
            {
                m_line_PC_S = Mathf.Lerp(m_line_PC_S, m_line_PC_SCurve.Evaluate(m_line_PC_S_Evaluate), speed);
            }
            m_line_C1P1 = m_line_PC_S / Mathf.Sqrt(Mathf.Pow(MathfTan(m_angle_CP2G) * MathfCos(m_angle_P1C1O1), 2) + 1);
        }
        protected virtual void CalcLookatPos(float speed)
        {
            m_angle_C1M1P1 = MathfAsin(Mathf.Min(1, m_line_C1P1 / m_target.m_line_MP_L * MathfSin(m_angle_M1C1O1 + m_angle_P1C1O1))) * Mathf.Rad2Deg;  // 公式：∠CMP=min(1,(s/L)*sin(α+β))
            m_angle_C1O1P1 = Mathf.Min(90, m_angle_C1M1P1 + m_angle_M1C1O1);
            if (m_angle_M1C1O1 != 0 && m_angle_P1C1O1 != 0 && m_angle_C1O1P1 != 0 && m_angle_C1M1P1 != 0)
            {
                m_line_O1P1 = m_line_C1P1 * MathfSin(m_angle_P1C1O1) / MathfSin(m_angle_C1O1P1);  // 公式： OP=EP/sin∠COP=（PC*sin∠PCO）/sin∠COP
            }
            else
            {
                m_line_O1P1 = m_line_C1P1 * m_target.m_line_MP_L * m_angleRatio_horizontal_P1C1O1 / ((m_angleRatio_horizontal_P1C1O1 + m_angleRatio_horizontal_M1C1O1) * m_line_C1P1 + m_angleRatio_horizontal_M1C1O1 * m_target.m_line_MP_L);   // 公式：OP=s*L*B/[A*L+(A+B)*s]
            }
            m_point_O = m_target.m_pointP + -m_target.m_normalized_MP * m_line_O1P1;
        }
        protected virtual void CalcCamPos(float speed)
        {
            m_line_O1E = m_line_O1P1 * MathfCos(m_angle_C1O1P1);
            m_line_O1F = (m_target.m_line_MP_L - m_line_O1P1) / m_line_O1P1 * m_line_O1E;
            if (m_angle_M1C1O1 != 0 && m_angle_P1C1O1 != 0 && m_angle_C1O1P1 != 0 && m_angle_C1M1P1 != 0)
            {
                m_line_O1C1 = m_line_C1P1 * MathfCos(m_angle_P1C1O1) + m_line_O1E;  // 公式：OC=EC+OE=EC+OP*cos∠COP=s*cosβ+OP*cos∠COP
            }
            else
            {
                m_line_O1C1 = m_line_C1P1 + m_line_O1P1;  // 公式：OC=s+OP
            }
            m_normalized_O1C1 = Quaternion.AngleAxis(CalcIsItRight() ? m_angle_C1O1P1 : -m_angle_C1O1P1, Vector3.up) * m_target.m_normalized_MP; // 判断左侧还是右侧
            m_point_C = m_point_O + m_normalized_O1C1 * m_line_O1C1;
        }
        protected virtual void CalcHeight(float speed)
        {
#if UNITY_EDITOR
            m_angleRatio_M2CO_P2CO = m_angleRatio_vertical_M2CO / (m_angleRatio_vertical_M2CO + m_angleRatio_vertical_P2CO);
            m_angle_M2CP2_Max = m_fov * (m_angleRatio_vertical_M2CO + m_angleRatio_vertical_P2CO);
#endif
            m_point_M2 = m_point_O + -m_normalized_O1C1 * m_line_O1F;
            m_point_M2.y = m_target.m_pointM_Height;
            m_point_P2 = m_point_O + m_normalized_O1C1 * m_line_O1E;
            m_point_P2.y = m_target.m_pointP_Height;

            m_line_P2C = m_line_PC_S / Mathf.Sqrt(Mathf.Pow(MathfTan(m_angle_P1C1O1) * MathfCos(m_angle_CP2G), 2) + 1);
            if (m_point_M2 == m_point_P2)
            {
                m_point_O = m_point_M2;
                m_angle_CP2G = m_angle_M2CP2_Max;
            }
            else
            {
                m_angle_M2CP2_Cur = m_angle_M2CP2_Max; //Mathf.Clamp(Vector3.Angle(m_point_M2, m_point_P2), 0, m_angle_M2CP2_Max);
                m_angle_M2CO = m_angle_M2CP2_Cur * m_angleRatio_M2CO_P2CO;
                m_angle_P2CO = m_angle_M2CP2_Cur * (1 - m_angleRatio_M2CO_P2CO);

                m_line_M2P2 = Vector3.Distance(m_point_M2, m_point_P2);
                m_angle_CM2P2 = MathfAsin(Mathf.Min(1, m_line_P2C / m_line_M2P2 * MathfSin(m_angle_M2CP2_Cur))) * Mathf.Rad2Deg;   // 根据正弦定理：MP/sin∠MCP=CP/sin∠CMP，即L/sin∠MCP=s/sin∠CMP

                m_point_O = m_point_P2 + (m_point_M2 - m_point_P2).normalized * (m_line_P2C * MathfSin(m_angle_P2CO) / MathfSin(m_angle_CM2P2 + m_angle_M2CO));  // P2O = P2C*sin(∠P2CO)/sin(∠COP2)
                m_angle_CP2G = Mathf.Clamp(m_angle_M2CP2_Cur + m_angle_CM2P2 - MathfAsin((m_target.m_pointM_Height - m_target.m_pointP_Height) / m_line_M2P2) * Mathf.Rad2Deg, m_angle_CP2G_clamp.x, m_angle_CP2G_clamp.y);
            }

            m_lookAtT.position = Vector3.Lerp(m_lookAtT.position, m_point_O, speed);
            m_point_C.y = m_line_P2C * MathfSin(m_angle_CP2G) + m_target.m_pointP_Height;
            m_dockT.position = Vector3.Lerp(m_dockT.position, m_point_C, speed);
            m_dockT.LookAt(m_lookAtT.position);
        }
        protected virtual void CalcCamFov(float speed)
        {
            if (Instance.IsCloseuping || Instance.IsPauseFOV)
            {
                return;
            }
            Instance.MainCamera.fieldOfView = Mathf.Lerp(Instance.MainCamera.fieldOfView, m_fov, speed);
        }
        protected virtual bool CalcIsItRight()
        {
            if (m_angle_standard)
            {
                return !m_angle_standard_onTheLeft;
            }
            else
            {
                return Vector3.Cross(m_target.m_normalized_CM, m_target.m_normalized_CP).y >= 0;
            }
        }
    }
    #endregion

    #region follow track with lookat and closeup logic
    [System.Serializable]
    public class CTraceWithLookat2Closeup : CTraceWithLookat
    {
        [Header("主控固定在左侧")]
        public bool m_fixed_side_onTheLeft = true;

        public override void Awake()
        {
            base.Awake();
            m_angle_standard = true;
            m_angle_standard_onTheLeft = m_fixed_side_onTheLeft;
        }

        public override void EdgeOfViewport(bool _onTheLeft, int _frameCount)
        {
        }

        protected override bool CalcIsItRight()
        {
            return !m_fixed_side_onTheLeft;
        }
    }
    #endregion

    #region camera closeup anim logic
    [Serializable]
    public class CCloseup : IDefine
    {
        public const string CONST_AnimName_FixedCamera = "Custom_FixedCamera";

        private CTarget m_target;
        private CPostProcessing m_postP;

        [Header("进入 跟随速率")]
        public CSpeed m_speed_enter;
        [Header("退出 跟随速率")]
        public CSpeed m_speed_exit;

        private Transform m_fDock;
        private Transform m_cDock;
        private Transform m_camRoot;
        private Transform m_closeupT;
        private Transform m_closeupOffsetT;

        private CamAnim m_freeCam = new CamAnim();
        private CamAnim m_targetCam = new CamAnim();
        private CamAnim m_curCam;

        private bool m_closeupFollow;
        private string m_curStateName;
        private string m_curPostProcessingStateName;

        private Action m_curStateOnFinished;
        private EPlayType m_curStatePlayType;
        private IEnumerator m_shutoff_IEnumerator;
        private IEnumerator m_duration_IEnumerator;

        public void Awake()
        {
            m_target = Instance.Target;
            m_postP = Instance.PostProcessing;
            m_fDock = Instance.FDockT;
            m_cDock = Instance.CDockT;
            m_camRoot = Instance.CamRootT;
            m_closeupT = Instance.RootT.Find("Sandbox");
            m_closeupOffsetT = m_closeupT.Find("Offset");
            m_freeCam.FreeMode(m_closeupOffsetT.Find("CamFreeAnim"));
            m_targetCam.TargetMode(m_closeupOffsetT.Find("CamTargetAnim"));

            m_speed_enter.Awake();
            m_speed_exit.Awake();
        }
        public void Enter()
        {
        }
        public void Exit()
        {
            if (null != m_shutoff_IEnumerator)
            {
                Instance.StopCoroutine(m_shutoff_IEnumerator);
                m_shutoff_IEnumerator = null;
            }
            if (null != m_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_duration_IEnumerator);
                m_duration_IEnumerator = null;
            }
            m_camRoot.parent = m_fDock;
            m_camRoot.localPosition = Vector3.zero;
            m_camRoot.localRotation = Quaternion.identity;
            m_speed_enter.Exit();
            m_speed_exit.Exit();
            m_curStateOnFinished = null;
        }
        public void LateUpdate()
        {
            if (!Instance.IsCloseuping || null == m_curCam)
            {
                return;
            }
            AnimatorStateInfo state = m_curCam.m_animA.GetCurrentAnimatorStateInfo(0);
            if (!state.IsName(m_curStateName))
            {
                return;
            }
            if (m_curStateName != CONST_AnimName_FixedCamera && state.normalizedTime >= 1f)
            {
                Stop();
                return;
            }
            m_curCam.LateUpdate();
            Follow();
        }
        private void Play(string _stateName, EPlayType _playType, Action _onFinished = null)
        {
            if (null != m_shutoff_IEnumerator)
            {
                Instance.StopCoroutine(m_shutoff_IEnumerator);
                m_shutoff_IEnumerator = null;
            }
            if (null != m_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_duration_IEnumerator);
                m_duration_IEnumerator = null;
            }

            m_curStateName = _stateName;
            m_curStatePlayType = _playType;
            m_curStateOnFinished = _onFinished;
            m_curCam.PlayAnimation(m_curStateName);

            m_speed_enter.SetLerp(m_curStatePlayType == EPlayType.BlendStart2BlendEnd || m_curStatePlayType == EPlayType.BlendStart2BlinkEnd || m_curStatePlayType == EPlayType.BlendStart2NoEnd);
            m_camRoot.parent = m_cDock;
            Instance.IsCloseuping = true;
        }

        public void Play(Vector3 _posCam, Vector3 _eulerAngleCam, float _camFov, EPlayType _playType, float _duration)
        {
            if (_duration <= 0)
            {
                return;
            }

            m_curCam = m_freeCam;
            m_curCam.m_animT.gameObject.SetActive(false);
            m_curCam.m_animT.position = _posCam;
            m_curCam.m_animT.eulerAngles = _eulerAngleCam;
            m_curCam.m_animC.fieldOfView = _camFov;
            m_curCam.m_animT.gameObject.SetActive(true);
            Play(CONST_AnimName_FixedCamera, _playType, null);

            m_duration_IEnumerator = Instance.TimeWait(_duration, () =>
            {
                Stop(CONST_AnimName_FixedCamera);
            });
            Instance.StartCoroutine(m_duration_IEnumerator);
        }
        public void Play(string _stateName, Vector3? _posCam, Vector3? _eulerAngleCam, Vector3 _posOffset, Vector3 _rotOffset, EPlayType _playType, Action _onFinished = null)
        {
            // stateName和animName一致，和策划约定！！！
            var _cam = m_freeCam.m_animClips.Contains(_stateName) ? m_freeCam : (m_targetCam.m_animClips.Contains(_stateName) ? m_targetCam : null);
            if (null == _cam)
            {
                _onFinished?.Invoke();
                //PapeGames.X3.X3Debug.Log("[CameraTrace][特写镜头：无此动画 " + _stateName + "]");
                return;
            }

            if (null == _posCam || null == _eulerAngleCam)
            {
                m_closeupFollow = true;
            }
            else
            {
                m_closeupFollow = false;
                m_closeupT.position = _posCam.Value;
                m_closeupT.eulerAngles = _eulerAngleCam.Value;
            }

            m_curCam = _cam;
            m_closeupOffsetT.localPosition = _posOffset;
            m_closeupOffsetT.localEulerAngles = _rotOffset;
            Play(_stateName, _playType, _onFinished);
        }
        public void Play(string _stateName, Vector3 _posOffset, Vector3 _rotOffset, EPlayType _playType, Action _onFinished = null)
        {
            // Play(_stateName, null, null, _posOffset, _rotOffset, _playType, _onFinished);
            Play(_stateName, m_target.GetFollowRootPosition(), m_target.GetFollowRootEulerAngles(), _posOffset, _rotOffset, _playType, _onFinished);
        }
        public void PlayPostProcessing(string _animStateName, float _duration)
        {
            if (string.IsNullOrEmpty(_animStateName) || !Instance.IsCloseuping)
            {
                return;
            }
            m_curPostProcessingStateName = _animStateName;
            m_postP.Play(_animStateName, _duration);
        }
        public void Stop()
        {
            if (!Instance.IsCloseuping)
            {
                return;
            }
            if (m_curStatePlayType == EPlayType.BlinkStart2NoEnd || m_curStatePlayType == EPlayType.BlendStart2NoEnd)
            {
                m_curStateOnFinished?.Invoke();
            }
            else
            {
                m_camRoot.parent = m_fDock;
                if (m_curStatePlayType == EPlayType.BlendStart2BlendEnd || m_curStatePlayType == EPlayType.BlinkStart2BlendEnd)
                {
                    m_speed_exit.SetLerp(true);
                    m_shutoff_IEnumerator = ShutOff();
                    Instance.StartCoroutine(m_shutoff_IEnumerator);
                }
                else
                {
                    m_speed_exit.SetLerp(false);
                    m_camRoot.localPosition = Vector3.zero;
                    m_camRoot.localRotation = Quaternion.identity;
                }

                m_curStateName = null;
                m_curCam.StopAnimation();
                m_postP.Stop(m_curPostProcessingStateName);
                m_curStateOnFinished?.Invoke();
            }
            m_curStateOnFinished = null;
            Instance.IsCloseuping = false;

#if UNITY_EDITOR
            Debug.Log("[CameraTrace][结束特写镜头][当前帧：" + Time.frameCount + "][播放模式：" + m_curStatePlayType + "]");
#endif

        }
        public void Stop(EPlayType _playType)
        {
            m_curStatePlayType = _playType;
            Stop();
        }
        public void Stop(string _stateName)
        {
            if (_stateName != m_curStateName)
            {
                return;
            }
            Stop();
        }
        public void Stop(string _stateName, EPlayType _playType)
        {
            if (_stateName != m_curStateName)
            {
                return;
            }
            Stop(_playType);
        }
        private void Follow()
        {
            if (m_closeupFollow)
            {
                // TODO，此处获取的Y值为0！！
                m_closeupT.position = m_target.GetFollowRootPosition();
                m_closeupT.eulerAngles = m_target.GetFollowRootEulerAngles();
                // Debug.Log(m_target.GetFollowRootPosition().ToString() + ":" + m_target.GetFollowRootForward().ToString());
            }

            m_speed_enter.CalcSpeed();

            // transform
            m_camRoot.position = Vector3.Lerp(m_camRoot.position, m_curCam.m_animT.position, m_speed_enter.m_speed_cur);
            m_camRoot.rotation = Quaternion.Lerp(m_camRoot.rotation, m_curCam.m_animT.rotation, m_speed_enter.m_speed_cur);
            // camfov
            Instance.MainCamera.fieldOfView = Mathf.Lerp(Instance.MainCamera.fieldOfView, m_curCam.m_animC.fieldOfView, m_speed_enter.m_speed_cur);
        }
        private IEnumerator ShutOff()
        {
            Vector3 pos = m_camRoot.localPosition;
            Vector3 rot = m_camRoot.localRotation.eulerAngles;
            // Mathf.Approximately(pos.x,0)
            while (Mathf.Abs(pos.x) > 0.001f || Mathf.Abs(pos.y) > 0.001f || Mathf.Abs(pos.z) > 0.001f || Mathf.Abs(rot.x) > 0.001f || Mathf.Abs(rot.y) > 0.001f || Mathf.Abs(rot.z) > 0.001f)
            {
                m_speed_exit.CalcSpeed();
                m_camRoot.localPosition = Vector3.Lerp(m_camRoot.localPosition, Vector3.zero, m_speed_exit.m_speed_cur);
                m_camRoot.localRotation = Quaternion.Lerp(m_camRoot.localRotation, Quaternion.identity, m_speed_exit.m_speed_cur);
                pos = m_camRoot.localPosition;
                rot = m_camRoot.localRotation.eulerAngles;
                yield return null;
            }
        }

        public class CamAnim
        {
            public Transform m_animT { get; private set; }
            public Animator m_animA { get; private set; }
            public Camera m_animC { get; private set; }
            public List<string> m_animClips { get; private set; }

            private Transform m_camTargetT = null;

            public void FreeMode(Transform _root)
            {
                if (null == _root)
                {
                    return;
                }
                m_animT = _root;
                m_animT.gameObject.SetActive(true);
                m_animA = Instance.AddMissingComponent<Animator>(_root);
                m_animC = Instance.AddMissingComponent<Camera>(_root);
                m_animC.enabled = false;
                m_animA.enabled = false;
                AnimClips();
            }
            public void TargetMode(Transform _root)
            {
                if (null == _root)
                {
                    return;
                }
                m_animA = Instance.AddMissingComponent<Animator>(_root);
                m_animT = _root.Find("Camera001");
                m_animT.gameObject.SetActive(true);
                m_animC = Instance.AddMissingComponent<Camera>(m_animT);
                m_animC.enabled = false;
                m_animA.enabled = false;
                m_camTargetT = _root.Find("Camera001.Target");
                AnimClips();
            }
            public void PlayAnimation(string _name)
            {
                m_animA.enabled = true;
                m_animA.Play(_name, 0, 0);
            }
            public void StopAnimation()
            {
                m_animA.enabled = false;
            }
            public void LateUpdate()
            {
                // if (null == m_camTargetT)
                // {
                //     return;
                // }
                // m_animT.LookAt(m_camTargetT);
            }
            private void AnimClips()
            {
                if (null == m_animClips)
                {
                    m_animClips = new List<string>();
                }
                m_animClips.Clear();
                if (null != m_animA && null != m_animA.runtimeAnimatorController)
                {
                    foreach (var _v in m_animA.runtimeAnimatorController.animationClips)
                    {
                        if (m_animClips.Contains(_v.name))
                        {
                            //PapeGames.X3.X3Debug.Log("[CameraTrace][镜头特写： 有相同的动画命名 " + _v.name + "]");
                            continue;
                        }
                        m_animClips.Add(_v.name);
                    }
                }
            }
        }
    }
    #endregion

    #region camera postProcessing logic
    // [System.Serializable]
    public class CPostProcessing : IDefine
    {
        public const string CONST_Dynamic_AnimClipKey = "FxPP_dynamic_placeholder";

        private Animator m_cameraAnimator;
        private AnimatorOverrideController m_cameraOverideAnimCtrl;
        //private PapeGameAdditionalCameraData m_cameraAdditional;

        private IEnumerator m_wait_IEnumerator;
        private string m_curStateName;

        public void Awake()
        {
        }
        public void Enter()
        {
            //m_cameraAdditional = Instance.Camera.Additional;
            m_cameraAnimator = Instance.Camera.CamA;
        }
        public void Exit()
        {
            Stop(m_curStateName);
            if (null != m_cameraOverideAnimCtrl)
            {
                Destroy(m_cameraOverideAnimCtrl);
                m_cameraOverideAnimCtrl = null;
            }
        }
        public void LateUpdate()
        {
        }
        public void Play(AnimationClip _clip)
        {
            if (null == _clip)
            {
                return;
            }
            if (null == m_cameraOverideAnimCtrl)
            {
                m_cameraOverideAnimCtrl = new AnimatorOverrideController(m_cameraAnimator.runtimeAnimatorController);
                m_cameraAnimator.runtimeAnimatorController = m_cameraOverideAnimCtrl;
            }
            m_cameraOverideAnimCtrl[CONST_Dynamic_AnimClipKey] = _clip;
            PlayAnimation(CONST_Dynamic_AnimClipKey);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="_inAnimStateName"></param>
        /// <param name="_duration, If this value is equal or lesser than 0, it is set at the last frame."></param>
        /// <param name="_outAnimStateName"></param>
        public void Play(string _inAnimStateName, float _duration, string _outAnimStateName = null)
        {
            if (null == m_cameraAnimator)
            {
                //PapeGames.X3.X3Debug.Log("[CameraTrace][后处理!! 无此动画组件：" + "Animator]");
                return;
            }

            if (string.IsNullOrEmpty(_inAnimStateName))
            {
                return;
            }

            if (null != m_wait_IEnumerator)
            {
                Instance.StopCoroutine(m_wait_IEnumerator);
                m_wait_IEnumerator = null;
            }
            if (m_curStateName != _inAnimStateName)
            {
                Stop(m_curStateName);
            }

            m_curStateName = _inAnimStateName;
            PlayAnimation(_inAnimStateName);

            if (_duration > 0)
            {
                m_wait_IEnumerator = Instance.TimeWait(_duration, _outAnimStateName, PlayOut);
                Instance.StartCoroutine(m_wait_IEnumerator);
            }
        }
        private void PlayOut(string _outAnimStateName)
        {
            if (string.IsNullOrEmpty(_outAnimStateName) || _outAnimStateName.ToLower() == "null")
            {
                Stop(m_curStateName);
            }
            else
            {
                PlayAnimation(_outAnimStateName);
            }
        }
        public void Stop(string _animStateName)
        {
            if (string.IsNullOrEmpty(_animStateName) || m_curStateName != _animStateName)
            {
                return;
            }
            if (null != m_wait_IEnumerator)
            {
                Instance.StopCoroutine(m_wait_IEnumerator);
                m_wait_IEnumerator = null;
            }

            m_curStateName = null;
            // 停止动画
            StopAnimation();
            //// 径向模糊
            //m_cameraAdditional.RadialBlur = false;
            //// 灰度
            //m_cameraAdditional.Style = false;
            //// 暗角
            //m_cameraAdditional.Vignette = false;
            //// 景深
            //m_cameraAdditional.DOFEnable = false;
        }
        private void PlayAnimation(string _name)
        {
            m_cameraAnimator.enabled = true;
            m_cameraAnimator.Play(_name, 0, 0);
        }
        private void StopAnimation()
        {
            m_cameraAnimator.enabled = false;
        }
    }
    #endregion

    #region camera effect logic
    public enum ECamEffectType
    {
        None = 0,
        Normal = 1,
        Adaptation = 2,
        ScreenShotRT = 3,
        AdaptationEachFrame = 4,
    }
    // [System.Serializable]
    //public class CCamEffect : IDefine
    //{
    //    public Dictionary<string, Effect> m_camEffects = new Dictionary<string, Effect>();

    //    public void Awake()
    //    {
    //    }
    //    public void Enter()
    //    {
    //    }
    //    public void Exit()
    //    {
    //        if (m_camEffects.Count <= 0)
    //        {
    //            return;
    //        }
    //        List<Effect> _values = new List<Effect>(m_camEffects.Values);
    //        foreach (var _v in _values)
    //        {
    //            _v.Reset();
    //        }
    //        m_camEffects.Clear();
    //    }
    //    public void LateUpdate()
    //    {
    //    }
    //    public void Play(string _name, float _duration, ECamEffectType _type = ECamEffectType.None, Action _complete = null)
    //    {
    //        if (string.IsNullOrEmpty(_name) || _duration <= 0)
    //        {
    //            _complete?.Invoke();
    //            return;
    //        }

    //        bool _add = false;
    //        Effect _effect;
    //        if (!m_camEffects.TryGetValue(_name, out _effect))
    //        {
    //            _add = true;
    //            _effect = Effect.Get();
    //        }
    //        if (_effect.Play(_name, _duration, _type, _complete, Stop) && _add)
    //        {
    //            m_camEffects.Add(_name, _effect);
    //        }
    //        else
    //        {
    //            _complete?.Invoke();
    //        }
    //    }
    //    public void Stop(string _name)
    //    {
    //        if (string.IsNullOrEmpty(_name))
    //        {
    //            return;
    //        }
    //        Effect _effect;
    //        if (!m_camEffects.TryGetValue(_name, out _effect))
    //        {
    //            return;
    //        }
    //        _effect.Stop();
    //        m_camEffects.Remove(_name);
    //        Effect.Back(_effect);
    //    }
    //    public class Effect
    //    {
    //        private IEnumerator m_wait_IEnumerator;
    //        private IEnumerator m_adaptation_IEnumerator;
    //        private GameObject m_effectObj;
    //        private Vector3 m_scaleTemp = Vector3.one;
    //        private RenderTexture m_screenRT;
    //        private Action m_onStop;

    //        public bool Play(string _name, float _duration, ECamEffectType _type, Action _onStop, Action<string> _onComplete)
    //        {
    //            this.Reset();

    //            if (null == m_effectObj)
    //            {
    //                m_effectObj = null; // GameObjectPoolManager.Instance.GetObject(_name, ResType.T_NormalEffect);
    //            }
    //            if (null == m_effectObj)
    //            {
    //                return false;
    //            }
    //            if (m_effectObj.activeSelf)
    //            {
    //                m_effectObj.SetActive(false);
    //            }

    //            m_onStop = _onStop;
    //            m_effectObj.transform.SetParent(Instance.Camera.Root, false);
    //            m_effectObj.transform.localPosition = Vector3.zero;
    //            m_effectObj.transform.localRotation = Quaternion.identity;

    //            if (_type == ECamEffectType.None || _type == ECamEffectType.Normal)
    //            {
    //                m_effectObj.transform.localScale = Vector3.one;
    //            }
    //            if (_type == ECamEffectType.AdaptationEachFrame)
    //            {
    //                m_adaptation_IEnumerator = Adaptation(_duration);
    //                Instance.StartCoroutine(m_adaptation_IEnumerator);
    //            }
    //            if (_type == ECamEffectType.Adaptation || _type == ECamEffectType.ScreenShotRT)
    //            {
    //                Adaptation();
    //            }
    //            if (_type == ECamEffectType.ScreenShotRT)
    //            {
    //                m_screenRT = ScreenShotRT();
    //            }

    //            m_effectObj.SetActive(true);
    //            m_wait_IEnumerator = Instance.TimeWait(_duration, _name, _onComplete);
    //            Instance.StartCoroutine(m_wait_IEnumerator);

    //            return true;
    //        }
    //        public void Stop()
    //        {
    //            m_onStop?.Invoke();
    //            this.Reset();
    //        }
    //        public void Reset()
    //        {
    //            if (null != m_screenRT)
    //            {
    //                PapegameRenderPipeline._Instance.ReleaseNoPPRT();
    //                // m_screenRT.Release();
    //                m_screenRT = null;
    //            }

    //            if (null != m_wait_IEnumerator)
    //            {
    //                Instance.StopCoroutine(m_wait_IEnumerator);
    //            }
    //            m_wait_IEnumerator = null;

    //            if (null != m_adaptation_IEnumerator)
    //            {
    //                Instance.StopCoroutine(m_adaptation_IEnumerator);
    //                m_adaptation_IEnumerator = null;
    //            }

    //            if (null != m_effectObj)
    //            {
    //                GameObjectPoolManager.Instance.Discard(m_effectObj);
    //            }
    //            m_effectObj = null;
    //            m_onStop = null;
    //        }
    //        private void Adaptation()
    //        {
    //            if (null == m_effectObj)
    //            {
    //                return;
    //            }
    //            m_scaleTemp.y = MathfTan(Instance.Target.m_angle_fov_V * 0.5f) / DEFAULT_EFFECT_FOV_V_TAN_VALUE;
    //            m_scaleTemp.x = MathfTan(Instance.Target.m_angle_fov_H * 0.5f) / DEFAULT_EFFECT_FOV_H_TAN_VALUE;
    //            m_effectObj.transform.localScale = m_scaleTemp;
    //        }
    //        private IEnumerator Adaptation(float _time)
    //        {
    //            while (true)
    //            {
    //                Adaptation();
    //                _time -= Time.deltaTime;
    //                if (_time <= 0 || null == m_effectObj)
    //                {
    //                    yield break;
    //                }
    //                yield return null;
    //            }
    //        }

    //        private static Stack<Effect> m_idles = new Stack<Effect>();
    //        private static Dictionary<string, Material> m_screenShot_rt_material;

    //        public static float DEFAULT_EFFECT_FOV_V;
    //        public static float DEFAULT_EFFECT_FOV_H;
    //        public static float DEFAULT_EFFECT_FOV_V_TAN_VALUE;
    //        public static float DEFAULT_EFFECT_FOV_H_TAN_VALUE;

    //        static Effect()
    //        {
    //            DEFAULT_EFFECT_FOV_V = 60;
    //            DEFAULT_EFFECT_FOV_V_TAN_VALUE = MathfTan(DEFAULT_EFFECT_FOV_V * 0.5f);
    //            DEFAULT_EFFECT_FOV_H = HorizontalFov(DEFAULT_EFFECT_FOV_V, PapeGames.ScreenShotManager.Instance.screenShotWidth / (float)PapeGames.ScreenShotManager.Instance.screenShotHeight);
    //            DEFAULT_EFFECT_FOV_H_TAN_VALUE = MathfTan(DEFAULT_EFFECT_FOV_H * 0.5f);
    //        }
    //        public static RenderTexture ScreenShotRT()
    //        {
    //            if (null == m_screenShot_rt_material)
    //            {
    //                m_screenShot_rt_material = new Dictionary<string, Material>();

    //                string _name = "ScreenShotRT";
    //                GameObject _sShot = PapeGames.X3.Res.LoadGameObject(_name, ResType.T_BasicWidget);
    //                if (null == _sShot)
    //                {
    //                    return null;
    //                }

    //                DontDestroyOnLoad(_sShot);
    //                _sShot.name = _name;
    //                _sShot.transform.SetParent(Instance.RootT);
    //                _sShot.SetActive(false);

    //                Renderer[] _rds = _sShot.GetComponentsInChildren<Renderer>(true);
    //                foreach (var _v in _rds)
    //                {
    //                    if (m_screenShot_rt_material.ContainsKey(_v.name))
    //                    {
    //                        continue;
    //                    }
    //                    m_screenShot_rt_material.Add(_v.name, _v.sharedMaterial);
    //                }
    //            }

    //            Instance.Camera.Additional.isBeforePostProcessRT = true;
    //            RenderTexture _rt = PapegameRenderPipeline._Instance.CreateNoPPRT(Screen.width, Screen.height);
    //            Instance.MainCamera.Render();
    //            Instance.Camera.Additional.isBeforePostProcessRT = false;

    //            foreach (var _v in m_screenShot_rt_material.Values)
    //            {
    //                _v.SetTexture("_DiffuseMap", _rt);
    //            }

    //            return _rt;
    //        }
    //        public static Effect Get()
    //        {
    //            Effect _effect = null;
    //            if (m_idles.Count > 0)
    //            {
    //                _effect = m_idles.Pop();
    //            }
    //            else
    //            {
    //                _effect = new Effect();
    //            }
    //            return _effect;
    //        }
    //        public static void Back(Effect _effect)
    //        {
    //            if (null == _effect)
    //            {
    //                return;
    //            }
    //            m_idles.Push(_effect);
    //        }
    //    }
    //}
    #endregion

    #region camera fade in and fade out logic
    //[System.Serializable]
    //public class CFade : IDefine
    //{
    //    [Header("淡入曲线")]
    //    public AnimationCurve m_fadeIn = AnimationCurve.Linear(0, 0, 1, 1);
    //    [Header("淡出曲线")]
    //    public AnimationCurve m_fadeOut = AnimationCurve.Linear(0, 1, 1, 0);

    //    private PapeGameAdditionalCameraData m_cameraAdditional;
    //    private IEnumerator m_fade_IEnumerator;
    //    private float m_fadeExposure;
    //    private float m_fadeInDuration;
    //    private float m_fadeStayDuration;
    //    private float m_fadeOutDuration;

    //    public void Awake()
    //    {

    //    }
    //    public void Enter()
    //    {
    //        m_cameraAdditional = Instance.Camera.Additional;
    //        if (null != m_cameraAdditional)
    //        {
    //            m_fadeExposure = m_cameraAdditional.exposure;
    //        }
    //    }
    //    public void Exit()
    //    {
    //        if (null != m_fade_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_fade_IEnumerator);
    //            m_fade_IEnumerator = null;
    //        }
    //        if (null != m_cameraAdditional)
    //        {
    //            m_cameraAdditional.exposure = m_fadeExposure;
    //        }
    //    }
    //    public void LateUpdate()
    //    {

    //    }
    //    public void Play(float _fadeInDuration, float _fadeStayDuration, float _fadeOutDuration)
    //    {
    //        if (null == m_cameraAdditional)
    //        {
    //            PapeGames.X3.X3Debug.Log("[CameraTrace][淡入淡出!! 无此脚本：" + "PapeGameAdditionalCameraData]");
    //            return;
    //        }
    //        if (null != m_fade_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_fade_IEnumerator);
    //            m_fade_IEnumerator = null;
    //        }

    //        m_fadeInDuration = _fadeInDuration;
    //        m_fadeStayDuration = _fadeStayDuration;
    //        m_fadeOutDuration = _fadeOutDuration;
    //        m_fade_IEnumerator = FadeIn();
    //        Instance.StartCoroutine(m_fade_IEnumerator);
    //    }
    //    private IEnumerator FadeIn()
    //    {
    //        if (m_fadeInDuration > 0)
    //        {
    //            float _value = 0;
    //            do
    //            {
    //                _value += Time.deltaTime;
    //                m_cameraAdditional.exposure = m_fadeExposure - m_fadeIn.Evaluate(_value / m_fadeInDuration) * m_fadeExposure;
    //                yield return null;
    //            }
    //            while (_value < m_fadeInDuration);
    //        }
    //        else
    //        {
    //            m_cameraAdditional.exposure = m_fadeExposure - m_fadeIn.Evaluate(1) * m_fadeExposure;
    //        }
    //        m_fade_IEnumerator = Instance.TimeWait(m_fadeStayDuration, () =>
    //        {
    //            m_fade_IEnumerator = FadeOut();
    //            Instance.StartCoroutine(m_fade_IEnumerator);
    //        });
    //        Instance.StartCoroutine(m_fade_IEnumerator);
    //    }
    //    private IEnumerator FadeOut()
    //    {
    //        if (m_fadeOutDuration > 0)
    //        {
    //            float _value = 0;
    //            do
    //            {
    //                _value += Time.deltaTime;
    //                m_cameraAdditional.exposure = m_fadeExposure - m_fadeOut.Evaluate(_value / m_fadeOutDuration) * m_fadeExposure;
    //                yield return null;
    //            }
    //            while (_value < m_fadeOutDuration);
    //        }
    //        else
    //        {
    //            m_cameraAdditional.exposure = m_fadeExposure - m_fadeIn.Evaluate(1) * m_fadeExposure;
    //        }
    //    }
    //}
    #endregion

    #region scene effect logic
    // [System.Serializable]
    //public class CSceneEffect : IDefine
    //{
    //    private Animator m_effectAnim;
    //    private IEnumerator m_effect_IEnumerator;
    //    private string m_curEffectName;

    //    public void Awake()
    //    {

    //    }
    //    public void Enter()
    //    {
    //        if (null == BattleSceneEffect.Instance)
    //        {
    //            return;
    //        }
    //        m_effectAnim = Instance.AddMissingComponent<Animator>(BattleSceneEffect.Instance.gameObject);
    //    }
    //    public void Exit()
    //    {
    //        Stop(m_curEffectName);
    //        m_effectAnim = null;
    //    }
    //    public void LateUpdate()
    //    {

    //    }
    //    public void Play(string _effectName, float _duration)
    //    {
    //        if (null == m_effectAnim)
    //        {
    //            PapeGames.X3.X3Debug.Log("[CameraTrace][场景压暗!! 场景内无此脚本：" + "BattleSceneEffect!!]");
    //            return;
    //        }
    //        if (null != m_effect_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_effect_IEnumerator);
    //            m_effect_IEnumerator = null;
    //        }

    //        if (_duration > 0)
    //        {
    //            m_effect_IEnumerator = Instance.TimeWait(_duration, _effectName, Stop);
    //            Instance.StartCoroutine(m_effect_IEnumerator);
    //        }
    //        m_curEffectName = _effectName;
    //        m_effectAnim.Play(_effectName);
    //    }
    //    public void Stop(string _effectName)
    //    {
    //        if (_effectName != m_curEffectName || null == m_effectAnim)
    //        {
    //            return;
    //        }
    //        if (null != m_effect_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_effect_IEnumerator);
    //            m_effect_IEnumerator = null;
    //        }
    //        _effectName = null;
    //        m_effectAnim.Play("Empty");
    //    }
    //}
    #endregion

    #region camera shake
    //// [System.Serializable]
    //public class CShake : IDefine
    //{
    //    public const string ShakeEventNamePrefix = @"Shake_Mode_";
    //    public const string ShakeCountParameterName = @"BattleCamera_Shake_Count";
    //    public const string ShakeSpeedParameterName = @"BattleCamera_Shake_Speed";
    //    public const string ShakeShutOffActionEvent = @"BattleCamera_ShutOffShakeAction_Event";

    //    private PlayMakerFSM m_shakePMF;
    //    private Animation m_shakeAnim;
    //    private Transform m_shake;
    //    private bool m_isSwitchOffShake = false;

    //    private Dictionary<Int32, string> m_shakeEventNameDict = new Dictionary<Int32, string>(1, new Int32Compare());
    //    private Vector3 m_shakeAmplitude = Vector3.zero;
    //    private Vector3 m_shakePosition;
    //    private IEnumerator m_amplitude_IEnumerator;
    //    private IEnumerator m_switchOff_IEnumerator;

    //    public void Awake()
    //    {
    //        m_shake = Instance.ShakeT;
    //        m_shakePMF = Instance.AddMissingComponent<PlayMakerFSM>(m_shake);
    //        m_shakeAnim = Instance.AddMissingComponent<Animation>(m_shake);
    //    }
    //    public void Enter()
    //    {
    //    }
    //    public void Exit()
    //    {
    //        if (null != m_amplitude_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_amplitude_IEnumerator);
    //            m_amplitude_IEnumerator = null;
    //        }
    //        if (null != m_switchOff_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_switchOff_IEnumerator);
    //            m_switchOff_IEnumerator = null;
    //        }
    //        m_isSwitchOffShake = false;
    //    }
    //    public void LateUpdate()
    //    {
    //        if (m_isSwitchOffShake)
    //        {
    //            return;
    //        }
    //        CalcAmplitude();
    //    }
    //    public void Play(Int32 _shakeMode, Int32 _shakeCount, float _shakeSpeed, Vector3 _shakeAmplitude)
    //    {
    //        if (m_isSwitchOffShake)
    //        {
    //            return;
    //        }

    //        string _shakeEvent;
    //        if (!m_shakeEventNameDict.TryGetValue(_shakeMode, out _shakeEvent))
    //        {
    //            _shakeEvent = ShakeEventNamePrefix + _shakeMode.ToString();
    //            m_shakeEventNameDict.Add(_shakeMode, _shakeEvent);
    //        }
    //        SetFsmParameter(m_shakePMF, ShakeSpeedParameterName, _shakeSpeed);
    //        SetFsmParameter(m_shakePMF, ShakeCountParameterName, _shakeCount);
    //        SendFsmEvent(m_shakePMF, _shakeEvent);
    //    }
    //    public void Play(Int32 _shakeMode, Int32 _shakeCount, float _shakeSpeed, Vector3 _shakeAmplitudeFrom, Vector3 _shakeAmplitudeTo, float _time)
    //    {
    //        if (m_isSwitchOffShake)
    //        {
    //            return;
    //        }

    //        Play(_shakeMode, _shakeCount, _shakeSpeed, _shakeAmplitudeFrom);
    //        if (null != m_amplitude_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_amplitude_IEnumerator);
    //            m_amplitude_IEnumerator = null;
    //        }
    //        if (_time > 0)
    //        {
    //            m_amplitude_IEnumerator = AmplitudeLerp(_shakeAmplitudeFrom, _shakeAmplitudeTo, _time);
    //            Instance.StartCoroutine(m_amplitude_IEnumerator);
    //        }
    //        else
    //        {
    //            m_shakeAmplitude = _shakeAmplitudeTo;
    //        }
    //    }
    //    public void SwitchOff(bool _off, float _duration)
    //    {
    //        if (_off)
    //        {
    //            ShutOff();
    //        }
    //        Reset();

    //        if (null != m_switchOff_IEnumerator)
    //        {
    //            Instance.StopCoroutine(m_switchOff_IEnumerator);
    //            m_switchOff_IEnumerator = null;
    //        }
    //        if (_off && _duration > 0)
    //        {
    //            m_switchOff_IEnumerator = Instance.TimeWait(_duration, () => { m_isSwitchOffShake = false; });
    //            Instance.StartCoroutine(m_switchOff_IEnumerator);
    //        }
    //        m_isSwitchOffShake = _off;
    //    }
    //    public void ShutOff()
    //    {
    //        SendFsmEvent(m_shakePMF, ShakeShutOffActionEvent);
    //    }
    //    public void Reset()
    //    {
    //        m_shake.localPosition = Vector3.zero;
    //        m_shake.localRotation = Quaternion.identity;
    //    }
    //    private void CalcAmplitude()
    //    {
    //        if (null == m_shakeAnim || !m_shakeAnim.isPlaying)
    //        {
    //            return;
    //        }
    //        m_shakePosition = m_shake.localPosition;
    //        m_shakePosition.x *= m_shakeAmplitude.x;
    //        m_shakePosition.y *= m_shakeAmplitude.y;
    //        m_shakePosition.z *= m_shakeAmplitude.z;
    //        m_shake.localPosition = m_shakePosition;
    //    }
    //    private void SetFsmParameter(PlayMakerFSM _fSM, string _paraName, Int32 _para)
    //    {
    //        if (string.IsNullOrEmpty(_paraName)) return;
    //        PMHelper.SetFsmParamter(_fSM, _paraName, _para);
    //    }
    //    private void SetFsmParameter(PlayMakerFSM _fSM, string _paraName, float _para)
    //    {
    //        if (string.IsNullOrEmpty(_paraName)) return;
    //        PMHelper.SetFsmParamter(_fSM, _paraName, _para);
    //    }
    //    private void SendFsmEvent(PlayMakerFSM _fSM, string _event)
    //    {
    //        if (string.IsNullOrEmpty(_event)) return;
    //        PMHelper.SendEvent(_fSM, _event);
    //    }
    //    private IEnumerator AmplitudeLerp(Vector3 _shakeAmplitude1, Vector3 _shakeAmplitude2, float _time)
    //    {
    //        float _cur = 0;
    //        while (_cur <= _time)
    //        {
    //            m_shakeAmplitude = Vector3.Lerp(_shakeAmplitude1, _shakeAmplitude2, _cur / _time);
    //            _cur += Time.deltaTime;
    //            yield return null;
    //        }
    //    }
    //}
    #endregion

    #region define

    public enum ECamMode
    {
        None = 0,
        Free,
        Enter,
        Trace,
    }

    public enum ETraceMode
    {
        None = 0,
        DoubleLookAt,
        DoubleFollow,
        TakeAim,
    }

    public enum EPlayType
    {
        None = -1,
        // 平滑进-平滑退
        BlendStart2BlendEnd = 0,
        // 平滑进-瞬间退
        BlendStart2BlinkEnd,
        // 瞬间进-平滑退
        BlinkStart2BlendEnd,
        // 瞬间进-瞬间退
        BlinkStart2BlinkEnd,
        // 平滑进-无退出
        BlendStart2NoEnd,
        // 瞬间进-无退出
        BlinkStart2NoEnd,
    }
    public class CDefine
    {
        [Header("名称")]
        public string m_name = "Default";
    }
    public interface IDefine
    {
        void Awake();
        void Enter();
        void Exit();
        void LateUpdate();
    }
    public class IMode<T> : IDefine where T : CDefine, IDefine
    {
        private Dictionary<string, T> m_setups = new Dictionary<string, T>();
        private IEnumerator m_duration_IEnumerator;
        private EPlayType m_playType = EPlayType.None;

        [Header("当前参数")]
        public T m_currSetup;
        protected T m_prevSetup;
        protected T m_defaultSetup;

        public virtual void Awake()
        {
            m_defaultSetup = m_currSetup;
            m_currSetup.Awake();
        }
        public virtual void Enter()
        {
            m_currSetup.Enter();
        }
        public virtual void Exit()
        {
            if (null != m_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_duration_IEnumerator);
                m_duration_IEnumerator = null;
            }
            m_playType = EPlayType.None;
            m_currSetup.Exit();
            m_currSetup = m_defaultSetup;
        }
        public virtual void LateUpdate()
        {
            m_currSetup.LateUpdate();
        }
        public void RecoverPrevSetup()
        {
            if (m_playType == EPlayType.BlendStart2BlinkEnd || m_playType == EPlayType.BlinkStart2BlinkEnd)
            {
                Instance.Lerp.SetLerp(false);
            }
            SetSetup(m_prevSetup, -1);
        }

        public void SetExternalSetup(string _name, float _duration = -1, EPlayType _playType = EPlayType.None)
        {
            if (null == m_setups || string.IsNullOrEmpty(_name))
            {
                return;
            }

            T _setup;
            if (string.IsNullOrEmpty(_name))
            {
                _setup = m_defaultSetup;
            }
            else if (!m_setups.TryGetValue(_name, out _setup))
            {
                //PapeGames.X3.X3Debug.LogError("[CameraTrace][ 异常!!  设置参数失败 无key:" + _name);
                return;
            }

            m_playType = _playType;
            if (m_playType == EPlayType.BlinkStart2BlendEnd || m_playType == EPlayType.BlinkStart2BlinkEnd || m_playType == EPlayType.BlinkStart2NoEnd)
            {
                Instance.Lerp.SetLerp(false);
            }
            SetSetup(_setup, _duration);
        }
        public void AddExternalSetup(T _setup)
        {
            if (string.IsNullOrEmpty(_setup.m_name))
            {
                //PapeGames.X3.X3Debug.LogError("[CameraTrace][ 异常!!   参数传入key为空");
                return;
            }
            if (HasSetup(_setup.m_name))
            {
                return;
            }
            _setup.Awake();
            m_setups.Add(_setup.m_name, _setup);
        }
        public bool HasSetup(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                return false;
            }
            return m_setups.ContainsKey(name);
        }
        private void SetSetup(T _setup, float _duration = -1)
        {
            if (null != m_duration_IEnumerator)
            {
                Instance.StopCoroutine(m_duration_IEnumerator);
                m_duration_IEnumerator = null;
            }

            m_currSetup.Exit();
            m_prevSetup = m_currSetup;
            m_currSetup = _setup;
            m_currSetup.Enter();

            if (_duration > 0)
            {
                m_duration_IEnumerator = Instance.TimeWait(_duration, RecoverPrevSetup);
                Instance.StartCoroutine(m_duration_IEnumerator);
            }
        }
    }

    //#if UNITY_EDITOR
    //    [ContextMenu("Refresh")]
    //    void SaveTT()
    //    {
    //        NewCameraTrack o = GetComponent<NewCameraTrack>();
    //        if (o == null)
    //        {
    //            return;
    //        }

    //        CameraTrace s = o.GetComponent<CameraTrace>();

    //        s.Lerp = o.Lerp.DeepCopy();
    //        s.Drag = o.Drag.DeepCopy();
    //        s.EnterMode.m_currSetup = o.EnterMode.m_currSetup.DeepCopy();
    //        s.FreeMode.m_currSetup = o.FreeMode.m_currSetup.DeepCopy();
    //        s.DoubleLookatMode.m_currSetup = o.DoubleLookatMode.m_currSetup.DeepCopy();
    //        s.DoubleFollwMode.m_currSetup = o.DoubleFollwMode.m_currSetup.DeepCopy();
    //        s.TakeAimMode.m_currSetup = o.TakeAimMode.m_currSetup.DeepCopy();
    //        s.Closeup = o.Closeup.DeepCopy();
    //        s.Fade = o.Fade.DeepCopy();



    //        UnityEditor.EditorUtility.SetDirty(s);
    //        UnityEditor.AssetDatabase.Refresh();
    //    }
    //#endif

    #endregion
}
