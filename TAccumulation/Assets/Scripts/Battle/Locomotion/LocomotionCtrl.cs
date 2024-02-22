using System;
using NodeCanvas.Framework;
using NodeCanvas.StateMachines;
using System.Collections.Generic;
using UnityEngine;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class LocomotionCtrl
    {
        public bool HasDestDir => _destDir != Vector3.zero;
        public Vector3 movePos => _movePos;
        public float movePosRadius => _movePosRadius;
        public float movePosDistance => _movePosDistance;
        public Vector3 destDir { get => _destDir; set => _destDir = value; }
        public Vector3 moveDir => _moveDir;
        public bool isRotationFinish => !_isRotating;//是否旋转完成
        public bool isMoveFinish => !_isMoving;//是否移动完成
        public LocomotionMode LocomotionMode => _locomotionMode;//运动公式
        public MoveType moveType => _moveType;//动作类型
        public string moveAnim => _moveAnim;//动作名
        public List<string> inclineAnimNames { get
            {
                if (_inclineAnimNames == null)
                {
                    _inclineAnimNames = new List<string>();
                }
                return _inclineAnimNames;
            } }

        //目标方向 
        protected Vector3 _destDir = Vector3.zero;
        //实际移动方向 (摇杆放开后stopMove保留,导航后修改)
        protected Vector3 _moveDir = Vector3.zero;
        //移动位置 移动目标可能是方向也可能是一个位置
        protected Vector3 _movePos = Vector3.zero;
        protected float _movePosRadius;
        protected float _movePosDistance;

        //运动方式
        protected LocomotionMode _locomotionMode = LocomotionMode.MoveDeltaTurnSpeedAndRM;
        protected MoveType _moveType = MoveType.Num;
        protected string _moveAnim;
        protected bool _isPause = false;
        protected bool _isRotating = false;
        protected bool _isMoving = false;

        //RM Speed
        //移速比例分为 : ①属性移速比例 ②locomotion移速比例 结果相乘得到最后移速比例 且只在移动状态下生效
        public float moveAttrSpeedMultiplier
        {
            get { return _moveAttrSpeedMultiplier; }
            set
            {
                _moveAttrSpeedMultiplier = Mathf.Clamp(value, 0f, 1f);
                _UpdateMoveSpeedMultiplier();
            }
        }
        public float moveCtrlSpeedMultiplier
        {
            get { return _moveCtrlSpeedMultiplier; }
            set
            {
                _moveCtrlSpeedMultiplier = Mathf.Clamp(value, 0f, 1f);
                _UpdateMoveSpeedMultiplier();
            }
        }
        public float moveCurSpeed = 5; //移动速度由动画控制 此速度不是准确速度
        public bool isUpdateRmMultiplier = false;
        public float maxRmAngle = 15f;
        public float minRmAngle = 60f;
        public float maxRmMultiplier = 1f;
        public float minRmMultiplier = 0.1f;
        protected float _moveAttrSpeedMultiplier = 1;
        protected float _moveCtrlSpeedMultiplier = 1;

        //locomotion speed set
        public bool CanSetSpeed = true;
        public float turnCurSpeed = 0;
        //Move TurnSpeed
        public float turnMaxSpeed = 1333;
        public float turnMaxSpeedAngle = 180;
        public bool isTurnStopToLastDir = true;
        //Wander TurnSpeed
        public float wanderMaxSpeed = 666;
        public float wanderMaxSpeedAngle = 180;

        //SpotTurn Speed
        public SpotTurnMode spotTurnMode = SpotTurnMode.None;
        public float spotTurnMinSpeed = 0;
        public float spotTurnMaxSpeed = 500;
        public bool isSpotTurnExtCtrlSpeed = false;
        public bool isSpotTurnHasSign = true;//旋转是否有方向 默认true
        public int setSpotTurnSign;
        public bool isSpotTurnArrived = false;//是否到达   
        public bool isSpotTurnArrivedStop = true;//是否到达后停止   
        public Vector3 spotTurnEnterSelfDir;

        //侧倾
        public float inclineWeight = 0f;
        public float moveInclineAngleRatio;
        public float moveInclineInterpSpeed = 1;

        protected List<string> _inclineAnimNames;
        public float inclineBlendValue;
        protected float _targetInclineBlendValue;
        protected float _inclineBlendTick;

        // WalkRunBlend相关
        public AnimationCurve turnSpeedRatioCurve { get; private set; }
        public AnimationCurve inclineRatioCurve { get; private set; }
        public AnimationCurve moveSpeedRatioCurve { get; private set; }
        private float _runThreshold; // Run动画的阈值 
        private float _walkThreshold; // Walk动画的阈值  

        //打断
        public Dictionary<CtrlInterruptType, CanInterruptType> canMoveInterrupt =
            new Dictionary<CtrlInterruptType, CanInterruptType>((int)CtrlInterruptType.Num) {
                { CtrlInterruptType.Locomotion, CanInterruptType.Can },
                { CtrlInterruptType.Timeline, CanInterruptType.None },
            };
        public Dictionary<CtrlInterruptType, CanInterruptType> canSkillInterrupt =
            new Dictionary<CtrlInterruptType, CanInterruptType>((int)CtrlInterruptType.Num) {
                { CtrlInterruptType.Locomotion, CanInterruptType.Can },
                { CtrlInterruptType.Timeline, CanInterruptType.None },
            };
        protected SkillTypeFlag _skillInterruptFlag = (SkillTypeFlag)(-1);

        //外部
        protected IRMAgent _rmAgent;
        public ILocomotionContext context { get; private set; }
        protected FSMOwner _animState;
        protected ActorMainState _mainState;
        protected ActorCharacterContext _graphContext;
        protected float _deltaTime;
        protected GameObject goFsm;

        private Action<EventAttrChange> _actionOnAttrChange;
        private Action<EventActorStateChange> _actionOnMainStateChange;

#if UNITY_EDITOR
        public bool testWalkRun = false;
#endif

        #region Init

        public LocomotionCtrl()
        {
            _actionOnAttrChange = _OnAttrChange;
            _actionOnMainStateChange = _OnMainStateChange;
        }

        public void OnStart(ILocomotionContext context, IRMAgent rmAgent, RoleCfg roleCfg, ActorMainState mainState)
        {
            this.context = context;
            _rmAgent = null == AstarPath.active ? null : rmAgent;
            _mainState = mainState;
            this.context?.onStateNotify.AddListener(OnAnimStateChange);

            var locomotionRatio = BattleResMgr.Instance.Load<LocomotionRatioAsset>(BattleConst.LocomotionRatioAssetName, BattleResType.LocomotionAsset);
            turnSpeedRatioCurve = locomotionRatio.turnSpeedRatio;
            inclineRatioCurve = locomotionRatio.inclineRatio;
            moveSpeedRatioCurve = locomotionRatio.moveSpeedRatio;
            BattleResMgr.Instance.Unload<LocomotionRatioAsset>(locomotionRatio);


            if (roleCfg == null) return;

            goFsm = BattleResMgr.Instance.Load<GameObject>(roleCfg.AnimFSMFilename, BattleResType.Fsm, "AnimState");
            if (goFsm == null) return;

            context.AddChild(goFsm.transform, false);
            _animState = goFsm.GetComponent<FSMOwner>();
            _graphContext = new ActorCharacterContext(this);
        }

        public void Born(RoleCfg roleCfg, Actor actor)
        {
            if(_animState != null)
            {
                _animState.blackboard.Reset();
                _graphContext.actor = actor;
                _graphContext.battle = actor.battle;
                _animState.blackboard.SetVariableValue(BattleConst.ContextVariableName, _graphContext);

                maxRmAngle = TbUtil.battleConsts.MoveSpeedEffectFrom;
                minRmAngle = TbUtil.battleConsts.MoveSpeedEffectTo;
                maxRmMultiplier = TbUtil.battleConsts.MaxMoveSpeedRatio;
                minRmMultiplier = TbUtil.battleConsts.MinMoveSpeedRatio;
                moveInclineAngleRatio = TbUtil.battleConsts.MoveInclineAngleRatio;
                moveInclineInterpSpeed = TbUtil.battleConsts.MoveInclineInterpSpeed;
                turnMaxSpeed = roleCfg.TurnMaxSpeed != 0 ? roleCfg.TurnMaxSpeed : turnMaxSpeed;
                wanderMaxSpeed = roleCfg.WanderTurnMaxSpeed != 0 ? roleCfg.WanderTurnMaxSpeed : wanderMaxSpeed;
                _animState.blackboard.SetVariableValue("TurnMaxSpeed", turnMaxSpeed);
                _animState.blackboard.SetVariableValue("TurnMaxSpeedAngle", turnMaxSpeedAngle = roleCfg.TurnMaxSpeedAngle);
                _animState.blackboard.SetVariableValue("WanderTurnMaxSpeed", wanderMaxSpeed);
                _animState.blackboard.SetVariableValue("WanderTurnMaxSpeedAngle", wanderMaxSpeedAngle = roleCfg.WanderTurnMaxSpeedAngle);

                _animState.blackboard.SetVariableValue("SpotTurnModeType", spotTurnMode = (SpotTurnMode)roleCfg.SpotTurnModeType);
                _animState.blackboard.SetVariableValue("SpotTurnAnimType", roleCfg.SpotTurnAnimType);
                _animState.blackboard.SetVariableValue("SpotTurnMinSpeed", spotTurnMinSpeed = roleCfg.SpotTurnMinSpeed);
                _animState.blackboard.SetVariableValue("SpotTurnMaxSpeed", spotTurnMaxSpeed = roleCfg.SpotTurnMaxSpeed);
                _animState.RestartBehaviour();//必须先于MainState Restart一下 否则监听不到MainState事件
                _animState.graph?.UpdateGraph(0);//必须Update一下才能执行到Start 否则会被MainState通知切走
            }

            _graphContext.actor.eventMgr.AddListener<EventAttrChange>(EventType.RootMotionMutiplierChange, _actionOnAttrChange, "LocomotionCtrl._OnAttrChange");
            _graphContext.actor.eventMgr.AddListener<EventActorStateChange>(EventType.ActorStateChange, _actionOnMainStateChange, "LocomotionCtrl._OnMainStateChange");
            _runThreshold = context.GetBlendTreeInfo(AnimStateName.Run).maxThreshold; // 
            _walkThreshold = context.GetBlendTreeInfo(AnimStateName.Run).minThreshold; // run状态配置成blendTree会生效            
        }
        #endregion

        #region Update

        public void Update(float deltaTime)
        {
            using (ProfilerDefine.LocomotionCtrlUpdatePMarker.Auto())
            {
                _deltaTime = deltaTime;
                _UpdateInclineBlend(_deltaTime);
                _UpdateMainState();
                _UpdateAnimState();
            }
        }

        protected void _UpdateMainState()
        {
            if (_mainState == null)
                return;

            if (_moveType == MoveType.Num)//有移动模式才去尝试进入移动 允许仅destDir 不进移动
                return;

            using (ProfilerDefine.LocomotionCtrlUpdateMainStatePMarker.Auto())
            {
                //没有destDir 如果在移动状态 则MoveSpeed设0 自然过度退出移动
                if (_destDir == Vector3.zero && _mainState.IsState(ActorMainStateType.Move) && GetAnimFloat(AnimParams.MoveSpeed) != 0)
                {
                    context.SetFloat(AnimParams.MoveSpeed, 0); //要求Aniamtor连线到Idle
                }
            }
        }

        protected void _UpdateAnimState()
        {
            using (ProfilerDefine.LocomotionCtrlUpdateAnimStatePMarker.Auto())
            {
                _animState?.graph?.UpdateGraph(_deltaTime);

                //Move侧倾
                GetMoveDeltaAngleY(out var includeAngleY, out var sign);
                var targetIncline = Mathf.Min(includeAngleY * moveInclineAngleRatio,
                    TbUtil.battleConsts.MoveInclineMaxAngleValue) * sign;
                UpdateIncline(targetIncline);
            }
        }
        public void UpdateIncline(float targetIncline, bool immediately = false)
        {
            if (_graphContext.actor.IsBoy() || _graphContext.actor.IsGirl())
            {
                if (immediately)
                {
                    inclineWeight = targetIncline;
                    context.SetLayerWeight((int)RoleAnimLayer.BaseAdd, inclineWeight * inclineBlendValue * GetWalkRunRatio(inclineRatioCurve));
                    return;
                }
                var currentIncline = GetAnimFloat(AnimParams.MoveIncline);
                if (currentIncline != targetIncline)
                {
                    var nextMoveIncline = BattleUtil.FInterpTo(currentIncline, targetIncline, _deltaTime, moveInclineInterpSpeed);

                    context.SetFloat(AnimParams.MoveIncline, nextMoveIncline);
                    inclineWeight = Mathf.Abs(nextMoveIncline) / TbUtil.battleConsts.MoveInclineMaxAngleValue;
                    context.SetLayerWeight((int)RoleAnimLayer.BaseAdd, inclineWeight * inclineBlendValue * GetWalkRunRatio(inclineRatioCurve));
                }
            }
        }

        public void LateUpdate()
        {
            using (ProfilerDefine.LocomotionCtrlLateUpdatePMarker.Auto())
            {
                _UpdateMove();
                _UpdateRotate();
            }
        }

        protected void _UpdateMove()
        {
            using (ProfilerDefine.LocomotionCtrlUpdateMovePMarker.Auto())
            {
                if (_isPause || _isMoving == false)
                {
                    return;
                }

                _destDir = _moveDir = _movePos - context.position;
                _CalcNavMesh();
                _movePosDistance = Vector3.Distance(_movePos, context.position);
                var moveDistance = _deltaTime * moveCurSpeed;

                if (_movePosDistance < _movePosRadius)
                {
                    StopMove();
                }
                else if (_destDir.sqrMagnitude <= moveDistance * moveDistance)
                {
                    //如果距离小于此帧移动速度 直接设置过去 防止绕圈
                    context.SetPosition(_movePos);
                    StopMove();
                }

            }
        }

        protected void _UpdateRotate()
        {
            if (_isPause || _moveDir == Vector3.zero)
                return;

            using (ProfilerDefine.LocomotionCtrlUpdateRotationPMarker.Auto())
            {

                GetMoveDeltaAngleY(out float angleY, out var sign);

                switch (_locomotionMode)
                {
                    case LocomotionMode.ConstTurnSpeed:
                        _UpdateMoveByConstantSpeed(sign);
                        break;
                    case LocomotionMode.MoveDeltaTurnSpeedAndRM:
                        _UpdateMoveBySlopeSpeedAndRM(angleY);
                        break;
                    case LocomotionMode.SpotTurnLogicSpeed:
                        _SpotTurnLogicSpeed(angleY, sign);
                        break;
                }

                CheckRotateEnd();
            }
        }
        protected void _UpdateMoveByConstantSpeed(int sign)
        {
            Quaternion q = Quaternion.LookRotation(_moveDir);
            context.SetRotation(Quaternion.RotateTowards(context.rotation, q, turnCurSpeed * GetWalkRunRatio(turnSpeedRatioCurve) * _deltaTime));
        }
        protected void _UpdateMoveBySlopeSpeedAndRM(float angleY)
        {
            var speedT = 0f;
            if (_moveType == MoveType.Wander)
            {
                if (wanderMaxSpeedAngle != 0)//防止计算出NaN
                    speedT = (wanderMaxSpeedAngle - angleY) / (wanderMaxSpeedAngle - 0);
                turnCurSpeed = Mathf.Lerp(wanderMaxSpeed, 0, speedT);
            }
            else
            {
                if (turnMaxSpeedAngle != 0)
                    speedT = (turnMaxSpeedAngle - angleY) / (turnMaxSpeedAngle - 0);
                turnCurSpeed = Mathf.Lerp(turnMaxSpeed, 0, speedT);
            }
            Quaternion q = Quaternion.LookRotation(_moveDir);
            context.SetRotation(Quaternion.RotateTowards(context.rotation, q, turnCurSpeed * GetWalkRunRatio(turnSpeedRatioCurve) * _deltaTime));
        }
        public void UpdateDeltaRM()
        {
            GetMoveDeltaAngleY(out var includeAngleY, out var _);
            //Run的速度受到人物方向与遥感方向夹角影响
            var t = (maxRmAngle - includeAngleY) / (maxRmAngle - minRmAngle);
            var targetMultiplier = Mathf.Lerp(minRmMultiplier, maxRmMultiplier, t);
            //var nextMultiplier = Mathf.MoveTowards(_context.locomotionCtrl.moveCtrlSpeedMultiplier, targetMultiplier, TbUtil.battleConsts.MoveRmAccelSpeed);
            moveCtrlSpeedMultiplier = targetMultiplier;
        }

        protected void _SpotTurnLogicSpeed(float angleY, int sign)
        {
            if (isSpotTurnArrived)//转到后不再转
                return;

            if (isSpotTurnHasSign)
            {
                var nextSpotTurnAngle = Vector3.Angle(spotTurnEnterSelfDir, _moveDir);
                var nextSpotTurnSign = Vector3.Cross(spotTurnEnterSelfDir, _moveDir).y > 0 ? 1 : -1;
                //反向并且还超过设置角度 
                if (nextSpotTurnSign != setSpotTurnSign && 180 - nextSpotTurnAngle > TbUtil.battleConsts.SpotTurnOverAngle)
                {
                    isSpotTurnArrived = true;
                    return;
                }
                //规定方向一致，但是和当前方向不一致
                else if (nextSpotTurnSign == setSpotTurnSign && sign != setSpotTurnSign)
                {
                    isSpotTurnArrived = true;
                    return;
                }
                //即使要转大弯 也要按照进入时设定的方向转
                else
                {
                    sign = setSpotTurnSign;
                }
            }
            if (!isSpotTurnExtCtrlSpeed)
            {
                var state = GetCurrentAnimatorStateInfo();
                turnCurSpeed = angleY / (float)(state.length - state.length * state.normalizedTime);
                turnCurSpeed = Mathf.Clamp(turnCurSpeed, spotTurnMinSpeed, spotTurnMaxSpeed);
            }
            var nextRot = turnCurSpeed * _deltaTime;//此处速度由action设置
            if (nextRot > angleY)
            {
                nextRot = angleY;
            }
            context.TranslateEulerAnglesY(nextRot * sign);
        }
        protected void _CalcNavMesh()
        {
            if (null != _rmAgent && !_rmAgent.isStopped && _rmAgent.steeringDirection != Vector3.zero)
            {
                _moveDir = _rmAgent.steeringDirection;
                _moveDir.y = 0;
                Debug.DrawLine(context.position, context.position + _moveDir, Color.green);
            }
        }

        protected void CheckRotateEnd()
        {
            //不同状态 不同停止逻辑 Run:松开摇杆且方向达到 Trun:方向达到
            //TODO 有些在Cmd内完成 有些在这里 需要整理一下
            if (_moveType == MoveType.Run)
            {
                if (_destDir == Vector3.zero && _moveDir == context.forward ||
                    _destDir == Vector3.zero && _moveDir == Vector3.zero)
                    StopMove();
            }
            else if (_moveType == MoveType.Turn)
            {
                if (isSpotTurnArrivedStop && _moveDir == context.forward)
                    StopMove();
            }
        }
        #endregion

        #region 接口
        public void SetLocomotionMode(LocomotionMode mode)
        {
            _locomotionMode = mode;
        }

        public bool MoveDir(Vector3 destDir, MoveType moveType, string useMoveAnim, bool isEnter)
        {
            bool canMove = _canMove(useMoveAnim, isEnter, out var reEnter);
            _destDir = destDir;

            if (!canMove)
                return false;

            if (destDir != Vector3.zero || !isTurnStopToLastDir)//如果非松开摇杆
            {
                _moveDir = destDir;
                _moveDir.y = 0;
                _isRotating = true;
                _moveType = moveType;
                _moveAnim = useMoveAnim;
                if (reEnter)
                    TriggerFSMEvent("OnMoveEnter");
            }
            else if (!_mainState.IsState(ActorMainStateType.Move))//松开摇杆 不在Move状态 设置moveDir
            {
                _moveDir = destDir;
            }
            return true;
        }

        public bool MovePos(Vector3 destPos, float radius, bool isEnter, string useMoveAnim = MoveRunAnimName.Run)
        {
            if (!_canMove(useMoveAnim, isEnter, out var reEnter))
                return false;

            //如果已经在范围内了 不再进入移动
            var distance = destPos - context.position;
            var proDis = Vector3.ProjectOnPlane(distance, Vector3.up);
            if (proDis.sqrMagnitude <= radius * radius)
            {
                _isMoving = false;
                return false;
            }

            _moveType = MoveType.Run;
            _movePos = destPos;
            _movePosRadius = radius;
            _destDir = _moveDir = destPos - context.position;
            _moveDir.y = 0;
            if (null != _rmAgent) _rmAgent.destination = destPos;
            _isMoving = true;
            _isRotating = true;
            _moveAnim = useMoveAnim;
            if (reEnter)
                TriggerFSMEvent("OnMoveEnter");
            return true;
        }
        
        bool _canMove(string useMoveAnim, bool isEnter, out bool reEnter)
        {
            bool inMoveState = _mainState.IsState(ActorMainStateType.Move);
            bool canInterrupt = CanMoveInterrupt();
            bool newMoveAnim = _moveAnim != useMoveAnim || _destDir == Vector3.zero;
            reEnter = false;
            if (inMoveState)
            {
                if (canInterrupt)
                {
                    if (isEnter && newMoveAnim)
                        reEnter = true;
                }
                else
                {
                    if (isEnter)
                        return false;
                }
            }
            return true;
        }

        public void StopMove(bool resetDest = true)
        {
            context.SetFloat(AnimParams.MoveSpeed, 0);
            if (null != _rmAgent) _rmAgent.isStopped = true;
            if (resetDest)
            {
                _destDir = Vector3.zero;
            }
            _locomotionMode = LocomotionMode.Null;
            _moveType = MoveType.Num;
            _movePos = _moveDir = Vector3.zero;
            _isRotating = _isMoving = isSpotTurnArrived = false;
            _moveAnim = null;
        }

        public void SetPause(bool v)
        {
            _isPause = v;
        }

        //public void SwitchMoveIncline(bool v)
        //{
        //    if (!CanSetSpeed)
        //        return;
        //    isUseIncline = v;
        //}

        public void SetTurnSpeed(float? cur, float? min, float? max, float? minSpeedAngle, float? maxSpeedAngle, float? accel = 0)
        {
            if (!CanSetSpeed)
                return;
            if (cur != null)
                turnCurSpeed = cur.Value;
            if (max != null)
            {
                if (_moveType == MoveType.Wander)
                    wanderMaxSpeed = max.Value;
                else
                    turnMaxSpeed = max.Value;
            }
            if (maxSpeedAngle != null)
            {
                if (_moveType == MoveType.Wander)
                    wanderMaxSpeedAngle = maxSpeedAngle.Value;
                else
                    turnMaxSpeedAngle = maxSpeedAngle.Value;
            }
            //if(min != null)  _turnMinSpeed = min.Value;
            //if (minSpeedAngle != null) _turnMinSpeedAngle = minSpeedAngle.Value;
            //if (accel != null) _turnAccelSpeed = accel.Value;
        }
        public void SetEnterRMTurn(int spotTurnAnim)
        {
            _isPause = true;
            GetMoveDeltaAngleY(out float angleY, out int sign);
            if (spotTurnAnim == (int)SpotTurnAnim.FourAnim)
            {
                if (sign > 0)
                {
                    if (angleY < TbUtil.battleConsts.SpotTurnSelectAngle)
                    {
                        context.SetRootMotionMultiplier(null, angleY / 90f);
                    }
                    else
                    {
                        context.SetRootMotionMultiplier(null, angleY / 180f);
                    }
                }
                else
                {
                    if (angleY < TbUtil.battleConsts.SpotTurnSelectAngle)
                    {
                        context.SetRootMotionMultiplier(null, angleY / 90f);
                    }
                    else
                    {
                        context.SetRootMotionMultiplier(null, angleY / 180f);
                    }
                }
            }
            else if (spotTurnAnim == (int)SpotTurnAnim.TwoAnim)
            {
                context.SetRootMotionMultiplier(null, angleY / 180f);
            }
        }

        public bool TriggerFSMEvent(string eventName)
        {
            if (_animState?.behaviour is FSM fsm)
            {
                return fsm.TriggerEvent(eventName);
            }

            return false;
        }

        public T GetAnimFSMVariable<T>(string name)
        {
            if (_animState == null)
                return default;

            return _animState.blackboard.GetVariableValue<T>(name);
        }

        public void SetAnimFSMVariable<T>(string name, T value)
        {
            if (_animState == null)
                return;
            _animState.blackboard.SetVariableValue(name, value);
        }

        public void GetMoveDeltaAngleY(out float angleY, out int sign)
        {
            angleY = Vector3.Angle(context.forward, _moveDir);

            var cross = Vector3.Cross(context.forward, _moveDir).y;
            if (cross > 0)
                sign = 1;
            else
                sign = -1;
        }

        public bool IsMoveEndAnim()
        {
            var anim = context.GetCurrentAnimatorStateName();
            if (anim == MoveRunAnimName.RunStop ||
                anim == MoveWanderAnimName.LeftStop || anim == MoveWanderAnimName.RightStop ||
                anim == MoveWanderAnimName.ForwardStop || anim == MoveWanderAnimName.BackStop)
            {
                return true;
            }
            return false;
        }

        public void SetInclineAnims(List<string> names)
        {
            _inclineAnimNames = names;
        }

        #endregion

        #region 动画

        public void PlayAnim(string stateName, float fade = 0)
        {
            if (context == null)
                return;
            context.PlayAnim(stateName, true, fade);
        }

        public X3.PlayableAnimator.AnimatorStateInfo GetCurrentAnimatorStateInfo()
        {
            if (context == null)
                return new X3.PlayableAnimator.AnimatorStateInfo();
            return context.GetCurrentAnimatorStateInfo();
        }

        public string GetCurrentAnimStateName()
        {
            if (context == null)
                return null;
            return context.GetCurrentAnimatorStateName(AnimConst.DefaultLayer);
        }

        public bool HasAnimState(string stateName)
        {
            if (context == null)
                return false;
            return context.HasState(stateName);
        }

        public AnimationClip GetAnimatorStateClip(string stateName)
        {
            if (context == null)
                return null;
            return context.GetAnimatorStateClip(stateName);
        }

        public void OnAnimStateChange(int layerIndex, StateNotifyType notifyType, string stateName)
        {
            if (context == null)
                return;
            if (layerIndex != AnimConst.DefaultLayer)
                return;
            if (notifyType == StateNotifyType.PrepEnter)
            {
                var prevStateName = context.GetPreviousAnimatorStateInfo().name;
                var currStateName = context.GetCurrentAnimatorStateInfo().name;

                // 如果上一个动画是绑定了侧倾状态的，而下一个动画不是，则将侧倾参数过渡到0
                if (inclineAnimNames.Contains(prevStateName) && !inclineAnimNames.Contains(currStateName))
                {
                    _StartInclineBlend(0, context.GetBlendTick());
                }
                else if (!inclineAnimNames.Contains(prevStateName) && inclineAnimNames.Contains(currStateName))
                {
                    _StartInclineBlend(1, context.GetBlendTick());
                }
            }
            if (notifyType == StateNotifyType.Enter)
            {

                using (ProfilerDefine.LocomotionCtrlSendFSMEventPMarker.Auto())
                {

                    using (zstring.Block())
                    {
                        zstring animEvent = (zstring)"Anim_" + stateName;
                        TriggerFSMEvent(animEvent);
                    }
                }

                if (_mainState.IsState(ActorMainStateType.Move) && stateName == AnimStateName.Idle)
                {
                    StopMove();
                    _mainState.TryToState(ActorMainStateType.Idle);
                }
            }
            if (notifyType == StateNotifyType.Complete)
            {
                using (zstring.Block())
                {
                    zstring animEvent = (zstring)"Anim_" + stateName + "_Complete";
                    TriggerFSMEvent(animEvent);
                }
            }
        }

        public float GetAnimFloat(string animName)
        {
            if (context == null)
                return 0;
            return context.GetFloat(animName);
        }

        protected void _UpdateMoveSpeedMultiplier()
        {
            if (_mainState.IsState(ActorMainStateType.Move))
            {
                var multipler = _moveAttrSpeedMultiplier * _moveCtrlSpeedMultiplier * GetWalkRunRatio(moveSpeedRatioCurve);
                context.SetRootMotionMultiplier(x: multipler, z: multipler);
            }
        }

        protected string _GetMoveAnimStateName(string animName)
        {
            if (context.HasParam(AnimParams.WalkRunBlend) && animName == MoveRunAnimName.Walk)
                return MoveRunAnimName.Run;
            return animName;
        }
        #endregion

        #region WalkRunBlend
        public void SetWalkRunBlend(float speed)
        {
            if (context.TryCalBlendTreeParamValue(AnimStateName.Run, speed, out var paramValue, 0))
                context.SetFloat(AnimParams.WalkRunBlend, paramValue, TbUtil.battleConsts.WalkRunInterpTime);
        }

        /// <summary>
        /// 如果从非移动状态进入移动状态，直接把WalkRunBlendTree设到对应状态,否则缓慢过渡到对应状态
        /// </summary>
        public void CheckWalkRunBlend(ref string moveAnim)
        {
#if UNITY_EDITOR
            if (testWalkRun)
                return;
#endif
            if (!_mainState.IsState(ActorMainStateType.Move))
            {
                // 非Move状态进入Move状态，直接把参数设到对应阈值
                if (moveAnim == MoveRunAnimName.Run)
                    context.SetFloat(AnimParams.WalkRunBlend, _runThreshold);
                else if (moveAnim == MoveRunAnimName.Walk)
                {
                    moveAnim = _GetMoveAnimStateName(moveAnim);
                    context.SetFloat(AnimParams.WalkRunBlend, _walkThreshold);
                }
            }
            else
            {
                // 否则缓慢过渡到对应阈值
                if (moveAnim == MoveRunAnimName.Run)
                    context.SetFloat(AnimParams.WalkRunBlend, _runThreshold, TbUtil.battleConsts.WalkRunInterpTime);
                else if (moveAnim == MoveRunAnimName.Walk)
                {
                    moveAnim = _GetMoveAnimStateName(moveAnim);
                    context.SetFloat(AnimParams.WalkRunBlend, _walkThreshold, TbUtil.battleConsts.WalkRunInterpTime);
                }
            }
        }

        /// <summary>
        /// 根据当前walkRun的混合程度，获取对应的转身/侧倾/速度 修正系数
        /// </summary>
        /// <returns></returns>
        public float GetWalkRunRatio(AnimationCurve curve)
        {
            if (curve == null || !context.HasParam(AnimParams.WalkRunBlend))
                return 1;
            var weight = context.GetBlendTreeInfo(AnimStateName.Run).outSpeedNormalize;
            return curve.Evaluate(weight);
        }
        #endregion

        #region 侧倾
        private void _StartInclineBlend(float target, float time)
        {
            _inclineBlendTick = time;
            _targetInclineBlendValue = target;
        }

        private void _UpdateInclineBlend(float deltaTime)
        {
            if (_inclineBlendTick > deltaTime)
            {
                var speed = (_targetInclineBlendValue - inclineBlendValue) / _inclineBlendTick;
                inclineBlendValue += speed * deltaTime;
                _inclineBlendTick -= deltaTime;
            }
            else if (_inclineBlendTick < deltaTime && _inclineBlendTick > 0)
            {
                inclineBlendValue = _targetInclineBlendValue;
                _inclineBlendTick = 0;
            }
            else if (_inclineBlendTick == 0 && inclineBlendValue != _targetInclineBlendValue)
            {
                inclineBlendValue = _targetInclineBlendValue;
            }
        }
        #endregion

        #region 打断
        public bool CanSkillInterrupt(SkillType otherType)
        {
            //只要有可打断 那就可
            foreach (var interrupt in canSkillInterrupt)
            {
                if (interrupt.Value == CanInterruptType.Can)
                {
                    if (BattleUtil.ContainSkillType(_skillInterruptFlag, otherType))
                        return true;
                }
            }
            return false;
        }
        public void SetSkillInterrupt(CtrlInterruptType type, CanInterruptType can, SkillTypeFlag flag = 0)
        {
            canSkillInterrupt[type] = can;
            if (can == CanInterruptType.Cannot)
            {
                _skillInterruptFlag = 0;
            }
            else
            {
                _skillInterruptFlag = flag;
            }
        }

        public bool CanMoveInterrupt()
        {
            //只要有可打断 那就可
            foreach (var interrupt in canMoveInterrupt)
            {
                if (interrupt.Value == CanInterruptType.Can)
                    return true;
            }
            return false;
        }
        public void SetMoveInterrupt(CtrlInterruptType type, CanInterruptType can)
        {
            canMoveInterrupt[type] = can;
        }
        public void ResetInterrupt()
        {
            for (int i = 0; i < (int)CtrlInterruptType.Num; i++)
            {
                if (i == (int)CtrlInterruptType.Locomotion)
                {
                    canMoveInterrupt[(CtrlInterruptType)i] = canSkillInterrupt[(CtrlInterruptType)i] = CanInterruptType.Can;
                }
                else if (i == (int)CtrlInterruptType.Timeline)
                {
                    canMoveInterrupt[(CtrlInterruptType)i] = canSkillInterrupt[(CtrlInterruptType)i] = CanInterruptType.None;
                }
            }
            _skillInterruptFlag = (SkillTypeFlag)(-1);
        }
        #endregion

        #region Destroy
        public void OnDestroy()
        {
            _graphContext.actor.eventMgr.RemoveListener<EventAttrChange>(EventType.RootMotionMutiplierChange, _actionOnAttrChange);
            _graphContext.actor.eventMgr.RemoveListener<EventActorStateChange>(EventType.ActorStateChange, _actionOnMainStateChange);
        }

        public void Discard()
        {
            UnloadAnimFSM();
        }

        private void UnloadAnimFSM()
        {
            if (!goFsm) return;

            goFsm.transform.SetParent(null);
            BattleResMgr.Instance.Unload(goFsm);
            goFsm = null;
        }

        private void _OnMainStateChange(EventActorStateChange arg)
        {
            if (arg.toStateName == ActorMainStateType.Move) //进入移动
            {
                _UpdateMoveSpeedMultiplier();
            }
            else if (arg.fromStateName == ActorMainStateType.Move) //退出移动
            {
                context.SetRootMotionMultiplier(x: 1, z:1);
            }
        }

        private void _OnAttrChange(EventAttrChange arg)
        {
            moveAttrSpeedMultiplier = _graphContext.actor.attributeOwner.GetAttrValue(AttrType.RootMotionMutiplierXZ);
        }
        #endregion
    }
}