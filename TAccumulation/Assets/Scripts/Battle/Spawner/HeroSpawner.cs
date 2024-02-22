using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class HeroSpawner : ActorSpawner
    {
        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorMainState),
            typeof(AttributeOwner),
            typeof(HPOwner),
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
            typeof(ActorIdle),
            typeof(LookAt),
            typeof(SignalOwner),
            typeof(ActorEffectPlayer),
            typeof(ActorEventMgr),
            typeof(BattleTimer),
            typeof(HaloOwner),
            typeof(ActorShadowPlayer),
            typeof(ActorInput),
            typeof(ActorDamageMeters),
            typeof(ActorTaunt),
            typeof(ActorWeapon),
            typeof(EnergyOwner),
            typeof(ActorFrozen),
            typeof(ActorShield),
        };

        public HeroSpawner(Battle battle) : base(battle)
        {
        }

        public override Actor CreateActor(ActorCfg actorCfg, ActorCreateCfg createCfg)
        {
            TbUtil.TryGetCfg(createCfg.ModelCfg.SuitID, out ActorSuitCfg suitCfg);
            var actor = _GenerateActor(actorCfg, suitCfg, createCfg);
            actor.AddLocomotionCtrl();
            return actor;
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            var bornCfg = ObjectPoolUtility.GetActorBornCfg<RoleBornCfg>();
            var pointConfig = pointCfg as PointConfig;
            _GenerateCommonBornCfg(bornCfg, pointConfig);
            _GenerateHeroBornCfg(pointConfig, bornCfg);
            return bornCfg as T;
        }

        protected void _GenerateHeroBornCfg(PointConfig heroPoint, RoleBornCfg bornCfg)
        {
            if (heroPoint.PointType == PointType.Standard)
            {
                PapeGames.X3.LogProxy.LogError($"【CreateBornConfigByPointConfig】标椎点暂不支持创建出生数据 ID = {heroPoint.ID}");
                return;
            }
			
            // DONE: 预热阶段默认全开, 这样预热的全面.
            if (!Battle.Instance.isPreloading)
            {
                bornCfg.AutoCastPassiveSkill = false;
                bornCfg.AutoStartSkillCD = false;
                bornCfg.AutoStartEnergy = false;
                bornCfg.AutoStartAI = false;
            }
            
            if (heroPoint.RoleType == RoleType.Girl)
            {
                // DONE: 查女主武器皮肤表
                if (TbUtil.TryGetCfg<WeaponSkinConfig>(battle.arg.girlWeaponID, out var weaponSkinConfig))
                {
                    bornCfg.SkinID = weaponSkinConfig.WeaponSkinCfgID;

                    // DONE: 查女主武器Logic表
                    var weaponLogicCfg = TbUtil.GetCfg<WeaponLogicConfig>(weaponSkinConfig.WeaponLogicID);
                    if (weaponLogicCfg != null)
                    {
                        bornCfg.BornActionModule = weaponLogicCfg.BornActionModeID;
                        bornCfg.DeadActionModule = weaponLogicCfg.DeadActionModeID;
                    }
                }
                else
                {
                    PapeGames.X3.LogProxy.LogError($"请联系策划【清心】, WeaponSkinConfig表里没有Id={battle.arg.girlWeaponID}的数据");
                }
            }
            else if (heroPoint.RoleType == RoleType.Boy)
            {
                // DONE: 查男主皮肤表
                if (TbUtil.TryGetCfg(bornCfg.CfgID, out BoyCfg maleRoleCfg))
                {
                    if (TbUtil.TryGetCfg(bornCfg.SuitID, out MaleSuitConfig suitCfg))
                    {
                        bornCfg.SkinID = suitCfg.SkinEditorID;
                    }

                    bornCfg.BornActionModule = maleRoleCfg.BornActionModule;
                    bornCfg.DeadActionModule = maleRoleCfg.DeadActionModule;
                }
                else
                {
                    PapeGames.X3.LogProxy.LogError($"请联系程序, RoleCfg里没有Id={bornCfg.CfgID}的数据");
                }
            }
            
            bornCfg.GroupID = 0;
            if (battle.arg.cacheBornCfgs.TryGetValue(bornCfg.CfgID, out var cacheBornCfg))
            {
                bornCfg.Level = cacheBornCfg.Level;
                bornCfg.AnimatorCtrlName = cacheBornCfg.AnimatorCtrlName;
                if (null == cacheBornCfg.SkillSlots)
                {
                    bornCfg.SkillSlots = null;
                }
                else
                {
                    if (null == bornCfg.SkillSlots)
                    {
                        bornCfg.SkillSlots = new Dictionary<int, SkillSlotConfig>();
                    }

                    foreach (var skillSlot in cacheBornCfg.SkillSlots)
                    {
                        bornCfg.SkillSlots.Add(skillSlot.Key, skillSlot.Value);
                    }
                }
            }

            // 非离线模式
            if (battle.arg.startupType == BattleStartupType.Online)
            {
                _GenerateActorPropertyFromServer(bornCfg);
                return;
            }

            //数值模式
            if (battle.arg.isNumberMode)
            {
                if (battle.config.OfflineHeroPropertyIDs == null)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,单机男女主属性缺失配置");
                }
                else if (battle.config.OfflineHeroPropertyIDs.Length != 2)
                {
                    PapeGames.X3.LogProxy.LogError($"BattleLevel表,单机男女主属性配置长度错误:Length = {battle.config.OfflineHeroPropertyIDs.Length}");
                }
                else
                {
                    switch (heroPoint.RoleType)
                    {
                        case RoleType.Boy:
                            bornCfg.PropertyID = battle.config.OfflineHeroPropertyIDs[0];
                            break;
                        case RoleType.Girl:
                            bornCfg.PropertyID = battle.config.OfflineHeroPropertyIDs[1];
                            break;
                    }
                }
            }
            else
            {
                bornCfg.PropertyID = heroPoint.PropertyID;
            }

            if (heroPoint.RoleType == RoleType.Girl)
            {
                if (battle.config.GirlActiveSkills != null)
                {
                    foreach (S2Int s2Int in battle.config.GirlActiveSkills)
                    {
                        BattleUtil.AddSkillCfg(bornCfg.SkillSlots,s2Int.ID,SkillSlotType.Active, SkillSourceType.Normal,s2Int.Num);
                    }
                }
            }
            else if (heroPoint.RoleType == RoleType.Boy)
            {
                if (bornCfg.SkillSlots == null)
                {
                    bornCfg.SkillSlots = new Dictionary<int, SkillSlotConfig>();
                }
                else
                {
                    bornCfg.SkillSlots.Clear();
                }

                if (TbUtil.TryGetCfg(bornCfg.CfgID, out BoyCfg maleRoleCfg))
                {
                    foreach (var kSkillSlotConfig in maleRoleCfg.SkillSlots)
                    {
                        bornCfg.SkillSlots.Add(kSkillSlotConfig.Key, kSkillSlotConfig.Value);
                    }   
                }

                if (battle.config.BoyActiveSkills != null)
                {
                    foreach (S2Int s2Int in battle.config.BoyActiveSkills)
                    {
                        BattleUtil.AddSkillCfg(bornCfg.SkillSlots,s2Int.ID,SkillSlotType.Active, SkillSourceType.Normal,s2Int.Num);
                    }
                }
            }

            if (TbUtil.TryGetCfg(bornCfg.CfgID, out ActorCfg cfg))
            {
                bornCfg.Attrs.Add(AttrType.RigidPoint, ((RoleCfg)cfg).RigidPoint);
            }

            BattleEnv.LuaBridge.GenOfflineHeroBornCfg(bornCfg, heroPoint.RoleType);
        }
    }
}
