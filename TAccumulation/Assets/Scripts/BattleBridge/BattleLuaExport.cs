using System;
using XLua;
using PapeGames.X3;
using System.Collections.Generic;
using PapeGames.X3UI;
using Unity.Profiling;

namespace X3Battle
{
    public static class BattleLuaExport
    {
        /// <summary>
        /// 生成这个类型的适配代码,Wrap
        /// </summary>
        [LuaCallCSharp] public static List<Type> lua_call_cs_list = new List<Type>
        {
            typeof(BattleLuaExport),
            typeof(ActorExtension),
            typeof(Action<string>),
            typeof(List<Actor>),
            typeof(SkillTimeline),
            typeof(MonsterProperty),
            typeof(EventBattleEnd),
            typeof(SkillSlotType),
            typeof(DamageExporterType),
            typeof(AttributeOwner),
            typeof(DamageType),
            typeof(SkillOwner),
            typeof(SkillSlotConfig),
            typeof(IBuff),
            typeof(X3Buff),
            typeof(ActorWeak),
            typeof(BoyCfg),
            typeof(BattleConsts),
            typeof(DamageInfo),
            typeof(WeaponSkinConfig),
            typeof(ECObject),
            typeof(EventType),
            typeof(Battle),
            typeof(BattleLuaClient),
            typeof(SkillLevelCfg),
            typeof(EntityData),
            typeof(WeaponLogicConfig),
            typeof(BattleClient),
            typeof(EventCastSkill),
            typeof(ActorMgr),
            typeof(BattleStartupType),
            typeof(ISkill),
            typeof(BattleArg),
            typeof(ActorType),
            typeof(DamageBoxCfg),
            typeof(EventBuffChange),
            typeof(ActorCfg),
            typeof(SkillActive),
            typeof(BattleComponent),
            typeof(BattleLevelConfig),
            typeof(QTEResultType),
            typeof(BattleStatistics),
            typeof(ECEventDataBase),
            typeof(BattleResType),
            typeof(AttrType),
            typeof(EventUIActive),
            typeof(MonsterCfg),
            typeof(ECComponent),
            typeof(FactionType),
            typeof(SkillSlot),
            typeof(ActorMainStateType),
            typeof(BattleUtil),
            typeof(BattleEnv),
            typeof(EventEndSkill),
            typeof(TbUtil),
            typeof(TargetLockModeType),
            typeof(EventBuffLayerChange),
            typeof(PlayerInput),
            typeof(BuffOwner),
            typeof(QTEOperateType),
            typeof(CameraTrace),
            typeof(DamageExporter),
            typeof(ActorLifeStateType),
            typeof(EventDialogueBubble),
            typeof(ActorComponent),
            typeof(ActorModel),
            typeof(ActorTransform),
            typeof(EventPerform),
            typeof(Actor),
            typeof(RoleBornCfg),
            typeof(EventActorBase),
            typeof(PlayerBtnType),
            typeof(PlayerBtnStateType),
            typeof(BattleSetting),
            typeof(EventChangeLockTarget),
            typeof(DummyType),
            typeof(RoleCfg),
            typeof(HeroCfg),
            typeof(BattleResMgr),
            typeof(ResTags),
            typeof(EventExportDamage),
            typeof(LevelFlowBase),
            typeof(FxMgr),
            typeof(EventActor),
            typeof(ActorCacheBornCfg),
            typeof(UIComponentType),
            typeof(CameraModeType),
            typeof(EventComponentActive),
            typeof(ResDesc),
            typeof(BattleUI),
            typeof(FloatWordMgr),
            typeof(DialogueConfig),
            typeof(EventActorHealthChangeForUI),
            typeof(BattleBossIntroduction),
            typeof(EventCoreChange),
            typeof(EventCoreMaxChange),
            typeof(BattleCheatStatistics),
            typeof(List<CheatHurtBase>),
            typeof(List<CheatSkillBase>),
            typeof(List<ECEventDataBase>),
            typeof(List<EventType>),
            typeof(EventWeakFull),
            typeof(EventShowMissionTips),
            typeof(SkillDisableController),
            typeof(SlotEnergyCoster),
            typeof(QTEController),
            typeof(BattleGuide),
            typeof(BattleCounterMgr),
            typeof(ResAnalyzer),
            typeof(ResAnalyzerExtension),
            typeof(X3Joystick.EJoystick),
            typeof(BattleReplayMode),
            typeof(EventActorFrozen),
            typeof(ActorWeapon),
            typeof(BattleEnabledMask),
            typeof(BattleWndMode),
            typeof(ActorBornCfg),
            typeof(ActorDialogue),
            typeof(BattleExtension),
            typeof(RogueEntry),
            typeof(FpsOperateType),
            typeof(BattleRunStatus)
        };

        /*
        /// <summary>
        /// 生成这个类型的适配代码,Wrap
        /// </summary>
        [LuaCallCSharp]
        public static List<Type> lua_call_cs_event_list => (from type in Assembly.Load("BattleClient").GetTypes() where type.BaseType == typeof(ECEventDataBase) select type).ToList();
        */

        /// <summary>
        /// 不导出的黑名单列表（方法，属性）
        /// </summary>
        [BlackList] public static List<List<string>> lua_call_cs_black_list = new List<List<string>>
        {
        };

        /// <summary>
        /// 主要是cs到lua的相关委托,Interface
        /// </summary>
        [CSharpCallLua] public static List<Type> cs_call_lua_list = new List<Type>
        {
            typeof(IBattleLuaClient),
            typeof(IBattleLuaBridge),
            typeof(IBattleServerProxy)
        };

        /// <summary>
        /// 值类型优化
        /// </summary>
        [GCOptimize(OptimizeFlag.PackAsTable)] public static List<Type> gc_optimize_list = new List<Type>
        {
            typeof(EventType),
            typeof(AttrType),
            typeof(DummyType),
            typeof(SkillSlotType),
            typeof(PlayerBtnType),
            typeof(PlayerBtnStateType),
            typeof(BattleReplayMode),
            typeof(BattleEnabledMask),
            typeof(BattleWndMode),
            typeof(FpsOperateType),
            typeof(BattleRunStatus)
        };

        /// <summary>
        /// 反射的时候使用，会生成link.xml防止il2cpp代码裁剪
        /// </summary>
        [ReflectionUse] public static List<Type> reflection_use_list = new List<Type>
        {
            typeof(BattleLuaExport)
        };

        /// <summary>
        /// 加载lua端用到的wrap
        /// </summary>
        public static void LoadWrap(Type type)
        {
            var luaEnv = X3Lua.GetLuaEnv()?.GetLuaEnv();
            luaEnv?.translator.TryDelayWrapLoader(luaEnv.L, type);
        }

        /// <summary>
        /// 加载lua端用到的wrap
        /// </summary>
        private static ProfilerMarker LoadWrapsPMarker = new ProfilerMarker("BattleLua.LoadWraps()");
        public static void LoadWraps()
        {
            var luaEnv = X3Lua.GetLuaEnv()?.GetLuaEnv();
            if (null == luaEnv)
            {
                return;
            }

            using (LoadWrapsPMarker.Auto())
            {
                foreach (var type in lua_call_cs_list)
                {
                    luaEnv.translator.TryDelayWrapLoader(luaEnv.L, type);
                }
            }
        }
    }
}