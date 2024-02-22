using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class TbCfgProxy : TbCfgProxyBase
    {
        private static TbCfgProxy _instance;
        public static TbCfgProxy instance => _instance ?? (_instance = new TbCfgProxy());
        /// <summary>
        /// 此类型对应的配置集获取函数
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<bool, object>> _typeToGetCfgsFunc { get;  } =  new Dictionary<Type, Func<bool, object>>
        {
            //Excel类型配置
            [typeof(BattleConsts)] = onlyFromCache => instance._GetExcelCfgs<BattleConsts>("AutoGen/BattleConsts", onlyFromCache),
            [typeof(BattleFactionConfigs)] = onlyFromCache => instance._GetExcelCfgs<BattleFactionConfigs>("AutoGen/BattleFactionConfig", onlyFromCache),
            [typeof(BattleGuides)] = onlyFromCache => instance._GetExcelCfgs<BattleGuides>("AutoGen/BattleGuide", onlyFromCache),
            [typeof(BattleLevelConfigs)] = onlyFromCache => instance._GetExcelCfgs<BattleLevelConfigs>("AutoGen/BattleLevelConfig", onlyFromCache),
            [typeof(BattleRogueConfigs)] = onlyFromCache => instance._GetExcelCfgs<BattleRogueConfigs>("AutoGen/BattleRogueConfig", onlyFromCache),
            [typeof(BattleRogueLevelConfigs)] = onlyFromCache => instance._GetExcelCfgs<BattleRogueLevelConfigs>("AutoGen/BattleRogueLevelConfig", onlyFromCache),
            [typeof(BattleSummons)] = onlyFromCache => instance._GetExcelCfgs<BattleSummons>("AutoGen/BattleSummon", onlyFromCache),
            [typeof(BuffLevelConfigs)] = onlyFromCache => instance._GetExcelCfgs<BuffLevelConfigs>("AutoGen/BuffLevelConfig", onlyFromCache),
            [typeof(DialogueConfigs)] = onlyFromCache => instance._GetExcelCfgs<DialogueConfigs>("AutoGen/DialogueConfig", onlyFromCache),
            [typeof(DialogueKeyConfigs)] = onlyFromCache => instance._GetExcelCfgs<DialogueKeyConfigs>("AutoGen/DialogueKeyConfig", onlyFromCache),
            [typeof(FXConfigs)] = onlyFromCache => instance._GetExcelCfgs<FXConfigs>("AutoGen/FXConfig", onlyFromCache),
            [typeof(GroundMoveFxs)] = onlyFromCache => instance._GetExcelCfgs<GroundMoveFxs>("AutoGen/GroundMoveFx", onlyFromCache),
            [typeof(HitParamConfigs)] = onlyFromCache => instance._GetExcelCfgs<HitParamConfigs>("AutoGen/HitParamConfig", onlyFromCache),
            [typeof(HurtStateMapConfigs)] = onlyFromCache => instance._GetExcelCfgs<HurtStateMapConfigs>("AutoGen/HurtStateMapConfig", onlyFromCache),
            [typeof(MonsterBases)] = onlyFromCache => instance._GetExcelCfgs<MonsterBases>("AutoGen/MonsterBase", onlyFromCache),
            [typeof(MonsterPropertys)] = onlyFromCache => instance._GetExcelCfgs<MonsterPropertys>("AutoGen/MonsterProperty", onlyFromCache),
            [typeof(PerformConfigs)] = onlyFromCache => instance._GetExcelCfgs<PerformConfigs>("AutoGen/PerformConfig", onlyFromCache),
            [typeof(StateToTimelines)] = onlyFromCache => instance._GetExcelCfgs<StateToTimelines>("AutoGen/StateToTimeline", onlyFromCache),
            [typeof(WeaponLogicConfigs)] = onlyFromCache => instance._GetExcelCfgs<WeaponLogicConfigs>("AutoGen/WeaponLogicConfig", onlyFromCache),
            [typeof(WeaponSkinConfigs)] = onlyFromCache => instance._GetExcelCfgs<WeaponSkinConfigs>("AutoGen/WeaponSkinConfig", onlyFromCache),
            [typeof(BuffTagConflictConfigs)] = onlyFromCache => instance._GetExcelCfgs<BuffTagConflictConfigs>("AutoGen/BuffTagConflictConfig", onlyFromCache),
            [typeof(BattleManStrategys)] = onlyFromCache => instance._GetExcelCfgs<BattleManStrategys>("AutoGen/BattleManStrategy", onlyFromCache),
            [typeof(BattleWomanStrategys)] = onlyFromCache => instance._GetExcelCfgs<BattleWomanStrategys>("AutoGen/BattleWomanStrategy", onlyFromCache),
            [typeof(HurtMaterialConfigs)] = onlyFromCache => instance._GetExcelCfgs<HurtMaterialConfigs>("AutoGen/HurtMaterialConfig", onlyFromCache),
            [typeof(SkillPublicCdCfgs)] = onlyFromCache => instance._GetExcelCfgs<SkillPublicCdCfgs>("AutoGen/SkillPublicCdCfg", onlyFromCache),
            [typeof(BattleBossIntroductions)] = onlyFromCache => instance._GetExcelCfgs<BattleBossIntroductions>("AutoGen/BattleBossIntroduction", onlyFromCache),
            [typeof(BattleTags)] = onlyFromCache => instance._GetExcelCfgs<BattleTags>("AutoGen/BattleTag", onlyFromCache),
            [typeof(MaleSuitConfigs)] = onlyFromCache => instance._GetExcelCfgs<MaleSuitConfigs>("AutoGen/MaleSuitConfig", onlyFromCache),
            [typeof(FemaleSuitConfigs)] = onlyFromCache => instance._GetExcelCfgs<FemaleSuitConfigs>("AutoGen/FemaleSuitConfig", onlyFromCache),
            [typeof(DialogueNameConfigs)] = onlyFromCache => instance._GetExcelCfgs<DialogueNameConfigs>("AutoGen/DialogueNameConfig", onlyFromCache),
            [typeof(BattleSceneCameraColliders)] = onlyFromCache => instance._GetExcelCfgs<BattleSceneCameraColliders>("AutoGen/BattleSceneCameraCollider", onlyFromCache),
            [typeof(InterActorComponentConfigs)] = onlyFromCache => instance._GetExcelCfgs<InterActorComponentConfigs>("AutoGen/InterActorComponentConfig", onlyFromCache),
			[typeof(RogueEntriesConfigs)] = onlyFromCache => instance._GetExcelCfgs<RogueEntriesConfigs>("AutoGen/RogueEntriesConfig", onlyFromCache),
            [typeof(RogueEntriesLibraryConfigs)] = onlyFromCache => instance._GetExcelCfgs<RogueEntriesLibraryConfigs>("AutoGen/RogueEntriesLibraryConfig", onlyFromCache),
            [typeof(ActorCfgs)] = onlyFromCache => instance._GetExcelCfgs<ActorCfgs>("Process/ActorCfg", onlyFromCache),
            [typeof(SkillLevelCfgs)] = onlyFromCache => instance._GetExcelCfgs<SkillLevelCfgs>("Process/SkillLevelCfg", onlyFromCache),
            //[typeof(InterActorModelConfigs)] = onlyFromCache => instance._GetExcelCfgs<InterActorModelConfigs>("AutoGen/InterActorModelConfig", onlyFromCache),
            //后处理类型配置
            [typeof(Dictionary<int, ActorCfg>)] = onlyFromCache => instance._GetPostProcessCfgs<Dictionary<int, ActorCfg>>(onlyFromCache),
            [typeof(Dictionary<int, ActorSuitCfg>)] = onlyFromCache => instance._GetPostProcessCfgs<Dictionary<int, ActorSuitCfg>>(onlyFromCache),
            [typeof(Dictionary<AttrType, float>)] = onlyFromCache => instance._GetPostProcessCfgs<Dictionary<AttrType, float>>(onlyFromCache),
            //动态类型配置
            [typeof(Dictionary<int, SkillCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, SkillCfg>>(onlyFromCache),
            [typeof(Dictionary<int, MissileCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, MissileCfg>>(onlyFromCache),
            [typeof(Dictionary<int, RogueEntryCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, RogueEntryCfg>>(onlyFromCache),
            [typeof(Dictionary<int, DamageBoxCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, DamageBoxCfg>>(onlyFromCache),
            [typeof(Dictionary<int, ActionModuleCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, ActionModuleCfg>>(onlyFromCache),
            [typeof(Dictionary<int, SkinCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, SkinCfg>>(onlyFromCache),
            [typeof(Dictionary<int, BuffCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, BuffCfg>>(onlyFromCache),
            [typeof(Dictionary<int, MagicFieldCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, MagicFieldCfg>>(onlyFromCache),
            [typeof(Dictionary<int, ItemCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, ItemCfg>>(onlyFromCache),
            [typeof(Dictionary<int, HaloCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, HaloCfg>>(onlyFromCache),
            [typeof(Dictionary<int, StageConfig>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, StageConfig>>(onlyFromCache),
            [typeof(Dictionary<int, TriggerCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, TriggerCfg>>(onlyFromCache),
            [typeof(Dictionary<string, ModelInfo>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<string, ModelInfo>>(onlyFromCache),
            //调试类型配置
            [typeof(BattleEditorConfigs)] = onlyFromCache => instance._GetDebugCfgs<BattleEditorConfigs>(debugCfgFiles[0], onlyFromCache),
            [typeof(BattleEditorScenes)] = onlyFromCache => instance._GetDebugCfgs<BattleEditorScenes>(debugCfgFiles[1], onlyFromCache),
            [typeof(BuffConflictTags)] = onlyFromCache => instance._GetDebugCfgs<BuffConflictTags>(debugCfgFiles[2], onlyFromCache),
            [typeof(BattleBuffMultipleTags)] = onlyFromCache => instance._GetDebugCfgs<BattleBuffMultipleTags>(debugCfgFiles[3], onlyFromCache),
            [typeof(BattleSkillTags)] = onlyFromCache => instance._GetDebugCfgs<BattleSkillTags>(debugCfgFiles[4], onlyFromCache),
            [typeof(DebugTextCfgs)] = onlyFromCache => instance._GetDebugCfgs<DebugTextCfgs>(debugCfgFiles[5], onlyFromCache),
            [typeof(BattleActorShowTags)] = onlyFromCache => instance._GetDebugCfgs<BattleActorShowTags>(debugCfgFiles[6], onlyFromCache),
            [typeof(EntriesTags)] = onlyFromCache => instance._GetDebugCfgs<EntriesTags>(debugCfgFiles[7], onlyFromCache),
            [typeof(BattleActionTags)] = onlyFromCache => instance._GetDebugCfgs<BattleActionTags>(debugCfgFiles[8], onlyFromCache),
        };

        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// Dictionary AttrType, float、DebugTextCfgs  不具备通用性，暂不予支持
        /// </summary>
        protected override Dictionary<Type, Func<ValueType, bool, object>> _typeToGetCfgByValueKeyFunc { get;  } = new Dictionary<Type, Func<ValueType, bool, object>>
        {
            //Excel类型配置
            [typeof(BattleFactionConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((FactionType)id, instance.GetCfgs<BattleFactionConfigs>(onlyFromCache)?.battleFactionConfigs),
            [typeof(BattleGuide)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleGuides>(onlyFromCache)?.battleGuides),
            [typeof(BattleLevelConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleLevelConfigs>(onlyFromCache)?.battleLevelConfigs),
            [typeof(BattleRogueConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleRogueConfigs>(onlyFromCache)?.battleRogueConfigs),
            [typeof(BattleRogueLevelConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleRogueLevelConfigs>(onlyFromCache)?.battleRogueLevelConfigs),
            [typeof(BattleSummon)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleSummons>(onlyFromCache)?.battleSummons),
            [typeof(Dictionary<int, BuffLevelConfig>)] = (id, onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BuffLevelConfigs>(onlyFromCache)?.buffLevelConfigs),
            [typeof(DialogueConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<DialogueConfigs>(onlyFromCache)?.dialogueConfigs),
            [typeof(DialogueKeyConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<DialogueKeyConfigs>(onlyFromCache)?.dialogueKeyConfigs),
            [typeof(FXConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<FXConfigs>(onlyFromCache)?.fxConfigs),
            [typeof(Dictionary<int, GroundMoveFx>)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<GroundMoveFxs>(onlyFromCache)?.groundMoveFxs),
            [typeof(Dictionary<int, HitParamConfig>)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<HitParamConfigs>(onlyFromCache)?.hitParamConfigs),
            [typeof(Dictionary<int, HurtStateMapConfig>)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<HurtStateMapConfigs>(onlyFromCache)?.hurtStateMapConfigs),
            [typeof(Dictionary<int, MonsterBase>)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<MonsterBases>(onlyFromCache)?.monsterBases),
            [typeof(MonsterProperty)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<MonsterPropertys>(onlyFromCache)?.monsterPropertys),
            [typeof(PerformConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<PerformConfigs>(onlyFromCache)?.performConfigs),
            [typeof(StateToTimeline)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<StateToTimelines>(onlyFromCache)?.stateToTimelines),
            [typeof(WeaponLogicConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<WeaponLogicConfigs>(onlyFromCache)?.weaponLogicConfigs),
            [typeof(WeaponSkinConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<WeaponSkinConfigs>(onlyFromCache)?.weaponSkinConfigs),
            [typeof(Dictionary<BuffConflictType, BuffTagConflictConfig>)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BuffTagConflictConfigs>(onlyFromCache)?.buffTagConflictConfigs),
            [typeof(BattleManStrategy)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleManStrategys>(onlyFromCache)?.battleManStrategys),
            [typeof(BattleWomanStrategy)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleWomanStrategys>(onlyFromCache)?.battleWomanStrategys),
            [typeof(SkillPublicCdCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<SkillPublicCdCfgs>(onlyFromCache)?.skillPublicCdCfgs),
            [typeof(BattleBossIntroduction)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleBossIntroductions>(onlyFromCache)?.battleBossIntroductions),
            [typeof(BattleTag)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleTags>(onlyFromCache)?.battleTags),
            [typeof(MaleSuitConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<MaleSuitConfigs>(onlyFromCache)?.maleSuitConfigs),
            [typeof(FemaleSuitConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<FemaleSuitConfigs>(onlyFromCache)?.femaleSuitConfigs),
            [typeof(DialogueNameConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<DialogueNameConfigs>(onlyFromCache)?.dialogueNameConfigs),
            [typeof(BattleSceneCameraCollider)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleSceneCameraColliders>(onlyFromCache)?.battleSceneCameraColliders),
            [typeof(InterActorComponentConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<InterActorComponentConfigs>(onlyFromCache)?.interActorComponentConfigs),
			[typeof(RogueEntriesConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<RogueEntriesConfigs>(onlyFromCache)?.rogueEntriesConfigs),
            [typeof(RogueEntriesLibraryConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<RogueEntriesLibraryConfigs>(onlyFromCache)?.rogueEntriesLibraryConfigs),
            [typeof(HeroCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<ActorCfgs>(onlyFromCache)?.girlCfgs),
            [typeof(BoyCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<ActorCfgs>(onlyFromCache)?.boyCfgs),
            [typeof(MonsterCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<ActorCfgs>(onlyFromCache)?.monsterCfgs),
            [typeof(MachineCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<ActorCfgs>(onlyFromCache)?.machineCfgs),
            [typeof(InterActorCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<ActorCfgs>(onlyFromCache)?.interActorCfgs),
            [typeof(Dictionary<int, SkillLevelCfg>)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<SkillLevelCfgs>(onlyFromCache)?.skillLevelCfgs),
            [typeof(InterActorModelConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<InterActorModelConfigs>(onlyFromCache)?.interActorModelConfigs),
            //后处理类型配置
            [typeof(ActorCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance._GetPostProcessCfgs<Dictionary<int, ActorCfg>>(onlyFromCache)),
            [typeof(ActorSuitCfg)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance._GetPostProcessCfgs<Dictionary<int, ActorSuitCfg>>(onlyFromCache)),
            //动态类型配置
            [typeof(SkillCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<SkillCfg>((int)id, onlyFromCache, "Skill/", "卡宝宝"),
            [typeof(MissileCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<MissileCfg>((int)id, onlyFromCache, "Missile/", "佚之喵"),
            [typeof(RogueEntryCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<RogueEntryCfg>((int)id, onlyFromCache, "RogueEntry/", "渐渐"),
            [typeof(DamageBoxCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<DamageBoxCfg>((int)id, onlyFromCache, "DamageBox/", "佚之喵"),
            [typeof(ActionModuleCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<ActionModuleCfg>((int)id, onlyFromCache, "ActionModule/", "卡宝宝"),
            [typeof(SkinCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<SkinCfg>((int)id, onlyFromCache, "Skin/", "清心"),
            [typeof(BuffCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<BuffCfg>((int)id, onlyFromCache, "Buff/", "卡宝宝"),
            [typeof(MagicFieldCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<MagicFieldCfg>((int)id, onlyFromCache, "MagicField/", "卡宝宝"),
            [typeof(ItemCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<ItemCfg>((int)id, onlyFromCache, "Item/", "卡宝宝"),
            [typeof(HaloCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<HaloCfg>((int)id, onlyFromCache, "Halo/", "楚门"),
            [typeof(StageConfig)] = (id,onlyFromCache) => instance._GetDynamicCfg<StageConfig>((int)id, onlyFromCache, "Level/Stage_", "五当"),
            [typeof(TriggerCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<TriggerCfg>((int)id, onlyFromCache, "Trigger/", "佚之喵"),
            //调试类型配置
            [typeof(BattleEditorConfig)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleEditorConfigs>(onlyFromCache)?.battleEditorConfigs),
            [typeof(BattleEditorScene)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleEditorScenes>(onlyFromCache)?.battleEditorScenes),
            [typeof(BuffConflictTag)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BuffConflictTags>(onlyFromCache)?.buffConflictTags),
            [typeof(BattleBuffMultipleTag)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleBuffMultipleTags>(onlyFromCache)?.battleBuffMultipleTags),
            [typeof(BattleSkillTag)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleSkillTags>(onlyFromCache)?.battleSkillTags),
            [typeof(BattleActorShowTag)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleActorShowTags>(onlyFromCache)?.battleActorShowTags),
            [typeof(EntriesTag)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<EntriesTags>(onlyFromCache)?.entriesTags),
            [typeof(BattleActionTag)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleActionTags>(onlyFromCache)?.battleActionTags),
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Two Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<ValueType, ValueType, bool, object>> _typeToGetCfgByTwoValueKeyFunc { get;  } = new Dictionary<Type, Func<ValueType, ValueType, bool, object>>
        {
            //Excel类型配置
            [typeof(BuffLevelConfig)] = (id1,id2, onlyFromCache) => instance._GetExcelCfg((int)id1, (int)id2, instance.GetCfgs<BuffLevelConfigs>(onlyFromCache)?.buffLevelConfigs),
            [typeof(GroundMoveFx)] = (id1,id2,onlyFromCache) => instance._GetExcelCfg((int)id1, (int)id2, instance.GetCfgs<GroundMoveFxs>(onlyFromCache)?.groundMoveFxs),
            [typeof(HitParamConfig)] = (id1,id2,onlyFromCache) => instance._GetExcelCfg((int)id1 ,(int)id2, instance.GetCfgs<HitParamConfigs>(onlyFromCache)?.hitParamConfigs),
            [typeof(HurtStateMapConfig)] = (id1,id2,onlyFromCache) => instance._GetExcelCfg((int)id1, (int)id2, instance.GetCfgs<HurtStateMapConfigs>(onlyFromCache)?.hurtStateMapConfigs),
            [typeof(MonsterBase)] = (id1,id2,onlyFromCache) => instance._GetExcelCfg((int)id1, (int)id2, instance.GetCfgs<MonsterBases>(onlyFromCache)?.monsterBases),
            [typeof(BuffTagConflictConfig)] = (id1, id2, onlyFromCache) => instance._GetExcelCfg((int)id1, (BuffConflictType)id2, instance.GetCfgs<BuffTagConflictConfigs>(onlyFromCache)?.buffTagConflictConfigs),
            [typeof(SkillLevelCfg)] = (id1,id2,onlyFromCache) => instance._GetExcelCfg((int)id1, (int)id2, instance.GetCfgs<SkillLevelCfgs>(onlyFromCache)?.skillLevelCfgs),
            //后处理类型配置
            //调试类型配置
        };

        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<string, bool, object>> _typeToGetCfgByStrKeyFunc { get;  } = new Dictionary<Type, Func<string, bool, object>>
        {
            //Excel类型配置
            [typeof(Dictionary<int, HurtMaterialConfig>)] = (id,onlyFromCache) => instance._GetExcelCfg(id, instance.GetCfgs<HurtMaterialConfigs>(onlyFromCache)?.hurtMaterialConfigs),
            //动态类型配置
            [typeof(ModelInfo)] = (id,onlyFromCache) => instance._GetDynamicCfg<ModelInfo>(id, onlyFromCache, "ModelInfos/", "unknown")
            //调试类型配置
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过双Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<string, string, bool, object>> _typeToGetCfgByTwoStrKeyFunc { get;  } = new Dictionary<Type, Func<string, string, bool, object>>
        {
            
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过SStr、Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<string, ValueType, bool, object>> _typeToGetCfgByStrValueFunc { get;  } = new Dictionary<Type, Func<string, ValueType, bool, object>>
        {
            [typeof(HurtMaterialConfig)] = (id1, id2, onlyFromCache) => instance._GetExcelCfg(id1, (int)id2, instance.GetCfgs<HurtMaterialConfigs>(onlyFromCache)?.hurtMaterialConfigs),
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Value、Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<ValueType, string, bool, object>> _typeToGetCfgByValueStrFunc { get;  } = new Dictionary<Type, Func<ValueType, string, bool, object>>
        {
            
        };

        /// <summary>
        /// 销毁
        /// </summary>
        public static void Dispose()
        {
            _instance = null;
        }
    }
}