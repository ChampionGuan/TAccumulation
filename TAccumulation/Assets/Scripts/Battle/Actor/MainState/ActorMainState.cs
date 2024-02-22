using System;
using System.Collections.Generic;
using NodeCanvas.StateMachines;
using PapeGames.X3;

namespace X3Battle
{
    public class ActorMainState : ActorComponent
    {
        private Action<EventActorStateChange> _actionOnActorStateChange;
        
        
        public interface IArg
        {
        }

        /// <summary>
        /// 改变状态项
        /// </summary>
        public class ChangeStateInfo : IReset
        {
            public bool isToState { get; private set; } = true;
            public ActorMainStateType stateType { get; private set; }
            public int subType { get; private set; }
            public ActorStateMatrix.IArg stateArg { get; private set; }
            public Action<bool, IArg> callback { get; private set; }
            public IArg callbackArg { get; private set; }

            public void Init(bool isToState, ActorMainStateType mainStateType, int subType, ActorStateMatrix.IArg stateArg, Action<bool, IArg> callback, IArg callbackArg)
            {
                this.isToState = isToState;
                this.stateType = mainStateType;
                this.subType = subType;
                this.stateArg = stateArg;
                this.callback = callback;
                this.callbackArg = callbackArg;
            }

            public void Reset()
            {
                this.isToState = true;
                this.stateType = ActorMainStateType.Num;
                this.stateArg = null;
                this.callback = null;
                this.callbackArg = null;
            }

            public static ChangeStateInfo Create(bool isToState, ActorMainStateType mainStateType, int subType, ActorStateMatrix.IArg stateArg, Action<bool, IArg> callback, IArg callbackArg)
            {
                var item = ObjectPoolUtility.CandidateMainStateItemPool.Get();
                item.Init(isToState, mainStateType, subType, stateArg, callback, callbackArg);
                return item;
            }

            public static void Recycle(ChangeStateInfo info)
            {
                ObjectPoolUtility.CandidateMainStateItemPool.Release(info);
            }
        }

        public class AbnormalInfo : IReset
        {
            public ActorAbnormalType type { get; private set; }
            public object adder { get; private set; }

            public void Init(ActorAbnormalType type, object adder)
            {
                this.type = type;
                this.adder = adder;
            }

            public void Reset()
            {
                type = ActorAbnormalType.None;
                adder = null;
            }

            public override string ToString()
            {
                return $"{type.ToString()}:{adder}";
            }
        }

        // 虚弱>受击>眩晕
        public static readonly Dictionary<ActorAbnormalType, int> AbnormalPriority = new Dictionary<ActorAbnormalType, int>
        {
            { ActorAbnormalType.None, 0 },
            { ActorAbnormalType.Vertigo, 1 },
            { ActorAbnormalType.Hurt, 2 },
            { ActorAbnormalType.Weak, 3 }
        };

        public static readonly Dictionary<ActorMainStateType, int> MainStatePriority = new Dictionary<ActorMainStateType, int>
        {
            { ActorMainStateType.Num, -1 },
            { ActorMainStateType.Born, 0 },
            { ActorMainStateType.Idle, 1 },
            { ActorMainStateType.Move, 1 },
            { ActorMainStateType.Skill, 2 },
            { ActorMainStateType.Abnormal, 3 },
            { ActorMainStateType.Dead, 4 },
        };

        private static readonly Dictionary<ActorMainStateType, EventType> _EnterStateEventTypes = new Dictionary<ActorMainStateType, EventType>
        {
            { ActorMainStateType.Born, EventType.OnActorEnterBornState },
            { ActorMainStateType.Idle, EventType.OnActorEnterIdleState },
            { ActorMainStateType.Move, EventType.OnActorEnterMoveState },
            { ActorMainStateType.Skill, EventType.OnActorEnterSkillState },
            { ActorMainStateType.Dead, EventType.OnActorEnterDeadState },
            { ActorMainStateType.Abnormal, EventType.OnActorEnterAbnormalState }
        };

        public const string ArgBornActionModule = "ArgBornActionModule";
        public const string ArgDeadActionModule = "ArgDeadActionModule";
        public const string ArgHurtLieDeadActionModule = "ArgHurtLieDeadActionModule";
        public const string ArgOnStateEndCheck = "ArgOnStateEndCheck";
        public const string ArgSkipDeadActionModule = "ArgSkipDeadActionModule";
        public const string ArgSkipDeadSkill = "ArgSkipDeadSkill";

