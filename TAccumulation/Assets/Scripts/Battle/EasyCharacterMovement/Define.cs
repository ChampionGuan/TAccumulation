using System;
using System.Collections.Generic;
using UnityEngine;
using X3Battle;
using CollisionQuery;

namespace EasyCharacterMovement
{
    /// <summary>
    /// The hit location WRT Character's capsule, eg: Sides, Above, Below.
    /// </summary>
    public enum HitLocation
    {
        None = 0,
        Sides = 1,
        Above = 2,
        Below = 4,
    }

    public class CharacterMoveConst
    {
        public const string CollisionBehaviorTips = @"Walkable：可行走 NotWalkable：不可行走 CanPerchOn：可悬停 CanNotPerchOn：不可悬停 CanStepOn：可站立（当不可行走时，可站立) CanNotStepOn：不可站立 CanRideOn：可站立（与站立对象一起移动）CanNotRideOn：不可站立 CanNotFilterWhenIgnoreCollision：不可忽略（当忽略碰撞时）";
    }

    // /// <summary>
    // /// The character collision behavior.
    // /// </summary>
    // [Flags] 
    // public enum CollisionBehavior
    // {
    //     Default = 0,
    //
    //     /// <summary>
    //     /// Determines if the character can walk on the other collider.
    //     /// </summary>
    //     Walkable = 1 << 0, // =1  可行走
    //     NotWalkable = 1 << 1, // =2  不可行走
    //
    //     /// <summary>
    //     /// Determines if the character can perch on the other collider.
    //     /// </summary>
    //     CanPerchOn = 1 << 2, // 4   可悬停
    //     CanNotPerchOn = 1 << 3, // 8    不可悬停
    //
    //     /// <summary>
    //     /// Defines if the character can step up onto the other collider.
    //     /// </summary>
    //     CanStepOn = 1 << 4, //可站立（当不可行走时，可站立）
    //     CanNotStepOn = 1 << 5,  //不可站立
    //
    //     /// <summary>
    //     /// Defines if the character can effectively travel with the object it is standing on.
    //     /// </summary>
    //     CanRideOn = 1 << 6, //可站立（与站立对象一起移动）
    //     CanNotRideOn = 1 << 7,  //不可站立
    //     
    //     /// <summary>
    //     /// Defines if the character can filter the collider, when character ignore collision.
    //     /// 用于配置例如：空气墙，机关等类型的Actor，不可忽略碰撞
    //     /// </summary>
    //     CanNotFilterWhenIgnoreCollision = 1 << 8,   //不可忽略（当忽略碰撞时）
    // }
    
    /// <summary>
    /// Holds information about found ground (if any).
    /// </summary>
    public struct FindGroundResult
    {
        /// <summary>
        /// Did we hit ground ? Eg. impacted capsule's bottom sphere.
        /// </summary>
        public bool hitGround;

        /// <summary>
        /// Is the found ground walkable ?
        /// </summary>
        public bool isWalkable;

        /// <summary>
        /// Is walkable ground ? (eg: hitGround == true && isWalkable == true).
        /// </summary>

        public bool isWalkableGround => hitGround && isWalkable;

        /// <summary>
        /// The Character's position, in case of a raycast result this equals to point.
        /// </summary>
        public Vector3 position;

        /// <summary>
        /// The impact point in world space.
        /// </summary>

        public Vector3 point => hitResult.point;

        /// <summary>
        /// The normal of the hit surface.
        /// </summary>

        public Vector3 normal => hitResult.normal;

        /// <summary>
        /// Normal of the hit in world space, for the object that was hit by the sweep, if any.
        /// For example if a capsule hits a flat plane, this is a normalized vector pointing out from the plane.
        /// In the case of impact with a corner or edge of a surface, usually the "most opposing" normal (opposed to the query direction) is chosen.
        /// </summary>
        public Vector3 surfaceNormal;

        /// <summary>
        /// The collider of the hit object.
        /// </summary>
        public CollisionQuery.CqCollider collider;

        /// <summary>
        /// The Rigidbody of the collider that was hit. If the collider is not attached to a rigidbody then it is null.
        /// </summary>

        public CqRigidActor rigidbody => collider ? collider.attachedRigidActor : null;

        /// <summary>
        /// The Transform of the rigidbody or collider that was hit.
        /// </summary>

        public Transform transform
        {
            get
            {
                if (collider == null)
                    return null;

                var attachedRigidbody = collider.attachedRigidActor;
                return attachedRigidbody ? attachedRigidbody.transform : collider.transform;
            }
        }

        /// <summary>
        /// The distance to the ground, computed from the swept capsule.
        /// </summary>
        public float groundDistance;

