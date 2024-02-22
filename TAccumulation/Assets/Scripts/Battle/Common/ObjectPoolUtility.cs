using System;
using System.Collections.Generic;
using FlowCanvas;
using X3Battle.TargetSelect;

namespace X3Battle
{
    // 回收时自动Clear的List
    public class ResetList<T> : List<T>, IReset
    {
        public ResetList()
        {
        }

        public ResetList(int capacity) : base(capacity)
        {
        }

        public void Reset()
        {
            this.Clear();
        }
    }

    public class ResetHashSet<T> : HashSet<T>, IReset
    {
        public void Reset()
        {
            this.Clear();
        }
    }
    
    public class ResetDictionary<K, V> : Dictionary<K, V>, IReset
    {
        public void Reset()
        {
            this.Clear();
        }
    }

    public static class ObjectPoolUtility
    {
        // 通用actor列表.
        public static ObjectPool<ResetList<Actor>> CommonActorList;
        public static ObjectPool<ResetList<X3Buff>> CommonBuffList;
        public static ObjectPool<ResetList<string>> CommonStringList;
        public static ObjectPool<ResetList<zstring>> CommonZstringList;
        public static ObjectPool<ResetList<int>> CommonIntList;
        public static ObjectPool<ResetDictionary<int, SkillSlotConfig>> CommonSlotCfgDict;

        public static ObjectPool<ResetHashSet<Actor>> CommonActorHashSet;

        public static ObjectPool<ActorInfo> ActorInfoPool { get; private set; }
        // 引用float类型池
        public static ObjectPool<ShieldAddInfo> ShieldAddInfoPool { get; private set; }
        public static ObjectPool<ResetList<ActorInfo>> ActorInfoListPool { get; private set; }
        public static ObjectPool<ActorMainState.ChangeStateInfo> CandidateMainStateItemPool { get; private set; }
        public static ObjectPool<ActorMainState.AbnormalInfo> AbnormalInfoPool { get; private set; }

        public static ObjectPool<SkillLinkDataItem> SkillLink;
        public static ObjectPool<MissileBezierPoint> MissileBezierPoint;
        public static ObjectPool<ColdToken> ColdToken;
        public static ObjectPool<StrategySector> StrategySector;
        public static ObjectPool<ActorStrategy> ActorStrategy;
        public static ObjectPool<StrategyWander> StrategyWander;
        public static ObjectPool<GroupStrategy> ColonyStrategy;
        public static ObjectPool<TauntData> TauntData;

        public static ObjectPool<BattleUI.WindowData> WindowData;
        public static ObjectPool<BattleUI.HudData> HudData;

        public static ObjectPool<TagData> TagData;
        public static ObjectPool<AffixData> AffixData;
        
        public static ObjectPool<FrameUpdateMgr.ObjFrame> ActorFrame;
        public static ObjectPool<FrameUpdateMgr.FrameData> FrameData;

        //仇恨
        public static ObjectPool<EnemyHateData> EnemyHateData;
        public static ObjectPool<PlayerHateData> PlayerHateData;

        public static ObjectPool<ActorAdapter> ActorAdapter;


        //属性
        public static ObjectPool<Attribute> Attribute;
        public static ObjectPool<InstantAttr> InstantAttr;

        // timeline池
        public static ObjectPool<BattleSequencer> BS;

        // BattleActorAnimFeature池
        public static ObjectPool<BSCActorAnim> BattleActorAnimCom;

        // BattleControlCameraFeature 池
        public static ObjectPool<BSCControlCamera> BattleControlCameraCom;

        public static ObjectPool<BSCSkill> BattleSkillCom;

        public static ObjectPool<BSCSceneEffect> BattleSceneEffectCom;
        
        public static ObjectPool<BSCActor> BattleActorCom;

        // BattlePerformFeature 池
        public static ObjectPool<BSCPerform> BattlePerformCom;

        // BattleResFeature 池
        public static ObjectPool<BSCRes> BattleResCom;

        // ClockFeature 池
        public static ObjectPool<BSCClock> ClockCom;

        // MainlineResFeature 池
        public static ObjectPool<BSCDefaultRes> MainlineResCom;

        // MaterialAnimFeature池
        // public static ObjectPool<MaterialAnimCom> MaterialAnimCom;

        // TrackBindFeature池
        public static ObjectPool<BSCTrackBind> TrackBindCom;

        // ComplexPlayableInstance池
        public static ObjectPool<ComplexPlayableInstance> ComplexPlayableInstance;

        // MaterialPlayableInstance池
        public static ObjectPool<MaterialPlayableInstance> MaterialPlayableInstance;

        // PerformPlayableInstance池
        public static ObjectPool<PerformPlayableInstance> PerformPlayableInstance;
        public static ObjectPool<SkillSelectData> SkillSelectData;
        public static ObjectPool<TargetSelectUtil.EnemyItem> EnemyItem;

        // Buff池
        public static ObjectPool<X3Buff> X3BuffPool;

        public static ObjectPool<ActorDirGuide> ActorDirGuidePool;