        private NotionGraph<FSMOwner> _fsmOwner;
        private ActorMainStateContext _fsmContext;

        private AbnormalInfo _currAbnormalInfo; // 当前异常
        private List<AbnormalInfo> _allAbnormalInfo;
        private AbnormalState _abnormalState;

        private Dictionary<ActorMainStateType, BaseMainState> _allFsmStates;
        private BaseMainState _currFsmState;

        private bool _isLocked; // 上锁保护切状态期间不会产生新的切状态.

        private List<ChangeStateInfo> _tempStateInfoList; // 临时列表.
        private List<ChangeStateInfo> _pendingStateInfoList; // 候选列表.
        private ChangeStateInfo _currStateInfo; // 正在处理的状态.
        private ChangeStateInfo _nextStateInfo; // 待处理的状态.

        /// <summary> 前一个主状态. </summary>
        public ActorMainStateType prevStateType { get; private set; }

        /// <summary> 当前的主状态. </summary>
        public ActorMainStateType mainStateType { get; private set; }

        /// <summary> 前一个异常状态. </summary>
        public ActorAbnormalType prevAbnormalType { get; private set; }

        /// <summary> 当前的异常状态. </summary>
        public ActorAbnormalType abnormalType => _currAbnormalInfo?.type ?? ActorAbnormalType.None;

        public ActorMainState() : base(ActorComponentType.MainState)
        {
            _actionOnActorStateChange = _OnActorStateChange;
        }

        protected override void OnAwake()
        {
            _allAbnormalInfo = new List<AbnormalInfo>(5);
            _pendingStateInfoList = new List<ChangeStateInfo>(5);
            _tempStateInfoList = new List<ChangeStateInfo>(5);
            _fsmContext = new ActorMainStateContext(this.actor, _OnLockCallback, _OnChangeAbnormalType);
            _fsmOwner = new NotionGraph<FSMOwner>();
            _fsmOwner.Init(_fsmContext, BattleConst.MainFSMName, BattleResType.Fsm, actor.GetDummy(), false);

            _abnormalState = new AbnormalState(this);
            _allFsmStates = new Dictionary<ActorMainStateType, BaseMainState>
            {
                { ActorMainStateType.Born, new BornState(this) },
                { ActorMainStateType.Idle, new IdleState(this) },
                { ActorMainStateType.Move, new MoveState(this) },
                { ActorMainStateType.Skill, new SkillState(this) },
                { ActorMainStateType.Dead, new DeadState(this) },
                { ActorMainStateType.Abnormal, _abnormalState },
            };
        }

        protected override void OnDestroy()
        {
            _allFsmStates.Clear();
            _fsmOwner.OnDestroy();
            _fsmOwner = null;
        }

        public override void OnBorn()
        {
            _isLocked = false;
            _allAbnormalInfo.Clear();
            _pendingStateInfoList.Clear();
            _currAbnormalInfo = null;

            prevStateType = ActorMainStateType.Num;
            mainStateType = ActorMainStateType.Num;
            prevAbnormalType = ActorAbnormalType.None;
            foreach (var fsmState in _allFsmStates.Values)
            {
                fsmState.Init();
            }

            var bornCfg = actor.bornCfg;
            if (bornCfg.BornActionModule != 0) actor.sequencePlayer.CreateBornFlowCanvasModule(bornCfg.BornActionModule);
            if (bornCfg.DeadActionModule != 0) actor.sequencePlayer.CreateFlowCanvasModule(bornCfg.DeadActionModule);
            if (bornCfg.HurtLieDeadActionModule != 0) actor.sequencePlayer.CreateFlowCanvasModule(bornCfg.HurtLieDeadActionModule);
            _fsmOwner.SetVariableValue(ArgBornActionModule, bornCfg.BornActionModule, true);
            _fsmOwner.SetVariableValue(ArgDeadActionModule, bornCfg.DeadActionModule, true);
            _fsmOwner.SetVariableValue(ArgHurtLieDeadActionModule, bornCfg.HurtLieDeadActionModule, true);
            _fsmOwner.SetVariableValue(ArgOnStateEndCheck, true, true);
            _fsmOwner.SetVariableValue(ArgSkipDeadSkill, false, true);
            _fsmOwner.SetVariableValue(ArgSkipDeadActionModule, false, true);
            using (ProfilerDefine.ActorMainStateMainFSMRestartPMarker.Auto())
            {
                _fsmOwner.Restart();
            }
            actor.eventMgr.AddListener(EventType.ActorStateChange, _actionOnActorStateChange, "ActorTimeScaler._OnActorStateChange");
        }
        
