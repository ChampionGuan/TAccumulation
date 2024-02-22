using System;
using System.Collections;
using System.Collections.Generic;
using Pathfinding;
using Pathfinding.RVO;
using Pathfinding.Util;
using UnityEngine;
using UnityEngine.Profiling;
using X3Battle;

[DisallowMultipleComponent]
[RequireComponent(typeof(RVOController))]
[AddComponentMenu("Pathfinding/AI/RMNavMeshAgent (for RootMotion)")]
public class RMNavMeshAgent : MonoBehaviour, IAstarAI, IRMAgent
{
    public int rvoTimeMax
    {
        get => m_rvoTimeMax;
        set => m_rvoTimeMax = value;
    }

    public int outNavmeshMax
    {
        get => m_outNavmeshMax;
        set => m_outNavmeshMax = value;
    }

    public int rvoKeepDir
    {
        get => m_rvoKeepDir;
        set => m_rvoKeepDir = value;
    }
    public float pickNextWaypointDist { get; set; }
    public int insID { get; set; }
    public Vector3 velocity => Vector3.zero;
    public Vector3 desiredVelocity => Vector3.zero;
    public event RMGridAgent.DelegateSeachPathBefore DeleSeachPathBefore;
    public float radius
    {
        get => m_radius;
        set => m_radius = value;
    }

    public float height
    {
        get => m_height;
        set => m_height = value;
    }

    public float maxSpeed
    {
        get => m_moveSpeed;
        set => m_moveSpeed = value;
    }

    public bool canMove
    {
        get => true;
        set { }
    }

    public bool canSearch
    {
        get => m_autoRepath.mode != AutoRepathPolicy.Mode.Never;
        set
        {
            if (value)
            {
                if (m_autoRepath.mode == AutoRepathPolicy.Mode.Never)
                {
                    m_autoRepath.mode = AutoRepathPolicy.Mode.EveryNSeconds;
                }
            }
            else
            {
                m_autoRepath.mode = AutoRepathPolicy.Mode.Never;
            }
        }
    }

    public float m_radius = 0.5f;
    public float m_height = 2;
    public float m_moveSpeed = 7;
    public float acceleration = 90;
    public float rotationSpeed = 360;
    public float m_rvoSensitivity = 3;
    public float m_endReachedDistance = 0.01f;
    public bool m_funnelSimplification = true;
    public AutoRepathPolicy m_autoRepath = new AutoRepathPolicy();
    public bool m_Debug = false;
    //判断人物卡死的时间
    public int m_rvoTimeMax = 20;
    //在navmesh之外的次数
    public int m_outNavmeshMax = 15;
    //人物卡死之后修改随机修改前进方向 修改维持的时间
    public int m_rvoKeepDir = 15;
    //用于RVO判断卡死的时间
    private int rvoTime;
    private int outNavmesh;
    private int keepDirTime;
    public Vector3 rvoChangeVector3 = Vector3.back;

    public Action onSearchPath { get; set; }

    /// <summary>
    /// 停止
    /// </summary>
    public bool isStopped
    {
        get => m_isStopped;
        set
        {
            if (value == isStopped)
            {
                return;
            }

            if (value)
            {
                ClearPath();
            }

            m_isStopped = value;
        }
    }

    public int pathTag { get; set; }

    /// <summary>
    /// 目的地
    /// </summary>
    public Vector3 destination
    {
        get => m_destinationPosition;
        set
        {
            m_destinationPosition = value;
            //steeringDirection = Vector3.zero;
            isStopped = false;
        }
    }

    /// <summary>
    /// 应该重新计算路径
    /// </summary>
    protected bool shouldRecalculatePath => !waitingForPathCalculation && m_autoRepath.ShouldRecalculatePath(this) && !traversingOffMeshLink;

    /// <summary>
    /// 自定义OffMeshLink过程
    /// </summary>
    public Func<RichSpecial, IEnumerator> onTraverseOffMeshLink;

    /// <summary>
    /// 剩余距离
    /// </summary>
    public float remainingDistance => distanceToSteeringTarget + Vector3.Distance(steeringTarget, richPath.Endpoint);

