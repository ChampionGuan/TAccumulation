using Framework;
using PapeGames.X3;
using UnityEngine;
using X3.CustomEvent;
using X3Battle.TargetSelect;
using X3Sequence;
using Random = UnityEngine.Random;

namespace X3Battle
{
    /// <summary>
    /// 战斗世界
    /// 继承自ECWorld
    /// </summary>
    public class Battle : ECWorld, IDeltaTime, IUnscaledDeltaTime
    {
        public static Battle Instance { get; private set; }

        public BattleArg arg { get; }
        public BattleLevelConfig config { get; private set; }

        public BattleRunStatus status { get; private set; }
        public BattleEndReason endReason { get; private set; }
        public bool isBegin => status == BattleRunStatus.Begin;
        public bool isEnd => status == BattleRunStatus.Fail || status == BattleRunStatus.Success;
        public bool isPreloading { get; private set; }

        public float unscaledDeltaTime => base.deltaTime;
        public new float deltaTime => timeScaler.deltaTime;
        public float time => timeScaler.time;
        public float timeScale => timeScaler.scale;
        public Actor player => actorMgr.player;

        public CustomEvent onAnimationJobCompleted { get; } = new CustomEvent();
        public ECEntity entity { get; private set; }
        public int enabledMask { get; private set; }

        public LevelFlowBase levelFlow => gameplay.levelFlow; //关卡流
        public BattleGameplayBase gameplay { get; private set; } //玩法实例
        public RogueGameplay rogue => gameplay as RogueGameplay; //肉鸽玩法

        public Transform root { get; } //战斗资源根对象
        public Transform actorRootTrans { get; } //所有Actor的根对象
        public Transform modelRootTrans { get; } //所有model的根对象
        public Transform timelineRootTrans { get; } // 所有Timeline的根对象
        public Transform performRootTrans { get; } // 表演的根对象

        protected TimeScaler timeScaler { get; private set; }
        public FxMgr fxMgr { get; private set; }
        public FrameUpdateMgr frameUpdateMgr { get; private set; }
        public ActorMgr actorMgr { get; private set; }
        public BattleSetting setting { get; private set; }
        public BattleGlobalBlackboard globalBlackboard { get; private set; }
        public CameraTrace cameraTrace { get; private set; }
        public CameraImpulse cameraImpulse { get; private set; }
        public BattlePPVMgr ppvMgr { get; private set; }
        public ActorDialogue dialogue { get; private set; }
        public BattleSequencePlayer sequencePlayer { get; private set; }
        public BattleDirGuide dirGuide { get; private set; }
        public PlayerSelectFx playerSelectFx { get; private set; }
        public BattleStrategy battleStrategy { get; private set; }
        public FloatWordMgr floatWordMgr { get; private set; }
        public BattleUI ui { get; private set; }
        public BattleMisc misc { get; private set; }
        public BattleStatistics statistics { get; private set; }
        public TriggerMgr triggerMgr { get; private set; }
        public BattleTimer battleTimer { get; private set; }
        public PlayerInput input { get; private set; }
        public BattleCheatStatistics cheatStatistics { get; private set; }
        public BattleModelMgr modelMgr { get; private set; }
        public BattlePvRecord pvRecord { get; private set; }
        public BattleDamageProcess damageProcess { get; private set; }
        public BattleGridPenaltyMgr gridPenaltyMgr { get; private set; }
        public WwiseBattleManager wwiseBattleManager { get; private set; }

