using System;
using UnityEngine;

namespace X3Battle
{
    public class PreviewMissileMotionCurve : PreviewMissileMotionBase
    {
        private float _curSpeed; // 实时速度
        private float _curAngleSpeed; // 实时角速度
        
        private Vector3 _startPos;  // 起始位置
        private Vector3 _startForward; // 起始朝向
        
        private bool _bIsComplete; // 标记是否完成.
        
        #region 导弹记录发射时追踪的目标.

        private Vector3 _targetPos; // 目标位置.
        //private Actor _target; // 初始追踪的目标
        private bool _bIsMissTarget; // 是否丢失目标.
        //private Transform _targetHitTrans; // 目标Hit点的Transform 

        #endregion
        
        #region 抛物线模式用到的私有变量
        
        private float _startHeight; // 起始子弹高度.
        private float _parabolaTime; // 抛物线运动时间
        private float _remainParabolaTime; // 抛物线还剩多久运行时间
        private Vector3 _horizontalForward; // 抛物线的水平方向.
        private float _ySpeed; // 抛物线初始向上的速度.
        private float _xzSpeed; // 抛物线水平方向上的速度.

        #endregion
        
        protected override void _OnStart()
        {
            _bIsComplete = false;
            _bIsMissTarget = false; 
            _startPos = startPos;
            _startForward = startForward;
            _curSpeed = _cfg.MotionData.InitialSpeed;
            _curAngleSpeed = _cfg.MotionData.CurveData.AngleSpeed;
            _remainParabolaTime = 0f;
            _missile.transform.SetLocalPositionAndRotation(startPos, _missile.transform.rotation);
            switch (_cfg.MotionData.CurveData.MissileCurveTraceMode)
            {
                case MissileCurveTraceMode.Target:
                    _targetPos = targetPosition;
                    break;
                case MissileCurveTraceMode.OriginPosition:
                    _targetPos = targetPosition + _cfg.MotionData.CurveData.HitPointOffset;
                    break;
                case MissileCurveTraceMode.Parabola:
                    _horizontalForward = new Vector3(_startForward.x, 0f, _startForward.z);
                    _targetPos = _startPos + _horizontalForward * _cfg.MotionData.CurveData.ParabolaDefaultDistance;
                    _startHeight = _missile.transform.localPosition.y;
                    _parabolaTime = _CalcuParabolaTime(_startHeight, _cfg.MotionData.CurveData.ParabolaYSpeed, Math.Abs(_cfg.MotionData.CurveData.GravitationalAcceleration));
                    _remainParabolaTime = _parabolaTime;
                    _ySpeed = _cfg.MotionData.CurveData.ParabolaYSpeed;
                    _xzSpeed = (_targetPos - _startPos).magnitude / _parabolaTime;
                    break;
            }
        }

        protected override void _OnStop()
        {
        }

