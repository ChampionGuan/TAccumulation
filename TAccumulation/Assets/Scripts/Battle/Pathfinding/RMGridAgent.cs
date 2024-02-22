using System;
using System.Collections.Generic;
using PapeGames.X3;
using Pathfinding;
using Pathfinding.Util;
using UnityEngine;
using UnityEngine.Profiling;
using X3Battle;
using EventType = X3Battle.EventType;

public interface IRMAgent
{
    float radius { get; set; }
    float height { get; set; }
    bool isStopped { get; set; }
    int pathTag { get; set; }
    Vector3 destination { get; set; }
    Vector3 steeringTarget { get; }
    Vector3 steeringDirection { get; }
    float pickNextWaypointDist { get; set; }
    void OnUpdate(float deltaTime);
    event RMGridAgent.DelegateSeachPathBefore DeleSeachPathBefore;
    void UnLoadDestroy();
}

[DisallowMultipleComponent]
public class RMGridAgent : MonoBehaviour, IAstarAI, IRMAgent
{
    private float m_radius = 0.1f;
    public bool drawGizmos;
    public float m_height = 2;
    public float m_endReachedDistance = 0.02f;
    public float pickNextWaypointDist { get; set; }
    
    public AutoRepathPolicy m_autoRepath = new AutoRepathPolicy();
    public Action onSearchPath { get; set; }
    public Vector3 velocity => Vector3.zero;
    public Vector3 desiredVelocity => Vector3.zero;
    /// <summary>
    /// 寻路的node惩罚算法
    /// </summary>
    PentlyTagTraversalProvider provider = new PentlyTagTraversalProvider();
    public delegate void DelegateSeachPathBefore();

    public event DelegateSeachPathBefore DeleSeachPathBefore;
    private NNConstraint _nnConstraint = new NNConstraint();
    public float radius
    {
        get => m_radius;
        set
        {
            m_radius = value;
        }
    }

    public float height
    {
        get => m_height;
        set => m_height = value;
    }

    public float maxSpeed
    {
        get => 1;
        set { }
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
        get => m_destination;
        set
        {
            m_destination = value;
            isStopped = false;
        }
    }

    /// <summary>
    /// 应该重新计算路径
    /// </summary>
    protected bool shouldRecalculatePath => !m_isPathRequest && m_autoRepath.ShouldRecalculatePath(this);

    /// <summary>
    /// 剩余距离
    /// </summary>
    public float remainingDistance => m_interpolator.valid ? m_interpolator.remainingDistance + m_movementPlane.ToPlane(m_interpolator.position - position).magnitude : float.PositiveInfinity;

    /// <summary>
    /// 已经到达目标点
    /// </summary>
    public bool reachedDestination
    {
        get
        {
            if (!reachedEndOfPath) return false;
            if (!m_interpolator.valid || remainingDistance + m_movementPlane.ToPlane(destination - m_interpolator.endPoint).magnitude > m_endReachedDistance) return false;
            m_movementPlane.ToPlane(destination - position, out var elevation);
            var h = trans.localScale.y * height;
            return !(elevation > h) && !(elevation < -h * 0.5);
        }
    }

    /// <summary>
    /// 已经达到路径结束点
    /// </summary>
    public bool reachedEndOfPath { get; private set; }

    /// <summary>
    /// 寻到路径
    /// </summary>
    public bool hasPath => m_interpolator.valid;

    /// <summary>
    /// 寻路等待中
    /// </summary>
    public bool pathPending => m_isPathRequest;

    /// <summary>
    /// 拐点位置
    /// </summary>
    public Vector3 steeringTarget => m_interpolator.valid ? m_interpolator.position : position;

    /// <summary>
    /// 拐点方向
    /// </summary>
    public Vector3 steeringDirection
    {
        get
        {
            return m_interpolator.valid && !reachedDestination ? steeringTarget - position : isStopped ? Vector3.zero : destination - position;
        }   
    }

    /// <summary>
    /// 当前位置
    /// </summary>
    public Vector3 position => trans.position;