        public Battle(BattleArg startupArg, Transform root) : base("BattleWorld")
        {
            if (Instance != null)
            {
                LogProxy.LogErrorFormat("【战斗启动异常】已有战斗实例存在，请确认是否重复创建，或者是上场战斗未成功ShutDown！！");
                return;
            }

            CriticalLog.Log("[战斗][启动流程][Battle.ctor()] 创建战斗!");

            arg = BattleEnv.StartupArg = startupArg;
            status = BattleRunStatus.Ready;
            config = TbUtil.GetCfg<BattleLevelConfig>(arg.levelID);
            Instance = this;

            this.root = root ? root : new GameObject("__Battle").transform;
            actorRootTrans = BattleUtil.EnsureChild(root, "ActorRoot");
            modelRootTrans = BattleUtil.EnsureChild(root, "ModelRoot");
            timelineRootTrans = BattleUtil.EnsureChild(root, "TimelineRoot");
            performRootTrans = BattleUtil.EnsureChild(root, "PerformRoot", new Vector3(0, 500f, 0f));

            zstring.Init();
            Sequencer.InternStrFunc = zstring.Intern;
            Random.InitState((int)Time.realtimeSinceStartup);
            ParadoxNotion.Services.EventRouter.InitPool(200);
            ParadoxNotion.EventData.InitPool(150);
            ObjectPoolUtility.Init();
            X3Physics.TryInit();
            BattleResMgr.Instance.TryInit();
            GoVisibleExtension.VisibleInfo.Preload(20);

            _CreatePostUpdateEvent();
            _CreatePostUpdateEntity();
            _CreateBattleEntity();
        }

        public void AnimationJobCompleted()
        {
            if (!enabled || !isStarted || isDestroyed)
            {
                return;
            }

            onAnimationJobCompleted.Dispatch();
        }

        protected override void OnAnimationJobRunning()
        {
            base.OnAnimationJobRunning();

            using (ProfilerDefine.BattlePhysicTickPMarker.Auto())
            {
                X3Physics.Collision.UpdateSceneColliderData();
                X3Physics.Collision.CaculateCollision();
            }
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            BattleUtil.TryInvoke(fxMgr.OnDestroy);
            BattleUtil.TryInvoke(_ClearNotionGraph);
            BattleUtil.TryInvoke(X3Physics.Destroy);
            BattleUtil.TryInvoke(ObjectPoolUtility.UnInit);
            BattleUtil.TryInvoke(TargetSelectUtil.ClearCache);
            BattleUtil.TryInvoke(BattleAnimatorCtrlContext.UnloadAllAnimatorCtrl);
            BattleUtil.TryInvoke(zstring.UnInit);
            Sequencer.InternStrFunc = null;
            BattleUtil.TryInvoke(BattleEnv.OnBattleDestroy);
            BattleUtil.TryInvoke(BattleResMgr.Instance.TryUninit);
            BattleUtil.TryInvoke(BattleEnv.ClientBridge.OnBattleDestroy);
            onAnimationJobCompleted.Clear();
            config = null;
            entity = null;
            if (Instance == this) Instance = null;
        }

        /// <summary>
        /// 开启预加载
        /// </summary>
        public void Preload()
        {
            if (isBegin || isPreloading)
            {
                return;
            }

            CriticalLog.Log("[战斗][启动流程][Battle.Preload()] 开始战斗预加载!");

            // 此阶段不允许物理更新（by:橘猫）
            if (null != PhysicsManager.Instance())
            {
                PhysicsManager.Instance().ForceStopUpate = true;
            }

            isPreloading = true;
            foreach (var tab in EventDefine.RelevantToListenerType)
            {
                eventMgr.Preload(tab.Key, tab.Value);
            }

            ui.Preload();
            actorMgr.Preload();
            sequencePlayer.PreloadBattleSequences();
            gameplay.Preload();
        }

        /// <summary>
        /// 预加载结束
        /// </summary>
        public void PreloadFinished()
        {
            if (isBegin || !isPreloading)
            {
                return;
            }

            if (null != PhysicsManager.Instance())
            {
                PhysicsManager.Instance().ForceStopUpate = false;
            }

            triggerMgr.PreloadFinished();
            sequencePlayer.PreloadFinished();
            actorMgr.PreloadFinished();
            cameraImpulse.ClearCameraShake();
            fxMgr.DestroyAllFx();
            statistics.PreloadFinished();
            globalBlackboard.PreloadFinished();
            ui.PreloadFinished();
            TbUtil.DisposeModifyCfgs();

            // note:预加载阶段标记在所有预加载结束之后进行修改
            isPreloading = false;
        }

        /// <summary>
        /// 启动结束
        /// </summary>
        public void StartupFinished()
        {
            if (isBegin)
            {
                return;
            }

            PreloadFinished();

            gameplay.StartupFinished();

            CriticalLog.Log("[战斗][启动流程][Battle.StartupFinished()] 战斗启动结束!");
        }