        protected override void _OnUpdate(float deltaTime)
        {
            if (_bIsComplete)
            {
                return;
            }
            
            //曲线往回走直接return
            if (deltaTime < 0)
            {
                return;
            }
            
            Vector3 curPos = _missile.transform.localPosition;
            Vector3 curForward = _missile.transform.forward;

            Vector3 newPos = curPos;
            Vector3 newForward = curForward;
            
            // DONE: 考虑极限距离的判断.
            if (_cfg.MotionData.CurveData.EnableLimitMaxDistance && (_startPos - curPos).sqrMagnitude > _cfg.MotionData.CurveData.LimitMaxDistance * _cfg.MotionData.CurveData.LimitMaxDistance)
            {
                _bIsComplete = true;
                return;
            }
            
            // DONE: 计算最新当前速度.
            _curSpeed = _CalcuCurSpeed(_curSpeed, _cfg.MotionData.Accelerate, _cfg.MotionData.MaxSpeed, deltaTime);
            
            Vector3 offsetPos = Vector3.zero;
            switch (_cfg.MotionData.CurveData.MissileCurveTraceMode)
            {
                case MissileCurveTraceMode.None:
                {
                    // DONE: 仅计算轴向加速度.
                    // s = v * t + 0.5 * a * t^2.
                    offsetPos = newForward * (_curSpeed * deltaTime) + Quaternion.LookRotation(newForward) * (Vector3)_cfg.MotionData.CurveData.AxialAcceleration * (0.5f * deltaTime * deltaTime);
                    break;
                }
                case MissileCurveTraceMode.Target:
                {
                    // DONE: 获取目标位置
                    offsetPos = _CalcuTracePositionOffset(curPos, curForward, _targetPos, deltaTime);    
                    break;
                }
                case MissileCurveTraceMode.OriginPosition:
                {
                    offsetPos = _CalcuTracePositionOffset(curPos, curForward, _targetPos, deltaTime);
                    break;
                }
                case MissileCurveTraceMode.Parabola:
                {
                    // 横向位移.
                    Vector3 horizontalOffset = _horizontalForward * _xzSpeed * deltaTime; 
                    
                    // 纵向位移.
                    // 更新y轴速度 
                    _ySpeed -= _cfg.MotionData.CurveData.GravitationalAcceleration * deltaTime;
                    Vector3 verticalOffset = Vector3.up * _ySpeed * deltaTime;
                    offsetPos = horizontalOffset + verticalOffset;
                    break;
                }
                default:
                    throw new ArgumentOutOfRangeException();
            }

            newPos += offsetPos;
            newForward = offsetPos.normalized;
            
            // DONE: 当该次位移超过目标点时.
            if (newPos.sqrMagnitude >= targetPosition.sqrMagnitude)
            {
                _bIsComplete = true;
            }
            
            // DONE: 设置导弹当前位置.
            _missile.transform.SetLocalPositionAndRotation(newPos, _missile.transform.localRotation);
            // DONE: 设置导弹当前朝向.
            if (newForward != Vector3.zero)
            {
                _missile.transform.forward = newForward;
            }
        }

        public override bool IsComplete()
        {
            return _bIsComplete;
        }

        private Vector3 _CalcuTracePositionOffset(Vector3 curPos, Vector3 curForward, Vector3 targetPos, float deltaTime)
        {
            Vector3 offsetPos = Vector3.zero;

            // DONE: 计算最新的角速度.
            _curAngleSpeed = _CalcuCurAngleSpeed(_curAngleSpeed, _cfg.MotionData.CurveData.AngleSpeed, _cfg.MotionData.CurveData.AngleLimitSpeed, deltaTime);
                    
            // DONE: 计算单帧最大旋转角度.
            float maxAngle = _CalcuMaxRotationAngle(_curAngleSpeed, _cfg.MotionData.CurveData.EnableLimitMaxAngle, _cfg.MotionData.CurveData.LimitMaxAngle, deltaTime);
                    
            // DONE: 计算包含旋转角的最新朝向.
            Vector3 newForward = _CalcuNewForward(curForward, curPos, targetPos, maxAngle);
                    
            // DONE: 朝新朝向位移.
            offsetPos = _curSpeed * newForward * deltaTime;

            return offsetPos;
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
            float limitAngle = maxLimitAngle * deltatime;
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
        /// <param name="maxSpeed"> 最大速度限制 </param>
        /// <param name="deltaTime"> 帧时长 </param>
        /// <returns></returns>
        static float _CalcuCurSpeed(float curSpeed, float accelerate, float maxSpeed, float deltaTime)
        {
            float speed = curSpeed + deltaTime * accelerate;
            if (maxSpeed > 0 && speed > maxSpeed)
            {
                speed = maxSpeed;
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
        /// <returns> 落地时间 </returns>
        static float _CalcuParabolaTime(float h0, float v1, float a)
        {
            float t0 = Math.Abs(v1 / a);
            double h1 = v1 * t0 - 0.5 * a * t0 * t0;
            float h = h0 + (float)h1;
            double result = Math.Sqrt(2 * h / a) + t0;
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