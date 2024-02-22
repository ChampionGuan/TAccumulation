using System;
using System.Collections.Generic;
using System.Linq;
using MessagePack;

namespace X3Battle
{
    [BuffAction("禁用技能")]
    [MessagePackObject]
    [Serializable]
    public class DisableSkill : BuffActionBase
    {
        [BuffLable("禁用技能类型")] [Key(0)] public SkillTypeFlag flag;
        [BuffLable("禁用技能tags")] [Key(1)] public List<int> skillTags;//这是只读的，不允许运行时修改

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.DisableSkill;
        }

        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            PapeGames.X3.LogProxy.Log($"buff action DisableSkill  SkillTypeFlag = {flag}");
            _actor.skillOwner.disableController.AcquireDisableFlag(this, flag);
            _actor.skillOwner.disableController.AcquireDisableFlag(this, skillTags);
        }

        public override void OnDestroy()
        {
            _actor.skillOwner.disableController.RemoveDisableFlag(this, flag);
            _actor.skillOwner.disableController.RemoveDisableFlag(this, skillTags);
            ObjectPoolUtility.BuffActionDisableSkillPool.Release(this);
            
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionDisableSkillPool.Get();
            action.flag = flag;
            //这里可以浅拷贝
            // action.skillTags = skillTags.ToList();
            action.skillTags = skillTags;
            return action;
        }
    }
}