        /// <summary>
        /// 开始战斗
        /// </summary>
        public void Begin()
        {
            if (isBegin)
            {
                return;
            }

            CriticalLog.Log("[战斗][启动流程][Battle.Begin()] 开始战斗！");

            status = BattleRunStatus.Begin;
            for (var i = 0; i < entity.comps.Length; i++)
            {
                (entity.comps[i] as IBattleComponent)?.OnBattleBegin();
            }
        }

        /// <summary>
        /// 结束战斗
        /// </summary>
        /// <param name="isWin"></param>
        /// <param name="endReason">结束原因</param>
        public void End(bool isWin, BattleEndReason endReason = BattleEndReason.None)
        {
            if (isEnd)
            {
                return;
            }

            if (endReason != BattleEndReason.ManualQuit && BattleEnv.DontEndBattleNonManual)
            {
                LogProxy.LogError("[战斗][Battle.End()] 不能正常结束战斗, 因为勾选了【战斗调试器->控制->跳过结算流程】！");
                return;
            }

            SetWorldEnable(true);
            status = isWin ? BattleRunStatus.Success : BattleRunStatus.Fail;
            this.endReason = endReason;

            CriticalLog.LogFormat("[战斗][Battle.End()] 开始结束战斗！argInfo:{0}", arg.ToString());

            for (var i = 0; i < entity.comps.Length; i++)
            {
                (entity.comps[i] as IBattleComponent)?.OnBattleEnd();
            }

            var eventData = eventMgr.GetEvent<EventBattleEnd>();
            eventData.Init(config.ID, isWin, endReason);
            eventMgr.Dispatch(EventType.OnBattleEnd, eventData);
        }

        /// <summary>
        /// 退出战斗
        /// </summary>
        public new void Destroy()
        {
            if (isDestroyed)
            {
                return;
            }

            eventMgr.Clear();
            for (var i = 0; i < entity.comps.Length; i++)
            {
                (entity.comps[i] as IBattleComponent)?.OnBattleShutDown();
            }

            base.Destroy();
            CriticalLog.Log("[战斗][退出流程][Battle.Destroy()] 战斗成功销毁！");
        }

        /// <summary>
        /// 设置某种类型的scale值
        /// </summary>
        public void SetTimeScale(float timeScale, float? duration = null, int type = 0)
        {
            if ((int)LevelTimeScaleType.Bullet == type)
            {
                timeScaler.SetScale(timeScale, duration, type, 0, TbUtil.battleConsts.BattleBulletScaleFadeoutDuration);
            }
            else
            {
                timeScaler.SetScale(timeScale, duration, type);
            }
        }

        /// <summary>
        /// 暂停/恢复战斗主逻辑
        /// </summary>
        public void SetWorldEnable(bool enabled, BattleEnabledMask enabledMask = BattleEnabledMask.All, EAudioPauseType pauseType = EAudioPauseType.EAll, bool isForce = false)
        {
            if (!isForce && isEnd)
            {
                return;
            }

            //暂停音频
            wwiseBattleManager.PauseOrResumeAudio(enabled, pauseType);

            if (enabled)
            {
                this.enabledMask &= ~(int)enabledMask;
            }
            else
            {
                this.enabledMask |= (int)enabledMask;
            }

            if (this.enabled == (this.enabledMask == 0)) return;
            this.enabled = !this.enabled;

            var eventData = eventMgr.GetEvent<EventWorldEnable>();
            eventData.Init(this.enabled);
            eventMgr.Dispatch(EventType.OnWorldEnable, eventData);
        }

        /// <summary>
        /// 卸载无用资源（目前此处为强制清理，在战斗结束后，结算UI前由lua端调用）
        /// </summary>
        public void UnloadUnusedRes()
        {
            actorMgr?.DestroyCacheActors();
            modelMgr?.DestroyAllModelIns();
            sequencePlayer.Destroy();
            floatWordMgr.UnloadUnusedRes();
            BattleResMgr.Instance.UnloadUnusedAll(true);
        }

