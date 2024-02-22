using System.Collections.Generic;

namespace X3Battle
{
    public static partial class TbUtil
    {
        #region --excel导出的配置--
        public static BattleConsts battleConsts => GetCfgs<BattleConsts>();
        public static Dictionary<FactionType, BattleFactionConfig> battleFactionConfigs => GetCfgs<BattleFactionConfigs>()?.battleFactionConfigs;
        public static Dictionary<int, BattleGuide> battleGuides => GetCfgs<BattleGuides>()?.battleGuides;
        public static Dictionary<int, BattleLevelConfig> battleLevelConfigs => GetCfgs<BattleLevelConfigs>()?.battleLevelConfigs;
        public static Dictionary<int, BattleRogueConfig> battleRogueConfigs => GetCfgs<BattleRogueConfigs>()?.battleRogueConfigs;
        public static Dictionary<int, BattleRogueLevelConfig> battleRogueLevelConfigs => GetCfgs<BattleRogueLevelConfigs>()?.battleRogueLevelConfigs;
        public static Dictionary<int, BattleSummon> battleSummons => GetCfgs<BattleSummons>()?.battleSummons;
        public static Dictionary<int, Dictionary<int, BuffLevelConfig>> buffLevelConfigs => GetCfgs<BuffLevelConfigs>()?.buffLevelConfigs;
        public static Dictionary<int, DialogueConfig> dialogueConfigs => GetCfgs<DialogueConfigs>()?.dialogueConfigs;
        public static Dictionary<int, DialogueKeyConfig> dialogueKeyConfigs => GetCfgs<DialogueKeyConfigs>()?.dialogueKeyConfigs;
        public static Dictionary<int, FXConfig> fxConfigs => GetCfgs<FXConfigs>()?.fxConfigs;
        public static Dictionary<int, Dictionary<int, GroundMoveFx>> groundMoveFxs => GetCfgs<GroundMoveFxs>()?.groundMoveFxs;
        public static Dictionary<int, Dictionary<int, HitParamConfig>> hitParamConfigs => GetCfgs<HitParamConfigs>()?.hitParamConfigs;
        public static Dictionary<int, Dictionary<int, HurtStateMapConfig>> hurtStateMapConfigs => GetCfgs<HurtStateMapConfigs>()?.hurtStateMapConfigs;
        public static Dictionary<int, Dictionary<int, MonsterBase>> monsterBases => GetCfgs<MonsterBases>()?.monsterBases;
        public static Dictionary<int, MonsterProperty> monsterPropertys => GetCfgs<MonsterPropertys>()?.monsterPropertys;
        public static Dictionary<int, PerformConfig> performConfigs => GetCfgs<PerformConfigs>()?.performConfigs;
        public static Dictionary<int, StateToTimeline> stateToTimelines => GetCfgs<StateToTimelines>()?.stateToTimelines;
        public static Dictionary<int, WeaponLogicConfig> weaponLogicConfigs => GetCfgs<WeaponLogicConfigs>()?.weaponLogicConfigs;
        public static Dictionary<int, WeaponSkinConfig> weaponSkinConfigs => GetCfgs<WeaponSkinConfigs>()?.weaponSkinConfigs;
        public static Dictionary<int, Dictionary<BuffConflictType, BuffTagConflictConfig>> buffTagConflictConfigs => GetCfgs<BuffTagConflictConfigs>()?.buffTagConflictConfigs;
        public static Dictionary<int, BattleManStrategy> battleManStrategys => GetCfgs<BattleManStrategys>()?.battleManStrategys;
        public static Dictionary<int, BattleWomanStrategy> battleWomanStrategys => GetCfgs<BattleWomanStrategys>()?.battleWomanStrategys;
        public static Dictionary<string, Dictionary<int, HurtMaterialConfig>> hurtMaterialConfigs => GetCfgs<HurtMaterialConfigs>()?.hurtMaterialConfigs;
        public static Dictionary<int, SkillPublicCdCfg> skillPublicCdCfgs => GetCfgs<SkillPublicCdCfgs>()?.skillPublicCdCfgs;
        public static Dictionary<int, BattleBossIntroduction> battleBossIntroductions => GetCfgs<BattleBossIntroductions>()?.battleBossIntroductions;
        public static Dictionary<int, BattleTag> battleTags => GetCfgs<BattleTags>()?.battleTags;
        public static Dictionary<int, MaleSuitConfig> boySuitCfgs => GetCfgs<MaleSuitConfigs>()?.maleSuitConfigs;
        public static Dictionary<int, FemaleSuitConfig> girlSuitCfgs => GetCfgs<FemaleSuitConfigs>()?.femaleSuitConfigs;
        public static Dictionary<int, DialogueNameConfig> dialogueNameConfigs => GetCfgs<DialogueNameConfigs>()?.dialogueNameConfigs;
        public static Dictionary<int, BattleSceneCameraCollider> battleSceneCameraColliders => GetCfgs<BattleSceneCameraColliders>()?.battleSceneCameraColliders;
        public static Dictionary<int, InterActorComponentConfig> interActorComponentCfgs => GetCfgs<InterActorComponentConfigs>()?.interActorComponentConfigs;
        public static Dictionary<int, Dictionary<int, SkillLevelCfg>> skillLevelCfgs => GetCfgs<SkillLevelCfgs>()?.skillLevelCfgs;
		public static Dictionary<int, RogueEntriesConfig> rogueEntriesConfigs => GetCfgs<RogueEntriesConfigs>()?.rogueEntriesConfigs;
        public static Dictionary<int, RogueEntriesLibraryConfig> rogueEntriesLibraryConfigs => GetCfgs<RogueEntriesLibraryConfigs>()?.rogueEntriesLibraryConfigs;
        
        public static Dictionary<int, InterActorModelConfig> interActorModelCfgs => GetCfgs<InterActorModelConfigs>()?.interActorModelConfigs;

        #endregion
    }
}
