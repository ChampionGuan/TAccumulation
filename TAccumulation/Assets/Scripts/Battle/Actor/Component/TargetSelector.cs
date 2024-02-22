using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using X3Battle.TargetSelect;

namespace X3Battle
{
    public class TargetSelector : ActorComponent
    {
        private SelectModeBase _curMode;
        private Dictionary<TargetLockModeType, SelectModeBase> _type2ModeDict;

        private Action<EventActorAIDisabled> _actionActorAIDisabled;
        private Action<EventChangeLevelState> _actionChangeLevelState;

        public TargetSelector() : base(ActorComponentType.TargetSelector)
        {
            _actionActorAIDisabled = _OnEventActorAIDisabled;
            _actionChangeLevelState = _OnLevelChange;
        }

        protected override void OnAwake()
        {
            _type2ModeDict = new Dictionary<TargetLockModeType, SelectModeBase>();
            _type2ModeDict.Add(TargetLockModeType.AI, new AISelectMode(this));
            _type2ModeDict.Add(TargetLockModeType.Smart, new SmartSelectMode(this));
            _type2ModeDict.Add(TargetLockModeType.Manual, new ManualSelectMode(this));
            _type2ModeDict.Add(TargetLockModeType.Boss, new BossSelectMode(this));
        }

        protected override void OnDestroy()
        {
            this._curMode?.Destroy();
            this._curMode = null;
        }

        public override void OnBorn()
        {
            actor.eventMgr.AddListener<EventActorAIDisabled>(EventType.ActorAIDisabled, _actionActorAIDisabled, "TargetSelector._OnEventActorAIDisabled");
            actor.battle.eventMgr.AddListener<EventChangeLevelState>(EventType.ChangeLevelState, _actionChangeLevelState, "TargetSelector._OnLevelChange");
            if (this.actor.IsPlayer())
            {
                // 智能索敌开启，主控默认用Smart模式
                this.SwitchMode(battle.setting.lockModeType);
            }
            else
            {
                this.SwitchMode(TargetLockModeType.AI);
            }
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            this._curMode?.Update();
        }

        public override void OnRecycle()
        {
            actor.battle.eventMgr.RemoveListener<EventChangeLevelState>(EventType.ChangeLevelState, _actionChangeLevelState);
            actor.eventMgr.RemoveListener<EventActorAIDisabled>(EventType.ActorAIDisabled, _actionActorAIDisabled);
            this._curMode?.Stop();
            this._curMode = null;
        }

        // 只有自己才修改
        private void _OnEventActorAIDisabled(EventActorAIDisabled arg)
        {
            if (arg.actor != actor)
            {
                return;
            }

            if (arg.disabled)
            {
                SwitchMode(battle.setting.lockModeType);
            }
            else
            {
                SwitchMode(TargetLockModeType.AI);
            }
        }

        ////------------------------------------------ 对外接口--------------------------------------------
        // 获取目标
        //-@return Actor
        public Actor GetTarget()
        {
            // if (actor.isDead)
            // {
            //     LogProxy.LogErrorFormat("外部模块调用错误，人已经死了还在调用他的锁定目标！");
            // }
            var target = this._curMode?.GetTarget();
            return target;
        }

        //-@return TargetLockModeType
        public TargetLockModeType? GetModeType()
        {
            if (this._curMode != null)
            {
                return this._curMode.modeType;
            }

            return null;
        }

        // 切换索敌模式
        //-@param targetSelectMode TargetLockModeType
        public void SwitchMode(TargetLockModeType targetSelectMode)
        {
            // 目前只有主控才能切模式，其余角色只能使用普通模式
            if (!actor.IsPlayer() && targetSelectMode != TargetLockModeType.AI)
            {
                PapeGames.X3.LogProxy.LogWarning("目前只有女主才能切模式，其余角色只能使用普通模式");
                return;
            }

            var preSelectMode = this._curMode?.modeType ?? TargetLockModeType.None;
            // 停止当前模式
            if (this._curMode != null)
            {
                if (this._curMode.modeType == targetSelectMode)
                {
                    return; // 模式相同直接跳出           
                }

                else
                {
                    this._curMode.Stop();
                    this._curMode = null;
                }
            }

            // 开启新模式
            var newMode = _type2ModeDict[targetSelectMode];
            this._curMode = newMode;
            this._curMode.Start();

            var eventData = battle.eventMgr.GetEvent<EventChangeLockTargetMode>();
            eventData.Init(this.actor, preSelectMode,targetSelectMode);
            this.battle.eventMgr.Dispatch(EventType.ChangeLockTargetMode, eventData);
        }

        private void _OnLevelChange(EventChangeLevelState arg)
        {
            if (arg.curLevelBattleState == LevelBattleState.None)
            {
                SwitchMode(battle.setting.lockModeType);
            }
            else if (arg.curLevelBattleState == LevelBattleState.Normal)
            {
                if (this._curMode.modeType == TargetLockModeType.Boss)
                {
                    SwitchMode(battle.setting.lockModeType); 
                }
            }
            else if (arg.curLevelBattleState == LevelBattleState.Boss)
            {
                var girlAIEnable = actor.IsGirl() && actor.aiOwner.enabled;
                if (!girlAIEnable)
                {
                    // girl并且AI开启，不进入boss模式
                    SwitchMode(TargetLockModeType.Boss);
                }
            }
        }
        
        //-@param type TargetSelectorUpdateType
        //-@param data any
        public void TryUpdateTarget(TargetSelectorUpdateType type, object data)
        {
            if (this._curMode != null)
            {
                this._curMode.TryUpdateTarget(type, data);
            }
        }
    }
}