        // BuffAction池
        public static ObjectPool<AddTaunt> AddTauntPool;
        public static ObjectPool<AddActorStateTag> AddActorStateTagPool;
        public static ObjectPool<BuffActionHalo> BuffActionHaloPool;
        public static ObjectPool<BuffEndDamage> BuffEndDamagePool;
        public static ObjectPool<BuffHPShield> BuffHPShieldPool;
        public static ObjectPool<BuffLockHP> BuffLockHPPool;
        public static ObjectPool<BuffModifySkillDamage> BuffModifySkillDamagePool;
        public static ObjectPool<DynamicChangeAttr> DynamicChangeAttrPool;
        public static ObjectPool<DynamicDamageModify> DynamicDamageModifyPool;
        public static ObjectPool<PlayMatAnim> PlayMatAnimPool;
        public static ObjectPool<SetToughness> SetToughnessPool;
        public static ObjectPool<ForbidEnergyRecover> ForbidEnergyRecoverPool;
        public static ObjectPool<BuffActionGhost> BuffActionGhostPool;
        public static ObjectPool<BuffActionFrozen> BuffActionFrozenPool;
        public static ObjectPool<BuffActionVertigo> BuffActionVertigoPool;
        public static ObjectPool<BuffActionWeak> BuffActionWeakPool;
        public static ObjectPool<BuffActionUnVisibility> BuffActionUnVisibilityPool;
        public static ObjectPool<BuffActionRemoveDebuff> BuffActionRemoveDebuffPool;
        public static ObjectPool<BuffActionDrag> BuffActionDragPool;
        public static ObjectPool<SkillNoConsumption> BuffActionSkillNoConsumptionPool;
        public static ObjectPool<PlayGroupFx> PlayGroupFxPool;
        public static ObjectPool<DisableSkill> BuffActionDisableSkillPool;
        public static ObjectPool<BuffActionAttrModifier> BuffActionAttrModifierPool;
        public static ObjectPool<RemoveMatchBuff> BuffActionRemoveMatchBuffPool;
        public static ObjectPool<BuffActionPlayFx> BuffActionPlayFxPool;
        public static ObjectPool<BuffActionChangeMaxHP> BuffActionChangeMaxHPPool;
        public static ObjectPool<BuffActionWitchTime> BuffActionWitchTimePool;
        public static ObjectPool<BuffActionPlayPPV> BuffActionPlayPPVPool;

        public static ObjectPool<TriggerFlow> TriggerFlowPool;
        public static ObjectPool<ShapeBox> ShapeBoxPool;
        public static ObjectPool<PhysicsDamageBox> PhysicsDamageBoxPool;
        public static ObjectPool<DirectDamageBox> DirectDamagePool;
        public static ObjectPool<DamageBoxGroup> DamageBoxGroupPool;
        public static ObjectPool<DamageInfo> DamageInfoPool;
        public static ObjectPool<HitInfo> HitInfoPool;
        public static ObjectPool<DynamicDamageInfo> DynamicDamageInfoPool;
        public static ObjectPool<DynamicHitInfo> DynamicHitInfoPool;
        public static ObjectPool<DamageExportMeters> DamageExporterMetersPool;
        public static ObjectPool<DamageMeter> DamageMetersPool;
        public static ObjectPool<ResetList<DamageMeter>> DamageMetersListPool;
        public static ObjectPool<DamageParam> DamageParamPool;

        //指令缓存池
        public static Dictionary<Type, ObjectPoolBase<ActorCmd>> ActorCmdPool;

        //出生实例配置
        public static Dictionary<Type, ObjectPool<ActorBornCfg>> ActorBornCfgPool;

        public static ObjectPool<ResetList<AttrModifyData>> AttrModifyListPool;
        public static ObjectPool<ResetList<CollisionDetectionInfo>> CollisionInfoListPool;

        // 子弹数据缓存
        public static ObjectPool<RicochetShareData> RicochetShareData;

        //防作弊事件统计相关
        public static ObjectPool<CheatBuffEvent> CheatBuffEventPool;
        public static ObjectPool<CheatAttrChangeEvent> CheatAttrChangePool;
        public static ObjectPool<CheatCastSkill> CheatCastSkillPool;
        public static ObjectPool<CheatEndSkill> CheatEndSkillPool;
        public static ObjectPool<CheatOnKillTarget> CheatOnKillPool;
        public static ObjectPool<CheatActor> CheatActorPool;

        public static ObjectPool<CheatLockHp> CheatLockHpPool;
        public static ObjectPool<CheatCoreChange> CheatCoreChangePool;
        public static ObjectPool<CheatTauntChange> CheatTauntChangePool;
        public static ObjectPool<CheatBattleEnd> CheatBattleEndPool;
        

        //防作弊技能统计
        public static ObjectPool<CheatSkillBase> CheatSkillPool;

        //防作弊伤害统计
        public static ObjectPool<CheatHurtBase> CheatHurtPool;
        public static ObjectPool<CheatBuff> CheatBuffPool;
        
        
        public static ObjectPool<CheatAttrBase> CheatAttrPool;
        

        // 共鸣技辅助计算点池
        public static ObjectPool<BSCSkill.MeshPointInfo> MeshPointInfo;
        public static ObjectPool<BSCSkill.PointInfo> PointInfo;

        public static ObjectPool<ActorGroup> ActorGroupPool;

        public static ObjectPool<NotionGraph<FlowScriptController>> FlowScriptControllerPool;

        public static Dictionary<Type, ObjectPoolBase<IAIActionGoal>> AIActionGoalPool;
        public static Dictionary<Type, ObjectPoolBase<IAIConditionGoal>> AIConditionGoalPool;