    /// <summary>
    /// 是否即将到达当前部分最后拐点
    /// </summary>
    public bool approachingPartEndpoint => lastCorner && nextCorners.Count == 1;

    /// <summary>
    /// 是否即将到达最后部分的最后拐点
    /// </summary>
    public bool approachingPathEndpoint => approachingPartEndpoint && richPath.IsLastPart;

    /// <summary>
    /// 已经达到路径结束点
    /// </summary>
    public bool reachedEndOfPath => approachingPathEndpoint && distanceToSteeringTarget < m_endReachedDistance;

    /// <summary>
    /// 已经到达目标点
    /// </summary>
    public bool reachedDestination
    {
        get
        {
            if (!reachedEndOfPath) return false;
            if (approachingPathEndpoint && distanceToSteeringTarget + m_movementPlane.ToPlane(destination - richPath.Endpoint).magnitude > m_endReachedDistance) return false;
            m_movementPlane.ToPlane(destination - position, out var elevation);
            var h = trans.localScale.y * height;
            return !(elevation > h) && !(elevation < -h * 0.5);
        }
    }

    /// <summary>
    /// 寻到路径
    /// </summary>
    public bool hasPath => richPath.GetCurrentPart() != null;

    /// <summary>
    /// 寻路等待中
    /// </summary>
    public bool pathPending => waitingForPathCalculation || delayUpdatePath;

    /// <summary>
    /// 正在OffMeshLink中
    /// </summary>
    public bool traversingOffMeshLink { get; protected set; }

    /// <summary>
    /// 拐点位置
    /// </summary>
    public Vector3 steeringTarget { get; protected set; }

    /// <summary>
    /// rvo目标位置
    /// </summary>
    public Vector3 rvoTargetPoint { get; protected set; }

    /// <summary>
    /// 移动方向
    /// </summary>
    public Vector3 steeringDirection { get; protected set; }

    /// <summary>
    /// 当前位置
    /// </summary>
    public Vector3 position
    {
        get => trans.position;
        set
        {
            if (m_updatePosition)
            {
                trans.position = value;
            }
            else
            {
                simulatedPosition = value;
            }
        }
    }

    /// <summary>
    /// 当前朝向
    /// </summary>
    public Quaternion rotation
    {
        get => trans.rotation;
        set
        {
            if (m_updateRotation)
            {
                trans.rotation = value;
            }
            else
            {
                simulatedRotation = value;
            }
        }
    }

    public Transform trans
    {
        get
        {
            if (null != m_trans) return m_trans;
            m_trans = transform;
            return m_trans;
        }
    }

    public Seeker seeker
    {
        get
        {
            if (null != m_seek) return m_seek;
            m_seek = trans.GetComponent<Seeker>();
            if (null == m_seek) m_seek = trans.gameObject.AddComponent<Seeker>();
            //m_seek.hideFlags = HideFlags.HideInInspector;
            return m_seek;
        }
    }

    public RVOController rvoCtrl
    {
        get
        {
            return m_rvoCtrl;
        }
    }

    private void _InitRvoCtrl()
    {
        if (null == m_rvoCtrl)
        {
            m_rvoCtrl = trans.GetComponent<RVOController>();
            m_rvoCtrl.agentTimeHorizon = 0.1f;
            m_rvoCtrl.obstacleTimeHorizon = 0.1f;
        }
    }
    public Vector3 simulatedPosition { get; protected set; }

    public Quaternion simulatedRotation { get; protected set; }

    //速度
    protected Vector2 velocity2D;

    //路径
    protected readonly RichPath richPath = new RichPath();

    //拐点
    protected readonly List<Vector3> nextCorners = new List<Vector3>();

    //到拐点距离
    protected float distanceToSteeringTarget = float.PositiveInfinity;

    //延迟更新路径
    protected bool delayUpdatePath;

    //最后一个拐点
    protected bool lastCorner;

    //等待寻路结束
    protected bool waitingForPathCalculation = false;

    protected IMovementPlane m_movementPlane = GraphTransform.identityTransform;
    protected bool m_isPathActive;
    protected bool m_updatePosition = false;
    protected bool m_updateRotation = false;
    protected bool m_isStopped = true;
    protected Vector3 m_destinationPosition;
    protected RVOController m_rvoCtrl;
    protected Transform m_trans;
    protected Seeker m_seek;

