using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class MissileMotionBezier : MissileMotionBase
    {
        private bool _isMiss;
        private Vector3 _start;
        private Vector3 _middle1;
        private Vector3 _middle2;
        private Vector3 _end;
        private const int _pointNumber = 30;
        private float _pointGap;
        private MissileBezierPoint[] _points = new MissileBezierPoint[_pointNumber + 1];
        private int _cursor;
        private float _distance;
        private bool _isComplete;
        private bool _isAxisZ;
        private Vector3 _forward;
        private float _forwardAxis;
        
        protected override void _OnStart()
        {
            using (ProfilerDefine.MissileMotionBezierOnStartPMarker.Auto())
            {
                _InitLockPoint();
                _curSpeed = _cfg.InitialSpeed;
                _pointGap = 1f / _pointNumber;
                _start = _model.position;
                Transform transform = _model.actor.GetDummy();
                _middle1 = transform.TransformPoint(_cfg.BezierData.ControlOffset1);
                _middle2 = transform.TransformPoint(_cfg.BezierData.ControlOffset2);
                if (_cfg.BezierData.EndType == MissileBezierEndType.Target)
                {
                    Actor skillTarget = _targetActor;
                    if (skillTarget == null)
                    {
                        _isMiss = true;
                    }
                    else
                    {
                        _isMiss = false;
                    }
                }
                else
                {
                    _isMiss = false;
                }

                _isAxisZ = Mathf.Abs(_end.z - _start.z) > Mathf.Abs(_end.x - _start.x);
                float distance = 0;
                for (int i = 0; i <= _pointNumber; i++)
                {
                    MissileBezierPoint point = ObjectPoolUtility.MissileBezierPoint.Get();
                    if (i == 0)
                    {
                        point.position = _start;
                        point.length = 0;
                    }
                    else
                    {
                        point.position = _Bezier(i * _pointGap);
                        MissileBezierPoint beforePoint = _points[i - 1];
                        point.length = _isAxisZ
                            ? Mathf.Abs(point.position.z - beforePoint.position.z)
                            : Mathf.Abs(point.position.x - beforePoint.position.x);
                        distance += point.length;
                    }

                    point.distance = distance;
                    _points[i] = point;
                }

                _cursor = 1;
                _distance = 0;
                _isComplete = false;
            }
        }

        protected override void _OnUpdate(float deltaTime)
        {
            using (ProfilerDefine.MissileMotionBezierOnUpdatePMarker.Auto())
            {

                if (_isMiss)
                {
                    Vector3 deltaPos = _curSpeed * deltaTime * _model.forward;
                    Vector3 targetPos = _model.position + deltaPos;
                    _model.SetPosition(targetPos);
                }
                else
                {
                    if (_cursor <= _pointNumber)
                    {
                        if (_cursor == 1)
                        {
                            _forward = (_points[_cursor].position - _points[_cursor - 1].position).normalized;
                            _forwardAxis = _isAxisZ ? _forward.z : _forward.x;
                        }

                        _distance += Mathf.Abs(_curSpeed * deltaTime * _forwardAxis);
                        _isComplete = true;
                        for (int i = _cursor; i <= _pointNumber; i++)
                        {
                            MissileBezierPoint point = _points[i];
                            if (point.distance > _distance)
                            {
                                if (_cursor != i)
                                {
                                    _cursor = i;
                                    _forward = (_points[_cursor].position - _points[_cursor - 1].position).normalized;
                                    _forwardAxis = _isAxisZ ? _forward.z : _forward.x;
                                    _model.SetForward(_forward, false);
                                }

                                Vector3 targetPos = _points[_cursor].position - (point.distance - _distance) * _forward;
                                _model.SetPosition(targetPos);
                                _isComplete = false;
                                break;
                            }
                        }

                        if (_isComplete)
                        {
                            _forward = (_points[_cursor].position - _points[_cursor - 1].position).normalized;
                            _cursor = _pointNumber + 1;
                            _model.SetForward(_forward, false);
                            _model.SetPosition(_end);
                        }
                    }
                }
            }
        }

        private void _InitLockPoint()
        {
            Transform transform = _model.actor.GetDummy();
            _end = transform.TransformPoint(_cfg.BezierData.EndOffset);

            if (_cfg.BezierData.EndType == MissileBezierEndType.Target && _targetActor != null)
            {
                var tsf = BattleUtil.GetLockPoint(_targetActor, cfg.LockPointType);
                if (tsf != null)
                {
                    // DONE: 获取目标的受击骨骼点 + 配置的命中点偏移.
                    _end = tsf.position + _cfg.BezierData.HitPointOffset;
                }
            }
        }
        public override bool IsComplete()
        {
            return _isComplete;
        }
        
        protected override void _OnStop()
        {
            for (int i = 0; i <= _pointNumber; i++)
            {
                MissileBezierPoint missileBezierPoint = _points[i];
                ObjectPoolUtility.MissileBezierPoint.Release(missileBezierPoint);
                _points[i] = null;
            }
        }
        
        /// <summary>
        /// 获得三阶曲线上的点
        /// </summary>
        /// <param name="t"></param>
        /// <returns></returns>
        private Vector3 _Bezier(float t)
        {
            Vector3 aa = _start + (_middle1 - _start) * t;
            Vector3 bb = _middle1 + (_middle2 - _middle1) * t;
            Vector3 cc = _middle2 + (_end - _middle2) * t;

            Vector3 aaa = aa + (bb - aa) * t;
            Vector3 bbb = bb + (cc - bb) * t;
            return aaa + (bbb - aaa) * t;
        }
    }
}