        public static ObjectPool<DialogueNode> DialogueNodePool;
        public static ObjectPool<BoundingShape> BoundingShapePool;
        
        // QTE选点
        public static ObjectPool<QTEController.QTEPointInfo> QTEPointInfo;

        public static ObjectPoolBase<LinkedListNode<ActorCmd>> ActorCmdLinkNodePool;

        public static ObjectPool<ActorWitchTimeSettings> WitchTimeSettings;
        
        public static ObjectPool<PlayerBtnStateData> PlayerBtnStateDatas;
        
        //Battle UI
        public static ObjectPool<BattleUI.BattleUIPlayable> BattleUIPlayablePool;

        public static ObjectPool<Halo> HaloPool;

        public static ObjectPool<ModifyAttrValue> ModifyAttrValuePool { get; private set; }
        public static ObjectPool<Dictionary<AttrType, ModifyAttrValue>> ModifyAttrValueDictionary { get; private set; }
        
        public static ObjectPool<ActivateInfo> ActivateInfoPool { get; set; }

        //音频
        public static ObjectPool<ResetList<WwiseBattleManager.EventObj>> WwiseEventList{ get; set; }
        
        private static Dictionary<Type, ObjectPoolBase<ActorPointBase>> ActorPointCfgPool;
        
        // 肉鸽
        public static ObjectPool<EntryExpressionRootNode> EntryExpressionRootNodePool;
        public static ObjectPool<EntryExpressionBranchNode> EntryExpressionBranchNodePool;
        public static ObjectPool<EntryExpressionLeafNode> EntryExpressionLeafNodePool;

