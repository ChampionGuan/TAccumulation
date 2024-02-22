namespace X3Battle
{
    public class SlotEnergyCoster
    {
        public AttrType energyType { get; private set; } // 能量类型
        public int energyRatio { get; private set; }// 能量值千分比值
        public float energyValue { get; private set; } // 能量值
        public AttrChoseTarget choseTarget { get; private set; } // 目标类型
        public AttrType targetEnergyType { get; private set; } // 目标的能量类型
        
        private Actor _actor;  // 能量消耗actor
        private bool _lowAttrCanSkill;  // 能量不足是否能释放技能
        private bool _attrCanZero;  // 扣除属性是否可以为0
        private SkillType _skillType;  // 技能类型
        private int _skillID;  // 技能ID
        private float _defaultEnergyValue; // 默认配置的能量值.
        private int _defaultEnergyRatio; // 默认配置的能量值千分比值

        public SlotEnergyCoster(ISkill skill, float[] attrCost, bool lowAttrCanSkill, bool attrCanZero)
        {
            _actor = skill.actor;
            _skillType = skill.config.Type;
            _skillID = skill.config.ID;
            _lowAttrCanSkill = lowAttrCanSkill;
            _attrCanZero = attrCanZero;

            energyType = AttrType.None;
            energyValue = 0;
            choseTarget = AttrChoseTarget.Self;
            targetEnergyType = AttrType.None;
            
            if (attrCost != null && attrCost.Length >= 3)
            {
                energyType = (AttrType) (int) attrCost[0];
                energyRatio = (int)attrCost[1]; // 数值表里填的是千分比
                energyValue = attrCost[2];
                if (attrCost.Length >= 5)
                {
                    choseTarget = (AttrChoseTarget) (int) attrCost[3];
                    targetEnergyType = (AttrType) (int) attrCost[4];
                }
            }

            _defaultEnergyValue = energyValue;
            _defaultEnergyRatio = energyRatio;
        }
        
        // 是否消耗能量
        public bool HaveCastEnergy()
        {
            var usingEnergyType = _GetRealEnergyType(energyType);
            var usingTargetEnergyType = _GetRealEnergyType(targetEnergyType);
            if (usingEnergyType == AttrType.None && usingTargetEnergyType == AttrType.None)
            {
                return false;
            }
            return true;
        }
        
        // 释放技能时尝试消耗能量
        public void TryCostEnergy()
        {
            if (HaveCastEnergy() && IsEnergyFull())
            {
                var usingEnergyType = _GetRealEnergyType(energyType);
                var usingTargetEnergyType = _GetRealEnergyType(targetEnergyType);
                _actor.battle.ConsumeAttr(_actor,usingEnergyType,energyRatio, energyValue, choseTarget,usingTargetEnergyType,_attrCanZero? 0 : 1);
            }
        }
        
        // 补满能量
        public void SetEnergyFull()
        {
            if (HaveCastEnergy())
            {
                _actor.battle.GatherAttr(_actor, energyType, energyRatio, energyValue, choseTarget, targetEnergyType);
            }  
        }
        
        /// <summary>
        /// 该技能能量是否满足
        /// </summary>
        public bool IsEnergyFull()
        {
            if (HaveCastEnergy())
            {
                var usingEnergyType = _GetRealEnergyType(energyType);
                var usingTargetEnergyType = _GetRealEnergyType(targetEnergyType);
                var result = _lowAttrCanSkill || _actor.battle.QueryConsumeAttr(_actor,usingEnergyType, energyRatio, energyValue, choseTarget,usingTargetEnergyType);
                return result;
            }
            return true;
        }

        /// <summary>
        /// 添加能量值
        /// </summary>
        /// <param name="value"> 添加多少值 </param>
        public void AddCostEnergyValue(float value)
        {
            this.energyValue += value;
            var eventData = Battle.Instance.eventMgr.GetEvent<ECEventDataBase>();
            Battle.Instance.eventMgr.Dispatch(EventType.EnergyCostChange, eventData);
        }

        /// <summary>
        /// 设置能量值
        /// </summary>
        /// <param name="value"> 设置多少值 </param>
        public void SetCostEnergyValue(float value)
        {
            this.energyValue = value;
            var eventData = Battle.Instance.eventMgr.GetEvent<ECEventDataBase>();
            Battle.Instance.eventMgr.Dispatch(EventType.EnergyCostChange, eventData);
        }

        /// <summary>
        /// 将能量值重置回默认值
        /// </summary>
        public void ResetEnergyValue()
        {
            this.energyValue = _defaultEnergyValue;
            var eventData = Battle.Instance.eventMgr.GetEvent<ECEventDataBase>();
            Battle.Instance.eventMgr.Dispatch(EventType.EnergyCostChange, eventData);
        }

        private AttrType _GetRealEnergyType(AttrType originalType)
        {
            if (originalType == AttrType.None)
            {
                return AttrType.None;
            }
            
            // 判断这个技能类型是否不消耗此种属性
            var energyController = _actor.skillOwner.energyController;
            var noConsumption = energyController.HasNoConsumptionInfo(_skillType, originalType) || energyController.HasNoConsumptionInfo(_skillID, originalType);
            if (noConsumption)
            {
                return AttrType.None;
            }
            
            return originalType;
        }
    }
}