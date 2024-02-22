using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    public enum AICastSkillMode
    {
        None = 0,
        ByFaceDirection = 1,
        ByTargetDirection = 2,
    }

    [Serializable]
    public class AICastSkillActionParams : AIActionParams<AICastSkillActionParams>
    {
        [ParadoxNotion.Design.Header("节点常用参数")]
        public BBParameter<Actor> skillTarget = new BBParameter<Actor>();

        public BBParameter<SkillSlotType> skillType = SkillSlotType.SkillID;
        public BBParameter<int> skillIndex = 0;

        [ParadoxNotion.Design.Header("节点特殊参数")]
        [SliderField(0, 100)]
        [Tooltip("技能提前结束的概率")]
        public int endInBackSwingProbability = 100;

        [Tooltip("技能正常结束的CD")]
        public float endInBackSwingCD = 0f;

        [Tooltip("技能方向的朝向类型，None为不传入技能方向，Face为自身朝向，Target为自身目标连线方向")]
        public AICastSkillMode castMode = AICastSkillMode.None;

        [Tooltip("技能方向，朝向类型为None时不生效")]
        public Vector3 direction;

        [Tooltip("行为在行为队列中执行前的条件需要满足目标不能处于【死亡或不可锁定】, 并且行为过程中【目标死亡或不可锁定】时会异常结束")]
        public bool targetMustBeLegal = true;

        public override void CopyFrom(AICastSkillActionParams @params)
        {
            skillTarget.value = @params.skillTarget.value;
            skillType.value = @params.skillType.value;
            skillIndex.value = @params.skillIndex.value;
            endInBackSwingProbability = @params.endInBackSwingProbability;
            endInBackSwingCD = @params.endInBackSwingCD;
            castMode = @params.castMode;
            direction = @params.direction;
            targetMustBeLegal = @params.targetMustBeLegal;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            skillTarget.value = null;
            skillType.value = SkillSlotType.SkillID;
            skillIndex.value = 0;
            endInBackSwingProbability = 100;
            endInBackSwingCD = 0f;
            castMode = AICastSkillMode.None;
            direction = Vector3.zero;
            targetMustBeLegal = true;
            base.Reset();
        }

        public override string ToString()
        {
            return $"{base.ToString()},skillIndex={skillIndex.value}";
        }
    }

    /// <summary>
    /// 释放技能行为
    /// 具体见文档：depot/x3/策划文档/战斗/5.系统设计/2.AI规则/AI行为节点整理.xlsx
    /// </summary>
    public class AICastSkillActionGoal : AIActionGoal<AICastSkillActionParams>
    {
        private int _slotID;
        private float _aiSkillCD;
        private bool _isStageStrategy;
        private Action<EventEndSkill> _actionOnEndSkill;
        private Action<ECEventDataBase> _actionSkillBackSwing;
        private Action<EventActorEnterStateBase> _actionOnAbnormalStateChange;

        public AICastSkillActionGoal()
        {
            _actionOnEndSkill = _OnEndSkill;
            _actionSkillBackSwing = _OnSkillBackSwing;
            _actionOnAbnormalStateChange = OnAbnormalStateChange;
        }

        protected override void OnInit()
        {
            var slotID = actor.skillOwner.GetSlotID(parameters.skillType.value, parameters.skillIndex.value);
            _slotID = 0;

            SkillSlot skillSlot = null;
            if (slotID != null)
            {
                skillSlot = actor.skillOwner.GetSkillSlot(slotID.Value);
            }
            
            if (null == skillSlot)
            {
                PapeGames.X3.LogProxy.LogErrorFormat($"配置了【角色：{actor.config.Name}不存在的技能skillType：{0}， skillIndex：{1}，请检查行为树的AddCastSkillActionGoal节点，模块策划【楚门】", parameters.skillType.value, parameters.skillIndex.value);
                return;
            }

            _slotID = slotID.Value;
            var iSkill = skillSlot.skill;
            _aiSkillCD = iSkill.config.AISkillCD;
            _isStageStrategy = iSkill.config.IsStageStrategy;
        }

        protected override void OnEnter()
        {
            if (_CastSkill(parameters.castMode))
            {
                actor.battle.eventMgr.AddListener(EventType.EndSkill, _actionOnEndSkill, "AICastSkillActionGoal._OnEndSkill");
                actor.eventMgr.AddListener(EventType.AIBackSwing, _actionSkillBackSwing, "AICastSkillActionGoal._OnSkillBackSwing");
                actor.eventMgr.AddListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange, "AICastSkillActionGoal._OnAbnormalStateChange");
            }
            else
            {
                SetFinish(false);
            }
        }

        protected override void OnExit()
        {
            if (_slotID != 0)
            {
                float globalSkillCD = actor.aiOwner.GetGlobalSkillCD();
                if (_aiSkillCD > 0 && (globalSkillCD < 0 || _aiSkillCD > globalSkillCD))
                {
                    actor.aiOwner.SetGlobalCD(_aiSkillCD, _isStageStrategy);
                }
            }

            actor.battle.eventMgr.RemoveListener(EventType.EndSkill, _actionOnEndSkill);
            actor.eventMgr.RemoveListener(EventType.AIBackSwing, _actionSkillBackSwing);
            actor.eventMgr.RemoveListener(EventType.OnActorEnterAbnormalState, _actionOnAbnormalStateChange);
        }

        protected void OnAbnormalStateChange(EventActorEnterStateBase data)
        {
            //角色进入异常状态，则结束此行为及后续行为
            SetFinish(false, true);
        }

        protected override bool OnVerifyingConditions(AIConditionPhaseType phaseType)
        {
            switch (phaseType)
            {
                case AIConditionPhaseType.Pending:
                    //策划特殊需求：有等待当前行为结束的条件时，不再走后续检测逻辑
                    if (AIGoalUtil.HasWaitCurrActionCondition(this, phaseType)) break;
                    //此技能不可以释放
                    using (ProfilerDefine.AICanCastSkillBySlot1PMarker.Auto())
                    {
                        if (!actor.skillOwner.CanCastSkillBySlot(_slotID))
                        {
                            return false;
                        }
                    }
                    break;
                case AIConditionPhaseType.PreRun:
                    //目标死亡或不可锁定
                    if (parameters.targetMustBeLegal && AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.skillTarget.value)) return false;
                    //此技能不可以释放
                    using (ProfilerDefine.AICanCastSkillBySlot2PMarker.Auto())
                    {
                        if (!actor.skillOwner.CanCastSkillBySlot(_slotID))
                        {
                            return false;
                        }
                    }
                    break;
                case AIConditionPhaseType.Running:
                    break;
            }

            return base.OnVerifyingConditions(phaseType);
        }

        protected void _OnEndSkill(EventEndSkill arg)
        {
            //技能执行结束，则结束此行为
            if (arg.skill.actor != actor) return;
            if (arg.skill.slotID != _slotID) return;

            // 如果是被中断，清空后续行为队列
            if (arg.endType == SkillEndType.Interrupt)
            {
                SetFinish(false, true);
            }
            else
            {
                SetFinish();
            }
        }

        protected void _OnSkillBackSwing(ECEventDataBase arg)
        {
            var aiContext = context as ActorAIContext;
            if (aiContext != null &&
                actor.time - aiContext.endInBackSwingTimeStamp < parameters.endInBackSwingCD)
            {
                SetFinish();
                return;
            }

            //如果进入AI打断后摇阶段，则结束此行为
            if (parameters.endInBackSwingProbability <= Random.Range(0, 100))
            {
                if (aiContext != null)
                {
                    aiContext.endInBackSwingTimeStamp = actor.time;
                }

                return;
            }

            SetFinish();
        }

        protected bool _CastSkill(AICastSkillMode mode)
        {
            var result = false;
            var slotID = _slotID;
            var targetID = parameters.skillTarget.value?.insID ?? 0;
            if (mode == AICastSkillMode.None)
            {
                // 释放技能
                result = _CastSkill(slotID, targetID);
            }
            else
            {
                // 取方向
                var direction = Vector3.zero;
                switch (mode)
                {
                    case AICastSkillMode.ByFaceDirection:
                        direction = actor.transform.rotation * parameters.direction;
                        break;
                    case AICastSkillMode.ByTargetDirection:
                        var target = actor.battle.actorMgr.GetActor(targetID);
                        if (null == target) break;
                        var forward = target.transform.position - actor.transform.position;
                        direction = Quaternion.LookRotation(forward) * parameters.direction;
                        break;
                }

                if (direction == Vector3.zero)
                {
                    // 无方向
                    PapeGames.X3.LogProxy.LogError("配置了相对目标朝向释放技能的行为，但是没有传递有效的目标！");
                    // 释放技能
                    result = _CastSkill(slotID, targetID);
                }
                else
                {
                    // 有方向
                    var beforeCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                    beforeCmd.Init(direction);
                    ExecuteCmd(beforeCmd);

                    // 释放技能
                    result = _CastSkill(slotID, targetID);

                    //重置摇杆输入
                    //技能释放失败也要执行ActorMoveDirCmd指令重置输入方向
                    var afterCmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                    afterCmd.Init(Vector3.zero);
                    ExecuteCmd(afterCmd);
                }
            }

            if (result) return true;
            SetFinish(false);
            return false;
        }

        protected bool _CastSkill(int slotID, int targetID)
        {
            var cmd = ObjectPoolUtility.GetActorCmd<ActorSkillCommand>();
            cmd.Init(slotID, targetID);
            var result = ExecuteCmd(cmd);
            return result && actor.skillOwner?.currentSlot != null 
                          && actor.skillOwner.currentSlot.ID == slotID;
        }

        protected override void OnUpdate(float deltaTime)
        {
            if (parameters.targetMustBeLegal && AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.skillTarget.value))
            {
                SetFinish(false, true);
            }
        }
    }
}