    private OnPathDelegate m_onPathCompleted;
    
    void OnEnable()
    {
        m_isPathActive = null != AstarPath.active?.data && AstarPath.active.data.graphs.Length > 0;
        seeker.pathCallback += m_onPathCompleted;
        // if (canMove) Teleport(position, false);
        m_autoRepath.Reset();
        // if (shouldRecalculatePath) SearchPath();
        if (rvoCtrl != null)
        {
            rvoCtrl.enabled = true;
        }
    }

    protected void Awake()
    {
        m_onPathCompleted = OnPathComplete;
        _InitRvoCtrl();
    }

    void OnDisable()
    {
        ClearPath();
        seeker.pathCallback -= m_onPathCompleted;
        velocity2D = Vector3.zero;
        StopAllCoroutines();
        traversingOffMeshLink = false;
        if (rvoCtrl != null)
        {
            rvoCtrl.enabled = false;
        }
    }

    public void UnLoadDestroy()
    {
        
    }
    public virtual void OnUpdate(float deltaTime)
    {
        if (m_isStopped || !m_isPathActive)
        {
            return;
        }

        if (shouldRecalculatePath)
        {
            SearchPath();
        }

        MovementUpdate(Time.deltaTime, out var nextPosition, out var nextRotation);
        FinalizeMovement(nextPosition, nextRotation);
    }

    /// <summary>
    /// 寻路结束
    /// </summary>
    /// <param name="newPath"></param>
    protected void OnPathComplete(Path path)
    {
        using (ProfilerDefine.RMNavMeshAgentOnPathCompletePMarker.Auto())
        {
            waitingForPathCalculation = false;
            path.Claim(this);

            if (path.error)
            {
                path.Release(this);
                return;
            }

            if (traversingOffMeshLink)
            {
                delayUpdatePath = true;
            }
            else
            {
                richPath.Initialize(seeker, path, true, m_funnelSimplification);

                if (richPath.GetCurrentPart() is RichFunnel part)
                {
                    simulatedPosition = trans.position;
                    simulatedRotation = trans.rotation;
                    var position2D = m_movementPlane.ToPlane(GetPos2RefreshData(part));
                    var steeringTarget2D = m_movementPlane.ToPlane(steeringTarget);
                    distanceToSteeringTarget = (steeringTarget2D - position2D).magnitude;
                    if (approachingPartEndpoint && distanceToSteeringTarget <= m_endReachedDistance)
                    {
                        NextPartOfPath();
                    }
                }
            }

            path.Release(this);
        }
    }

    /// <summary>
    /// 清除路径
    /// </summary>
    protected void ClearPath()
    {
        CancelCurrentPathRequest();
        richPath.Clear();
        nextCorners.Clear();
        lastCorner = false;
        delayUpdatePath = false;
        distanceToSteeringTarget = float.PositiveInfinity;
        steeringDirection = Vector3.zero;
    }

    protected void CancelCurrentPathRequest()
    {
        waitingForPathCalculation = false;
        if (m_isPathActive) seeker.CancelCurrentPathRequest();
    }

    /// <summary>
    /// 瞬移到目标点
    /// </summary>
    /// <param name="position"></param>
    /// <param name="clearPath"></param>
    public void Teleport(Vector3 position, bool clearPath = true)
    {
        var nearest = AstarPath.active != null ? AstarPath.active.GetNearest(position) : new NNInfo();
        m_movementPlane.ToPlane(position, out var elevation);
        position = m_movementPlane.ToWorld(m_movementPlane.ToPlane(nearest.node != null ? nearest.position : position), elevation);

        if (clearPath) ClearPath();
        simulatedPosition = position;
        if (m_updatePosition) trans.position = position;
        rvoCtrl.Move(Vector3.zero);
        if (clearPath) SearchPath();
    }

    public void Move(Vector3 deltaPosition)
    {
    }

