using System;
using System.Collections.Generic;
using ParadoxNotion;
using UnityEngine;

namespace X3Battle
{
    public class MachineSpawner : ActorSpawner
    {
        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorModel),
            typeof(ActorEffectPlayer),
            typeof(MachineFlow),
            typeof(ColliderBehavior),
            typeof(ActorSequencePlayer),
            typeof(BattleTimer),
            typeof(SkillOwner),
        };

        public MachineSpawner(Battle battle) : base(battle)
        {
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            var cfgID = bornCfg?.CfgID ?? actorCfgID.Value;
            if (TbUtil.TryGetCfg(cfgID, out MachineCfg actorCfg))
            {
                return actorCfg;
            }

            PapeGames.X3.LogProxy.LogError($"[MachineSpawner.CreateActor()]创建Actor失败,(机关configID={cfgID}) 配置信息不存在, 请检查!");
            return null;
        }

        public override Actor CreateActor(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            var actor = base.CreateActor(actorCfg, createCfg);
            if ((actorCfg as MachineCfg).NeedProperty == 1) // 此种需要属性
            {
                actor.entity.AddComponent<AttributeOwner>();
            }

            return actor;
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            if (!(pointCfg is MachineConfig cfg))
            {
                PapeGames.X3.LogProxy.LogErrorFormat("机关诞生失败，config 类型：{0} 非MachineConfig", pointCfg.GetType());
                return null;
            }

            var bornCfg = ObjectPoolUtility.GetActorBornCfg<MachineBornCfg>();
            bornCfg.MachineType = cfg.MachineType;
            _GenerateCommonBornCfg(bornCfg, cfg);
            switch (cfg.MachineType)
            {
                case MachineType.Door:
                    bornCfg.State = (int) cfg.Door.State;
                    break;
                case MachineType.Switch:
                    bornCfg.State = (int) cfg.Switch.State;
                    break;
                case MachineType.AttackBasic:
                    bornCfg.State = (int) cfg.AttackBasic.State;
                    break;
            }

            if (!TbUtil.TryGetCfg(bornCfg.CfgID, out MachineCfg machineActorCfg))
            {
                PapeGames.X3.LogProxy.LogErrorFormat("机关初始化属性失败，【MachineTemple】表中没有key：{0} 策划：【五当】", bornCfg.CfgID);
                return bornCfg as T;
            }

            bornCfg.AnimatorCtrlName = machineActorCfg.AnimatorCtrlName;
            bornCfg.FlowName = machineActorCfg.FlowName;
            if (machineActorCfg.NeedProperty != 1) // 此种机关不需要属性
            {
                return bornCfg as T;
            }

            _GenerateMachineProperty(cfg, bornCfg);

            return bornCfg as T;
        }

        protected void _GenerateMachineProperty(MachineConfig spawnPoint, MachineBornCfg bornCfg)
        {
            bornCfg.GroupID = spawnPoint.GroupID;
            //数值模式
            if (battle.arg.isNumberMode)
            {
                if (battle.config.MachineUIDs == null)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,没有填写机关UID");
                    return;
                }

                if (battle.config.MachinePropertyIDs == null)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,没有填写机关属性ID");
                    return;
                }

                if (battle.config.MachineUIDs.Length != battle.config.MachinePropertyIDs.Length)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,机关ID数量与属性ID数量不一致");
                    return;
                }

                for (var i = 0; i < battle.config.MachineUIDs.Length; i++)
                {
                    if (battle.config.MachineUIDs[i] != bornCfg.SpawnID) continue;
                    bornCfg.PropertyID = battle.config.MachinePropertyIDs[i];
                    break;
                }
            }
            else
            {
                bornCfg.PropertyID = spawnPoint.PropertyID;
            }

            // 机关的属性配置，和怪物的属性配置表是同一套
            var monsterProperty = TbUtil.GetCfg<MonsterProperty>(bornCfg.PropertyID);
            if (monsterProperty == null)
            {
                PapeGames.X3.LogProxy.LogError($"【机关】【_SetProperty】MonsterProperty获取失败PropertyID={bornCfg.PropertyID}");
                return;
            }

            // DONE: 机关等级初始化.
            bornCfg.Level = monsterProperty.Level;
            bornCfg.Attrs.Add(AttrType.RigidPoint, monsterProperty.RigidPoint);
            bornCfg.Attrs.Add(AttrType.FinalDmgAddRate, monsterProperty.FinalDmgAddRate);
            bornCfg.Attrs.Add(AttrType.MoveSpeed, 1000);
            bornCfg.Attrs.Add(AttrType.TurnSpeed, 150);
            bornCfg.Attrs.Add(AttrType.HpShield, 0);
            bornCfg.Attrs.Add(AttrType.HpShieldHurtAdd, 0);
            bornCfg.Attrs.Add(AttrType.HpShieldHurtDec, 0);
            bornCfg.Attrs.Add(AttrType.WeakPoint, 0);
            bornCfg.Attrs.Add(AttrType.RootMotionMutiplierXZ, 1);
            bornCfg.Attrs.Add(AttrType.RootMotionMutiplierY, 1);
            
            var monsterBase = TbUtil.GetCfg<MonsterBase>(monsterProperty.NumType, monsterProperty.Level);
            if (monsterBase == null)
            {
                return;
            }

            var maxHp = monsterBase.MaxHP * monsterProperty.MaxHPRate / 1000;
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
