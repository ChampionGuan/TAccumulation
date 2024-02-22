using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class MonsterSpawner : ActorSpawner
    {
        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorMainState),
            typeof(AttributeOwner),
            typeof(ActorModel),
            typeof(SkillOwner),
            typeof(BuffOwner),
            typeof(AIOwner),
            typeof(ActorCommander),
            typeof(ColliderBehavior),
            typeof(ActorSequencePlayer),
            typeof(ActorHurt),
            typeof(ActorStateTag),
            typeof(TargetSelector),
            typeof(ActorWeak),
            typeof(LocomotionView),
            typeof(SignalOwner),
            typeof(ActorEffectPlayer),
            typeof(ActorEventMgr),
            typeof(BattleTimer),
            typeof(HaloOwner),
            typeof(ActorDamageMeters),
            typeof(ActorTaunt),
            typeof(HPOwner),
            typeof(LookAt),
            typeof(ActorFrozen),
            typeof(InterActorOwner),
            typeof(ActorShield),
        };

        public MonsterSpawner(Battle battle) : base(battle)
        {
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            var cfgID = bornCfg?.CfgID ?? actorCfgID.Value;
            if (TbUtil.TryGetCfg(cfgID, out MonsterCfg actorCfg))
            {
                return actorCfg;
            }

            PapeGames.X3.LogProxy.LogError($"【MonsterSpawner.CreateActor()】创建Actor失败,怪物configID:{cfgID}的配置信息不存在,请联系策划，进行检查!");
            return null;
        }

        public override Actor CreateActor(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            var actor = base.CreateActor(actorCfg, createCfg);
            actor.AddLocomotionCtrl();
            return actor;
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            var bornCfg = ObjectPoolUtility.GetActorBornCfg<RoleBornCfg>();
            var pointConfig = pointCfg as ActorPointBase;
            _GenerateCommonBornCfg(bornCfg, pointConfig);
            _GenerateMonsterBornCfg((SpawnPointConfig) pointConfig, bornCfg);
            return bornCfg as T;
        }

        protected void _GenerateMonsterBornCfg(SpawnPointConfig spawnPoint, RoleBornCfg bornCfg)
        {
            bornCfg.GroupID = spawnPoint.GroupID;
            bornCfg.AIStatus = spawnPoint.BehaviorType;
            bornCfg.IsAIActive = spawnPoint.IsActive;
            bornCfg.ControlBornPerform = spawnPoint.EnableBornCamera;
            bornCfg.MonsterHudControl = spawnPoint.HudControl;
            bornCfg.MonsterHudIsTop = spawnPoint.HudIsTop;
            bornCfg.MonsterHudIsHead = spawnPoint.HudIsHead;
            bornCfg.EnableBossCamera = spawnPoint.EnableBossCamera;

            if (TbUtil.TryGetCfg(bornCfg.CfgID, out ActorCfg actorCfg))
            {
                bornCfg.BornActionModule = actorCfg.BornActionModule;
                bornCfg.DeadActionModule = actorCfg.DeadActionModule;
                bornCfg.HurtLieDeadActionModule = actorCfg is MonsterCfg cfg ? cfg.HurtLieDeadActionModule : 0;
                bornCfg.IsShowArrowIcon = spawnPoint.IsShowArrowIcon || actorCfg.SubType == (int) MonsterType.Boss;
            }
            else
            {
                PapeGames.X3.LogProxy.LogErrorFormat("请联系策划，检查种怪配置, 配置了不存在的怪！ID={0}", bornCfg.CfgID);
            }

            //数值模式
            if (battle.arg.isNumberMode)
            {
                if (battle.config.MonsterUIDs == null)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,没有填写怪物UID");
                }
                else if (battle.config.MonsterPropertyIDs == null)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,没有填写怪物属性ID");
                }
                else if (battle.config.MonsterUIDs.Length != battle.config.MonsterPropertyIDs.Length)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,怪物ID数量与属性ID数量不一致");
                }
                else
                {
                    for (var i = 0; i < battle.config.MonsterUIDs.Length; i++)
                    {
                        if (battle.config.MonsterUIDs[i] != bornCfg.SpawnID) continue;
                        bornCfg.PropertyID = battle.config.MonsterPropertyIDs[i];
                        break;
                    }
                }
            }
            else
            {
                bornCfg.PropertyID = spawnPoint.PropertyID;
            }

            MonsterSpawner.HandleMonsterBornCfgAttrs(bornCfg);
        }

        public static void HandleMonsterBornCfgAttrs(RoleBornCfg bornCfg)
        {
            var monsterProperty = TbUtil.GetCfg<MonsterProperty>(bornCfg.PropertyID);
            if (monsterProperty == null)
            {
                return;
            }

            // DONE: 怪物等级初始化.
            bornCfg.Level = monsterProperty.Level;
            bornCfg.Attrs.Add(AttrType.RigidPoint, monsterProperty.RigidPoint);
            bornCfg.Attrs.Add(AttrType.FinalDmgAddRate, monsterProperty.FinalDmgAddRate);
            bornCfg.Attrs.Add(AttrType.MoveSpeed, 1000);
            bornCfg.Attrs.Add(AttrType.TurnSpeed, 150);
            bornCfg.Attrs.Add(AttrType.HpShield, 0);
            bornCfg.Attrs.Add(AttrType.HpShieldHurtAdd, 0);
            bornCfg.Attrs.Add(AttrType.HpShieldHurtDec, 0);
            bornCfg.Attrs.Add(AttrType.WeakPoint, 0);
            bornCfg.Attrs.Add(AttrType.FinalDamageAdd, 0);
            bornCfg.Attrs.Add(AttrType.FinalDamageDec, 0);
            bornCfg.Attrs.Add(AttrType.IgnoreDefence, 0);
            bornCfg.Attrs.Add(AttrType.RootMotionMutiplierXZ, 1);
            bornCfg.Attrs.Add(AttrType.CoreDamageRatio, 1);
            if(TbUtil.TryGetCfg(bornCfg.CfgID, out MonsterCfg monsterCfg))
            {
                bornCfg.Attrs.Add(AttrType.ShieldRecoverTime, monsterCfg.WeakRecoverTime);
            }
            
            var monsterBase = TbUtil.GetCfg<MonsterBase>(monsterProperty.NumType, monsterProperty.Level);
            if (monsterBase == null)
            {
                return;
            }

            float maxHp = monsterBase.MaxHP * (monsterProperty.MaxHPRate / 1000f);
            bornCfg.Attrs.Add(AttrType.MaxHP, maxHp);
            bornCfg.Attrs.Add(AttrType.HP, maxHp);
            bornCfg.Attrs.Add(AttrType.PhyAttack, monsterBase.PhyAttack * monsterProperty.PhyAttackRate / 1000);
            bornCfg.Attrs.Add(AttrType.PhyDefence, monsterBase.PhyDefence * monsterProperty.PhyDefenceRate / 1000);
            bornCfg.Attrs.Add(AttrType.CritVal, monsterBase.CritVal * monsterProperty.CritValRate / 1000);
            bornCfg.Attrs.Add(AttrType.CritHurtAdd, monsterBase.CritHurtAdd * monsterProperty.CritHurtAddRate / 1000);
            bornCfg.Attrs.Add(AttrType.ElementRatio, monsterBase.ElementRatio * monsterProperty.ElementRatioRate / 1000);
        }
    }
}
