using System;
using System.Collections.Generic;
using MessagePack;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("技能增伤")]
    [MessagePackObject]
    [Serializable]
    public class BuffModifySkillDamage : BuffActionBase
    {
        [BuffLable("技能类型")] [Key(0)] public SkillTypeFlag skillTypeFlag;

        [BuffLable("生效次数 (满了移除buff)")] [Key(1)] public float runTimes = 1;

        [BuffLable("增伤参数")] [Key(2)] public MathParamType paramType;

        [IgnoreMember] [NonSerialized] private Action<EventCastSkill> _actionCastSkill;

        [IgnoreMember] [NonSerialized] private int _curRunTimes; // 已生效次数
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.ModifySkillDamage;
            _actionCastSkill = _OnCastSkill;
        }

        public override void OnAdd(int layer)
        {
            _curRunTimes = 0;
            _actor.battle.eventMgr.AddListener(EventType.CastSkill, _actionCastSkill, "BuffModifySkillDamage._OnCastSkill");
        }

        public override void OnReset()
        {
            _curRunTimes = 0;
        }

        public override void OnDestroy()
        {
            _actor.battle.eventMgr.RemoveListener(EventType.CastSkill, _actionCastSkill);
            ObjectPoolUtility.BuffModifySkillDamagePool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffModifySkillDamagePool.Get();
            action.skillTypeFlag = skillTypeFlag;
            action.runTimes = runTimes;
            action.paramType = paramType;
            return action;
        }

        private void _OnCastSkill(EventCastSkill arg)
        {
            var skill = arg.skill;
            if (_CheckTimesValid() && _CheckArgValid(skill))
            {
                // 读buff表获取modifyvalue
                var modifyValue = 0f;
                var buffLevelConfig = TbUtil.GetBuffLevelConfig(_owner);
                if (buffLevelConfig != null)
                {
                    float[] results = BattleUtil.GetBuffMathParam(buffLevelConfig, paramType);
                    if (results != null && results.Length > 0)
                    {
                        modifyValue = results[0];
                    }
                }
                skill.SetFinalDamageAddAttr(skill.finalDamageAddAttr + modifyValue);
                _curRunTimes += 1;
                if (!_CheckTimesValid())
                {
                    _owner.Destroy();
                }
            }
        }

        // 检测技能释放者是自己，并且技能类型满足要求
        private bool _CheckArgValid(ISkill skill)
        {
            if (skill.actor != null && skill.actor == _actor && BattleUtil.ContainSkillType(skillTypeFlag, skill.config.Type))
            {
                return true;
            }
            return false;
        }

        // 检测生效次数是否有剩余
        private bool _CheckTimesValid()
        {
            if (runTimes <= 0)
            {
                return true;
            }
            return _curRunTimes < runTimes;
        }
        
    }
}