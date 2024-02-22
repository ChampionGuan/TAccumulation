using System;
using System.Collections.Generic;
using EasyCharacterMovement;
using UnityEngine;
using X3.CustomEvent;

namespace X3Battle
{
    public static class EventDefine
    {
        /// <summary>
        /// Lua目前使用到的事件, 需要在此注册Lua层才能收到事件.
        /// </summary>
        public static readonly HashSet<EventType> LuaUseEvents = new HashSet<EventType>()
        {
            EventType.CastSkill,
            EventType.EndSkill,
            EventType.UIComponentActive,
            EventType.ActorHealthChangeForUI,
            EventType.OnBattleEnd,
            EventType.CreateQTE,
            EventType.SetQTEActive,
            EventType.ExitQTE,
            EventType.ChangeLockTarget,
            EventType.ShowSkillTips,
            EventType.RefreshSlotData,
            EventType.Actor,
            EventType.ArtEditorState,
            EventType.DialogueBubble,
            EventType.BuffChange,
            EventType.BuffLayerChange,
            EventType.WeakFull,
            EventType.CoreChange,
            EventType.CoreMaxChange,
            EventType.DebugColonyStrategyChange,
            EventType.DebugActorStrategyChange,
            EventType.DebugActorStrategyDataChange,
            EventType.DebugActorActionGoalChange,
            EventType.ShowMissionTips,
            EventType.DebugHideUI,
            EventType.RefreshSkillUI,
            EventType.EnergyCostChange,
            EventType.DialogueText,
            EventType.StateTagChange,
            EventType.ActorFrozen,
            EventType.MaxHpChange,
        };

        /// <summary>
        /// EventType相关联的EventData类型
        /// </summary>
        public static readonly Dictionary<EventType, Type> RelevantToListenerType = new Dictionary<EventType, Type>
        {
            {EventType.ActorCommand, typeof(EventListener<EventActorCommand>)},
            {EventType.ActorCmdFinished, typeof(EventListener<EventActorCmdFinished>)},
            {EventType.Actor, typeof(EventListener<EventActor>)},
            {EventType.ActorBorn, typeof(EventListener<EventActorBase>)},
            {EventType.ActorDead, typeof(EventListener<EventActorBase>)},
            {EventType.ActorRecycle, typeof(EventListener<EventActorBase>)},
            {EventType.ActorPreDead, typeof(EventListener<EventActorBase>)},
            {EventType.ActorChangeParts, typeof(EventListener<EventActorChangeParts>)},
            {EventType.ActorStateChange, typeof(EventListener<EventActorStateChange>)},
            {EventType.OnActorEnterBornState, typeof(EventListener<EventActorEnterStateBase>)},
            {EventType.OnActorEnterIdleState, typeof(EventListener<EventActorEnterStateBase>)},
            {EventType.OnActorEnterMoveState, typeof(EventListener<EventActorEnterStateBase>)},
            {EventType.OnActorEnterSkillState, typeof(EventListener<EventActorEnterStateBase>)},
            {EventType.OnActorEnterDeadState, typeof(EventListener<EventActorEnterStateBase>)},
            {EventType.OnActorEnterAbnormalState, typeof(EventListener<EventActorEnterStateBase>)},
            {EventType.ActorHealthChangeForUI, typeof(EventListener<EventActorHealthChangeForUI>)},
            {EventType.CastSkill, typeof(EventListener<EventCastSkill>)},
            {EventType.CanInterruptSkill, typeof(EventListener<EventCanInterruptSkill>)},
            {EventType.CanLinkSkill, typeof(EventListener<EventCanLinkSkill>)},
            {EventType.EndSkill, typeof(EventListener<EventEndSkill>)},
            {EventType.SetQTEActive, typeof(EventListener<EventSetQTEActive>)},
            {EventType.ExitQTE, typeof(EventListener<EventExitQTE>)},
            {EventType.QTEButtonPerfect, typeof(EventListener<EventQTEButton>)},
            {EventType.QTEButtonSuccess, typeof(EventListener<EventQTEButton>)},
            {EventType.ChangeLockTargetMode, typeof(EventListener<EventChangeLockTargetMode>)},
            {EventType.ChangeLockTarget, typeof(EventListener<EventChangeLockTarget>)},
            {EventType.Perform, typeof(EventListener<EventPerform>)},
            {EventType.DialogueBubble, typeof(EventListener<EventDialogueBubble>)},
            {EventType.UIComponentActive, typeof(EventListener<EventComponentActive>)},
            {EventType.GuideCallBack, typeof(EventListener<EventGuide>)},
            {EventType.BuffChange, typeof(EventListener<EventBuffChange>)},
            {EventType.BuffLayerChange, typeof(EventListener<EventBuffLayerChange>)},
            {EventType.OnGroupNumChange, typeof(EventListener<EventGroupNumChange>)},
            {EventType.OnLevelStart, typeof(EventListener<ECEventDataBase>)},
            {EventType.OnBattleEnd, typeof(EventListener<EventBattleEnd>)},
            {EventType.OnWorldEnable, typeof(EventListener<EventWorldEnable>)},
            {EventType.MachineStateChange, typeof(EventListener<EventMachineStateChange>)},
            {EventType.StateTagChange, typeof(EventListener<EventStateTagChange>)},
            {EventType.CannotMoveStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.CannotCastSkillStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.DamageImmunityStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.CollisionIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.HitIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.HurtIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.LockIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.CoreDamageImmunityStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.TractionImmunityStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.AttackIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.DebuffImmunityStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.RecoverIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.CannotEnterMoveStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.MissileBlastIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.LogicTestIgnoreStateTagChange, typeof(EventListener<EventStateTagChangeBase>)},
            {EventType.AbnormalTypeChange, typeof(EventListener<EventAbnormalTypeChange>)},
            {EventType.OnFpsOperateChange, typeof(EventListener<EventFpsOperateChange>)},
            {EventType.UpdateFriendHate, typeof(EventListener<ECEventDataBase>)},
            {EventType.TimerOver, typeof(EventListener<EventTimerOver>)},
            {EventType.TauntActorChange, typeof(EventListener<EventTauntActor>)},
            {EventType.HateActorChange, typeof(EventListener<EventHateActor>)},
            {EventType.OnBoxHitActors, typeof(EventListener<EventBoxHitActors>)},
            {EventType.OnTriggerArea, typeof(EventListener<EventOnTriggerArea>)},
            {EventType.OnKillTarget, typeof(EventListener<EventOnKillTarget>)},
            {EventType.CreateQTE, typeof(EventListener<EventCreateQTE>)},
            {EventType.OnLevelEndFlowStart, typeof(EventListener<ECEventDataBase>)},
            {EventType.MonsterActive, typeof(EventListener<EventActorBase>)},
            {EventType.ActorVisible, typeof(EventListener<EventActorVisible>)},
            {EventType.ActorAIDisabled, typeof(EventListener<EventActorAIDisabled>)},
            {EventType.OnPickItem, typeof(EventListener<EventPickItem>)},
            {EventType.OnReceiveSignal, typeof(EventListener<EventReceiveSignal>)},
            {EventType.OnBeforeHit, typeof(EventListener<EventBeforeHit>)},
            {EventType.OnPreExportDamage, typeof(EventListener<EventPreExportDamage>)},
            {EventType.ExportDamage, typeof(EventListener<EventExportDamage>)},
            {EventType.OnDamageInvalid, typeof(EventListener<EventDamageInvalid>)},
            {EventType.SetMachineState, typeof(EventListener<EventSetMachineState>)},
            {EventType.OnLockHp, typeof(EventListener<EventLockHp>)},
            {EventType.EnergyFull, typeof(EventListener<EventEnergyFull>)},
            {EventType.OnLevelSignal, typeof(EventListener<EventLevelSignal>)},
            {EventType.OnLevelEvent, typeof(EventListener<EventLevelEvent>)},
            {EventType.CameraCancelLock, typeof(EventListener<EventCameraCancelLock>)},
            {EventType.OnFoundGround, typeof(EventListener<EventOnFoundGround>)},
            {EventType.AttrChange, typeof(EventListener<EventAttrChange>)},
            {EventType.RootMotionMutiplierChange, typeof(EventListener<EventAttrChange>)},
            {EventType.MoveSpeedChange, typeof(EventListener<EventAttrChange>)},
            {EventType.OnScalerChange, typeof(EventListener<EventScalerChange>)},
            {EventType.ShieldChange, typeof(EventListener<EventShieldChange>)},
            {EventType.CreateItem, typeof(EventListener<EventCreateItem>)},
            {EventType.OnAddShield, typeof(EventListener<EventOnAddShield>)},
            {EventType.WeakFull, typeof(EventListener<EventWeakFull>)},
            {EventType.OnBornCameraState, typeof(EventListener<EventBornCameraState>)},
            {EventType.TimelineWithVirCam, typeof(EventListener<EventTimeLineWithVirCam>)},
			{EventType.CoreChange, typeof(EventListener<EventCoreChange>) },
            {EventType.CoreMaxChange, typeof(EventListener<EventCoreMaxChange>) },
            {EventType.WeakEnd, typeof(EventListener<EventWeakEnd>) },
            {EventType.DebugColonyStrategyChange, typeof(EventListener<EventDebugGroupStrategyChange>)},
            {EventType.DebugActorStrategyChange, typeof(EventListener<EventDebugActorStrategyChange>)},
            {EventType.DebugActorStrategyDataChange, typeof(EventListener<EventDebugActorStrategyDataChange>)},
            {EventType.MagicFieldStateChange, typeof(EventListener<EventMagicFieldState>)},
            {EventType.EnergyExhausted, typeof(EventListener<EventEnergyExhausted>)},
            {EventType.ObstacleStateChange, typeof(EventListener<EventObstacleState>)},
            {EventType.ShowMissionTips, typeof(EventListener<EventShowMissionTips>) },
            {EventType.ChangeLevelState, typeof(EventListener<EventChangeLevelState>) },
            {EventType.DebugHideUI, typeof(EventListener<EventDebugHideUI>) },
            {EventType.RefreshSkillUI, typeof(EventListener<ECEventDataBase>) },
            {EventType.OnDamageCritical, typeof(EventListener<EventDamageCritical>) },
            {EventType.OnPrevDamage, typeof(EventListener<EventPrevDamage>) },
            {EventType.OnHitProcessStart, typeof(EventListener<EventHitProcessStart>)},
            {EventType.OnHitProcessEnd, typeof(EventListener<EventHitProcessEnd>)},
            {EventType.EnergyCostChange, typeof(EventListener<ECEventDataBase>)},
            {EventType.DialogueText, typeof(EventListener<EventDialogueText>)},
            {EventType.OnUpdatePently, typeof(EventListener<EventUpdatePenalty>)},
            {EventType.ActorFrozen, typeof(EventListener<EventActorFrozen>)},
            {EventType.DialoguePlay, typeof(EventListener<EventDialoguePlay>)},
            {EventType.DialogueInterrupt, typeof(EventListener<EventDialogueInterrupt>)},
            {EventType.DialoguePlayEnd, typeof(EventListener<EventDialoguePlayEnd>)},
            {EventType.DialoguePlayError, typeof(EventListener<EventDialoguePlayError>)},
            {EventType.MaxHpChange, typeof(EventListener<EventAttrChange>)},
            {EventType.OnActorCreateBeforeBornStep, typeof(EventListener<EventCreateBeforeBornStep>)},
            {EventType.InterActorDone, typeof(EventListener<EventInterActorDone>)},
            {EventType.BuffAdd, typeof(EventListener<EventBuffChange>)},
            {EventType.ActorHealthChange, typeof(EventListener<EventActorHealthChange>)},
            {EventType.OnPerfectDodge, typeof(EventListener<ECEventDataBase>)},
        };
    }

