using UnityEngine;

namespace X3Battle
{
    public class ShapeBox : IReset
    {
        private Vector3 _startPos;
        private Vector3 _startEulerAngle;

        private Vector3 _curPos;
        private Vector3 _curEulerAngle;

        private bool _bIsFollowPos;
        private bool _bIsFollowRot;

        private ShapeBoxInfo _shapeBoxInfo;

        public ShapeBoxInfo shapeBoxInfo
        {
            get => _shapeBoxInfo;
        }

        private VirtualTrans? _trans;

        private Vector3 _offsetPos;
        private Vector3 _offsetEuler;

        private Vector3 _lastPrevPos;
        private BoundingShape _boundingShape = new BoundingShape();
        private bool _bSetBounding = false;

        private Vector3? _terminalPos = null;
        private Vector3? _terminalEuler = null;

        private bool _isAutoDestroyShape = true;

        public void Init(ShapeBoxInfo shapeBoxInfo, VirtualTrans? trans, Vector3? offsetPos = null, Vector3? offsetEuler = null, Vector3? terminalPos = null, Vector3? terminalEuler = null, bool isAutoDestroyShape = true)
        {
            _terminalPos = terminalPos;
            _terminalEuler = terminalEuler;
            
            _shapeBoxInfo = shapeBoxInfo;
            _trans = trans;

            _offsetPos = offsetPos ?? shapeBoxInfo.OffsetPos;
            _offsetEuler = offsetEuler ?? shapeBoxInfo.OffsetEuler;

            // DONE: 初始化当前位置和旋转并记录.
            _curPos = _startPos = _lastPrevPos = _CalcPosition();
            _curEulerAngle = _startEulerAngle = _CalcRotation();

            _isAutoDestroyShape = isAutoDestroyShape;
            
            #region 是否跟随变量初始化

            switch (_shapeBoxInfo.ShapeBoxFollowMode)
            {
                case ShapeBoxFollowMode.PositionAndRotation:
                    _bIsFollowPos = true;
                    _bIsFollowRot = true;
                    break;
                case ShapeBoxFollowMode.None:
                    _bIsFollowPos = false;
                    _bIsFollowRot = false;
                    break;
                case ShapeBoxFollowMode.Position:
                    _bIsFollowPos = true;
                    _bIsFollowRot = false;
                    break;
                case ShapeBoxFollowMode.Rotation:
                    _bIsFollowPos = false;
                    _bIsFollowRot = true;
                    break;
            }

            #endregion
        }

        public void Reset()
        {
            if (_isAutoDestroyShape)
            {
                
            }
            _shapeBoxInfo = null;
            _trans = null;
            _bSetBounding = false;
        }
        
        // 计算位置
        private Vector3 _CalcPosition()
        {
            if (_terminalPos != null)
            {
                return _terminalPos.Value;
            }
            return _trans.Value.GetWorldPos(_offsetPos);
        }

        // 计算旋转
        private Vector3 _CalcRotation()
        {
            if (_terminalEuler != null)
            {
                return _terminalEuler.Value;
            }
            return _trans.Value.GetWorldEuler(_offsetEuler);
        }

        // 是否跟随位置
        public bool IsFollowPos()
        {
            return _bIsFollowPos;
        }

        // 是否跟随旋转
        public bool IsFollowRotate()
        {
            return _bIsFollowRot;
        }
        
        public void Update()
        {
            _lastPrevPos = _curPos;
            
            if (_bIsFollowPos)
            {
                // DONE: 基于transform局部坐标系计算最终位置.
                _curPos = _CalcPosition();
            }

            if (_bIsFollowRot)
            {
                // DONE: 基于transform局部坐标系计算最终角度.
                _curEulerAngle = _CalcRotation();
            }
        }

        public Vector3 GetCurWorldEuler()
        {
            return _curEulerAngle;
        }

        public Vector3 GetCurWorldPos()
        {
            return _curPos;
        }

        public Vector3 GetPrevWorldPos()
        {
            return _lastPrevPos;
        }

        public BoundingShape GetBoundingShape()
        {
            if (_bSetBounding)
            {
                return _boundingShape;
            }
            
            var shapeType = _shapeBoxInfo.ShapeInfo.ShapeType;
            float length = 0f, width = 0f, height = 0f, radius = 0f, angle = 0f;
            switch (shapeType)
            {
                case ShapeType.Capsule:
                    radius = _shapeBoxInfo.ShapeInfo.CapsuleShapeInfo.Radius;
                    height = _shapeBoxInfo.ShapeInfo.CapsuleShapeInfo.Height;
                    break;
                case ShapeType.Cube:
                    length = _shapeBoxInfo.ShapeInfo.CubeShapeInfo.Length;
                    width = _shapeBoxInfo.ShapeInfo.CubeShapeInfo.Width;
                    height = _shapeBoxInfo.ShapeInfo.CubeShapeInfo.Height;
                    break;
                case ShapeType.FanColumn:
                    radius = _shapeBoxInfo.ShapeInfo.FanColumnShapeInfo.Radius;
                    angle = _shapeBoxInfo.ShapeInfo.FanColumnShapeInfo.Angle;
                    height = _shapeBoxInfo.ShapeInfo.FanColumnShapeInfo.Height;
                    break;
                case ShapeType.Sphere:
                    radius = _shapeBoxInfo.ShapeInfo.SphereShapeInfo.Radius;
                    break;
                case ShapeType.Ray:
                    length = _shapeBoxInfo.ShapeInfo.RayShapeInfo.Length;
                    if (length < 0f)
                    {
                        length = float.MaxValue;
                    }
                    break;
                case ShapeType.RingFanColumn:
                    length = _shapeBoxInfo.ShapeInfo.RingShapeInfo.InnerRadius;
                    radius = _shapeBoxInfo.ShapeInfo.RingShapeInfo.OuterRadius;
                    angle = _shapeBoxInfo.ShapeInfo.RingShapeInfo.Angle;
                    height = _shapeBoxInfo.ShapeInfo.RingShapeInfo.Height;
                    break;
            }
            
            _bSetBounding = true;
            
            _boundingShape.ShapeType = _shapeBoxInfo.ShapeInfo.ShapeType;
            _boundingShape.Length = length;
            _boundingShape.Width = width;
            _boundingShape.Height = height;
            _boundingShape.Radius = radius;
            _boundingShape.Angle = angle;
            
            if (!X3Physics.CheckShapeValid(_boundingShape))
            {
                PapeGames.X3.LogProxy.LogError($"请联系【策划】, 形状配置错误出自{_shapeBoxInfo.ShapeInfo.DebugInfo}");
            }

            return _boundingShape;
        }
    }
}