using UnityEngine;

namespace X3Battle
{
    public class SkillSlot
    {
        private SkillSlotConfig _config;
        public SkillSlotConfig config => _config;
        public ISkill skill;
        public int configID => _config.ID;
        
        // 能量消耗类型与能量消耗值 (Lua层会用，需要publicGet)
        public SlotEnergyCoster energyCoster1 { get; private set; }
        public SlotEnergyCoster energyCoster2 { get; private set; }
        public SlotEnergyCoster energyCoster3 { get; private set; }

        public int maxCastCount { get; set; }
        public int castCount { get; set; }

        private float _remainCD;

        public float remainCD
        {
            get => _remainCD;
            private set
            {
                if (_remainCD <=0 && value > 0)
                {
                    // 进入CD
                    skill.EnterCD();
                }
                else if (_remainCD > 0 && value <= 0)
                {
                    // CD结束
                    skill.ExitCD();
                }
                
                _remainCD = value;
            }
        }

        private float cdAddPercent;
        private float cdAddAdditional;
        private float cdMax;
        private float startCdMax;//开始CD随机上限
        private int cdGroupID;         
        private SkillSlotType _slotType;
        public SkillSlotType slotType => _slotType;

        private int _slotIndex;

        public int _ID;
        public int ID => _ID;

        public SkillSlot(SkillSlotConfig _config, ISkill _skill, int slotID)
        {
            this._config = _config;
            skill = _skill;
            _ID = slotID;
            _slotType = BattleUtil.GetSlotTypeAndIndex(_config.ID, out _slotIndex);
            maxCastCount = skill.GetCastCount();
            castCount = maxCastCount;
            // CD百分比加成
            cdAddPercent = 0;
            // CD数值加成
            cdAddAdditional = 0;
            cdMax = skill.GetCDMaxLimit();
            startCdMax = skill.GetStartMaxCDLimit();
            cdGroupID = skill.GetGroupID();
            
            var levelCfg = _skill.levelConfig;
            energyCoster1 = new SlotEnergyCoster(_skill, levelCfg.AttrCost1, levelCfg.LowAttrCanSkill1, levelCfg.AttrCanZero1);
            energyCoster2 = new SlotEnergyCoster(_skill, levelCfg.AttrCost2, levelCfg.LowAttrCanSkill2, levelCfg.AttrCanZero2);
            energyCoster3 = new SlotEnergyCoster(_skill, levelCfg.AttrCost3, levelCfg.LowAttrCanSkill3, levelCfg.AttrCanZero3);
        }

        // 释放技能时开始CD
        public void StartCastCD()
        {
            var targetSkill = skill;
            //是否由动作模组控制CD
            var isActiveControlCD = false;
            if (targetSkill is SkillActive activeSkill)
            {
                isActiveControlCD = activeSkill.IsActiveControlCD();
            }
            
            if (!isActiveControlCD)
            {
                // 开启CD和连击CD
                if (castCount <= 0 || castCount == maxCastCount)
                {
                    SetRandomCD();
                }
                //开启公共CD
                StartPublicGroupCD();
            }    
        }
        
        // 激活公共CD组
        public void StartPublicGroupCD()
        {

            var publicCDValue = GetPublicCD();
            if (publicCDValue <= 0)
                return;
            
            var groupID = GetSkillGroupID();
            
            foreach (var iter in skill.actor.skillOwner.slots)
            {
                var slot = iter.Value;

                if (slot == null)
                    continue;
                
                //不算自己
                if(slot == this)
                    continue;

                if (slot.GetSkillGroupID() != groupID)
                    continue;

                slot.SetPublicCD(publicCDValue);
            }
        }

        public void Update(float deltaTime)
        {
            UpdateCD(deltaTime);
        }

