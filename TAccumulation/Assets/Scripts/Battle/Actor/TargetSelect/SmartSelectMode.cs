using System;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle.TargetSelect
{
    public class SmartSelectMode : SelectModeBase
    {
        private int? _curSkillId;
        private float _leftTime;
        private bool _isLockTime;
            
        // 常规选点逻辑  切换目标成功CD开始计时
        // 常规选点逻辑 当前目标死亡 CD清零
        // 常规选点逻辑 CD过程中 切换目标不成功
        private float _smartStrategyCD;

        private Action<EventActorEnterStateBase> _actionActorEnterDeadState;
        private Action<EventCameraCancelLock> _actionOnCameraCancelLock;
        private Action<EventStateTagChangeBase> _actionOnActorStateTagChange;

        public SmartSelectMode(TargetSelector targetSelector) : base(targetSelector, TargetLockModeType.Smart)
        {
            _actionActorEnterDeadState = _OnActorEnterDeadState;
            _actionOnCameraCancelLock = _OnCameraCancelLock;
            _actionOnActorStateTagChange = _OnActorStateTagChange;
        }

        protected override void _OnInit()
        {
            this._Clear();
        }

        private void _Clear()
        {
            // 当前主动技能
            // type Int
            this._curSkillId = null;
            this._leftTime = 0;
            this._isLockTime = true; // 是否锁定时间
            this._target = null;
        }

        protected override void _OnStart()
        {
            var battle = this._actor.battle;
            battle.eventMgr.AddListener(EventType.OnActorEnterDeadState, _actionActorEnterDeadState, "SmartSelectMode._OnActorEnterDeadState");
            battle.eventMgr.AddListener(EventType.CameraCancelLock, _actionOnCameraCancelLock, "SmartSelectMode._OnCameraCancelLock");
            battle.eventMgr.AddListener(EventType.LockIgnoreStateTagChange, _actionOnActorStateTagChange, "SmartSelectMode._OnActorStateTagChange");
        }

        protected override void _OnStop()
        {
            var battle = this._actor.battle;
            battle.eventMgr.RemoveListener(EventType.OnActorEnterDeadState, _actionActorEnterDeadState);
            battle.eventMgr.RemoveListener(EventType.CameraCancelLock, _actionOnCameraCancelLock);
            battle.eventMgr.RemoveListener(EventType.LockIgnoreStateTagChange, _actionOnActorStateTagChange);
            this._Clear();
        }
        
        // 目标锁定免疫生效，实时脱锁
        private void _OnActorStateTagChange(EventStateTagChangeBase data)
        {
            if (data.actor == _target && data.active)
            {
                var name1 = _actor.name;
                var name2 = _target.name;
                LogProxy.LogFormat("【目标】：{0} 智能锁定模式，锁定目标 {1}, 进入不可锁定状态！", name1, name2);
                _SetTargetWithEvent(null);
            }
        }
        
        private void _OnCameraCancelLock(EventCameraCancelLock arg)
        {
            var name1 = _actor.name;
            LogProxy.LogFormat("【目标】：{0} 智能锁定模式，因为相机拖动而脱锁！", name1);
            _SetTargetWithEvent(null);
        }
        
        public void _OnActorEnterDeadState(EventActorEnterStateBase arg)
        {
            if (arg.actor == this._target)
            {
                var name1 = _actor.name;
                var name2 = _target.name;
                _smartStrategyCD = 0;  // 锁定目标死亡时，计时器清空
                LogProxy.LogFormat("【目标】：{0} 智能锁定模式，锁定目标 {1}, 死亡！", name1, name2);
                this._SetTargetWithEvent(null);
                _Clear();
            }
        }

        protected override void _OnUpdate()
        {
            if (_smartStrategyCD > 0)
            {
                _smartStrategyCD -= _actor.deltaTime;
                if (_smartStrategyCD < 0)
                {
                    _smartStrategyCD = 0;
                }
            }
            
            if (this._target != null)
            {
                if (!this._isLockTime)
                {
                    this._leftTime = this._leftTime - this._actor.deltaTime;
                    if (this._leftTime < 0)
                    {
                        _smartStrategyCD = 0;
                        var name1 = _actor.name;
                        LogProxy.LogFormat("【目标】：{0} 智能锁定模式，锁定时间已到，脱锁！", name1);
                        this._SetTargetWithEvent(null);
                        this._Clear();
                        return;
                    }
                }
            }
        }

        // param type TargetSelectorUpdateType
        // param data any
        protected override void _OnTryUpdateTarget(TargetSelectorUpdateType type, object data)
        {
            if (type == TargetSelectorUpdateType.SkillSelectTarget)
            {
                this._OnSkillUpdateTarget(data as SkillSelectData);
            }
            else if (type == TargetSelectorUpdateType.SkillEnd)
            {
                this._OnSkilEnd(data as SkillSelectData);
            }
        }

        // 技能更新目标
        // param data SkillSelectData
        private void _OnSkillUpdateTarget(SkillSelectData data)
        {
            var targetSelectType = data.targetSelectType;
            if (targetSelectType != TargetSelectType.Lock)
            {
                PapeGames.X3.LogProxy.LogWarningFormat("智能锁定模式不支持TargetSelectType.Nearest之外的模式：{0}", targetSelectType);
                return;
            }

            var lockChangeType = data.lockChangeType;
            if (lockChangeType == SkillLockChangeType.Update)
            {
                this._OnSkillUpdateLock(data.skillId);
            }
            else if (lockChangeType == SkillLockChangeType.Clear)
            {
                var name1 = _actor.name;
                LogProxy.LogFormat("【目标】：{0} 智能锁定模式，因技能配置尝试脱锁！", name1);
                this._SetTargetWithEvent(null);
                this._Clear();
            }
        }

        // 技能更新目标和时间
        public void _OnSkillUpdateLock(int skillID)
        {
            this._curSkillId = skillID;
            var slotType = _targetSelector.actor.skillOwner.GetTypeBySkillID(skillID);
            var curTarget = _targetSelector.actor.GetTarget();
            Actor selectTarget = null;
            Actor target = null;
            bool isTargetFromSmart = false;
            bool isUseCoreSelect = false;
            var slotID = _targetSelector.actor.skillOwner.GetSlotIDBySkillID(skillID);
            if (slotID != null)
            {
                var slotSkill = _targetSelector.actor.skillOwner.GetSkillBySlot(slotID.Value);
                if (slotSkill != null)
                {
                    isUseCoreSelect = slotSkill.config.IsUseCoreSelect;
                }
            }

            if (isUseCoreSelect)
            {
                //LogProxy.LogFormat("【目标】 索敌规则 skillid = {0} {1}", skillID, " 使用破核选地逻辑");
                target = TargetSelectUtil.CoopSkillSelect(_targetSelector, _smartStrategyCD == 0, out var isFromSmart);
                isTargetFromSmart = isFromSmart;
            }
            else
            {
                //LogProxy.LogFormat("【目标】 索敌规则 skillid = {0} {1}", skillID, " 不使用破核选地逻辑");
                target = TargetSelectUtil.CommonSkillSelect(_targetSelector, _smartStrategyCD == 0, out var isFromSmart);
                isTargetFromSmart = isFromSmart;
            }

            // 成功切换了目标，并且新目标来源是老的智能选点模式，则设置一下CD
            if (curTarget != target && isTargetFromSmart)
            {
                _smartStrategyCD = TbUtil.battleConsts.SmartStrategyChangeTargetCD;
            }
            
            var name1 = _actor.name;
            var name2 = target == null ? "null" : target.name;
            LogProxy.LogFormat("【目标】：{0} 智能锁定模式，放技能更新目标：{1}", name1, name2);
            this._isLockTime = true;
            this._SetTargetWithEvent(target);
        }


        
        // 技能结束
        // param data SkillSelectData
        public void _OnSkilEnd(SkillSelectData data)
        {
            if (this._curSkillId != data.skillId)
            {
                return; // 不是走SkillUpdateTarget影响到锁定的技能不处理
            }

            var lockChangeType = data.lockChangeType;
            if (lockChangeType == SkillLockChangeType.Update)
            {
                this._isLockTime = false;
                this._leftTime = TbUtil.battleConsts.LockTime;
            }
        }
    }
}