    public enum EventType
    {
        //事件命令
        //type EventActorCommand
        ActorCommand = 0,

        //指令结束
        ActorCmdFinished,

        //AI打断后摇
        AIBackSwing,
        
        //角色换部件
        ActorChangeParts,
        
        //Actor事件发生变化
        //type EventActor
        Actor,

        ActorBorn,
        ActorDead,
        ActorRecycle,
        
        //type EventActorBase
        ActorPreDead,
        
        //ActorState发生变化
        //type EventActorStateChange
        ActorStateChange,
        
        // type EventActorEnterStateBase
        OnActorEnterBornState,
        
        // type EventActorEnterStateBase
        OnActorEnterIdleState,
        
        // type EventActorEnterStateBase
        OnActorEnterMoveState,
        
        // type EventActorEnterStateBase
        OnActorEnterSkillState,
        
        // type EventActorEnterStateBase
        OnActorEnterDeadState,
        
        // type EventActorEnterStateBase
        OnActorEnterAbnormalState,

        //Actor血量变化（发给UI用）
        //type EventActorHealthChange
        ActorHealthChangeForUI,

        //释放指定技能
        //type EventCastSkill
        CastSkill,

        //可以中断技能
        //type EventCanInterruptSkill
        CanInterruptSkill,

        //可以释放连接技
        //type EventCanLinkSkill
        CanLinkSkill,

        //释放指定技能
        //type EventEndSkill
        EndSkill,

        //设置QTE显示/隐藏
        //type EventSetQTEActive
        SetQTEActive,

        //关闭QTE
        //type EventExitQTE
        ExitQTE,

        //按键QTE完美触发
        //type EventQTEButtonPerfect
        QTEButtonPerfect,

        //按键QTE普通触发
        //type EventQTEButtonSuccess
        QTEButtonSuccess,

        //切换索敌模式
        //type EventChangeLockTargetMode
        ChangeLockTargetMode,

        //切换索敌目标
        //type EventChangeLockTarget
        ChangeLockTarget,

        //表演
        //type EventPerform
        Perform,

        //播放战斗沟通
        //type EventDialogueBubble
        DialogueBubble,

        //隐藏战斗UI
        //type EventUIActive
        BattleUIActive,

        //隐藏战斗UI Component
        //type EventComponentActive
        UIComponentActive,

        //引导完成回调
        //type EventGuide
        GuideCallBack,

        //服务器战斗结束的结算数据统计消息回调
        ServerStatisticsDataCallBack,

        //buff创建或销毁
        //type EventBuffChange
        BuffChange,

        //buff层数改变
        BuffLayerChange,

        // 血量变化
        //type EventDataBloodChange
        OnBloodChange,

        // Group数量变化
        //type EventDataGroupNumChange
        OnGroupNumChange,
        
        //fps玩法操作变化
        OnFpsOperateChange,

        // 关卡开始
        OnLevelStart,
        
        // 战斗结束之后的 关卡结束流开始.
        OnLevelEndFlowStart,

        // 战斗结束
        OnBattleEnd,
        
        // 战斗暂停继续
        OnWorldEnable,

        // 机器状态变化
        //type EventMachineStateChangePar
        MachineStateChange,

        // 角色基础标签变化
        //type EventStateTagChange
        StateTagChange,
        // 角色具体的基础标签变化
        //type EventStateTagChangeBase
        CannotMoveStateTagChange,
        CannotCastSkillStateTagChange,
        DamageImmunityStateTagChange,
        CollisionIgnoreStateTagChange,
        HitIgnoreStateTagChange,
        HurtIgnoreStateTagChange,
        LockIgnoreStateTagChange,
        CoreDamageImmunityStateTagChange,
        TractionImmunityStateTagChange,
        AttackIgnoreStateTagChange,
        DebuffImmunityStateTagChange,
        RecoverIgnoreStateTagChange,
        CannotEnterMoveStateTagChange,
        MissileBlastIgnoreStateTagChange,
        LogicTestIgnoreStateTagChange,

        // 角色异常类型变化
        //type EventStateTagChange
        AbnormalTypeChange,

        //主控通知友方尝试更新仇恨数据
        UpdateFriendHate,
        
        //计时器结束
        //type EventTimerOver
        TimerOver,

        //嘲讽目标变化
        //type EventTauntActor
        TauntActorChange,

        //仇恨目标变化
        //type EventHateActor
        HateActorChange,

        //type EventOnTriggerArea
        OnTriggerArea,

        //Actor事件发生变化
        //type EventOnKillTarget
        OnKillTarget,

        //创建QTE
        CreateQTE,

        //调试器刷新槽位技能
        RefreshSlotData,

        // 角色可见性状态
        ActorVisible,
        
        // 角色活跃状态
        MonsterActive,

        ShowSkillTips,
        ArtEditorState,
        SkillCountdown,

        // 角色AI是否禁用
        ActorAIDisabled,
        
        //拾取道具
        // type EventPickItem
        OnPickItem,

        // 收到信号
        // type EventReceiveSignal
        OnReceiveSignal,

        // 命中前
        // type EventBeforeHit
        OnBeforeHit,

        // 伤害结算前事件
        //type EventPreExportDamage
        OnPreExportDamage,

        // 伤害输出事件
        //type EventExportDamage
        ExportDamage,

        // 伤害无效无效事件
        // type EventDamageInvalid
        OnDamageInvalid,

        //-------------------战斗真机调试器 use start---------------
        // type EventDebugColonyStrategyChange
        DebugColonyStrategyChange,

        // type EventDebugActorStrategyChange
        DebugActorStrategyChange,

        // type EventDebugActorStrategyDataChange
        DebugActorStrategyDataChange,
        DebugActorActionGoalChange,
        //-------------------战斗真机调试器 use end---------------

        // 设置机关状态的事件
        SetMachineState,

        // 锁血事件
        // type EventLockHp
        OnLockHp,

        //能量充满
        EnergyFull,

        // 能量耗尽
        EnergyExhausted,

