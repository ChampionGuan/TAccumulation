using Unity.Profiling;

namespace X3Battle
{
    public static class ProfilerDefine
    {
        // Actor
        public static ProfilerMarker ActorBornPMarker = new ProfilerMarker("Actor.Born()");
        public static ProfilerMarker ActorDeadPMarker = new ProfilerMarker("Actor.Dead()");
        public static ProfilerMarker ActorRecyclePMarker = new ProfilerMarker("Actor.Recycle()");
        public static ProfilerMarker ActorPlayFxPMarker = new ProfilerMarker("Actor.PlayFx()");
        public static ProfilerMarker ActorPlayGroupFxPMarker = new ProfilerMarker("Actor.PlayGroupFx()");
        public static ProfilerMarker ActorPlayWarnFxPMarker = new ProfilerMarker("Actor.PlayWarnFx()");
        public static ProfilerMarker ActorPlaySoundPMarker = new ProfilerMarker("Actor.PlaySound()");

        //BattleClient
        public static ProfilerMarker BattleClientUpdatePMarker = new ProfilerMarker("BattleClient.Update()");
        public static ProfilerMarker BattleClientAnimationJobRunningPMarker = new ProfilerMarker("BattleClient.AnimationJobRunning()");
        public static ProfilerMarker BattleClientAnimationJobCompletedPMarker = new ProfilerMarker("BattleClient.AnimationJobCompleted()");
        public static ProfilerMarker BattleClientLateUpdatePMarker = new ProfilerMarker("BattleClient.LateUpdate()");
        public static ProfilerMarker BattleClientPhysicalJobRunningPMarker = new ProfilerMarker("BattleClient.PhysicalJobRunning()");
        public static ProfilerMarker BattleClientFixedUpdatePMarker = new ProfilerMarker("BattleClient.FixedUpdate()");
        public static ProfilerMarker BattleClientStartupPMarker = new ProfilerMarker("BattleClient.Startup()");
        public static ProfilerMarker BattleClientPreloadPMarker = new ProfilerMarker("BattleClient.Preload()");
        public static ProfilerMarker BattleClientStartupFinishedPMarker = new ProfilerMarker("BattleClient.StartupFinished()");
        public static ProfilerMarker BattleClientShutdownPMarker = new ProfilerMarker("BattleClient.Shutdown()");
        public static ProfilerMarker BattleClientBeginPMarker = new ProfilerMarker("BattleClient.Begin()");
        public static ProfilerMarker BattleClientEndPMarker = new ProfilerMarker("BattleClient.End()");

        //OfflineBattleFramework
        public static ProfilerMarker InitLuaEnvPMarker = new ProfilerMarker("InitLuaEnv");
        public static ProfilerMarker CreateAnalyzeOfflineDataPMarker = new ProfilerMarker("CreateAnalyzeOfflineData");
        public static ProfilerMarker EditorTrySwitchAutoPMarker = new ProfilerMarker("PlayerInput.TrySwitchAuto()");

        //ECEventMgr
        public static ProfilerMarker ECEventMgrDispatchPMarker = new ProfilerMarker("ECEventMgr.Dispatch()");

        //AutoEventChecker
        public static ProfilerMarker OnCustomEventOnEnablePMarker = new ProfilerMarker("AutoEventChecker.OnCustomEvent.OnEnable");
        public static ProfilerMarker OnCustomEventOnDisablePMarker = new ProfilerMarker("AutoEventChecker.OnCustomEvent.OnDisable");
        public static ProfilerMarker OnCustomEventPMarker = new ProfilerMarker("AutoEventChecker.OnCustomEvent");
        public static ProfilerMarker OnCustomEvent1PMarker = new ProfilerMarker("AutoEventChecker.OnCustomEvent.11111");
        public static ProfilerMarker OnCustomEvent2PMarker = new ProfilerMarker("AutoEventChecker.OnCustomEvent.22222");
        public static ProfilerMarker OnCustomEvent3PMarker = new ProfilerMarker("AutoEventChecker.OnCustomEvent.33333");

        //FxMgr
        public static ProfilerMarker FxMgrRequestPMarker = new ProfilerMarker("FxMgr.Request()");
        public static ProfilerMarker FxMgrUpdatePMarker = new ProfilerMarker("FxMgr.Update()");
        public static ProfilerMarker FxMgrLoadFxPMarker = new ProfilerMarker("FxMgr.LoadFx");
        public static ProfilerMarker FxMgrUnloadFxPMarker = new ProfilerMarker("FxMgr.Unload");

        //DynamicDamageModify
        public static ProfilerMarker DynamicDamageModifyOnBeforeHitPMarker = new ProfilerMarker("DynamicDamageModify._OnBeforeHit");
        public static ProfilerMarker DynamicDamageModifyAttrModifiesPMarker = new ProfilerMarker("DynamicDamageModify._OnBeforeHit.attrModifies");

        //X3Buff
        public static ProfilerMarker SendBuffAddEventPMarker = new ProfilerMarker("X3Buff.SendBuffAddEvent");
        public static ProfilerMarker X3BuffAddLayerPMarker = new ProfilerMarker("X3Buff.AddLayer");
        public static ProfilerMarker X3BuffReduceLayerPMarker = new ProfilerMarker("X3Buff.ReduceLayer");

        //QTEController
        public static ProfilerMarker SetQTEPositionPMarker = new ProfilerMarker("QTE SetQTEPosition");

        //MissileMotionBezier
        public static ProfilerMarker MissileMotionBezierOnStartPMarker = new ProfilerMarker("MissileMotionBezier._OnStart");
        public static ProfilerMarker MissileMotionBezierOnUpdatePMarker = new ProfilerMarker("MissileMotionBezier._OnUpdate");

        //Shadow
        public static ProfilerMarker ShadowShowPMarker = new ProfilerMarker("Shadow.Show");
        public static ProfilerMarker ShadowSyncTransformPMarker = new ProfilerMarker("Shadow.SyncTransform");
        public static ProfilerMarker ShadowHidePMarker = new ProfilerMarker("Shadow.Hide");
        public static ProfilerMarker ShadowUpdateColorPMarker = new ProfilerMarker("Shadow.UpdateColor");

        //ActorCommander
        public static ProfilerMarker ActorCommanderTryExecutePMarker = new ProfilerMarker("ActorCommander.TryExecute");