        public void UpdateCD(float deltaTime)
        {
            if (GetRemainCD() > 0 || (GetRemainCD() == 0 && HasMultiSegmentSkill()))
            {
                SetRemainCD(GetRemainCD() - deltaTime);
                if (GetRemainCD() <= 0)
                {
                    AddCastCount();
                    if (castCount < maxCastCount)
                    {
                        SetRemainCD(CalcRemainCD(skill.GetCD()));
                    }
                }
            }
        }
        
        /// <summary>
        /// 随机设置初始CD
        /// </summary>
        public void SetStartCD()
        {
            // 先设置StartCD
            remainCD = skill.GetStartCD();
            // 然后再设置startCDMax
            if (startCdMax > remainCD)
            {
                float tempRemainCD = UnityEngine.Random.Range(remainCD, startCdMax);
                tempRemainCD *= BattleUtil.GetAggressiveCDR(skill.config.IsStageStrategy);
                remainCD = tempRemainCD;
            }
        }
        
        /// <summary>
        /// 设置公共CD 
        /// </summary>
        public void SetPublicCD(float publicCD)
        {
            //如果技能当前CD小于设置的公共CD
            if (remainCD < publicCD)
            {
                remainCD = publicCD;
            }
        }
        
        public float GetMaxCD()
        {
            return skill.GetCD();
        }

        /// <summary>
        ///  AI 进入战斗时会调用过来
        /// </summary>
        public void StartAICD()
        {
            var minCD = skill.config.AIBattleCD;
            var maxCD = skill.config.AIBattleCDMax;
            var targetCD = minCD;
            
            if (minCD < maxCD)
            {
                // 配置兼容，最大值大于最小值才生效随机
                targetCD = Random.Range(minCD, maxCD);
            }
            targetCD *= BattleUtil.GetAggressiveCDR(skill.config.IsStageStrategy);
            if (remainCD < targetCD)
            {
                remainCD = targetCD;
            }
        }

        /// <summary>
        /// 降低CD
        /// </summary>
        /// <param name="value"></param>
        public void ReduceRemainCD(float value)
        {
            if (value < 0f)
            {
                PapeGames.X3.LogProxy.LogError("请联系程序, 降低CD不允许负值参数.");
                return;
            }
            remainCD -= value;
            remainCD = remainCD >= 0f ? remainCD : 0f;
        }
        
        public void SetRemainCD(float value)
        {
            remainCD = value;
        }

        public float GetRemainCD()
        {
            return remainCD;
        }

        // 通过debugEditor直接设置属性, 目前只有编辑器用
        public void SetEnergyFull()
        {
            energyCoster1.SetEnergyFull();
            energyCoster2.SetEnergyFull();
            energyCoster3.SetEnergyFull();
        }

        /// <summary>
        /// 该技能能量是否满足
        /// </summary>
        public bool IsEnergyFull()
        {
            return energyCoster1.IsEnergyFull() && energyCoster2.IsEnergyFull() && energyCoster3.IsEnergyFull();
        }
        
        // 是否消耗能量
        public bool HaveCastEnergy()
        {
            return energyCoster1.HaveCastEnergy() || energyCoster2.HaveCastEnergy() || energyCoster3.HaveCastEnergy(); 
        }

        // 释放技能时尝试消耗能量
        public void TryCostEnergy()
        {
            energyCoster1.TryCostEnergy();
            energyCoster2.TryCostEnergy();
            energyCoster3.TryCostEnergy();
        }

        public bool IsCD()
        {
            return remainCD > 0;
        }

        /// <summary>
        /// 是否有多段技能
        /// </summary>
        /// <returns></returns>
        public bool HasMultiSegmentSkill()
        {
            return maxCastCount > 0; 
        }

        /// <summary>
        /// 是否剩余技能次数处于最大值.
        /// </summary>
        /// <returns></returns>
        public bool IsFullCastCount()
        {
            return castCount >= maxCastCount;
        }

        /// <summary>
        /// 获取能使用的段数
        /// </summary>
        /// <returns></returns>
        public int GetCanCastCount()
        {
            return castCount;
        }