        // 关卡信号
        // type EventLevelSignal
        OnLevelSignal,

        // 关卡事件
        // type EventLevelEvent
        OnLevelEvent,

        // 相机脱锁事件
        CameraCancelLock,

        // 碰到地面事件，上一次位置更改不在地面上，下一次在地面上时触发
        OnFoundGround,

        // 属性变化事件
        AttrChange,
        RootMotionMutiplierChange,
        MoveSpeedChange,

        // 缩放变化
        // type EventScaler
        OnScalerChange,

        // 进入虚弱
        WeakFull,

        // 出生镜头
        // type EventBornCameraState
        OnBornCameraState,

        // 绑定了虚拟相机的timeline开始或结束
        TimelineWithVirCam,

        // 统计技能伤害结束时, 该技能及其衍生物造成的伤害.
        // type EventDamageMeter
        OnDamageMeter,

        // 芯核数量变化
        CoreChange,

        // 芯核最大值变化
        CoreMaxChange,

        // 虚弱结束
        WeakEnd,
        //法术场状态改变
        MagicFieldStateChange,

        //空气墙状态变化
        ObstacleStateChange,

        // -------------- 战斗指引相关 ---------------
        ShowMissionTips,
        // ------------- 战斗指引相关

        //-------------- Debug隐藏指定UI----------------
        DebugHideUI,

        // 改变关卡状态
        ChangeLevelState,

        // 进入受击
        EnterHurt,

        // 通知技能UI刷新一下
        RefreshSkillUI,
        
        // 伤害暴击事件
        // type EventDamageCritical
        OnDamageCritical,
        
        // 伤害前事件
        // type EventPrevDamage
        OnPrevDamage,
        
        OnSkillFinished,
        
        // 开始技能动画
        StartDelayAnim,
        
        // 总伤害流程开始
        // type EventHitProcessStart
        OnHitProcessStart,

        // 总伤害流程结束
        // type EventHitProcessEnd
        OnHitProcessEnd,

        // box命中了任何一个target
        OnBoxHitActors,
		
        // type EventChangeTagMaterial
        ChangeTagMaterial,
        
        // 技能消耗改变事件
        EnergyCostChange,
        
        // 战斗沟通文本事件
        DialogueText,
        
        //更新寻路网格惩罚
        OnUpdatePently,
        
        //角色冰冻状态
        ActorFrozen,

        //战斗沟通播放
        DialoguePlay,
        
        //战斗沟通播放结束
        DialoguePlayEnd,
        
        //战斗沟通被打断
        DialogueInterrupt,
        
        //战斗沟通播放失败
        DialoguePlayError,
        
        // 技能衔接事件
        SwitchRunningSkill,
        
        // 最大血量发生变化
        MaxHpChange,
        
        // 创建后出生前的阶段
        OnActorCreateBeforeBornStep,
        
        // 交互物交互完成
        InterActorDone,
        //buff添加（包含刷新时间和层数变化）
        BuffAdd,
        //血量变化（发给蓝图逻辑）
        ActorHealthChange,
        // 进入移动模式
        OnEnterMoveMode,
        // 退出移动模式
        OnExitMoveMode,
        // 角色护盾改变
        ShieldChange,
        // 道具创建事件
        CreateItem,
        // 即将添加护盾事件（护盾值添加之前，发出去蓝图里做修饰）
        OnAddShield,
        //触发完美闪避
        OnPerfectDodge,
    }

    //-------------------战斗真机调试器 use start---------------
    public class EventDebugGroupStrategyChange : ECEventDataBase
    {
        public bool isAdd;
        public GroupStrategy groupStrategy;

        public void Init(bool isAdd, GroupStrategy groupStrategy)
        {
            this.isAdd = isAdd;
            this.groupStrategy = groupStrategy;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugGroupStrategyChange>();
            eventData.isAdd = isAdd;
            eventData.groupStrategy = groupStrategy;
            return eventData;
        }
    }

    public class EventDebugActorStrategyChange : ECEventDataBase
    {
        public bool isAdd;
        public ActorStrategy actorStrategy;

        public void Init(bool isAdd, ActorStrategy actorStrategy)
        {
            this.isAdd = isAdd;
            this.actorStrategy = actorStrategy;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugActorStrategyChange>();
            eventData.isAdd = isAdd;
            eventData.actorStrategy = actorStrategy;
            return eventData;
        }
    }

    public class EventDebugActorStrategyDataChange : ECEventDataBase
    {
        public ActorStrategy actorStrategy;

        public void Init(ActorStrategy actorStrategy)
        {
            this.actorStrategy = actorStrategy;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugActorStrategyDataChange>();
            eventData.actorStrategy = actorStrategy;
            return eventData;
        }
    }
    //-------------------战斗真机调试器 use end---------------

    public class EventBoxHitActors : ECEventDataBase
    {
        public List<HitTargetInfo> hitTargetInfos { get; private set; } = new List<HitTargetInfo>();
        public Actor hitCaster { get; private set; }
        public ISkill hitSkill { get; private set; }

        public DamageBox hitBox { get; private set; }

        public void Init(DamageBox box, Actor _hitCaster, ISkill _hitSkill)
        {
            hitCaster = _hitCaster;
            hitSkill = _hitSkill;
            hitBox = box;
            hitTargetInfos.Clear();
            var targets = box.lastHitTargets;
            for (int i = 0; i < targets.Count; i++)
            {
                hitTargetInfos.Add(targets[i]);
            }
        }
    }
    
    /// <summary>
    /// 结束战斗事件
    /// </summary>
    public class EventBattleEnd : ECEventDataBase
    {
        /// 关卡ID, battleLevelConfigs
        public int id { get; private set; }

        /// 战斗结果
        public bool isWin { get; private set; }

        /// <summary>
        /// 失败原因
        /// </summary>
        public int failRes { get; private set; }

        public void Init(int id, bool isWin, BattleEndReason res)
        {
            this.id = id;
            this.isWin = isWin;
            this.failRes = (int)res;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventBattleEnd>();
            eventData.id = this.id;
            eventData.isWin = this.isWin;
            eventData.failRes = this.failRes;
            return eventData;
        }
        
    }
    

    /// 战斗暂停继续
    /// </summary>
    public class EventWorldEnable : ECEventDataBase
    {
        /// 继续/暂停
        public bool isEnable { get; private set; }

        public void Init(bool isEnable)
        {
            this.isEnable = isEnable;
        }
    }

    /// <summary>
    /// 角色生命周期事件
    /// </summary>
    public class EventActor : EventActorBase
    {
        /// 角色状态
        public ActorLifeStateType state { get; private set; }

        public void Init(Actor actor, ActorLifeStateType state)
        {
            this.actor = actor;
            this.state = state;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventActor>();
            eventData.actor = actor;
            eventData.state = state;
            return eventData;
        }

        #region lua层使用

        public bool isRole => actor.IsRole();
        public bool isItem =>actor.IsItem();
        
        #endregion



    }

    /// <summary>
    /// 命中前
    /// </summary>
    public class EventBeforeHit : ECEventDataBase
    {
        public DamageExporter damageExporter => hitInfo.damageExporter;
        public DamageBoxCfg damageBoxCfg => hitInfo.damageBoxCfg;
        public HitParamConfig hitParamConfig => hitInfo.hitParamConfig;
        public float damageProportion { get; private set; }
        public Actor target => hitInfo.damageTarget;

        // 策划可动态配置的一个数据包
        public HitInfo hitInfo { get; private set; }

        public DynamicHitInfo dynamicHitInfo { get; private set; }

        public void Init(HitInfo hitInfo, DynamicHitInfo dynamicHitInfo, float damageProportion)
        {
            this.hitInfo = hitInfo;
            this.damageProportion = damageProportion;
            this.dynamicHitInfo = dynamicHitInfo;
        }

        public override void OnRecycle()
        {
            this.hitInfo = null;
            this.dynamicHitInfo = null;
        }
    }

    /// <summary>
    /// 输出伤害前
    /// </summary>
    public class EventPreExportDamage : ECEventDataBase
    {
        public DamageExporter exporter => hitInfo.damageExporter;

        public DamageBoxCfg damageBoxCfg => hitInfo.damageBoxCfg;

        public HitParamConfig hitParamConfig => hitInfo.hitParamConfig;
        public Actor target => damageInfo.actor;
        public HitInfo hitInfo { get; private set; }

        public DamageInfo damageInfo { get; private set; }

        public DynamicDamageInfo dynamicDamageInfo { get; private set; }

        public DamageType damageType { get; private set; }

        /// 该次伤害事件是否包含暴击
        public bool hasCritical { get; private set; }

        /// 该次伤害事件造成的总伤害(是个>0的数)
        public float totalDamage { get; private set; }