        //ActorMainState
        public static ProfilerMarker ActorMainStateMainFSMRestartPMarker = new ProfilerMarker("ActorMainState.MainFSM.Restart");
        public static ProfilerMarker ActorMainStateMainFSMDisablePMarker = new ProfilerMarker("ActorMainState.MainFSM.Disable");
        public static ProfilerMarker ActorMainStateFsmOwnerOnUpdatePMarker = new ProfilerMarker("ActorMainState.FsmOwner.OnUpdate");
        public static ProfilerMarker ActorMainStateSubStateUpdatePMarker = new ProfilerMarker("ActorMainState.SubState.Update");

        //ActorWeak
        public static ProfilerMarker ActorWeakShieldBreakPMarker = new ProfilerMarker("ActorWeak.ShieldBreak");
        public static ProfilerMarker ActorWeakShieldReducePMarker = new ProfilerMarker("ActorWeak.ShieldReduce");
        public static ProfilerMarker ActorWeakPlayFxPMarker = new ProfilerMarker("ActorWeak.PlayFx");
        public static ProfilerMarker ActorWeakDispatchPMarker = new ProfilerMarker("ActorWeak.Dispatch");

        //TimelineMotion
        public static ProfilerMarker TimelineMotionSetTimePMarker = new ProfilerMarker("TimelineMotion.SetTime");
        public static ProfilerMarker TimelineMotionOnExitPMarker = new ProfilerMarker("TimelineMotion.OnExit");

        //AttributeOwner
        public static ProfilerMarker AttributeOwnerOnbornPMarker = new ProfilerMarker("AttributeOwner.Onborn");
        public static ProfilerMarker AttributeOwnerATTR_TYPESPMarker = new ProfilerMarker("AttributeOwner.Onborn.ATTR_TYPES");
        public static ProfilerMarker AttributeOwnerExecuteModifyPMarker = new ProfilerMarker("AttributeOwner.ExecuteModify");

        //ActorCmd
        public static ProfilerMarker ActorCmdStartPMarker = new ProfilerMarker("ActorCmd.Start");

        //ActorDamageMeters
        public static ProfilerMarker ActorDamageMetersOnExportDamagePMarker = new ProfilerMarker("ActorDamageMeters._OnExportDamage");

        //AIOwner
        public static ProfilerMarker CombatAIUpdatePMarker = new ProfilerMarker("_combatAI.Update");
        public static ProfilerMarker AIOwnerSetCombatTreeStatusPMarker = new ProfilerMarker(" AIOwner.SetCombatTreeStatus");

        //ActorSequencePlayer
        public static ProfilerMarker ActorSequencePlayerCreatePMarker = new ProfilerMarker("ActorSequencePlayer._Create");

        //HaloOwner
        public static ProfilerMarker HaloOwnerAddHaloPMarker = new ProfilerMarker("HaloOwner.AddHalo");
        public static ProfilerMarker HaloOwnerRemoveHaloPMarker = new ProfilerMarker("HaloOwner.RemoveHalo");

        //NotionGraph
        public static ProfilerMarker NotionGraphInitIsExistsPMarker = new ProfilerMarker("NotionGraph.Init.IsExists");

        //ActorWeapon
        public static ProfilerMarker ActorWeaponBakeOnAnimStateChangePMarker = new ProfilerMarker("ActorWeapon._OnAnimStateChange");
        public static ProfilerMarker ActorWeaponBakeWeaponFollowPMarker = new ProfilerMarker("ActorWeapon._BakeWeaponFollow");
        public static ProfilerMarker ActorWeaponMarkHideWeaponPMarker = new ProfilerMarker("ActorWeapon._MarkHideWeapon");
        public static ProfilerMarker ActorWeaponNewStateHidePMarker = new ProfilerMarker("ActorWeapon.NewState = Hide");
        public static ProfilerMarker ActorWeaponNewStateShowPMarker = new ProfilerMarker("ActorWeapon.NewState = Show");
        public static ProfilerMarker ActorWeaponInitBakeWeaponCurveAnimatorBakeMeshPMarker = new ProfilerMarker("ActorWeapon._InitBakeWeaponCurveAnimator.BakeMesh");
        public static ProfilerMarker ActorWeaponInitBakeWeaponCurveAnimatorAddCurveAnimatorPMarker = new ProfilerMarker("ActorWeapon._InitBakeWeaponCurveAnimator.AddCurveAnimator");
        public static ProfilerMarker ActorWeaponFadeOutWeaponPlayFadeOutFxPMarker = new ProfilerMarker("ActorWeapon._FadeOutWeapon.PlayFadeOutFx");
        public static ProfilerMarker ActorWeaponFadeOutWeaponPlayFadeOutSoundPMarker = new ProfilerMarker("ActorWeapon._FadeOutWeapon.PlayFadeOutSound");
        public static ProfilerMarker ActorWeaponFadeOutWeaponPlayHideWeaponPMarker = new ProfilerMarker("ActorWeapon._FadeOutWeapon._PlayHideWeapon");
        public static ProfilerMarker ActorWeaponFadeOutWeaponHideWeaponGOPMarker = new ProfilerMarker("ActorWeapon._FadeOutWeapon._HideWeaponGO");
        public static ProfilerMarker ActorWeaponGetCurVisibleWeaponPartNamePMarker = new ProfilerMarker("ActorWeapon._GetCurVisibleWeaponPartName");
        public static ProfilerMarker ActorWeaponPlayHideWeaponBakeMeshPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.BakeMesh");
        public static ProfilerMarker ActorWeaponPlayHideWeaponSetVisiblePMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.SetVisible");
        public static ProfilerMarker ActorWeaponPlayHideWeaponbakeHidePosPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon._bakeHidePos");
        public static ProfilerMarker ActorWeaponPlayHideWeaponSetParentPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.SetParent");
        public static ProfilerMarker ActorWeaponPlayHideWeaponAddCurveAnimatorPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.Add CurveAnimator");
        public static ProfilerMarker ActorWeaponPlayHideWeaponCurveAnimAssetLoadPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.CurveAnimAsset.Load");
        public static ProfilerMarker ActorWeaponPlayHideWeaponCurveAnimatorPlayPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.CurveAnimator.Play");
        public static ProfilerMarker ActorWeaponPlayHideWeaponTimerInfoPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.TimerInfo");
        public static ProfilerMarker ActorWeaponPlayHideWeaponAddTimerPMarker = new ProfilerMarker("ActorWeapon._PlayHideWeapon.AddTimer");