        public void AddCastCount(int times = 1)
        {
            if (times <= 0)
                return;
            int addTimes = System.Math.Min(times, maxCastCount - castCount);
            if (addTimes <= 0)
            {
                return;
            }
            
            if (castCount + addTimes <= maxCastCount)
            {
                castCount += addTimes;
            }
        }

        public void SubCastCount()
        {
            if (castCount > 0)
            {
                castCount--;
            }
        }

        public Actor GetActor()
        {
            return skill.actor;
        }

        public int GetActorID()
        {
            return skill.actor.insID;
        }

        public void ChangeCDAdd(float percent, float additional)
        {
            cdAddPercent += percent;
            cdAddAdditional += additional;
        }
        
        /// <summary>
        /// 增加随机CD的处理
        /// 释放技能CD时，CD 在result - cdlimit中随机选一个
        /// </summary>
        /// <param name="baseCD"></param>
        /// <returns></returns>
        public float RandomCastCD(float baseCD)
        {
            if (cdMax > baseCD)
            {
                baseCD = UnityEngine.Random.Range(baseCD, cdMax);
            }

            return baseCD;
        }
        
        public float CalcRemainCD(float baseCD)
        {
            var result = baseCD * (cdAddPercent + 1) + cdAddAdditional;
            
            // 加入属性CD衰减
            var attributeOwner = skill.actor.attributeOwner;
            if (attributeOwner != null)
            {
                var ratio = attributeOwner.GetPerthAttrValue(AttrType.CDDec);
                result *= (1.0f - ratio);
            }
            
            if (result < 0)
            {
                result = 0;
            }
            result *= BattleUtil.GetAggressiveCDR(skill.config.IsStageStrategy);
            return result;
        }
        
        /// <summary>
        /// 获取随机公共CD
        /// </summary>
        /// <returns></returns>
        public float GetPublicCD()
        {
            if (!TbUtil.TryGetCfg(cdGroupID, out SkillPublicCdCfg curSkillPublicCdCfg))
                return -1;
            
            var publicCD = curSkillPublicCdCfg.PublicCD / 1000f;
            var maxPublicCD = curSkillPublicCdCfg.PublicCDMax / 1000f;
            if (maxPublicCD > publicCD)
            {
                publicCD = UnityEngine.Random.Range(publicCD, maxPublicCD);
            }
            publicCD *= BattleUtil.GetAggressiveCDR(skill.config.IsStageStrategy);
            return publicCD;
        }

        /// <summary>
        /// 获取公共CD组ID
        /// </summary>
        /// <returns></returns>
        public int GetSkillGroupID()
        {
            return cdGroupID;
        }

        /// <summary>
        /// 设置CD 这里会增加随机CD
        /// </summary>
        public void SetRandomCD()
        {
            //这里增加使用随机CD的设定
            remainCD = RandomCastCD(skill.GetCD());
                
            // 注意level表里的cd会覆盖skill，cd不对先检查level表
            remainCD = CalcRemainCD(remainCD);
        }

        public void AddCostEnergyValue(AttrType energyType, float value)
        {
            if (energyType == energyCoster1.energyType)
            {
                energyCoster1.AddCostEnergyValue(value);
            }

            if (energyType == energyCoster2.energyType)
            {
                energyCoster2.AddCostEnergyValue(value);
            }

            if (energyType == energyCoster3.energyType)
            {
                energyCoster3.AddCostEnergyValue(value);
            }
        }

        public void SetCostEnergyValue(AttrType energyType, float value)
        {
            if (energyType == energyCoster1.energyType)
            {
                energyCoster1.SetCostEnergyValue(value);
            }

            if (energyType == energyCoster2.energyType)
            {
                energyCoster2.SetCostEnergyValue(value);
            }

            if (energyType == energyCoster3.energyType)
            {
                energyCoster3.SetCostEnergyValue(value);
            }
        }
    }
}