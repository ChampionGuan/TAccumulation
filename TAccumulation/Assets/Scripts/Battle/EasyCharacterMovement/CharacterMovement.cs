using System;
using System.Collections.Generic;
using Cinemachine.Utility;
using CollisionQuery;
using PapeGames.X3;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Profiling;
using X3Battle;

namespace EasyCharacterMovement
{

    // [RequireComponent(typeof(Rigidbody), typeof(CapsuleCollider))]
    [RequireComponent(typeof(CqCapsuleCollider), typeof(CqRigidActor))]
    public partial class CharacterMovement : MonoBehaviour
    {
        #region CONSTANTS
        private const float kKindaSmallNumber = 0.0001f;
        private const float kHemisphereLimit = 0.01f;
        private const float kSweepEdgeRejectDistance = 0.0015f;

        private const float kMinGroundDistance = 0.0005f;
        private const float kMaxGroundDistance = 0.0015f;
        private const float kAvgGroundDistance = (kMinGroundDistance + kMaxGroundDistance) * 0.5f;

        private const float kMinWalkableSlopeLimit = 1.000000f; // cos(0)   
        private const float kMaxWalkableSlopeLimit = 0.017452f; // cos(89)

        private const float kPenetrationOffset = 0.00125f;

        private const float kContactOffset = 0.01f;
        private const float kSmallContactOffset = 0.001f;
        #endregion
        public float slideRatio = 0.5f;
        // transform info
        private Vector3 _updatedPosition;
        private float _updatedPositionY;
        private Quaternion _updatedRotation;
        private Vector3 _characterUp;
        private Vector3 _characterRight;
        private Vector3 _characterForward;

        // 胶囊体朝向
        public Vector3 capsuleUp
        {
            get
            {
                if (direction == Direction.Y)
                    return  _characterUp;
                else if (direction == Direction.X)
                    return _characterRight ;
                else
                    return _characterForward;
            }
        }

        public Vector3 worldCenter => transform.position + transform.rotation * _capsuleCenter; // 胶囊体的中心
        public Quaternion updatedRotation => _updatedRotation;
        
        // capsule info
        private float _radius;
        private float _height;
        private Direction _direction;
        private Vector3 _capsuleCenter;
        private Vector3 _capsuleTopCenter;
        private Vector3 _capsuleBottomCenter;
        private Vector3 _transformedCapsuleCenter;
        private Vector3 _transformedCapsuleTopCenter;
        private Vector3 _transformedCapsuleBottomCenter;

        public float radius { get => _radius; set => SetDimensions(value, _height, _capsuleCenter, _direction); }
        public float height { get => _height; set => SetDimensions(_radius, value, _capsuleCenter, _direction); }
        public Vector3 center { get => _capsuleCenter; set => SetDimensions(_radius, _height, value, _direction); }
        public Direction direction { get => _direction; set => SetDimensions(_radius, _height, _capsuleCenter, value); }
        // cc胶囊体底部相对于角色root点的偏移
        public Vector3 ccOffset
        {
            get
            {
                if (direction == Direction.Y)
                    return _capsuleBottomCenter - radius * _characterUp;
                else
                    return center - _characterUp * radius;
            }
            }

        // 移动的参数控制
        [SerializeField] private float _slopeLimit; // 爬坡角度限制
        private float _minSlopeLimit;
        [SerializeField] private float _stepOffset; // 步高限制 >0
        [SerializeField] private float _perchOffset; // 边缘悬停，距离限制 >0
        [SerializeField] private float _perchAdditionalHeight; // 悬停高度，相对与地面
        [SerializeField] private Advanced _advanced;
        [SerializeField] private bool _isUseSlide = true;
        [SerializeField] private float _yLerpTime = 0.1f;
        
        public bool allowPushCharacters { set=> _advanced.allowPushCharacters = value;}
        public int maxDepenetrationIterations { set=> _advanced.maxDepenetrationIterations = value;}

        /// <summary>
        /// The maximum angle (in degrees) for a walkable slope.
        /// </summary>
        public float slopeLimit
        {
            get => _slopeLimit;
            set
            {
                _slopeLimit = Mathf.Clamp(value, 0.0f, 89.0f);
                // Add 0.01f to avoid numerical precision errors
                _minSlopeLimit = Mathf.Cos((_slopeLimit + 0.01f) * Mathf.Deg2Rad);
            }
        }
        
        public float stepOffset { get => _stepOffset; set => _stepOffset = value; }

        [SerializeField] private Vector3 _velocity;
        [SerializeField] private Vector3 _bePushedVelocity; // 推动力
        [SerializeField] private Vector3 _beResolveVec; // 被挤出的向量
        [SerializeField] private float _pushForceScale = 1.0f; // 推动力缩放
        public float pushForceScale { get => _pushForceScale; set => _pushForceScale = value;}
        public float yLerpTime  {  get => _yLerpTime;  set => _yLerpTime = value; }
        public Vector3 velocity { get => _velocity; set => _velocity = value; }
        public Vector3 bePushedVelocity { get => _bePushedVelocity; set => _bePushedVelocity = value; }
        public Vector3 beResolveVec { get => _beResolveVec; set => _beResolveVec = value; }
        
        private LayerMask _collisionLayers = 1;
        private QueryTriggerInteraction _triggerInteraction = QueryTriggerInteraction.Ignore;
        private CqCapsuleCollider _capsuleCollider;
        private CqRigidActor _rigidActor;
        
        public CqCapsuleCollider collider => _capsuleCollider;
        public CqRigidActor rigidActor => _rigidActor;
        
        private static Comparison<CqCollider> _massCompare = new OverlapColliderMassCompare().Compare;

        // 移动模式的切换控制逻辑控制
        private MovementModeCtrl _modeCtrl;
        public MovementModeCtrl ModeCtrl => _modeCtrl;
        
        #region CALLBACKS

        /// <summary>
        /// Let you define if the character should collide with given collider.
        /// Return true to filter (ignore) collider, false otherwise.
        /// </summary>
        public ColliderFilterCallback colliderFilterCallback { get; set; }

        /// <summary>
        /// Let you define the character behavior when collides with collider.
        /// </summary>
        public CollisionBehaviorCallback collisionBehaviorCallback { get; set; }
        #endregion

        #region EVENTS
        /// <summary>
        /// Event triggered when a character finds ground (walkable or non-walkable) as a result of a downcast sweep (eg: FindGround method).
        /// </summary>
        public event FoundGroundEventHandler FoundGround;
        
        public event FinallySetWorldPosEventHandler OnSetWorldPos;
        #endregion

        // 地面检测处理
        private bool _hasLanded;
        private FindGroundResult _foundGround;
        private FindGroundResult _currentGround;
        
        public bool isOnWalkableGround => _currentGround.isWalkableGround;
        
        /// <summary>
        /// Is the character on ground， ground not walkable
        /// </summary>
        public bool wasOnGround { get; private set; }
        public bool isOnGround => _currentGround.hitGround;

        /// <summary>
        /// The current ground impact point.
        /// </summary>
        public Vector3 groundPoint => _currentGround.point;

        public Vector3 groundNormal => _currentGround.normal;

        public CollisionFlags collisionFlags { get; private set; }

        // 优化
        private int _preMoveFrameNum = 0; // 上一次发生移动时的帧号
        private const int kMaxCollisionCount = 8;
        private const int kMaxOverlapCount = 8;
        private int _collisionCount;
        private readonly HashSet<CqCollider> _ignoredColliders = new HashSet<CqCollider>();
        private readonly CqRaycastHit[] _hits = new CqRaycastHit[kMaxCollisionCount];
        private readonly CqRaycastHit[] _rayHits = new CqRaycastHit[kMaxCollisionCount];
        private readonly CqCollider[] _overlaps = new CqCollider[kMaxOverlapCount];
        private readonly CollisionResult[] _collisionResults = new CollisionResult[kMaxCollisionCount];
        private CqRaycastHit[] _hitInfos = new CqRaycastHit[100];

        private void Reset()
        {
            SetDefaultValue();
        }
        
        private void OnValidate()
        {
            SetDimensions(_radius, _height, _capsuleCenter, _direction);
            slopeLimit = Mathf.Max(0, _slopeLimit);
            _stepOffset = Mathf.Max(0, _stepOffset);
            _perchOffset = Mathf.Max(0, _perchOffset);
            _perchAdditionalHeight = Mathf.Max(0, _perchAdditionalHeight);
            _advanced.OnValidate();
        }

        private void Awake()
        {
            InitCollisionMask();
            CacheComponents();
            SetDefaultValue();
            SetDimensions(_radius, _height, _capsuleCenter, _direction);
        }

        private void OnEnable()
        {
            _updatedPosition = transform.position;
            _updatedRotation = transform.rotation;
        }

        public void OnLateUpdate(float deltaTime)
        {
            _modeCtrl.Update(deltaTime);
            if (_preMoveFrameNum != Time.frameCount)
            {
                // 保底措施 如果当前帧没有移动过，则进行一次原地移动，完整物理模拟
                _Move(Vector3.zero, deltaTime);
            }
        }

        public void Move(Vector3 newVelocity, float deltaTime)
        {
            using (ProfilerDefine.X3CharacterMovementMoveFunPMarker.Auto())
            {
                if (_preMoveFrameNum == Time.frameCount)
                {
                    // 当前帧的非第一次移动使用简单的物理模拟
                    SimpleMove(newVelocity, deltaTime);
                }
                else
                {
                    // 当前帧的第一次移动使用完整的物理模拟
                    _Move(newVelocity, deltaTime);
                }
                _preMoveFrameNum = Time.frameCount;
            }
        }

        public void SimpleMove(Vector3 newVelocity, float deltaTime)
        {
            using (ProfilerDefine.CharacterMovementSimpleMovePMarker.Auto())
            {
                Vector3 originalPos = transform.position + transform.rotation * ccOffset;

                UpdateCachedFields();
                ClearCollisionResults();
                UpdateVelocity(newVelocity, deltaTime);
                _velocity = _modeCtrl.Move(deltaTime, _velocity);

                using (ProfilerDefine.CharacterMovementSimplePerformMovementPMarker.Auto())
                {
                    SimplePerformMovement(deltaTime);
                }
                SetPositionAndRotation(originalPos, _updatedPosition, _updatedRotation, deltaTime);
            }
        }

        /// <summary>
        /// Moves the character along the given velocity vector.
        /// This performs collision constrained movement resolving any collisions / overlaps found during this movement.
        /// </summary>
        /// <param name="newVelocity">The updated velocity for current frame. It is typically a combination of vertical motion due to gravity and lateral motion when your character is moving.</param>
        /// <param name="deltaTime">The simulation deltaTime. If not assigned, it defaults to Time.deltaTime.</param>
        /// <returns>Return CollisionFlags. It indicates the direction of a collision: None, Sides, Above, and Below.</returns>
        private CollisionFlags _Move(Vector3 newVelocity, float deltaTime)
        {
            using (ProfilerDefine.CharacterMovementMovePMarker.Auto())
            {
                Vector3 originalPos = transform.position + transform.rotation * ccOffset;

                UpdateCachedFields();
                ClearCollisionResults();
                UpdateVelocity(newVelocity, deltaTime);
                _velocity = _modeCtrl.Move(deltaTime, _velocity);

                using (ProfilerDefine.CharacterMovementResolveOverlapsPMarker.Auto())
                {
                    ResolveOverlaps();
                }

                using (ProfilerDefine.CharacterMovementPerformMovementPMarker.Auto())
                {
                    PerformMovement(deltaTime);
                }

                using (ProfilerDefine.CharacterMovementResolveDynamicCollisionsPMarker.Auto())
                {
                    ResolveDynamicCollisions();
                }

                bool foundGround = isOnWalkableGround || _hasLanded;
                bool useHighMap = _advanced.isUseGroundHighMap;
                if (foundGround || useHighMap)
                {
                    FindGround(_updatedPosition, out _foundGround);
                }
                
                UpdateCurrentGround(ref _foundGround);
                
                AdjustGroundHeight();

                SetPositionAndRotation(originalPos, _updatedPosition, _updatedRotation, deltaTime);
                
                return collisionFlags;
            }
        }