    public void MovementUpdate(float deltaTime, out Vector3 nextPosition, out Quaternion nextRotation)
    {
        simulatedPosition = trans.position;
        simulatedRotation = trans.rotation;

        var currentPart = richPath.GetCurrentPart();
        if (currentPart is RichFunnel funnelPart && !isStopped)
        {
            TraverseFunnelPath(funnelPart, deltaTime, out nextPosition, out nextRotation);
            return;
        }

        if (currentPart is RichSpecial specialPart)
        {
            if (!traversingOffMeshLink && !richPath.CompletedAllParts)
            {
                StartCoroutine(TraverseSpecialPath(specialPart));
            }

            nextPosition = simulatedPosition;
            nextRotation = simulatedRotation;
            steeringTarget = simulatedPosition;
            return;
        }

        var forward = (destination - simulatedPosition).normalized;
        nextPosition = simulatedPosition;
        nextRotation = SimulateRotationTowards(forward);
        rvoCtrl.ForceSetVelocity(forward);
        velocity2D = m_movementPlane.ToPlane(forward) * m_moveSpeed;
    }
    public void FinalizeMovement(Vector3 nextPosition, Quaternion nextRotation)
    {
        rotation = nextRotation;
        position = nextPosition;
        steeringDirection = nextRotation * Vector3.forward;
        RvoBlockPatch(nextPosition, nextRotation);
    }

    /// <summary>
    /// RVO卡死补丁
    /// 当人物处于rvo状态卡死的时候 修改人物前进方向
    /// 判断人物卡死 RvoTime帧内OutRvoNum次的nextposition 都在navmesh之外
    /// 人物卡死之后修改随机修改前进方向 修改维持RvoKeepDir帧
    /// </summary>
    public void RvoBlockPatch( Vector3 nextPosition, Quaternion nextRotation)
    {
        rvoTime++;
        keepDirTime--;
        if (rvoTime >= rvoTimeMax)
        {
            rvoTime = 0;
            outNavmesh = 0;
        }

        if (!rvoCtrl.rvoAgent.insideAnyVO)
            return;

        
        var point = BattleUtil.GetNavMeshNearestPoint(nextPosition);
        if (point != nextPosition)
        {
            outNavmesh++;
        }
        
        //判断是否卡死
        bool isBlock = outNavmesh >= outNavmeshMax && rvoTime <= rvoTimeMax;
        if (isBlock || keepDirTime >= 0)
        {
            if (isBlock)
            {
                rvoChangeVector3 = nextRotation * Vector3.back;
                keepDirTime = m_rvoKeepDir;
            }
            steeringDirection  = rvoChangeVector3;
            rvoTime = 0;
            outNavmesh = 0;
        }
    }
    
    
    /// <summary>
    /// 获取剩余路径
    /// </summary>
    /// <param name="buffer"></param>
    /// <param name="stale"></param>
    public void GetRemainingPath(List<Vector3> buffer, out bool stale)
    {
        richPath.GetRemainingPath(buffer, simulatedPosition, out stale);
    }

    /// <summary>
    /// 每帧驱动，移动
    /// </summary>
    protected virtual void MovementFinal(Vector3 position3D, float deltaTime, float distanceToEndOfPath, out Vector3 nextPosition, out Quaternion nextRotation)
    {
        var rvoTarget = rvoTargetPoint = position3D + m_movementPlane.ToWorld(Vector2.ClampMagnitude(velocity2D, distanceToEndOfPath));
        rvoCtrl.SetTarget(rvoTarget, velocity2D.magnitude * m_rvoSensitivity, maxSpeed * m_rvoSensitivity);

        var deltaPosition2D = m_movementPlane.ToPlane(rvoCtrl.CalculateMovementDelta(position3D, deltaTime));
        var deltaPosition3D = m_movementPlane.ToWorld(deltaPosition2D, 0);
        nextPosition = position3D + deltaPosition3D;
        nextRotation = SimulateRotationTowards(deltaPosition2D);
    }

    protected Quaternion SimulateRotationTowards(Vector2 direction)
    {
        return direction != Vector2.zero ? Quaternion.LookRotation(m_movementPlane.ToWorld(direction, 0), m_movementPlane.ToWorld(Vector2.zero, 1)) : simulatedRotation;
    }

