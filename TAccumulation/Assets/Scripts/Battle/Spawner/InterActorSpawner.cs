using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class InterActorSpawner : ActorSpawner
    {
        public InterActorSpawner(Battle battle) : base(battle)
        {
            
        }

        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorMainState),
            typeof(AttributeOwner),
            typeof(ActorModel),
            typeof(SkillOwner),
            typeof(BuffOwner),
            typeof(ColliderBehavior),
            typeof(ActorSequencePlayer),
            typeof(ActorStateTag),
            typeof(TargetSelector),
            typeof(SignalOwner),
            typeof(ActorEffectPlayer),
            typeof(ActorEventMgr),
            typeof(BattleTimer),
            typeof(HaloOwner),
            typeof(HPOwner),
            typeof(ActorFrozen),
            typeof(LookAt),
            typeof(InterActorOwner),
            typeof(ActorShield),
        };

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            if (bornCfg == null)
            {
                return null;
            }

            if (!(bornCfg is RoleBornCfg interActorBornCfg))
            {
                return null;
            }
            
            if (TbUtil.TryGetCfg(interActorBornCfg.InterActorModelCfgId, out InterActorCfg interActorCfg))
            {
                return interActorCfg;
            }

            return null;
        }
        
        public override Actor CreateActor(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            var actor = base.CreateActor(actorCfg, createCfg);

            return actor;
        }
        
        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            var bornCfg = ObjectPoolUtility.GetActorBornCfg<RoleBornCfg>();
            var pointConfig = pointCfg as ActorPointBase;
            if (pointConfig == null) return null;
            
            _GenerateCommonBornCfg(bornCfg, pointConfig);
            _GenerateInterActorBornCfg((InterActorPointConfig) pointConfig, bornCfg);
            return bornCfg as T;
        }
        
        private void _GenerateInterActorBornCfg(InterActorPointConfig spawnPoint, RoleBornCfg bornCfg)
        {
            bornCfg.GroupID = spawnPoint.GroupID;
            bornCfg.InterActorModelCfgId = spawnPoint.ModelCfgId;

            if (TbUtil.TryGetCfg(bornCfg.InterActorModelCfgId, out InterActorCfg actorCfg))
            {
                bornCfg.BornActionModule = actorCfg.BornActionModule;
                bornCfg.DeadActionModule = actorCfg.DeadActionModule;
            }
            else
            {
                PapeGames.X3.LogProxy.LogErrorFormat("请联系策划，检查InterActorModelCfg, 配置了不存在的交互怪！ID={0}", bornCfg.InterActorModelCfgId);
            }

            bornCfg.PropertyID = spawnPoint.PropertyID;
            MonsterSpawner.HandleMonsterBornCfgAttrs(bornCfg);
        }
    }
}