        /// <summary>
        /// Resolves any character's volume overlaps against specified colliders.
        /// </summary>
        private void ResolveOverlaps()
        {
            for (int i = 0; i < _advanced.maxDepenetrationIterations; i++)
            {
                Vector3 top = _updatedPosition + _transformedCapsuleTopCenter;
                Vector3 bottom = _updatedPosition + _transformedCapsuleBottomCenter;

                // int overlapCount = Physics.OverlapCapsuleNonAlloc(bottom, top, _radius, _overlaps, _collisionLayers,
                //     _triggerInteraction);
                Array.Clear(_overlaps, 0, _overlaps.Length);
                int overlapCount = X3Physics.Collision.CapsuleOverlap(new CqCapsule(bottom, top, _radius), _overlaps, _collisionLayers);

                if (overlapCount == 0)
                    break;
                // 挤出算法调整，无cc的Collider认定为质量无限大（静态collider）
                // 第一步：优先与质量最大的重叠Collider，进行分离
                // 第二步：记录上一次的分离方向，和实际分离距离。 一旦当前的分离方向和上一次的分离方向成钝角，方向相反时。
                // 判定上一次的分离距离是否为0，若分离距离为0，则证明当前方向已不可能移动。但是又不能穿透
                // 那么只能让重叠的collider被挤出（非静态）,如果是静态的，则保持不动不在挤出
                if (overlapCount > 1)
                    Array.Sort(_overlaps, _massCompare);
                Vector3 preRecoverDirection = Vector3.zero;
                
                for (int j = 0; j < overlapCount; j++)
                {
                    var overlappedCollider = _overlaps[j];

                    if (ShouldFilter(overlappedCollider))
                        continue;

                    var otherRigidActor = overlappedCollider.attachedRigidActor;
                    if (otherRigidActor)
                    {
                        // 质量轻的无法挤开质量重的
                        if (otherRigidActor.mass < _rigidActor.mass)
                            continue;
                    }
                    
                    if (ComputeMTD(_updatedPosition, _updatedRotation, overlappedCollider, overlappedCollider.transform,
                            out Vector3 recoverDirection, out float recoverDistance))
                    {
                        // 项目定制，挤出行为，只表现在水平方向上
                        var recoverVec = _updatedPosition + recoverDirection * recoverDistance;
                        var horizontalRecover = recoverVec.ProjectOntoPlane(Vector3.up);
                        // 计算相对于角色的水平位移 方向，距离
                        horizontalRecover.y = _updatedPosition.y;
                        recoverDirection = (horizontalRecover - _updatedPosition).normalized;
                        recoverDistance = (horizontalRecover - _updatedPosition).magnitude;
                        
                        // 上算法的第二步
                        if (Vector3.Dot(preRecoverDirection, recoverDirection) < 0)
                        {
                            var otherCC = GetCharacterMovement(overlappedCollider);
                            if (otherCC != null)
                                otherCC._beResolveVec = -recoverDirection * recoverDistance * (1 + kContactOffset);
                            continue;
                        }

                        top = _updatedPosition + _updatedRotation * _transformedCapsuleTopCenter;
                        bottom = _updatedPosition + _updatedRotation * _transformedCapsuleTopCenter;
                        
                        // 保证分离的过程中，不会穿透其它的collider
                        int hitNum = X3Physics.Collision.CapsuleCast(new CqCapsule(bottom, top, _radius-kSmallContactOffset),recoverDirection, recoverDistance, _hitInfos, _collisionLayers);
                        if (hitNum > 0)
                        {
                            float minDis = recoverDistance;
                            for (int k = 0; k < hitNum; k++)
                            {
                                var hitCollider = _hitInfos[k].Collider;
                                if (ShouldFilter(_hitInfos[k].Collider))
                                    continue;
                                if (hitCollider == overlappedCollider)
                                    continue;
                                // 允许穿透同一个角色上的其它Collider
                                if (otherRigidActor != null && hitCollider.attachedRigidActor == otherRigidActor)
                                    continue;
                                if (_hitInfos[k].distance < minDis)
                                {
                                    minDis = _hitInfos[k].distance;
                                }
                            }

                            if (minDis < recoverDistance)
                            {
                                recoverDistance = minDis;
                            }
                        }

                        HitLocation hitLocation = ComputeHitLocation(recoverDirection);
                        bool isWalkable = IsWalkable(overlappedCollider, recoverDirection);
                        Vector3 impactNormal = ComputeBlockingNormal(recoverDirection, isWalkable);
                        _updatedPosition += impactNormal * (recoverDistance + kPenetrationOffset);

                        if (_collisionCount < kMaxCollisionCount)
                        {
                            Vector3 point;
                            if (hitLocation == HitLocation.Above)
                                point = _updatedPosition + _transformedCapsuleTopCenter - recoverDirection * _radius;
                            else if (hitLocation == HitLocation.Below)
                                point = _updatedPosition + _transformedCapsuleBottomCenter - recoverDirection * _radius;
                            else
                                point = _updatedPosition + _transformedCapsuleCenter - recoverDirection * _radius;
                            var rigidActor = overlappedCollider.attachedRigidActor;
                            var haveRigidActor = rigidActor != null;
                            var overlapCC = GetCharacterMovement(overlappedCollider);
                            CollisionResult collisionResult = new CollisionResult
                            {
                                startPenetrating = true,
                                hitLocation = hitLocation,
                                isWalkable = isWalkable,

                                position = _updatedPosition,
                                velocity = _velocity,
                                otherVelocity = overlapCC ? overlapCC.velocity : Vector3.zero,

                                point = point,
                                normal = impactNormal,
                                surfaceNormal = impactNormal,

                                collider = overlappedCollider,
                                rigidActor = rigidActor,
                                transform = haveRigidActor ? rigidActor.transform : overlappedCollider.transform,
                                isRigidbodyCollider = haveRigidActor && rigidActor.transform == overlappedCollider.transform,
                                characterMovement = overlapCC,
                            };

                            AddCollisionResult(ref collisionResult);
                        }

                        preRecoverDirection = recoverDirection;
                    }
                }
            }
        }

        /// <summary>
        /// Performs collision constrained movement.
        /// This refers to the process of smoothly sliding a moving entity along any obstacles encountered.
        /// Updates _probingPosition.
        /// </summary>
        private void PerformMovement(float deltaTime)
        {
            // If grounded, discard velocity vertical component
            if (isOnWalkableGround && !(_modeCtrl.curMode.canUpDown))
                _velocity = _velocity.projectedOnPlane(_characterUp);

            // Compute displacement
            Vector3 displacement = _velocity * deltaTime;
            
            if (isOnWalkableGround)
            {
                displacement = displacement.tangentTo(groundNormal, _characterUp);
            }
            
            // Cache pre movement displacement
            Vector3 inputDisplacement = displacement;
            
            TryHitGround(ref displacement);

            // Prevent moving into current BLOCKING overlaps, treat those as collisions and slide along 
            int iteration = 0;
            Vector3 prevNormal = default;

            for (int i = 0; i < _collisionCount; i++)
            {
                ref CollisionResult collisionResult = ref _collisionResults[i];

                bool opposesMovement = displacement.dot(collisionResult.normal) < 0.0f;
                if (!opposesMovement)
                    continue;

                // If falling, check if hit is a valid landing spot
                if (!isOnWalkableGround)
                {
                    if (IsValidLandingSpot(_updatedPosition, ref collisionResult))
                    {
                        _hasLanded = true;
                    }
                    else
                    {
                        // See if we can convert a normally invalid landing spot (based on the hit result) to a usable one.
                        if (collisionResult.hitLocation == HitLocation.Below)
                        {
                            FindGround(_updatedPosition, out FindGroundResult groundResult);

                            collisionResult.isWalkable = groundResult.isWalkableGround;
                            if (collisionResult.isWalkable)
                            {
                                _foundGround = groundResult;
                                _hasLanded = true;
                            }
                        }
                    }

                    // If failed to find a valid landing spot but hit ground, update _foundGround with sweep hit result

                    if (!_hasLanded && collisionResult.hitLocation == HitLocation.Below)
                    {
                        _foundGround.SetFromSweepResult(true, false, _updatedPosition, collisionResult.point,
                            collisionResult.normal, collisionResult.surfaceNormal, collisionResult.collider,
                            collisionResult.hitResult.distance);
                    }
                }

                if (_isUseSlide)
                {
                    // Slide along blocking overlap
                    iteration = SlideAlongSurface(iteration, inputDisplacement, ref _velocity, ref displacement,
                        ref collisionResult, ref prevNormal);
                }
            }

            // Perform collision constrained movement (aka: collide and slide)
            int maxSlideCount = _advanced.maxMovementIterations;
            while (displacement.sqrMagnitude > _advanced.minMoveDistanceSqr)
            {
                bool collided = MovementSweepTest(_updatedPosition, _velocity, displacement,
                    out CollisionResult collisionResult);

                if (!collided)
                    break;
                
                // Apply displacement up to hit (near position) and update displacement with remaining displacement
                _updatedPosition += collisionResult.displacementToHit;
                                
                if (maxSlideCount-- <= 0)
                {
                    // 最后一次的滑动次数，且此时碰到了物体， 则不在保留剩余位移
                    displacement = Vector3.zero;
                    break;
                }
                displacement = collisionResult.remainingDisplacement;

                // Hit a 'barrier', try to step up
                if (isOnWalkableGround && !collisionResult.isWalkable)
                {
                    if (CanStepUp(collisionResult.collider) &&
                        StepUp(ref collisionResult, out CollisionResult stepResult))
                    {
                        _updatedPosition = stepResult.position;

                        displacement = Vector3.zero;
                        break;
                    }
                }

                // If falling, check if hit is a valid landing spot
                if (!isOnWalkableGround)
                {
                    if (IsValidLandingSpot(_updatedPosition, ref collisionResult))
                    {
                        _hasLanded = true;
                    }
                    else
                    {
                        // See if we can convert a normally invalid landing spot (based on the hit result) to a usable one.
                        if (ShouldCheckForValidLandingSpot(ref collisionResult))
                        {
                            FindGround(_updatedPosition, out FindGroundResult groundResult);

                            collisionResult.isWalkable = groundResult.isWalkableGround;
                            if (collisionResult.isWalkable)
                            {
                                _foundGround = groundResult;
                                _hasLanded = true;
                            }
                        }
                    }

                    // If failed to find a valid landing spot but hit ground, update _foundGround with sweep hit result
                    if (!_hasLanded && collisionResult.hitLocation == HitLocation.Below)
                    {
                        float sweepDistance = collisionResult.hitResult.distance;
                        Vector3 surfaceNormal = collisionResult.surfaceNormal;

                        _foundGround.SetFromSweepResult(true, false, _updatedPosition, sweepDistance,
                            ref collisionResult.hitResult, surfaceNormal);
                    }
                }

                if (!_isUseSlide)
                {
                    // Cache collision result
                    AddCollisionResult(ref collisionResult);
                    // 如果不使用滑动，则碰到即停
                    displacement = Vector3.zero;
                    break;
                }
                // Resolve collision (slide along hit surface)
                iteration = SlideAlongSurface(iteration, inputDisplacement, ref _velocity, ref displacement,
                    ref collisionResult, ref prevNormal);

                // Cache collision result
                AddCollisionResult(ref collisionResult);
            }

            // Apply remaining displacement
            if (displacement.sqrMagnitude > _advanced.minMoveDistanceSqr)
                _updatedPosition += displacement;

            // 这里后续不在使用该速度， 为了优化注释掉。  这里目的保留原始速度的大小
            // If grounded, discard vertical movement BUT preserve its magnitude
            // if (isGrounded)
            // {
            //     _velocity = _velocity.projectedOnPlane(_characterUp).normalized * _velocity.magnitude;
            // }
        }

        /// <summary>
        /// 因地面没有碰撞器，而移动的时候，又不能穿过地面。所以这里使用目标位移，先去尝试碰地面
        /// 如果碰到地面，则限制位移的长度不能穿过地面
        /// </summary>
        /// <param name="displacement"></param>
        // 使用高度图时，地面collider不存在，移动表现时无法确定是否碰到Collider所以这里优先进行一次地面检测
        // 限制位移距离，最多只能移动到地面
        // 原理，判断该次的位移是否会和地面相交，并求出交点。限制位移只能是从起点到交点
        private void TryHitGround(ref Vector3 displacement)
        {
            // 使用高度图时，地面collider不存在，移动表现时无法确定是否碰到Collider所以这里优先进行一次地面检测
            // 限制位移距离，最多只能移动到地面
            // 原理，判断该次的位移是否会和地面相交，并求出交点。限制位移只能是从起点到交点
            if (_advanced.isUseGroundHighMap && !isOnWalkableGround)
            {
                Vector3 targetPos = _updatedPosition + displacement;
                if (targetPos.y < _updatedPosition.y)
                {
                    // 斜上方运动时，不做地面检测，便于允许从地面上起飞。 斜下方运动时检测，防止穿透地面
                    Vector3 groundStartPos = _updatedPosition;
                    Vector3 groundEndPos = targetPos;
                    groundStartPos.y = BattleUtil.GetGroundHeight(_updatedPosition);
                    groundEndPos.y = BattleUtil.GetGroundHeight(groundEndPos);
                    bool isHit = X3Physics.SegmentSegmentPoint2D(_updatedPosition, targetPos, groundStartPos, groundEndPos, out var hitPoint);
                    if (isHit)
                    {
                        // 确保，下一步的移动不会移动到地面上,和地面接触的状态
                        hitPoint.y = BattleUtil.GetGroundHeight(hitPoint) + kAvgGroundDistance;
                        displacement = hitPoint - _updatedPosition;
                    }
                }
            }
        }

        /// <summary>
        /// Compute and apply collision response impulses for dynamic collisions (eg: character vs rigidbodies or character vs other character).
        /// </summary>
        private void ResolveDynamicCollisions()
        {
            if (!_advanced.allowPushCharacters)
            {
                return;
            }
            for (int i = 0; i < _collisionCount; i++)
            {
                ref CollisionResult collisionResult = ref _collisionResults[i];
                if (collisionResult.isWalkable)
                    continue;

                var otherRigidbody = collisionResult.rigidActor;
                if (otherRigidbody == null)
                    continue;

                var otherCharacter = collisionResult.characterMovement;
                if (!otherCharacter)
                    continue; // 推动效果，限定在两个有 CC 组件的角色上

                if (!collisionResult.isRigidbodyCollider)
                    continue; // 角色的身体部位collider，不参与推动效果

                var otherImpulse = ComputeDynamicCollisionResponse(ref collisionResult);
                otherCharacter.bePushedVelocity = otherImpulse * _pushForceScale;
            }

            // TODO 后重写推动算法 推别人时，自己不受力
            // if (isGrounded)
            //     _bePushedVelocity = _bePushedVelocity.projectedOnPlane(_characterUp).normalized *
            //                         _bePushedVelocity.magnitude;
        }

        /// <summary>
        /// Trigger FoundGround event.
        /// </summary>
        public void TryOnFoundGround()
        {
            if (wasOnGround || !isOnGround)
                return;
                
            // 上一次不在地面上，当前帧在地面上，才需要触发OnFoundGround。
            using (ProfilerDefine.CharacterMovementOnFoundGroundPMarker.Auto())
            {
                LogProxy.LogFormat("{0}: 触发OnFoundGround", this.name);
                FoundGround?.Invoke(ref _currentGround);
            }
        }