    protected Quaternion SimulateRotationTowards(Vector3 direction)
    {
        return direction != Vector3.zero ? Quaternion.LookRotation(direction) : simulatedRotation;
    }

    /// <summary>
    /// 取点并刷新数据
    /// </summary>
    /// <param name="fn"></param>
    /// <returns></returns>
    protected virtual Vector3 GetPos2RefreshData(RichFunnel fn)
    {
        nextCorners.Clear();
        var position3D = fn.Update(simulatedPosition, nextCorners, 2, out lastCorner, out var requiresRepath);
        steeringTarget = nextCorners[0];
        if (requiresRepath && !waitingForPathCalculation && canSearch) SearchPath();
        return position3D;
    }

    /// <summary>
    /// 搜寻路径
    /// </summary>
    public void SearchPath()
    {
        if (!m_isPathActive)
        {
            return;
        }

        if (traversingOffMeshLink)
        {
            delayUpdatePath = true;
        }
        else
        {
            if (float.IsPositiveInfinity(destination.x)) return;
            using (ProfilerDefine.RMNavMeshAgentOnSearchPathPMarker.Auto())
            {
                onSearchPath?.Invoke();
                var abPath = ABPath.Construct(position, destination, null);

                // abPath.nnConstraint = NNConstraint.Default;
                // abPath.calculatePartial = true;
                // abPath.nnConstraint.graphMask = -1;

                SetPath(abPath);
            }
        }
    }

    /// <summary>
    /// 设置路径
    /// </summary>
    /// <param name="path"></param>
    /// <exception cref="ArgumentException"></exception>
    public void SetPath(Path path)
    {
        if (path == null)
        {
            CancelCurrentPathRequest();
            ClearPath();
        }
        else if (path.PipelineState == PathState.Created)
        {
            waitingForPathCalculation = true;
            seeker.CancelCurrentPathRequest();
            seeker.StartPath(path);
            m_autoRepath.DidRecalculatePath(destination);
        }
        else if (path.PipelineState == PathState.Returned)
        {
            if (seeker.GetCurrentPath() != path) seeker.CancelCurrentPathRequest();
            else throw new ArgumentException("If you calculate the path using seeker.StartPath then this script will pick up the calculated path anyway as it listens for all paths the Seeker finishes calculating. You should not call SetPath in that case.");
            OnPathComplete(path);
        }
        else
        {
            throw new ArgumentException("You must call the SetPath method with a path that either has been completely calculated or one whose path calculation has not been started at all. It looks like the path calculation for the path you tried to use has been started, but is not yet finished.");
        }
    }

    /// <summary>
    /// 路径的下一部分
    /// </summary>
    protected virtual void NextPartOfPath()
    {
        if (richPath.CompletedAllParts)
            return;

        if (!richPath.IsLastPart)
            lastCorner = false;

        richPath.NextPart();
        if (richPath.CompletedAllParts)
            OnTargetReached();
    }

    /// <summary>
    /// 到达目的地
    /// </summary>
    protected virtual void OnTargetReached()
    {
    }

    /// <summary>
    /// 穿过（NavMesh）
    /// </summary>
    /// <param name="fn"></param>
    /// <param name="deltaTime"></param>
    /// <param name="nextPosition"></param>
    /// <param name="nextRotation"></param>
    protected virtual void TraverseFunnelPath(RichFunnel fn, float deltaTime, out Vector3 nextPosition, out Quaternion nextRotation)
    {
        var position3D = GetPos2RefreshData(fn);
        var position2D = m_movementPlane.ToPlane(position3D, out var elevation);
        var tgtPoint2D = m_movementPlane.ToPlane(steeringTarget);
        var dir = tgtPoint2D - position2D;
        var normDir = VectorMath.Normalize(dir, out distanceToSteeringTarget);

        velocity2D = normDir * m_moveSpeed;
        var tgtVelocity2D = Vector2.zero;
        if (approachingPartEndpoint)
        {
            tgtVelocity2D = normDir * maxSpeed;
            if (distanceToSteeringTarget <= m_endReachedDistance)
            {
                NextPartOfPath();
            }
        }
        else
        {
            var nextNextCorner = nextCorners.Count > 1 ? m_movementPlane.ToPlane(nextCorners[1]) : position2D + 2 * dir;
            tgtVelocity2D = (nextNextCorner - tgtPoint2D).normalized * maxSpeed;
        }

        var forward = m_movementPlane.ToPlane(simulatedRotation * Vector3.forward);
        var accel = MovementUtilities.CalculateAccelerationToReachPoint(tgtPoint2D - position2D, tgtVelocity2D, velocity2D, acceleration, rotationSpeed, maxSpeed, forward);
        velocity2D += accel * deltaTime;

        var distanceToEndOfPath = distanceToSteeringTarget + Vector3.Distance(steeringTarget, fn.exactEnd);
        MovementFinal(position3D, deltaTime, distanceToEndOfPath, out nextPosition, out nextRotation);
    }