    /// <summary>
    /// 当前朝向
    /// </summary>
    public Quaternion rotation
    {
        get => trans.rotation;
        set { }
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

    private bool m_isStopped = true;
    private bool m_isPathRequest;
    private bool m_isPathActive;
    private Vector3 m_destination;
    private Transform m_trans;
    private Seeker m_seek;
    private Path m_path;
    private SimpleSmoothModifier m_simpleSmoothModifier;
    private PathInterpolator m_interpolator = new PathInterpolator();
    private IMovementPlane m_movementPlane = GraphTransform.identityTransform;

    private void Awake()
    {
        //var modifier2 = gameObject.GetOrAddComponent<RaycastModifier>();
        //modifier2.hideFlags = HideFlags.HideInInspector;
        m_seek = gameObject.GetOrAddComponent<Seeker>();
        m_seek.hideFlags = HideFlags.HideInInspector;
        m_seek.pathCallback += OnPathComplete;
        //挂载路径修饰符
        m_simpleSmoothModifier = gameObject.GetOrAddComponent<SimpleSmoothModifier>();
        m_simpleSmoothModifier.smoothType = SimpleSmoothModifier.SmoothType.Simple;
        m_simpleSmoothModifier.maxSegmentLength = 0.5f;
        m_simpleSmoothModifier.uniformLength = true;
        m_simpleSmoothModifier.iterations = 1;
        m_simpleSmoothModifier.strength = 0.5f;

        _nnConstraint.graphMask = 0;
        _nnConstraint.graphMask = 1 << 0;
    }

    void OnEnable()
    {
        m_isPathActive = null != AstarPath.active?.data && AstarPath.active.data.graphs.Length > 0;
        m_autoRepath.Reset();
    }

    void OnDisable()
    {
        ClearPath();
        if (m_seek != null)
        {
            // ReSharper disable once DelegateSubtraction
            m_seek.pathCallback -= OnPathComplete;
        }
        StopAllCoroutines();
    }

    public void UnLoadDestroy()
    {
        ClearPath();
        DeleSeachPathBefore = null;
        onSearchPath = null;
        m_autoRepath = null;
        provider = null;
        _nnConstraint = null;
        m_seek.OnDestroy();
        m_seek = null;
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

        m_interpolator.MoveToCircleIntersection2D(position, pickNextWaypointDist, m_movementPlane);
        var distanceToEnd = m_movementPlane.ToPlane(steeringTarget - position).magnitude + Mathf.Max(0, m_interpolator.remainingDistance);
        reachedEndOfPath = distanceToEnd <= m_endReachedDistance && m_interpolator.valid;
    }
    

    /// <summary>
    /// 寻路结束
    /// </summary>
    /// <param name="newPath"></param>
    private void OnPathComplete(Path newPath)
    {
        if (!enabled) return;
        if (!(newPath is ABPath p)) return;
        m_isPathRequest = false;

        p.Claim(this);
        if (p.error)
        {
            p.Release(this);
            SetPath(null);
            return;
        }

        m_path?.Release(this);
        m_path = p;
        if (m_path.vectorPath.Count == 1) m_path.vectorPath.Add(m_path.vectorPath[0]);
        m_interpolator.SetPath(m_path.vectorPath);
        
        var graph = m_path.path.Count > 0 ? AstarData.GetGraph(m_path.path[0]) as ITransformedGraph : null;
        m_movementPlane = graph != null ? graph.transform : GraphTransform.identityTransform;

        reachedEndOfPath = false;
        
        m_interpolator.MoveToCircleIntersection2D(position, pickNextWaypointDist, m_movementPlane);
        
        if (!(remainingDistance <= m_endReachedDistance)) return;
        reachedEndOfPath = true;
    }

    /// <summary>
    /// 清除路径
    /// </summary>
    private void ClearPath()
    {
        CancelPathRequest();
        m_path?.Release(this);
        m_path = null;
        m_interpolator?.SetPath(null);
        m_autoRepath?.Reset();
        reachedEndOfPath = false;
    }

    /// <summary>
    /// 取消当前路径请求
    /// </summary>
    private void CancelPathRequest()
    {
        m_isPathRequest = false;
        if (m_isPathActive && m_seek != null)
        {
            m_seek.CancelCurrentPathRequest();
        }
    }

    /// <summary>
    /// 获取剩余路径
    /// </summary>
    /// <param name="buffer"></param>
    /// <param name="stale"></param>
    public void GetRemainingPath(List<Vector3> buffer, out bool stale)
    {
        buffer.Clear();
        buffer.Add(position);
        if (!m_interpolator.valid)
        {
            stale = true;
            return;
        }

        stale = false;
        m_interpolator.GetRemainingPath(buffer);
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

        if (float.IsPositiveInfinity(destination.x)) return;
        using (ProfilerDefine.BattleRMAgentSearchPathPMarker.Auto())
        {
            //发送标记惩罚更新事件
            DeleSeachPathBefore?.Invoke();

            onSearchPath?.Invoke();
            var abPath = ABPath.Construct(position, destination);
            abPath.pathTag = pathTag;
            abPath.traversalProvider = provider;
            abPath.nnConstraint = _nnConstraint;
            SetPath(abPath);
            LogProxy.Log("actor.name = " + gameObject.name + " 发起寻路请求 frameCount = " + Battle.Instance.frameCount);
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
            CancelPathRequest();
            ClearPath();
        }
        else
        {
            switch (path.PipelineState)
            {
                case PathState.Created:
                    m_isPathRequest = true;
                    m_seek.CancelCurrentPathRequest();
                    m_seek.StartPath(path);
                    m_autoRepath.DidRecalculatePath(destination);
                    break;
                case PathState.Returned:
                {
                    if (m_seek.GetCurrentPath() != path) m_seek.CancelCurrentPathRequest();
                    else throw new ArgumentException("If you calculate the path using seeker.StartPath then this script will pick up the calculated path anyway as it listens for all paths the Seeker finishes calculating. You should not call SetPath in that case.");
                    OnPathComplete(path);
                    break;
                }
                default:
                    throw new ArgumentException("You must call the SetPath method with a path that either has been completely calculated or one whose path calculation has not been started at all. It looks like the path calculation for the path you tried to use has been started, but is not yet finished.");
            }
        }
    }

    public void MovementUpdate(float deltaTime, out Vector3 nextPosition, out Quaternion nextRotation)
    {
        nextPosition = Vector3.zero;
        nextRotation = Quaternion.identity;
    }

    public void FinalizeMovement(Vector3 nextPosition, Quaternion nextRotation)
    {
    }

    public void Teleport(Vector3 position, bool clearPath = true)
    {
    }

    public void Move(Vector3 deltaPosition)
    {
    }


#if UNITY_EDITOR
    [NonSerialized] int gizmoHash;
    [NonSerialized] float lastChangedTime = float.NegativeInfinity;

    static readonly Color GizmoColor = new Color(46.0f / 255, 104.0f / 255, 201.0f / 255);
    static readonly Color ShapeGizmoColor = new Color(240 / 255f, 213 / 255f, 30 / 255f);

    protected void OnDrawGizmos()
    {
        if (null != m_seek)
        {
            m_seek.drawGizmos = drawGizmos;
            m_seek.detailedGizmos = drawGizmos;
        }

        if (!drawGizmos) return;

        var color = ShapeGizmoColor;
        Draw.Gizmos.Cylinder(position, rotation * Vector3.up, trans.localScale.y * height, radius * trans.localScale.x, color);

        if (!float.IsPositiveInfinity(destination.x) && Application.isPlaying) Draw.Gizmos.CircleXZ(destination, 0.2f, Color.blue);
        m_autoRepath.DrawGizmos(this);

        var newGizmoHash = pickNextWaypointDist.GetHashCode() ^ m_endReachedDistance.GetHashCode();
        if (newGizmoHash != gizmoHash && gizmoHash != 0) lastChangedTime = Time.realtimeSinceStartup;
        gizmoHash = newGizmoHash;
        var alpha = drawGizmos ? 1 : Mathf.SmoothStep(1, 0, (Time.realtimeSinceStartup - lastChangedTime - 5f) / 0.5f) * (UnityEditor.Selection.gameObjects.Length == 1 ? 1 : 0);

        if (!(alpha > 0)) return;
        if (!drawGizmos) UnityEditor.SceneView.RepaintAll();
        Draw.Gizmos.Line(position, steeringTarget, Color.magenta);
        Gizmos.matrix = Matrix4x4.TRS(position, transform.rotation * Quaternion.identity, Vector3.one);
        Draw.Gizmos.CircleXZ(Vector3.zero, pickNextWaypointDist, GizmoColor * new Color(1, 1, 1, alpha));
        Draw.Gizmos.CircleXZ(Vector3.zero, m_endReachedDistance, Color.Lerp(GizmoColor, Color.red, 0.8f) * new Color(1, 1, 1, alpha));
    }
#endif
}