        public void OnDead()
        {
            actor.eventMgr.RemoveListener(EventType.ActorStateChange, _actionOnActorStateChange);
        }

        /// <summary>
        /// 进入异常状态后，将忽略一段时间的魔女缩放
        /// </summary>
        /// <param name="data"></param>
        private void _OnActorStateChange(EventActorStateChange data)
        {
            if (data.fromStateName != ActorMainStateType.Abnormal && data.toStateName != ActorMainStateType.Abnormal)
            {
                return;
            }

            actor.SetWitchDisabled(data.toStateName == ActorMainStateType.Abnormal);
        }

        public override void OnRecycle()
        {
            using (ProfilerDefine.ActorMainStateMainFSMDisablePMarker.Auto())
            {
                _fsmOwner.Disable(true);
            }

            foreach (var fsmState in _allFsmStates.Values)
            {
                fsmState.UnInit();
            }
        }

        protected override void OnUpdate()
        {
            using (ProfilerDefine.ActorMainStateSubStateUpdatePMarker.Auto())
            {
                _currFsmState?.Update();
            }
        }

        public bool TriggerFSMEvent(string eventName)
        {
            return _fsmOwner.TriggerFSMEvent(eventName);
        }

        public void SkipDeadEffect()
        {
            _fsmOwner.SetVariableValue(ArgSkipDeadSkill, true, true);
            _fsmOwner.SetVariableValue(ArgSkipDeadActionModule, true, true);
        }

        public void SetDeadActionModule(int deadActionModule)
        {
            _fsmOwner.SetVariableValue(ArgDeadActionModule, deadActionModule, true);
        }

        public void GetAllAbnormalInfo(List<AbnormalInfo> outList)
        {
            if (null == outList) return;
            outList.Clear();
            outList.AddRange(_allAbnormalInfo);
        }

        public AbnormalInfo GetDestAbnormalInfo()
        {
            return _allAbnormalInfo.Count > 0 ? _allAbnormalInfo[_allAbnormalInfo.Count - 1] : null;
        }

