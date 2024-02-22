using System;
using MessagePack;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public enum ActorCmdState
    {
        Initial,
        Running,
        Successful,
        Interrupted,
    }

    [Union(0, typeof(ActorEndBattleCommand))]
    [Union(1, typeof(ActorMoveDirCmd))]
    [Union(2, typeof(ActorMovePosCmd))]
    [Union(3, typeof(ActorSkillCommand))]
    [Union(4, typeof(ActorSwitchTargetCmd))]
    [Union(5, typeof(ActorCancelLockCacheCmd))]
    [Union(6, typeof(ActorBtnStateCommand))]
    [Union(7, typeof(CreateRoleCmd))]
    [Union(8, typeof(ActorSkillCmdEditor))]
    [Union(9, typeof(ActorLockModeCommand))]
    [MessagePackObject]
    public abstract class ActorCmd : IReset
    {
        [IgnoreMember] private Action<ActorCmd> _onFinished;

        /// <summary>
        /// 角色
        /// </summary>
        [IgnoreMember]
        public Actor actor { get; private set; }

        /// <summary>
        /// 指令状态
        /// </summary>
        [IgnoreMember]
        public ActorCmdState state { get; private set; } = ActorCmdState.Initial;

        /// <summary>
        /// 指令运行中
        /// </summary>
        [IgnoreMember]
        public bool isRunning => state == ActorCmdState.Running;

        /// <summary>
        /// 是否是后台模式运行
        /// 后台模式：不会打断当前的指令，并行执行一帧且结束
        /// </summary>
        [IgnoreMember]
        public virtual bool isBgCmd { get; }

        public ActorCmd()
        {
        }

        public void Reset()
        {
            actor = null;
            state = ActorCmdState.Initial;
            _onFinished = null;
            _OnReset();
        }

        public void SetActor(Actor actor)
        {
            this.actor = actor;
        }

        public virtual bool CanExecuted()
        {
            return true;
        }

        public void Start(Action<ActorCmd> onFinished)
        {
            using (ProfilerDefine.ActorCmdStartPMarker.Auto())
            {
                if (state != ActorCmdState.Initial)
                {
                    LogProxy.LogError($"ActorCmd.Start() {GetType()}执行状态异常，该指令未被重复，会有脏数据存在，请注意检查！！");
                }

                this.state = ActorCmdState.Running;
                _onFinished = onFinished;

                // Editor下默认开启， 真机上如果勾选录像，也需要记录指令.  只记录主控角色
                if ((actor.battle.arg.replayMode == BattleReplayMode.Record || Application.isEditor) &&
                    actor.IsPlayer())
                {
                    var eventData = actor.battle.eventMgr.GetEvent<EventActorCommand>();
                    eventData.Init(actor, this);
                    actor.battle.eventMgr.Dispatch(EventType.ActorCommand, eventData);
                }

                _OnEnter();
            }
        }

        public void Finish(ActorCmd nextCmd = null, bool interrupt = false)
        {
            if (state == ActorCmdState.Successful || state == ActorCmdState.Interrupted)
            {
                return;
            }

            if (isRunning)
            {
                state = interrupt || null != nextCmd ? ActorCmdState.Interrupted : ActorCmdState.Successful;
                _OnExit(nextCmd);

                //抛出指令事件
                var eventData = actor.eventMgr.GetEvent<EventActorCmdFinished>();
                eventData.Init(this);
                actor.eventMgr.Dispatch(EventType.ActorCmdFinished, eventData);
            }

            _onFinished?.Invoke(this);
        }

        public void Update()
        {
            if (!isRunning) return;
            _OnUpdate();
        }

        protected virtual void _OnEnter()
        {
        }

        protected virtual void _OnUpdate()
        {
        }

        protected virtual void _OnExit(ActorCmd nextCmd)
        {
        }

        protected virtual void _OnReset()
        {
        }
    }
}