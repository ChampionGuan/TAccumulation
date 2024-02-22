using System.Collections.Generic;
using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using NodeCanvas.StateMachines;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class ActorCombatAI : AIActionQueue
    {
        #region Debug调试信息

        public List<IAIActionGoal> waitActions => _waitActions;
        public IAIActionGoal currAction => _currAction;

        #endregion

        private const int SwitchOn = (int)(AISwitchType.Active | AISwitchType.Revive | AISwitchType.Debug | AISwitchType.Player | AISwitchType.ActionModule | AISwitchType.LevelBefore);
        /// <summary>
        /// 是否处于禁用状态
        /// </summary>
        public override bool disabled => _switchState != SwitchOn;
        
        private int _switchState = SwitchOn;

        /// <summary>
        /// 是否处于暂停状态
        /// </summary>
        public override bool paused { get; set; }
		
		private bool _isStarted;
        private ActorAIStatus _cachedStatus = ActorAIStatus.None;
        
        protected ActorAIContext _aiContext;
        protected NotionGraph<FSMOwner> _treeOwner;
        
        protected const string _variableSelfKey = "selfActor";
        protected const string _variableGirlKey = "girl";
        protected const string _variableBoyKey = "boy";
		//与策划（楚门）约定的 Tag 名称
        protected const string _battleStateTag = "Battle";

        //用于在动态设置行为树后返回原始的子树
        private BehaviourTree _originalSubTree = null;

        public bool isStarted => _isStarted;

        public ActorCombatAI(Actor owner, string aiName) : base(null)
        {
            _treeOwner = new NotionGraph<FSMOwner>();
            context = _aiContext = new ActorAIContext(owner, _treeOwner) { status = ActorAIStatus.None, actionQueue = this };
            _treeOwner.Init(_aiContext, aiName, BattleResType.AITree, actor.GetDummy(), false);

            //初始化默认的黑板值。TODO：后期补上编辑器需求
            _treeOwner.SetVariableValue(_variableSelfKey, actor);
            _treeOwner.SetVariableValue(_variableGirlKey, actor.battle.actorMgr.girl);
            _treeOwner.SetVariableValue(_variableBoyKey, actor.battle.actorMgr.boy);
            actor.battle.eventMgr.AddListener<EventActorBase>(EventType.ActorBorn, _OnActorBorn, "ActorCombatAI._OnActorBorn");
            
            //预加载动态切换子树
            if (owner.IsGirl())
            {
                _PreCreateSubTree(BattleEnv.GirlSubTreeList);
            }
            if (owner.IsBoy())
            {
                _PreCreateSubTree(BattleEnv.BoySubTreeList);
            }
            _originalSubTree = null;
        }

        private void _PreCreateSubTree(HashSet<BehaviourTree> subTreeList)
        {
            if (subTreeList == null)
            {
                return;
            }
            foreach (var subTree in subTreeList)
            {
                NestedBTState targetBTState = _SetBehaviourTree(subTree);
                if (targetBTState == null)
                {
                    LogProxy.LogError($"预加载动态子树失败，subTree = {subTree},actor = {actor}");
                }

                BackToOriginalSubTree();
            }
        }

        public void Update(float deltaTime)
        {
            _TryStartAI();
            if (paused || disabled)
            {
                return;
            }

            base.Update(deltaTime);
        }

        public void Reset()
        {
            _isStarted = false;
            _cachedStatus = ActorAIStatus.None;
            _switchState = SwitchOn;
            paused = false;
            _aiContext.status = ActorAIStatus.None;
        }

        public void Destroy()
        {
            _treeOwner?.OnDestroy();
            _originalSubTree = null;
        }

        public void Pause(bool paused)
        {
            if (this.paused == paused)
            {
                return;
            }
            this.paused = paused;
            if (disabled)
            {
                return;
            }

            if (!_isStarted)
            {
                return;
            }
            _treeOwner?.Paused(paused);
        }

        public void Disable(bool disabled, AISwitchType switchType)
        {
            if (_treeOwner == null)
            {
                return;
            }

            var switchValue = (int)switchType;
            if (disabled)
            {
                switchValue = ~switchValue;
                _switchState = switchValue & _switchState;
                if (_isStarted)
                {
                    _treeOwner.Disable(disabled);
                    _NotifyPlayerAIDisable();
                }
                ClearAllActions();
                return;
            }

            _switchState |= switchValue;
            if (_switchState != SwitchOn || !_isStarted) return;
            _treeOwner.Disable(disabled);
            _NotifyPlayerAIDisable();
            if (paused)
            {
                _treeOwner?.Paused(paused);
            }
        }
        
        private void _TryStartAI()
        {
            if (_isStarted)
            {
                return;
            }
            _treeOwner.Restart(true);
            _isStarted = true;
            //促使graph状态和combatAI状态统一
            if (disabled)
            {
                _treeOwner.Disable(true);
            }
            else if (paused)
            {
                _treeOwner?.Paused(paused);
            }

            Disable(!actor.roleBornCfg.IsAIActive, AISwitchType.Active);
            if (actor.type == ActorType.Hero)
            {
                SetTreeStatus(ActorAIStatus.Standby);
            }
            else
            {
                SetTreeStatus(actor.roleBornCfg.IsAIActive ? ActorAIStatus.Attack : ActorAIStatus.Standby);
            }

            if (!actor.roleBornCfg.AutoStartAI)
            {
                Disable(true, AISwitchType.LevelBefore);
            }
        }

        private void _NotifyPlayerAIDisable()
        {
            if (actor != Battle.Instance.player)
            {
                return;
            }
            var eventData = Battle.Instance.eventMgr.GetEvent<EventActorAIDisabled>();
            eventData.Init(actor, disabled);
            actor.eventMgr.Dispatch(EventType.ActorAIDisabled, eventData);
        }

        /// <summary>
        /// 开关AI
        /// </summary>
        /// <param name="aiSwitchType"></param>
        /// <returns></returns>
        public bool SwitchIsOn(AISwitchType aiSwitchType)
        {
            return ((int)aiSwitchType & _switchState) == (int)aiSwitchType;
        }

        /// <summary>
        /// 获取AI状态
        /// </summary>
        /// <returns></returns>
        public ActorAIStatus GetTreeStatus()
        {
            return _aiContext.status;
        }

        /// <summary>
        /// 设置AI状态
        /// </summary>
        /// <param name="status"></param>
        public void SetTreeStatus(ActorAIStatus status)
        {
            if (!_isStarted)
            {
                _cachedStatus = status;
                return;
            }
            if (_cachedStatus != ActorAIStatus.None)
            {
                status = _cachedStatus;
                _cachedStatus = ActorAIStatus.None;
            }
            
            if (status == _aiContext.status)
            {
                return;
            }
            _aiContext.status = status;
            if (status == ActorAIStatus.Attack)
            {
                actor.skillOwner?.StartAICD();
            }
            if (actor.IsRole())
            {
                _treeOwner.TriggerFSMEvent(BattleConst.ActorAIStatusUpdate);
            }

            if (status == ActorAIStatus.Attack)
            {
                actor.actorHate?.UpdateHates();
            }
            else
            {
                actor.actorHate?.ClearHates();
            }
            actor.lookAtOwner?.ResetLookAtStrategy();
        }

        /// <summary>
        /// 是否可以产生行为
        /// </summary>
        /// <returns></returns>
        protected override bool _CanGenerateActions()
        {
            // note:此处不要轻易更改，如果更改将会影响到之前已配置完成的AI树！！

            // 当前处于出生态，不可更新
            if (actor.mainState.mainStateType == ActorMainStateType.Born)
            {
                return false;
            }

            // 当前处于技能态，且不可被打断时，不可更新
            if (actor.mainState.mainStateType == ActorMainStateType.Skill && !actor.skillOwner.SkillCanMove())
            {
                return false;
            }

            // 当前处于受击态，且不可被打断时，不可更新
            if (actor.mainState.HasAbnormalType(ActorAbnormalType.Hurt) && !actor.hurt.hurtInterruptController.hurtInterruptByMove && !actor.hurt.hurtInterruptController.hurtInterruptBySkill)
            {
                return false;
            }

            //当前含有不能进入移动且不能释放技能的标签时，不可更新
            if (actor.stateTag.IsActive(ActorStateTagType.CannotEnterMove) && actor.stateTag.IsActive(ActorStateTagType.CannotCastSkill))
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// 角色出生
        /// </summary>
        /// <param name="data"></param>
        private void _OnActorBorn(EventActorBase data)
        {
            if (data.actor.type != ActorType.Hero) return;
            if (data.actor.subType == (int)HeroType.Boy)
            {
                _treeOwner.SetVariableValue(_variableBoyKey, actor.battle.actorMgr.boy);
            }
            else
            {
                _treeOwner.SetVariableValue(_variableGirlKey, actor.battle.actorMgr.girl);
            }
        }

        public void SwitchCurrentSubTree(BehaviourTree behaviourTree)
        {
            if (behaviourTree == null)
            {
                return;
            }

            using (ProfilerDefine.AISwitchCurrentSubTreePMarker.Auto())
            {
                NestedBTState targetBTState = _SetBehaviourTree(behaviourTree);


                if (targetBTState == null)
                {
                    return;
                }
                PapeGames.X3.LogProxy.Log($"动态切换子树，{targetBTState.subGraph} 切换 {behaviourTree}");
            }
            ClearAllActions();
        }

        public void BackToOriginalSubTree()
        {
            if (_originalSubTree == null)
            {
                PapeGames.X3.LogProxy.Log($"{actor} 没有动态切换过子树时就回退到原始子树!");
                return;
            }

            using (ProfilerDefine.AIBackToOriginalSubTreePMarker.Auto())
            {
                NestedBTState targetBTState = _SetBehaviourTree(_originalSubTree);
                if (targetBTState == null)
                {
                    return;
                }
                PapeGames.X3.LogProxy.Log($"恢复原始子树，{targetBTState.subGraph} 切换 {_originalSubTree}");
            }
        }
        
        private NestedBTState _SetBehaviourTree(BehaviourTree behaviourTree)
        {
            FSM fsm = _treeOwner.graph as FSM;
            if (fsm == null)
            {
                return null;
            }

            // 有的AI是一层，有的AI是两层,兼容性代码
            //待策划把所有配置中多余的状态机和原有切换机制删除后，可以缓存NestedBTState
            // NestedBTState targetBTState = fsm.currentState as NestedBTState;
            // while (fsm != null && targetBTState == null)
            // {
            //     if (fsm.currentState is NestedFSMState tempFSMState)
            //     {
            //         fsm = tempFSMState.subGraph;
            //         targetBTState = fsm.currentState as NestedBTState;
            //     }
            //     else
            //     {
            //         break;
            //     }
            // }
            
            NestedBTState targetBTState = null;
            NestedFSMState fsmState = null;
            //策划要求任何时候修改的都是战斗状态下的子树
            foreach (var node in fsm.allNodes)
            {
                if (node.tag == _battleStateTag)
                {
                    fsmState = node as NestedFSMState;
                    break;
                }
            }
            
            if (fsmState!=null)
            {
                fsm = fsmState.subGraph;
                foreach (var subNode in fsm.allNodes)
                {
                    //女主可能AI没有运行，用tag查找
                    if (subNode.tag == _battleStateTag)
                    {
                        targetBTState = subNode as NestedBTState;
                        break;
                    }
                }

                if (targetBTState == null)
                {
                    //如果二层tag找不到，用默认的运行中的当前状态
                    if (fsm.currentState == null)
                    {
                        // 状态机的图在OnGraphStart后的第一帧会处在Action state。currentState 是 null，此时执行下fsm，CheckTransitions
                        // 会更新currentState的状态，进入默认的第一个状态（目前AI状态机只有一个状态）
                        fsmState.Execute(_treeOwner.owner, _treeOwner.graph.blackboard);
                    }
                    targetBTState = fsm.currentState as NestedBTState;
                }
            }

            if (targetBTState == null)
            {
                PapeGames.X3.LogProxy.LogError($"动态切换子树，切换 {behaviourTree},未找到有标识的战斗状态");
                return null;
            }
            
            // 不能相同子树切相同子树
            if (targetBTState.subGraph?.name == behaviourTree.name)
            {
                return null;
            }
            
            targetBTState.subGraph.Stop();
            if (_originalSubTree == null)
            {
                _originalSubTree = targetBTState.subGraph;
            }
            targetBTState.subGraph = behaviourTree;
            
            //区分两种情况，如果当前就是在战斗状态，就需要重新进入。不在战斗状态，不重新进入
            //EnterState后判断BT的状态后会自动调用OnGraphStarted
            if (fsm.isRunning)
            {
                fsm.EnterState(targetBTState,FSM.TransitionCallMode.Normal);
            }
            else
            {
                targetBTState.CheckInstance();
            }
            
            return targetBTState;
        }
    }
}