        //ActorTimeScaler
        public static ProfilerMarker ActorTimeScalerSetWitchTimePMarker = new ProfilerMarker("ActorTimeScaler.SetWitchTime()");
        public static ProfilerMarker ActorTimeScalePauseActorSoundsPMarker = new ProfilerMarker("ActorTimeScale.PauseActorSounds()");

        // AI
        public static ProfilerMarker AICanEnterMovePMarker = new ProfilerMarker("_combatAI.OnVerifyingConditions.CanEnterMove");
        public static ProfilerMarker AICanMoveInterruptPMarker = new ProfilerMarker("_combatAI.OnVerifyingConditions.CanMoveInterrupt");
        public static ProfilerMarker AIHasWaitCurrActionPMarker = new ProfilerMarker("_combatAI.OnVerifyingConditions.HasWaitCurrActionCondition");
        public static ProfilerMarker AIActorIsDeadOrLockIgnore = new ProfilerMarker("_combatAI.OnVerifyingConditions.ActorIsDeadOrLockIgnore");
        public static ProfilerMarker AICanCastSkillBySlot1PMarker = new ProfilerMarker("_combatAI.OnVerifyingConditions.CanCastSkillBySlot1");
        public static ProfilerMarker AICanCastSkillBySlot2PMarker = new ProfilerMarker("_combatAI.OnVerifyingConditions.CanCastSkillBySlot2");
        public static ProfilerMarker AITickSubTreeGoalIsStatePMarker = new ProfilerMarker("_combatAI.OnVerifyingConditions.IsState");
        public static ProfilerMarker AITickSubTreeGoalIsMoveEndAnimPMarker = new ProfilerMarker("_combatAI.OnVerifyingConditions.IsMoveEndAnim");
        public static ProfilerMarker AISwitchCurrentSubTreePMarker = new ProfilerMarker("_combatAI.SwitchCurrentSubTree");
        public static ProfilerMarker AIBackToOriginalSubTreePMarker = new ProfilerMarker("_combatAI.BackToOriginalSubTree");
        public static ProfilerMarker AITickActionPMarker = new ProfilerMarker("_combatAI._TickAction");
        public static ProfilerMarker AIGenerateAndExecuteActionPMarker = new ProfilerMarker("_combatAI._GenerateAndExecuteAction");
        public static ProfilerMarker AIExecuteActionPMarker = new ProfilerMarker("_combatAI._ExecuteAction");

        // BattleAnimator
        public static ProfilerMarker AnimatorUpdatePMarker = new ProfilerMarker("BattleAnimator.Update");
        public static ProfilerMarker AnimatorSetDeltaTimePMarker = new ProfilerMarker("BattleAnimator.SetDeltaTransform()");

        // ActorHurt
        public static ProfilerMarker HurtUpdatePMarker = new ProfilerMarker("ActorHurt.OnUpdate");
        public static ProfilerMarker HurtUpdateHurtBackPMarker = new ProfilerMarker("ActorHurt._UpdateHurtBack");
        public static ProfilerMarker HurtEffectHurtIgnorePMarker = new ProfilerMarker("ActorHurt.TakeEffect.HurtIgnore");
        public static ProfilerMarker HurtEffectCheckHurtPMarker = new ProfilerMarker("ActorHurt.TakeEffect.CheckHurt");
        public static ProfilerMarker HurtEffectIsAdditiveHurtUpdatePMarker = new ProfilerMarker("ActorHurt.TakeEffect.IsAdditiveHurt");
        public static ProfilerMarker HurtEffectLightHurtPMarker = new ProfilerMarker("ActorHurt.TakeEffect.LightHurt");
        public static ProfilerMarker HurtEffectCheckMonsterCfgPMarker = new ProfilerMarker("ActorHurt.TakeEffect.CheckMonsterCfg");
        public static ProfilerMarker HurtEffectHurtTypePMarker = new ProfilerMarker("ActorHurt.TakeEffect.hurtType");
        public static ProfilerMarker HurtEffectCalHurtDirPMarker = new ProfilerMarker("ActorHurt.TakeEffect.CalHurtDir");
        public static ProfilerMarker HurtEffectActorAbnormalTypePMarker = new ProfilerMarker("ActorHurt.TakeEffect.ActorAbnormalType");
        public static ProfilerMarker HurtEffectTryEndSkillPMarker = new ProfilerMarker("ActorHurt.TakeEffect.TryEndSkill");
        public static ProfilerMarker HurtEffectSendFSMEventPMarker = new ProfilerMarker("ActorHurt.TakeEffect.SendFSMEvent");
        public static ProfilerMarker HurtEffectSetScalePMarker = new ProfilerMarker("ActorHurt.TakeEffect.SetScale");
        public static ProfilerMarker HurtEffectPlayVirabratePMarker = new ProfilerMarker("ActorHurt.TakeEffect.PlayVirabrate");
        public static ProfilerMarker HurtBackParamHurtBackCurvePMarker = new ProfilerMarker("ActorHurt.TakeEffect.SetHurtBackParam.hurtBackCurve");
        public static ProfilerMarker HurtBackParamHurtHeightCurvePMarker = new ProfilerMarker("ActorHurt.TakeEffect.SetHurtBackParam.hurtHeightCurve");
        public static ProfilerMarker HurtBackSetPositionPMarker = new ProfilerMarker("ActorHurt.UpdateHurtBack.SetPosition");
        public static ProfilerMarker HurtPlayBoneShakePMarker = new ProfilerMarker("ActorHurt.PlayBoneShake");
        public static ProfilerMarker HurtOnFoundGroundPMarker = new ProfilerMarker("ActorHurt._OnFoundGround");

