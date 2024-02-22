using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class StageSpawner : ActorSpawner
    {
        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(AttributeOwner),
            typeof(ActorModel),
            typeof(ActorSequencePlayer),
            typeof(SkillOwner),
            typeof(BuffOwner),
            typeof(BattleTimer),
            typeof(ActorEffectPlayer),
            typeof(SignalOwner),
        };
        
        public StageSpawner(Battle battle) : base(battle)
        {
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            if (!(pointCfg is StagePointData stagePointData))
            {
                return null;
            }

            var bornCfg = ObjectPoolUtility.GetActorBornCfg<StageBornCfg>();
            bornCfg.Name = "Stage";
            bornCfg.FactionType = FactionType.Neutral;
            bornCfg.Position = stagePointData.Position;
            bornCfg.Forward = Quaternion.Euler(stagePointData.Rotation) * Vector3.forward;
            
            _GenerateCommonBornCfg(bornCfg, stagePointData);
            bornCfg.CfgID = battle.config.StageActorID;
            bornCfg.PropertyID = battle.config.StageActorPropertyID; // 与策划确定不用区分数值模式.
            
            // DONE: 将词缀技能添加进SkillSlots.
            bornCfg.SkillSlots = new Dictionary<int, SkillSlotConfig>();
            var affixesSkillSlotConfigs = battle.arg.affixesSkillSlotConfigs;
            if (affixesSkillSlotConfigs != null)
            {
                foreach (SkillSlotConfig argAffixesSkillSlotConfig in affixesSkillSlotConfigs)
                { 
                    bornCfg.SkillSlots.Add(argAffixesSkillSlotConfig.ID, argAffixesSkillSlotConfig);
                }
            }

            if (TbUtil.TryGetCfg(bornCfg.CfgID, out MonsterCfg monsterCfg))
            {
                // DONE: 组装技能槽位数据.
                if (monsterCfg.SkillSlots != null)
                {
                    foreach (var monsterCfgSkillSlot in monsterCfg.SkillSlots)
                    {
                        bornCfg.SkillSlots.Add(monsterCfgSkillSlot.Key, monsterCfgSkillSlot.Value);
                    }
                }

                bornCfg.BornActionModule = monsterCfg.BornActionModule;
                bornCfg.DeadActionModule = monsterCfg.DeadActionModule;
                bornCfg.HurtLieDeadActionModule = monsterCfg.HurtLieDeadActionModule;
            }
            
            bornCfg.AutoCastPassiveSkill = false;
            bornCfg.AutoStartEnergy = false;
            bornCfg.AutoStartAI = false;
            bornCfg.AutoStartSkillCD = false;
            

            // DONE: 与怪物同样的属性处理.
            MonsterSpawner.HandleMonsterBornCfgAttrs(bornCfg);
            
            return bornCfg as T;
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            if (null == bornCfg)
            {
                return null;
            }

            var actorCfg = new ActorCfg
            {
                ID = bornCfg.CfgID,
                Type = ActorType.Stage,
                Name = bornCfg.Name,
            };
            return actorCfg;
        }
    }
}