        public static void Init()
        {
            ActorInfoPool = new ObjectPool<ActorInfo>(20);
            ShieldAddInfoPool = new ObjectPool<ShieldAddInfo>(4);
            ActorInfoListPool = new ObjectPool<ResetList<ActorInfo>>(20);
            ActivateInfoPool = new ObjectPool<ActivateInfo>(20);
            
            CandidateMainStateItemPool = new ObjectPool<ActorMainState.ChangeStateInfo>(20);
            AbnormalInfoPool = new ObjectPool<ActorMainState.AbnormalInfo>(5);
                
            ModifyAttrValuePool = new ObjectPool<ModifyAttrValue>(3);
            ModifyAttrValueDictionary = new ObjectPool<Dictionary<AttrType, ModifyAttrValue>>(3);
            
            HaloPool = new ObjectPool<Halo>(6);
            EntryExpressionRootNodePool = new ObjectPool<EntryExpressionRootNode>(1);
            EntryExpressionBranchNodePool = new ObjectPool<EntryExpressionBranchNode>(4);
            EntryExpressionLeafNodePool = new ObjectPool<EntryExpressionLeafNode>(4);
            
            ActorCmdLinkNodePool = new ObjectPoolBase<LinkedListNode<ActorCmd>>(20, () => new LinkedListNode<ActorCmd>(null));
            MeshPointInfo = new ObjectPool<BSCSkill.MeshPointInfo>(16);
            PointInfo = new ObjectPool<BSCSkill.PointInfo>(8);
            QTEPointInfo = new ObjectPool<QTEController.QTEPointInfo>(16);
            WitchTimeSettings = new ObjectPool<ActorWitchTimeSettings>(10);
            PlayerBtnStateDatas = new ObjectPool<PlayerBtnStateData>(8);
            
            CommonActorList = new ObjectPool<ResetList<Actor>>();
            for (int i = 0; i < 2; i++)
            {
                CommonActorList.Release(new ResetList<Actor>(16));
            }

            CommonBuffList = new ObjectPool<ResetList<X3Buff>>(2);
            
            CommonStringList = new ObjectPool<ResetList<string>>(12);
            CommonZstringList = new ObjectPool<ResetList<zstring>>(4);
            CommonIntList = new ObjectPool<ResetList<int>>(4);
            CommonSlotCfgDict = new ObjectPool<ResetDictionary<int, SkillSlotConfig>>(4);
            CommonActorHashSet = new ObjectPool<ResetHashSet<Actor>>(2);
            
            SkillLink = new ObjectPool<SkillLinkDataItem>(10);
            MissileBezierPoint = new ObjectPool<MissileBezierPoint>(200);
            ColdToken = new ObjectPool<ColdToken>(20);
            StrategySector = new ObjectPool<StrategySector>(20);
            ActorStrategy = new ObjectPool<ActorStrategy>(10);
            StrategyWander = new ObjectPool<StrategyWander>(10);
            ColonyStrategy = new ObjectPool<GroupStrategy>(5);
            TauntData = new ObjectPool<TauntData>(10);
            WindowData = new ObjectPool<BattleUI.WindowData>(5);
            TagData = new ObjectPool<TagData>(3);
            AffixData = new ObjectPool<AffixData>(3);
            HudData = new ObjectPool<BattleUI.HudData>(10);
            ActorFrame = new ObjectPool<FrameUpdateMgr.ObjFrame>(20);
            FrameData = new ObjectPool<FrameUpdateMgr.FrameData>(50);
            EnemyHateData = new ObjectPool<EnemyHateData>(20);
            PlayerHateData = new ObjectPool<PlayerHateData>(10);

            ActorAdapter = new ObjectPool<ActorAdapter>(5);


            Attribute = new ObjectPool<Attribute>(150);
            InstantAttr = new ObjectPool<InstantAttr>(150);

            var timelinePreCount = 25; // 正常tiemline的预加载对象
            BS = new ObjectPool<BattleSequencer>(timelinePreCount);
            BattleActorAnimCom = new ObjectPool<BSCActorAnim>(timelinePreCount);
            BattleControlCameraCom = new ObjectPool<BSCControlCamera>(timelinePreCount);
            BattleSkillCom = new ObjectPool<BSCSkill>(timelinePreCount);
            BattleSceneEffectCom = new ObjectPool<BSCSceneEffect>(timelinePreCount);
            BattleActorCom = new ObjectPool<BSCActor>(timelinePreCount);
            BattlePerformCom = new ObjectPool<BSCPerform>(timelinePreCount);
            BattleResCom = new ObjectPool<BSCRes>(timelinePreCount);
            ClockCom = new ObjectPool<BSCClock>(timelinePreCount);
            MainlineResCom = new ObjectPool<BSCDefaultRes>(timelinePreCount);
            // MaterialAnimCom = new ObjectPool<MaterialAnimCom>(timelinePreCount);
            TrackBindCom = new ObjectPool<BSCTrackBind>(timelinePreCount);
            var graphPreCount = 10; // graphAnim相关的预加载对象数量
            ComplexPlayableInstance = new ObjectPool<ComplexPlayableInstance>(graphPreCount);
            MaterialPlayableInstance = new ObjectPool<MaterialPlayableInstance>(graphPreCount);
            PerformPlayableInstance = new ObjectPool<PerformPlayableInstance>(3);
            SkillSelectData = new ObjectPool<SkillSelectData>(10);
            EnemyItem = new ObjectPool<TargetSelectUtil.EnemyItem>(10);
            X3BuffPool = new ObjectPool<X3Buff>(20);
            ActorDirGuidePool = new ObjectPool<ActorDirGuide>(2);

            AddTauntPool = new ObjectPool<AddTaunt>(3);
            AddActorStateTagPool = new ObjectPool<AddActorStateTag>(3);
            BuffActionHaloPool = new ObjectPool<BuffActionHalo>(3);
            BuffEndDamagePool = new ObjectPool<BuffEndDamage>(3);
            BuffHPShieldPool = new ObjectPool<BuffHPShield>(3);
            BuffLockHPPool = new ObjectPool<BuffLockHP>(3);
            BuffModifySkillDamagePool = new ObjectPool<BuffModifySkillDamage>(4);
            DynamicChangeAttrPool = new ObjectPool<DynamicChangeAttr>(3);
            DynamicDamageModifyPool = new ObjectPool<DynamicDamageModify>(3);
            PlayMatAnimPool = new ObjectPool<PlayMatAnim>(3);
            SetToughnessPool = new ObjectPool<SetToughness>(3);
            ForbidEnergyRecoverPool = new ObjectPool<ForbidEnergyRecover>(3);
            BuffActionGhostPool = new ObjectPool<BuffActionGhost>(3);
            BuffActionFrozenPool = new ObjectPool<BuffActionFrozen>(3);
            BuffActionVertigoPool = new ObjectPool<BuffActionVertigo>(3);
            PlayGroupFxPool = new ObjectPool<PlayGroupFx>(3);
            BuffActionWeakPool = new ObjectPool<BuffActionWeak>(3);
            BuffActionUnVisibilityPool = new ObjectPool<BuffActionUnVisibility>(3);
            BuffActionRemoveDebuffPool = new ObjectPool<BuffActionRemoveDebuff>(3);
            BuffActionDragPool = new ObjectPool<BuffActionDrag>(3);
            BuffActionSkillNoConsumptionPool = new ObjectPool<SkillNoConsumption>(3);
            BuffActionDisableSkillPool = new ObjectPool<DisableSkill>(3);
            BuffActionAttrModifierPool = new ObjectPool<BuffActionAttrModifier>(3);
            BuffActionRemoveMatchBuffPool = new ObjectPool<RemoveMatchBuff>(3);
            BuffActionPlayFxPool = new ObjectPool<BuffActionPlayFx>(3);
            BuffActionChangeMaxHPPool = new ObjectPool<BuffActionChangeMaxHP>(3);
            BuffActionWitchTimePool = new ObjectPool<BuffActionWitchTime>(3);
            BuffActionPlayPPVPool = new ObjectPool<BuffActionPlayPPV>(3);

            TriggerFlowPool = new ObjectPool<TriggerFlow>(10);
            ShapeBoxPool = new ObjectPool<ShapeBox>(10);
            PhysicsDamageBoxPool = new ObjectPool<PhysicsDamageBox>(10);
            DirectDamagePool = new ObjectPool<DirectDamageBox>(5);
            DamageBoxGroupPool = new ObjectPool<DamageBoxGroup>(10);
            DamageInfoPool = new ObjectPool<DamageInfo>(30);
            HitInfoPool = new ObjectPool<HitInfo>(30);
            DynamicDamageInfoPool = new ObjectPool<DynamicDamageInfo>(30);
            DynamicHitInfoPool = new ObjectPool<DynamicHitInfo>(30);
            DamageExporterMetersPool = new ObjectPool<DamageExportMeters>(80);
            DamageMetersPool = new ObjectPool<DamageMeter>(80);
            DamageMetersListPool = new ObjectPool<ResetList<DamageMeter>>(10);
            DamageParamPool = new ObjectPool<DamageParam>(5);
            BattleUIPlayablePool = new ObjectPool<BattleUI.BattleUIPlayable>(10);

            //指令缓存池 
            ActorCmdPool = new Dictionary<Type, ObjectPoolBase<ActorCmd>>
            {
                {typeof(ActorBtnStateCommand), new ObjectPoolBase<ActorCmd>(5, () => new ActorBtnStateCommand())},
                {typeof(ActorCancelLockCacheCmd), new ObjectPoolBase<ActorCmd>(1, () => new ActorCancelLockCacheCmd())},
                {typeof(ActorEndBattleCommand), new ObjectPoolBase<ActorCmd>(1, () => new ActorEndBattleCommand())},
                {typeof(ActorLockModeCommand), new ObjectPoolBase<ActorCmd>(1, () => new ActorLockModeCommand())},
                {typeof(ActorMoveDirCmd), new ObjectPoolBase<ActorCmd>(5, () => new ActorMoveDirCmd())},
                {typeof(ActorMovePosCmd), new ObjectPoolBase<ActorCmd>(5, () => new ActorMovePosCmd())},
                {typeof(ActorSkillCmdEditor), new ObjectPoolBase<ActorCmd>(1, () => new ActorSkillCmdEditor())},
                {typeof(ActorSkillCommand), new ObjectPoolBase<ActorCmd>(8, () => new ActorSkillCommand())},
                {typeof(ActorSwitchTargetCmd), new ObjectPoolBase<ActorCmd>(2, () => new ActorSwitchTargetCmd())},
                {typeof(CreateRoleCmd), new ObjectPoolBase<ActorCmd>(1, () => new CreateRoleCmd())},
            };

            ActorBornCfgPool = new Dictionary<Type, ObjectPool<ActorBornCfg>>
            {
                {typeof(ActorBornCfg), new ObjectPool<ActorBornCfg>(8, () => new ActorBornCfg())},
                {typeof(RoleBornCfg), new ObjectPool<ActorBornCfg>(8, () => new RoleBornCfg())},
                {typeof(ItemBornCfg), new ObjectPool<ActorBornCfg>(2, () => new ItemBornCfg())},
                {typeof(MachineBornCfg), new ObjectPool<ActorBornCfg>(2, () => new MachineBornCfg())},
                {typeof(ObstacleBornCfg), new ObjectPool<ActorBornCfg>(2, () => new ObstacleBornCfg())},
                {typeof(TriggerAreaBornCfg), new ObjectPool<ActorBornCfg>(2, () => new TriggerAreaBornCfg())},
                {typeof(SkillAgentBornCfg), new ObjectPool<ActorBornCfg>(2, () => new SkillAgentBornCfg())},
                {typeof(StageBornCfg), new ObjectPool<ActorBornCfg>(1, ()=> new StageBornCfg())},
            };

            ActorPointCfgPool = new Dictionary<Type, ObjectPoolBase<ActorPointBase>>
            {
                {typeof(CreaturePointData), new ObjectPoolBase<ActorPointBase>(1, () => new CreaturePointData())},
            };
                
            AttrModifyListPool = new ObjectPool<ResetList<AttrModifyData>>();
            for (int i = 0; i < 5; i++)
            {
                AttrModifyListPool.Release(new ResetList<AttrModifyData>(20));
            }
            
            WwiseEventList = new ObjectPool<ResetList<WwiseBattleManager.EventObj>>();
            for (int i = 0; i < 20; i++)
            {
                WwiseEventList.Release(new ResetList<WwiseBattleManager.EventObj>(6));
            }

            CollisionInfoListPool = new ObjectPool<ResetList<CollisionDetectionInfo>>();
            for (int i = 0; i < 5; i++)
            {
                CollisionInfoListPool.Release(new ResetList<CollisionDetectionInfo>(20));
            }

            RicochetShareData = new ObjectPool<RicochetShareData>(20);

            CheatBuffPool = new ObjectPool<CheatBuff>(400);
            CheatBuffEventPool = new ObjectPool<CheatBuffEvent>(450);
            CheatAttrChangePool = new ObjectPool<CheatAttrChangeEvent>(450);
            CheatCastSkillPool = new ObjectPool<CheatCastSkill>(320);
            CheatEndSkillPool = new ObjectPool<CheatEndSkill>(320);
            CheatOnKillPool = new ObjectPool<CheatOnKillTarget>(10);
            CheatActorPool = new ObjectPool<CheatActor>(30);
            CheatLockHpPool = new ObjectPool<CheatLockHp>(2);
            CheatSkillPool = new ObjectPool<CheatSkillBase>(25);
            CheatHurtPool = new ObjectPool<CheatHurtBase>(400);
            CheatAttrPool = new ObjectPool<CheatAttrBase>(200); 
            CheatCoreChangePool = new ObjectPool<CheatCoreChange>(20);
            CheatTauntChangePool = new ObjectPool<CheatTauntChange>(10);
            CheatBattleEndPool = new ObjectPool<CheatBattleEnd>(2);
            
            ActorGroupPool = new ObjectPool<ActorGroup>(1);

            BoundingShapePool = new ObjectPool<BoundingShape>(1);
            
            FlowScriptControllerPool = new ObjectPool<NotionGraph<FlowScriptController>>(20);

            AIActionGoalPool = new Dictionary<Type, ObjectPoolBase<IAIActionGoal>>
            {
                {typeof(AIApproachPositionActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIApproachPositionActionGoal())},
                {typeof(AIApproachTargetActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIApproachTargetActionGoal())},
                {typeof(AICastSkillActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AICastSkillActionGoal())},
                {typeof(AIHoverActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIHoverActionGoal())},
                {typeof(AIMoveAndCastSkillActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIMoveAndCastSkillActionGoal())},
                {typeof(AIRotateTargetActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIRotateTargetActionGoal())},
                {typeof(AITickSubTreeGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AITickSubTreeGoal())},
                {typeof(AIWaitActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIWaitActionGoal())},
                {typeof(AIWalkBackTargetActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIWalkBackTargetActionGoal())},
                {typeof(AISmartHoverActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AISmartHoverActionGoal())},
                {typeof(AIApproachTargetBySpeedActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIApproachTargetBySpeedActionGoal())},
                {typeof(AIApproachTargetBySpeedWithOffsetActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIApproachTargetBySpeedWithOffsetActionGoal())},
                {typeof(AIHoverPointActionGoal), new ObjectPoolBase<IAIActionGoal>(2, () => new AIHoverPointActionGoal())},
            };
            AIConditionGoalPool = new Dictionary<Type, ObjectPoolBase<IAIConditionGoal>>
            {
                {typeof(AIDistanceConditionGoal), new ObjectPoolBase<IAIConditionGoal>(2, () => new AIDistanceConditionGoal())},
                {typeof(AIIsTargetInAreaConditionGoal), new ObjectPoolBase<IAIConditionGoal>(2, () => new AIIsTargetInAreaConditionGoal())},
                {typeof(AIIsTimerOverConditionGoal), new ObjectPoolBase<IAIConditionGoal>(2, () => new AIIsTimerOverConditionGoal())},
                {typeof(AINotInGlobalCDConditionGoal), new ObjectPoolBase<IAIConditionGoal>(2, () => new AINotInGlobalCDConditionGoal())},
                {typeof(AIWaitCurrActionFinishConditionGoal), new ObjectPoolBase<IAIConditionGoal>(2, () => new AIWaitCurrActionFinishConditionGoal())},
            };
            
            DialogueNodePool = new ObjectPool<DialogueNode>(10);
        }

