using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("窗口期结算")]
    [MessagePackObject]
    [Serializable]
    public class BuffEndDamage:BuffActionBase
    {
        [BuffLable("打击盒ID")]
        [Key(0)]
        public int damageBoxID;
        [BuffLable("伤害系数")]
        [Key(1)]
        public float percent;
        [BuffLable("伤害来源的角色")]
        [Key(2)]
        public DamageSourceActor damageSourceActor;
        [BuffLable("伤害来源的技能类型")]
        [Key(3)]
        public SkillTypeFlag skillTypeFlag;
        [BuffLable("伤害的打击盒类型")]
        [Key(4)]
        public DamageBoxTypeFlag damageBoxTypeFlag;
        [NonSerialized]
        private float _totalGetDamage;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.EndDamage;
        }

        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            _totalGetDamage = 0;
            Battle.Instance.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, OnHurt, "BuffEndDamage.OnHurt");
        }

        
        public override void OnDestroy()
        {
            Battle.Instance.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, OnHurt);
            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(damageBoxID);
            if (damageBoxCfg == null)
            {
                return;
            }
            
            var hitParamConfig = TbUtil.GetHitParamConfig(damageBoxCfg.HitParamID, _owner.level, _owner.layer);
            if (hitParamConfig == null)
            {
                hitParamConfig = new HitParamConfig();
                hitParamConfig.TargetDamageType = (int) DamageType.Sub;
            }
            //策划默认情况下不想配置是伤害还是治疗，默认是伤害
            if (hitParamConfig.TargetDamageType == (int)DamageType.None)
            {
                hitParamConfig.TargetDamageType = (int)DamageType.Sub;
            }

            // 此处为真实伤害
            hitParamConfig.IsTrueDamage = true;
            // 这里直接修改 基本伤害
            hitParamConfig.TargetBasicDamage = (int)(_totalGetDamage * percent);
                
            _owner.CastDamageBox(null, damageBoxCfg, hitParamConfig, _actor, _owner.level, out _);
            
            ObjectPoolUtility.BuffEndDamagePool.Release(this);

            base.OnDestroy();
        }

        private void OnHurt(EventExportDamage arg)
        {
            if (arg.damageInfo.actor != _owner.actor)
                return;
            //过滤伤害来源
            var caster = arg.exporter.GetCaster();
            switch (damageSourceActor)
            {
                case DamageSourceActor.Default:
                    break;
                case DamageSourceActor.Girl:
                    if (caster != Battle.Instance.actorMgr.girl) return;
                    break;
                case DamageSourceActor.Boy:
                    if (caster != Battle.Instance.actorMgr.boy) return;
                    break;
                case DamageSourceActor.BoyAndGirl:
                    if (caster != Battle.Instance.actorMgr.boy && caster != Battle.Instance.actorMgr.girl) return;
                    break;
                default:
                    PapeGames.X3.LogProxy.LogError($"BuffEndDamage.damageSourceActor 配置错误 {_owner.ID}");
                    break;
            }

            //过滤技能类型
            if (skillTypeFlag != 0)
            {
                var iSkill = arg.exporter as ISkill;
                if (iSkill == null) return;
                if (!BattleUtil.ContainSkillType(skillTypeFlag, iSkill.config.Type)) return;
            }

            //过滤打击盒类型
            if (damageBoxTypeFlag != 0)
            {
                if (!BattleUtil.ContainDamageBoxType(damageBoxTypeFlag, arg.damageBoxCfg.DamageBoxType)) return;
            }

            _totalGetDamage += arg.damageInfo.realDamage;
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffEndDamagePool.Get();
            action.damageBoxID = damageBoxID;
            action.percent = percent;
            action.damageSourceActor = damageSourceActor;
            action.skillTypeFlag = skillTypeFlag;
            action.damageBoxTypeFlag = damageBoxTypeFlag;
            return action;
        }
    }
}