        public bool HasAbnormalType(ActorAbnormalType type)
        {
            foreach (var value in _allAbnormalInfo)
            {
                if (value.type == type)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 尝试进入某异常, callback返回结果.
        /// </summary>
        /// <param name="type"> 异常枚举 </param>
        /// <param name="callback"> callback的bool返回值, 指的是当前异常数据列表是否有当前这个异常枚举.(并没有考虑来源)! </param>
        /// <param name="callbackArg"></param>
        public void TryEnterAbnormal(ActorAbnormalType type, object adder, Action<bool, IArg> callback = null, IArg callbackArg = null)
        {
            if (type == ActorAbnormalType.None)
            {
                return;
            }

            var result = ActorStateMatrix.CanToAbnormal(actor, type);
            switch (result)
            {
                case ActorStateMatrix.Result.Failure:
                    callback?.Invoke(HasAbnormalType(type), callbackArg);
                    return;
                case ActorStateMatrix.Result.SucceedAndMutex:
                    _TryRemoveAbnormal(abnormalType, _currAbnormalInfo.adder);
                    break;
            }

            _TryAddAbnormal(type, adder);

            var destAbnormal = GetDestAbnormalInfo();
            if (null != destAbnormal && destAbnormal.type != abnormalType)
            {
                // DONE: 异常切异常.
                _TrySetState(ActorMainStateType.Abnormal, (int)destAbnormal.type, callback: callback, callbackArg: callbackArg);
            }
            else
            {
                callback?.Invoke(HasAbnormalType(type), callbackArg);
            }
        }

        public void TryEndAbnormal(ActorAbnormalType type, object adder)
        {
            if (type == ActorAbnormalType.None)
            {
                return;
            }
            
            if (!_TryRemoveAbnormal(type, adder))
            {
                return;
            }

            var destAbnormal = GetDestAbnormalInfo();
            if (null == destAbnormal)
            {
                // DONE: 退出异常状态
                _TryEndState(ActorMainStateType.Abnormal);
            }
            else if (destAbnormal.type != abnormalType)
            {
                _TrySetState(ActorMainStateType.Abnormal, (int)destAbnormal.type);
            }
        }

        public bool IsState(ActorMainStateType value)
        {
            return mainStateType == value;
        }

        public bool CanToState(ActorMainStateType toState, ActorStateMatrix.IArg arg = null)
        {
            return ActorStateMatrix.CanToState(actor, toState, arg);
        }

        public void TryToState(ActorMainStateType toState, ActorStateMatrix.IArg toStateArg = null, Action<bool, IArg> callback = null, IArg callbackArg = null)
        {
            _TrySetState(toState, 0, toStateArg, callback, callbackArg);
        }

        public void StopSkill()
        {
            _TryEndState(ActorMainStateType.Skill);
        }

        /// <summary>
        /// 尝试切换状态
        /// 目的状态与当前相同/单位已死亡/未出生，返回失败
        /// </summary>
        /// <param name="targetStateType"></param>
        /// <returns></returns>
        private void _TrySetState(ActorMainStateType targetStateType, int subType = 0, ActorStateMatrix.IArg stateArg = null, Action<bool, IArg> callback = null, IArg callbackArg = null)
        {
            if (!ActorStateMatrix.CanToState(actor, targetStateType, stateArg))
            {
                callback?.Invoke(false, callbackArg);
                return;
            }

            var stateInfo = ChangeStateInfo.Create(true, targetStateType, subType, stateArg, callback, callbackArg);
            // DONE: 切换状态上锁了, 不允许切换状态.
            if (_isLocked)
            {
                LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}), 当前主状态:{1}, 尝试切换至主状态{2}的行为放置候选队列.", this.actor.name, this.mainStateType, targetStateType);
                _pendingStateInfoList.Add(stateInfo);
                return;
            }

            // DONE: 正在处理的状态切换Callback.
            _currStateInfo = stateInfo;
            
            if (mainStateType != ActorMainStateType.Num)
            {
                // DONE: 结束当前主状态后的FSM状态间自然过渡关闭.
                _fsmOwner.SetVariableValue(ArgOnStateEndCheck, false, true);
                // 旧状态退出
                TriggerFSMEvent(FSMEventName.MainStatesEnd[(int)mainStateType]);
            }

            if (targetStateType != ActorMainStateType.Num)
            {
                // 新状态进入
                TriggerFSMEvent(FSMEventName.MainStates[(int)targetStateType]);
            }
        }

        /// <summary>
        /// 尝试结束状态
        /// </summary>
        /// <param name="targetStateType"></param>
        private void _TryEndState(ActorMainStateType targetStateType)
        {
            if (targetStateType == ActorMainStateType.Num)
            {
                return;
            }

            if (mainStateType != targetStateType)
            {
                LogProxy.LogWarning($"【战斗】【主状态机】角色(name={actor.name})状态机：当前不处于【{targetStateType}】状态，无法退出！");
                return;
            }

            if (_isLocked)
            {
                LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}), 尝试退出当前主状态{1}的行为放置候选队列.", this.actor.name, targetStateType);
                _pendingStateInfoList.Add(ChangeStateInfo.Create(false, targetStateType, 0, null, null, null));
                return;
            }