        // BuffOwner
        public static ProfilerMarker BuffsSortPMarker = new ProfilerMarker("BuffOwner.Buffs.Sort");
        public static ProfilerMarker BuffReduceStackPMarker = new ProfilerMarker("BuffOwner.ReduceStack");
        public static ProfilerMarker BuffDestroyPMarker = new ProfilerMarker("BuffOwner.DestroyBuff");
        public static ProfilerMarker BuffAddPMarker = new ProfilerMarker("BuffOwner.Add");
        public static ProfilerMarker BuffsCreateByConfigPMarker = new ProfilerMarker("BuffOwner.CreateBuffByConfig");
        public static ProfilerMarker BuffOnHurtPMarker = new ProfilerMarker("BuffOwner.OnHurt");
        public static ProfilerMarker BuffOnHurtGetBuffWithActionPMarker = new ProfilerMarker("BuffOwner.OnHurt.GetBuffWithAction");
        public static ProfilerMarker BuffOnHurtSortByBuffTimePMarker = new ProfilerMarker("BuffOwner.OnHurt.SortByBuffTime");
        public static ProfilerMarker BuffOnHurtDestroyBuffPMarker = new ProfilerMarker("BuffOwner.OnHurt.DestroyBuff");
        public static ProfilerMarker BuffCreatePMarker = new ProfilerMarker("BuffOwner.CreateBuffs");
        public static ProfilerMarker BuffRemovePMarker = new ProfilerMarker("BuffOwner.RemoveBuffs");

        // EnergyOwner
        public static ProfilerMarker EnergyEventEnergyExhaustedPMarker = new ProfilerMarker("BuffOwner.EventEnergyExhausted");
        public static ProfilerMarker EnergyEventEnergyFullPMarker = new ProfilerMarker("BuffOwner.EventEnergyFull");

        // SkillOwner
        public static ProfilerMarker SkillEnergyJudgePMarker = new ProfilerMarker("SkillOwner.EnergyJudge");
        public static ProfilerMarker SkillStateTagJudgePMarker = new ProfilerMarker("SkillOwner.StateTagJudge");
        public static ProfilerMarker SkillDisableControllerJudgePMarker = new ProfilerMarker("SkillOwner.DisableControllerJudge");
        public static ProfilerMarker SkillLocomotionJudgePMarker = new ProfilerMarker("SkillOwner.LocomotionJudge");
        public static ProfilerMarker SkillLinkPriorityJudgePMarker = new ProfilerMarker("SkillOwner.LinkPriorityJudge");

        // BattleUtils
        public static ProfilerMarker UtilPickAOETargetPMarker = new ProfilerMarker("BattleUtil.PickAOETarget");
        public static ProfilerMarker UtilGetGroundHeightPMarker = new ProfilerMarker("BattleUtil.HeightInquirer.GetGroundHeight()");
        public static ProfilerMarker UtilGetNavMeshNearestPointPMarker = new ProfilerMarker("BattleUtil.GetNavMeshNearestPoint");
        public static ProfilerMarker UtilGetNavmeshPosPMarker = new ProfilerMarker("BattleUtil.GetNavmeshPos");
        public static ProfilerMarker UtilBattleUIActive1PMarker = new ProfilerMarker("BattleUtil.BattleUIActive1");
        public static ProfilerMarker UtilBattleUIActive2PMarker = new ProfilerMarker("BattleUtil.BattleUIActive2");
        public static ProfilerMarker UtilGoVisibleExtensionPMarker = new ProfilerMarker("BattleUtil.GoVisibleExtension._AddVisible()");
        public static ProfilerMarker UtilNavMeshSearchIsRightPointPMarker = new ProfilerMarker("BattleUtil_NavMesh.IsRightPoint");

        //CharacterMovement
        public static ProfilerMarker X3CharacterMovementMoveFunPMarker = new ProfilerMarker("X3CharacterMovement.MoveFun");
        public static ProfilerMarker CharacterMovementSimpleMovePMarker = new ProfilerMarker("CharacterMovement.SimpleMove");
        public static ProfilerMarker CharacterMovementSimplePerformMovementPMarker = new ProfilerMarker("CharacterMovement.SimplePerformMovement");
        public static ProfilerMarker CharacterMovementMovePMarker = new ProfilerMarker("CharacterMovement.Move");
        public static ProfilerMarker CharacterMovementResolveOverlapsPMarker = new ProfilerMarker("CharacterMovement.ResolveOverlaps");
        public static ProfilerMarker CharacterMovementPerformMovementPMarker = new ProfilerMarker("CharacterMovement.PerformMovement");
        public static ProfilerMarker CharacterMovementResolveDynamicCollisionsPMarker = new ProfilerMarker("CharacterMovement.ResolveDynamicCollisions");
        public static ProfilerMarker CharacterMovementFindGroundPMarker = new ProfilerMarker("CharacterMovement.FindGround");
        public static ProfilerMarker CharacterMovementAdjustGroundHeightPMarker = new ProfilerMarker("CharacterMovement.AdjustGroundHeight");
        public static ProfilerMarker CharacterMovementSetPositionAndRotationPMarker = new ProfilerMarker("CharacterMovement.SetPositionAndRotation");
        public static ProfilerMarker CharacterMovementOnFoundGroundPMarker = new ProfilerMarker("CharacterMovement.OnFoundGround");
        public static ProfilerMarker ComputeDynamicCollisionResponsePMarker = new ProfilerMarker("ComputeDynamicCollisionResponse");
        public static ProfilerMarker CharacterMovementSetPositionPMarker = new ProfilerMarker("CharacterMovement.SetPosition");
        public static ProfilerMarker SweepTestExPMarker = new ProfilerMarker("SweepTestEx");
        public static ProfilerMarker ResolvePenetrationPMarker = new ProfilerMarker("ResolvePenetration");
        public static ProfilerMarker CapsuleCastExPMarker = new ProfilerMarker("CapsuleCastEx");
        public static ProfilerMarker CqColliderComputeContactPMarker = new ProfilerMarker("CqCollider.ComputeContact");
        public static ProfilerMarker CapsuleCastPMarker = new ProfilerMarker("CapsuleCast");
        public static ProfilerMarker ComputeBlockingNormalPMarker = new ProfilerMarker("ComputeBlockingNormal");
        public static ProfilerMarker ShouldFilterPMarker = new ProfilerMarker("ShouldFilter");
        public static ProfilerMarker FindBoxOpposingNormalPMarker = new ProfilerMarker("FindBoxOpposingNormal");
        public static ProfilerMarker TransformSetPositionAndRotationPMarker = new ProfilerMarker("transform.SetPositionAndRotation");