        public static void UnInit()
        {
            ActorInfoListPool.Destroy();
            ActorInfoListPool = null;
            
            ActorInfoPool.Destroy();
            ActorInfoPool = null;
            
            ShieldAddInfoPool.Destroy();
            ShieldAddInfoPool = null;
            
            ActivateInfoPool.Destroy();
            ActivateInfoPool = null;
            
            CandidateMainStateItemPool.Destroy();
            CandidateMainStateItemPool = null;
            
            AbnormalInfoPool.Destroy();
            AbnormalInfoPool = null;
            
            ModifyAttrValueDictionary.Destroy();
            ModifyAttrValueDictionary = null;
            
            ModifyAttrValuePool.Destroy();
            ModifyAttrValuePool = null;
            
            HaloPool.Destroy();
            HaloPool = null;
            
            EntryExpressionRootNodePool.Destroy();
            EntryExpressionRootNodePool = null;
            
            EntryExpressionBranchNodePool.Destroy();
            EntryExpressionBranchNodePool = null;
            
            EntryExpressionLeafNodePool.Destroy();
            EntryExpressionLeafNodePool = null;
            
            ActorCmdLinkNodePool.Destroy();
            ActorCmdLinkNodePool = null;
            
            MeshPointInfo.Destroy();
            MeshPointInfo = null;

            PointInfo.Destroy();
            PointInfo = null;
            
            QTEPointInfo.Destroy();
            QTEPointInfo = null;
            
            WitchTimeSettings.Destroy();
            WitchTimeSettings = null;
            
            PlayerBtnStateDatas.Destroy();
            PlayerBtnStateDatas = null;

            CommonActorList.Destroy();
            CommonActorList = null;
            
            CommonBuffList.Destroy();
            CommonBuffList = null;

            CommonStringList.Destroy();
            CommonStringList = null;
            
            CommonZstringList.Destroy();
            CommonZstringList = null;
            
            CommonIntList.Destroy();
            CommonIntList = null;
            
            CommonSlotCfgDict.Destroy();
            CommonSlotCfgDict = null;
            
            CommonActorHashSet.Destroy();
            CommonActorHashSet = null;

            SkillLink.Destroy();
            SkillLink = null;

            MissileBezierPoint.Destroy();
            MissileBezierPoint = null;

            ColdToken.Destroy();
            ColdToken = null;
            StrategySector.Destroy();
            StrategySector = null;
            ActorStrategy.Destroy();
            ActorStrategy = null;
            StrategyWander.Destroy();
            StrategyWander = null;
            ColonyStrategy.Destroy();
            ColonyStrategy = null;

            TauntData.Destroy();
            TauntData = null;
            
            WindowData.Destroy();
            WindowData = null;
            
            TagData.Destroy();
            TagData = null;
            
            AffixData.Destroy();
            AffixData = null;
            
            HudData.Destroy();
            HudData = null;
            
            ActorFrame.Destroy();
            ActorFrame = null;
            FrameData.Destroy();
            FrameData = null;

            EnemyHateData.Destroy();
            EnemyHateData = null;

            PlayerHateData.Destroy();
            PlayerHateData = null;

            ActorAdapter.Destroy();
            ActorAdapter = null;


            Attribute.Destroy();
            Attribute = null;

            InstantAttr.Destroy();
            InstantAttr = null;

            BS.Destroy();
            BS = null;

            BattleActorAnimCom.Destroy();
            BattleActorAnimCom = null;

            BattleControlCameraCom.Destroy();
            BattleControlCameraCom = null;

            BattleSkillCom.Destroy();
            BattleSkillCom = null;

            BattleSceneEffectCom.Destroy();
            BattleSceneEffectCom = null;
            
            BattleActorCom.Destroy();
            BattleActorCom = null;

            BattlePerformCom.Destroy();
            BattlePerformCom = null;

            BattleResCom.Destroy();
            BattleResCom = null;

            ClockCom.Destroy();
            ClockCom = null;

            MainlineResCom.Destroy();
            MainlineResCom = null;

            // MaterialAnimCom.Destroy();
            // MaterialAnimCom = null;

            TrackBindCom.Destroy();
            TrackBindCom = null;

            ComplexPlayableInstance.Destroy();
            ComplexPlayableInstance = null;

            MaterialPlayableInstance.Destroy();
            MaterialPlayableInstance = null;

            PerformPlayableInstance.Destroy();
            PerformPlayableInstance = null;

            SkillSelectData.Destroy();
            SkillSelectData = null;

            EnemyItem.Destroy();
            EnemyItem = null;

            X3BuffPool.Destroy();
            X3BuffPool = null;

            ActorDirGuidePool.Destroy();
            ActorDirGuidePool = null;

            TriggerFlowPool.Destroy();
            TriggerFlowPool = null;

            ShapeBoxPool.Destroy();
            ShapeBoxPool = null;

            PhysicsDamageBoxPool.Destroy();
            PhysicsDamageBoxPool = null;

            DirectDamagePool.Destroy();
            DirectDamagePool = null;

            DamageBoxGroupPool.Destroy();
            DamageBoxGroupPool = null;

            DamageInfoPool.Destroy();
            DamageInfoPool = null;

            HitInfoPool.Destroy();
            HitInfoPool = null;

            DynamicDamageInfoPool.Destroy();
            DynamicDamageInfoPool = null;

            DynamicHitInfoPool.Destroy();
            DynamicHitInfoPool = null;

            DamageExporterMetersPool.Destroy();
            DamageExporterMetersPool = null;

            DamageMetersPool.Destroy();
            DamageMetersPool = null;

            DamageMetersListPool.Destroy();
            DamageMetersListPool = null;


            DamageParamPool.Destroy();
            DamageParamPool = null;
            
            BattleUIPlayablePool.Destroy();
            BattleUIPlayablePool = null;


            AddTauntPool.Destroy();
            AddActorStateTagPool.Destroy();
            BuffActionHaloPool.Destroy();
            BuffEndDamagePool.Destroy();
            BuffHPShieldPool.Destroy();
            BuffLockHPPool.Destroy();
            BuffModifySkillDamagePool.Destroy();
            DynamicChangeAttrPool.Destroy();
            DynamicDamageModifyPool.Destroy();
            ForbidEnergyRecoverPool.Destroy();
            PlayMatAnimPool.Destroy();
            SetToughnessPool.Destroy();
            BuffActionGhostPool.Destroy();
            BuffActionFrozenPool.Destroy();
            BuffActionVertigoPool.Destroy();
            PlayGroupFxPool.Destroy();
            BuffActionWeakPool.Destroy();
            BuffActionUnVisibilityPool.Destroy();
            BuffActionRemoveDebuffPool.Destroy();
            BuffActionDragPool.Destroy();
            BuffActionSkillNoConsumptionPool.Destroy();
            BuffActionDisableSkillPool.Destroy();
            BuffActionAttrModifierPool.Destroy();
            BuffActionRemoveMatchBuffPool.Destroy();
            BuffActionPlayFxPool.Destroy();
            WwiseEventList.Destroy();
            BuffActionChangeMaxHPPool.Destroy();
            BuffActionWitchTimePool.Destroy();
            BuffActionPlayPPVPool.Destroy();

            WwiseEventList = null;
            AddTauntPool = null;
            AddActorStateTagPool = null;
            BuffActionHaloPool = null;
            BuffEndDamagePool = null;
            BuffHPShieldPool = null;
            BuffLockHPPool = null;
            BuffModifySkillDamagePool = null;
            DynamicChangeAttrPool = null;
            DynamicDamageModifyPool = null;
            ForbidEnergyRecoverPool = null;
            PlayMatAnimPool = null;
            SetToughnessPool = null;
            BuffActionGhostPool = null;
            BuffActionFrozenPool = null;
            BuffActionVertigoPool = null;
            PlayGroupFxPool = null;
            BuffActionWeakPool = null;
            BuffActionUnVisibilityPool = null;
            BuffActionRemoveDebuffPool = null;
            BuffActionDragPool = null;
            BuffActionSkillNoConsumptionPool = null;
            BuffActionDisableSkillPool = null;
            BuffActionAttrModifierPool = null;
            BuffActionRemoveMatchBuffPool = null;
            BuffActionPlayFxPool = null;
            BuffActionChangeMaxHPPool = null;
            BuffActionWitchTimePool = null;
            BuffActionPlayPPVPool = null;

            //指令缓存
            foreach (var pool in ActorCmdPool.Values)
            {
                pool.Destroy();
            }

            ActorCmdPool.Clear();
            ActorCmdPool = null;

            foreach (var pool in ActorBornCfgPool.Values)
            {
                pool.Destroy();
            }

            ActorBornCfgPool.Clear();
            ActorBornCfgPool = null;

            AttrModifyListPool.Destroy();
            AttrModifyListPool = null;

            CollisionInfoListPool.Destroy();
            CollisionInfoListPool = null;

            RicochetShareData.Destroy();
            RicochetShareData = null;

            CheatBuffPool.Destroy();
            CheatAttrChangePool.Destroy();
            CheatCastSkillPool.Destroy();
            CheatEndSkillPool.Destroy();
            CheatOnKillPool.Destroy();
            CheatActorPool.Destroy();
            CheatLockHpPool.Destroy();
            CheatSkillPool.Destroy();
            CheatHurtPool.Destroy();
            ActorGroupPool.Destroy();
            BoundingShapePool.Destroy();
            
            CheatAttrPool.Destroy();
            CheatCoreChangePool.Destroy();
            CheatTauntChangePool.Destroy();
            CheatBattleEndPool.Destroy();
            

            CheatBuffPool = null;
            CheatAttrChangePool = null;
            CheatCastSkillPool = null;
            CheatEndSkillPool = null;
            CheatOnKillPool = null;
            CheatActorPool = null;
            CheatLockHpPool = null;
            CheatSkillPool = null;
            CheatHurtPool = null;
            CheatBuffEventPool = null;
            ActorGroupPool = null;
            BoundingShapePool = null;
            CheatAttrPool = null;
            CheatCoreChangePool = null;
            CheatTauntChangePool = null;
            CheatBattleEndPool = null;
            
            FlowScriptControllerPool.Destroy();
            FlowScriptControllerPool = null;

            foreach (var pool in AIActionGoalPool.Values)
            {
                pool.Destroy();
            }

            AIActionGoalPool.Clear();
            AIActionGoalPool = null;

            foreach (var pool in AIConditionGoalPool.Values)
            {
                pool.Destroy();
            }

            AIConditionGoalPool.Clear();
            AIConditionGoalPool = null;
            
            DialogueNodePool.Destroy();
            DialogueNodePool = null;
            
            foreach (var pool in ActorPointCfgPool.Values)
            {
                pool.Destroy();
            }

            ActorPointCfgPool.Clear();
            ActorPointCfgPool = null;
        }