        /// <summary>
        /// 强制拉到地面上，受移动区域限制
        /// 1.可以从指定位置，拉到地面上。默认使用当前位置
        /// 2.如果忽略碰撞，可以与其它Collider重叠
        /// </summary>
        public void ForceGrounded(Vector3? targetPos=null, bool ignoreCollision=false)
        {
            Vector3 curPos = targetPos ?? _updatedPosition;
            var groundResult = default(FindGroundResult);

            if (!ignoreCollision)
                FindGround(curPos, out groundResult);
            
            if (!groundResult.hitGround)
            {
                // 如果没有检测到地面，这里构造高度图地面信息， 必须要保证检测到地面
                var curGroundHeight = BattleUtil.GetGroundHeight(curPos);
                var hitPos = _updatedPosition;
                hitPos.y = curGroundHeight;
                
                var hitResult = default(CqRaycastHit);
                hitResult.point = hitPos;
                hitResult.distance = curGroundHeight;
                hitResult.normal = _characterUp;
                groundResult.SetFromSweepResult(true, true, curPos, curGroundHeight,
                    ref hitResult, _characterUp);
            }
            UpdateCurrentGround(ref groundResult);
            AdjustGroundHeight();
            SetPositionAndRotation(_updatedPosition, groundResult.point, _updatedRotation, 0);
        }

        /// <summary>
        /// 移动模式的切换
        /// 暂时支持两种：Normal， flying
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public void SwitchMode(MovementMode model)
        {
            _modeCtrl.SwitchMode(model); 
        }
        
        /// <summary>
        /// Resolve collisions of Character's bounding volume during a Move call.
        /// </summary>
        private int SlideAlongSurface(int iteration, Vector3 inputDisplacement, ref Vector3 inVelocity,
            ref Vector3 displacement, ref CollisionResult inHit, ref Vector3 prevNormal)
        {
            if (inHit.hitLocation == HitLocation.Above)
            {
                Vector3 surfaceNormal = FindBoxOpposingNormal(displacement, inHit.transform, inHit.normal);
                if (inHit.normal != surfaceNormal)
                {
                    inHit.normal = surfaceNormal;
                    inHit.surfaceNormal = surfaceNormal;
                }
            }

            inHit.normal = ComputeBlockingNormal(inHit.normal, inHit.isWalkable);

            if (inHit.isWalkable)
            {
                inVelocity = ComputeSlideVector(inVelocity, inHit.normal, true);
                displacement = ComputeSlideVector(displacement, inHit.normal, true);
            }
            else
            {
                if (iteration == 0)
                {
                    inVelocity = ComputeSlideVector(inVelocity, inHit.normal, inHit.isWalkable);
                    displacement = ComputeSlideVector(displacement, inHit.normal, inHit.isWalkable);

                    iteration++;
                }
                else if (iteration == 1)
                {
                    Vector3 crease = prevNormal.perpendicularTo(inHit.normal);

                    Vector3 oVel = inputDisplacement.projectedOnPlane(crease);

                    Vector3 nVel = ComputeSlideVector(displacement, inHit.normal, inHit.isWalkable);
                    nVel = nVel.projectedOnPlane(crease);

                    if (oVel.dot(nVel) <= 0.0f || prevNormal.dot(inHit.normal) < 0.0f)
                    {
                        inVelocity = inVelocity.projectedOn(crease);
                        displacement = displacement.projectedOn(crease);
                        ++iteration;
                    }
                    else
                    {
                        inVelocity = ComputeSlideVector(inVelocity, inHit.normal, inHit.isWalkable);
                        displacement = ComputeSlideVector(displacement, inHit.normal, inHit.isWalkable);
                    }
                }
                else
                {
                    inVelocity = Vector3.zero;
                    displacement = Vector3.zero;
                }

                prevNormal = inHit.normal;
            }
            float distanceRatio = 1;
            if (inHit.collider.attachedRigidActor != null)
                distanceRatio = inHit.collider.attachedRigidActor.mass / (_rigidActor.mass + inHit.collider.attachedRigidActor.mass);
            displacement = displacement * distanceRatio * slideRatio;

            return iteration;
        }

        /// <summary>
        /// Determine whether we should try to find a valid landing spot after an impact with an invalid one (based on the Hit result).
        /// For example, landing on the lower portion of the capsule on the edge of geometry may be a walkable surface, but could have reported an unwalkable surface normal.
        /// </summary>
        private bool ShouldCheckForValidLandingSpot(ref CollisionResult inCollision)
        {
            // See if we hit an edge of a surface on the lower portion of the capsule.
            // In this case the normal will not equal the surface normal, and a downward sweep may find a walkable surface on top of the edge.
            if (inCollision.hitLocation == HitLocation.Below && inCollision.normal != inCollision.surfaceNormal)
            {
                if (IsWithinEdgeTolerance(_updatedPosition, inCollision.point, _radius))
                    return true;
            }

            return false;
        }

        /// <summary>
        /// Calculate slide vector along a surface.
        /// </summary>
        private Vector3 ComputeSlideVector(Vector3 displacement, Vector3 inNormal, bool isWalkable)
        {
            if (isOnWalkableGround)
            {
                if (isWalkable)
                    displacement = displacement.tangentTo(inNormal, _characterUp);
                else
                {
                    Vector3 right = inNormal.perpendicularTo(groundNormal);
                    Vector3 up = right.perpendicularTo(inNormal);

                    displacement = displacement.projectedOnPlane(inNormal);
                    displacement = displacement.tangentTo(up, _characterUp);
                }
            }
            else
            {
                if (isWalkable)
                {
                    displacement = displacement.projectedOnPlane(_characterUp);
                    displacement = displacement.projectedOnPlane(inNormal);
                }
                else
                {
                    Vector3 slideResult = displacement.projectedOnPlane(inNormal);
                    slideResult = HandleSlopeBoosting(slideResult, displacement, inNormal);
                    displacement = slideResult;
                }
            }

            return displacement;
        }

        /// <summary>
        /// Limit the slide vector when falling if the resulting slide might boost the character faster upwards.
        /// </summary>
        private Vector3 HandleSlopeBoosting(Vector3 slideResult, Vector3 displacement, Vector3 inNormal)
        {
            Vector3 result = slideResult;

            float yResult = Vector3.Dot(result, _characterUp);
            if (yResult > 0.0f)
            {
                // Don't move any higher than we originally intended.
                float yLimit = Vector3.Dot(displacement, _characterUp);
                if (yResult - yLimit > kKindaSmallNumber)
                {
                    if (yLimit > 0.0f)
                    {
                        // Rescale the entire vector (not just the Z component) otherwise we change the direction and likely head right back into the impact.
                        float upPercent = yLimit / yResult;
                        result *= upPercent;
                    }
                    else
                    {
                        // We were heading down but were going to deflect upwards. Just make the deflection horizontal.
                        result = Vector3.zero;
                    }

                    // Make remaining portion of original result horizontal and parallel to impact normal.
                    Vector3 lateralRemainder = (slideResult - result).projectedOnPlane(_characterUp);
                    Vector3 lateralNormal = inNormal.projectedOnPlane(_characterUp).normalized;
                    Vector3 adjust = lateralRemainder.projectedOnPlane(lateralNormal);

                    result += adjust;
                }
            }

            return result;
        }