        /// <summary>
        /// True if the hit found a valid walkable ground using a raycast (rather than a sweep test, which happens when the sweep test fails to yield a walkable surface).
        /// </summary>
        public bool isRaycastResult;

        /// <summary>
        /// The distance to the ground, computed from a raycast. Only valid if isRaycast is true.
        /// </summary>
        public float raycastDistance;

        /// <summary>
        /// Hit result of the test that found ground.
        /// </summary>
        public CollisionQuery.CqRaycastHit hitResult;

        /// <summary>
        /// Gets the distance to ground, either raycastDistance or distance.
        /// </summary>
        public float GetDistanceToGround()
        {
            return isRaycastResult ? raycastDistance : groundDistance;
        }

        /// <summary>
        /// Initialize this with a sweep test result.
        /// </summary>
        public void SetFromSweepResult(bool hitGround, bool isWalkable, Vector3 position, float sweepDistance,
            ref CollisionQuery.CqRaycastHit inHit, Vector3 surfaceNormal)
        {
            this.hitGround = hitGround;
            this.isWalkable = isWalkable;

            this.position = position;

            collider = inHit.Collider;

            groundDistance = sweepDistance;

            isRaycastResult = false;
            raycastDistance = 0.0f;

            hitResult = inHit;

            this.surfaceNormal = surfaceNormal;
        }

        public void SetFromSweepResult(bool hitGround, bool isWalkable, Vector3 position, Vector3 point, Vector3 normal,
            Vector3 surfaceNormal, CollisionQuery.CqCollider collider, float sweepDistance)
        {
            this.hitGround = hitGround;
            this.isWalkable = isWalkable;

            this.position = position;

            this.collider = collider;

            groundDistance = sweepDistance;

            isRaycastResult = false;
            raycastDistance = 0.0f;

            hitResult = new CollisionQuery.CqRaycastHit
            {
                point = point,
                normal = normal,

                distance = sweepDistance
            };

            this.surfaceNormal = surfaceNormal;
        }

        /// <summary>
        /// Initialize this with a raycast result.
        /// </summary>
        public void SetFromRaycastResult(bool hitGround, bool isWalkable, Vector3 position, float sweepDistance,
            float castDistance, ref CqRaycastHit inHit)
        {
            this.hitGround = hitGround;
            this.isWalkable = isWalkable;

            this.position = position;

            collider = inHit.Collider;

            groundDistance = sweepDistance;

            isRaycastResult = true;
            raycastDistance = castDistance;

            float oldDistance = hitResult.distance;

            hitResult = inHit;
            hitResult.distance = oldDistance;

            surfaceNormal = hitResult.normal;
        }
    }

    /// <summary>
    /// Describes a collision of this Character.
    /// </summary>
    public struct CollisionResult
    {
        /// <summary>
        /// True if character is overlapping.
        /// </summary>
        public bool startPenetrating;

        /// <summary>
        /// The hit location WRT Character's capsule, eg: Below, Sides, Top.
        /// </summary>
        public HitLocation hitLocation;

        /// <summary>
        /// Is the hit walkable ground ?
        /// </summary>
        public bool isWalkable;

        /// <summary>
        /// The character position at this collision.
        /// </summary>
        public Vector3 position;

        /// <summary>
        /// The character's velocity at this collision.
        /// </summary>
        public Vector3 velocity;

        /// <summary>
        /// The collided object's velocity.
        /// </summary>
        public Vector3 otherVelocity;

        /// <summary>
        /// The impact point in world space.
        /// </summary>
        public Vector3 point;

        /// <summary>
        /// The impact normal in world space.
        /// </summary>
        public Vector3 normal;

        /// <summary>
        /// Normal of the hit in world space, for the object that was hit by the sweep, if any.
        /// For example if a capsule hits a flat plane, this is a normalized vector pointing out from the plane.
        /// In the case of impact with a corner or edge of a surface, usually the "most opposing" normal (opposed to the query direction) is chosen.
        /// </summary>
        public Vector3 surfaceNormal;

        /// <summary>
        /// The character's displacement up to this hit.
        /// </summary>
        public Vector3 displacementToHit;

        /// <summary>
        /// Remaining displacement after hit.
        /// </summary>
        public Vector3 remainingDisplacement;

        /// <summary>
        /// The collider of the hit object.
        /// </summary>
        public CqCollider collider;

        /// <summary>
        /// The Rigidbody of the collider that was hit. If the collider is not attached to a rigidbody then it is null.
        /// </summary>
        public CqRigidActor rigidActor;

        /// <summary>
        /// The Transform of the rigidbody or collider that was hit.
        /// </summary>
        public Transform transform; // 初始化时直接赋值
        // {
        //     get
        //     {
        //         if (collider == null)
        //             return null;
        //         return rigidbody ? rigidbody.transform : collider.transform;
        //     }
        // }

