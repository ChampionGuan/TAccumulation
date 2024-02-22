using System.Collections.Generic;

namespace X3Battle
{
    public static partial class TbUtil
    {
        public static MonsterBase GetMonsterBase(int id, int level)
        {
            return GetCfg<MonsterBase>(id, level);
        }
        
        public static HitParamConfig GetHitParamConfig(int id, int level, int layer)
        {
            int subKey = level * 1000 + layer;
            return GetCfg<HitParamConfig>(id, subKey);
        }

        public static HitParamConfig GetHitParamConfigByHitId(int hitParamId)
        {
            foreach (var hitParamConfigDic in hitParamConfigs)
            {
                foreach (var hitParamConfigItem in hitParamConfigDic.Value)
                {
                    HitParamConfig hitParamConfig = hitParamConfigItem.Value;
                    if (hitParamConfig.HitParamID == hitParamId)
                    {
                        return hitParamConfig;
                    }
                }
            }
            return null;
        }

        public static BuffLevelConfig GetBuffLevelConfig(int id, int level,int layer,bool errorLog = true)
        {
            int subKey = level * 1000 + layer;
            BuffLevelConfig buffLevelConfig = GetCfg<BuffLevelConfig>(id, subKey);
            if (buffLevelConfig == null && errorLog)
            {
                PapeGames.X3.LogProxy.LogError($"BuffLevelConfig表没有配置对应level或layer，buffID {id}，level {level}， layer {layer}联系策划卡宝宝");
            }
            return buffLevelConfig;
        }
        
        public static BattleLevelConfig GetBattleLevelConfig(int id)
        {
            return GetCfg<BattleLevelConfig>(id);
        }

        public static MonsterProperty GetMonsterProperty(int id)
        {
            return GetCfg<MonsterProperty>(id);
        }

        public static ActorCfg GetActorCfg(int id)
        {
            return GetCfg<ActorCfg>(id);
        }
        
        public static WeaponLogicConfig GetWeaponLogicConfigBySkinId(int id)
        {
            WeaponSkinConfig weaponSkinConfig = GetCfg<WeaponSkinConfig>(id);
            if (weaponSkinConfig == null)
            {
                return null;
            }
            return GetWeaponLogicConfig(weaponSkinConfig.WeaponLogicID);
        }

        public static WeaponLogicConfig GetWeaponLogicConfig(int id)
        {
            return GetCfg<WeaponLogicConfig>(id);
        }

        public static WeaponSkinConfig GetWeaponSkinConfig(int id)
        {
            return GetCfg<WeaponSkinConfig>(id);
        }

        public static BoyCfg GetBoyCfg(int id)
        {
            return GetCfg<BoyCfg>(id);
        }
        
        public static HeroCfg GetGirlCfg(int id)
        {
            return GetCfg<HeroCfg>(id);
        }

        public static BattleGuide GetBattleGuide(int id)
        {
            return GetCfg<BattleGuide>(id);
        }

        public static DialogueConfig GetDialogueConfig(int id)
        {
            return GetCfg<DialogueConfig>(id);
        }

        public static BattleBossIntroduction GetBattleBossIntroduction(int id)
        {
            return GetCfg<BattleBossIntroduction>(id);
        }
        
        public static BuffLevelConfig GetBuffLevelConfig(X3Buff buff)
        {
            if (buff == null)
            {
                return null;
            }

            return GetBuffLevelConfig(buff.ID, buff.level, buff.layer);
        }
        
        // lua端使用
        public static SkillCfg GetSkillCfg(int id)
        {
            return GetCfg<SkillCfg>(id);
        }
        
        /// <summary>
        /// 获取buff参数
        /// </summary>
        /// <param name="buffLevelConfig"></param>
        /// <param name="mathParam"></param>
        /// <returns></returns>
        public static float[] GetBuffMathParam(BuffLevelConfig buffLevelConfig, string mathParam)
        {
            return MpUtil.GetBuffMathParam(buffLevelConfig, mathParam);
        }

        /// <summary>
        /// lua端在用，勿删，获取女主默认角色配置
        /// </summary>
        public static int GetGirlDefaultCfgID()
        {
            // 默认女主角色配置ID为1,与策划约定！！
            return 1;
        }

        /// <summary>
        /// lua端在用，勿删，通过套装ID,获取男主默认角色配置
        /// </summary>
        /// <param name="suitID"></param>
        /// <param name="cfgIDs"></param>
        public static int GetBoyDefaultCfgIDBySuitID(int suitID)
        {
            // 默认男主角色配置即为ScoreID,与策划约定！！
            return !TryGetCfg(suitID, out ActorSuitCfg suitCfg) ? suitID : suitCfg.ScoreID;
        }

        /// <summary>
        /// 通过套装ID,获取角色的配置ID
        /// </summary>
        /// <param name="suitID"></param>
        /// <param name="outCfgIDs"></param>
        public static void GetActorCfgIDsBySuitID(int suitID, List<int> outCfgIDs)
        {
            if (null == outCfgIDs || !TryGetCfg(suitID, out ActorSuitCfg cfg))
            {
                return;
            }

            outCfgIDs.Clear();
            foreach (var actorCfg in actorCfgs.Values)
            {
                if (!(actorCfg is HeroCfg heroCfg)) continue;
                if (heroCfg.ScoreID == cfg.ScoreID)
                {
                    outCfgIDs.Add(actorCfg.ID);
                }
            }
        }

        /// <summary>
        /// 通过配置ID,获取角色的套装ID
        /// </summary>
        /// <param name="suitID"></param>
        /// <param name="actorCfgIDs"></param>
        public static void GetActorSuitIDsByCfgID(int cfgID, List<int> outSuitIDs)
        {
            if (null == outSuitIDs || !TryGetCfg(cfgID, out ActorCfg cfg))
            {
                return;
            }

            outSuitIDs.Clear();
            if (!(cfg is HeroCfg heroCfg)) return;
            foreach (var suitCfg in actorSuitCfgs.Values)
            {
                if (suitCfg.ScoreID == heroCfg.ScoreID)
                {
                    outSuitIDs.Add(suitCfg.SuitID);
                }
            }
        }

        /// <summary>
        /// 获取属性最小值
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static float GetAttrMinValue(AttrType type)
        {
            return _proxy.GetAttrMinValue(type);
        }

        // 获取技能等级配置
        public static SkillLevelCfg GetSkillLevelCfg(int id, int level)
        {
            return GetCfg<SkillLevelCfg>(id, level);
        }
        
        //lua端使用
        public static RogueEntriesConfig GetRogueEntriesConfig(int id)
        {
            return GetCfg<RogueEntriesConfig>(id);
        }
        
        public static void InitByResModule(ResModule resModule)
        {
            // todo: 皮肤暂时还没有preload by:sanxi
            if (resModule.ownerType == nameof(BuffResAnalyzer))
            {
                GetCfg<BuffCfg>(resModule.id);
            }
            else if (resModule.ownerType == nameof(HaloAnalyzer))
            {
                GetCfg<HaloCfg>(resModule.id);
            }
            else if (resModule.ownerType == nameof(MagicFieldAnalyzer))
            {
                GetCfg<MagicFieldCfg>(resModule.id);
            }
            else if (resModule.ownerType == nameof(MissileAnalyzer))
            {
                GetCfg<MissileCfg>(resModule.id);
            }
            else if (resModule.ownerType == nameof(DamageBoxAnalyzer))
            {
                GetCfg<DamageBoxCfg>(resModule.id);
            }

            foreach (var child in resModule.children)
            {
                InitByResModule(child);
            }
        }
    }
}