using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3.PlayableAnimator
{
    /// <summary>
    /// 动画状态的姿态类
    /// 由多个动画状态组成树状关系
    /// 此状态进入的同帧就会退出，所以姿势态的Status会一直处于即将退出或退出
    /// 目前支持姿势态时，是否也驱动姿势对应的多个状态的时间线（让姿势动起来）
    /// </summary>
    public class StatePose : StatePlayable
    {
        public AnimatorControllerLayer animLayer => m_AnimLayer;
        public override bool isValid => true;
        public override float weight => m_InternalWeight;
        public override float speed => 1;
        public override float defaultSpeed => 1;
        public override bool isRunning => m_Status != InternalStatusType.Exit;
        public override bool isLooping => m_MainState.isLooping;
        public override float length => m_MainState.length;
        public override double normalizedTime => m_MainState.normalizedTime;
        public override Motion motion => null;
        public override int internalHashID => m_HashID;
        public override bool hasEmptyClip => m_Pose != null && m_Pose.hasEmptyClip;

        [NonSerialized] protected AnimatorControllerLayer m_AnimLayer;
        [NonSerialized] private float m_InternalWeight;

        [NonSerialized] private Pose m_Pose;
        [NonSerialized] private Pose m_CachePose;
        [NonSerialized] private StateMotion m_MainState;
        [NonSerialized] private StatePlayable m_NextState;
        [NonSerialized] private InternalStatusType m_Status = InternalStatusType.Exit;
        [NonSerialized] private int m_HashID;

        public StatePose(AnimatorControllerLayer layer) : base(Vector2.zero, null, null)
        {
            m_AnimLayer = layer;
        }

        public void Enter(StateMotion mainState, StatePlayable prevState, StatePlayable currState)
        {
            if (null == mainState)
            {
                return;
            }

            var pose = null == m_Pose ? PoseA.Get(currState, prevState) : PoseB.Get(mainState, m_Pose) as Pose;
            m_MainState = mainState;
            m_Name = mainState.name;
            m_Pose = pose;
            m_Status = InternalStatusType.PrepEnter;
            m_HashID++;
        }

        private void Exit()
        {
            SetWeight(0);
            m_HashID = 0;
            m_CachePose = m_Pose;
            m_Pose = null;
            m_Status = InternalStatusType.Exit;
            m_CachePose.OnExit(m_NextState);
        }

        public override void OnEnter(float startTime, StatePlayable prevState)
        {
        }

        public override void OnUpdate(float deltaTime, float lifeTime = float.MaxValue)
        {
            if (!isRunning)
            {
                return;
            }

            if (m_Status == InternalStatusType.PrepExit && lifeTime <= 0)
            {
                Exit();
                return;
            }

            m_Pose.OnUpdate(deltaTime);
            switch (m_Status)
            {
                case InternalStatusType.PrepEnter:
                    m_Status = InternalStatusType.Enter;
                    break;
                case InternalStatusType.PrepExit:
                    m_MainState?.CheckToDestinationState();
                    break;
            }
        }

        public override void OnExit(float lifeTime, StatePlayable nextState)
        {
            if (!isRunning)
            {
                return;
            }

            m_NextState = nextState;
            m_Status = InternalStatusType.PrepExit;
            if (lifeTime <= 0) Exit();
        }

        public override void OnDestroy()
        {
        }

        public override void Reset()
        {
        }

        public override void TickTime(float deltaTime)
        {
        }

        public override void SetWeight(float weight)
        {
            m_InternalWeight = weight;
            m_Pose?.SetWeight(weight);
        }

        public override void SetSpeed(float speed)
        {
        }

        public bool ContainState(StatePlayable state)
        {
            if (null == state || null == m_Pose)
            {
                return false;
            }

            return m_Pose.ContainState(state);
        }

        public abstract class Pose
        {
            public float weight { get; protected set; }
            public bool requiredUpdate { get; protected set; }
            public abstract bool hasEmptyClip { get; }
            public abstract bool ContainState(StatePlayable state);
            public abstract void SetWeight(float weight);
            public abstract void OnUpdate(float deltaTime);
            public abstract void OnExit(StatePlayable nextState);
        }

        public class PoseA : Pose
        {
            public StatePlayable stateA { get; protected set; }
            public StatePlayable stateB { get; protected set; }
            public override bool hasEmptyClip => stateA.hasEmptyClip || stateB.hasEmptyClip;

            public override bool ContainState(StatePlayable state)
            {
                return stateA == state || stateB == state;
            }

            public override void SetWeight(float weight)
            {
                stateA.SetWeight(weight * this.weight);
                stateB.SetWeight(weight * (1 - this.weight));
            }

            public override void OnUpdate(float deltaTime)
            {
                if (!requiredUpdate) return;
                stateA.TickTime(deltaTime);
                stateB.TickTime(deltaTime);
            }

            public override void OnExit(StatePlayable nextState)
            {
                stateB?.OnExit(0, nextState);
                stateA?.OnExit(0, nextState);
                Back(this);
            }

            private static Stack<PoseA> _cache = new Stack<PoseA>();

            public static void Back(PoseA pose)
            {
                if (null == pose)
                {
                    return;
                }

                pose.weight = 0;
                pose.stateA = null;
                pose.stateB = null;
                _cache.Push(pose);
            }

            public static PoseA Get(StatePlayable stateA, StatePlayable stateB, bool requireUpdate = false)
            {
                var pose = _cache.Count > 0 ? _cache.Pop() : new PoseA();
                pose.requiredUpdate = requireUpdate;
                pose.weight = stateA.weight;
                pose.stateA = stateA;
                pose.stateB = stateB;
                return pose;
            }
        }

        public class PoseB : Pose
        {
            public StatePlayable stateA { get; protected set; }
            public Pose poseB { get; protected set; }
            public override bool hasEmptyClip => stateA.hasEmptyClip || poseB.hasEmptyClip;

            public override bool ContainState(StatePlayable state)
            {
                return stateA == state || poseB.ContainState(state);
            }

            public override void SetWeight(float weight)
            {
                stateA.SetWeight(weight * this.weight);
                poseB.SetWeight(weight * (1 - this.weight));
            }

            public override void OnUpdate(float deltaTime)
            {
                if (!requiredUpdate) return;
                stateA.TickTime(deltaTime);
                poseB.OnUpdate(deltaTime);
            }

            public override void OnExit(StatePlayable nextState)
            {
                poseB.OnExit(nextState);
                stateA.OnExit(0, nextState);
                Back(this);
            }

            private static Stack<PoseB> _cache = new Stack<PoseB>();

            public static void Back(PoseB pose)
            {
                if (null == pose)
                {
                    return;
                }

                pose.weight = 0;
                pose.stateA = null;
                pose.poseB = null;
                _cache.Push(pose);
            }

            public static PoseB Get(StatePlayable stateA, Pose poseB, bool requireUpdate = false)
            {
                var pose = _cache.Count > 0 ? _cache.Pop() : new PoseB();
                pose.requiredUpdate = requireUpdate;
                pose.weight = stateA.weight;
                pose.stateA = stateA;
                pose.poseB = poseB;
                return pose;
            }
        }
    }
}