        public void Init(HitInfo hitInfo, DamageInfo damageInfo, DamageType damageType)
        {
            this.hitInfo = hitInfo;
            this.damageInfo = damageInfo;
            this.damageType = damageType;
            this.hasCritical = damageInfo.isCritical;
            this.totalDamage = damageInfo.damage;
            this.dynamicDamageInfo = ObjectPoolUtility.DynamicDamageInfoPool.Get();
        }

        public override void OnRecycle()
        {
            if (this.dynamicDamageInfo != null)
            {
                ObjectPoolUtility.DynamicDamageInfoPool.Release(this.dynamicDamageInfo);    
            }
        }
    }

    /// <summary>
    /// 造成伤害事件
    /// </summary>
    public class EventExportDamage : ECEventDataBase
    {
        /// 伤害源对象
        public DamageExporter exporter => hitInfo.damageExporter;

        public DamageBoxCfg damageBoxCfg => hitInfo.damageBoxCfg;

        public HitParamConfig hitParamConfig => hitInfo.hitParamConfig;

        public HitInfo hitInfo { get; private set; }

        /// 单个伤害信息
        public DamageInfo damageInfo { get; private set; }

        public DamageType damageType { get; private set; }

        public Vector3? hitPoint => hitInfo.hitPoint;

        /// 该次伤害事件是否包含暴击
        public bool hasCritical => damageInfo.isCritical;

        /// 该次伤害事件造成的总伤害(是个>0的数)
        public float totalDamage => damageInfo.damage;

        public Actor hurtActor => damageInfo.actor;
        public float hurtDamage => damageInfo.damage;
        public float hurtRealDamage => damageInfo.realDamage;
        public bool hurtCritical => damageInfo.isCritical;
        public bool hurtIsGirl => exporter.GetCaster().IsGirl();
        public FactionType hurtFactionType => hurtActor.factionType;

        public void Init(HitInfo hitInfo, DamageInfo damageInfo, DamageType damageType)
        {
            this.damageInfo = damageInfo;
            this.damageType = damageType;
            this.hitInfo = hitInfo;
        }
    }

    public class EventUIActive : ECEventDataBase
    {
        public bool active { get; private set; }
        public bool isNeedHideTime { get; private set; }
        public float hideTime { get; private set; }
        public bool touchEnable { get; private set; }

        public void Init(bool active, float time = 0, bool isNeedHideTime = false, bool touchEnable = false)
        {
            this.active = active;
            this.hideTime = time;
            this.isNeedHideTime = isNeedHideTime;
            this.touchEnable = touchEnable;
        }
    }

    public class EventComponentActive : ECEventDataBase
    {
        public bool active { get; private set; }
        public UIComponentType type { get; private set; }
        public int insId;

        public void Init(UIComponentType type, bool active, int insId)
        {
            this.type = type;
            this.active = active;
            this.insId = insId;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventComponentActive>();
            eventData.type = this.type;
            eventData.active = this.active;
            eventData.insId = this.insId;
            return eventData;
        }
    }

    public class EventGuide : ECEventDataBase
    {
        public string eventName { get; private set; }

        public void Init(string eventName)
        {
            this.eventName = eventName;
        }
    }

    public class EventSetQTEActive : ECEventDataBase
    {
        public bool active { get; private set; }

        public void Init(bool active)
        {
            this.active = active;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventSetQTEActive>();
            eventData.active = active;
            return eventData;
        }
    }

    public class EventCreateQTE : ECEventDataBase
    {
        public QTEOperateType operateType { get; private set; }
        public int subType { get; private set; }
        public int qteId { get; private set; }
        public float currentTime { get; private set; }
        public float duration { get; private set; }
        public int priority { get; private set; }
        public int positionType { get; private set; }
        public float ratio { get; private set; }

        public void Init(QTEOperateType operateType, int subType, int qteId, float currentTime, float duration, int priority, int positionType, float ratio)
        {
            this.operateType = operateType;
            this.subType = subType;
            this.qteId = qteId;
            this.currentTime = currentTime;
            this.duration = duration;
            this.priority = priority;
            this.positionType = positionType;
            this.ratio = ratio;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventCreateQTE>();
            eventData.operateType = operateType;
            eventData.subType = subType;
            eventData.qteId = qteId;
            eventData.currentTime = currentTime;
            eventData.duration = duration;
            eventData.priority = priority;
            eventData.positionType = positionType;
            eventData.ratio = ratio;
            return eventData;
        }
    }

    public class EventExitQTE : ECEventDataBase
    {
        public int qteId { get; private set; }

        public void Init(int qteId)
        {
            this.qteId = qteId;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventExitQTE>();
            eventData.qteId = qteId;
            return eventData;
        }
    }

    public class EventQTEButton : ECEventDataBase
    {
        public int qteId { get; private set; }

        public void Init(int qteId)
        {
            this.qteId = qteId;
        }
    }

    public class EventGroupNumChange : ECEventDataBase
    {
        public ActorGroup actorGroup { get; private set; }
        public int preNum { get; private set; }
        public int curNum { get; private set; }

        public void Init(ActorGroup actorGroup, int preNum, int curNum)
        {
            this.actorGroup = actorGroup;
            this.preNum = preNum;
            this.curNum = curNum;
        }
    }

    /// <summary>
    /// 机关状态变化事件
    /// </summary>
    public class EventMachineStateChange : ECEventDataBase
    {
        public Actor Actor { get; private set; }
        public MachineType MachineType { get; private set; }
        public int State { get; private set; }
        public string TriggerMode { get; private set; }

        public void Init(Actor actor, MachineType machineType, int state, string triggerMode)
        {
            this.Actor = actor;
            this.MachineType = machineType;
            this.State = state;
            this.TriggerMode = triggerMode;
        }
    }

    /// <summary>
    /// 设置机关状态
    /// </summary>
    public class EventSetMachineState : ECEventDataBase
    {
        public int InsID { get; private set; }
        public int State { get; private set; }

        public void Init(int insID, int state)
        {
            this.InsID = insID;
            this.State = state;
        }
    }

    /// <summary>
    /// 战斗沟通显示事件
    /// </summary>
    public class EventDialogueBubble : ECEventDataBase
    {
        /// 角色
        public Actor actor { get; private set; }

        /// 显示时长
        public float showTime { get; private set; }

        /// 显示的文本ID
        public int textID { get; private set; }

        public void Init(Actor actor, float showTime, int textID)
        {
            this.actor = actor;
            this.showTime = showTime;
            this.textID = textID;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDialogueBubble>();
            eventData.actor = actor;
            eventData.showTime = showTime;
            eventData.textID = textID;
            return eventData;
        }
    }

    public class EventChangeLockTarget : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public Actor target { get; private set; }