    /// <summary>
    /// 穿过（specialPath)
    /// </summary>
    /// <param name="link"></param>
    /// <returns></returns>
    protected virtual IEnumerator TraverseSpecialPath(RichSpecial link)
    {
        traversingOffMeshLink = true;
        velocity2D = Vector3.zero;

        var offMeshLinkCoroutine = onTraverseOffMeshLink != null ? onTraverseOffMeshLink(link) : TraverseOffMeshLink(link);
        yield return StartCoroutine(offMeshLinkCoroutine);
        traversingOffMeshLink = false;
        NextPartOfPath();

        if (!delayUpdatePath) yield break;
        delayUpdatePath = false;
        if (canSearch) SearchPath();
    }

    /// <summary>
    /// 穿过OffMeshLink
    /// </summary>
    /// <param name="link"></param>
    /// <returns></returns>
    protected virtual IEnumerator TraverseOffMeshLink(RichSpecial link)
    {
        var duration = maxSpeed > 0 ? Vector3.Distance(link.second.position, link.first.position) / maxSpeed : 1;
        var startTime = Time.time;
        var endTime = startTime + duration;
        while (true)
        {
            var pos = Vector3.Lerp(link.first.position, link.second.position, Mathf.InverseLerp(startTime, endTime, Time.time));
            if (m_updatePosition)
            {
                trans.position = pos;
            }
            else
            {
                simulatedPosition = pos;
            }

            if (Time.time > endTime)
            {
                break;
            }

            yield return null;
        }

        yield return null;
    }

    protected void OnDrawGizmos()
    {
        var color = AIBase.ShapeGizmoColor;
        if (rvoCtrl != null && rvoCtrl.locked) color *= 0.5f;
        Draw.Gizmos.Cylinder(position, rotation * Vector3.up, trans.localScale.y * height, radius * trans.localScale.x, color);

        if (!float.IsPositiveInfinity(destination.x) && Application.isPlaying) Draw.Gizmos.CircleXZ(destination, 0.2f, Color.blue);
        m_autoRepath.DrawGizmos(this);

        if (null == trans || !m_Debug || null == rvoCtrl.rvoAgent) return;
        if (seeker.hideFlags != HideFlags.None)
            seeker.hideFlags = HideFlags.None;
        if (rvoCtrl.hideFlags != HideFlags.None)
            rvoCtrl.hideFlags = HideFlags.None;

        Gizmos.color = Color.red;
        var lastPosition = position;
        for (var i = 0; i < nextCorners.Count; lastPosition = nextCorners[i], i++)
        {
            Gizmos.DrawLine(lastPosition, nextCorners[i]);
        }

        var rvoTarget = destination;
        rvoTarget.x = rvoCtrl.rvoAgent.CalculatedTargetPoint.x;
        rvoTarget.z = rvoCtrl.rvoAgent.CalculatedTargetPoint.y;

        Gizmos.color = Color.red;
        Gizmos.DrawSphere(rvoTarget, 0.4f);
        Gizmos.color = Color.green;
        Gizmos.DrawSphere(rvoTargetPoint, 0.3f);

        Gizmos.color = Color.blue;
        Gizmos.DrawSphere(steeringTarget, 0.3f);
        Gizmos.color = Color.black;
        Gizmos.DrawSphere(destination, 0.1f);
    }
}
