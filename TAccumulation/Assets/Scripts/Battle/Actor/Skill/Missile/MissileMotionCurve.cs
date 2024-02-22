using System;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class MissileMotionCurve : MissileMotionBase
    {
        private float _curSpeed; // 实时速度
        private float _curAngleSpeed; // 实时角度旋转速度
        
        private Vector3 _startPos;  // 起始位置
        private Vector3 _startForward; // 起始朝向
        
        private bool _bIsComplete; // 标记是否完成.
        private bool _enableCollision; // 是否启用正常的碰撞逻辑;
        private int _jumpNum;
        #region 导弹记录发射时追踪的目标.

        private Vector3 _targetPos; // 目标位置.
        private Actor _target; // 初始追踪的目标
        private bool _bIsMissTarget; // 是否丢失目标.
        private Transform _targetHitTrans; // 目标Hit点的Transform
        private float _trackTime; // 追踪计时用.

        #endregion
        
        #region 抛物线模式用到的私有变量
        
        private float _startHeight; // 起始子弹高度.
        private float _parabolaTime; // 抛物线运动时间
        private Vector3 _horizontalForward; // 抛物线的水平方向.
        private float _ySpeed; // 抛物线初始向上的速度.
        private float _xzSpeed; // 抛物线水平方向上的速度.
        private float? _jumpYSpeed;  // 弹跳时的速度（记录一下，为了避免帧率不稳导致的衰减）

        public float ySpeed
        {
            get => _ySpeed;
            set => _ySpeed = value;
        }

        public float xzSpeed
        {
            get => _xzSpeed;
            set => _xzSpeed = value;
        }

        #endregion

        protected override void _OnStart()
        {
            _InitLockPoint();
            _bIsComplete = false;
            _bIsMissTarget = false;
            _startPos = _model.position;
            _startForward = _model.forward;
            _curSpeed = _cfg.InitialSpeed;
            _curAngleSpeed = _cfg.CurveData.AngleSpeed;
            _trackTime = 0f;
            _enableCollision = _cfg.CurveData.EnableCollisionBeforeReaching;
            _jumpNum = _cfg.CurveData.JumpMotionData.JumpNum;
            switch (_cfg.CurveData.MissileCurveTraceMode)
            {
                case MissileCurveTraceMode.None:
                    break;
                case MissileCurveTraceMode.Target:
                    _target = _targetActor;
                    _bIsMissTarget = _target == null;
                    break;
                case MissileCurveTraceMode.OriginPosition:
                    _target = _targetActor;
                    if (_targetHitTrans != null)
                    {
                        _targetPos = _targetHitTrans.position + _cfg.CurveData.HitPointOffset;
                    }
                    else
                    {
                        _bIsMissTarget = true;
                    }
                    break;
                case MissileCurveTraceMode.Parabola:
                    Vector3 startXZPos = new Vector3(_startPos.x, 0f, _startPos.z);
                    _target = _targetActor;
                    _bIsMissTarget = _target == null;
                    _horizontalForward = new Vector3(_startForward.x, 0f, _startForward.z);
                    if (_target != null && _targetHitTrans != null)
                    {
                        var position = _targetHitTrans.position;
                        var targetModelXZPos = new Vector3(position.x, 0f, position.z);
                        // DONE: 当开启极限距离限制时, 当目标距离朝过策划配置的极限距离, 则采用极限距离作为抛物线落点.
                        if (_cfg.CurveData.EnableLimitMaxDistance && (targetModelXZPos - startXZPos).magnitude >= _cfg.CurveData.LimitMaxDistance)
                        {
                            _targetPos = startXZPos + _horizontalForward * _cfg.CurveData.LimitMaxDistance;
                        }
                        else
                        {
                            _targetPos = targetModelXZPos;
                        }
                    }
                    else
                    {
                        if (_cfg.CurveData.EnableLimitMaxDistance && _cfg.CurveData.ParabolaDefaultDistance >= _cfg.CurveData.LimitMaxDistance)
                        {
                            _targetPos = startXZPos + _horizontalForward * _cfg.CurveData.LimitMaxDistance;
                        }
                        else
                        {
                            _targetPos = startXZPos + _horizontalForward * _cfg.CurveData.ParabolaDefaultDistance;   
                        }
                    }
                    _startHeight = _model.position.y;
                    // DONE: 特殊处理对象池时, y<0这种特殊逻辑.
                    if (_startHeight < 0)
                    {
                        _startHeight = 0;
                    }
                    _parabolaTime = _CalcuParabolaTime(_startHeight, _cfg.CurveData.ParabolaYSpeed, Math.Abs(_cfg.CurveData.GravitationalAcceleration), _targetHitTrans == null ? 0 : _targetHitTrans.position.y);
                    _ySpeed = _cfg.CurveData.ParabolaYSpeed;
                    
                    // DONE: 求水平速度, 应忽略y轴高度.
                    Vector3 targetXZPos = new Vector3(_targetPos.x, 0f, _targetPos.z);
                    _xzSpeed = (targetXZPos - startXZPos).magnitude / _parabolaTime;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        protected override void _OnStop()
        {
            
        }

        private void _InitLockPoint()
        {
            _targetHitTrans = null;
            switch (_cfg.CurveData.MissileCurveTraceMode)
            {
                case MissileCurveTraceMode.None:
                    break;
                case MissileCurveTraceMode.Target:
                case MissileCurveTraceMode.OriginPosition:
                case MissileCurveTraceMode.Parabola:
                    _targetHitTrans = BattleUtil.GetLockPoint(_targetActor, _cfg.LockPointType);
                    break;
            }
        }

        protected override void _OnHitAny(Actor actor)
        {
            if (_enableCollision)
            {
                return;
            }

            if (actor != _target)
            {
                return;
            }

            _enableCollision = true;
        }

        public override bool CanHit(Actor actor)
        {
            return _enableCollision || actor == _target;
        }

        protected override void _OnUpdate(float deltaTime)
        {
            if (_bIsComplete)
            {
                return;
            }
            
            Vector3 curPos = _model.position;
            Vector3 curForward = _model.forward;

            // DONE: 考虑极限距离的判断. (抛物线的极限距离逻辑在_OnStart里已做了处理 .)
            if (_cfg.CurveData.MissileCurveTraceMode != MissileCurveTraceMode.Parabola && 
                _cfg.CurveData.EnableLimitMaxDistance && (_startPos - curPos).sqrMagnitude > _cfg.CurveData.LimitMaxDistance * _cfg.CurveData.LimitMaxDistance)
            {
                _bIsComplete = true;
                return;
            }
            
            // DONE: 计算最新当前速度.
            float oldSpeed = _curSpeed;
            float accelerate = _cfg.Accelerate;
            if (_cfg.CurveData.MissileCurveTraceMode == MissileCurveTraceMode.None)
            {
                accelerate += _cfg.CurveData.AxialAcceleration.z;
            }
            
            _curSpeed = _CalcuCurSpeed(_curSpeed, accelerate, _cfg.MaxSpeed, deltaTime);
            
            Vector3 offsetPos = Vector3.zero;
            switch (_cfg.CurveData.MissileCurveTraceMode)
            {
                case MissileCurveTraceMode.None:
                {
                    //如果使用世界坐标系
                    if (_cfg.CurveData.IsUseWorldAcc)
                    {
                        offsetPos = 0.5f * (Quaternion.LookRotation(Vector3.forward) * new Vector3(_cfg.CurveData.AxialAcceleration.x, _cfg.CurveData.AxialAcceleration.y, _curSpeed + oldSpeed)) * deltaTime;
                    }
                    else
                    {
                        // DONE: 仅计算轴向加速度.
                        // s = 0.5 * (v0 + v1) * t
                        offsetPos = 0.5f * (Quaternion.LookRotation(curForward) * new Vector3(_cfg.CurveData.AxialAcceleration.x, _cfg.CurveData.AxialAcceleration.y, _curSpeed + oldSpeed)) * deltaTime;
                    }
                    break;
                }
                case MissileCurveTraceMode.Target:
                {
                    _trackTime += deltaTime;
                    // DONE: 是否继续追踪 = 追踪的时长不超过策划的配置（-1代表永久响应时间.） && 目标没有丢失.
                    bool isTrack = (_cfg.CurveData.TrackTime < 0 || _trackTime < _cfg.CurveData.TrackTime) && !_bIsMissTarget;
                    // DONE: 实时获取骨骼点的偏移位置.
                    _targetPos = !_bIsMissTarget ? _targetHitTrans.position + _cfg.CurveData.HitPointOffset : Vector3.zero;
                    offsetPos = _CalcuTracePositionOffset(isTrack, curPos, curForward, _targetPos, deltaTime);
                    break;
                }
                case MissileCurveTraceMode.OriginPosition:
                {
                    offsetPos = _CalcuTracePositionOffset(!_bIsMissTarget, curPos, curForward, _targetPos, deltaTime);
                    break;
                }
                case MissileCurveTraceMode.Parabola:
                {
                    // 横向位移.
                    _horizontalForward = new Vector3(curForward.x, 0, curForward.z).normalized;
                    Vector3 horizontalOffset = _horizontalForward * _xzSpeed * deltaTime; 
                    
                    // 纵向位移.
                    // 更新y轴速度 
                    _ySpeed -= _cfg.CurveData.GravitationalAcceleration * deltaTime;
                    Vector3 verticalOffset = Vector3.up * _ySpeed * deltaTime;
                    offsetPos = horizontalOffset + verticalOffset;
                    break;
                }
                default:
                    throw new ArgumentOutOfRangeException();
            }

            Vector3 newPos = curPos + offsetPos;
            Vector3 newForward = offsetPos.normalized;
            
            // DONE: 设置导弹当前位置.
            _model.SetPosition(newPos);
            
            // DONE: 设置导弹当前朝向.
            if (newForward != Vector3.zero)
            {
                _model.SetForward(newForward, false);
            }
        }

        public override bool IsComplete()
        {
            return _bIsComplete;
        }

        private Vector3 _CalcuTracePositionOffset(bool isTrack, Vector3 curPos, Vector3 curForward, Vector3 targetPos, float deltaTime)
        {
            Vector3 offsetPos = Vector3.zero;
            if (isTrack)
            {
                // DONE: 计算最新的角速度.
                _curAngleSpeed = _CalcuCurAngleSpeed(_curAngleSpeed, _cfg.CurveData.AngleAcceleration, _cfg.CurveData.AngleLimitSpeed, deltaTime);
                        
                // DONE: 计算单帧最大旋转角度.
                float maxAngle = _CalcuMaxRotationAngle(_curAngleSpeed, _cfg.CurveData.EnableLimitMaxAngle, _cfg.CurveData.LimitMaxAngle, deltaTime);
                        
                // DONE: 计算包含旋转角的最新朝向.
                Vector3 newForward = _CalcuNewForward(curForward, curPos, targetPos, maxAngle);
                        
                // DONE: 朝新朝向位移.
                offsetPos = _curSpeed * newForward * deltaTime;
            }
            else
            {
                // DONE: 丢失目标则子弹按直线运动.
                offsetPos = _curSpeed * curForward * deltaTime;
            }

            return offsetPos;
        }

        /// <summary>
        /// 弹跳
        /// </summary>
        protected override bool _OnJump()
        {
            if (!(_cfg.MotionType == MissileMotionType.Curve
                && (_cfg.CurveData.MissileCurveTraceMode == MissileCurveTraceMode.Parabola ||
                    _cfg.CurveData.MissileCurveTraceMode == MissileCurveTraceMode.None)
                && _cfg.CurveData.JumpMotionData.JumpNum > 0))
            {
                return true;
            }
            
            if (_jumpNum <= 0)
            {
                _isStopUpdate = true;
                return _cfg.CurveData.JumpMotionData.JumpEndDisappear;
            }

            if (_missileTrans == null)
            {
                return false;
            }
            //改变速度反向
            //只需要改变Y轴朝向 不需要旋转方向那么复杂
            var forward = missileTrans.forward;
            missileTrans.forward = new Vector3(forward.x, -forward.y, forward.z);

            if (_cfg.CurveData.MissileCurveTraceMode == MissileCurveTraceMode.None)
            {
                _curSpeed *= 1.0f - _cfg.CurveData.JumpMotionData.JumReduce;
            }
            else
            {
                //改变速度
                if (_jumpYSpeed == null)
                {
                    // 使用jumpYSpeed计算衰减，避免帧率不稳导致的误差
                    _jumpYSpeed = ySpeed;
                }
                _jumpYSpeed *= (1.0f - _cfg.CurveData.JumpMotionData.JumpYReduce);
                _jumpYSpeed = Mathf.Abs(_jumpYSpeed.Value); 
                ySpeed = _jumpYSpeed.Value;
            
                xzSpeed *= (1.0f - _cfg.CurveData.JumpMotionData.JumZXReduce);
            }
            
            _jumpNum -= 1;

            return false;
        }
        /// <summary>
        /// 计算单帧最大能旋转的角度
        /// </summary>
        /// <param name="curAngleSpeed"> 当前角度旋转速度 </param>
        /// <param name="enableMaxLimitAngle"> 是否启用 </param>
        /// <param name="maxLimitAngle"> 最大旋转角限制 </param>
        /// <param name="deltatime"> 帧率 </param>
        /// <returns></returns>
        static float _CalcuMaxRotationAngle(float curAngleSpeed, bool enableMaxLimitAngle, float maxLimitAngle, float deltatime)
        {
            float angleSpeed = curAngleSpeed;
            
            // DONE: 转换成单帧旋转角度.
            float angle = angleSpeed * deltatime;
            float limitAngle = maxLimitAngle;
            if (enableMaxLimitAngle && angle > limitAngle)
            {
                angle = limitAngle;
            }
            return angle;
        }
        
        /// <summary>
        /// 计算最新当前速度
        /// </summary>
        /// <param name="curSpeed"> 目前速度 </param>
        /// <param name="accelerate"> 加速度 </param>
        /// <param name="limitSpeed"> 极限速度限制 </param>
        /// <param name="deltaTime"> 帧时长 </param>
        /// <returns></returns>
        static float _CalcuCurSpeed(float curSpeed, float accelerate, float limitSpeed, float deltaTime)
        {
            float speed = curSpeed + deltaTime * accelerate;
            if (limitSpeed >= 0f)
            {
                if (accelerate > 0f)
                {
                    if (speed > limitSpeed)
                    {
                        speed = limitSpeed;
                    }
                }
                else if (accelerate < 0f)
                {
                    if (speed < limitSpeed)
                    {
                        speed = limitSpeed;
                    }
                }
            }
            // 没有极限速度限制, 即为 {0, +∞}
            else
            {
                if (accelerate < 0f)
                {
                    if (speed < 0f)
                    {
                        speed = 0f;
                    }
                }
            }

            return speed;
        }

        /// <summary>
        /// 计算最新当前角速度
        /// </summary>
        /// <param name="curAngleSpeed"> 目前角旋转速度（每秒旋转多少度 °/s） </param>
        /// <param name="angleAccelerate"> 角旋转加速度 </param>
        /// <param name="maxAngleSpeed"> 角旋转速度最大限制 </param>
        /// <param name="deltaTime"> 帧时长 </param>
        /// <returns></returns>
        static float _CalcuCurAngleSpeed(float curAngleSpeed, float angleAccelerate, float maxAngleSpeed, float deltaTime)
        {
            float angleSpeed = curAngleSpeed + angleAccelerate * deltaTime;

            if (maxAngleSpeed > 0f)
            {
                if (angleAccelerate < 0f && angleSpeed < maxAngleSpeed)
                {
                    angleSpeed = maxAngleSpeed;
                }
                else if (angleAccelerate >= 0f && angleSpeed > maxAngleSpeed)
                {
                    angleSpeed = maxAngleSpeed;
                }
            }

            return angleSpeed;
        }

        /// <summary>
        /// 计算导弹抛物线落地时间.
        /// </summary>
        /// <param name="h0"> 导弹离地高度 </param>
        /// <param name="v1"> 导弹初始y轴速度, v1必须大于0 </param>
        /// <param name="a"> 重力加速度 </param>
        /// <param name="targetHeight"> 目标点得高度 </param>
        /// <returns> 落地时间 </returns>
        static float _CalcuParabolaTime(float h0, float v1, float a, float targetHeight)
        {
            float t0 = Math.Abs(v1 / a);
            double h1 = v1 * t0 - 0.5 * a * t0 * t0;
            float h = h0 + (float)h1;
            double result = 0.0d;
            if (targetHeight > h)
            {
                //如果目标点得高度大于抛物线得最高点 使用原点
                LogProxy.Log("子弹得目标点高度 = " + targetHeight + " 已经大于抛物线最大能达到高度 = " + h);
                result = Math.Sqrt(2 * h / a) + t0;
            }
            else
            {
                h -= targetHeight;
                result = Math.Sqrt(2 * h / a) + t0; 
            }
            return (float)result;
        }

        /// <summary>
        /// 包含摆头角度计算新朝向
        /// </summary>
        /// <param name="curForward"> 目前朝向 </param>
        /// <param name="curPos"> 目前位置 </param>
        /// <param name="targetPos"> 目标位置 </param>
        /// <param name="maxAngle"> 限制最大摆头角度 </param>
        /// <returns></returns>
        static Vector3 _CalcuNewForward(Vector3 curForward, Vector3 curPos, Vector3 targetPos, float maxAngle)
        {
            Vector3 targetForward = (targetPos - curPos).normalized;
            if (targetForward == curForward)
            {
                return targetForward;
            }
            
            // DONE: 算两向量的z轴
            var zAxis = Vector3.Cross(curForward, targetForward).normalized;

            // DONE: 计算两向量的夹角.
            float offsetAngle = Vector3.SignedAngle(curForward, targetForward, zAxis);
            
            // DONE: 摆头角度不能超过限制最大摆头角度.
            if (Math.Abs(offsetAngle) > maxAngle)
            {
                offsetAngle = (offsetAngle > 0 ? 1 : -1) * maxAngle;
            }

            // DONE: 绕Z轴旋转 (弧度转成的角度).
            Vector3 newForward = (Quaternion.AngleAxis(offsetAngle, zAxis) * curForward).normalized;
            return newForward;
        }
    }
}