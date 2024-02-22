using System;
using System.Collections.Generic;
using FlowCanvas;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class AIOwner : ActorComponent,IFrameUpdate
    {
        public bool requiredFrameUpdate => enabled || !isStarted;
        public bool canFrameUpdate { get; set; }
        private ActorCombatAI _combatAI;
        private float _globalSkillCD;

        private bool _isStrategy;
        private int _updateMinFrameCount;
        private float _actorTime;
        private bool _beStrategyControl;

        /// <summary>
        /// 角色AI是否处于禁用状态
        /// </summary>
        public bool enabled => _combatAI == null || !_combatAI.disabled && !_combatAI.paused;

        public bool isStarted => _combatAI?.isStarted ?? true;

        public bool isBattleState => status == ActorAIStatus.Attack;

        public bool isActive{ get; private set; }

        /// <summary>
        /// 角色AI状态
        /// </summary>
        public ActorAIStatus status => _combatAI?.GetTreeStatus() ?? ActorAIStatus.None;
        
        /// <summary>
        /// 真机调试器专用 TODO 可删 改为反射
        /// </summary>
        public ActorCombatAI combatAI => _combatAI;

        public bool isStrategy => _isStrategy;
        
        private Action<EventActorStateChange> _actionOnActorStateChange;

        public AIOwner() : base(ActorComponentType.AI)
        {
            _actionOnActorStateChange = _OnActorStateChange;
        }

        #region AI 记录数据
        private float _moveEndTimeStamp;
        private float _moveStartTimeStamp;

        //已经持续多久没有移动过了
        public float noMoveTime => _moveStartTimeStamp >= _moveEndTimeStamp ? 0 : actor.time - _moveEndTimeStamp;

        #endregion

        protected override void OnAwake()
        {
            //女主AI由武器中获取
            if (actor == actor.battle.actorMgr.girl)
            {
                WeaponLogicConfig weaponLogicConfig = BattleUtil.GetCurrentWeaponLogicConfig();
                if (!string.IsNullOrEmpty(weaponLogicConfig.AI))
                {
                    _combatAI = new ActorCombatAI(actor, weaponLogicConfig.AI);
                }
            }
            else if (!string.IsNullOrEmpty(actor.config.CombatAIName))
            {
                _combatAI = new ActorCombatAI(actor, actor.config.CombatAIName);
            }
        }

        protected override void OnDestroy()
        {
            _combatAI?.Destroy();
            _combatAI = null;
        }

        public override void OnBorn()
        {
            _globalSkillCD = -1;
            _isStrategy = true;
            _beStrategyControl = false;
            _updateMinFrameCount = battle.frameCount + 1;
            _actorTime = actor.time;
            _combatAI.Reset();

            isActive = actor.roleBornCfg.IsAIActive;
            actor.eventMgr.AddListener<EventActorStateChange>(EventType.ActorStateChange, _actionOnActorStateChange, "AIOwner._OnActorStateChange");
            battle.frameUpdateMgr.Add(this);
        }
        
        private void _OnActorStateChange(EventActorStateChange data)
        {
            if (data.toStateName == ActorMainStateType.Move)
            {
                _moveStartTimeStamp = actor.time;
            }
            else
            {
                _moveEndTimeStamp = actor.time;
            }
        }

        public override void OnRecycle()
        {
            battle.frameUpdateMgr.Remove(this);
            _combatAI.Reset();
            actor.eventMgr.RemoveListener<EventActorStateChange>(EventType.ActorStateChange, _actionOnActorStateChange);
        }

        protected override void OnUpdate()
        {
            //当前帧数小于可更新帧数
            if (battle.frameCount < _updateMinFrameCount)
            {
                return;
            }
            if (!canFrameUpdate)
            {
                return;
            }
            //PapeGames.X3.LogProxy.LogError($"【AIOwner】OnUpdate:{actor.insID}，FrameCount:{Time.frameCount}");
            float deltaTime = actor.time - _actorTime;
            _actorTime = actor.time;
            if (_globalSkillCD > 0)
            {
                _globalSkillCD -= deltaTime;
                if (_globalSkillCD <= 0)
                {
                    _globalSkillCD = -1;
                }
            }
            //Debug.LogError("AIOwner:OnUpdate" + actor.name);
            using (ProfilerDefine.CombatAIUpdatePMarker.Auto())
            {
                _combatAI?.Update(deltaTime);
            }
        }

        public float GetGlobalSkillCD()
        {
            return _globalSkillCD;
        }

        public bool IsInGlobalCD()
        {
            return !_beStrategyControl && _globalSkillCD > 0;
        }

        public void SetGlobalCD(float globalSkillCD, bool isStageStrategy = true)
        {
            _globalSkillCD = globalSkillCD * BattleUtil.GetAggressiveCDR(isStageStrategy);
        }

        public void TickCombatAI()
        {
            _combatAI?.Update(0);
        }

        public void SetCombatTreeStatus(ActorAIStatus status)
        {
            using (ProfilerDefine.AIOwnerSetCombatTreeStatusPMarker.Auto())
            {
                _combatAI?.SetTreeStatus(status);
            }
        }

        public bool SwitchIsOn(AISwitchType aiSwitchType)
        {
            if (_combatAI == null)
            {
                return true;
            }
            return _combatAI.SwitchIsOn(aiSwitchType);
        }
        
        /// <summary>
        /// 激活角色
        /// </summary>
        /// <param name="isActive"></param>
        public void ActiveAI(bool isActive)
        {
            this.isActive = isActive;
            DisableAI(!this.isActive, AISwitchType.Active);
            if (this.isActive)
            {
                SetCombatTreeStatus(ActorAIStatus.Attack);
            }
            var eventData = actor.eventMgr.GetEvent<EventActorBase>();
            eventData.Init(actor);
            actor.eventMgr.Dispatch(EventType.MonsterActive, eventData);
        }

        public void DisableAI(bool disabled, AISwitchType switchType)
        {
            _combatAI?.Disable(disabled, switchType);
        }
        
        public void PauseAI(bool paused)
        {
            _combatAI?.Pause(paused);
        }

        public void SetIsStrategy(bool isStrategy)
        {
            _isStrategy = isStrategy;
             battle.battleStrategy.UpdateStrategy(actor);
        }

        public bool ActionGoalsIsEmpty()
        {
            if (_combatAI == null)
            {
                return true;
            }
            return !_combatAI.hasWaitAction;
        }

        public bool ActionGoalIsExecuting()
        {
            return _combatAI != null && _combatAI.hasExecutingAction;
        }

        public void ClearCombatAIGoal()
        {
            _combatAI?.ClearAllActions();
        }

        public void DisableAll(bool disabled)
        {
            DisableAI(disabled, AISwitchType.Revive);
        }

        public void ChangeStrategyControl(bool beControl)
        {
            _beStrategyControl = beControl;
            if (beControl)
            {
                SetGlobalCD(0f, false);
            }
        }
    }
}
