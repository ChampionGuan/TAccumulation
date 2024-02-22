using System;
using System.Collections.Generic;
using System.Diagnostics;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public static class DamageFormula
    {
        ///常量定义
        const float MAX_DMGDECRATE = 0.95f;             //最大免伤率
        const float THOUSANDTH = 0.001f;                //千分比参数系数
        const int DEF_DMG_RE_PARA1 = 30;                //防御系数1，乘以等级的系数
        const int DEF_DMG_RE_PARA2 = 1600;              //防御系数2，基础系数
        const float Final_Damage_Random_Range = 0.05f;     //最终伤害随机系数，填小数X，代表最终伤害在[(1-X),(1+X)]之间
        const float FOne = 1f;                          //常数1
        const float FZero = 0f;                         //常数0
        const bool DamageLogOpen = true;               //是否打开伤害公式的过程日志，仅用于本地测试，默认不打开
        private static System.Random ran = new System.Random();
        
        // DONE: 每次伤害公式前进行临时属性加成处理, 然后伤害公式里获取该次伤害临时处理的数据, 结束后获取该次伤害.
        private static Dictionary<Actor, Dictionary<AttrType, ModifyAttrValue>> _tempModifyAttrs = new Dictionary<Actor, Dictionary<AttrType, ModifyAttrValue>>(10);
        
        /// <summary>
        /// 进行暴击评定
        /// </summary>
        /// <param name="hitParamConfig"></param>
        /// <param name="damageCaster"></param>
        /// <param name="criticalModifyDatas"></param>
        /// <returns></returns>
        public static bool CriticalJudge(HitParamConfig hitParamConfig, Actor damageCaster, List<CriticalModifyData> criticalModifyDatas, List<AttrModifyData> attrModifyDatas)
        {
            _CalcTempModifyAttr(attrModifyDatas);
            var casterAttributeOwner = damageCaster.attributeOwner;
            float caster_CritVal = casterAttributeOwner._GetAdditionalAttrValue(AttrType.CritVal) * THOUSANDTH;
            float final_CritVal = caster_CritVal + hitParamConfig.CritValueModify * THOUSANDTH;

            if (criticalModifyDatas != null && criticalModifyDatas.Count > 0)
            {
                for (var i = 0; i < criticalModifyDatas.Count; i++)
                {
                    var criticalModifyData = criticalModifyDatas[i];
                    if (criticalModifyData.modifiableCriticalType == ModifiableCriticalType.CritValue)
                    {
                        final_CritVal = criticalModifyData.modifyValue * THOUSANDTH;
                    }
                    else
                    {
                        final_CritVal += criticalModifyData.modifyValue * THOUSANDTH;
                    }
                }
            }

            _ClearTempModifyAttr();
            // 生成随机数, 与暴击率比较
            double randomNum = ran.NextDouble();
            return final_CritVal >= randomNum;
        }
        
        /// <summary>
        /// 伤害计算主入口
        /// </summary>
        /// <param name="exporter">伤害来源</param>
        /// <param name="taker">伤害接受者</param>
        /// <param name="assistor">协作者</param>
        /// <param name="hitParamConfig"></param>
        public static void CalcDamage(ref DamageInfo damageInfo, DamageExporter exporter, Actor taker, Actor assistor, HitParamConfig hitParamConfig, float hurtAddAngle, float damageProportion, bool isCritical, List<AttrModifyData> attrModifyDatas, bool bIsTarget, float damageRandomValue)
        {
            // 统计该次临时属性的加成结果.
            _CalcTempModifyAttr(attrModifyDatas);

            //预期伤害计算
            CalcDamageChild(ref damageInfo, exporter, taker, hitParamConfig, exporter.GetCaster(), damageProportion, isCritical, damageRandomValue);

            //协作者伤害计算
            if (assistor != null)
            {
                float tempDamage = damageInfo.damage;
                bool tempIsCrit = damageInfo.isCritical;
                float tempRealDamage = damageInfo.realDamage;
                CalcDamageChild(ref damageInfo, exporter, taker, hitParamConfig, assistor, damageProportion, isCritical, damageRandomValue);
                damageInfo.damage = tempDamage + damageInfo.damage;
                damageInfo.isCritical = tempIsCrit;
                damageInfo.realDamage = tempRealDamage + damageInfo.realDamage;
            }

            //血量护盾计算
            CalcHpShieldDamage(ref damageInfo, exporter, taker, damageInfo.damage, hurtAddAngle);

            //实际伤害计算，当前血量判断
            float currentHP = taker.attributeOwner._GetAdditionalAttrValue(AttrType.HP);
            if (currentHP < damageInfo.realDamage)
            {
                damageInfo.realDamage = currentHP;
            }

            _LogWarningFormat("hitID{0}最终伤害输出：伤害 = {1}, 是否暴击 = {2}, 实际伤害 = {3}", hitParamConfig.ID, damageInfo.damage, damageInfo.isCritical, damageInfo.realDamage);

            _ClearTempModifyAttr();
        }

        /// <summary>
        /// 伤害计算详细流程
        /// </summary>
        /// <param name="damageExporter">伤害来源</param>
        /// <param name="damageTaker">伤害接受者</param>
        /// <param name="hitParamConfig"></param>
        private static void CalcDamageChild(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster, float damageProportion, bool isCritical, float damageRandomValue)
        {
            //是否暴击更新至damageInfo中
            damageInfo.isCritical = isCritical;            
            //第1步：计算基础伤害
            CalcDamageBase(ref damageInfo, damageExporter, damageTaker, hitParamConfig, damageCaster);
            if (!hitParamConfig.IsTrueDamage)
            {            
                //第2步：计算防御减伤
                CalcDamageDef(ref damageInfo, damageExporter, damageTaker, hitParamConfig, damageCaster);
                //第3步：计算暴击影响
                CalcDamageCrit(ref damageInfo, damageExporter, damageTaker, hitParamConfig, damageCaster);
            };            
            //第4步：计算附加伤害（无视防御和暴击影响）
            CalcDamagePlus(ref damageInfo, damageExporter, damageTaker, hitParamConfig, damageCaster);
            if (!hitParamConfig.IsTrueDamage)
            {
                //第5步：计算tag增伤和tag减伤，计算虚弱影响
                CalcDamageTag(ref damageInfo, damageExporter, damageTaker, hitParamConfig, damageCaster);
                //第6步：计算技能类型增伤，专武技能类型增伤，和通用增伤和减伤影响；计算玩法增伤和玩法减伤
                CalcDamageBonus(ref damageInfo, damageExporter, damageTaker, hitParamConfig, damageCaster);
            }                
            //第7步：伤害修饰（伤害权重和结果随机化）
            CalcDamageDecorate(ref damageInfo, damageExporter, damageTaker, hitParamConfig, damageCaster, damageProportion, damageRandomValue);
            damageInfo.realDamage = damageInfo.damage;
        }


        /// <summary>
        /// 计算基础伤害
        /// </summary>
        private static void CalcDamageBase(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster)
        {
            //获取攻击方的攻击、血量、防御属性；20240204：追加自身当前血量护盾
            float caster_atk = damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.PhyAttack);
            float caster_maxHP = damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.MaxHP);
            float caster_def = damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.PhyDefence);
            float caster_hpShield = damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.HpShield);

            //获取技能的伤害系数；20240204：新增血量护盾系数
            float basicPara = hitParamConfig.TargetBasicDamage;
            float atkPara = hitParamConfig.TargetDamageAtkRatio;
            float maxHpPara = hitParamConfig.TargetDamageHpRatio;
            float defPara = hitParamConfig.TargetDamageDefRatio;
            float shieldPara = hitParamConfig.TargetDamageShieldRatio;

            //技能伤害初始值 = (基础伤害 + 施法者攻击力 * 攻击系数 + 施法者最大血量 * 血量系数 + 施法者防御力 * 防御系数 + 施法者当前血量护盾 * 护盾系数) * 伤害权重系数      
            damageInfo.damage = (basicPara + caster_atk * atkPara + caster_maxHP * maxHpPara + caster_def * defPara + caster_hpShield * shieldPara);

            //打印属性，验证战斗内属性是否准确（不影响战斗的结算流程，后续可删除）
            _LogWarningFormat(
                "hitID{0}伤害_基础={1}，固定伤害={2}，攻击力={3}，攻击系数={4}，最大生命={5}，生命系数={6}，防御力={7}，防御系数={8}，血量护盾={9}，血量护盾系数={10}",
                hitParamConfig.ID, damageInfo.damage, basicPara, caster_atk, atkPara, caster_maxHP, maxHpPara, caster_def, defPara, caster_hpShield, shieldPara);
        }

        /// <summary>
        /// 计算防御减伤
        /// </summary>
        private static void CalcDamageDef(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster)
        {
            //目标防御值 = 受击方物理防御 * (1 - 攻击方的忽视防御千分比)
            float target_def = damageTaker.attributeOwner._GetAdditionalAttrValue(AttrType.PhyDefence);
            float caster_ignoreDefence = damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.IgnoreDefence);
            target_def = target_def * (1 - caster_ignoreDefence * THOUSANDTH);

            int caster_level = damageCaster.level;
            float fDefRate = 0f;
            if (target_def >= 0)
            {
                //免伤率 = Math.Min(目标防御值 / (目标防御值 + 施法者的等级 * （防御系数1=20） + 防御系数2=1600), (最大免伤率=0.95))
                fDefRate = Math.Min(target_def / (target_def + caster_level * DEF_DMG_RE_PARA1 + DEF_DMG_RE_PARA2), MAX_DMGDECRATE);
            }
            else
            {
                //增加防御为负数时的处理：
                fDefRate = Math.Max(target_def / (-target_def + caster_level * DEF_DMG_RE_PARA1 + DEF_DMG_RE_PARA2), -MAX_DMGDECRATE);
            }

            //计算防御后的伤害 = 技能初始值 * (1-防御免伤率)
            damageInfo.damage = damageInfo.damage * (FOne - fDefRate);

            _LogWarningFormat(
                    "hitID{0}伤害_防御后={1}，伤害减免={2}，目标防御={3}，攻击者等级={4}",
                    hitParamConfig.ID, damageInfo.damage, fDefRate, target_def, caster_level);
        }


        /// <summary>
        /// 计算暴击影响
        /// </summary>
        private static void CalcDamageCrit(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster)
        {
            //判断是否暴击，若暴击则伤害提升
            if (damageInfo.isCritical)
            {
                //暴击伤害为千分比（角色初始1500），需要先乘以千分之一再参与运算，暴击伤害加成必定大于1
                float caster_CritHurtAdd = Math.Max(FOne, damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.CritHurtAdd) * THOUSANDTH);

                // 计算暴击伤害加成后的伤害 = 计算防御后的伤害 * 暴击伤害加成
                damageInfo.damage = damageInfo.damage * caster_CritHurtAdd;

                _LogWarningFormat("hitID{0}伤害_暴击后={1}，暴击伤害倍率={2}", hitParamConfig.ID, damageInfo.damage, caster_CritHurtAdd);
            }
        }


        /// <summary>
        /// 计算附加伤害，不受防御和暴击影响
        /// </summary>
        private static void CalcDamagePlus(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster)
        {
            //20230410:引入伤害——不受防御和暴击影响，但受后续的环节影响
            //20230410:这一版本实现目标血量上限*千分比真实伤害（因为导表已经处理为小数，不需要乘以THOUSANDTH），后续注意对于大血量怪物，考虑加上限限制（避免百分比伤害过高）
            float targetMaxHPDmgRatio = Math.Min(hitParamConfig.TargetDamageHpRatioOther, FOne);
            if (targetMaxHPDmgRatio > 0)
            {
                float targetMaxHP = damageTaker.attributeOwner._GetAdditionalAttrValue(AttrType.MaxHP);
                damageInfo.damage = damageInfo.damage + targetMaxHP * targetMaxHPDmgRatio;
                _LogWarningFormat("hitID{0}伤害_附加目标血量后={1}，目标最大血量={2}，血量伤害系数={3}", hitParamConfig.ID, damageInfo.damage, targetMaxHP, targetMaxHPDmgRatio);
            }
        }

        /// <summary>
        /// 计算Tag相关的伤害加成和减免，含虚弱伤害加成
        /// </summary>
        private static void CalcDamageTag(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster)
        {
            //2023.06.09：计算TAG伤害加深、TAG伤害减免影响（该伤害加成乘区为TAG匹配专用）
            //伤害加深和伤害减免为千分比，需要先乘以千分之一再参与运算
            float caster_dmgUP = damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.HurtAdd) * THOUSANDTH;
            float target_dmgRe = damageTaker.attributeOwner._GetAdditionalAttrValue(AttrType.HurtDec) * THOUSANDTH;

            if (caster_dmgUP != 0 || target_dmgRe != 0)
            {
                damageInfo.damage = damageInfo.damage * (FOne + caster_dmgUP) * (FOne - target_dmgRe);
                _LogWarningFormat("hitID{0}伤害_tag={1}，tag伤害加成={2}，tag伤害减免={3}", hitParamConfig.ID, damageInfo.damage, caster_dmgUP, target_dmgRe);
            }

            //2023.06.09 获取受击方虚弱伤害加成（该数值仅用于怪物虚弱时，附加给怪物从而造成虚弱增伤）
            float target_weakHurtAdd = damageTaker.attributeOwner._GetAdditionalAttrValue(AttrType.WeakHurtAdd) * THOUSANDTH;
            if (null != damageTaker.actorWeak && damageTaker.actorWeak.weak)
            {
                //2023.09.25 获取攻击方的虚弱增伤属性（属性含义为：百分比提升对虚弱状态下的目标的伤害）
                float caster_weakDamageAdd = damageCaster.attributeOwner._GetAdditionalAttrValue(AttrType.WeakDamageAdd) * THOUSANDTH;
                damageInfo.damage = damageInfo.damage * (FOne + target_weakHurtAdd + caster_weakDamageAdd);
                _LogWarningFormat("hitID{0}伤害_虚弱={1}，受击方虚弱易伤={2},攻击方虚弱增伤={3}", hitParamConfig.ID, damageInfo.damage, target_weakHurtAdd, caster_weakDamageAdd);
            }
        }

        /// <summary>
        /// 计算通用伤害加成和减免，技能类型增伤，专武技能类型增伤；新增玩法增伤和玩法减伤
        /// </summary>
        private static void CalcDamageBonus(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster)
        {
            var casterAttributeOwner = damageCaster.attributeOwner;
            var takerAttributeOwner = damageTaker.attributeOwner;

            //特定技能类型（普攻、主动技、连携技、爆发技）伤害增加，注意传入值含义为千分比，需要先除以1000
            float caster_skillTypeDmgUp = FZero;
            //增加武器专属增伤结算——用以实现专武的普攻增伤和主动技增伤，传入值为千分比，需要除以1000
            float caster_weaponSkillTypeDmgUp = FZero;

            //初始化skillType
            //TODO 是否可以考虑透传进来
            var damageSkillType = DamageSkillType.Attack;
            //伤害结算中优先使用hitParamConfig的类型   
            if (hitParamConfig.SkillDamageType >= 0)
            {
                damageSkillType = (DamageSkillType)hitParamConfig.SkillDamageType;
            }
            else
            {
                damageSkillType = (DamageSkillType)damageExporter.GetSkillType();
            }

            switch (damageSkillType)
            {
                case DamageSkillType.Attack:
                    caster_skillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.AttackSkillAdd) * THOUSANDTH;
                    caster_weaponSkillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.WeaponAttackSkillAdd) * THOUSANDTH;
                    break;
                case DamageSkillType.Active:
                    caster_skillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.ActiveSkillAdd) * THOUSANDTH;
                    caster_weaponSkillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.WeaponActiveSkillAdd) * THOUSANDTH;
                    break;
                case DamageSkillType.Coop:
                    caster_skillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.CoopSkillAdd) * THOUSANDTH;
                    break;
                case DamageSkillType.Ultra:
                    caster_skillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.UltraSkillAdd) * THOUSANDTH;
                    break;
                case DamageSkillType.AttackHeavy:
                    caster_skillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.ThumpSkillAdd) * THOUSANDTH;
                    break;
                case DamageSkillType.MaleActive:
                case DamageSkillType.EXMaleActive:
                    caster_skillTypeDmgUp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.AssistSkillAdd) * THOUSANDTH;
                    break;    
                default:
                    break;
            }
            // DONE: 计算技能类型增伤 = (1 + 技能类型伤害提升) * (1 + 专武技能类型伤害提升）
            if (caster_skillTypeDmgUp != 0 || caster_weaponSkillTypeDmgUp != 0)
            {
                damageInfo.damage = damageInfo.damage * (FOne + caster_skillTypeDmgUp) * (FOne + caster_weaponSkillTypeDmgUp);
                _LogWarningFormat("hitID{0}伤害_技能类型伤害加成后={1}，技能伤害加成={2}，专武伤害加成={3}，技能类型={4}",
                        hitParamConfig.ID, damageInfo.damage, caster_skillTypeDmgUp, caster_weaponSkillTypeDmgUp, damageSkillType);
            }
            

            //2022.08.08 通用伤害加成和通用伤害减免
            float caster_finalDamageAdd = casterAttributeOwner._GetAdditionalAttrValue(AttrType.FinalDamageAdd) * THOUSANDTH;
            float target_finalDamageDec = takerAttributeOwner._GetAdditionalAttrValue(AttrType.FinalDamageDec) * THOUSANDTH;

            if (caster_finalDamageAdd != 0 || target_finalDamageDec != 0)
            {
                // 2023.06.09 伤害修饰 =  (1 + 通用伤害加成 ）*（1- 通用伤害减免） 
                damageInfo.damage = damageInfo.damage * (FOne + caster_finalDamageAdd) * (FOne - target_finalDamageDec);
                _LogWarningFormat("hitID{0}伤害_通用伤害加成后={1}，通用伤害加成={2}，通用伤害减免={3}",
                        hitParamConfig.ID, damageInfo.damage, caster_finalDamageAdd, target_finalDamageDec);
            }

            //2023.11.10 玩法伤害加成和玩法伤害减免
            float caster_gameplayDamageAdd = casterAttributeOwner._GetAdditionalAttrValue(AttrType.GameplayDamageAdd) * THOUSANDTH;
            float target_gameplayDamageDec = takerAttributeOwner._GetAdditionalAttrValue(AttrType.GameplayDamageDec) * THOUSANDTH;
            if(caster_gameplayDamageAdd != 0 || target_gameplayDamageDec !=0)
            {
                damageInfo.damage = damageInfo.damage * (FOne + caster_gameplayDamageAdd) * (FOne - target_gameplayDamageDec);
                _LogWarningFormat("hitID{0}伤害_玩法专用伤害加成后={1}，攻方玩法伤害加成={2}，受击方玩法伤害减免={3}",
                        hitParamConfig.ID, damageInfo.damage, caster_gameplayDamageAdd, target_gameplayDamageDec);
            }
        }

        /// <summary>
        /// 伤害修饰
        /// </summary>
        private static void CalcDamageDecorate(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, Actor damageCaster, float damageProportion, float damageRandomValue)
        {
            //伤害结果随机化
            if (Final_Damage_Random_Range > 0)
            {
                //伤害随机系数 = [-1 , 1] * (最终伤害随机系数=0)
                float randomRatio = (damageRandomValue * 2 - 1) * Final_Damage_Random_Range;
                //计算伤害结果随机化后的伤害 = 最终伤害系数 * (1 + 伤害随机系数)
                damageInfo.damage = damageInfo.damage * (1 + randomRatio);
                _LogWarningFormat("hitID{0}伤害_随机后={1}，随机系数={2}", hitParamConfig.ID, damageInfo.damage, randomRatio);
            }


            //计算伤害保底后的伤害，伤害不能小于1
            damageInfo.damage = damageInfo.damage * damageProportion;
            damageInfo.damage = Mathf.Floor(Math.Max(damageInfo.damage, FOne));
            _LogWarningFormat("hitID{0}伤害_算上权重后={1},伤害权重 ={2}", hitParamConfig.ID, damageInfo.damage, damageProportion);
        }


        /// <summary>
        /// 治疗计算主入口
        /// </summary>
        /// <param name="damageExporter">伤害来源</param>
        /// <param name="damageTaker">伤害接受者</param>
        /// <param name="hitParamConfig"></param>
        public static void CalcHeal(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig, float damageProportion, List<AttrModifyData> attrModifyDatas ,bool bIsTarget)
        {
            _CalcTempModifyAttr(attrModifyDatas);
            
            //若技能效果是治疗技能：
            float healHp = 0f;
            Actor caster = damageExporter.GetCaster();
            var casterAttributeOwner = caster.attributeOwner;
            var takerAttributeOwner = damageTaker.attributeOwner;
            float caster_atk = casterAttributeOwner._GetAdditionalAttrValue(AttrType.PhyAttack);
            float caster_hp = casterAttributeOwner._GetAdditionalAttrValue(AttrType.MaxHP);
            float caster_def = casterAttributeOwner._GetAdditionalAttrValue(AttrType.PhyDefence);
            float attrAddSkillHeal = 0;
            float attrAddSelfSkillHeal = 0;
            float healSkillInit = 0f;
            if (bIsTarget)
            {
                //属性附加技能治疗 = 施法者攻击力 * 目标攻击治疗系数 + 施法者最大血量 * 目标血量上限治疗系数 + 施法者防御力 * 目标防御治疗系数
                attrAddSkillHeal = caster_atk * hitParamConfig.TargetHealAtkRatio + caster_hp * hitParamConfig.TargetHealHpRatio + caster_def * hitParamConfig.TargetHealDefRatio;
                healSkillInit = (hitParamConfig.TargetBasicHeal + attrAddSkillHeal) * damageProportion;
            }
            else
            {
                //属性附加自我技能治疗 = 施法者攻击力 * 施法者攻击治疗系数 + 施法者最大血量 * 施法者血量上限治疗系数
                attrAddSelfSkillHeal = caster_atk * hitParamConfig.SelfHealAtkRatio + caster_hp * hitParamConfig.SelfHealHpRatio;
                healSkillInit = (hitParamConfig.SelfBasicHeal + attrAddSelfSkillHeal) * damageProportion;
            }
            //20230410:引入目标最大血量百分比治疗，会受到治疗加成效果影响
            float healMaxHPRatio = Math.Min(hitParamConfig.TargetHealHpRatioOther, FOne);
            float healPlusPct = healSkillInit + takerAttributeOwner._GetAdditionalAttrValue(AttrType.MaxHP) * healMaxHPRatio;

            //施法方治疗效果增强和受施法方被治疗效果增强。20221003：治疗加成和受治疗加成为千分比，需要手动乘以千分之一
            float caster_CureAdd = casterAttributeOwner._GetAdditionalAttrValue(AttrType.CureAdd) * THOUSANDTH;
            float target_CuredAdd = takerAttributeOwner._GetAdditionalAttrValue(AttrType.CuredAdd) * THOUSANDTH;
            healHp = healPlusPct * (FOne + caster_CureAdd + target_CuredAdd);
            
            if (bIsTarget)
            {
                _LogWarningFormat("攻击力 = {0}, 治疗攻击加成系数 = {1}, 治疗血量加成系数 = {2}, 此hit伤害占比系数 = {3}, 基础治疗量 = {4}, 施法方治疗效果增强 = {5}, 受施法方被治疗效果增强 = {6}",
                caster_atk, hitParamConfig.TargetHealAtkRatio, hitParamConfig.TargetHealHpRatio, damageProportion, hitParamConfig.TargetBasicHeal,
                caster_CureAdd, target_CuredAdd);
            }
            else
            {
                _LogWarningFormat("攻击力 = {0}, 治疗攻击加成系数 = {1},  治疗血量加成系数 = {2}, 此hit伤害占比系数 = {3}, 基础治疗量 = {4}, 施法方治疗效果增强 = {5}, 受施法方被治疗效果增强 = {6}",
                caster_atk, hitParamConfig.SelfHealAtkRatio, hitParamConfig.SelfHealHpRatio, damageProportion, hitParamConfig.SelfBasicHeal,
                caster_CureAdd, target_CuredAdd);
            }

            //增加1为保底
            healHp = Mathf.Floor(Math.Max(healHp, FOne));
            damageInfo.damage = healHp;

            //治疗healDamage计算
            float currentHP = takerAttributeOwner._GetAdditionalAttrValue(AttrType.HP);
            float maxHP = takerAttributeOwner._GetAdditionalAttrValue(AttrType.MaxHP);
            if (healHp > maxHP - currentHP)
            {
                damageInfo.realDamage = maxHP - currentHP;
            }
            else
            {
                damageInfo.realDamage = healHp;
            }

            _LogWarningFormat("CalcHeal最终治疗：damage = {0}, realDamage = {1}", damageInfo.damage, damageInfo.realDamage);
            
            _ClearTempModifyAttr();
        }

        /// <summary>
        /// 扣除生命
        /// </summary>
        /// <param name="damageInfo"></param>
        /// <param name="damageExporter"></param>
        /// <param name="damageTaker"></param>
        /// <param name="hitParamConfig"></param>
        /// <param name="damageProportion"></param>
        public static void CalcDeduct(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, HitParamConfig hitParamConfig)
        {
            var targetHp = damageTaker.attributeOwner._GetAdditionalAttrValue(AttrType.HP);
            var targetHpDeductRatio = hitParamConfig.TargetHpDeductRatio;
            var targetHpMax = damageTaker.attributeOwner._GetAdditionalAttrValue(AttrType.MaxHP);
            var targetHpMaxDeductRatio = hitParamConfig.TargetHpMaxDeductRatio;

            // 公式: [当前生命]*[目标当前血量扣除系数]+[生命上限]*[目标血量上限扣除系数]
            damageInfo.damage = targetHp * targetHpDeductRatio + targetHpMax * targetHpMaxDeductRatio;
            
            if (damageInfo.damage > targetHp)
            {
                // 扣除最小生命值限制.
                if (hitParamConfig.TargetDeductMinHpLimit > 0)
                {
                    damageInfo.damage = targetHp - hitParamConfig.TargetDeductMinHpLimit;
                }
                // 扣除最小生命值限制比例.
                else if (hitParamConfig.TargetDeductMinHpRatio > 0)
                {
                    damageInfo.damage = targetHp - targetHpMax * hitParamConfig.TargetDeductMinHpRatio;
                }
            }
            
            damageInfo.realDamage = damageInfo.damage;
        }
        
        /// <summary>
        /// 血量护盾计算
        /// </summary>
        /// <param name="damageExporter">伤害来源</param>
        /// <param name="damageTaker">伤害接受者</param>
        /// <param name="damage">最终伤害值</param>
        /// <param name="hurtAddAngle">伤害加深夹角</param>
        private static void CalcHpShieldDamage(ref DamageInfo damageInfo, DamageExporter damageExporter, Actor damageTaker, float damage, float hurtAddAngle)
        {
            var takerAttributeOwner = damageTaker.attributeOwner;
            
            float hpShieldDamage = FZero;
            float hpDamage = damage;
            
            //血量护盾值
            float hpShield = takerAttributeOwner._GetAdditionalAttrValue(AttrType.HpShield);
            //判断是否有血量护盾
            if (hpShield <= FZero)
            {
                return;
            }
            
            // //@type Role 伤害输出Actor
            // Actor caster = damageExporter.GetCaster();
            
            //接收者朝向
            Vector3 takerForward = damageTaker.transform.forward;
            
            //伤害源朝向
            Vector3 casterPos = damageExporter.GetCaster().transform.position;
            Vector3 takerPos = damageTaker.transform.position;
            Vector3 damageForward = casterPos - takerPos;
            
            float hpShieldHurtAdd = takerAttributeOwner._GetAdditionalAttrValue(AttrType.HpShieldHurtAdd);
            float hpShieldHurtDec = takerAttributeOwner._GetAdditionalAttrValue(AttrType.HpShieldHurtDec);
            
            //伤害系数，大于伤害加深夹角时，使用护盾伤害加深系数，否则取减免系数
            float damageFactor = Vector3.Angle(damageForward, takerForward) > hurtAddAngle ? (FOne + hpShieldHurtAdd) : (FOne + hpShieldHurtDec);
            
            //如果factor* damage>hpShield，那么这次扣除的血量护盾值为hpShield，剩余的血量护盾值为0，接下来需要扣除的血量值为damage-hpShield/factor
            //如果factor* damage<=hpShield，那么这次扣除的血量护盾值为factor* damage，剩余的血量护盾值为hpShield-factor* damage

            damageInfo.realDamage = damageTaker.shield.DamageHpShield(damage, damageFactor);
        }

        /// <summary>
        /// 获取加成后的属性
        /// </summary>
        /// <param name="attributeOwner"></param>
        /// <param name="attrType"></param>
        /// <returns></returns>
        private static float _GetAdditionalAttrValue(this AttributeOwner attributeOwner, AttrType attrType)
        {
            if (!_tempModifyAttrs.TryGetValue(attributeOwner.actor, out var dictionary))
            {
                return attributeOwner.GetAttrValue(attrType);
            }

            if (!dictionary.TryGetValue(attrType, out var modifyAttrValue))
            {
                return attributeOwner.GetAttrValue(attrType);
            }
            
            return modifyAttrValue.finalValue;
        }
        
        private static void _CalcTempModifyAttr(List<AttrModifyData> attrModifyDatas)
        {
            _tempModifyAttrs.Clear();
            foreach (var attrModifyData in attrModifyDatas)
            {
                var target = attrModifyData.actor;
                var attrType = attrModifyData.attrType;
                if (!_tempModifyAttrs.TryGetValue(target, out var dictionary))
                {
                    var modifyAttrValue = ObjectPoolUtility.ModifyAttrValuePool.Get();
                    modifyAttrValue.type = attrType;
                    modifyAttrValue.additionalValue = attrModifyData.additionalValue;
                    modifyAttrValue.percentValue = attrModifyData.percentValue;
                    
                    var modifyAttrValueDictionary = ObjectPoolUtility.ModifyAttrValueDictionary.Get();
                    modifyAttrValueDictionary.Add(attrType, modifyAttrValue);
                    _tempModifyAttrs.Add(target, modifyAttrValueDictionary);
                }
                else
                {
                    if (!dictionary.TryGetValue(attrModifyData.attrType, out var modifyAttrValue))
                    {
                        modifyAttrValue = ObjectPoolUtility.ModifyAttrValuePool.Get();
                        modifyAttrValue.type = attrType;
                        modifyAttrValue.additionalValue = attrModifyData.additionalValue;
                        modifyAttrValue.percentValue = attrModifyData.percentValue;
                        dictionary.Add(attrModifyData.attrType, modifyAttrValue);
                    }
                    else
                    {
                        modifyAttrValue.additionalValue += attrModifyData.additionalValue;
                        modifyAttrValue.percentValue += attrModifyData.percentValue;   
                    }
                }
            }

            foreach (var kAttributeValue in _tempModifyAttrs)
            {
                var attributeOwner = kAttributeValue.Key.attributeOwner;
                var dictionary = kAttributeValue.Value;
                foreach (var kModifyAttrValue in dictionary)
                {
                    var modifyAttrValue = kModifyAttrValue.Value;
                    var attr = attributeOwner.GetAttr(kModifyAttrValue.Key);
                    if (attr == null)
                    {
                        continue;
                    }

                    // DONE: 提前计算出临时属性加成后的最终值是多少.
                    modifyAttrValue.finalValue = attr.CalculateAddedValue(modifyAttrValue.percentValue, modifyAttrValue.additionalValue);
                }
            }
        }

        private static void _ClearTempModifyAttr()
        {
            foreach (var kTempModifyAttr in _tempModifyAttrs)
            {
                var dictionary = kTempModifyAttr.Value;
                foreach (var kModifyAttrValue in dictionary)
                {
                    ObjectPoolUtility.ModifyAttrValuePool.Release(kModifyAttrValue.Value);
                }
                dictionary.Clear();
                ObjectPoolUtility.ModifyAttrValueDictionary.Release(dictionary);
            }
            
            _tempModifyAttrs.Clear();
        }

        [Conditional(LogProxy.DEBUG_LOG)]
        private static void _LogWarningFormat(string format, params object[] args)
        {
            if (DamageLogOpen)
            {
                LogProxy.LogWarningFormat(format, args);
            }
        }
    }
}