        //LocomotionCtrl
        public static ProfilerMarker LocomotionCtrlUpdatePMarker = new ProfilerMarker("LocomotionCtrl.Update()");
        public static ProfilerMarker LocomotionCtrlUpdateMainStatePMarker = new ProfilerMarker("LocomotionCtrl._UpdateMainState()");
        public static ProfilerMarker LocomotionCtrlUpdateAnimStatePMarker = new ProfilerMarker("LocomotionCtrl._UpdateAnimState()");
        public static ProfilerMarker LocomotionCtrlLateUpdatePMarker = new ProfilerMarker("LocomotionCtrl.LateUpdate()");
        public static ProfilerMarker LocomotionCtrlUpdateMovePMarker = new ProfilerMarker("LocomotionCtrl._UpdateMove()");
        public static ProfilerMarker LocomotionCtrlUpdateRotationPMarker = new ProfilerMarker("LocomotionCtrl._UpdateRotation()");
        public static ProfilerMarker LocomotionCtrlSendFSMEventPMarker = new ProfilerMarker("LocomotionCtrl.SendFSMEvent()");

        //RMGridAgent
        public static ProfilerMarker BattleRMAgentSearchPathPMarker = new ProfilerMarker("BattleRMAgent SearchPath");

        //RMNavMeshAgent
        public static ProfilerMarker RMNavMeshAgentOnPathCompletePMarker = new ProfilerMarker("RMNavMeshAgent OnPathComplete");
        public static ProfilerMarker RMNavMeshAgentOnSearchPathPMarker = new ProfilerMarker("RMNavMeshAgent onSearchPath");

        //X3Physics
        public static ProfilerMarker CollisionCapsuleCastPMarker = new ProfilerMarker("Collision.CapsuleCast");

        //X3PhysicsExtension
        public static ProfilerMarker CollisionTestPMarker = new ProfilerMarker("CollisionTest");
        public static ProfilerMarker CollisionTestNoGCPMarker = new ProfilerMarker("CollisionTestNoGC");
        public static ProfilerMarker RayCastPMarker = new ProfilerMarker("RayCast");
        public static ProfilerMarker SphereCastPMarker = new ProfilerMarker("SphereCast");
        public static ProfilerMarker TriangleTestPMarker = new ProfilerMarker("TriangleTest");

        //X3UnityPhysics
        public static ProfilerMarker X3UnityPhysicsCollisionTestNoGCPMarker = new ProfilerMarker("X3UnityPhysics.CollisionTestNoGC");

        //BattleResTest
        public static ProfilerMarker TestSetRootActiveTruePMarker = new ProfilerMarker("TestSetRootActive True");
        public static ProfilerMarker TestSetRootActiveFalsePMarker = new ProfilerMarker("TestSetRootActive false");
        public static ProfilerMarker TestSetRootVisibleFalsePMarker = new ProfilerMarker("TestSetRootVisible false");
        public static ProfilerMarker TestSetRootVisibleTruePMarker = new ProfilerMarker("TestSetRootVisible true");
        public static ProfilerMarker AllActiveTruePMarker = new ProfilerMarker("AllActive True");
        public static ProfilerMarker AllActiveFalsePMarker = new ProfilerMarker("AllActive false");
        public static ProfilerMarker AllVisibleFalsePMarker = new ProfilerMarker("AllVisible false");
        public static ProfilerMarker AllVisibleTruePMarker = new ProfilerMarker("AllVisible true");

        //BattleCheatStatistics
        public static ProfilerMarker BattleCheatStatisticsOnExportDamagePMarker = new ProfilerMarker("BattleCheatStatistics._OnExportDamage");

        //TriggerFlow
        public static ProfilerMarker TriggerFlowSetVariableValuePMarker = new ProfilerMarker("TriggerFlow.SetVariableValue");

        //TriggerMgr
        public static ProfilerMarker TriggerMgrAddTriggerPMarker = new ProfilerMarker("TriggerMgr.AddTrigger");

        //Battle
        public static ProfilerMarker BattlePhysicTickPMarker = new ProfilerMarker("Battle.PhysicTick");

        //BattleExtension
        public static ProfilerMarker BattleExtensionSetActorsWitchTimeExclusionPMarker = new ProfilerMarker("BattleExtension.SetActorsWitchTime_Exclusion()");
        public static ProfilerMarker BattleExtensionSetActorsWitchTimeInclusionPMarker = new ProfilerMarker("BattleExtension.SetActorsWitchTime_Inclusion()");

