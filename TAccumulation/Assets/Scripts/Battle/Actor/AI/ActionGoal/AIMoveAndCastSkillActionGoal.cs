using System;
using System.Collections.Generic;
using MessagePack;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Serializable]
    public class AIMoveAndCastSkillActionParams : AIActionParams<AIMoveAndCastSkillActionParams>
    {
        [ParadoxNotion.Design.Header("节点常用参数")]
        public BBParameter<Actor> target = new BBParameter<Actor>();

        [Tooltip("移动停止距离")]
        public BBParameter<float> radius = 0;

        [Tooltip("移动最大时间，超时失败")]
        public BBParameter<float> maxMoveTime = 0;
        public BBParameter<AIMoveType> moveType = AIMoveType.Run;
        public BBParameter<SkillSlotType> skillType = SkillSlotType.SkillID;
        public BBParameter<int> skillIndex = 0;


        [ParadoxNotion.Design.Header("节点特殊参数")]
        [Tooltip("技能提前结束的概率")]
        [SliderField(0, 100)]
        public int endInBackSwingProbability = 100;

        [Tooltip("技能正常结束的CD")]
        public float endInBackSwingCD = 0f;

        [Tooltip("技能方向的朝向类型，None为不传入技能方向，Face为自身朝向，Target为自身目标连线方向")]
        public AICastSkillMode castMode = AICastSkillMode.None;

        [Tooltip("技能方向，朝向类型为None时不生效")]
        public Vector3 direction;
        
        [Tooltip("行为在行为队列中执行前的条件需要满足目标不能处于【死亡或不可锁定】, 并且行为过程中【目标死亡或不可锁定】时会异常结束")]
        public bool targetMustBeLegal = true;

        public override void CopyFrom(AIMoveAndCastSkillActionParams @params)
        {
            target.value = @params.target.value;
            radius.value = @params.radius.value;
            maxMoveTime.value = @params.maxMoveTime.value;
            moveType.value = @params.moveType.value;
            skillType.value = @params.skillType.value;
            skillIndex.value = @params.skillIndex.value;
            endInBackSwingProbability = @params.endInBackSwingProbability;
            endInBackSwingCD =  @params.endInBackSwingCD;
            castMode = @params.castMode;
            direction = @params.direction;
            targetMustBeLegal = @params.targetMustBeLegal;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            target.value = null;
            radius.value = 0;
            maxMoveTime.value = 0;
            moveType.value = AIMoveType.Run;
            skillType.value = SkillSlotType.SkillID;
            skillIndex.value = 0;
            endInBackSwingProbability = 100;
            endInBackSwingCD = 0f;
            castMode = AICastSkillMode.None;
            direction = Vector3.zero;
            targetMustBeLegal = true;
            base.Reset();
        }
    }

    /// <summary>
    /// 释放并释放技能行为
    /// 复合行为，由两个行为组成（分别为：AIApproachTargetActionGoal和AICastSkillActionGoal)
    /// 具体见文档：depot/x3/策划文档/战斗/5.系统设计/2.AI规则/AI行为节点整理.xlsx
    /// </summary>
    public class AIMoveAndCastSkillActionGoal : AIActionGoal<AIMoveAndCastSkillActionParams>, IAICompositeAction
    {
        private AIApproachTargetActionParams _approachTargetParams = new AIApproachTargetActionParams();
        private AIWaitCurrActionFinishConditionParams _waitCurrActionParams = new AIWaitCurrActionFinishConditionParams();
        private AICastSkillActionParams _castSkillParams = new AICastSkillActionParams();

        public void GenSubActions(List<IAIActionGoal> outActions)
        {
            if (null == outActions) return;
            outActions.Clear();

            // 移动到目标处行为
            var actionMove = ObjectPoolUtility.GetAIActionGoal<AIApproachTargetActionGoal>();
            _approachTargetParams.holdTime.value = parameters.holdTime.value;
            _approachTargetParams.target.value = parameters.target.value;
            _approachTargetParams.radius.value = parameters.radius.value;
            _approachTargetParams.maxMoveTime.value = parameters.maxMoveTime.value;
            _approachTargetParams.moveType.value = parameters.moveType.value;
            actionMove.SetParameters(_approachTargetParams, null, null, null);
            actionMove.AddConditions(_conditions);
            outActions.Add(actionMove);

            // 释放技能行为
            var actionCastSkill = ObjectPoolUtility.GetAIActionGoal<AICastSkillActionGoal>();
            _castSkillParams.holdTime.value = parameters.maxMoveTime.value; // 使用最大移动时间作为技能行为holdTime
            _castSkillParams.skillTarget.value = parameters.target.value;
            _castSkillParams.skillType.value = parameters.skillType.value;
            _castSkillParams.skillIndex.value = parameters.skillIndex.value;
            _castSkillParams.endInBackSwingProbability = parameters.endInBackSwingProbability;
            _castSkillParams.endInBackSwingCD = parameters.endInBackSwingCD;
            _castSkillParams.castMode = parameters.castMode;
            _castSkillParams.direction = parameters.direction;
            actionCastSkill.SetParameters(_castSkillParams, _subTree.node, _subTree.agent, _subTree.blackboard);

            // 释放技能的行为需要等待移动行为完成
            var conditionWaitCurr = ObjectPoolUtility.GetAIConditionGoal<AIWaitCurrActionFinishConditionGoal>();
            _waitCurrActionParams.source.value = actor;
            _waitCurrActionParams.phaseType = AIConditionPhaseType.Pending;
            conditionWaitCurr.SetParameters(_waitCurrActionParams);
            actionCastSkill.AddCondition(conditionWaitCurr);
            outActions.Add(actionCastSkill);
        }
        
        protected override bool OnVerifyingConditions(AIConditionPhaseType phaseType)
        {
            switch (phaseType)
            {
                case AIConditionPhaseType.Pending:
                    break;
                case AIConditionPhaseType.PreRun:
                    //目标死亡或不可锁定
                    if (parameters.targetMustBeLegal && AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.target.value)) return false;
                    break;
                case AIConditionPhaseType.Running:
                    break;
            }

            return base.OnVerifyingConditions(phaseType);
        }

        protected override void OnUpdate(float deltaTime)
        {
            //目标死亡或不可锁定，则结束此行为
            if (parameters.targetMustBeLegal && AIGoalUtil.ActorIsDeadOrLockIgnore(parameters.target.value))
            {
                SetFinish(false, true);
            }
        }
    }
}
