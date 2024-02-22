using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class EnergyOwner : ActorComponent
    {
        public bool energyRecoverEnable = true;
        private List<AttrType> _energyList = new List<AttrType>();
        private Dictionary<AttrType, int> _forbidRecoverEnergys = new Dictionary<AttrType, int>(new AttrUtil.AttrTypeComparer());

        public EnergyOwner() : base(ActorComponentType.Energy)
        {
        }

        public override void OnBorn()
        {
            if (actor.IsGirl())
            {
                var maleConfig = TbUtil.GetCfg<BoyCfg>(actor.battle.arg.boyID);
                for (int i = 0; i < maleConfig.Energy.Length; i++)
                {
                    AttrType k = (AttrType)maleConfig.Energy[i];
                    if (AttrUtil.energyDict.ContainsKey(k))
                    {
                        _RegisterCfgEnergy(k, maleConfig.InitEnergy[i], maleConfig.MaxEnergy[i], maleConfig.EnergyRecover[i]);
                    }
                }

                if (maleConfig.SkillEnergy != null)
                {
                    for (int i = 0; i < maleConfig.SkillEnergy.Length; i++)
                    {
                        AttrType k = (AttrType)maleConfig.SkillEnergy[i];
                        if (AttrUtil.energyDict.ContainsKey(k))
                        {
                            _RegisterCfgEnergy(k, maleConfig.InitSkillEnergy[i], maleConfig.MaxSkillEnergy[i], maleConfig.SkillEnergyRecover[i]);
                        }
                    }
                }

                var skillSlots = actor.skillOwner.GetAllSlotConfigs();
                foreach (var iter in skillSlots)
                {
                    var skillID = iter.Value.SkillID;
                    var skillLevel = iter.Value.SkillLevel;
                    var skillLevelCfg = TbUtil.GetSkillLevelCfg(skillID, skillLevel);
                    // 能量回复注册 by刘夕
                    if (skillLevelCfg != null && skillLevelCfg.SkillEnergy != null)
                    {
                        for (int i = 0; i < skillLevelCfg.SkillEnergy.Length; i++)
                        {
                            _RegisterCfgEnergy((AttrType)skillLevelCfg.SkillEnergy[i], skillLevelCfg.InitSkillEnergy[i], skillLevelCfg.MaxSkillEnergy[i], skillLevelCfg.SkillEnergyRecover[i]);
                        }
                    }
                }
                
                if (actor.weapon.weaponLogicCfg == null)
                {
                    PapeGames.X3.LogProxy.LogError($"武器配置缺失！！能量配置获取不到 actor ID:{actor.cfgID}");
                }
                else
                {
                    for (int i = 0; i < actor.weapon.weaponLogicCfg.WeaponEnergy.Length; i++)
                    {
                        actor.energyOwner._RegisterCfgEnergy((AttrType)actor.weapon.weaponLogicCfg.WeaponEnergy[i], actor.weapon.weaponLogicCfg.InitWeaponEnergy[i], actor.weapon.weaponLogicCfg.MaxWeaponEnergy[i], actor.weapon.weaponLogicCfg.WeaponEnergyRecover[i]);
                    }
                }
            }

            if (actor.roleBornCfg != null && !actor.roleBornCfg.AutoStartEnergy)
            {
                ForbidAllEnergyRecover(true);
            }
        }

        // 出生流程走完之后设置初始能量值
        public void EvalEnergyAfterBorn()
        {
            if (actor.IsGirl())
            {
                foreach (var iter in AttrUtil.energyDict)
                {
                    // ①服务器先走，②然后走配置（内部会判断优先服务器），③然后走被动init，然后走到这里真正设置初始值。
                    var energyInfo = iter.Value;
                    var initAttr = actor.attributeOwner.GetAttr(energyInfo.energyInit);
                    if (initAttr != null)
                    {
                        actor.attributeOwner.SetAttrValue(energyInfo.energy, initAttr.GetValue());
                        var attrType = iter.Key;
                        if (!_energyList.Contains(attrType))
                        {
                            _energyList.Add(attrType);
                        }
                    }
                }   
            }
        }

        public override void OnDead()
        {
            if (actor.roleBornCfg != null && !actor.roleBornCfg.AutoStartEnergy)
            {
                ForbidAllEnergyRecover(false);
            }
            UnRegisterEnergys();
            base.OnDead();
        }

        public void ForbidAllEnergyRecover(bool isForbid)
        {
            ForbidEnergyRecover(EnergyType.Male, isForbid);
            ForbidEnergyRecover(EnergyType.Skill, isForbid);
            ForbidEnergyRecover(EnergyType.Ultra, isForbid);
            ForbidEnergyRecover(EnergyType.Weapon, isForbid);
        }
        
        public void ForbidEnergyRecover(EnergyType energyType, bool isForbid)
        {
            var attr = AttrUtil.ConvertEnergyToAttr(energyType);
            if (isForbid)
            {
                if (_forbidRecoverEnergys.ContainsKey(attr))
                    _forbidRecoverEnergys[attr] += 1;
                else
                    _forbidRecoverEnergys[attr] = 1;
            }
            else
            {
                if (_forbidRecoverEnergys.ContainsKey(attr))
                {
                    if (--_forbidRecoverEnergys[attr] < 0)
                        _forbidRecoverEnergys[attr] = 0;
                }
            }
        }

        /// <summary>
        /// 能量设置回初始值
        /// </summary>
        public void ResetEnergy()
        {
            foreach (var e in _energyList)
            {
                // 自然能量恢复
                if (AttrUtil.energyDict.ContainsKey(e))
                {
                    float init = actor.attributeOwner.GetAttrValue(AttrUtil.energyDict[e].energyInit);
                    actor.attributeOwner.GetAttr(AttrUtil.energyDict[e].energy).Set(init);
                }
            }
        }

        // 从配置来的属性初始化设置
        private void _RegisterCfgEnergy(AttrType type, int initEnergy, float maxEnergy, float recoverEnergy)
        {
            if (_energyList.Contains(type))
            {
                PapeGames.X3.LogProxy.LogError($"配置了相同的能量属性 ID:{(int)type}，联系策划卡宝宝");
                return;
            }
            _energyList.Add(type);

            var energyInfo = AttrUtil.energyDict[type];
            if (energyInfo != null)
            {
                var bornAttrs = actor.bornCfg.Attrs;
                // 策划设定，服务器下发的能量值优先级最高，下发的数据会放到bornCfg.Attrs中
                actor.attributeOwner.SetAttrMinValue(energyInfo.energyRecover, float.MinValue);
                if (bornAttrs.TryGetValue(energyInfo.energyRecover, out var recoverAttr))
                {
                    actor.attributeOwner.SetAttrValue(energyInfo.energyRecover, recoverAttr);
                }
                else
                {
                    actor.attributeOwner.SetAttrValue(energyInfo.energyRecover, recoverEnergy);
                }

                if (bornAttrs.TryGetValue(energyInfo.energyMax, out var maxAttr))
                {
                    actor.attributeOwner.SetAttrValue(energyInfo.energyMax, maxAttr);
                }
                else
                {
                    actor.attributeOwner.SetAttrValue(energyInfo.energyMax, maxEnergy);
                }

                // 初始值
                float finalInitValue = initEnergy;
                if (bornAttrs.TryGetValue(energyInfo.energyInit, out var initAttr))
                {
                    finalInitValue = initAttr;
                }
                actor.attributeOwner.SetAttrValue(energyInfo.energyInit, finalInitValue);   
                
                // 判断当前值没有被服务器设置，有就是异常数据，和策划设定不符
                if (bornAttrs.ContainsKey(energyInfo.energy))
                {
                    // bornAttrs里面有是异常情况，策划设定能量不会由服务器直接下发值
                    PapeGames.X3.LogProxy.LogErrorFormat("{0} 配置了收到策划设定里不该下发的属性 {1}，请联系策划卡宝宝或路浩！", actor.name, (int)type);
                }
            }
        }

        public void UnRegisterEnergys()
        {
            _energyList.Clear();
        }

        public void ConsumeEnergy(EnergyType energyType, float energy)
        {
            ConsumeEnergy(AttrUtil.ConvertEnergyToAttr(energyType), energy, false,0);
        }

        public void GatherEnergy(EnergyType energyType, float energy)
        {
            GatherEnergy(AttrUtil.ConvertEnergyToAttr(energyType), energy);
        }

        /// <summary>
        /// 消耗能量
        /// </summary>
        /// <param name="attrType"></param> 能量的属性类型
        /// <param name="energy"></param>
        /// <param name="hasLimit">是否限制消耗后的最小值</param>
        /// <param name="min">限制消耗后的最小值</param>
        /// 
        public void ConsumeEnergy(AttrType attrType, float energy, bool hasLimit, float min)
        {
            //不能消耗常规属性
            var instantAttr = actor.attributeOwner.GetAttr(attrType) as InstantAttr;
            if (instantAttr == null)
            {
                PapeGames.X3.LogProxy.LogError($"ConsumeEnergy ,{actor.cfgID} 尝试消耗常规属性 :{attrType}");
                return;
            }
            var energyValue = instantAttr.GetValue();
            if (energyValue > 0 && energyValue <= energy)
            {
                var eventData = battle.eventMgr.GetEvent<EventEnergyExhausted>();
                eventData.Init(attrType, actor);
                Battle.Instance.eventMgr.Dispatch(EventType.EnergyExhausted, eventData);
            }
            instantAttr.Sub(energy, 0, 0,hasLimit,min);
        }

        /// <summary>
        /// 获取到能量
        /// </summary>
        /// <param name="type"></param> 获取能量的类型
        /// <param name="energy"></param> 获取能量的数值
        public void GatherEnergy(AttrType type, float energy)
        {
            if (_forbidRecoverEnergys.ContainsKey(type) && _forbidRecoverEnergys[type] > 0)
                return;
            AttrEnergy attrEnergy = _GetAttrEnergy(type);
            float gatherRatio = actor.attributeOwner.GetAttrValue(attrEnergy.energyGather);
            float max = actor.attributeOwner.GetAttrValue(AttrUtil.energyDict[type].energyMax);
            float cur = actor.attributeOwner.GetAttrValue(type);
            if (cur < max)
            {
                actor.attributeOwner.GetAttr(type).Add(energy * (1 + gatherRatio / 1000f), 0);
                cur = actor.attributeOwner.GetAttrValue(type);
                if (cur >= max)
                {
                    var eventData = battle.eventMgr.GetEvent<EventEnergyFull>();
                    eventData.Init(type, actor);
                    Battle.Instance.eventMgr.Dispatch(EventType.EnergyFull, eventData); // 若能量满了发送事件
                }
            }
        }

        private AttrEnergy _GetAttrEnergy(AttrType type)
        {
            foreach (AttrEnergy energy in AttrUtil.energyDict.Values)
            {
                if (energy.energy == type)
                {
                    return energy;
                }
            }
            return null;
        }

        protected override void OnUpdate()
        {
            if (!energyRecoverEnable)
                return;
            foreach (var e in _energyList)
            {
                // 自然能量恢复
                if (AttrUtil.energyDict.TryGetValue(e, out AttrEnergy attrEnergy))
                {
                    var attributeOwner = actor.attributeOwner;
                    float gatherRatio = attributeOwner.GetAttrValue(attrEnergy.energyGather);
                    float recover = attributeOwner.GetAttrValue(attrEnergy.energyRecover);
                    float max = attributeOwner.GetAttrValue(attrEnergy.energyMax);
                    float cur = attributeOwner.GetAttrValue(e);
                    if (_forbidRecoverEnergys.TryGetValue(e, out int forbidRecover) && forbidRecover > 0 && recover > 0)
                        continue;
                    var aboutToAdd  = recover * (1 + gatherRatio / 1000f) * battle.deltaTime;
                    if (cur > 0 && cur + aboutToAdd < 0)
                    {
                        using (ProfilerDefine.EnergyEventEnergyExhaustedPMarker.Auto())
                        {
                            var eventData = battle.eventMgr.GetEvent<EventEnergyExhausted>();
                            eventData.Init(e, actor);
                            Battle.Instance.eventMgr.Dispatch(EventType.EnergyExhausted, eventData);
                        }
                    }
                    if (cur < max && cur + aboutToAdd >= max)
                    {
                        using (ProfilerDefine.EnergyEventEnergyFullPMarker.Auto())
                        {
                            var eventData = battle.eventMgr.GetEvent<EventEnergyFull>();
                            eventData.Init(e, actor);
                            Battle.Instance.eventMgr.Dispatch(EventType.EnergyFull, eventData);
                        }
                    }
                    attributeOwner.GetAttr(attrEnergy.energy).Add(aboutToAdd, 0);
                }
            }
        }
    }
}