        //DamageProcess
        public static ProfilerMarker DamageProcess_ExportDamage_PMarker = new ProfilerMarker(nameof(DamageProcess_ExportDamage_PMarker));
        public static ProfilerMarker DamageProcess_FilterRules_PMarker = new ProfilerMarker(nameof(DamageProcess_FilterRules_PMarker));
        public static ProfilerMarker DamageProcess_SortHitTargets_PMarker = new ProfilerMarker(nameof(DamageProcess_SortHitTargets_PMarker));
        public static ProfilerMarker DamageProcess_PlayCameraShake_PMarker = new ProfilerMarker(nameof(DamageProcess_PlayCameraShake_PMarker));
        public static ProfilerMarker DamageProcess_TryExecute_PMarker = new ProfilerMarker(nameof(DamageProcess_TryExecute_PMarker));
        public static ProfilerMarker DamageProcess_ExportedDamageAction_PMarker = new ProfilerMarker(nameof(DamageProcess_ExportedDamageAction_PMarker));
        public static ProfilerMarker DamageProcess_EventHitProcessStartDispatch_PMarker = new ProfilerMarker(nameof(DamageProcess_EventHitProcessStartDispatch_PMarker));
        public static ProfilerMarker DamageProcess_EventHitProcessEndDispatch_PMarker = new ProfilerMarker(nameof(DamageProcess_EventHitProcessEndDispatch_PMarker));
        public static ProfilerMarker DamageProcess_EventBeforeHitDispatch_PMarker = new ProfilerMarker(nameof(DamageProcess_EventBeforeHitDispatch_PMarker));
        public static ProfilerMarker DamageProcess_CriticalJudge_PMarker = new ProfilerMarker(nameof(DamageProcess_CriticalJudge_PMarker));
        public static ProfilerMarker DamageProcess_EventCriticalJudgeDispatch_PMarker = new ProfilerMarker(nameof(DamageProcess_EventCriticalJudgeDispatch_PMarker));
        public static ProfilerMarker DamageProcess_PrevDamage_PMarker = new ProfilerMarker(nameof(DamageProcess_PrevDamage_PMarker));
        public static ProfilerMarker DamageProcess_IsInterruptHitProcess_PMarker = new ProfilerMarker(nameof(DamageProcess_IsInterruptHitProcess_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_Target_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_Target_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_Caster_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_Caster_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_OnDamageInvalid_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_OnDamageInvalid_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_CalcDamage_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_CalcDamage_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_CalcHeal_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_CalcHeal_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_CalcDeduct_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_CalcDeduct_PMarker));
        public static ProfilerMarker DamageProcess_TakeDamage_EventExportDamage_PMarker = new ProfilerMarker(nameof(DamageProcess_TakeDamage_EventExportDamage_PMarker));
        public static ProfilerMarker DamageProcess_HitEffect_PMarker = new ProfilerMarker(nameof(DamageProcess_HitEffect_PMarker));
        public static ProfilerMarker DamageProcess_HitEffect_PlayHurtFX_PMarker = new ProfilerMarker(nameof(DamageProcess_HitEffect_PlayHurtFX_PMarker));
        public static ProfilerMarker DamageProcess_HitEffect_PlayHurtFX_PlayFx__PMarker = new ProfilerMarker(nameof(DamageProcess_HitEffect_PlayHurtFX_PlayFx__PMarker));
        public static ProfilerMarker DamageProcess_HitEffect_PlaySound_PMarker = new ProfilerMarker(nameof(DamageProcess_HitEffect_PlaySound_PMarker));
        public static ProfilerMarker DamageProcess_HitEffect_PlayMatAnimator_PMarker = new ProfilerMarker(nameof(DamageProcess_HitEffect_PlayMatAnimator_PMarker));
        public static ProfilerMarker DamageProcess_AfterHit_PMarker = new ProfilerMarker(nameof(DamageProcess_AfterHit_PMarker));
        public static ProfilerMarker DamageProcess_TryDead_PMarker = new ProfilerMarker(nameof(DamageProcess_TryDead_PMarker));
        public static ProfilerMarker DamageProcess_TryDead_EventOnKillTarget_PMarker = new ProfilerMarker(nameof(DamageProcess_TryDead_EventOnKillTarget_PMarker));
        public static ProfilerMarker DamageProcess_EventPrevDamage_PMarker = new ProfilerMarker(nameof(DamageProcess_EventPrevDamage_PMarker));
        public static ProfilerMarker DamageProcess_BrokenToughness_PMarker = new ProfilerMarker(nameof(DamageProcess_BrokenToughness_PMarker));
        public static ProfilerMarker DamageProcess_BrokenToughness_HurtDir_PMarker = new ProfilerMarker(nameof(DamageProcess_BrokenToughness_HurtDir_PMarker));
        public static ProfilerMarker DamageProcess_BrokenToughness_OnEventEnterHurt_PMarker = new ProfilerMarker(nameof(DamageProcess_BrokenToughness_OnEventEnterHurt_PMarker));
        public static ProfilerMarker DamageProcess_ResourceCost_PMarker = new ProfilerMarker(nameof(DamageProcess_ResourceCost_PMarker));
        public static ProfilerMarker DamageProcess_BrokenShield_PMarker = new ProfilerMarker(nameof(DamageProcess_BrokenShield_PMarker));

        // DamageBox
        public static ProfilerMarker DamageBox_CastDamageBox_Evaluate_Once = new ProfilerMarker(nameof(DamageBox_CastDamageBox_Evaluate_Once));
        public static ProfilerMarker DamageBox_CastDamageBox_Evaluate_PeriodCount = new ProfilerMarker(nameof(DamageBox_CastDamageBox_Evaluate_PeriodCount));
        public static ProfilerMarker DamageBox_CastDamageBox_Evaluate_ActorCDCount = new ProfilerMarker(nameof(DamageBox_CastDamageBox_Evaluate_ActorCDCount));
        public static ProfilerMarker DamageBox_CastDamageBox_PhysicsDamageBox = new ProfilerMarker(nameof(DamageBox_CastDamageBox_PhysicsDamageBox));
        public static ProfilerMarker DamageBox_CastDamageBox_DirectDamageBox = new ProfilerMarker(nameof(DamageBox_CastDamageBox_DirectDamageBox));
        public static ProfilerMarker DamageBox_CastDamageBox_TryEvaluate = new ProfilerMarker(nameof(DamageBox_CastDamageBox_TryEvaluate));
        public static ProfilerMarker DamageBox_DirectDamageBox_PickDamageBoxTargets = new ProfilerMarker(nameof(DamageBox_DirectDamageBox_PickDamageBoxTargets));
        public static ProfilerMarker DamageBox_PhysicsDamageBox_PickDamageBoxTargets = new ProfilerMarker(nameof(DamageBox_PhysicsDamageBox_PickDamageBoxTargets));

        public static ProfilerMarker GetDialogueByKey = new ProfilerMarker("ActorDialogue._GetDialogueByKey");
        public static ProfilerMarker GetDialogueByKeyRange = new ProfilerMarker("ActorDialogue._GetDialogueByKey Range");
        public static ProfilerMarker GetDialogueByKeyConfig = new ProfilerMarker("ActorDialogue._GetDialogueByKeyConfig");

        public static ProfilerMarker InsertToActorGroup = new ProfilerMarker("ActorMgr._InsertToActorGroup");
        public static ProfilerMarker CreateActor = new ProfilerMarker("ActorMgr.CreateActor()");

        public static ProfilerMarker LuaOnFireEvent = new ProfilerMarker("LuaClient._OnFireEvent");
        public static ProfilerMarker LuaAddEventForDelayHandle = new ProfilerMarker("LuaClient._AddEventForDelayHandle");

        public static ProfilerMarker LoadSceneNavMesh = new ProfilerMarker("BattleEnvironment.LoadSceneNavMesh()");

        public static ProfilerMarker PPVMgrPlay = new ProfilerMarker("BattlePPVMgr.Play()");