        public static void ReleaseActorCmd(ActorCmd cmd)
        {
            if (null == cmd) return;
            ;
            var type = cmd.GetType();
            if (ActorCmdPool.TryGetValue(type, out var pool))
            {
                pool.Release(cmd);
            }
        }

        public static T GetActorCmd<T>() where T : ActorCmd
        {
            var type = typeof(T);
            if (ActorCmdPool.TryGetValue(type, out var pool))
            {
                return pool.Get() as T;
            }

            return default;
        }

        public static void ReleaseActorBornCfg(ActorBornCfg cfg)
        {
            if (null == cfg) return;
            var type = cfg.GetType();
            if (ActorBornCfgPool.TryGetValue(type, out var pool))
            {
                pool.Release(cfg);
            }
        }

        public static T GetActorBornCfg<T>() where T : ActorBornCfg
        {
            var type = typeof(T);
            if (ActorBornCfgPool.TryGetValue(type, out var pool))
            {
                return pool.Get() as T;
            }

            return default;
        }

        public static void ReleaseActorPointCfg(ActorPointBase cfg)
        {
            if (null == cfg) return;
            var type = cfg.GetType();
            if (ActorPointCfgPool.TryGetValue(type, out var pool))
            {
                pool.Release(cfg);
            }
        }

        public static T GetActorPointCfg<T>() where T : ActorPointBase
        {
            var type = typeof(T);
            if (ActorPointCfgPool.TryGetValue(type, out var pool))
            {
                return pool.Get() as T;
            }

            return default;
        }
        
        public static void ReleaseAIActionGoal(IAIActionGoal goal)
        {
            if (null == goal) return;
            var type = goal.GetType();
            if (AIActionGoalPool.TryGetValue(type, out var pool))
            {
                pool.Release(goal);
            }
        }

        public static T GetAIActionGoal<T>() where T : class, IAIActionGoal
        {
            var type = typeof(T);
            if (AIActionGoalPool.TryGetValue(type, out var pool))
            {
                return pool.Get() as T;
            }

            return default;
        }

        public static void ReleaseAIConditionGoal(IAIConditionGoal goal)
        {
            if (null == goal) return;
            ;
            var type = goal.GetType();
            if (AIConditionGoalPool.TryGetValue(type, out var pool))
            {
                pool.Release(goal);
            }
        }

        public static T GetAIConditionGoal<T>() where T : class, IAIConditionGoal
        {
            var type = typeof(T);
            if (AIConditionGoalPool.TryGetValue(type, out var pool))
            {
                return pool.Get() as T;
            }

            return default;
        }
    }
}
