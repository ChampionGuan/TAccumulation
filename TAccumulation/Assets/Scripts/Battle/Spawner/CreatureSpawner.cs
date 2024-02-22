using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class CreatureSpawner : ActorSpawner
    {
        private ActorCfg _fakebodyCfg = new ActorCfg {ID = 0, Type = ActorType.Programmer, SubType = -1, Name = "Fakebody"};

        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorModel),
            typeof(ActorStateTag),
            typeof(ColliderBehavior),
        };

        public CreatureSpawner(Battle battle) : base(battle)
        {
        }

        public override T1 CreateActorBornCfg<T1>(PointBase pointCfg)
        {
            var bornCfg = ObjectPoolUtility.GetActorBornCfg<T1>();

            if (pointCfg is CreaturePointData point)
            {
                _GenerateCommonBornCfg(bornCfg, point);
                bornCfg.Master = point.Master;
                bornCfg.CreatureType = point.CreatureType;
            }

            if (pointCfg is SummonCreaturePointData point2 && bornCfg is RoleBornCfg roleBornCfg)
            {
                _GenerateCreatureBornCfg(point2, roleBornCfg);
            }

            return bornCfg;
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            switch (bornCfg.CreatureType)
            {
                case CreatureType.Fakebody:
                    return _fakebodyCfg;
            }

            return null;
        }

        public override Actor CreateActor(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            Actor actor = null;
            switch (createCfg.CreatureType)
            {
                case CreatureType.Fakebody:
                    actor = base.CreateActor(actorCfg, createCfg);
                    actor.entity.AddComponent<ActorEffectPlayer>();
                    break;
                case CreatureType.Effect:
                    actor = base.CreateActor(actorCfg, createCfg);
                    actor.entity.AddComponent<ActorMainState>();
                    actor.entity.AddComponent<AttributeOwner>();
                    actor.entity.AddComponent<SkillOwner>();
                    actor.entity.AddComponent<BuffOwner>();
                    actor.entity.AddComponent<AIOwner>();
                    actor.entity.AddComponent<ActorCommander>();
                    actor.entity.AddComponent<ActorSequencePlayer>();
                    actor.entity.AddComponent<ActorHurt>();
                    actor.entity.AddComponent<TargetSelector>();
                    actor.entity.AddComponent<ActorWeak>();
                    actor.entity.AddComponent<SignalOwner>();
                    actor.entity.AddComponent<ActorEffectPlayer>();
                    actor.entity.AddComponent<ActorEventMgr>();
                    actor.entity.AddComponent<HaloOwner>();
                    actor.entity.AddComponent<ActorDamageMeters>();
                    actor.entity.AddComponent(new BattleTimer(actor, (int) ActorComponentType.Timer));
                    break;
            }

            return actor;
        }

        /// <summary>
        /// 对创生物出生配置进行 属性继承处理.
        /// </summary>
        protected void _GenerateCreatureBornCfg(SummonCreaturePointData data, RoleBornCfg bornCfg)
        {
            if (null == bornCfg) return;

            var masterBornCfg = data.Master.roleBornCfg;
            var summonConfig = data.SummonConfig;

            // DONE: 召唤物的AI默认激活状态.
            bornCfg.IsAIActive = true;
            bornCfg.AIStatus = ActorAIStatus.Attack;
            bornCfg.SummonID = summonConfig.ID;
            bornCfg.LifeTime = summonConfig.LifeTime;
            bornCfg.DeadWithMaster = summonConfig.DeadWithMaster != 0;
            bornCfg.InheritHatred = summonConfig.InheritHatred;
            bornCfg.EnableBeLocked = summonConfig.EnableBeLocked == 0;
			bornCfg.IsShowArrowIcon = summonConfig.IsShowArrowIcon;
            bornCfg.SkinID = masterBornCfg.SkinID;

            // DONE: 创生物等级继承
            bornCfg.Level = data.Master.level;

            // DONE: 创生物技能等级继承
            if (bornCfg.SkillSlots != null)
            {
                foreach (var skillSlotConfig in bornCfg.SkillSlots)
                {
                    skillSlotConfig.Value.SkillLevel = data.MasterSkill.level;
                }
            }

            // DONE: 创生物属性继承
            bornCfg.Attrs.Add(AttrType.HP, 0f);
            bornCfg.Attrs.Add(AttrType.MaxHP, 0f);
            bornCfg.Attrs.Add(AttrType.PhyAttack, 0f);
            bornCfg.Attrs.Add(AttrType.PhyDefence, 0f);
            bornCfg.Attrs.Add(AttrType.CritVal, 0f);
            bornCfg.Attrs.Add(AttrType.CritHurtAdd, 0f);
            bornCfg.Attrs.Add(AttrType.CoreDamageRatio, 0f);
            bornCfg.Attrs.Add(AttrType.MoveSpeed, 1000); 
 
            // DONE: 继承主人属性
            if (summonConfig.Source == 0)
            {
                foreach (var attr in masterBornCfg.Attrs)
                {
                    if (bornCfg.Attrs.ContainsKey(attr.Key))
                    {
                        bornCfg.Attrs[attr.Key] = attr.Value;
                    }
                    else
                    {
                        bornCfg.Attrs.Add(attr.Key, attr.Value);
                    }
                }

                BattleUtil.SetDictAttrBySummonScale(bornCfg.Attrs,summonConfig.AttrScale);
            }
            // DONE: 继承主人等级-从Base里取
            else if (summonConfig.Source == 1)
            {
                var monsterBase = TbUtil.GetMonsterBase(summonConfig.NumType, data.Master.level);
                if (monsterBase != null)
                {
                    foreach (var attr in masterBornCfg.Attrs)
                    {
                        if (bornCfg.Attrs.ContainsKey(attr.Key))
                        {
                            bornCfg.Attrs[attr.Key] = attr.Value;
                        }
                        else
                        {
                            bornCfg.Attrs.Add(attr.Key, 0f);
                        }
                    }

                    bornCfg.Attrs[AttrType.HP] = monsterBase.MaxHP;
                    bornCfg.Attrs[AttrType.MaxHP] = monsterBase.MaxHP;
                    bornCfg.Attrs[AttrType.PhyAttack] = monsterBase.PhyAttack;
                    bornCfg.Attrs[AttrType.PhyDefence] = monsterBase.PhyDefence;
                    bornCfg.Attrs[AttrType.CritVal] =  monsterBase.CritVal;
                    bornCfg.Attrs[AttrType.CritHurtAdd] = monsterBase.CritHurtAdd;
                    BattleUtil.SetDictAttrBySummonScale(bornCfg.Attrs,summonConfig.AttrScale);
                }
                else
                {
                    PapeGames.X3.LogProxy.LogError($"请联系策划【卡宝】 配置表：monsterBases 没有NumType= {summonConfig.NumType} && Level={data.Master.level} 的配置");
                }
            }
            else if (summonConfig.Source == 2)
            {
                //实时继承master
                bornCfg.RealTimeInherit = true;
            }
        }
    }
}