        /// <summary>
        /// Structure containing information about this hit.
        /// </summary>
        public CollisionQuery.CqRaycastHit hitResult;

        /// <summary>
        /// 是否是挂载刚体的Collider，用于识别是否是CC的Collider
        /// 一个刚体可以attach多个Collider
        /// </summary>
        public bool isRigidbodyCollider; 
        // {
        //     get
        //     {
        //         if (collider == null || rigidbody == null)
        //             return false;
        //         return collider.transform == rigidbody.transform;
        //     }
        // }

        public CharacterMovement characterMovement;
    }
    
    /// <summary>
    /// Structure containing advanced settings.
    /// </summary>
    [Serializable]
    public struct Advanced
    {
        [Tooltip("The minimum move distance of the character controller." +
                 " If the character tries to move less than this distance, it will not move at all. This can be used to reduce jitter. In most situations this value should be left at 0.")]
        public float minMoveDistance;

        public float minMoveDistanceSqr => minMoveDistance * minMoveDistance;

        [Tooltip("Max number of iterations used during movement.")]
        public int maxMovementIterations;

        [Tooltip("Max number of iterations used to resolve penetrations.")]
        public int maxDepenetrationIterations;
        
        [Tooltip("If enabled, the character will interact with other characters when walking into them.")]
        public bool allowPushCharacters;
        
        public bool isUseGroundHighMap;
        public void Reset()
        {
            minMoveDistance = 0.0f;
            maxMovementIterations = 2;
            maxDepenetrationIterations = 1;
            allowPushCharacters = false;
            isUseGroundHighMap = true;
        }

        public void OnValidate()
        {
            minMoveDistance = Mathf.Max(minMoveDistance, 0.0f);
            maxMovementIterations = Mathf.Max(maxMovementIterations, 1);
            maxDepenetrationIterations = Mathf.Max(maxDepenetrationIterations, 1);
        }
    }
    
    /// <summary>
    /// Let you define if the character should collide with given collider.
    /// </summary>
    /// <param name="collider">The collider.</param>
    /// <returns>True to filter (ignore) given collider, false to collide with given collider.</returns>
    public delegate bool ColliderFilterCallback(CollisionQuery.CqCollider collider);

    /// <summary>
    /// Let you define the character behavior when collides with collider.
    /// </summary>
    /// <param name="collider">The collided collider</param>
    /// <returns>The desired collision behavior flags.</returns>
    public delegate CollisionBehavior CollisionBehaviorCallback(CollisionQuery.CqCollider collider);
    
    public delegate void FoundGroundEventHandler(ref FindGroundResult foundGround);
    
    public delegate void SwitchModeEvent(MovementModeBase mode);
    
    // 物理模拟完成后，应用到Transform上之前调用
    public delegate void FinallySetWorldPosEventHandler(Vector3 originalPos, ref Vector3 desirePos);
    
    /// <summary>
    /// Character's current movement mode (walking, falling, etc):
    ///    - walking:  Walking on a surface, under the effects of friction, and able to "step up" barriers. Vertical velocity is zero.
    ///    - falling:  Falling under the effects of gravity, after jumping or walking off the edge of a surface.
    ///    - flying:   Flying, ignoring the effects of gravity.
    /// </summary>
    public enum MovementMode
    {
        // 数值从1开始为了支持旧的配置
        walking =1,
        Falling =2,
        Flying =3,
    }

    public class OverlapColliderMassCompare : IComparer<CqCollider>
    {
        private int _order;
        /// <param name="flashBack">倒叙排列</param>
        public OverlapColliderMassCompare(bool flashBack = true)
        {
            _order = flashBack ? -1 : 1;
        }
        
        // 默认是从小到大的排列
        // 这里需要质量倒叙排列
        public int Compare(CqCollider x, CqCollider y)
        {
            if (x == null)
            {
                return 1; // null对象排到最后
            }
            if (y == null)
            {
                return -1; // null对象排到最后
            }
            
            // x, y都是与一个 cc重叠的两个collider
            // 两个collider没有绑定刚体，也既是静态的物体。 那么则认定为质量较大
            
            int num = 0; // 可以理解为 x - y的值， 差值 > 0 则 x 更大
            var xRigidActorMass = x.attachedRigidActor ? x.attachedRigidActor.mass : int.MaxValue;
            var yRigidActorMass = y.attachedRigidActor ? y.attachedRigidActor.mass : int.MaxValue;
            
            if (xRigidActorMass > yRigidActorMass)
            {
                num = 1;
            }
            else if (xRigidActorMass == yRigidActorMass)
            {
                num = 0;
            }
            else
            {
                num = -1;
            }
            return num * _order;
        }
        
    }
    
}