        public static ProfilerMarker BattleTimelinePlayerPlaySceneEffect = new ProfilerMarker("BattleTimelinePlayer.PlaySceneEffect");
        public static ProfilerMarker BattleTimelinePlayerPlayPerformFrame1 = new ProfilerMarker("BattleTimelinePlayer.PlayPerformFrame1");
        public static ProfilerMarker BattleTimelinePlayerPlayPerformFrame2 = new ProfilerMarker("BattleTimelinePlayer.PlayPerformFrame2");
        public static ProfilerMarker BattleTimelinePlayerStopPerformFrame1 = new ProfilerMarker("BattleTimelinePlayer.StopPerformFrame1");
        public static ProfilerMarker BattleTimelinePlayerStopPerformFrame2 = new ProfilerMarker("BattleTimelinePlayer.StopPerformFrame2");

        public static ProfilerMarker PerformStartStep1 = new ProfilerMarker("_PerformStartStep1");
        public static ProfilerMarker PerformStopBattle = new ProfilerMarker("Perform.StopBattle");
        public static ProfilerMarker PerformStartStep2 = new ProfilerMarker("_PerformStartStep2");
        public static ProfilerMarker PerformHideUI = new ProfilerMarker("Perform.HideUI");
        public static ProfilerMarker PerformHideScene = new ProfilerMarker("Perform.HideScene");
        public static ProfilerMarker PerformPPVDisable = new ProfilerMarker("Perform.PPV Disable");
        public static ProfilerMarker PerformClosePlayerSceneLight = new ProfilerMarker("Perform.Close Player SceneLight");
        public static ProfilerMarker PerformStartUI = new ProfilerMarker("Perform.StartUI");
        public static ProfilerMarker PerformShowScene = new ProfilerMarker("Perform.ShowScene");
        public static ProfilerMarker PerformPPVEnable = new ProfilerMarker("Perform.PPV enable");
        public static ProfilerMarker PerformSwitchActorSceneLight = new ProfilerMarker("Perform.SwitchActorSceneLight");
        public static ProfilerMarker PerformEnd = new ProfilerMarker("Perform.End");
        public static ProfilerMarker PerformStartBattle = new ProfilerMarker("Perform.StartBattle");

        public static ProfilerMarker BattleStatisticsOnExportDamageTryGetEntityData = new ProfilerMarker("BattleStatistics.OnExportDamage.TryGetEntityData");
        public static ProfilerMarker BattleStatisticsOnExportDamageSetEntityData = new ProfilerMarker("BattleStatistics.OnExportDamage.SetEntityData");
        public static ProfilerMarker BattleStatisticsTryGetEntityData = new ProfilerMarker("BattleStatistics:TryGetEntityData");

        public static ProfilerMarker BattleUIPreLoadUIIcons = new ProfilerMarker("BattleUI.PreLoad UI Icons");
        public static ProfilerMarker BattleUIOnLateUpdateHudData = new ProfilerMarker("BattleUI.OnLateUpdate.HudData");
        public static ProfilerMarker BattleUIOnLateUpdateUiPlayableGraphListUpdate = new ProfilerMarker("BattleUI.OnLateUpdate._uiPlayableGraphList.update");
        public static ProfilerMarker BattleUIScreenFabe = new ProfilerMarker("BattleUI.ScreenFabe");
        public static ProfilerMarker BattleUIPlayableCreateUIPlayable = new ProfilerMarker("BattleUIPlayable _CreateUIPlayable");

        public static ProfilerMarker CameraImpulseAddWorldImpulseLoadAsset = new ProfilerMarker("CameraImpulse.AddWorldImpulse.LoadAsset");
        public static ProfilerMarker CameraImpulseAddWorldImpulseAddImpulse = new ProfilerMarker("CameraImpulse.AddWorldImpulse.AddImpulse");
        public static ProfilerMarker CameraImpulseAddWorldImpulseAddActorImpulse = new ProfilerMarker("CameraImpulse.AddWorldImpulse.AddActorImpulse");

        public static ProfilerMarker CameraTraceIsInSight = new ProfilerMarker("CameraTrace.IsInSight");

        // FloatWorldMgr
        public static ProfilerMarker FWorldSetFloatPMarker = new ProfilerMarker("FloatWordMgr.OnUpdate.SetFloatWordText()");
        public static ProfilerMarker FWorldDamageInvalidPMarker = new ProfilerMarker("FloatWordMgr._OnDamageInvalid");
        public static ProfilerMarker FWorldDamageInvalidCheckPMarker = new ProfilerMarker("FloatWordMgr._OnDamageInvalid._CheckDamage");
        public static ProfilerMarker FWorldDamageInvalidIsExistPMarker = new ProfilerMarker("FloatWordMgr._OnDamageInvalid.isExist");
        public static ProfilerMarker FWorldDamageInvalidShowPMarker = new ProfilerMarker("FloatWordMgr._OnDamageInvalid._ShowWord");
        public static ProfilerMarker FWorldDamageCheckGetActorDummyPMarker = new ProfilerMarker("FloatWordMgr._CheckDamage.GetActorDummy");
        public static ProfilerMarker FWorldDamagePMarker = new ProfilerMarker("FloatWordMgr._OnDamage");
        public static ProfilerMarker FWorldDamageCheckPMarker = new ProfilerMarker("FloatWordMgr._OnDamage._CheckDamage");
        public static ProfilerMarker FWorldDamageResNamePMarker = new ProfilerMarker("FloatWordMgr._OnDamage.resName");
        public static ProfilerMarker FWorldShowPMarker = new ProfilerMarker("FloatWordMgr._ShowWord");
        public static ProfilerMarker FWorldPlayPMarker = new ProfilerMarker("FloatWordMgr._PlayWord");

        // PlayerInput
        public static ProfilerMarker InputUpdateMovePMarker = new ProfilerMarker("PlayerInput.UpdateMove");
        public static ProfilerMarker InputGetCmd1PMarker = new ProfilerMarker("PlayerInput.GetCmd1");
        public static ProfilerMarker InputGetCmd2PMarker = new ProfilerMarker("PlayerInput.GetCmd2");
        public static ProfilerMarker InputManualSwitchTargetPMarker = new ProfilerMarker("PlayerInput.ManualSwitchTarget");
        public static ProfilerMarker InputCancelManualPMarker = new ProfilerMarker("PlayerInput.CancelManual");
        public static ProfilerMarker InputTrySwitchAutoPMarker = new ProfilerMarker("PlayerInput.TrySwitchAuto");
        public static ProfilerMarker InputPlayerBtnStateChangePMarker = new ProfilerMarker("PlayerInput.PlayerBtnStateChange");