        public void Init(Actor actor, Actor target)
        {
            this.actor = actor;
            this.target = target;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventChangeLockTarget>();
            eventData.actor = actor;
            eventData.target = target;
            return eventData;
        }
    }

    public class EventCameraCancelLock : ECEventDataBase
    {
        public void Init()
        {
        }
    }

    /// <summary>
    /// 角色主状态切换事件
    /// </summary>
    public class EventActorStateChange : ECEventDataBase
    {
        /// 角色
        public Actor actor { get; private set; }

        /// 来自状态
        public ActorMainStateType fromStateName { get; private set; }

        /// 目标状态    
        public ActorMainStateType toStateName { get; private set; }

        public void Init(Actor actor, ActorMainStateType fromStateName, ActorMainStateType toStateName)
        {
            this.actor = actor;
            this.fromStateName = fromStateName;
            this.toStateName = toStateName;
        }
    }

    /// <summary>
    /// 角色进入状态事件
    /// </summary>
    public class EventActorEnterStateBase : ECEventDataBase
    {
        /// 角色
        public Actor actor { get; private set; }

        /// 来自状态
        public ActorMainStateType fromStateName { get; private set; }

        public void Init(Actor actor, ActorMainStateType fromStateName)
        {
            this.actor = actor;
            this.fromStateName = fromStateName;
        }
    }

    /// <summary>
    /// 可连接技能事件
    /// </summary>
    public class EventCanLinkSkill : ECEventDataBase
    {
        /// <summary>
        /// 技能对象
        /// </summary>
        public ISkill skill { get; private set; }

        /// <summary>
        /// 可以连接的金额能槽位ID
        /// </summary>
        public int linkSlotID { get; private set; }

        public void Init(ISkill skill, int linkSlotID)
        {
            this.skill = skill;
            this.linkSlotID = linkSlotID;
        }
    }

    /// <summary>
    /// 技能结束事件
    /// </summary>
    public class EventEndSkill : ECEventDataBase
    {
        /// <summary>
        /// 技能对象
        /// </summary>
        public ISkill skill { get; private set; }

        /// <summary>
        /// 技能结束类型
        /// Default = 0,正常结束
        /// Hurt = 1, 因为受到伤害而打断
        /// CastSkill = 2, 因为自己放了其他技能而打断。除了连接技（策划要求）
        /// </summary>
        public SkillEndType endType { get; private set; }

        public void Init(ISkill skill, SkillEndType endType)
        {
            this.skill = skill;
            this.endType = endType;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventEndSkill>();
            eventData.skill = this.skill;
            eventData.endType = this.endType;
            return eventData;
        }
    }

    /// <summary>
    /// 角色基础状态标签变化
    /// </summary>
    public class EventStateTagChangeBase : ECEventDataBase
    {
        public Actor actor { get; protected set; }
        public bool active { get; protected set; }

        public void Init(Actor _actor, bool _active)
        {
            actor = _actor;
            active = _active;
        }

        public override void OnRecycle()
        {
            actor = null;
        }
    }

    /// <summary>
    /// 角色基础状态标签变化
    /// </summary>
    public class EventStateTagChange : EventStateTagChangeBase
    {
        public ActorStateTagType stateTagType { get; private set; }

        public void Init(Actor _actor, ActorStateTagType _stateTagType, bool _active)
        {
            base.Init(_actor, _active);
            stateTagType = _stateTagType;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventStateTagChange>();
            eventData.actor = actor;
            eventData.stateTagType = stateTagType;
            eventData.active = active;
            return eventData;
        }
    }

    /// <summary>
    /// 角色异常状态切换事件
    /// </summary>
    public class EventAbnormalTypeChange : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public ActorAbnormalType abnormalType { get; private set; }
        public object adder { get; private set; }
        public bool active { get; private set; }
    
        public void Init(Actor actor, ActorAbnormalType abnormalType, object adder, bool active)
        {
            this.actor = actor;
            this.abnormalType = abnormalType;
            this.adder = adder;
            this.active = active;
        }
    }

    public class EventFpsOperateChange : ECEventDataBase
    {
        public FpsOperateType fpsOperateType { get; private set; }
        public int times{ get; private set; }
        
        public void Init(FpsOperateType fpsOperateType, int times)
        {
            this.fpsOperateType = fpsOperateType;
            this.times = times;
        }
    }
    

    public class EventActorBase : ECEventDataBase
    {
        public Actor actor { get; protected set; }

        public void Init(Actor actor)
        {
            this.actor = actor;
        }
    }

    public class EventTimerOver : ECEventDataBase
    {
        public int timerId{ get; private set; }
        public void Init(int timerId)
        {
            this.timerId = timerId;
        }
    }

    // 嘲讽目标改变事件
    public class EventTauntActor : ECEventDataBase
    {
        public Actor actor { get; private set; }  // 被嘲讽者
        public Actor tauntTarget { get; private set; }  // 嘲讽者

        public void Init(Actor _actor, Actor _tauntTarget)
        {
            this.actor = _actor;
            this.tauntTarget = _tauntTarget;
        }
    }

    // 仇恨目标改变事件
    public class EventHateActor : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public Actor hateTarget { get; private set; }

        public void Init(Actor _actor, Actor _hateTarget)
        {
            this.actor = _actor;
            this.hateTarget = _hateTarget;
        }
    }

    /// <summary>
    /// 修改目标锁定模式
    /// </summary>
    public class EventChangeLockTargetMode : ECEventDataBase
    {
        /// <summary>
        /// 单位对象
        /// </summary>
        public Actor actor { get; private set; }

        /// <summary>
        /// 之前的锁定模式类型
        /// </summary>
        public TargetLockModeType preLockMode { get; private set; }

        /// <summary>
        /// 新的锁定模式类型
        /// </summary>
        public TargetLockModeType targetLockMode { get; private set; }

        public void Init(Actor actor, TargetLockModeType preLockMode,TargetLockModeType targetLockMode)
        {
            this.actor = actor;
            this.preLockMode = preLockMode;
            this.targetLockMode = targetLockMode;
        }
    }
    
    /// <summary>
    /// 单位血量变化事件
    /// </summary>
    public class EventActorHealthChange : ECEventDataBase
    {
        /// <summary>
        /// 单位对象
        /// </summary>
        public Actor actor { get; private set; }

        public float changeValue;

        public HpChangeType changeType;

        public void Init(Actor actor)
        {
            this.actor = actor;
            changeValue = 0;
            changeType = HpChangeType.Other;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventActorHealthChange>();
            eventData.actor = this.actor;
            eventData.changeValue = this.changeValue;
            eventData.changeType = this.changeType;
            return eventData;
        }
    }

    /// <summary>
    /// 单位血量变化事件
    /// </summary>
    public class EventActorHealthChangeForUI : ECEventDataBase
    {
        /// <summary>
        /// 单位对象
        /// </summary>
        public Actor actor { get; private set; }

        public float currentValue;

        public void Init(Actor actor)
        {
            this.actor = actor;
            currentValue = 0;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventActorHealthChangeForUI>();
            eventData.actor = this.actor;
            eventData.currentValue = this.currentValue;
            return eventData;
        }

        #region lua层使用

        public bool weak
        {
            get
            {
                if (actor != null && actor.actorWeak != null)
                {
                    return actor.actorWeak.weak;
                }

                return false;
            }
        }
        
        #endregion

        
    }
    
    /// <summary>
    /// LocomotionCtrl关注的属性变化事件
    /// </summary>
    public class EventRootMotionMutiplierChange : ECEventDataBase
    {
        /// <summary>
        /// 单位对象
        /// </summary>
        public Actor actor { get; private set; }

        public void Init(Actor actor)
        {
            this.actor = actor;
        }
    }
    
    /// <summary>
    /// movespeed属性变化事件
    /// </summary>
    public class EventMoveSpeedChange : ECEventDataBase
    {
        /// <summary>
        /// 单位对象
        /// </summary>
        public Actor actor { get; private set; }

        public void Init(Actor actor)
        {
            this.actor = actor;
        }
    }

    public class EventAttrChange : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public AttrType type { get; private set; }

        public float oldValue { get; private set; }

        public float newValue { get; private set; }

        public void Init(Actor actor, AttrType type, float oldValue, float newValue)
        {
            this.oldValue = oldValue;
            this.newValue = newValue;
            this.actor = actor;
            this.type = type;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventAttrChange>();
            eventData.actor= actor;
            eventData.type= type;
            eventData.oldValue= oldValue;
            eventData.newValue= newValue;
            return eventData;
        }
    }

    /// <summary>
    /// 单位进入或者退出触发区域事件
    /// </summary>
    public class EventOnTriggerArea : ECEventDataBase
    {
        /// <summary>
        /// 单位
        /// </summary>
        public Actor actor { get; private set; }

        /// <summary>
        /// 是否是进入
        /// </summary>
        public bool isEnter { get; private set; }

        /// <summary>
        /// 触发的角色
        /// </summary>
        public Actor triggerActor { get; private set; }

        public bool isCharacterCollider { get; private set; }

        public void Init(Actor actor, bool isEnter, Actor triggerActor, bool isCharacterCollider)
        {
            this.actor = actor;
            this.isEnter = isEnter;
            this.triggerActor = triggerActor;
            this.isCharacterCollider = isCharacterCollider;
        }
    }

    /// <summary>
    /// Timeline表演事件
    /// </summary>
    public class EventPerform : ECEventDataBase
    {
        /// <summary>
        /// 是否是开始表演
        /// true:开始表演
        /// false:表演结束
        /// </summary>
        public bool state { get; private set; }

        public void Init(bool state)
        {
            this.state = state;
        }
    }

    /// <summary>
    /// buff改变事件
    ///
    /// </summary>
    public class EventBuffChange : ECEventDataBase,ECEventExpendParam
    {
        public enum DestroyedReason
        {
            None = 0,
            Others = 1,//被驱散等效果主动清除,被其他buff冲突覆盖了.外部模块控制buff生命周期，满足条件主动删除
            NormalDestory = 2,//正常结束
            CoverDestory = 3,//被相同buff替代
        }
        /// <summary>
        /// Buff对象
        /// </summary>
        public IBuff buff { get; private set; }

        public Actor target { get; private set; }
        public Actor caster { get; private set; }
        public BuffChangeType type { get; private set; }

        public DestroyedReason destroyedReason = DestroyedReason.None;
        
        
        private List<int> UIBuffIDs = new List<int>(6);
        private List<int> UIBuffLayers = new List<int>(6);

        public void Init(IBuff buff, Actor caster, Actor target, BuffChangeType type,DestroyedReason destroyedReason)
        {
            this.buff = buff;
            this.caster = caster;
            this.target = target;
            this.type = type;
            this.destroyedReason = destroyedReason;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventBuffChange>();
            eventData.buff = buff;
            eventData.caster = caster;
            eventData.target = target;
            eventData.type = type;
            eventData.destroyedReason = destroyedReason;
            return eventData;
        }

        #region lua层使用

        public int currentBuffNum = 0;
        public void ExpendParamForLua()
        {
            currentBuffNum = 0;
            UIBuffIDs.Clear();
            UIBuffLayers.Clear();
            if (target != null && target.buffOwner != null)
            {
                currentBuffNum = target.buffOwner.UpdateUIBuffDatas();
                for (int i = 0; i < currentBuffNum; i++)
                {
                    var UIBuffData = target.buffOwner.GetUIBuffData(i);
                    int id = 0;
                    int layer = 0;
                    if (UIBuffData != null)
                    {
                        id = UIBuffData.ID;
                        layer = UIBuffData.showLayer?UIBuffData.layer:0;
                    }
                    UIBuffIDs.Add(id);
                    UIBuffLayers.Add(layer);
                }
            }
        }
        
        public int GetUIBuffID(int i)
        {
            if (i >= UIBuffIDs.Count||i<0)
            {
                return 0;
            }

            return UIBuffIDs[i];
        }
        
        public int GetUIBuffLayer(int i)
        {
            if (i >= UIBuffLayers.Count||i<0)
            {
                return 0;
            }

            return UIBuffLayers[i];
        }
        #endregion
        
    }

    /// <summary>
    /// buff层数改变事件
    /// </summary>
    public class EventBuffLayerChange : ECEventDataBase
    {
        //变化的层数
        public int layer { get; private set; }
        public X3Buff buff { get; private set; }
        public Actor target { get; private set; }
        public Actor caster { get; private set; }
        public BuffChangeType type { get; private set; }
        public int currentLayer { get; private set; }

        public void Init(X3Buff buff, Actor caster, Actor target, int changeLayer, BuffChangeType type)
        {
            this.buff = buff;
            this.layer = changeLayer;
            this.caster = caster;
            this.target = target;
            this.type = type;
            this.currentLayer = buff.layer;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventBuffLayerChange>();
            eventData.buff = buff;
            eventData.layer = layer;
            eventData.caster = caster;
            eventData.target = target;
            eventData.type = type;
            eventData.currentLayer = currentLayer;
            return eventData;
        }

        #region lua层使用

        public int buffUIIndex
        {
            get
            {
                int UIIndex = 0;
                if (buff != null && buff.showLayer && target != null && target.buffOwner != null)
                {
                    int count = target.buffOwner.UpdateUIBuffDatas();
                    for (int i = 0; i < count; i++)
                    {
                        if (target.buffOwner.GetUIBuffData(i) == buff)
                        {
                            UIIndex = i + 1;
                            break;
                        }
                    }
                }

                return UIIndex;
            }
        }

        #endregion
    }

    public class EventEnergyFull : ECEventDataBase
    {
        public AttrType type { get; private set; }
        public Actor actor { get; private set; }

        public void Init(AttrType type, Actor actor)
        {
            this.actor = actor;
            this.type = type;
        }
    }

    public class EventEnergyExhausted : ECEventDataBase
    {
        public AttrType type { get; private set; }
        public Actor actor { get; private set; }

        public void Init(AttrType type, Actor actor)
        {
            this.actor = actor;
            this.type = type;
        }
    }

    /// <summary>
    /// 技能释放事件
    /// </summary>
    public class EventCastSkill : ECEventDataBase
    {
        /// <summary>
        /// 技能对象
        /// </summary>
        public ISkill skill { get; private set; }

        /// <summary>
        /// 技能目标, 有可能为空
        /// </summary>
        public Actor skillTarget { get; private set; }

        public void Init(ISkill skill)
        {
            this.skill = skill;
            this.skillTarget = skill.actor.GetTarget(TargetType.Skill);
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventCastSkill>();
            eventData.skill = this.skill;
            eventData.skillTarget = this.skillTarget;
            return eventData;
        }
    }
    
    // 主动技能切换事件（必须当前技能不为空，切下个技能才发）在新技能未结束，老技能未开始时
    public class EventSwitchRunningSkill : ECEventDataBase
    {
        public ISkill curSkill { get; private set; }
        public ISkill nextSkill { get; private set; }

        public void Init(ISkill _curSkill, ISkill _nextSkill)
        {
            curSkill = _curSkill;
            nextSkill = _nextSkill;
        }
    }

    /// <summary>
    /// 技能可被打断事件
    /// 收到该事件后，表示该技能被打断
    /// </summary>
    public class EventCanInterruptSkill : ECEventDataBase
    {
        /// <summary>
        /// 技能对象
        /// </summary>
        public ISkill skill { get; private set; }

        public void Init(ISkill skill)
        {
            this.skill = skill;
        }
    }

    /// <summary>
    /// 击杀目标事件
    /// </summary>
    public class EventOnKillTarget : ECEventDataBase
    {
        public DamageExporter damageExporter => hitInfo.damageExporter;

        public HitInfo hitInfo { get; private set; }

        /// 击杀者
        public Actor killer { get; private set; }

        /// 被击杀者
        public Actor deader { get; private set; }

        public void Init(HitInfo hitInfo, Actor killer, Actor deader)
        {
            this.hitInfo = hitInfo;
            this.killer = killer;
            this.deader = deader;
        }
    }

    /// <summary>
    /// actor 指令。 指令enter后发送该事件
    /// </summary>
    public class EventActorCommand : ECEventDataBase
    {
        public Actor owner { get; private set; } // cmd 的所有者
        public ActorCmd cmd { get; private set; } // 指令

        public void Init(Actor owner, ActorCmd cmd)
        {
            this.owner = owner;
            this.cmd = cmd;
        }
    }

    /// <summary>
    /// actor 指令。 指令结束
    /// </summary>
    public class EventActorCmdFinished : ECEventDataBase
    {
        public ActorCmd cmd { get; private set; }

        public void Init(ActorCmd cmd)
        {
            this.cmd = cmd;
        }
    }

    // actor是否处于可见事件
    public class EventActorVisible : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public bool visible { get; private set; }

        public void Init(Actor actor, bool visible)
        {
            this.actor = actor;
            this.visible = visible;
        }
    }

    /// <summary>
    /// 角色AI是否禁用
    /// </summary>
    public class EventActorAIDisabled : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public bool disabled { get; private set; }

        public void Init(Actor actor, bool disabled)
        {
            this.actor = actor;
            this.disabled = disabled;
        }
    }
    
    /// <summary>
    /// actor 指令。 角色换组件
    /// </summary>
    public class EventActorChangeParts : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public string[] parts { get; private set; } // 部件列表
        public bool isBrokenSuit = false;

        public void Init(Actor actor, string[] parts, bool isBrokenSuit = false)
        {
            this.actor = actor;
            this.parts = parts;
            this.isBrokenSuit = isBrokenSuit;
        }
    }
    
    /// <summary>
    /// 拾取道具
    /// </summary>
    public class EventPickItem : ECEventDataBase
    {
        public Actor picker { get; private set; }
        public Actor item { get; private set; }
        
        public void Init(Actor picker, Actor item)
        {
            this.picker = picker;
            this.item = item;
        }
    }
    
    /// <summary>
    /// 接受信号
    /// </summary>
    public class EventReceiveSignal : ECEventDataBase
    {
        public Actor reciever { get; private set; }
        public Actor writer { get; private set; }

        public string signalKey { get; private set; }

        public string signalValue { get; private set; }

        public void Init(Actor reciever, Actor writer, string signalKey, string signalValue)
        {
            this.reciever = reciever;
            this.writer = writer;
            this.signalKey = signalKey;
            this.signalValue = signalValue;
        }
    }

    /// <summary>
    /// 锁血事件
    /// </summary>
    public class EventLockHp : ECEventDataBase
    {
        /// <summary> 触发锁血的那个Actor(被打的那个) </summary>
        public Actor actor => damageInfo.actor;

        public HitInfo hitInfo { get; private set; }

        public DamageInfo damageInfo { get; private set; }

        public float lockHpValue { get; private set; }

        public int lockHpBuffId { get; private set; }

        public void Init(HitInfo hitInfo, DamageInfo damageInfo, float lockHpValue, int lockHpBuffId)
        {
            this.hitInfo = hitInfo;
            this.damageInfo = damageInfo;
            this.lockHpValue = lockHpValue;
            this.lockHpBuffId = lockHpBuffId;
        }
    }

    /// <summary>
    /// 关卡信号
    /// </summary>
    public class EventLevelSignal : ECEventDataBase
    {
        public string signalKey { get; private set; }
        public string signalValue { get; private set; }
        public Actor signalWriter { get; private set; }

        public void Init(Actor signalWriter, string signalKey, string signalValue)
        {
            this.signalWriter = signalWriter;
            this.signalKey = signalKey;
            this.signalValue = signalValue;
        }
    }

    /// <summary>
    /// 关卡事件
    /// </summary>
    public class EventLevelEvent : ECEventDataBase
    {
        public string eventName { get; private set; }
        public Actor sendActor { get; private set; }

        public void Init(string eventName, Actor sendActor)
        {
            this.eventName = eventName;
            this.sendActor = sendActor;
        }
    }

    public class EventOnFoundGround : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public EasyCharacterMovement.FindGroundResult groundResult { get; private set; }

        public void Init(Actor actor, EasyCharacterMovement.FindGroundResult groundResult)
        {
            this.actor = actor;
            this.groundResult = groundResult;
        }
    }
    
    public class EventOnSwitchMoveMode : ECEventDataBase
    {
        public Actor actor { get; private set; }
        // true: Enter  false:Exit
        public bool isEnter { get; private set; }
        public MovementModeBase curMode { get; private set; }

        public void Init(Actor actor, MovementModeBase mode, bool isEnter)
        {
            this.actor = actor;
            this.curMode = mode;
            this.isEnter = isEnter;
        }
    }

    public class EventScalerChange : ECEventDataBase
    {
        public object timeScalerOwner { get; private set; }
        public float timeScale { get; private set; }
        public Dictionary<int, float> changeDatas { get; private set; }

        public void Init(object timeScalerOwner,float timeScale, Dictionary<int, float> changeDatas)
        {
            this.timeScalerOwner = timeScalerOwner;
            this.timeScale = timeScale;
            this.changeDatas = changeDatas;
        }
    }

    public class EventShieldChange : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public float oldValue { get; private set; }
        public float newValue { get; private set; }
        
        public void Init(Actor actor, float oldValue, float newValue)
        {
            this.actor = actor;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
    }

    public class EventCreateItem : ECEventDataBase
    {
        public Actor itemActor { get; private set; }
        public int itemID { get; private set; }

        public void Init(Actor itemActor, int itemID)
        {
            this.itemID = itemID;
            this.itemActor = itemActor;
        }
    }

    public class EventOnAddShield : ECEventDataBase
    {
        public Actor caster { get; private set; } // 添加护盾的人
        public Actor target { get; private set; }  // 被添加护盾的人
        public IBuff castBuff { get; private set; } // 添加护盾的buff

        public ShieldAddInfo addInfo { get; private set; }

        public void Init(IBuff castBuff, Actor target, ShieldAddInfo addInfo)
        {
            this.caster = castBuff.GetCaster();
            this.target = target;
            this.castBuff = castBuff;
            this.addInfo = addInfo;
        }

        public override void OnRecycle()
        {
            caster = null;
            target = null;
            castBuff = null;
            addInfo = null;
        }
    }
    
    public class EventWeakFull : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public HitInfo hitInfo { get; private set; }

        public void Init(Actor actor, HitInfo hitInfo)
        {
            this.actor = actor;
            this.hitInfo = hitInfo;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventWeakFull>();
            eventData.actor = actor;
            eventData.hitInfo = hitInfo;
            return eventData;
        }

        public string WeakSound
        {
            get
            {
                if (actor != null)
                {
                    return actor.monsterCfg.WeakSound;
                }
                return null;
            }
        }

    }

    /// <summary>
    /// 出生镜头状态变化事件
    /// </summary>
    public class EventBornCameraState : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public BornCameraState state { get; private set; }

        public void Init(Actor actor, BornCameraState state)
        {
            this.actor = actor;
            this.state = state;
        }
    }

    public class EventTimeLineWithVirCam : ECEventDataBase
    {
        /// <summary>
        /// 一个hashCode值，owner值
        /// </summary>
        public int owner { get; private set; }

        /// <summary>
        /// Timeline的释放者，男主或怪物
        /// </summary>
        public Actor actor { get; private set; }

        /// <summary>
        /// Timeline下绑定的virtualCamera
        /// </summary>
        public GameObject virCam { get; private set; }

        /// <summary>
        /// 发该事件是在Timeline开始还是结束,开始为true，结束为false
        /// </summary>
        public bool isStart { get; private set; }

        public void Init(int owner, Actor actor, GameObject virCam, bool isStart)
        {
            this.actor = actor;
            this.virCam = virCam;
            this.isStart = isStart;
            this.owner = owner;
        }
    }

    public class EventDamageExporterMeter : ECEventDataBase
    {
        /// <summary>
        /// 伤害源 目前 ISkill & IBuff 继承 DamageExporter
        /// </summary>
        public DamageExporter damageExporter { get; private set; }

        /// <summary>
        /// 受击的伤害列表
        /// </summary>
        public List<DamageMeter> damageMeters { get; private set; }

        public Actor skillTarget => damageExporter.actor.GetTarget(TargetType.Skill);
        public bool isHitSkillTarget;

        public void Init(DamageExporter damageExporter, List<DamageMeter> damageMeters)
        {
            this.damageExporter = damageExporter;
            this.damageMeters = damageMeters;
            isHitSkillTarget = false;
            foreach (DamageMeter damageMeter in damageMeters)
            {
                if (damageMeter.actor == skillTarget)
                {
                    isHitSkillTarget = true;
                    break;
                }
            }
        }
    }

    public class EventCoreChange : ECEventDataBase
    {
        public Actor actor { get; private set; }
        public bool isCoreDamage { get; private set; } // 是否是由芯核伤害造成的芯核值变化
        public HitInfo hitInfo { get; private set; }

        public void Init(Actor actor, bool isCoreDamage, HitInfo hitInfo)
        {
            this.actor = actor;
            this.isCoreDamage = isCoreDamage;
            this.hitInfo = hitInfo;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventCoreChange>();
            eventData.actor = actor;
            eventData.isCoreDamage = isCoreDamage;
            eventData.hitInfo = null;//这个hitInfo会在外部很快销毁，UI暂时不用
            return eventData;
        }
    }

    public class EventCoreMaxChange : ECEventDataBase
    {
        public Actor actor { get; private set; }

        public void Init(Actor actor)
        {
            this.actor = actor;
        }
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventCoreMaxChange>();
            eventData.actor = actor;
            return eventData;
        }
        
        #region lua层使用

        public float maxCore
        {
            get
            {
                if (actor != null && actor.actorWeak != null)
                {
                    return actor.actorWeak.ShieldMax;
                }
                return 0f;
            }
        }
        
        #endregion

    }

    public class EventWeakEnd : ECEventDataBase
    {
        public Actor actor { get; private set; }

        public void Init(Actor actor)
        {
            this.actor = actor;
        }
    }

    /// <summary>
    /// 法术场状态改变
    /// </summary>
    public class EventMagicFieldState : ECEventDataBase
    {
        public int magicFieldID => magicFieldCfg.ID;

        public MagicFieldCfg magicFieldCfg => skillMagicField.magicFieldCfg;

        public MagicFieldStateType state { get; private set; }

        public SkillMagicField skillMagicField { get; private set; }

        /// <summary> 法术场的主人 </summary>
        public Actor master => actor.master;

        /// <summary> 法术场Actor </summary>
        public Actor actor => skillMagicField.actor;

        public void Init(SkillMagicField skillMagicField, MagicFieldStateType type)
        {
            this.skillMagicField = skillMagicField;
            this.state = type;
        }
    }

    /// <summary>
    /// 空气墙状态改变
    /// </summary>
    public class EventObstacleState : ECEventDataBase
    {
        public int obstacleID { get; private set; }

        public bool state;

        public void Init(int obstacleID, bool state)
        {
            this.obstacleID = obstacleID;
            this.state = state;
        }
    }

    /// <summary>
    /// 显示战斗指引UI
    /// </summary>
    public class EventShowMissionTips : ECEventDataBase
    {
        public int tipsID { get; private set; }
        public int type { get; private set; }
        
        public int slot { get; private set; }
        public int operation { get; private set; }
        public float value { get; private set; }

        public void Init(int tipsID, ShowMissionTipsType type,int slot,Arithmetic operation,float value)
        {
            this.tipsID = tipsID;
            this.type = (int) type;
            this.slot = slot;
            this.operation = (int)operation;
            this.value = value;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventShowMissionTips>();
            eventData.tipsID = tipsID;
            eventData.type = type;
            eventData.slot = slot;
            eventData.operation = operation;
            eventData.value = value;
            return eventData;
        }
    }

    /// <summary>
    /// Debug下隐藏指定UI
    /// </summary>
    public class EventDebugHideUI : ECEventDataBase
    {
        public DebugUIHideType UIHideType { get; private set; }
        public bool Active { get; private set; }

        public void Init(DebugUIHideType type, bool active)
        {
            this.UIHideType = type;
            this.Active = active;
        }
        
        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDebugHideUI>();
            eventData.UIHideType = UIHideType;
            eventData.Active = Active;
            return eventData;
        }
    }

    public class EventChangeLevelState : ECEventDataBase
    {
        //上一次关卡战斗状态
        public LevelBattleState lastLevelBattleState { get; private set; }

        //当前关卡战斗状态
        public LevelBattleState curLevelBattleState { get; private set; }

        public void Init(LevelBattleState lastLevelBattleState, LevelBattleState curLevelBattleState)
        {
            this.lastLevelBattleState = lastLevelBattleState;
            this.curLevelBattleState = curLevelBattleState;
        }
    }

    public class EventDamageInvalid : ECEventDataBase
    {
        public DamageInvalidType damageInvalidType { get; private set; }
        public HitInfo hitInfo { get; private set; }

        public void Init(HitInfo hitInfo, DamageInvalidType invalidType)
        {
            this.hitInfo = hitInfo;
            this.damageInvalidType = invalidType;
        }
    }

    public class OnEventEnterHurt : ECEventDataBase
    {
        public Actor caster { get; private set; }
        public Actor target { get; private set; }
        public HitInfo hitInfo { get; private set; }

        public void Init(Actor caster, Actor target, HitInfo hitInfo)
        {
            this.caster = caster;
            this.target = target;
            this.hitInfo = hitInfo;
        }
    }

    public class EventDamageCritical : ECEventDataBase
    {
        public DamageExporter damageExporter => hitInfo.damageExporter;
        public DamageBoxCfg damageBoxCfg => hitInfo.damageBoxCfg;
        public HitParamConfig hitParamConfig => hitInfo.hitParamConfig;
        public float damageProportion { get; private set; }
        public Actor target => hitInfo.damageTarget;

        // 策划可动态配置的一个数据包
        public HitInfo hitInfo { get; private set; }

        public DynamicHitInfo dynamicHitInfo { get; private set; }

        public void Init(HitInfo hitInfo, DynamicHitInfo dynamicHitInfo, float damageProportion)
        {
            this.hitInfo = hitInfo;
            this.damageProportion = damageProportion;
            this.dynamicHitInfo = dynamicHitInfo;
        }

        public override void OnRecycle()
        {
            this.hitInfo = null;
            this.dynamicHitInfo = null;
        }
    }

    /// <summary>
    /// 伤害前事件 (与伤害输出前事件不同)
    /// </summary>
    public class EventPrevDamage : ECEventDataBase
    {
        public DamageExporter damageExporter => hitInfo.damageExporter;
        public DamageBoxCfg damageBoxCfg => hitInfo.damageBoxCfg;
        public HitParamConfig hitParamConfig => hitInfo.hitParamConfig;
        public float damageProportion { get; private set; }
        public float damageRandomValue { get; private set; }
        public bool isCritical { get; private set; }
        public Actor target => hitInfo.damageTarget;

        // 策划可动态配置的一个数据包
        public HitInfo hitInfo { get; private set; }

        public DynamicHitInfo dynamicHitInfo { get; private set; }

        public void Init(HitInfo hitInfo, DynamicHitInfo dynamicHitInfo, float damageProportion, bool isCritical, float damageRandomValue)
        {
            this.hitInfo = hitInfo;
            this.damageProportion = damageProportion;
            this.dynamicHitInfo = dynamicHitInfo;
            this.isCritical = isCritical;
            this.damageRandomValue = damageRandomValue;
        }

        public override void OnRecycle()
        {
            this.hitInfo = null;
            this.dynamicHitInfo = null;
            this.isCritical = false;
        }
    }

    public class EventHitProcessStart : ECEventDataBase
    {
        public DamageExporter damageExporter { get; private set; }
        public DamageBoxCfg damageBoxCfg { get; private set; }
        public HitParamConfig hitParamConfig { get; private set; }

        public void Init(DamageExporter damageExporter, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig)
        {
            this.damageExporter = damageExporter;
            this.damageBoxCfg = damageBoxCfg;
            this.hitParamConfig = hitParamConfig;
        }

        public override void OnRecycle()
        {
            this.damageExporter = null;
            this.damageBoxCfg = null;
            this.hitParamConfig = null;
        }
    }

    public class EventHitProcessEnd : ECEventDataBase
    {
        public DamageExporter damageExporter { get; private set; }
        public DamageBoxCfg damageBoxCfg { get; private set; }
        public HitParamConfig hitParamConfig { get; private set; }
        public bool hasExportedDamage { get; private set; }

        public void Init(DamageExporter damageExporter, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, bool hasExportedDamage)
        {
            this.damageExporter = damageExporter;
            this.damageBoxCfg = damageBoxCfg;
            this.hitParamConfig = hitParamConfig;
            this.hasExportedDamage = hasExportedDamage;
        }

        public override void OnRecycle()
        {
            this.damageExporter = null;
            this.damageBoxCfg = null;
            this.hitParamConfig = null;
        }
    }
    
    public class EventDialogueText : ECEventDataBase
    {
        public int name;
        public int content;
        public float time;
        public void Init(int name, int content,float time)
        {
            this.name = name;
            this.content = content;
            this.time = time;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDialogueText>();
            eventData.name = name;
            eventData.content = content;
            eventData.time = time;
            return eventData;
        }
        public override void OnRecycle()
        {
            this.time = 0;
        }
    }
    
    public class EventUpdatePenalty : ECEventDataBase
    {
        public int insID;
        public float radius;
        public void Init(int insID, float radius)
        {
            this.insID = insID;
            this.radius = radius;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventUpdatePenalty>();
            eventData.insID = insID;
            eventData.radius = radius;
            return eventData;
        }
        public override void OnRecycle()
        {
            this.insID = 0;
            this.radius = 0;
        }
    }

    public class EventActorFrozen : ECEventDataBase
    {
        public static readonly int sEffectHalfTime = 1;
        public static readonly int sEffectClick = 2;

        public Actor actor;
        public bool isEnterFrozen;
        public int effectType; //1:时间过半特效，2.点击特效

        public void Init(Actor actor, bool isEnterFrozen, int effectType)
        {
            this.actor = actor;
            this.isEnterFrozen = isEnterFrozen;
            this.effectType = effectType;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventActorFrozen>();
            eventData.actor = actor;
            eventData.isEnterFrozen = isEnterFrozen;
            eventData.effectType = effectType;
            return eventData;
        }

        public override void OnRecycle()
        {
            this.actor = null;
            this.isEnterFrozen = false;
            this.effectType = 0;
        }
    }
 
    /// <summary>
    /// 战斗沟通播放
    /// </summary>
    public class EventDialoguePlay : ECEventDataBase
    {
        public DialogueNode node { get; private set; }
        
        public void Init(DialogueNode node)
        {
            this.node = node;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDialoguePlay>();
            eventData.node = node;
            return eventData;
        }
        public override void OnRecycle()
        {
            this.node = null;
        }
    }
    
    /// <summary>
    /// 战斗沟通被打断
    /// </summary>
    public class EventDialogueInterrupt : ECEventDataBase
    {
        //打断前node
        public DialogueNode currNode { get; private set; }
        //打断后Node
        public DialogueNode interruptNode { get; private set; }
        public void Init(DialogueNode currNode, DialogueNode interruptNode)
        {
            this.currNode = currNode;
            this.interruptNode = interruptNode;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDialogueInterrupt>();
            eventData.currNode = currNode;
            eventData.interruptNode = interruptNode;
            return eventData;
        }
        public override void OnRecycle()
        {
            this.currNode = null;
            this.interruptNode = null;
        }
    }
    
    /// <summary>
    /// 战斗沟通结束
    /// </summary>
    public class EventDialoguePlayEnd : ECEventDataBase
    {
        public DialogueNode node { get; private set; }
        
        public void Init(DialogueNode node)
        {
            this.node = node;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDialoguePlayEnd>();
            eventData.node = node;
            return eventData;
        }
        public override void OnRecycle()
        {
            this.node = null;
        }
    }
    
    /// <summary>
    /// 战斗沟通播放失败
    /// </summary>
    public class EventDialoguePlayError : ECEventDataBase
    {
        public DialogueNode node { get; private set; }
        
        public void Init(DialogueNode node)
        {
            this.node = node;
        }

        public override ECEventDataBase Clone()
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventDialoguePlayError>();
            eventData.node = node;
            return eventData;
        }
        public override void OnRecycle()
        {
            this.node = null;
        }
    }
    
    /// <summary>
    /// 单位创建出来但是在Born之前，用于修改bornConfig
    /// </summary>
    public class EventCreateBeforeBornStep : ECEventDataBase
    {
        public ActorBornCfg bornCfg { get; private set; }
        
        public void Init(ActorBornCfg bornCfg)
        {
            this.bornCfg = bornCfg;
        }
        
        public override void OnRecycle()
        {
            this.bornCfg = null;
        }
    }
    
    /// <summary>
    /// 交互物交互完成
    /// </summary>
    public class EventInterActorDone : ECEventDataBase
    {
        public int pointInsId { get; private set; }//交互物 pointInsid
        
        public int insId { get; private set; }//交互物 insid
        public int cfgId { get; private set; }//交互物组件ID
        public int res { get; private set; }//交互物交互结果 0 表示直接触发交互完成 不用点击按钮 1 2 3 4 表示点击的交互按钮

        public void Init(int pointInsId, int res, int cfgId, int insId)
        {
            this.pointInsId = pointInsId;
            this.cfgId = cfgId;
            this.res = res;
            this.insId = insId;
        }
    }
}