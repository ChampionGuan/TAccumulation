using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class SkillAgentSpawner : ActorSpawner
    {
        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorModel),
            typeof(ActorEffectPlayer),
            typeof(SkillOwner),
            typeof(BattleTimer),
        };

        public SkillAgentSpawner(Battle battle) : base(battle)
        {
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            if (!(bornCfg is SkillAgentBornCfg agentBornCfg))
            {
                return null;
            }

            var actorCfg = new ActorCfg
            {
                ID = bornCfg.CfgID,
                Type = ActorType.SkillAgent,
                SubType = (int) agentBornCfg.SubType,
                Name = bornCfg.Name,
            };
            actorCfg.CommonEffect.AddRange(bornCfg.CommonEffect);

            return actorCfg;
        }

        public override Actor CreateActor(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            var actor = base.CreateActor(actorCfg, createCfg);
            switch ((SkillAgentType) actorCfg.SubType)
            {
                case SkillAgentType.MagicField:
                    actor.entity.AddComponent<ActorSequencePlayer>();
                    actor.entity.AddComponent<ActorEffectPlayer>();
                    actor.entity.AddComponent<HaloOwner>();
                    break;
            }

            return actor;
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            return new SkillAgentBornCfg() as T;
        }

        public SkillAgentBornCfg CreateActorBornCfg(DamageExporter master, int configID, SkillAgentType type, Vector3 pos, Vector3 forward)
        {
            var bornCfg = ObjectPoolUtility.GetActorBornCfg<SkillAgentBornCfg>();

            bornCfg.CfgID = configID;
            bornCfg.GroupID = master.actor.bornCfg.GroupID;
            bornCfg.Master = master.GetCaster();
            bornCfg.MasterExporter = master;
            bornCfg.SubType = type;
            bornCfg.FactionType = master.actor.factionType;
            bornCfg.Position = pos;
            bornCfg.Forward = forward;
            // DONE: 皮肤替换使用主人的皮肤替换ID.
            bornCfg.SkinID = master.actor.bornCfg.SkinID;

            switch (type)
            {
                case SkillAgentType.Missile:
                    var missileCfg = TbUtil.GetCfg<MissileCfg>(configID);
                    if (missileCfg == null) return null;
                    bornCfg.Name = $"Missile {configID}";
                    bornCfg.CommonEffect.Add(missileCfg.FX);
                    bornCfg.LifeTime = -1;
                    break;
                case SkillAgentType.Dynamic:
                    bornCfg.Name = "SkillAgent";
                    bornCfg.LifeTime = 0;
                    break;
                case SkillAgentType.MagicField:
                    var magicFieldCfg = TbUtil.GetCfg<MagicFieldCfg>(configID);
                    if (magicFieldCfg == null) return null;
                    bornCfg.Name = $"MagicField {configID}";
                    break;
            }

            return bornCfg;
        }
    }
}