        public static ProfilerMarker InputEndBattlePMarker = new ProfilerMarker("PlayerInput.EndBattle");

        //Sequence
        public static ProfilerMarker SequenceCameraShakeMarker = new ProfilerMarker("CameraShakeAsset._OnEnter()");
        public static ProfilerMarker SequenceCameraShakeAddListenerMarker = new ProfilerMarker("ActionCameraShake._OnEnter.EventWeakFull.AddListener");
        public static ProfilerMarker SequenceCameraShakeAddMarker = new ProfilerMarker("CameraShake._OnEnter.cameraImpulse.Add");

        public static ProfilerMarker SimpleAudioPlaySoundMarker = new ProfilerMarker("wwiseMgr.PlaySound");
        public static ProfilerMarker SimpleAudioSetSpeedMarker = new ProfilerMarker("wwiseMgr.SetSpeed");

        public static ProfilerMarker BSAActorAnimGetSpeedMarker = new ProfilerMarker("BSAActorAnim.getSpeed");

        public static ProfilerMarker PhysicsWindOnStartMarker = new ProfilerMarker("PhysicsWindBehaviour.OnStart");
        public static ProfilerMarker PhysicsWindOnStopMarker = new ProfilerMarker("PhysicsWindBehaviour.OnStop");

        public static ProfilerMarker GhostBehaviourOnStartMarker = new ProfilerMarker("GhostBehaviour.OnStart");
        public static ProfilerMarker GhostBehaviourOnProcessFrameMarker = new ProfilerMarker("GhostBehaviour.OnProcessFrame");
        public static ProfilerMarker GhostBehaviourOnStopMarker = new ProfilerMarker("GhostBehaviour.OnStop");

        public static ProfilerMarker GhostActionItemOnStartMarker = new ProfilerMarker("GhostActionItem.OnStart");
        public static ProfilerMarker GhostActionItemOnProcessFrameMarker = new ProfilerMarker("GhostActionItem.OnProcessFrame");
        public static ProfilerMarker GhostActionItemOnStopFrameMarker = new ProfilerMarker("GhostActionItem.OnStop");

        public static ProfilerMarker ActionLodOnEnterMarker = new ProfilerMarker("ActionLod.OnEnter");

        public static ProfilerMarker LODBehaviorOnStartMarker = new ProfilerMarker("LODBehavior.OnStart");

        public static ProfilerMarker ActionGhostOnStartMarker = new ProfilerMarker("ActionGhost.OnStart");
        public static ProfilerMarker ActionGhostOnProcessFrameMarker = new ProfilerMarker("ActionGhost.OnProcessFrame");
        public static ProfilerMarker ActionGhostOnStopFrameMarker = new ProfilerMarker("ActionGhost.OnStop");

        public static ProfilerMarker ActionStaticWindOnEnterMarker = new ProfilerMarker("ActionStaticWind.OnEnter");
        public static ProfilerMarker ActionStaticWindOnStopMarker = new ProfilerMarker("ActionStaticWind.OnStop");

        public static ProfilerMarker BSCPerformStartPlay1Marker = new ProfilerMarker("BSCPerform.StartPlay1");
        public static ProfilerMarker BSCPerformStartPlay2Marker = new ProfilerMarker("BSCPerform.StartPlay2");
        public static ProfilerMarker BSCPerformStartPlay3Marker = new ProfilerMarker("BSCPerform.StartPlay3");
        public static ProfilerMarker BSCPerformStopPlay1Marker = new ProfilerMarker("BSCPerform.StopPlay1");
        public static ProfilerMarker BSCPerformStopPlay2Marker = new ProfilerMarker("BSCPerform.StopPlay2");
        public static ProfilerMarker BSCPerformFindMonsterMarker = new ProfilerMarker("BSCPerform.FindMonster");

        public static ProfilerMarker AvatarBehaviourOnStartMarker = new ProfilerMarker("AvatarBehaviour.OnStart");

        public static ProfilerMarker ActionSimpleAudioPlaySoundMarker = new ProfilerMarker("ActionSimpleAudio.PlaySound");
        public static ProfilerMarker ActionSimpleAudioSetSpeedMarker = new ProfilerMarker("ActionSimpleAudio.SetSpeed");

        public static ProfilerMarker PreviewMissileMotionBezierOnStartMarker = new ProfilerMarker("PreviewMissileMotionBezier._OnStart");

        public static ProfilerMarker PhysicsWindDynamicBehaviourOnStartMarker = new ProfilerMarker("PhysicsWindDynamicBehaviour.OnStart");
        public static ProfilerMarker PhysicsWindDynamicBehaviourOnStopMarker = new ProfilerMarker("PhysicsWindDynamicBehaviour.OnStop");
        public static ProfilerMarker BattleTimerAddTimer1Marker = new ProfilerMarker("BattleTimer.AddTimer1");

        public static ProfilerMarker WwiseBattleManagerPlaySound1Marker = new ProfilerMarker("WwiseBattleManager.PlaySound1");
        public static ProfilerMarker WwiseBattleManagerPlaySound2Marker = new ProfilerMarker("WwiseBattleManager.PlaySound2");
        public static ProfilerMarker WwiseBattleManagerPlaySound3Marker = new ProfilerMarker("WwiseBattleManager.PlaySound3");

        public static ProfilerMarker WwiseManagerPlaySound1Marker = new ProfilerMarker("WwiseManager.PlaySound1");
        public static ProfilerMarker WwiseManagerPlaySound2Marker = new ProfilerMarker("WwiseManager.PlaySound2");
        public static ProfilerMarker WwiseManagerPlaySound3Marker = new ProfilerMarker("WwiseManager.PlaySound3");

        public static ProfilerMarker ActorToMainStateMatrix = new ProfilerMarker("ActorStateMatrix.CanToState()");
        public static ProfilerMarker ActorToAbnormalStateMatrix = new ProfilerMarker("ActorStateMatrix.CanToAbnormal()");
    }
}