            TriggerFSMEvent(FSMEventName.MainStatesEnd[(int)targetStateType]);
        }

        /// <summary>
        /// 加入异常状态等待队列
        /// 进入队列的状态保持有序，高优先级在队尾
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        private void _TryAddAbnormal(ActorAbnormalType type, object adder)
        {
            if (type == ActorAbnormalType.None)
            {
                return;
            }
            
            LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}), 添加了异常状态数据{1}", this.actor.name, type);
            var info = ObjectPoolUtility.AbnormalInfoPool.Get();
            info.Init(type, adder);
            _allAbnormalInfo.Add(info);

            for (var i = _allAbnormalInfo.Count - 1; i >= 1; i--)
            {
                if (AbnormalPriority[_allAbnormalInfo[i].type] >= AbnormalPriority[_allAbnormalInfo[i - 1].type])
                {
                    break;
                }

                var tempType = _allAbnormalInfo[i];
                _allAbnormalInfo[i] = _allAbnormalInfo[i - 1];
                _allAbnormalInfo[i - 1] = tempType;
            }

            _abnormalState.OnChangeAbnormalType(type, adder, true);
            _DispatchAbnormalChangeEvent(type, adder, true);
        }

        /// <summary>
        /// 尝试移除异常子态
        /// </summary>
        private bool _TryRemoveAbnormal(ActorAbnormalType type, object adder)
        {
            if (type == ActorAbnormalType.None)
            {
                return false;
            }

            AbnormalInfo tgtAbnormalInfo = null;
            for (var i = _allAbnormalInfo.Count - 1; i >= 0; i--)
            {
                var abnormalInfo = _allAbnormalInfo[i];
                if (abnormalInfo.type != type || abnormalInfo.adder != adder) continue;

                _allAbnormalInfo.RemoveAt(i);
                tgtAbnormalInfo = abnormalInfo;
                break;
            }

            if (null == tgtAbnormalInfo)
            {
                return false;
            }

            LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}), 移除了异常状态数据{1}", this.actor.name, type);
            _abnormalState.OnChangeAbnormalType(tgtAbnormalInfo.type, tgtAbnormalInfo.adder, false);
            _DispatchAbnormalChangeEvent(tgtAbnormalInfo.type, tgtAbnormalInfo.adder, false);
            ObjectPoolUtility.AbnormalInfoPool.Release(tgtAbnormalInfo);
            return true;
        }
        
        private void _OnChangeAbnormalType(ActorAbnormalType toAbnormalType)
        {
            prevAbnormalType = abnormalType;
            _currAbnormalInfo = null;
            
            // DONE: 拿着toAbnormalType找到最高优先级匹配的abnormalInfo结构.
            if (toAbnormalType != ActorAbnormalType.None)
            {
                for (var i = _allAbnormalInfo.Count - 1; i >= 0; i--)
                {
                    var abnormalInfo = _allAbnormalInfo[i];
                    if (abnormalInfo.type == toAbnormalType)
                    {
                        _currAbnormalInfo = abnormalInfo;
                        break;
                    }
                }
            }
        }

        private void _OnLockCallback(ActorMainStateType toStateType, bool isLock)
        {
            // DONE: 1.添加标记的时候之前的标记未清除|| 解除标记的时候用的和之前的key不是同一个.
            if (isLock == _isLocked)
            {
                LogProxy.LogFatal($"【战斗】【严重错误】【ActorMainState】出现上锁行为不对称的严重问题. mainStateType={mainStateType}, _isLock={_isLocked}, toStateType={toStateType}, isLock={isLock}");
                return;
            }

            switch (isLock)
            {
                case false when toStateType != mainStateType:
                    LogProxy.LogFatal($"【战斗】【严重错误】【ActorMainState】出现LockKey不对称的严重问题. mainStateType={mainStateType}, _isLock={_isLocked}, toStateType={toStateType}, isLock={isLock}");
                    return;
                case true:
                    _SetLock(toStateType);
                    break;
                default:
                    _SetUnlock(toStateType);
                    break;
            }
        }

        private void _SetLock(ActorMainStateType toStateType)
        {
            // DONE: 上锁
            _isLocked = true;
            
            // DONE: 切原子状态.
            prevStateType = mainStateType;
            mainStateType = toStateType;
            
            // DONE: 子状态的退出逻辑.
            _currFsmState?.Exit(toStateType);
            
            LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}), 主状态从{1}切换至{2}", this.actor.name, this.prevStateType, mainStateType);
        }

        private void _SetUnlock(ActorMainStateType toStateType)
        {
            // DONE: 处理进入子状态.
            if (!_allFsmStates.TryGetValue(mainStateType, out var fsmState))
            {
                _currFsmState = null;
            }
            else
            {
                _currFsmState = fsmState;
                _currFsmState.Enter();
            }

            // DONE: 处理当前状态的callback.
            if (_currStateInfo != null)
            {
                bool result = true;
                
                // DONE: 如果是异常态, 还要比较异常子态是否进入到预期目标子态.
                if (_currStateInfo.isToState && _currStateInfo.stateType == ActorMainStateType.Abnormal)
                {
                    result = HasAbnormalType((ActorAbnormalType)_currStateInfo.subType);
                }

                _currStateInfo.callback?.Invoke(result, _currStateInfo.callbackArg);
                ChangeStateInfo.Recycle(_currStateInfo);
                _currStateInfo = null;
            }

            // DONE: 抛事件.
            _DispatchStateChangeEvent();

            // 尝试获取下一个状态信息
            _nextStateInfo = _TryGetNextStateInfo();

            // DONE: 解锁.
            _isLocked = false;

            // DONE: 结束当前主状态后的FSM状态间自然过渡打开.
            _fsmOwner.SetVariableValue(ArgOnStateEndCheck, true, true);

            // DONE: 开始处理下一个状态
            if (_nextStateInfo != null)
            {
                var isToState = _nextStateInfo.isToState;
                var stateType = _nextStateInfo.stateType;
                var subType = _nextStateInfo.subType;
                var stateArg = _nextStateInfo.stateArg;
                var callback = _nextStateInfo.callback;
                var callbackArg = _nextStateInfo.callbackArg;
                ChangeStateInfo.Recycle(_nextStateInfo);
                _nextStateInfo = null;

                if (isToState)
                {
                    LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}), 处理候选队列进入状态{1}", this.actor.name, stateType);
                    _TrySetState(stateType, subType, stateArg, callback, callbackArg);
                }
                else
                {
                    LogProxy.LogFormat("【战斗】【主状态机】角色(name={0}), 处理候选队列退出状态{1}", this.actor.name, stateType);
                    _TryEndState(stateType);
                }
            }
        }

        private ChangeStateInfo _TryGetNextStateInfo()
        {
            var count = _pendingStateInfoList.Count;
            if (count <= 0) return null;

            // DONE: 将排序的候选队列Copy到一个新的队列再进行执行.
            _tempStateInfoList.Clear();
            _tempStateInfoList.AddRange(_pendingStateInfoList);
            _pendingStateInfoList.Clear();

            ChangeStateInfo nextStateInfo = null;
            // 按照优先级规则，取下一个状态信息
            foreach (var stateInfo in _tempStateInfoList)
            {
                if (stateInfo.isToState)
                {
                    // 如果目标状态是异常，需要检测当前是否还有异常数据
                    if (stateInfo.stateType == ActorMainStateType.Abnormal && GetDestAbnormalInfo() == null)
                    {
                        continue;
                    }
                }

                if (null == nextStateInfo)
                {
                    nextStateInfo = stateInfo;
                    continue;
                }

                switch (stateInfo.isToState)
                {
                    case true when !nextStateInfo.isToState:
                        nextStateInfo = stateInfo;
                        continue;
                    case false:
                        continue;
                }

                if (MainStatePriority[stateInfo.stateType] > MainStatePriority[nextStateInfo.stateType])
                {
                    nextStateInfo = stateInfo;
                }
            }

            // DONE: 处理候选列表里失败状态的Callback.
            foreach (var stateInfo in _tempStateInfoList)
            {
                if (stateInfo == nextStateInfo)
                {
                    continue;
                }

                stateInfo.callback?.Invoke(false, stateInfo.callbackArg);
                ChangeStateInfo.Recycle(stateInfo);
            }

            _tempStateInfoList.Clear();
            return nextStateInfo;
        }

        private void _DispatchStateChangeEvent()
        {
            var fromStateType = prevStateType;
            var toStateType = mainStateType;

            // 抛出通用事件
            var eventData = actor.eventMgr.GetEvent<EventActorStateChange>();
            eventData.Init(actor, fromStateType, toStateType);
            actor.eventMgr.Dispatch(EventType.ActorStateChange, eventData);

            if (!_EnterStateEventTypes.TryGetValue(toStateType, out var eventType))
            {
                LogProxy.LogError($"【战斗】【主状态机】_stateEventTypes事件未注册{toStateType}, 需要处理!");
                return;
            }

            var enterStateData = actor.eventMgr.GetEvent<EventActorEnterStateBase>();
            enterStateData.Init(actor, fromStateType);
            actor.eventMgr.Dispatch(eventType, enterStateData);
        }

        private void _DispatchAbnormalChangeEvent(ActorAbnormalType type, object adder, bool active)
        {
            var eventData = actor.eventMgr.GetEvent<EventAbnormalTypeChange>();
            eventData.Init(actor, type, adder, active);
            actor.eventMgr.Dispatch(EventType.AbnormalTypeChange, eventData);
        }
    }
}