        /// <summary>
        /// Verify that the supplied CollisionResult is a valid landing spot when falling.
        /// </summary>
        private bool IsValidLandingSpot(Vector3 characterPosition, ref CollisionResult inCollision)
        {
            // Reject unwalkable ground normals.
            if (!inCollision.isWalkable)
                return false;

            // Reject hits that are above our lower hemisphere (can happen when sliding down a vertical surface).
            if (inCollision.hitLocation != HitLocation.Below)
                return false;

            // Reject hits that are barely on the cusp of the radius of the capsule
            if (!IsWithinEdgeTolerance(characterPosition, inCollision.point, _radius))
            {
                inCollision.isWalkable = false;

                return false;
            }

            FindGround(characterPosition, out FindGroundResult groundResult);
            {
                inCollision.isWalkable = groundResult.isWalkableGround;

                if (inCollision.isWalkable)
                {
                    _foundGround = groundResult;
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 计算被碰到的collider受到的力，这里直接用速度表示，主动发起碰撞的一方不受力
        /// </summary>
        private Vector3 ComputeDynamicCollisionResponse(ref CollisionResult inCollisionResult)
        {
            using (ProfilerDefine.ComputeDynamicCollisionResponsePMarker.Auto())
            {
                Vector3 tempVec = Vector3.Project(inCollisionResult.velocity * _pushForceScale, inCollisionResult.normal);
                var otherRigidbody = inCollisionResult.rigidActor;
                var otherImpulse = tempVec * (_rigidActor.mass / otherRigidbody.mass);
                return otherImpulse;
            }
        }

        /// <summary>
        /// Update cached fields using during Move.
        /// </summary>
        private void UpdateCachedFields()
        {
            _hasLanded = false;
            _foundGround = default;

            _updatedPosition = transform.position + transform.rotation * ccOffset; // 胶囊体底部的世界坐标
            _updatedRotation = transform.rotation;
            _updatedPositionY = _updatedPosition.y; 
            _characterUp = _updatedRotation * Vector3.up;
            _characterRight = _updatedRotation * Vector3.right;
            _characterForward = _updatedRotation * Vector3.forward;

            _transformedCapsuleCenter = _updatedRotation * (_capsuleCenter - ccOffset); // 胶囊体中心点相对于胶囊体底部的坐标
            _transformedCapsuleTopCenter = _updatedRotation *  (_capsuleTopCenter - ccOffset); // 胶囊体上球面圆心相对于胶囊体底部的坐标capsuleQuaternion *
            _transformedCapsuleBottomCenter = _updatedRotation  * (_capsuleBottomCenter - ccOffset); // 胶囊体下球面圆心相对于胶囊体底部的坐标* capsuleQuaternion

            collisionFlags = CollisionFlags.None;
        }

        private void ClearCollisionResults()
        {
            _collisionCount = 0;
        }

        private void UpdateVelocity(Vector3 newVelocity, float deltaTime)
        {
            // Assign new velocity
            _velocity = newVelocity + _bePushedVelocity;
            Vector3 beResolveVelocity = _beResolveVec / deltaTime;
            
            if (Vector3.Dot(beResolveVelocity, _velocity) < 0)
            {
                // 一旦触发，原始方向不变，距离重新计算
                _velocity = Vector3.Project(beResolveVelocity, _velocity.normalized);
            }
            else
            {
                _velocity += beResolveVelocity;
            }
            _bePushedVelocity = Vector3.zero;
            _beResolveVec = Vector3.zero;
        }

        /// <summary>
        /// 简单移动表现，碰到即停，不尝试滑动
        /// </summary>
        private void SimplePerformMovement(float deltaTime)
        {
            // If grounded, discard velocity vertical component
            if (isOnWalkableGround)
                _velocity = _velocity.projectedOnPlane(_characterUp);

            // Compute displacement
            Vector3 displacement = _velocity * deltaTime;

            TryHitGround(ref displacement);
            // Prevent moving into current BLOCKING overlaps, treat those as collisions and slide along 
            bool collided = MovementSweepTest(_updatedPosition, _velocity, displacement,
                out CollisionResult collisionResult);

            if (collided)
            {
                // Apply displacement up to hit (near position) and update displacement with remaining displacement
                _updatedPosition += collisionResult.displacementToHit;
            }
            else
            {
                _updatedPosition += displacement;
            }

            // Cache collision result
            AddCollisionResult(ref collisionResult);

            // If grounded, discard vertical movement BUT preserve its magnitude
            // if (isGrounded)
            // {
            //     _velocity = _velocity.projectedOnPlane(_characterUp).normalized * _velocity.magnitude;
            // }
        }

        public void SetPositionAndRotation(Vector3 originalPos, Vector3 newPosition, Quaternion newRotation,float deltaTime, bool updateGround = false)
        {
            using (ProfilerDefine.CharacterMovementSetPositionAndRotationPMarker.Auto())
            {
                _updatedPosition = newPosition;
                _updatedRotation = newRotation;
                if (updateGround)
                {
                    FindGroundResult groundResult;
                    FindGround(_updatedPosition, out  groundResult);

                    UpdateCurrentGround(ref groundResult);
                    AdjustGroundHeight();
                }

                if (OnSetWorldPos != null)
                {
                    OnSetWorldPos(originalPos, ref _updatedPosition);
                }

                // y轴向平滑处理
                if (_yLerpTime > 0 && _modeCtrl.curMode.needSmooth)
                {
                    var currentVelocity = 0f;
                    var smoothDampY = Mathf.SmoothDamp(_updatedPositionY, _updatedPosition.y, ref currentVelocity, _yLerpTime);
                    _updatedPosition.y = smoothDampY;
                }

                using (ProfilerDefine.TransformSetPositionAndRotationPMarker.Auto())
                {
                    if (_updatedPosition.IsNaN())
                    { 
                        LogProxy.LogError($"[CharacterMovement.SetPosition()]{name}：设置位置异常，位置信息非法，请留意检查！！");
                    }
                    else
                    {
                        transform.SetPositionAndRotation(_updatedPosition - _updatedRotation * ccOffset, _updatedRotation);
                    }
                }
                
                TryOnFoundGround();
            }
        }
        
        /// <summary>
        /// 传送接口，适用于远距离，不受移动区域限制（忽略寻路限制）
        /// </summary>
        /// <param name="newPosition"></param>
        /// <param name="updateGround"></param>
        public void SetPosition(Vector3 newPosition, bool updateGround = false)
        {
            using (ProfilerDefine.CharacterMovementSetPositionPMarker.Auto())
            {
                _updatedPosition = newPosition + _updatedRotation * ccOffset;

                if (updateGround)
                {
                    FindGround(_updatedPosition, out FindGroundResult groundResult);
                    {
                        UpdateCurrentGround(ref groundResult);
                        AdjustGroundHeight();
                    }
                }

                if (_updatedPosition.IsNaN())
                { 
                    LogProxy.LogError($"[CharacterMovement.SetPosition()]{name}：设置位置异常，位置信息非法，请留意检查！！");
                }
                else
                {
                    _rigidActor.position = _updatedPosition - _updatedRotation * ccOffset;
                    transform.position = _updatedPosition - _updatedRotation * ccOffset;
                }
                
                TryOnFoundGround();
            }
        }

        /// <summary>
        /// Compute distance to the ground from bottom sphere of capsule and store the result in collisionResult.
        /// This distance is the swept distance of the capsule to the first point impacted by the lower hemisphere,
        /// or distance from the bottom of the capsule in the case of a raycast.
        /// </summary>
        public void ComputeGroundDistance(Vector3 characterPosition, float sweepRadius, float sweepDistance,
            float castDistance, out FindGroundResult outGroundResult)
        {
            outGroundResult = default;

            // We require the sweep distance to be >= the raycast distance,
            // otherwise the HitResult can't be interpreted as the sweep result.
            if (sweepDistance < castDistance)
                return;

            float characterRadius = _radius;
            float characterHeight = _height;
            float characterHalfHeight = characterHeight * 0.5f;

            bool foundGround = default;
            bool startPenetrating = default;

            // Sweep test
            if (sweepDistance > 0.0f && sweepRadius > 0.0f)
            {
                // Use a shorter height to avoid sweeps giving weird results if we start on a surface.
                // This also allows us to adjust out of penetrations.
                const float kShrinkScale = 0.9f;
                float shrinkHeight = (characterHalfHeight - characterRadius) * (1.0f - kShrinkScale);
                float shrinkRadius = sweepRadius * (1.0f - kShrinkScale);
                float capsuleRadius;
                float actualSweepDistance;
                float capsuleHalfHeight = characterHalfHeight - shrinkHeight;
                
                if (direction == Direction.Y)
                { 
                    capsuleRadius = sweepRadius;
                    actualSweepDistance = sweepDistance + shrinkHeight;
                }
                else
                {
                    
                    capsuleRadius = sweepRadius - shrinkRadius;
                    actualSweepDistance = sweepDistance + shrinkRadius;
                }

                foundGround = GroundSweepTest(characterPosition, capsuleRadius, capsuleHalfHeight, actualSweepDistance,
                    out var hitResult, out startPenetrating);

                if (foundGround || startPenetrating)
                {
                    // Reject hits adjacent to us, we only care about hits on the bottom portion of our capsule.
                    // Check 2D distance to impact point, reject if within a tolerance from radius.
                    if (startPenetrating || !IsWithinEdgeTolerance(characterPosition, hitResult.point, capsuleRadius))
                    {
                        // Use a capsule with a slightly smaller radius and shorter height to avoid the adjacent object.
                        // Capsule must not be nearly zero or the trace will fall back to a line trace from the start point and have the wrong length.
                        const float kShrinkScaleOverlap = 0.1f;
                        shrinkHeight = (characterHalfHeight - characterRadius) * (1.0f - kShrinkScaleOverlap);
                        if (direction == Direction.Y)
                            shrinkRadius = 0;
                        else
                            shrinkRadius = Mathf.Max(0.0011f,
                                (capsuleRadius - kSweepEdgeRejectDistance - kKindaSmallNumber) * (1.0f - kShrinkScaleOverlap)) ;

                        capsuleRadius = Mathf.Max(0.0011f,
                            capsuleRadius - kSweepEdgeRejectDistance - kKindaSmallNumber - shrinkRadius) ;
                        capsuleHalfHeight = Mathf.Max(capsuleRadius, characterHalfHeight - shrinkHeight);

                        if (direction == Direction.Y)
                            actualSweepDistance = sweepDistance + shrinkHeight;
                        else
                            actualSweepDistance = sweepDistance + shrinkRadius;

                        foundGround = GroundSweepTest(characterPosition, capsuleRadius, capsuleHalfHeight,
                            actualSweepDistance, out hitResult, out startPenetrating);
                    }

                    if (foundGround && !startPenetrating)
                    {
                        // Reduce hit distance by shrinkHeight because we shrank the capsule for the trace.
                        // We allow negative distances here, because this allows us to pull out of penetrations.
                        float maxPenetrationAdjust = Mathf.Max(kMaxGroundDistance, characterRadius);
                        float sweepResult;
                        if (direction == Direction.Y)
                            sweepResult = Mathf.Max(-maxPenetrationAdjust, hitResult.distance - shrinkHeight);
                        else
                            sweepResult = Mathf.Max(-maxPenetrationAdjust, hitResult.distance - shrinkRadius);

                        Vector3 sweepDirection = -1.0f * _characterUp;
                        Vector3 hitPosition = (Vector3)hitResult.point - sweepDirection * shrinkRadius;

                        Vector3 surfaceNormal = hitResult.normal;

                        bool isWalkable = false;
                        bool hitGround = sweepResult <= sweepDistance &&
                                         ComputeHitLocation(hitResult.normal) == HitLocation.Below;

                        if (hitGround)
                        {
                            surfaceNormal = FindGeomOpposingNormal(sweepDirection * sweepDistance, ref hitResult);
                            isWalkable = IsWalkable(hitResult.Collider, surfaceNormal);
                        }

                        outGroundResult.SetFromSweepResult(hitGround, isWalkable, hitPosition, sweepResult,
                            ref hitResult, surfaceNormal);

                        if (outGroundResult.isWalkableGround)
                            return;
                    }
                }
            }

            // Since we require a longer sweep than raycast, we don't want to run the raycast if the sweep missed everything.
            // We do however want to try a raycast if the sweep was stuck in penetration.
            if (!foundGround && !startPenetrating)
                return;

            // Ray cast
            if (castDistance > 0.0f)
            {
                Vector3 rayOrigin = characterPosition + _transformedCapsuleCenter;
                Vector3 rayDirection = -1.0f * _characterUp;

                float shrinkHeight = characterHalfHeight;
                float rayLength = castDistance + shrinkHeight;

                foundGround = Raycast(rayOrigin, rayDirection, rayLength, _collisionLayers, out CqRaycastHit hitResult);
                if (foundGround && hitResult.distance > 0.0f)
                {
                    // Reduce hit distance by shrinkHeight because we started the ray higher than the base.
                    // We allow negative distances here, because this allows us to pull out of penetrations.

                    float MaxPenetrationAdjust = Mathf.Max(kMaxGroundDistance, characterRadius);
                    float castResult = Mathf.Max(-MaxPenetrationAdjust, hitResult.distance - shrinkHeight);

                    if (castResult <= castDistance && IsWalkable(hitResult.Collider, hitResult.normal))
                    {
                        outGroundResult.SetFromRaycastResult(true, true, outGroundResult.position,
                            outGroundResult.groundDistance, castResult, ref hitResult);

                        return;
                    }
                }
            }

            // No hits were acceptable.
            outGroundResult.isWalkable = false;
        }

        /// <summary>
        /// Downwards (along character's up axis) sweep against the world and return the first blocking hit.
        /// </summary>
        private bool GroundSweepTest(Vector3 characterPosition, float capsuleRadius, float capsuleHalfHeight,
            float sweepDistance, out CqRaycastHit hitResult, out bool startPenetrating)
        {
            bool foundBlockingHit;
            Vector3 characterCenter = characterPosition + _transformedCapsuleCenter;
            Vector3 tempVec = capsuleUp *  (capsuleHalfHeight - capsuleRadius);
            Vector3 point1, point2;
            point1 = characterCenter - tempVec; // bottom
            point2 = characterCenter + tempVec; // top



            if (!_advanced.isUseGroundHighMap) // 不使用高低地形
            {
                Vector3 sweepDirection = -1.0f * _characterUp;
                foundBlockingHit = CapsuleCast(point1, point2, capsuleRadius, sweepDirection, sweepDistance,
                    _collisionLayers, out hitResult, out startPenetrating);
                return foundBlockingHit;
            }
            // TODO:临时解决方法。后续要采用更精确的方法计算横着的胶囊体与高度图的交点
            if(direction != Direction.Y)
            {
                point1 = characterCenter;
            }
            float checkDis = sweepDistance + capsuleRadius;
            hitResult = default(CqRaycastHit);
            startPenetrating = false;
            foundBlockingHit = false;

            Vector3 hitPos = point1; // 当选择了y轴向时使用底部半球的球心， 选择了xz轴向使用圆柱体底部中点，可以使得参数 capsuleHalfHeight 生效
            hitPos.y = BattleUtil.GetGroundHeight(point1);
            var hitNor = _characterUp; // 暂时不使用高度图的法线，统一认定地面为平面
            float dis = Vector3.Project(hitPos - point1, hitNor).magnitude;
            if (Vector3.Dot(hitPos - point1, hitNor) > 0 || dis <= checkDis)
            {
                // 和地面穿透时，统一向上挤出
                foundBlockingHit = true;
                hitResult.point = hitPos;
                hitResult.normal = hitNor;
                hitResult.distance = dis - capsuleRadius;
                // 暂时只考虑， capsule 竖直情况
                startPenetrating = (point1.y - capsuleRadius) - hitPos.y <= 0;
            }
            
            return foundBlockingHit;
        }


        /// <summary>
        /// Compute the sweep result of the smaller capsule with radius specified by GetValidPerchRadius(),
        /// and return true if the sweep contacts a valid walkable normal within inMaxGroundDistance of impact point.
        /// This may be used to determine if the capsule can or cannot stay at the current location if perched on the edge of a small ledge or unwalkable surface. 
        /// </summary>
        private bool ComputePerchResult(Vector3 characterPosition, float testRadius, float inMaxGroundDistance,
            ref CqRaycastHit inHit, out FindGroundResult perchGroundResult)
        {
            perchGroundResult = default;

            if (inMaxGroundDistance <= 0.0f)
                return false;

            // Sweep further than actual requested distance, because a reduced capsule radius means we could miss some hits that the normal radius would contact.
            float inHitAboveBase = Mathf.Max(0.0f, Vector3.Dot((Vector3)inHit.point - characterPosition, _characterUp));
            float perchCastDist = Mathf.Max(0.0f, inMaxGroundDistance - inHitAboveBase);
            float perchSweepDist = Mathf.Max(0.0f, inMaxGroundDistance);

            float actualSweepDist = perchSweepDist + _radius;
            ComputeGroundDistance(characterPosition, testRadius, actualSweepDist, perchCastDist, out perchGroundResult);

            if (!perchGroundResult.isWalkable)
                return false;
            else if (inHitAboveBase + perchGroundResult.groundDistance > inMaxGroundDistance)
            {
                // Hit something past max distance
                perchGroundResult.isWalkable = false;
                return false;
            }

            return true;
        }

        /// <summary>
        /// Sweeps a vertical cast to find the ground for the capsule at the given location.
        /// Will attempt to perch if ShouldComputePerchResult() returns true for the downward sweep result.
        /// No ground will be found if collision is disabled (eg: detectCollisions == false).
        /// </summary>
        public void FindGround(Vector3 characterPosition, out FindGroundResult outGroundResult)
        {
            using (ProfilerDefine.CharacterMovementFindGroundPMarker.Auto())
            {
                // Increase height check slightly if walking,
                // to prevent ground height adjustment from later invalidating the ground result.
                float heightCheckAdjust = isOnWalkableGround ? kMaxGroundDistance + kKindaSmallNumber : -kMaxGroundDistance;
                float sweepDistance = Mathf.Max(kMaxGroundDistance, Math.Max(0, _stepOffset) + heightCheckAdjust);
    
                // Sweep ground
                ComputeGroundDistance(characterPosition, _radius, sweepDistance, sweepDistance, out outGroundResult);
    
                // outGroundResult.hitResult is now the result of the vertical ground check.
                // See if we should try to "perch" at this location.
                if (outGroundResult.hitGround && !outGroundResult.isRaycastResult)
                {
                    Vector3 positionOnGround = outGroundResult.position;
    
                    if (ShouldComputePerchResult(positionOnGround, ref outGroundResult.hitResult))
                    {
                        float maxPerchGroundDistance = sweepDistance;
                        if (isOnWalkableGround)
                            maxPerchGroundDistance += Mathf.Max(0, _perchAdditionalHeight);
    
                        float validPerchRadius = GetValidPerchRadius(outGroundResult.collider);
    
                        if (ComputePerchResult(positionOnGround, validPerchRadius, maxPerchGroundDistance,
                                ref outGroundResult.hitResult, out FindGroundResult perchGroundResult))
                        {
                            // Don't allow the ground distance adjustment to push us up too high,
                            // or we will move beyond the perch distance and fall next time.
                            float moveUpDist = kAvgGroundDistance - outGroundResult.groundDistance;
                            if (moveUpDist + perchGroundResult.groundDistance >= maxPerchGroundDistance)
                            {
                                outGroundResult.groundDistance = kAvgGroundDistance;
                            }
    
                            // If the regular capsule is on an unwalkable surface but the perched one would allow us to stand,
                            // override the normal to be one that is walkable.
                            if (!outGroundResult.isWalkableGround)
                            {
                                // Ground distances are used as the distance of the regular capsule to the point of collision,
                                // to make sure AdjustGroundHeight() behaves correctly.
                                float groundDistance = outGroundResult.groundDistance;
                                float raycastDistance = Mathf.Max(kMinGroundDistance, groundDistance);
    
                                outGroundResult.SetFromRaycastResult(true, true, outGroundResult.position, groundDistance,
                                    raycastDistance, ref perchGroundResult.hitResult);
                            }
                        }
                        else
                        {
                            // We had no ground (or an invalid one because it was unwalkable), and couldn't perch here,
                            // so invalidate ground (which will cause us to start falling).
                            outGroundResult.isWalkable = false;
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Adjust distance from ground, trying to maintain a slight offset from the ground when walking (based on current GroundResult).
        /// Only if character isConstrainedToGround == true.
        /// </summary>
        private void AdjustGroundHeight()
        {
            using (ProfilerDefine.CharacterMovementAdjustGroundHeightPMarker.Auto())
            {
                float groundVerticalHigh = 0;
                if (_advanced.isUseGroundHighMap) // 使用高低地形
                {
                    groundVerticalHigh = BattleUtil.GetGroundHeight(_updatedPosition);
                }
                float currentVerticalHigh = _updatedPosition.y;
                float targetVerticalHigh = kAvgGroundDistance + groundVerticalHigh;

                if (isOnWalkableGround) 
                {
                    float edge = Mathf.Max(_currentGround.groundDistance, _radius) - _radius;
                    float angle = Vector3.Angle(- _currentGround.normal, Vector3.down);
                    float cos = Mathf.Cos(angle * Mathf.Deg2Rad);
                    float verticalMove = cos != 0 ? edge / cos : 0;
                    if (verticalMove == 0)
                    {
                        groundVerticalHigh = _currentGround.point.y;
                    }
                    else
                    {
                        groundVerticalHigh = currentVerticalHigh - verticalMove - _radius * cos;
                    }
                
                    targetVerticalHigh = kAvgGroundDistance + groundVerticalHigh;
                    float maxVHigh = kMaxGroundDistance + groundVerticalHigh;
                    float minVHigh = kMinGroundDistance + groundVerticalHigh;
                    if (currentVerticalHigh > maxVHigh || currentVerticalHigh < minVHigh)
                    {
                        // 当前高度不在范围误差之内，需要调整地面高度
                        _updatedPosition.y = targetVerticalHigh;
                        _currentGround.groundDistance = kAvgGroundDistance;
                    }
                }

                if (currentVerticalHigh < groundVerticalHigh + kAvgGroundDistance)
                {
                    // 这里假定 地面高度 固定为0。 保底不允许设置到地面保持高度以下
                    _updatedPosition.y = targetVerticalHigh;
                    _currentGround.groundDistance = kAvgGroundDistance;
                }
            }
        }

        /// <summary>
        /// Determines if the character is able to step up on given collider.
        /// </summary>
        private bool CanStepUp(CqCollider otherCollider)
        {
            // Validate input collider
            if (otherCollider == null)
                return false;

            // If collision behavior callback assigned, use it
            if (collisionBehaviorCallback != null)
            {
                CollisionBehavior collisionBehavior = collisionBehaviorCallback.Invoke(otherCollider);

                if (CanStepOn(collisionBehavior))
                    return true;

                if (CanNotStepOn(collisionBehavior))
                    return false;
            }

            // Default case, managed by stepOffset
            return true;
        }

        private float GetPerchRadiusThreshold()
        {
            // Don't allow negative values.
            return Mathf.Max(0.0f, _radius - Mathf.Max(0, _perchOffset));
        }

        /// <summary>
        /// Returns the radius within which we can stand on the edge of a surface without falling (if this is a walkable surface).
        /// </summary>
        private float GetValidPerchRadius(CqCollider otherCollider)
        {
            if (!CanPerchOn(otherCollider))
                return 0.0011f;

            return Mathf.Clamp(_perchOffset, 0.0011f, _radius);
        }

        /// <summary>
        /// Check if the result of a sweep test (passed in InHit) might be a valid location to perch, in which case we should use ComputePerchResult to validate the location.
        /// </summary>
        private bool ShouldComputePerchResult(Vector3 characterPosition, ref CqRaycastHit inHit)
        {
            // Don't try to perch if the edge radius is very small.
            if (GetPerchRadiusThreshold() <= kSweepEdgeRejectDistance)
            {
                return false;
            }

            float distFromCenterSq = ((Vector3)inHit.point - characterPosition).projectedOnPlane(_characterUp).sqrMagnitude;
            float standOnEdgeRadius = GetValidPerchRadius(inHit.Collider);

            if (distFromCenterSq <= standOnEdgeRadius.square())
            {
                // Already within perch radius.
                return false;
            }

            return true;
        }


        /// <summary>
        /// Move up steps or slope.
        /// Does nothing and returns false if CanStepUp(collider) returns false, true if the step up was successful.
        /// </summary>
        private bool StepUp(ref CollisionResult inCollision, out CollisionResult stepResult)
        {
            stepResult = default;

            // Don't bother stepping up if top of capsule is hitting something.
            if (inCollision.hitLocation == HitLocation.Above)
                return false;

            // We need to enforce max step height off the actual point of impact with the ground.
            float characterInitialGroundPositionY = Vector3.Dot(inCollision.position, _characterUp);
            float groundPointY = characterInitialGroundPositionY;

            float actualGroundDistance = Mathf.Max(0.0f, _currentGround.GetDistanceToGround());
            characterInitialGroundPositionY -= actualGroundDistance;

            float stepTravelUpHeight = Mathf.Max(0.0f, _stepOffset - actualGroundDistance);
            float stepTravelDownHeight = _stepOffset + kMaxGroundDistance * 2.0f;

            bool hitVerticalFace =
                !IsWithinEdgeTolerance(inCollision.position, inCollision.point, _radius + kContactOffset);

            if (!_currentGround.isRaycastResult && !hitVerticalFace)
                groundPointY = Vector3.Dot(groundPoint, _characterUp);
            else
                groundPointY -= _currentGround.groundDistance;

            // Don't step up if the impact is below us, accounting for distance from ground.
            float initialImpactY = Vector3.Dot(inCollision.point, _characterUp);
            if (initialImpactY <= characterInitialGroundPositionY)
                return false;

            // Step up, treat as vertical wall
            Vector3 sweepOrigin = inCollision.position;
            Vector3 sweepDirection = _characterUp;

            float sweepRadius = _radius;
            float sweepDistance = stepTravelUpHeight;

            int sweepLayerMask = _collisionLayers;

            bool foundBlockingHit = SweepTest(sweepOrigin, sweepRadius, sweepDirection, sweepDistance, sweepLayerMask,
                out var hitResult, out bool startPenetrating);

            if (startPenetrating)
                return false;

            if (!foundBlockingHit)
                sweepOrigin += sweepDirection * sweepDistance;
            else
                sweepOrigin += sweepDirection * hitResult.distance;

            // Step forward (lateral displacement only)
            Vector3 displacement = inCollision.remainingDisplacement;
            Vector3 displacement2D = Vector3.ProjectOnPlane(displacement, _characterUp);

            sweepDistance = displacement.magnitude;
            sweepDirection = displacement2D.normalized;

            foundBlockingHit = SweepTest(sweepOrigin, sweepRadius, sweepDirection, sweepDistance, sweepLayerMask,
                out hitResult, out startPenetrating);

            if (startPenetrating)
                return false;

            if (!foundBlockingHit)
                sweepOrigin += sweepDirection * sweepDistance;
            else
            {
                // Could not hurdle the 'barrier', return
                return false;
            }

            // Step down
            sweepDirection = -_characterUp;
            sweepDistance = stepTravelDownHeight;

            foundBlockingHit = SweepTest(sweepOrigin, sweepRadius, sweepDirection, sweepDistance, sweepLayerMask,
                out hitResult, out startPenetrating);

            if (!foundBlockingHit || startPenetrating)
                return false;

            // See if this step sequence would have allowed us to travel higher than our max step height allows.
            float deltaY = Vector3.Dot(hitResult.point, _characterUp) - groundPointY;
            if (deltaY > _stepOffset)
                return false;

            // Is position on step clear ?
            Vector3 positionOnStep = sweepOrigin + sweepDirection * hitResult.distance;

            if (OverlapTest(positionOnStep, _updatedRotation, _radius, _height, _collisionLayers, _overlaps,
                    _triggerInteraction) > 0)
                return false;

            // Reject unwalkable surface normals here.
            Vector3 surfaceNormal = FindGeomOpposingNormal(sweepDirection * sweepDistance, ref hitResult);

            bool isWalkable = IsWalkable(hitResult.Collider, surfaceNormal);
            if (!isWalkable)
            {
                // Reject if normal opposes movement direction.
                bool normalTowardsMe = Vector3.Dot(displacement, surfaceNormal) < 0.0f;
                if (normalTowardsMe)
                    return false;

                // Also reject if we would end up being higher than our starting location by stepping down.
                if (Vector3.Dot(positionOnStep, _characterUp) > Vector3.Dot(inCollision.position, _characterUp))
                    return false;
            }

            // Reject moves where the downward sweep hit something very close to the edge of the capsule.
            // This maintains consistency with FindGround as well.
            if (!IsWithinEdgeTolerance(positionOnStep, hitResult.point, _radius + kContactOffset))
                return false;

            // Don't step up onto invalid surfaces if traveling higher.
            if (deltaY > 0.0f && !CanStepUp(hitResult.Collider))
                return false;

            // Output new position on step.
            stepResult = new CollisionResult
            {
                position = positionOnStep
            };

            return true;
        }

        /// <summary>
        /// Tests if the character would collide with anything, if it was moved through the Scene.
        /// Returns True when the rigidbody sweep intersects any collider, otherwise false.
        /// </summary>
        private bool SweepTest(Vector3 sweepOrigin, float sweepRadius, Vector3 sweepDirection, float sweepDistance,
            int sweepLayerMask, out CqRaycastHit hitResult, out bool startPenetrating)
        {
            // Cast further than the distance we need, to try to take into account small edge cases (e.g. Casts fail 
            // when moving almost parallel to an obstacle for small distances).
            hitResult = default;

            bool innerCapsuleHit =
                CapsuleCast(sweepOrigin, sweepRadius, sweepDirection, sweepDistance + sweepRadius, sweepLayerMask,
                    out var innerCapsuleHitResult, out startPenetrating) &&
                innerCapsuleHitResult.distance <= sweepDistance;

            float outerCapsuleRadius = sweepRadius + kContactOffset;

            bool outerCapsuleHit =
                CapsuleCast(sweepOrigin, outerCapsuleRadius, sweepDirection, sweepDistance + outerCapsuleRadius,
                    sweepLayerMask, out var outerCapsuleHitResult, out _) &&
                outerCapsuleHitResult.distance <= sweepDistance;

            bool foundBlockingHit = innerCapsuleHit || outerCapsuleHit;
            if (!foundBlockingHit)
                return false;

            if (!outerCapsuleHit)
            {
                hitResult = innerCapsuleHitResult;
                hitResult.distance = Mathf.Max(0.0f, hitResult.distance - kContactOffset);
            }
            else if (innerCapsuleHit && innerCapsuleHitResult.distance < outerCapsuleHitResult.distance)
            {
                hitResult = innerCapsuleHitResult;
                hitResult.distance = Mathf.Max(0.0f, hitResult.distance - kContactOffset);
            }
            else
            {
                hitResult = outerCapsuleHitResult;
                hitResult.distance = Mathf.Max(0.0f, hitResult.distance - kSmallContactOffset);
            }

            return true;
        }

        /// <summary>
        /// Return true if the 2D distance to the impact point is inside the edge tolerance (CapsuleRadius minus a small rejection threshold).
        /// Useful for rejecting adjacent hits when finding a ground or landing spot.
        /// </summary>
        public bool IsWithinEdgeTolerance(Vector3 characterPosition, Vector3 inPoint, float testRadius)
        {
            float distFromCenterSq = (inPoint - characterPosition).projectedOnPlane(_characterUp).sqrMagnitude;

            if (direction == Direction.Y)
            {
                float reducedRadius = Mathf.Max(kSweepEdgeRejectDistance + kKindaSmallNumber,// 当胶囊体是竖着的时候，碰撞点与center的偏差小于半径的平方都是合法的
                    testRadius - kSweepEdgeRejectDistance);
                return distFromCenterSq < reducedRadius * reducedRadius;
            }
            else
            {
                float reducedHeight = 0.25f * _height * _height; // 当胶囊体是横着的时候，碰撞点与center的偏差小于半高的平方都是合法的
                return distFromCenterSq < reducedHeight * reducedHeight;
            }           
        }

        /// <summary>
        /// Updates current ground result.
        /// </summary>
        private void UpdateCurrentGround(ref FindGroundResult inGroundResult)
        {
            wasOnGround = isOnGround;
            _currentGround = inGroundResult;
        }

        /// <summary>
        /// Sweeps the character's volume along its displacement vector, stopping at near hit point if collision is detected or applies full displacement if not.
        /// Returns True when the rigidbody sweep intersects any collider, otherwise false.
        /// </summary>
        private bool MovementSweepTest(Vector3 characterPosition, Vector3 inVelocity, Vector3 displacement,
            out CollisionResult collisionResult)
        {
            collisionResult = default;

            Vector3 sweepOrigin = characterPosition;
            Vector3 sweepDirection = displacement.normalized;

            float sweepRadius = _radius;
            float sweepDistance = displacement.magnitude;

            int sweepLayerMask = _collisionLayers;

            bool hit = SweepTestEx(sweepOrigin, sweepRadius, sweepDirection, sweepDistance, sweepLayerMask,
                out var hitResult, out bool startPenetrating, out Vector3 recoverDirection,
                out float recoverDistance);

            if (startPenetrating)
            {
                // Handle initial penetrations
                Vector3 requestedAdjustement =
                    recoverDirection * (recoverDistance + kContactOffset + kPenetrationOffset);

                if (ResolvePenetration(displacement, requestedAdjustement))
                {
                    // Retry original movement
                    sweepOrigin = _updatedPosition;
                    hit = SweepTestEx(sweepOrigin, sweepRadius, sweepDirection, sweepDistance, sweepLayerMask,
                        out hitResult, out startPenetrating, out _, out _);
                }
            }

            if (!hit)
                return false;

            HitLocation hitLocation = ComputeHitLocation(hitResult.normal);

            Vector3 displacementToHit = sweepDirection * hitResult.distance;
            Vector3 remainingDisplacement = displacement - displacementToHit;

            Vector3 hitPosition = sweepOrigin + displacementToHit;

            Vector3 surfaceNormal = hitResult.normal;

            bool isWalkable = false;
            bool hitGround = hitLocation == HitLocation.Below;

            if (hitGround)
            {
                surfaceNormal = FindGeomOpposingNormal(displacement, ref hitResult);

                isWalkable = IsWalkable(hitResult.Collider, surfaceNormal);
            }

            var tempHitCollider = hitResult.Collider;
            var rigidActor = tempHitCollider.attachedRigidActor;
            bool haveRigidActor = rigidActor != null;
            var hitCC = GetCharacterMovement(tempHitCollider);
            collisionResult = new CollisionResult
            {
                startPenetrating = startPenetrating,
                hitLocation = hitLocation,
                isWalkable = isWalkable,
                position = hitPosition,

                velocity = inVelocity,
                otherVelocity = hitCC ? hitCC.velocity : Vector3.zero,

                point = hitResult.point,
                normal = hitResult.normal,

                surfaceNormal = surfaceNormal,

                displacementToHit = displacementToHit,
                remainingDisplacement = remainingDisplacement,
                rigidActor = rigidActor,
                collider = tempHitCollider,
                transform = haveRigidActor ? rigidActor.transform : tempHitCollider.transform,
                hitResult = hitResult,
                isRigidbodyCollider = haveRigidActor && rigidActor.transform == tempHitCollider.transform,
                characterMovement = hitCC,
            };

            return true;
        }

        /// <summary>
        /// Tests if the character would collide with anything, if it was moved through the Scene.
        /// Returns True when the rigidbody sweep intersects any collider, otherwise false.
        /// Unlike previous version this correctly restun (if deried) valid hits for blocking overlaps along with MTD to resolve penetration.
        /// </summary>
        private bool SweepTestEx(Vector3 sweepOrigin, float sweepRadius, Vector3 sweepDirection, float sweepDistance,
            int sweepLayerMask,
            out CqRaycastHit hitResult, out bool startPenetrating, out Vector3 recoverDirection,
            out float recoverDistance, bool ignoreBlockingOverlaps = false)
        {
            // Cast further than the distance we need, to try to take into account small edge cases (e.g. Casts fail 
            // when moving almost parallel to an obstacle for small distances).
            hitResult = default;
            using (ProfilerDefine.SweepTestExPMarker.Auto())
            {
                bool innerCapsuleHit =
                    CapsuleCastEx(sweepOrigin, sweepRadius, sweepDirection, sweepDistance + sweepRadius, sweepLayerMask,
                        out var innerCapsuleHitResult, out startPenetrating, out recoverDirection,
                        out recoverDistance, ignoreBlockingOverlaps) && innerCapsuleHitResult.distance <= sweepDistance;
                
                if (innerCapsuleHit && startPenetrating)
                {
                    hitResult = innerCapsuleHitResult;
                    hitResult.distance = Mathf.Max(0.0f, hitResult.distance - kSmallContactOffset);
                    return true;
                }

                float outerCapsuleRadius = sweepRadius + kContactOffset;

                bool outerCapsuleHit =
                    CapsuleCast(sweepOrigin, outerCapsuleRadius, sweepDirection, sweepDistance + outerCapsuleRadius,
                        sweepLayerMask, out var outerCapsuleHitResult, out _) &&
                    outerCapsuleHitResult.distance <= sweepDistance;

                bool foundBlockingHit = innerCapsuleHit || outerCapsuleHit;
                if (!foundBlockingHit)
                {
                    return false;
                }


                if (!outerCapsuleHit)
                {
                    hitResult = innerCapsuleHitResult;
                    hitResult.distance = Mathf.Max(0.0f, hitResult.distance - kContactOffset);
                }
                else if (innerCapsuleHit && innerCapsuleHitResult.distance < outerCapsuleHitResult.distance)
                {
                    hitResult = innerCapsuleHitResult;
                    hitResult.distance = Mathf.Max(0.0f, hitResult.distance - kContactOffset);
                }
                else
                {
                    hitResult = outerCapsuleHitResult;
                    hitResult.distance = Mathf.Max(0.0f, hitResult.distance - kSmallContactOffset);
                }

                return true;
            }
        }

        private bool ResolvePenetration(Vector3 displacement, Vector3 proposedAdjustment)
        {
            using (ProfilerDefine.ResolvePenetrationPMarker.Auto())
            {
                Vector3 adjustment = proposedAdjustment;
            if (adjustment.isZero())
            {
                return false;
            }

            // We really want to make sure that precision differences or differences between the overlap test and sweep tests don't put us into another overlap,
            // so make the overlap test a bit more restrictive.
            const float kOverlapInflation = 0.001f;

            if (!(OverlapTest(_updatedPosition + adjustment, _updatedRotation, _radius + kOverlapInflation, _height,
                    _collisionLayers, _overlaps, _triggerInteraction) > 0))
            {
                // Safe to move without sweeping
                _updatedPosition += adjustment;
                return true;
            }
            else
            {
                Vector3 lastPosition = _updatedPosition;

                // Try sweeping as far as possible, ignoring non-blocking overlaps, otherwise we wouldn't be able to sweep out of the object to fix the penetration.
                bool hit = CapsuleCastEx(_updatedPosition, _radius, adjustment.normalized, adjustment.magnitude,
                    _collisionLayers,
                    out var sweepHitResult, out bool startPenetrating, out Vector3 recoverDirection,
                    out float recoverDistance, true);

                if (!hit)
                    _updatedPosition += adjustment;
                else
                    _updatedPosition += adjustment.normalized *
                                        Mathf.Max(sweepHitResult.distance - kSmallContactOffset, 0.0f);

                // Still stuck?
                bool moved = _updatedPosition != lastPosition;
                if (!moved && startPenetrating)
                {
                    // Combine two MTD results to get a new direction that gets out of multiple surfaces.
                    Vector3 secondMTD = recoverDirection * (recoverDistance + kContactOffset + kPenetrationOffset);
                    Vector3 combinedMTD = adjustment + secondMTD;

                    if (secondMTD != adjustment && !combinedMTD.isZero())
                    {
                        lastPosition = _updatedPosition;

                        hit = CapsuleCastEx(_updatedPosition, _radius, combinedMTD.normalized, combinedMTD.magnitude,
                            _collisionLayers, out sweepHitResult, out _, out _, out _, true);

                        if (!hit)
                            _updatedPosition += combinedMTD;
                        else
                            _updatedPosition += combinedMTD.normalized *
                                                Mathf.Max(sweepHitResult.distance - kSmallContactOffset, 0.0f);

                        moved = _updatedPosition != lastPosition;
                    }
                }

                // Still stuck?
                if (!moved)
                {
                    // Try moving the proposed adjustment plus the attempted move direction.
                    // This can sometimes get out of penetrations with multiple objects.
                    Vector3 moveDelta = displacement;
                    if (!moveDelta.isZero())
                    {
                        lastPosition = _updatedPosition;

                        Vector3 newAdjustment = adjustment + moveDelta;
                        hit = CapsuleCastEx(_updatedPosition, _radius, newAdjustment.normalized,
                            newAdjustment.magnitude,
                            _collisionLayers, out sweepHitResult, out _, out _, out _, true);

                        if (!hit)
                            _updatedPosition += newAdjustment;
                        else
                            _updatedPosition += newAdjustment.normalized *
                                                Mathf.Max(sweepHitResult.distance - kSmallContactOffset, 0.0f);

                        moved = _updatedPosition != lastPosition;

                        // Finally, try the original move without MTD adjustments, but allowing depenetration along the MTD normal.
                        // This was blocked because ignoreBlockingOverlaps was false for the original move to try a better depenetration normal, but we might be running in to other geometry in the attempt.
                        // This won't necessarily get us all the way out of penetration, but can in some cases and does make progress in exiting the penetration.
                        if (!moved && Vector3.Dot(moveDelta, adjustment) > 0.0f)
                        {
                            lastPosition = _updatedPosition;

                            hit = CapsuleCastEx(_updatedPosition, _radius, moveDelta.normalized, moveDelta.magnitude,
                                _collisionLayers, out sweepHitResult, out _, out _, out _, true);

                            if (!hit)
                                _updatedPosition += moveDelta;
                            else
                                _updatedPosition += moveDelta.normalized *
                                                    Mathf.Max(sweepHitResult.distance - kSmallContactOffset, 0.0f);

                            moved = _updatedPosition != lastPosition;
                        }
                    }
                }

                return moved;
            }
            }
        }

        /// <summary>
        /// Check the given capsule against the physics world and return all overlapping colliders.
        /// Return overlapped colliders count.
        /// </summary>
        public int OverlapTest(Vector3 characterPosition, Quaternion characterRotation, float testRadius,
            float testHeight, int layerMask, CqCollider[] results, QueryTriggerInteraction queryTriggerInteraction)
        {
            MakeCapsule(testRadius, testHeight, new Vector3(0, 0, 0), out Vector3 bottomCenter, out Vector3 topCenter);

            Vector3 top = characterPosition + characterRotation * topCenter;
            Vector3 bottom = characterPosition + characterRotation * bottomCenter;

            // int rawOverlapCount =
            //     Physics.OverlapCapsuleNonAlloc(bottom, top, testRadius, results, layerMask, queryTriggerInteraction);

            int rawOverlapCount =
                X3Physics.Collision.CapsuleOverlap(new CqCapsule(bottom, top, testRadius), results, _collisionLayers);
            
            if (rawOverlapCount == 0)
                return 0;

            int filteredOverlapCount = rawOverlapCount;

            for (int i = 0; i < rawOverlapCount; i++)
            {
                var overlappedCollider = results[i];

                if (ShouldFilter(overlappedCollider))
                {
                    if (i < --filteredOverlapCount)
                        results[i] = results[filteredOverlapCount];
                }
            }

            return filteredOverlapCount;
        }

        /// <summary>
        /// Helper function to create a capsule of given dimensions.
        /// </summary>
        /// <param name="radius">The capsule radius.</param>
        /// <param name="height">The capsule height.</param>
        /// <param name="center">Output capsule center in local space.</param>
        /// <param name="bottomCenter">Output capsule bottom sphere center in local space.</param>
        /// <param name="topCenter">Output capsule top sphere center in local space.</param>
        private void MakeCapsule(float radius, float height, Vector3 center, out Vector3 bottomCenter,
            out Vector3 topCenter)
        {
            radius = Mathf.Max(radius, 0.0f);
            height = Mathf.Max(height, radius * 2.0f);


            float sideHeight = height - radius * 2.0f;

            if (direction == Direction.Y)
            {
                bottomCenter = center - sideHeight * 0.5f * Vector3.up;
                topCenter = center + sideHeight * 0.5f * Vector3.up;
            }
            else if (direction == Direction.X)
            {
                bottomCenter = center - sideHeight * 0.5f * Vector3.right;
                topCenter = center + sideHeight * 0.5f * Vector3.right;
            }
            else
            {
                bottomCenter = center - sideHeight * 0.5f * Vector3.forward;
                topCenter = center + sideHeight * 0.5f * Vector3.forward;
            }
        }

        /// <summary>
        /// Casts a capsule against all colliders in the Scene and returns detailed information on what was hit.
        /// Returns True when the capsule sweep intersects any collider, otherwise false. 
        /// Unlike previous version this correctly restun (if deried) valid hits for blocking overlaps along with MTD to resolve penetration.
        /// </summary>
        private bool CapsuleCastEx(Vector3 characterPosition, float castRadius, Vector3 castDirection,
            float castDistance, int layerMask, out CqRaycastHit hitResult, out bool startPenetrating,
            out Vector3 recoverDirection,
            out float recoverDistance, bool ignoreNonBlockingOverlaps = false)
        {
            hitResult = default;

            startPenetrating = default;
            recoverDirection = default;
            recoverDistance = default;

            Vector3 top = characterPosition + _transformedCapsuleTopCenter;
            Vector3 bottom = characterPosition + _transformedCapsuleBottomCenter;

            // int rawHitCount =
            //     Physics.CapsuleCastNonAlloc(bottom, top, castRadius, castDirection, _hits, castDistance, layerMask,
            //         _triggerInteraction);
            
            // 半径缩小的原因，在下面重载的接口内
            using (ProfilerDefine.CapsuleCastExPMarker.Auto())
            {

                int rawHitCount =
                    X3Physics.Collision.CapsuleCast(new CqCapsule(bottom, top, castRadius - kSmallContactOffset),
                        castDirection, castDistance, _hits, _collisionLayers);

                if (rawHitCount == 0)
                {
                    return false;
                }


                float closestDis = float.MaxValue;
                int closestIndex = -1;
                for (int i = 0; i < rawHitCount; i++)
                {
                    ref var hit = ref _hits[i];
                    if (ShouldFilter(hit.Collider))
                        continue;

                    bool isOverlapping = hit.distance <= 0.0f;
                    if (isOverlapping)
                    {
                        if (ComputeMTD(characterPosition, _updatedRotation, hit.Collider, hit.Collider.transform,
                                out Vector3 mtdDirection, out float mtdDistance))
                        {
                            HitLocation hitLocation = ComputeHitLocation(mtdDirection);

                            Vector3 point;
                            if (hitLocation == HitLocation.Above)
                                point = characterPosition + _transformedCapsuleTopCenter - mtdDirection * _radius;
                            else if (hitLocation == HitLocation.Below)
                                point = characterPosition + _transformedCapsuleBottomCenter - mtdDirection * _radius;
                            else
                                point = characterPosition + _transformedCapsuleCenter - mtdDirection * _radius;

                            Vector3 impactNormal =
                                ComputeBlockingNormal(mtdDirection, IsWalkable(hit.Collider, mtdDirection));

                            hit.point = point;
                            hit.normal = impactNormal;
                            hit.distance = -mtdDistance;
                        }
                    }

                    if (closestDis > hit.distance)
                    {
                        closestDis = hit.distance;
                        closestIndex = i;
                    }
                }

                float mostOpposingDot = Mathf.Infinity;
                int hitIndex = -1;
                for (int i = 0; i < rawHitCount; i++)
                {
                    ref var hit = ref _hits[i];
                    if (ShouldFilter(hit.Collider))
                        continue;

                    // bool isOverlapping = hit.distance <= 0.0f && !hit.point.isZero();
                    bool isOverlapping = hit.distance <= 0.0f && !(math.lengthsq(hit.point) < 1e-7f);
                    if (isOverlapping)
                    {
                        // Overlaps
                        float movementDotNormal = Vector3.Dot(castDirection, hit.normal);

                        if (ignoreNonBlockingOverlaps)
                        {
                            // If we started penetrating, we may want to ignore it if we are moving out of penetration.
                            // This helps prevent getting stuck in walls.
                            bool isMovingOut = movementDotNormal > 0.0f;
                            if (isMovingOut)
                                continue;
                        }

                        if (movementDotNormal < mostOpposingDot)
                        {
                            mostOpposingDot = movementDotNormal;
                            hitIndex = i;
                        }
                    }
                }

                if (hitIndex == -1)
                {
                    hitIndex = closestIndex;
                }

                if (hitIndex >= 0)
                {
                    hitResult = _hits[hitIndex];
                    if (hitResult.distance <= 0.0f)
                    {
                        startPenetrating = true;
                        recoverDirection = hitResult.normal;
                        recoverDistance = Mathf.Abs(hitResult.distance);
                    }

                    return true;
                }

                return false;
            }
        }
        
        /// <summary>
        /// 检测从当前位置到目标点之间是否有指定Tag的障碍物，返回第一个碰到障碍物时actor的位置
        /// </summary>
        /// <param name="targetPos"></param> 目标位置
        /// <param name="tag"></param> 检测的Tag
        /// <param name="position"></param> 沿射线方向，碰到第一个障碍物时actor的位置,如果没有碰到障碍物就返回目标位置
        /// <returns></returns>
        public bool CapsuleCast(Vector3 targetPos, ColliderTag tag, out Vector3 position)
        {
            position = targetPos;
            Vector3 top = worldCenter + _transformedCapsuleTopCenter;
            Vector3 bottom = worldCenter + _transformedCapsuleBottomCenter;
            Vector3 delta = targetPos - transform.position;
            Vector3 castDirection = delta.normalized;
            float castDistance = delta.magnitude;
            
            int rawHitCount = X3Physics.Collision.CapsuleCast(
                new CqCapsule(bottom, top, _radius), castDirection, castDistance, _hits,
                _collisionLayers);
            
            if (rawHitCount == 0)
            {
                return false;
            }
            
            float closestDistance = Mathf.Infinity;
            int hitIndex = -1;
            for (int i = 0; i < rawHitCount; i++)
            {
                ref CqRaycastHit hit = ref _hits[i];
                if (ShouldFilter(hit.Collider))
                    continue;

                X3Collider collider = X3Physics.GetX3Collider(hit.Collider);

                if (collider.tag == tag)
                {
                    if (hit.distance < closestDistance)
                    {
                        closestDistance = hit.distance;
                        hitIndex = i;
                    }
                }
            }
            
            if (hitIndex != -1)
            {
				
                position = (_hits[hitIndex].distance - kContactOffset)  * castDirection + transform.position;
                return true;
            }

            return false;
        }

        /// <summary>
        /// Casts a capsule against all colliders in the Scene and returns detailed information on what was hit.
        /// Returns True when the capsule sweep intersects any collider, otherwise false. 
        /// </summary>
        private bool CapsuleCast(Vector3 characterPosition, float castRadius, Vector3 castDirection, float castDistance,
            int layerMask, out CqRaycastHit hitResult, out bool startPenetrating)
        {
            hitResult = default;
            startPenetrating = false;

            Vector3 top = characterPosition + _transformedCapsuleTopCenter;
            Vector3 bottom = characterPosition + _transformedCapsuleBottomCenter;

            // int rawHitCount = Physics.CapsuleCastNonAlloc(bottom, top, castRadius, castDirection, _hits, castDistance,
            //     layerMask, _triggerInteraction);

            // 这里把半径缩小的原因是，保证确保穿透分离时overlap检测到的collider， cast检测的数量不能多于collider
            // 举例：
            // 女主和空气墙接触的情况下， Overlap接口检测不到空气墙，但是这个cast接口能检测到。
            // 导致角色飞行过程种向下移动时，碰到空气墙而无法移动，进而无法触发onFoundGround,导致女主浮空
            using (ProfilerDefine.CapsuleCastPMarker.Auto())
            {

                int rawHitCount = X3Physics.Collision.CapsuleCast(
                    new CqCapsule(bottom, top, castRadius - kSmallContactOffset), castDirection, castDistance, _hits,
                    _collisionLayers);

                if (rawHitCount == 0)
                {
                    return false;
                }


                float closestDistance = Mathf.Infinity;

                int hitIndex = -1;
                for (int i = 0; i < rawHitCount; i++)
                {
                    ref CqRaycastHit hit = ref _hits[i];
                    if (ShouldFilter(hit.Collider))
                        continue;

                    if (hit.distance <= 0.0f)
                        startPenetrating = true;
                    else if (hit.distance < closestDistance)
                    {
                        closestDistance = hit.distance;
                        hitIndex = i;
                    }
                }

                if (hitIndex != -1)
                {
                    hitResult = _hits[hitIndex];
                    return true;
                }

                return false;
            }
        }

        /// <summary>
        /// Casts a capsule against specified colliders (by layerMask) in the Scene and returns detailed information on what was hit.
        /// </summary>
        private bool CapsuleCast(Vector3 point1, Vector3 point2, float castRadius, Vector3 castDirection,
            float castDistance, int castLayerMask, out CqRaycastHit hitResult, out bool startPenetrating)
        {
            hitResult = default;
            startPenetrating = false;

            // int rawHitCount = Physics.CapsuleCastNonAlloc(point1, point2, castRadius, castDirection, _hits,
            //     castDistance, castLayerMask, _triggerInteraction);

            int rawHitCount = X3Physics.Collision.CapsuleCast(new CqCapsule(point1, point2, castRadius), castDirection, castRadius, _hits, _collisionLayers);
            
            if (rawHitCount == 0)
                return false;

            float closestDistance = Mathf.Infinity;
            int hitIndex = -1;
            for (int i = 0; i < rawHitCount; i++)
            {
                ref var hit = ref _hits[i];
                if (ShouldFilter(hit.Collider))
                    continue;
                
                if (hit.distance <= 0.0f)
                    startPenetrating = true;
                else if (hit.distance < closestDistance)
                {
                    closestDistance = hit.distance;
                    hitIndex = i;
                }
            }

            if (hitIndex != -1)
            {
                hitResult = _hits[hitIndex];
                return true;
            }

            return false;
        }

        /// <summary>
        /// Compute the minimal translation distance (MTD) required to separate the given colliders apart at specified poses.
        /// Uses an inflated capsule for better results, try MTD with a small inflation for better accuracy, then a larger one in case the first one fails due to precision issues.
        /// </summary>
        private bool ComputeMTD(Vector3 characterPosition, Quaternion characterRotation, CqCollider hitCollider,
            Transform hitTransform, out Vector3 mtdDirection, out float mtdDistance)
        {
            const float kSmallMTDInflation = 0.0025f;
            const float kLargeMTDInflation = 0.0175f;
            if (ComputeInflatedMTD(characterPosition, characterRotation, kSmallMTDInflation, hitCollider, hitTransform,
                    out mtdDirection, out mtdDistance) ||
                ComputeInflatedMTD(characterPosition, characterRotation, kLargeMTDInflation, hitCollider, hitTransform,
                    out mtdDirection, out mtdDistance))
            {
                // Success
                return true;
            }
            // Failure
            return false;
        }

        /// <summary>
        /// Compute the minimal translation distance (MTD) required to separate the given colliders apart at specified poses.
        /// Uses an inflated capsule for better results.
        /// </summary>
        private bool ComputeInflatedMTD(Vector3 characterPosition, Quaternion characterRotation, float mtdInflation,
            CqCollider hitCollider, Transform hitTransform, out Vector3 mtdDirection, out float mtdDistance)
        {
            mtdDirection = Vector3.zero;
            mtdDistance = 0.0f;

            _capsuleCollider.Radius = _radius + mtdInflation * 1.0f;
            _capsuleCollider.Height = _height + mtdInflation * 2.0f;

            // bool mtdResult = Physics.ComputePenetration(_capsuleCollider, characterPosition, characterRotation,
            //     hitCollider, hitTransform.position, hitTransform.rotation, out Vector3 recoverDirection,
            //     out float recoverDistance);
            // if (mtdResult)
            // {
            //     if (IsFinite(recoverDirection))
            //     {
            //         mtdDirection = recoverDirection;
            //         mtdDistance = Mathf.Max(Mathf.Abs(recoverDistance) - mtdInflation, 0.0f) + kKindaSmallNumber;
            //     }
            //     else
            //     {
            //         Debug.LogWarning($"Warning: ComputeInflatedMTD_Internal: MTD returned NaN " +
            //                          recoverDirection.ToString("F4"));
            //     }
            // }
            
            // out Vector3 recoverDirection, out float recoverDistance);
            bool mtdResult;
            CqContact contact;
            using (ProfilerDefine.CqColliderComputeContactPMarker.Auto())
            {
                mtdResult = CqCollider.ComputeContact(_capsuleCollider, characterPosition, characterRotation,
                    hitCollider, hitTransform.position, hitTransform.rotation, out contact);
            }

            if (mtdResult)
            {
                if (IsFinite(contact.depth))
                {
                    mtdDirection = contact.normal;
                    mtdDistance = Mathf.Max(Mathf.Abs(contact.depth) - mtdInflation, 0.0f) + kKindaSmallNumber;
                }
                else
                {
                    Debug.LogWarning($"Warning: ComputeInflatedMTD_Internal: MTD returned NaN " + contact.normal);
                }
            }
            
            _capsuleCollider.Radius = _radius;
            _capsuleCollider.Height = _height;
            return mtdResult;
        }

        /// <summary>
        /// When moving on walkable ground, and hit a non-walkable, modify hit normal (eg: the blocking hit normal)
        /// since We don't want to be pushed up an unwalkable surface,
        /// or be pushed down into the ground when the impact is on the upper portion of the capsule.
        /// </summary>
        private Vector3 ComputeBlockingNormal(Vector3 inNormal, bool isWalkable)
        {
            if ((isOnWalkableGround || _hasLanded) && !isWalkable)
            {
                using (ProfilerDefine.ComputeBlockingNormalPMarker.Auto())
                {
                    Vector3 actualGroundNormal = _hasLanded ? _foundGround.normal : _currentGround.normal;

                    Vector3 forward = actualGroundNormal.perpendicularTo(inNormal);
                    Vector3 blockingNormal = forward.perpendicularTo(_characterUp);

                    if (Vector3.Dot(blockingNormal, inNormal) < 0.0f)
                        blockingNormal = -blockingNormal;

                    if (!blockingNormal.isZero())
                        inNormal = blockingNormal;
                    return inNormal;
                }
            }

            return inNormal;
        }

        /// <summary>
        /// Determines if the given collider should be filtered (ignored) or not.
        /// Return true to filter collider (e.g. Ignore it), false otherwise.
        /// </summary>
        private bool ShouldFilter(CqCollider otherCollider)
        {
            using (ProfilerDefine.ShouldFilterPMarker.Auto())
            {
                // gameObject 上以及其child上的所有Collider必须加入忽略列表
                if (_ignoredColliders.Contains(otherCollider))
                {
                    return true;
                }

                // 如果collider，需要忽略碰撞，则忽略
                if (X3LayerMask.ActorCollider == (otherCollider.ExcludeLayers & X3LayerMask.ActorCollider))
                {
                    return true;
                }

                bool retValue = !ReferenceEquals(colliderFilterCallback, null) && colliderFilterCallback.Invoke(otherCollider);
                return retValue;
            }
        }

        /// <summary>
        ///  竖直的Capsule，水平或者竖直向下的检测，是否是错误的结果
        ///  错误结果判定：竖直胶囊下半球的圆心，距离碰撞点的距离大于半径 + hit.Distance
        /// </summary>
        /// <param name="bottom">胶囊体下班球的球心</param>
        /// <param name="hitInfo">碰撞信息</param>
        /// <returns></returns>
        private bool IsErrorCapsuleHit(Vector3 bottom, Vector3 top, float radius, Vector3 castDir, float castDis,
            ref CqRaycastHit hit, int castLayerMask)
        {
            var tempVec = bottom - top;
            // 竖直的capsule
            bool isRotateXZ = !IsZero(tempVec.x) || !IsZero(tempVec.z);
            if (isRotateXZ)
                return false;
            // 竖直向下检测
            bool isVerticalCast = IsZero(castDir.x) && IsZero(castDir.z) && IsZero(-1 - castDir.y);
            // 水平检测
            bool isHorizontalCast = IsZero(castDir.y);

            if (!isVerticalCast && !isHorizontalCast)
                return false;

            // 竖直的capsule， 竖直向下或者水平检测时， 屏蔽掉错误的检测结果，极少出现
            // 错误结果1：竖直胶囊下半球的圆心，距离碰撞点的距离大于半径 + hit.Distance
            // 错误的结果2：竖直胶囊下半球的圆心，距离碰撞点的距离等于半径 + hit.Distance。 但是该碰撞点不会产生碰撞
            // 判定：和射线检测的结果，对比，需要一致才是正确的检测结果
            // int hitNum =
                // Physics.RaycastNonAlloc(bottom, castDir, _rayHits, castDis, castLayerMask, _triggerInteraction);
            int hitNum = X3Physics.Collision.RayCast(new CqRay(bottom, castDir), castDis, _rayHits, _collisionLayers);
            float calHitDis = hit.distance;
            for (int i = 0; i < hitNum; i++)
            {
                if (_rayHits[i].Collider != hit.Collider)
                    continue;
                calHitDis = _rayHits[i].distance - radius;
            }

            if (!IsZero(calHitDis - hit.distance))
            {
                // 重新计算，hitDis 和 hitPoint
                hit.distance = calHitDis;
                hit.point = bottom + castDir * calHitDis;
                return false;
            }

            return false;
        }

        private bool IsFinite(float value)
        {
            return !float.IsNaN(value) && !float.IsInfinity(value);
        }

        private bool IsFinite(Vector3 value)
        {
            return IsFinite(value.x) && IsFinite(value.y) && IsFinite(value.z);
        }

        /// <summary>
        /// 用于判定向量的分量在支持的精度内是否是零
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        private bool IsZero(float value)
        {
            // 精度太大 0.00001
            // if (Mathf.Abs(value) - Vector3.kEpsilon <= Vector3.kEpsilon)
            // {
            //     return true;
            // }
            // 精度缩小， 改为 0.0001
            if (Mathf.Abs(value) - 1E-04f <= 1E-04f)
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// Determines the hit location WRT capsule for the given normal.
        /// </summary>
        private HitLocation ComputeHitLocation(Vector3 inNormal)
        {
            float verticalComponent = inNormal.dot(_characterUp);

            if (verticalComponent > kHemisphereLimit)
                return HitLocation.Below;

            return verticalComponent < -kHemisphereLimit ? HitLocation.Above : HitLocation.Sides;
        }

        /// <summary>
        /// Helper method to retrieve real surface normal, usually the most 'opposing' to sweep direction.
        /// </summary>
        private Vector3 FindGeomOpposingNormal(Vector3 sweepDirDenorm, ref CqRaycastHit inHit)
        {
            // SphereCollider or CapsuleCollider
            if (inHit.Collider is CqSphereCollider _ || inHit.Collider is CqCapsuleCollider _)
            {
                // We don't compute anything special, inHit.normal is the correct one.
                return inHit.normal;
            }

            // BoxCollider
            if (inHit.Collider is CqBoxCollider _)
            {
                return FindBoxOpposingNormal(sweepDirDenorm, inHit.Collider.transform, inHit.normal);
            }

            // // Non-Convex MeshCollider (MUST BE read / write enabled!)
            // if (inHit.collider is MeshCollider nonConvexMeshCollider && !nonConvexMeshCollider.convex)
            // {
            //     Mesh sharedMesh = nonConvexMeshCollider.sharedMesh;
            //     if (sharedMesh && sharedMesh.isReadable)
            //         return MeshUtility.FindMeshOpposingNormal(sharedMesh, ref inHit);
            //
            //     // No read / write enabled, fallback to a raycast...
            //     return FindOpposingNormal(sweepDirDenorm, ref inHit);
            // }
            //
            // // Convex MeshCollider
            // if (inHit.collider is MeshCollider convexMeshCollider && convexMeshCollider.convex)
            // {
            //     // No data exposed by Unity to compute normal. Fallback to a raycast...
            //     return FindOpposingNormal(sweepDirDenorm, ref inHit);
            // }
            //
            // // Terrain collider
            // if (inHit.collider is TerrainCollider)
            // {
            //     // return FindTerrainOpposingNormal(ref inHit);
            //     // fallback to a raycast...
            //     return FindOpposingNormal(sweepDirDenorm, ref inHit);
            // }

            return inHit.normal;
        }

        private static Vector3 FindBoxOpposingNormal(Vector3 displacement, Transform hitTransform, Vector3 hitNormal)
        {
            using (ProfilerDefine.FindBoxOpposingNormalPMarker.Auto())
            {
                Transform localToWorld = hitTransform;

                Vector3 localContactNormal = localToWorld.InverseTransformDirection(hitNormal);
                Vector3 localTraceDirDenorm = localToWorld.InverseTransformDirection(displacement);

                Vector3 bestLocalNormal = localContactNormal;
                float bestOpposingDot = float.MaxValue;

                for (int i = 0; i < 3; i++)
                {
                    if (localContactNormal[i] > kKindaSmallNumber)
                    {
                        float traceDotFaceNormal = localTraceDirDenorm[i];
                        if (traceDotFaceNormal < bestOpposingDot)
                        {
                            bestOpposingDot = traceDotFaceNormal;
                            bestLocalNormal = Vector3.zero;
                            bestLocalNormal[i] = 1.0f;
                        }
                    }
                    else if (localContactNormal[i] < -kKindaSmallNumber)
                    {
                        float traceDotFaceNormal = -localTraceDirDenorm[i];
                        if (traceDotFaceNormal < bestOpposingDot)
                        {
                            bestOpposingDot = traceDotFaceNormal;
                            bestLocalNormal = Vector3.zero;
                            bestLocalNormal[i] = -1.0f;
                        }
                    }
                }

                return localToWorld.TransformDirection(bestLocalNormal);
            }
        }

        private Vector3 FindOpposingNormal(Vector3 sweepDirDenorm, ref RaycastHit inHit)
        {
            const float kThickness = (kContactOffset - kSweepEdgeRejectDistance) * 0.5f;

            Vector3 result = inHit.normal;
            Vector3 rayOrigin = inHit.point - sweepDirDenorm;
            float rayLength = sweepDirDenorm.magnitude * 2f;
            Vector3 rayDirection = sweepDirDenorm / sweepDirDenorm.magnitude;

            if (Raycast(rayOrigin, rayDirection, rayLength, _collisionLayers, out CqRaycastHit hitResult, kThickness))
                result = hitResult.normal;

            return result;
        }

        /// <summary>
        /// Casts a ray, from point origin, in direction direction, of length distance, against specified colliders (by layerMask) in the Scene.
        /// </summary>
        public bool Raycast(Vector3 origin, Vector3 direction, float distance, int layerMask, out CqRaycastHit hitResult,
            float thickness = 0.0f)
        {
            hitResult = default;

            // int rawHitCount = thickness == 0.0f
            //     ? Physics.RaycastNonAlloc(origin, direction, _hits, distance, layerMask, _triggerInteraction)
            //     : Physics.SphereCastNonAlloc(origin - direction * thickness, thickness, direction, _hits, distance,
            //         layerMask, _triggerInteraction);
            
            int rawHitCount = thickness == 0.0f
                ? X3Physics.Collision.RayCast(new CqRay(origin, direction), distance, _hits, _collisionLayers)
                : X3Physics.Collision.SphereCast(new CqSphere(origin - direction * thickness, thickness), 
                    direction, distance, _hits, _collisionLayers);

            if (rawHitCount == 0)
                return false;

            float closestDistance = Mathf.Infinity;

            int hitIndex = -1;
            for (int i = 0; i < rawHitCount; i++)
            {
                ref var hit = ref _hits[i];
                if (hit.distance <= 0.0f || ShouldFilter(hit.Collider))
                    continue;

                if (hit.distance < closestDistance)
                {
                    closestDistance = hit.distance;
                    hitIndex = i;
                }
            }

            if (hitIndex != -1)
            {
                hitResult = _hits[hitIndex];
                return true;
            }

            return false;
        }

        /// <summary>
        /// Determines if the given collider and impact normal should be considered as walkable ground.
        /// </summary>
        private bool IsWalkable(CqCollider inCollider, Vector3 inNormal)
        {
            // Do not bother if hit is not in capsule bottom sphere

            if (ComputeHitLocation(inNormal) != HitLocation.Below)
                return false;

            // If collision behavior callback is assigned, check walkable / not walkable flags
            if (collisionBehaviorCallback != null)
            {
                CollisionBehavior collisionBehavior = collisionBehaviorCallback.Invoke(inCollider);

                if (IsWalkable(collisionBehavior))
                    return Vector3.Dot(inNormal, _characterUp) > kMaxWalkableSlopeLimit;

                if (IsNotWalkable(collisionBehavior))
                    return Vector3.Dot(inNormal, _characterUp) > kMinWalkableSlopeLimit;
            }

            // Determine if the given normal is walkable
            return Vector3.Dot(inNormal, _characterUp) > _minSlopeLimit;
        }


        /// <summary>
        /// Helper method to test if given behavior flags contains CollisionBehavior.Walkable value.
        /// </summary>
        private static bool IsWalkable(CollisionBehavior behaviorFlags)
        {
            return (behaviorFlags & CollisionBehavior.Walkable) != 0;
        }

        /// <summary>
        /// Helper method to test if given behavior flags contains CollisionBehavior.NotWalkable value.
        /// </summary>
        private static bool IsNotWalkable(CollisionBehavior behaviorFlags)
        {
            return (behaviorFlags & CollisionBehavior.NotWalkable) != 0;
        }

        /// <summary>
        /// Determines if can perch on other collider depending CollisionBehavior flags (if any).
        /// </summary>
        private bool CanPerchOn(CqCollider otherCollider)
        {
            // Validate input collider
            if (otherCollider == null)
                return false;

            // If collision behavior callback is assigned, use it
            if (collisionBehaviorCallback != null)
            {
                CollisionBehavior tempCollisionBehavior = collisionBehaviorCallback.Invoke(otherCollider);
                if (CanPerchOn(tempCollisionBehavior))
                    return true;
                if (CanNotPerchOn(tempCollisionBehavior))
                    return false;
            }
            // Default case, managed by perchOffset
            return true;
        }

        /// <summary>
        /// Helper method to test if given behavior flags contains CollisionBehavior.CanPerchOn value.
        /// </summary>
        private static bool CanPerchOn(CollisionBehavior behaviorFlags)
        {
            return (behaviorFlags & CollisionBehavior.CanPerchOn) != 0;
        }

        /// <summary>
        /// Helper method to test if given behavior flags contains CollisionBehavior.CanNotPerchOn value.
        /// </summary>
        private static bool CanNotPerchOn(CollisionBehavior behaviorFlags)
        {
            return (behaviorFlags & CollisionBehavior.CanNotPerchOn) != 0;
        }

        /// <summary>
        /// Helper method to test if given behavior flags contains CollisionBehavior.CanStepOn value.
        /// </summary>
        private static bool CanStepOn(CollisionBehavior behaviorFlags)
        {
            return (behaviorFlags & CollisionBehavior.CanStepOn) != 0;
        }

        /// <summary>
        /// Helper method to test if given behavior flags contains CollisionBehavior.CanNotStepOn value.
        /// </summary>
        private static bool CanNotStepOn(CollisionBehavior behaviorFlags)
        {
            return (behaviorFlags & CollisionBehavior.CanNotStepOn) != 0;
        }
        
        private CharacterMovement GetCharacterMovement(CqCollider collider)
        {
            // 这里设定， CharacterMovement组件只能挂载在root节点上
            var x3Collider = X3Physics.GetX3Collider(collider);
            if (x3Collider is X3ActorCollider x3ActorCollider)
            {
                return x3ActorCollider.CharacterMovement;
            }
            return null;
        }
        

        /// <summary>
        /// Add a CollisionResult to collisions list found during Move.
        /// If CollisionResult is vs otherRigidbody add first one only.
        /// </summary>
        private void AddCollisionResult(ref CollisionResult collisionResult)
        {
            UpdateCollisionFlags(collisionResult.hitLocation);

            if (collisionResult.rigidActor)
            {
                // We only care about the first collision with a rigidbody
                for (int i = 0; i < _collisionCount; i++)
                {
                    if (collisionResult.rigidActor == _collisionResults[i].rigidActor)
                        return;
                }
            }

            if (_collisionCount < kMaxCollisionCount)
                _collisionResults[_collisionCount++] = collisionResult;
        }

        private void UpdateCollisionFlags(HitLocation hitLocation)
        {
            collisionFlags |= (CollisionFlags)hitLocation;
        }
        
        # region 组件默认值， 初始逻辑
        public void InitCollisionMask()
        {
            int layer = gameObject.layer;
            _collisionLayers = 0;
            for (int i = 0; i < 32; i++)
            {
                if (!Physics.GetIgnoreLayerCollision(layer, i))
                    _collisionLayers |= 1 << i;
            }
        }

        public void SetDimensions(float characterRadius, float characterHeight, float3 Center, Direction direction)
        {
            // 0.1f 为配置异常时的保底措施
            _radius = Mathf.Max(characterRadius, 0.1f);
            _height = Mathf.Max(characterHeight, characterRadius * 2.0f);
            _capsuleCenter = Center;
            _direction = direction;

            MakeCapsule(_radius, _height, _capsuleCenter, out _capsuleBottomCenter, out _capsuleTopCenter);

#if UNITY_EDITOR
            if (_capsuleCollider == null)
                _capsuleCollider = GetComponent<CqCapsuleCollider>();
            if (_rigidActor == null)
                _rigidActor = GetComponent<CqRigidActor>();
#endif

            if (_capsuleCollider)
            {
                _capsuleCollider.Radius = _radius;
                _capsuleCollider.Height = _height;
                _capsuleCollider.Center = Center;
                _capsuleCollider.Direction = direction;
            }
        }

        private void CacheComponents()
        {
            _capsuleCollider = GetComponent<CqCapsuleCollider>();
            _rigidActor = GetComponent<CqRigidActor>();
            if (_rigidActor != null && _capsuleCollider != null)
                _rigidActor.AttachCollider(_capsuleCollider);
            IgnoreCollision(_capsuleCollider);
        }

        // 设置默认值
        private void SetDefaultValue()
        {
            SetDimensions(0.5f, 2.0f, new float3(0, 0, 0), Direction.Y);
            _slopeLimit = 45.0f;
            _stepOffset = 0.45f;
            _perchOffset = 0.3f;
            _perchAdditionalHeight = 0.3f;

            _triggerInteraction = QueryTriggerInteraction.Ignore;
            _advanced.Reset();
            _pushForceScale = 1.0f;
            _modeCtrl = new MovementModeCtrl(this);
        }
        
        public void IgnoreCollision(CqCollider otherCollider, bool ignore = true)
        {
            if (otherCollider == null)
                return;

            if (ignore)
                _ignoredColliders.Add(otherCollider);
            else
                _ignoredColliders.Remove(otherCollider);
            // Physics.IgnoreCollision(_capsuleCollider, otherCollider, ignore);
        }
        # endregion
    }
}