        /// <summary>
        /// 创建战斗单位实例
        /// </summary>
        private void _CreateBattleEntity()
        {
            // 战斗实体
            entity = AddEntity(new ECEntity((int)BattleComponentType.Num, "BattleEntity"));

            // 战斗玩法组件
            switch (arg.gameplayType)
            {
                case BattleGameplayType.Default:
                    gameplay = entity.AddComponent<DefaultGameplay>();
                    break;
                case BattleGameplayType.Rogue:
                    gameplay = entity.AddComponent<RogueGameplay>();
                    break;
                default:
                    LogProxy.LogError("【战斗启动异常】创建战斗玩法失败，请传入正确的玩法类型！");
                    return;
            }

            // 其他战斗组件
            entity.AddComponent<BattleLuaClient>();
            fxMgr = new FxMgr(root);
            ppvMgr = entity.AddComponent<BattlePPVMgr>();
            globalBlackboard = entity.AddComponent<BattleGlobalBlackboard>();
            cameraTrace = entity.AddComponent<CameraTrace>();
            cameraImpulse = entity.AddComponent(new CameraImpulse(this, (int)BattleComponentType.CameraImpulse));
            frameUpdateMgr = entity.AddComponent<FrameUpdateMgr>();
            actorMgr = entity.AddComponent<ActorMgr>();
            setting = entity.AddComponent<BattleSetting>();
            dialogue = entity.AddComponent<ActorDialogue>();
            sequencePlayer = entity.AddComponent<BattleSequencePlayer>();
            dirGuide = entity.AddComponent<BattleDirGuide>();
            playerSelectFx = entity.AddComponent<PlayerSelectFx>();
            ui = entity.AddComponent<BattleUI>();
            floatWordMgr = entity.AddComponent<FloatWordMgr>();
            misc = entity.AddComponent<BattleMisc>();
            battleStrategy = entity.AddComponent<BattleStrategy>();
            statistics = entity.AddComponent<BattleStatistics>();
            triggerMgr = entity.AddComponent<TriggerMgr>();
            battleTimer = entity.AddComponent(new BattleTimer(this, (int)BattleComponentType.BattleTimer));
            timeScaler = entity.AddComponent(new TimeScaler(this, (int)LevelTimeScaleType.Num, (int)BattleComponentType.TimeScaler));
            cheatStatistics = entity.AddComponent<BattleCheatStatistics>();
            modelMgr = entity.AddComponent<BattleModelMgr>();
            damageProcess = entity.AddComponent<BattleDamageProcess>();
            gridPenaltyMgr = entity.AddComponent<BattleGridPenaltyMgr>();
            wwiseBattleManager = entity.AddComponent<WwiseBattleManager>();
            if (arg.replayMode != BattleReplayMode.Replay) // 回放时，无需输入组件
                input = entity.AddComponent<PlayerInput>();
            if (arg.replayMode != BattleReplayMode.Nothing || Application.isEditor)
                entity.AddComponent<BattleReplay>();
#if UNITY_EDITOR
            pvRecord = entity.AddComponent<BattlePvRecord>();
#endif
        }

        /// <summary>
        /// 创建PostUpdate单位实例
        /// </summary>
        private void _CreatePostUpdateEntity()
        {
            /*postUpdateEntity = new ECEntity(0);
            postLateUpdateEntity = new ECEntity(0);
            postFixedUpdateEntity = new ECEntity(0);*/
        }

        /// <summary>
        /// 创建PostUpdate多层回调事件实例
        /// </summary>
        private void _CreatePostUpdateEvent()
        {
            onPostUpdate = new ECMultiLayerEvent((int)BattlePostUpdateEventLayer.Num);
            onPostAnimationJobRunning = new ECMultiLayerEvent();
            onPostLateUpdate = new ECMultiLayerEvent();
            onPostPhysicalJobRunning = new ECMultiLayerEvent();
            onPostFixedUpdate = new ECMultiLayerEvent();
        }

        /// <summary>
        /// 清除NotionGraph数据
        /// </summary>
        private void _ClearNotionGraph()
        {
            ParadoxNotion.ReflectionTools.FlushMem();
            ParadoxNotion.Serialization.JSONSerializer.FlushMem();
            ParadoxNotion.Serialization.JSONSerializer.EnableDataCache(true);
#if UNITY_EDITOR
            ParadoxNotion.Design.AssetTracker.Clear();
#endif
            ParadoxNotion.EventData.ClearPool();
            ParadoxNotion.Services.EventRouter.ClearPool();
        }
    }
}