using System;
using MessagePack;
using PapeGames.X3;

namespace X3Battle
{
    [BuffAction("技能释放无消耗")]
    [MessagePackObject]
    [Serializable]
    public class SkillNoConsumption:BuffActionBase
    {
        [BuffLable("技能类型")]
        [Key(0)]
        public SkillType skillType;
        [BuffLable("不消耗何种属性")]
        [Key(1)]
        public AttrType attrType;
        [BuffLable("技能id")]
        [Key(2)]
        public int skillID = 0;
        [Key(3)]
        [BuffLable("是否使用技能id")]
        public bool useSkillID = false;
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.SkillNoConsumption;
        }
        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            PapeGames.X3.LogProxy.Log($"buff action SkillNoConsumption AddNoConsumption {skillType},{attrType},{skillID},{useSkillID}");
            if (useSkillID)
            {
                _actor.skillOwner.energyController.AddNoConsumption(this, skillID, attrType);
            }
            else
            {
                _actor.skillOwner.energyController.AddNoConsumption(this, skillType, attrType);
            }
        }

        public override void OnDestroy()
        {
            if (useSkillID)
            {
                _actor.skillOwner.energyController.RemoveNoConsumption(this, skillID, attrType);
            }
            else
            {
                _actor.skillOwner.energyController.RemoveNoConsumption(this, skillType, attrType);
            }
            PapeGames.X3.LogProxy.Log($"buff action SkillNoConsumption RemoveNoConsumption {skillType} {attrType}");
            ObjectPoolUtility.BuffActionSkillNoConsumptionPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionSkillNoConsumptionPool.Get();
            action.skillType = skillType;
            action.attrType = attrType;
            action.useSkillID = useSkillID;
            action.skillID = skillID;
            return action;
        }
    }
}