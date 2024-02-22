using System;
using System.Collections.Generic;
using Framework;
using MessagePack;
using NodeCanvas.Framework;
using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.UI;
using X3.Character;
using X3.PlayableAnimator;
using ISubsystem = X3.Character.ISubsystem;

namespace X3Battle
{
    // 战斗运行状态
    public enum BattleRunStatus
    {
        Ready = 1,
        Begin,
        Success,
        Fail,
    }

    public enum BattleWndMode
    {
        Normal = 0,
        Fps,
    }

    /// <summary>
    /// 战斗组件
    /// 此枚举值越大更新时机越晚
    /// 注意，表现向的组件，应该放在逻辑向组件之后！！
    /// </summary>
    public enum BattleComponentType
    {
        // 逻辑向的组件！
        TimeScaler = 0,
        BattleTimer,
        FrameUpdate,
        BattleMisc,
        ModelMgr,
        ActorMgr,
        PlayerInput,
        SequencePlayer,
        BattleSetting,
        BattleStatistics,
        TriggerMgr,
        BattleReplay,
        BattleStrategy,
        Gameplay,
        BattleDirGuide,
        BattleCheatStatistics,
        BattlePvRecord,
        BattleDamageProcess,
        BattleGlobalBlackboard,
        GridPenaltyMgr,//寻路网格惩罚管理器
        WwiseBattleManager,
        // lua端战斗框架
        LuaClient,

        // 表现向的组件！
        Dialogue,
        CameraImpulse, // 相机震屏
        CameraTrace, // 追踪镜头
        PPVMgr, // ppv管理
        BattleUI, // 战斗UI
        FloatWordMgr, // UI飘字
        PlayerSelectFx, // 选中特效

        // 最大组件个数
        Num
    }
    
    public enum TimerTickMode
    {
        Update,
        LateUpdate
    }

    // 阵营关系
    public enum FactionRelationship
    {
        Enemy = 1, // 敌对
        Neutral = 2, // 中立
        Friend = 3, // 友方
    }
    
    // 阵营关系Flag
    [Flags]
    public enum FactionRelationshipFlag
    {
        Enemy = 1 << FactionRelationship.Enemy,
        Neutral = 1 << FactionRelationship.Neutral,
        Friend = 1 << FactionRelationship.Friend,
    }

    // 引导tip
    public enum TipType
    {
        CenterTip = 1, //屏幕中央tips
        LeftBoyDialog = 2, //左侧男主对话框
        RightLevelTarget = 3, //右侧关卡目标tips（支持蓝图节点动态设置指定位置参数）
        AffixTip = 4, //关卡倒计时旁词缀提示
        RightLevelTarget2 = 11, //右侧关卡目标tips
    }

    // 形状盒的跟随模式
    public enum ShapeBoxFollowMode
    {
        PositionAndRotation = 0, // 位置和旋转
        None = 1, // 不跟随位置和旋转
        Position = 2, // 位置
        Rotation = 3, // 旋转
    }

    public struct WarnFxCfg
    {
        public int fxID;
        public float duration;
        public bool isFollow;
        public Vector3 pos;
        public Vector3 angle;
        public float centralAngle;
        public WarnType type;
        public TargetType targetType;
        public float radius;
        public float length;
        public float width;
    }

    // 通用取点的目标类型
    public enum CoorTargetType
    {
        Skill = TargetType.Skill, // 技能目标
        Lock = TargetType.Lock, // 锁定目标
        Self = TargetType.Self, // 自己
        Boy = TargetType.Boy, // 男主
        Girl = TargetType.Girl, // 女主
        NearestEnemy = TargetType.NearestEnemy, // 最近的敌方单位
        Move = TargetType.Move, // 移动目标
        Record = 20, // record目标
    }

    public enum AffectTargetType
    {
        Skill = TargetType.Skill,
        Lock = TargetType.Lock, // 锁定目标
        Self = TargetType.Self, // 自己
        Boy = TargetType.Boy, // 男主
        Girl = TargetType.Girl, // 女主
        NearestEnemy = TargetType.NearestEnemy, // 最近的敌方单位
        Behurt = 20, // 受击者
    }

    public enum ItemTargetType
    {
        Girl = 0, // 女主
        Boy, // 男主
        FilterTarget, // 筛选的目标
    }

    // 缓动类型
    public enum TweenEaseType
    {
        Liner, // 线性
        EaseInQuad, // 二次方加速
        EaseOutQuad, // 二次方减速
    }

    // 伤害盒挂载类型
    public enum MountType
    {
        Self = 1, // 自身
        Target = 2, // 目标
        World = 3, // 世界坐标系
        Girl = 4, // 女主
        Boy = 5, // 男主
        HpLessOfManAndWoman = 6, // 男女主中血少的
        CastingActorTrans = 7,  // 技能释放时人物的Trans信息
    }

    //移动动画名 TODO 转移到const
    public static class MoveRunAnimName
    {
        public const string Run = "Run";
        public const string RunStop = "RunStop";
        public const string Walk = "WalkForward";
    }

    public enum AIMoveType
    {
        Run = 1, //跑
        Walk = 2, //走
    }

    public enum LevelMonsterMode
    {
        Alive,
        Kill,
    }

    public enum LevelMonsterType
    {
        Boy = 0,
        Girl,
        Monster,
        ActorList,
    }

    public enum LevelTargetType
    {
        None,
        Girl,
        Boy,
        BoyOrGirl,
        Monster,
    }

    /// <summary>
    /// 关卡计时类型 正序or倒序
    /// </summary>
    public enum TimeLimitType
    {
        Positive = 1,
        Reverse = 2,
    }

    public enum MonsterCountListenerMode
    {
        MonsterActive, // 计入已激活怪物
        MonsterActiveFinish, // 仅计入真正创建出来的怪物
    }

    public static class MoveWanderAnimName
    {
        public const string Forward = "WalkForward";
        public const string Right = "WalkRight";
        public const string Back = "WalkBack";
        public const string Left = "WalkLeft";
        public const string ForwardStop = "WalkForwardStop";
        public const string RightStop = "WalkRightStop";
        public const string BackStop = "WalkBackStop";
        public const string LeftStop = "WalkLeftStop";
    }

    public static class MoveTurnAnimName
    {
        public const string TurnLeft = "TurnLeft";
        public const string TurnRight = "TurnRight";
    }

    //特效运行状态
    public enum FxRunType
    {
        Run = 1, //正常运行
        Ending = 2, //即将结束
        Destroying = 3, //销毁中
    }

    //特效随机旋转
    public enum BattleFXRandomRotateType
    {
        None = 1, //不随机
        Random = 2, //随机
    }

    //特效跟随类型
    public enum BattleFXFollowType
    {
        Not = 0, //不跟随
        All = 1, //所有
        PosOnly = 2, //仅位置
    }

    public enum BattleFXRandomHurtType
    {
        None = 1, //不随机
        Square = 2, //正方形随机
    }

    //AI蓝图使用的枚举，跟已有的ECompareOperator顺序不同，但是已经在使用了，Todo，刷一下数据
    public enum Operation
    {
        LessThan = 0,
        LessThanOrEqualTo = 1,
        EqualTo = 2,
        NotEqualTo = 3,
        GreaterThanOrEqualTo = 4,
        GreaterThan = 5
    }

    public enum ECompareOperator
    {
        [LabelText("等于")] EqualTo,
        [LabelText("不等于")] NotEqual,
        [LabelText("大于")] GreaterThan,
        [LabelText("小于")] LessThan,
        [LabelText("大于等于")] GreaterOrEqualTo,
        [LabelText("小于等于")] LessOrEqualTo
    }

    public enum ECoreCompareOperator
    {
        [LabelText("等于")] EqualTo,
        [LabelText("不等于")] NotEqual,
        [LabelText("大于")] GreaterThan,
        [LabelText("小于")] LessThan,
        [LabelText("大于等于")] GreaterOrEqualTo,
        [LabelText("小于等于")] LessOrEqualTo,
        [LabelText("是否等于最大值")] MaxEqualTo
    }

    public enum EEventTarget
    {
        [LabelText("全局")] All,
        [LabelText("目标")] Self,
        [LabelText("Girl")] Girl,
        [LabelText("Boy")] Boy,
        [LabelText("关卡")] Stage,
    }

    public enum EnergyType
    {
        Ultra = 1,
        Male,
        Weapon,
        Skill,
    }

    public enum BuffChangeType
    {
        Add = 1,
        Destroy,
        AddLayer,
        ReduceLayer,
    }

    public enum QTEButtonType
    {
        Dodge = 1,
        Link = 2,
        Wrestle = 3,
    }

    public enum QTEUnderlineType
    {
        Beeline = 1
    }

    public enum QTEResultType
    {
        Fail = 1,
        Success = 2,
        Perfect = 3,
    }

    // 技能结束原因
    public enum SkillEndType
    {
        Complete = 0,
        Interrupt = 1,
    }

    [Flags]
    public enum SkillEndFlag
    {
        Complete = 1 << (int)SkillEndType.Complete, // 正常结束（技能没有进行跳转、打断等，完整的执行了整个技能。）
        Interrupt = 1 << (int)SkillEndType.Interrupt, // 技能被打断了，包括技能跳转（含连招跳转）、移动打断、进入受击等等所有被打断的情况。
    }

    // 技能释放类型
    public enum SkillReleaseType
    {
        Active, // 主动技能     
        Passive, // 被动技能
    }

    // 索敌模块更新类型
    public enum TargetSelectorUpdateType
    {
        SkillSelectTarget = 1, // 技能释放时选择目标 (配合SkillSelectData使用)
        SkillEnd = 2, // 技能结束(配合skillId使用)
        SwitchTarget = 3, // 切换目标
        CancelLockCache = 4, // 取消手动模式下的缓存队列
        FixTarget = 5, // 固定目标（给战斗调试器用，目前只有AI模式会响应）
    }

    public enum MonsterType
    {
        Mobs = 1,
        Elite = 2,
        Boss = 3,
        Summon = 4,
    }

    public enum SkillAgentType
    {
        /*Bullet = 1, // 废弃*/
        Dynamic = 2,
        MagicField = 3, // 法术
        Missile = 4,
    }

    public enum ActorLifeStateType
    {
        Born = 1,
        Dead = 2,
        Recycle = 3,
        Destroy = 4
    }

    public enum ActorMainStateType
    {
        Born,
        Idle,
        Move,
        Skill,
        Dead,
        Abnormal,
        Num,
    }

    public enum ActorAbnormalType
    {
        None = -1,
        Hurt, // 受击（用于命中流程削韧和受击）
        Vertigo, // 眩晕(无法移动，无法技能)
        Weak, // 虚弱(无法移动，无法技能)
    }

    public enum InputCacheType
    {
        SkillPressDown = 1, // 目前只有按下
    }

    [Flags]
    public enum ActorStatus
    {
        InBirth = 1 << 0, // 出生中
        Born = 1 << 1, // 已出生
        Dying = 1 << 2, // 死亡中
        Dead = 1 << 3, // 已死亡
        Recycling = 1 << 4, // 回收中
        Recycled = 1 << 5, // 已回收
    }
    
    public enum ActorComponentType
    {
        TimeScaler = 0,
        Timer,
        ActorInput, // 用户输入
        Attribute,
        Actor,
        Transform,
        Model,
        TargetSelector,
        SequencePlayer,
        MainState,
        Commander,
        HP, // 生命模块
        Energy,
        Skill,
        Weak,
        Buff,
        AI,
        Signal,
        StateTag,
        Collider,
        Hurt,
        LookAt,
        Weapon,
        TriggerArea,
        MachineFlow,
        Obstacle,
        EffectPlayer,
        Hate,
        EventMgr,
        Halo,
        ShadowPlayer, // 残影
        Items,
        DamageMeters, // 伤害统计
        Taunt, //被嘲讽
        LocomotionView, // 运动表现
        Frozen,
        Idle, // 待机表现
        InteractorOwner,
        Shield,
        Num, // 这里需要确保Num是最大值
    }

    public enum MagicFieldStateType
    {
        Begin,
        End
    }

    /// <summary>
    /// 真机调试器专用
    /// </summary>
    public class DebugAction
    {
        public string id;
        public string goalName;
        public string targetName;
        public string holdTime;
    }

    public class TauntData : IComparable<TauntData>, IReset
    {
        // 嘲讽来源角色
        public Actor sourceActor { get; set; }

        // 角色的哪些buff造成了嘲讽
        public HashSet<IBuff> buffs = new HashSet<IBuff>();

        // 角色可选中
        public bool lockable { get; set; }

        // 排序用的索引，记录添加顺序
        public int index { get; set; }

        public int CompareTo(TauntData other)
        {
            return other.index - this.index;
        }

        public void Reset()
        {
            sourceActor = null;
            buffs.Clear();
            lockable = false;
            index = 0;
        }
    }

    public class RogueLevelWeight
    {
        public int id;
        public int weight;
        public int topWeight;
        public bool canDuplicate;
        public int conflictID;
    }

    public class RogueReward
    {
        public int type;
        public int rewardType;
        public int rewardParam;
    }
    
    public enum RogueRandomModeType 
    {
        Average = 0,
        Deduplication = 1,
    }

    //仇恨系统开始

    /// <summary>
    /// 仇恨数据基类
    /// </summary>
    public class HateDataBase : IReset
    {
        /// <summary>
        /// 角色实例id
        /// </summary>
        public int insId;

        /// <summary>
        /// 角色可选中
        /// </summary>
        public bool lockable;

        public virtual void Reset()
        {
            insId = 0;
            lockable = false;
        }
    }

    /// <summary>
    /// 敌方阵营的仇恨数据
    /// </summary>
    public class EnemyHateData : HateDataBase
    {
        /// <summary>
        /// 值；仅值类型有效
        /// </summary>
        public float value;

        /// <summary>
        /// 修正系数；仅值类型有效
        /// </summary>
        public float ratio;

        // 衰减时间
        public float attenuateTime;

        // 衰减周期
        public float attenuatePeriod;

        public EnemyHateData() : base()
        {
            ResetAttenuateData();
        }

        public void ResetAttenuateData()
        {
            attenuateTime = TbUtil.battleConsts.HateCheckPeriod;
            attenuatePeriod = 1f;
        }

        public override void Reset()
        {
            base.Reset();
            ResetAttenuateData();
            value = 0;
            ratio = 0;
        }
    }

    /// <summary>
    /// 主控的仇恨数据
    /// </summary>
    public class PlayerHateData : HateDataBase
    {
        /// <summary>
        /// 角色激活
        /// </summary>
        public bool active;

        /// <summary>
        ///权重
        /// </summary>
        public int weight;

        /// <summary>
        /// 单位威胁度评分
        /// </summary>
        public int threatenPoint;

        /// <summary>
        /// 单位类型评分
        /// </summary>
        public int typePoint;

        /// <summary>
        /// 锁定评分
        /// </summary>
        public int lockPoint;

        /// <summary>
        /// 镜头评分
        /// </summary>
        public int cameraPoint;

        /// <summary>
        /// 距离评分
        /// </summary>
        public int distancePoint;

        /// <summary>
        /// 距离
        /// </summary>
        public float sqrDistance;

        /// <summary>
        /// 距离女主的距离
        /// </summary>
        public float sqrGirlDistance;
    }
    //仇恨系统结束

    public enum CameraModeType
    {
        Battle = 0,
        FreeLook,
        NotBattle,
        BossBattle,
        StartBattle, // 战斗刚开始
        BoyDead,
        Num,
    }

    public enum ArtCameraType
    {
        None = 0,
        CoopSkill,
        SupportSkill,
        EXMaleActive,
    }

    public enum CameraAnimPlayType
    {
        None = 0,
        Hold = 1,
        Loop = 2,
    }

    public enum CameraEffectType
    {
        Shake = 0,
        PostProcess = 1,
        FullScreenEffect = 2
    }

    public enum CameraShakeDirType
    {
        Global = 0,
        Local
    }

    public enum CameraShakeCurveType
    {
        Linear,
        Quadratic,
    }

    public enum CameraShakeLayer
    {
        Short = 0,
        Long,
        LongAdditive,
    }

    public enum CameraStatusType
    {
        Standby = 0, //待机
        Live = 1, //直播
        Disabled = 2, //禁用
        Destroyed = 3, //销毁
    }

    public enum CameraCloseupPlayType
    {
        CutEnter2NoExit = 0, //---瞬进，无退
        CutEnter2CutExit = 1, //---瞬进，瞬退
        CutEnter2SmoothExit = 2, //---瞬进，平滑退
        SmoothEnter2NoExit = 3, //---平滑进，无退
        SmoothEnter2CutExit = 4, //---平滑进，瞬退
        SmoothEnter2SmoothExit = 5, //---平滑进，平滑退
    }

    public enum CameraPriorityType
    {
        None = -1,
        Lowest = 0, //---最低
        ProgrammingLow = 10, //---程序用，低
        Scene = 20, //---场景用
        ProgrammingMiddle = 30, //---程序用，中
        Timeline = 40, // ---CutScene、Timeline用
        Closeup = 50, // ---特写用
        ProgrammingHigh = 60, // ---程序用，高
    }

    public enum CameraDefaultBlendStyle
    {
        Cut = 0,
        EaseInOut = 1,
        EaseIn = 2,
        EaseOut = 3,
        HardIn = 4,
        HardOut = 5,
        Linear = 6,
        Custom = 7
    }

    /// <summary>
    /// 芯核类型
    /// </summary>
    public enum CoreType
    {
        None = 0,
        Elite = 1, // 精英
        Boss = 2, // Boss
    }

    /// <summary>
    /// 攻击方用的枚举
    /// </summary>
    public enum HurtType
    {
        LightHurt = 0,
        HeavyHurt,
        FloatHurt, // 挑飞
        FlyHurt, // 击飞
        LayDownHurt,
        Null,
        AddAnimHurt, //叠加受击动画
    }

    [Flags]
    public enum HurtTypeFlag
    {
        LightHurt = 1 << HurtType.LightHurt,
        HeavyHurt = 1 << HurtType.HeavyHurt,
        FloatHurt = 1 << HurtType.FloatHurt,
        FlyHurt = 1 << HurtType.FlyHurt,
        LayDownHurt = 1 << HurtType.LayDownHurt,
        Null = 1 << HurtType.Null,
    }

    public enum HurtDirType
    {
        Default,
        FaceDirection,
    }

    /// <summary>
    /// 最终受击类型
    /// </summary>
    public enum HurtStateType
    {
        None = 0, // 无
        LightHurt = 1, // 轻受击
        HeavyHurt, // 重受击
        Laydown, // 击倒
        HurtFly, // 击飞
        FloatHurt, // 击浮空
        LaydownHurt, // 倒地受击
        OnFlyHurt, // 浮空受击
        OnFlyLayDown, // 浮空击倒
        Num, //最大
    }

    //受击动画 用于判断是否进受击 //TODO 策划配置
    public static class HurtStateAnimName
    {
        public static readonly List<string[]> HeroNormalHurt = new List<string[]>((int)HurtStateType.Num)
        {
            { new string[4] { "HurtBack", "HurtLeft", "HurtFront", "HurtRight" } }, //1
            { new string[4] { "HurtBackHeavy", "HurtLeftHeavy", "HurtFrontHeavy", "HurtRightHeavy" } }, //2
            { new string[4] { "HurtBackHeavy", "HurtLeftHeavy", "HurtFrontHeavy", "HurtRightHeavy" } }, //3
            { new string[3] { "HurtFly_Start", "HurtFly_Loop", "HurtFly_Land" } }, //4
            { new string[2] { "HurtFloat", "HurtFloat_Land" } }, //5
            { new string[0] { } }, //6
            { new string[3] { "HurtFlyBeHit", "HurtFloat_Loop", "HurtFloat_Land" } },
            { new string[2] { "HurtFly_Loop", "HurtFly_Land" } },
        };

        public static readonly List<string[]> MobNormalHurt = new List<string[]>((int)HurtStateType.Num)
        {
            { new string[4] { "HurtBack", "HurtLeft", "HurtFront", "HurtRight" } },
            { new string[4] { "HurtBackHeavy", "HurtLeftHeavy", "HurtFrontHeavy", "HurtRightHeavy" } },
            { new string[3] { "HurtLie_Start", "HurtLie_Loop", "HurtLie_End" } },
            { new string[5] { "HurtFly_Start", "HurtFly_Loop", "HurtFly_Land", "HurtLie_Loop", "HurtLie_End" } },
            { new string[5] { "HurtFloat", "HurtFloat_Loop", "HurtFloat_Land", "HurtLie_Loop", "HurtLie_End" } },
            { new string[3] { "HurtLie_hit", "HurtLie_Loop", "HurtLie_End" } },
            { new string[5] { "HurtFlyBeHit", "HurtFloat_Loop", "HurtFloat_Land", "HurtLie_Loop", "HurtLie_End" } },
            { new string[4] { "HurtFloat_Loop", "HurtFloat_Land", "HurtLie_Loop", "HurtLie_End" } },
        };
        public static readonly string[] HurtName = new string[(int)HurtStateType.Num]
        {
            "无受击", "轻受击", "重受击", "击倒", "击飞", "击浮空", "倒地受击", "浮空受击", "浮空击倒"        
        };
    }

    public enum HurtShakeStrength
    {
        Low = 0,
        Medium = 1,
        High = 2,
        None,
    }

    /// <summary>
    /// 力方向枚举
    /// </summary>
    public enum ForceDirectionType
    {
        Default = 1,
        Right = 2,

        //Back = 3,
        Left = 4,
    }

    /// <summary>
    /// 受击方向枚举
    /// </summary>
    public enum HurtDirection
    {
        //受击方向
        Back = 1,
        Left = 2,
        Forward = 3,
        Right = 4,
    }

    public enum HurtBackStrategy
    {
        Default,
        Timeline,
        Attacker,
    }

    /// <summary>
    /// 受击之前处于的受击状态，与BattleHurt表中的ID对应
    /// </summary>
    public enum BeforeHurtState
    {
        DefaultIdle = 1,
        DefalutFloat = 2,
        LightHurtState = 3,
        HeavyHurtState = 4,
        FloatHurtState = 5,
        LayDownHurtState = 6,
        StandHurtState = 7,
        LayDownHurtCountFull = 8,
    }

    public enum BuffAction
    {
        Base = 0,
        Basic = 1,
        EndDamage = 2,
        StateTag = 3,
        HPShield = 4,
        Halo = 5,
        LockHP = 6,
        PlayMatAnim = 7,
        DynamicChangeAttr = 8,
        DynamicDamageModify = 9,
        SetToughness = 10,
        ForbidEnergyRecover = 11,
        Frozen,
        Ghost,
        Vertigo,
        PlayGroupFx,
        Weak,
        UnVisibility,
        RemoveDebuff,
        Drag,
        DisableSkill,
        SkillNoConsumption,
        AddTaunt,
        DynamicAttrModifier,
        RemoveMatchBuff,
        PlayFx,
        ChangeMaxHP,
        WitchTime,
        ModifySkillDamage,
    }
    

    public enum AttrChangeMode
    {
        Add = 1,
        Sub = 2,
        Any = 3
    }

    public enum AttrType
    {
        None = 0,
        MaxHP = 1, //---最大生命值          ---ID：1~1000为常规属性，需配置在Property中
        PhyAttack = 2, //---攻击力
        PhyDefence = 3, //---防御力
        CritVal = 4, //---暴击值 Critical value
        CritRate = 5, //---暴击率
        CritHurtAdd = 6, //---暴击伤害
        ElementRatio = 7, //---元素适应系数
        ATKSpeedUp = 9, //---普攻速度加成
        HurtAdd = 21, //---伤害加成
        HurtDec = 22, //---受到伤害减免
        CureAdd = 23, //---治疗效果增强
        CuredAdd = 24, //---受到治疗效果增强
        CDDec = 25, //---技能冷却缩减
        AttackSkillAdd = 26, //---普攻伤害提升
        ActiveSkillAdd = 27, //---主动技能伤害提升
        CoopSkillAdd = 28, //---连携技伤害提升
        UltraSkillAdd = 29, //---爆发技伤害提升
        RigidPoint = 30, //---刚性值（耐力值）
        MoveSpeed = 31, //---移动速度（千分比）
        TurnSpeed = 32, //---转向速度

        FinalDamageAdd = 34, // 最终伤害加成
        FinalDamageDec = 35, // 最终伤害减免
        IgnoreDefence = 36, // 忽视防御百分比
        WeakHurtAdd = 37, // 虚弱伤害加深

        ThumpSkillAdd = 38, // 重击类型技能伤害提升
        AssistSkillAdd = 39, // 协助类型技能伤害提升 
        WeaponAttackSkillAdd = 41, //武器普攻技能伤害提升
        WeaponActiveSkillAdd = 42, //武器主动技能伤害提升

        FinalDmgAddRate = 51, //---最终伤害修正倍率
        BoyEnergyMax = 52, // 男主能量最大值
        BoyEnergyInit = 53, // 男主能量初始值
        WeaponEnergyMax = 54, // 武器能量最大值

        WeaponEnergyInit = 55, // 武器能量初始值
        UltraEnergyMax = 56, // 爆发技能量最大值
        UltraEnergyInit = 57, // 爆发技能量初始值
        RootMotionMutiplierXZ = 58,
        RootMotionMutiplierY = 59,
        SkillEnergyMax = 60, // 技能能量最大值
        SkillEnergyInit = 61, // 技能能量初始值
        MaleEnergyGather = 62, // 男主能量获取效率（千分比）
        UltraEnergyGather = 63, // 爆发技能量获取效率（千分比）
        SkillEnergyGather = 64, // 技能能量获取效率（千分比）
        WeakDamageAdd = 65,//虚弱增伤属性值
        WeaponEnergyGather = 66,  // 武器能量获取效率
        GameplayDamageAdd = 67,  // 玩法增伤
        GameplayDamageDec = 68,  // 玩法减伤
        HpRecoverPerth = 69,  // 每秒生命回复千分比
        CoreDamageRatio = 70, // 芯核伤害倍率
        CoreDamageAdd = 71, // 芯核伤害加值
        
        HpShieldHurtAdd = 301, //---血量护盾加深
        HpShieldHurtDec = 302, //---血量护盾减免
        MaleEnergyRecover = 303, // 男主能量恢复
        WeaponEnergyRecover = 304, // 武器能量恢复
        UltraEnergyRecover = 305, // 爆发技能量恢复
        SkillEnergyRecover = 306, // 协作技能量恢复

        ShieldRecoverTime = 307, // 虚弱时长
        WeakPeriodRate = 308, // 破盾方,时长千分比调整值
        WeakPeriodAdd = 309, // 破盾方,固定增加值时长
        
        HpShieldObtainEfficiency = 310, //血量护盾获取效率
        HpShieldRatio  = 311, //护盾伤害减免系数
        
        //增加常规属性时，需要判断是否在BattleSummon表中增补属性字段。

        HP = 1000, //---当前血量 ----ID在1000以上的是【即时属性】
        WeakPoint = 1003, //---虚弱值
        HpShield = 1005, //---血量护盾
        MaleEnergy = 1009, // 男主能量
        WeaponEnergy = 1012, // 武器能量
        UltraEnergy = 1015, // 爆发技能量
        SkillEnergy = 1101, // 协作技能量
    }

    /// <summary> 即时属性 </summary>
    public enum InstantAttrType
    {
        Hp = AttrType.HP,
        WeakPoint = AttrType.WeakPoint,
        HpShield = AttrType.HpShield,
        MaleEnergy = AttrType.MaleEnergy,
        WeaponEnergy = AttrType.WeaponEnergy,
        UltraEnergy = AttrType.UltraEnergy,
        SkillEnergy = AttrType.SkillEnergy,
    }

    public enum RMMultiplierType
    {
        Base = 0, //基础
        MoveSpeedAttr, //移速属性
        AbnormalState, // 异常状态（受击等）
        Dominate, // 独占（例：跳台子）
    }

    public enum LockHPType
    {
        Fixed = 1,
        Ratio = 2,
    }

    public enum ShowMissionTipsType
    {
        Show = 1,
        Change,
        Close,
    }

    // 抗攻击等级修改模式
    public enum ToughnessSetType
    {
        Set, // 直接设置新的抗攻击等级
        Add, // 叠加
    }

    // 人物的锁定类型
    public enum LockRangeType
    {
        Melee = 0, // 近战
        Remote = 1, // 远程
    }

    // 索敌系统目标选择模式
    public enum TargetLockModeType
    {
        None = 0,//默认为空
        AI = 1, //普通模式，默认逻辑，可以锁定己方和敌方
        Smart = 2, //智能模式，女主使用，只能锁定敌方单位
        Manual = 3, // 手动模式, 目前仅点击锁定按钮的时候使用.
        Boss = 4 //Boss模式，女主使用 只能锁定Boss怪物
    }

    // 技能目标选择类型
    public enum TargetSelectType
    {
        Nothing = 0, // 什么都不选
        Self = 1,
        Girl = 2,
        Boy = 3,
        Lock = 4,
        NearestEnemy = 5,
    }

    // SkillLockChangeType 技能更新索敌模式
    public enum SkillLockChangeType
    {
        Update = 0, // 通常的攻击技能，会尝试更新一次目标和计时器
        Keep = 1, // 一些无攻击主动技能，如果当前没有锁定目标，也不会去取新目标
        Clear = 2, // 清除锁定目标，也直接结束计时器，目前会应用到闪避技能上
    }

    // 人物时间缩放
    public enum ActorTimeScaleType
    {
        Base = 0, // 基本时间，之前的卡肉属于base时间
        Witch = 1, // 魔女时间，新增的时间
        Num = 2, // 用于遍历
    }

    // 关卡时间缩放
    public enum LevelTimeScaleType
    {
        Base = 0, // 战斗基本时间，用于整体加速减速
        Bullet = 1, // 全局子弹时间，用于特殊技能慢镜头效果
        Pause = 2, // 用于暂停和恢复游戏
        Num = 3, // 用于遍历
    }

    // 关卡生成怪物模式
    public enum CreateGroupMonsterMode
    {
        Sequence = 0, // 顺序模式
        Random = 1, // 随机模式
    }

    public static class FSMEventName
    {
        public static readonly string[] MainStates = new string[(int)ActorMainStateType.Num]
        {
            "Born",
            "Idle",
            "Move",
            "Skill",
            "Dead",
            "Abnormal",
        };

        public static readonly string[] MainStatesEnd = new string[(int)ActorMainStateType.Num]
        {
            "BornEnd",
            "IdleEnd",
            "MoveEnd",
            "SkillEnd",
            "DeadEnd",
            "AbnormalEnd",
        };

        public static readonly Dictionary<ActorAbnormalType, string> AbnormalEvent = new Dictionary<ActorAbnormalType, string>
        {
            { ActorAbnormalType.None, "None" },
            { ActorAbnormalType.Vertigo, "Vertigo" },
            { ActorAbnormalType.Weak, "Weak" },
            { ActorAbnormalType.Hurt, "Hurt" },
        };
    }

    public static class AnimStateName
    {
        public const string Empty = "Empty";
        public const string Idle = "Idle";
        public const string WeaponIdle = "WeaponIdle";
        public const string RunStart = "RunStart";
        public const string RunStartLeft = "RunStartLeft";
        public const string RunStartRight = "RunStartRight";
        public const string Run = "Run";
        public const string RunLeft = "RunLeft";
        public const string RunRight = "RunRight";
        public const string RunStop = "RunStop";
        public const string RunStartStop = "RunStartStop";
        public const string TurnLeft = "TurnLeft";
        public const string TurnRight = "TurnRight";
        public const string TurnLeft90 = "TurnLeft90";
        public const string TurnLeft180 = "TurnLeft180";
        public const string TurnRight90 = "TurnRight90";
        public const string TurnRight180 = "TurnRight180";
        public const string TurnBack = "TurnBack";
        public const string Dodge = "Dodge";
        public const string HurtFrontAdditive = "HurtFrontAdditive";
    }

    public enum AnimatorLayerTimeScalerType
    {
        Default,
        BattleTimeScale,
        RealTime,
    }

    public static class AnimParams
    {
        public const string MoveSpeed = "MoveSpeed";
        public const string MoveDirection = "MoveDirection";
        public const string MoveIncline = "MoveIncline";
        public const string StopFoot = "StopFoot";
        public const string WalkRunBlend = "WalkRunBlend";
        public const string HurtFrontAdd = "HurtFrontAdd";
    }

    public static class AnimEvent
    {
        public const string PlayRunFx = "PlayRunFx";
        public const string SetStopFoot = "SetStopFoot";
    }

    public static class AnimConst
    {
        public const int DefaultLayer = 0;
        public const int HurtAdditiveLayer = 1;
        public const int AnimFrameCount = 30;
    }
    
    public enum ModifyShieldType
    {
        Add,
        Sub,
    }

    public enum MathParamType
    {
        MathParam1,
        MathParam2,
        MathParam3,
        MathParam4,
        MathParam5,
        MathParam6,
        MathParam7,
        MathParam8,
        MathParam9,
        MathParam10,
        MathParam11,
        MathParam12,
        MathParam13,
        MathParam14,
        MathParam15,
        MathParam16,
        MathParam17,
        MathParam18,
        MathParam19,
        MathParam20,
    }

    //@class BattleConst
    //@field DefaultCoopSlotID Int 默认协作技槽位ID
    //@field DefaultUltraSlotID Int 默认爆发技能槽位ID
    public static class BattleConst
    {
        public const float EPSINON = 0.00001f;

        public const string ExtPrefab = ".prefab";
        public const string ExtPng = ".png";
        public const string ExtTga = ".tga";
        public const string ExtAsset = ".asset";
        public const string ExtController = ".controller";
        public const string ExtBytes = ".bytes";
        public const string ExtMat = ".mat";
        public const string ExtPlayable = ".playable";
        public const string ExtAtlas = ".spriteatlas";
        public const int MaxPreloadCount = 10;
        public const int MaxCacheCount = 20;

        public const string ContextVariableName = "_Context";
        
        public const string LOD_MID = "_MD";
        public const string LOD_LOW = "_LD";

        public const float AnimFrameTime = 1 / 30f;
        public const float FrameTime = 1 / 60f;

        public const string MainFSMName = "MainFSM";
        public const string EmptyActorModelKey = "_InternalActorModelKey";
        public const string PathfinderGoName = "Astar";
        public const string ActorAIStatusUpdate = "_Internal_UpdateTreeStatus";

        //技能槽位间隔，普攻1~100，主动技能101~200
        public const int SkillSlotSpace = 100;
        // 无效角色ID
        public const int InvalidActorID = 0;
        // Actor实例ID的最大值
        public const int MaxActorInsID = InvalidActorID - 10000;
        // Actor种植ID的最小值
        public const int MinActorSpawnID = InvalidActorID + 10000;

        // 模型信息表名字
        public const string ModelInfosCfgFile = "ModelInfos";
        public const int InvalidActorSuitID = -1;
        public const int GirlScoreID = 0;

        public const string PhysicsWindConfigName = "PhysicsWindConfig";
        public const string BattleGlobalBlackboard = "BattleGlobalBlackboard";

        public const string LevelBeforeFsmName = "LevelBeforeFSM";
        public const string RogueFsmName = "RogueFSM";
        public const int LevelBeforeCameraActionModuleId = 1004;

        // Locomotion修正曲线资源名
        public const string LocomotionRatioAssetName = "LocomotionRatioAsset";
        // 特效ID分析时，特定的ResModule Name
        public const string FxResModule = "FXRESMODULE";
    }

    // 离线数学计算
    public static class MathConst
    {
        // sin45°值离线计算
        public const float sin45 = 0.7071f;

        // 局部坐标系xz平面八方向点，离线计算
        public static Vector3[] directions8 = new[]
        {
            new Vector3(0, 0, 1), // 前
            new Vector3(sin45, 0, sin45), // 右前
            new Vector3(-sin45, 0, sin45), //  左前
            new Vector3(1, 0, 0), // 右
            new Vector3(-1, 0, 0), // 左
            new Vector3(sin45, 0, -sin45), // 右后
            new Vector3(-sin45, 0, -sin45), // 左后
            new Vector3(0, 0, -1), // 后
        };
        
        // 局部坐标顺时针八方向
        public static Vector3[] clockwiseDirections8 = new[]
        {
            directions8[0],
            directions8[1],
            directions8[3],
            directions8[5],
            directions8[7],
            directions8[6],
            directions8[4],
            directions8[2],
        };
        
        // 局部坐标逆时针八方向
        public static Vector3[] anticlockwiseDirections8 = new[]
        {
            directions8[0],
            directions8[2],
            directions8[4],
            directions8[6],
            directions8[7],
            directions8[5],
            directions8[3],
            directions8[1],
        };
    }

    // QTE的方向
    public enum QTEDirection
    {
        First,
        Second,
        Third,
        Fourth,
        Fifth,
        Sixth,
        Seventh,
        Eighth,
    }
    
    // QTE的方向选择
    [Flags]
    public enum QTEDirectionFlag
    {
        First = 1 << QTEDirection.First,
        Second = 1 << QTEDirection.Second,
        Third = 1 << QTEDirection.Third,
        Fourth = 1 << QTEDirection.Fourth,
        Fifth = 1 << QTEDirection.Fifth,
        Sixth = 1 << QTEDirection.Sixth,
        Seventh = 1 << QTEDirection.Seventh,
        Eighth = 1 << QTEDirection.Eighth,
    }

    [Flags]
    public enum AISwitchType
    {
        Active = 0b01,
        Revive = 0b10,
        Debug = 0b100,
        Player = 0b1000,
        ActionModule = 0b10000,
        LevelBefore = 0b100000,
    }

    public enum ItemCreatePointType
    {
        Master = 0,
    }

    public enum UIComponentType
    {
        Joystick = 1, //遥感
        Attack, //普攻按钮
        Active, //主动技能按钮
        Coop, //连携技能按钮
        Power, //爆发技能按钮
        Dodge, //闪避按钮
        Switch, //切锁定按钮
        Auto, //切换自动/手动战斗按钮
        Timer, //战斗计时标签
        Quit, //退出战斗按钮
        SelfHud, //自方血条
        EnemyHud, //敌方血条
        Slot, //所有技能按钮
        Drag, //拖拽控件
        PlayerEnergy, //主控能量
        BoyActive, //男主主动技能按钮
        AllArrow,//指引图标
        BoyArrow,//男主指引图标
    }

    public class MissileBezierPoint
    {
        public Vector3 position;
        public float distance;
        public float length;
    }

    public enum CheckTargetType
    {
        Physical, // 物理检测
        Direct, // 直接获取
    }

    //移动类型
    public enum MoveType
    {
        Run = 0, //跑
        Wander, //徘徊
        Turn, //原地转身
        Num,
    }

    public static class LocomotionName
    {
        public static readonly string[] MoveTypeName = new string[(int)MoveType.Num]
        {
            "Run",
            "Wander",
            "Turn",
        };
    }

    // 按钮输入类型
    public enum PlayerBtnType
    {
        Attack = SkillSlotType.Attack, // 普攻技能
        Active = SkillSlotType.Active, // 主动技能
        Coop = SkillSlotType.Coop, // 共鸣技
        Ultra = SkillSlotType.Ultra, // 爆发技能
        Dodge = SkillSlotType.Dodge, // 闪避技能
        CoopAttack = SkillSlotType.CoopAttack, // 协作技普攻
    }

    // 按钮输入的多选枚举 (需要+1，因为Attack是从0开始的)
    [Flags]
    public enum PlayerBtnTypeFlag
    {
        Attack = 1 << (PlayerBtnType.Attack + 1),
        Active = 1 << (PlayerBtnType.Active + 1),
        Coop = 1 << (PlayerBtnType.Coop + 1),
        Ultra = 1 << (PlayerBtnType.Ultra + 1),
        Dodge = 1 << (PlayerBtnType.Dodge + 1),
        CoopAttack = 1 << (PlayerBtnType.CoopAttack + 1),
    }

    public enum PlayerBtnStateType
    {
        Down, // 按下
        Hold, // 按住状态
        Up, // 抬起
        Tap, // 按下+抬起是一次tap事件
    }

    // 用于ActionActiveInputCache中使用
    [Flags]
    public enum BtnStateInputFlag
    {
        Down = 1 << PlayerBtnStateType.Down,
        Up = 1 << PlayerBtnStateType.Up,
        Tap = 1 << PlayerBtnStateType.Tap,
    }

    public enum PointType
    {
        Standard = 1,
        BornPoint = 2
    }

    public enum RoleType
    {
        Girl = 1,
        Boy = 2,
        BoyAndGirl = 3,
        Other = 4,
        Monster = 5,
    }

    public enum TriggerType
    {
        Enter = 1,
        Exit = 2,
        EnterAndExit = 3,
        Stay = 4,
        StayIn = 5, // 保持停留-并持续保持
    }

    public enum TriggerShape
    {
        Sphere = 1,
        Cube = 2,
    }

    public enum PathFindShapeType
    {
        Circle ,
        Rectangle,
    }

    public enum DoorState
    {
        Open = 1,
        Close = 2,
    }

    public enum SwitchState
    {
        On = 1,
        Off = 2,
    }

    public enum AttackBasicState
    {
        On = 1,
        Off = 2,
    }

    public enum ActorAIStatus
    {
        None = -1,
        Standby = 0, //待机
        Attack = 2, //攻击
    }

    /// <summary>
    /// 直接获取类型
    /// SkillDamageCfg 配置使用
    /// </summary>
    public enum DirectSelectType
    {
        Self,

        /// <summary> 技能目标 </summary>
        SkillTarget,

        /// <summary> 指定目标 </summary>
        SpecifyTarget,
        Girl,
        Boy,
    }

    public enum WarnType
    {
        Shine, //发光
        Ray, //射线
        Circle, //圆形
        Sector, //扇形
        Rectangle, //矩形
        Lock, //锁定
    }

    public enum ShapeType
    {
        Capsule = 7, //胶囊
        Cube = 8, //立方体
        FanColumn = 10, //扇形柱：扇形 + 高度属性
        Sphere = 11, //球
        Ray = 12, //射线
        RingFanColumn = 13, // 环形扇形柱 
    }

    public enum IncludeSummonType
    {
        /// <summary> 可以包含召唤物 (即对列表不进行处理) </summary>
        AnyType,

        /// <summary> 只选取召唤物 </summary>
        OnlySummon,

        /// <summary> 不包含召唤物 </summary>
        NoSummon,
    }

    public enum CameraMode
    {
        Battle,
        Free,
        FPS,
    }

    public enum CameraType
    {
        VirturalCamera = 0,
        FreeLookCamera = 1,
        TargetCamera = 2,
        TargetFreeLookCamera = 3,
    }

    public enum CameraFollowType
    {
        None = 0,
        SimpleFollow = 1,
        CustomFollow = 2,
    }

    public enum QTEOperateType
    {
        Button = 1,
        Underline = 2,
    }

    public enum QTETriggerEffectType
    {
        Skill = 1,
        ContinuedButton = 2,
    }

    public enum MutexRelationType
    {
        ReplaceOldBuff = 1,
        NotReplace,
        NoMutexRelation,
        Isolate, //相互独立,buff叠加
    }

    public enum TimeConditionType
    {
        RefreshTime = 1,
        AddTime,
        None,
    }

    public enum IconShowType
    {
        NotShow = 1,
        ShowWithOutLayer,
        ShowWithLayer,
    }

    // TODO 三夕 使用自定义属性后， 可以删除
    public enum BuffActionType
    {
        Basic = 1,
    }

    public enum BattleMemorySize
    {
        Low = 0,
        Mid,
        High,
    }

    // 部件类型
    public enum PartType
    {
        Hair = 1, // 头发
        Body = 2, // 身体
        Decoration = 3, // 饰品
        Weapon = 4, // 武器
        Eyelash = 5, // 睫毛
        Face = 6, // 脸
    }

    public enum HurtShakeDirType
    {
        HurtDirProj, // 沿受击方向在相机平面的投影方向抖动
        CameraUpDir, // 沿相机y轴方向抖动
    }

    public static class FSMVariableName
    {
        public const string IdleState = "IsWeaponVisible";
    }

    public enum BornCameraState
    {
        Start = 1,
        End = 2,
    }

    [Serializable]
    public class CreateMissileParam
    {
        [LabelText("新子弹ID", jumpType:JumpModuleType.ViewMissile)] 
        public int missileID;

        [LabelText("悬停模式")] public MissileSuspendType SuspendType;

        [LabelText("悬停时间")] public float SuspendTime;

        [LabelText("悬停开启命中检测")] public bool SuspendCanDamage;
        
        [LabelText("悬停子弹消亡模式")] public SuspendDestroyType SuspendDestroyType = SuspendDestroyType.None;

        [DrawCoorPoint("通用选点")] public CoorPoint StartPos;

        [LabelText("起始朝向")] public CoorOrientation StartForward;

        [LabelText("用子弹算朝向")] public bool MissileCalculateForward;

        public bool IsTargetType { get; set; }
    }

    [MessagePackObject]
    [Serializable]
    public class CreateMagicFieldParam
    {
        [LabelText("动态类型覆盖时长")] 
        [Key(0)]
        public bool isCoverDuration;

        [LabelText("持续时间 (-1无限)", showCondition = "isCoverDuration")]
        [Key(1)]
        public float duration = -1f;
    }

    // 导弹悬停类型
    public enum MissileSuspendType
    {
        None, // 不悬停
        OriginPosition, // 原地悬停
        FollowCaster, // 位置朝向跟随释放者
    }

    public enum ModifyCfgType
    {
        Set,  // 设置
        Add,  // 加
        Sub,  // 减
    }

    [Serializable]
    public class BuffAddParam
    {
        [LabelText("buffID", jumpType:JumpModuleType.ViewBuff)] 
        public int bufId;
        
        [LabelText("指定堆叠层数")] public bool isOverrideStack;

        [LabelText("堆叠层数", showCondition = "isOverrideStack")]
        public int stackCount;

        [LabelText("是否指定时长", showCondition = "!interrupted")]
        public bool isOverrideDuration;

        [LabelText("持续时长", showCondition = "isOverrideDuration")]
        public float duration;

        [LabelText("指定Buff等级")] public bool isOverrideLevel;

        [LabelText("Buff等级", showCondition = "isOverrideLevel")]
        public int level;

        [LabelText("Buff是否关联时长")] public bool interrupted;
    }

    [Serializable]
    public class BuffRemoveParam
    {
        [LabelText("buffID")] public int buffID;

        [LabelText("勾选削减层数")] public bool removeLayer;

        [LabelText("削减层数", showCondition = "removeLayer")]
        public int layer;
                
        [LabelText("(临时字段，优先级大于layer)削减层数", showCondition = "removeLayer")]
        public BBParameter<int> tempLayer;
    }
    
    [Serializable]
    public class NewBuffRemoveParam
    {
        [LabelText("buffID")] public BBParameter<int> buffID = new BBParameter<int>();

        [LabelText("勾选削减层数")] public BBParameter<bool> removeLayer = new BBParameter<bool>();

        [LabelText("削减层数", showCondition = "removeLayer")]
        public BBParameter<int> layer = new BBParameter<int>();
    }
    
    [Serializable]
    public class NewBuffAddParam
    {
        [LabelText("buffID", jumpType:JumpModuleType.ViewBuff)] 
        public BBParameter<int> buffId = new BBParameter<int>();
        
        [LabelText("指定堆叠层数")] public BBParameter<bool> isOverrideStack = new BBParameter<bool>();

        [LabelText("堆叠层数", showCondition = "isOverrideStack")]
        public BBParameter<int> stackCount = new BBParameter<int>();

        [LabelText("是否指定时长", showCondition = "!interrupted")]
        public BBParameter<bool> isOverrideDuration = new BBParameter<bool>();

        [LabelText("持续时长", showCondition = "isOverrideDuration")]
        public BBParameter<float> duration = new BBParameter<float>();

        [LabelText("指定Buff等级")] public BBParameter<bool> isOverrideLevel = new BBParameter<bool>();

        [LabelText("Buff等级", showCondition = "isOverrideLevel")]
        public BBParameter<int> level = new BBParameter<int>();

        [LabelText("Buff是否关联时长")] public BBParameter<bool> interrupted = new BBParameter<bool>();
    }

    public class FloatWord
    {
        public string resName;
        public Actor actor;
        public Vector3 actorPos;
        public RectTransform trans;
        public TMPro.TextMeshProUGUI textPro;
        public RichText richText;
        public Text text;
        public bool textChange;
        public bool isPlay;
        public bool isCure;
        public int value;
        public float length;
        public bool isUsed;
        public float elapsedTime;
        public float offsetX;
        public float offsetY;
        public float offsetZ;
        public float horizontalRandom;
        public float verticalRandom;

        public MotionHandler motionHandler;
        public MotionHandler.MotionInfo montionInfo;
    }

    public static class FloatWordDatas
    {
        public const string DamageST = "UIPrefab_FloatWords_Damage_Role";
        public const string DamagePL = "UIPrefab_FloatWords_Damage_PL";
        public const string CriticalDamagePL = "UIPrefab_FloatWords_DamageCritical_PL";
        public const string Hurt = "UIPrefab_FloatWords_Hurt";
        public const string Cure = "UIPrefab_FloatWords_Cure";
        public const string Text = "UIPrefab_FloatWords_Text";
        public const string Dot = "UIPrefab_FloatWords_Dot";
        public const string Weak = "UIPrefab_FloatWords_DamageWeakness";

        public static readonly Dictionary<string, int> resNames = new Dictionary<string, int>
        {
            { DamageST, 10 },
            { DamagePL, 10 },
            { CriticalDamagePL, 5 },
            { Hurt, 12 },
            { Cure, 5 },
            { Text, 2 },
            { Dot, 8 },
            { Weak, 2 }
        };
    }

    public static class ActorDummyType
    {
        public const string Model = "_Internal_Model";
        public const string Root = "_Internal_Root";
        public const string PointRoot = "Point_Root";
        public const string PointTop = "Point_Top";
        public const string Point_HeadLookAt = "Point_HeadLookAt";
        public const string PointButton = "Point_Button";
        public const string PointBuff = "Point_Buff";
        public const string PointDebuff = "Point_Debuff";
        public const string PointCamera = "Point_Camera";
        public const string PointDialog = "Point_Dialog";
        public const string PointLeftForearm = "LeftForearm";
        public const string PointLeftHand = "LeftHand";
        public const string PointRightForearm = "RightForearm";
        public const string PointRightHand = "RightHand";
        public const string RenderPointPivot = "Render_Point_Pivot";
        public const string PointCameraFollow = "Point_Camera_Follow";
        public const string PointFootR = "Point_Foot_R";
        public const string PointFootL = "Point_Foot_L";

        public static readonly Dictionary<DummyType, string> dummyTypes = new Dictionary<DummyType, string>
        {
            { DummyType.Model, Model },
            { DummyType.Root, Root },
            { DummyType.PointRoot, PointRoot },
            { DummyType.PointTop, PointTop },
            { DummyType.PointButton, PointButton },
            { DummyType.PointBuff, PointBuff },
            { DummyType.PointDebuff, PointDebuff },
            { DummyType.PointCamera, PointCamera },
            { DummyType.PointDialog, PointDialog },
            { DummyType.PointLeftForearm, PointLeftForearm },
            { DummyType.PointLeftHand, PointLeftHand },
            { DummyType.PointRightForearm, PointRightForearm },
            { DummyType.PointRightHand, PointRightHand },
            { DummyType.RenderPointPivot, RenderPointPivot },
            {DummyType.PointCameraFollow, PointCameraFollow},
        };
    }

    public enum DummyType
    {
        Model,
        Root,
        PointRoot,
        PointTop,
        PointButton,
        PointBuff,
        PointDebuff,
        PointCamera,
        PointDialog,
        PointLeftForearm,
        PointLeftHand,
        PointRightForearm,
        PointRightHand,
        RenderPointPivot,
        PointCameraFollow,
    }

    public enum FpsOperateType
    {
        OpenFire,
        Reload,
    }

    /// <summary>
    /// 角色动画驱动模式
    /// </summary>
    public enum ActorAnimUpdateMode
    {
        Auto = 0,
        Timeline,
    }

    //切勿使用int值来作为层Index 不同角色不一样
    public enum RoleAnimLayer
    {
        Base, //人物基础动画层（Override）
        BaseAdd, //人物基础动画Add层（Additive）
        HurtAdd, //受击Add层
    }
    public static class RoleAnimLayerName
    {
        public const string BaseLayer = "BaseLayer";
        public const string BaseAdd = "BaseAdd";
        public const string HurtAdd = "HurtAdditiveLayer";
    }

    public enum ActorPlayableType
    {
        AnimCtrl = 0,
        Timeline,
        Num,
    }

    /// <summary>
    /// 角色状态标签
    /// 请依次在尾部加入新枚举，切勿中间插入！！
    /// </summary>
    public enum ActorStateTagType
    {
        None = -1,
        CannotMove = 20, // 无法移动(不同步位移信息)
        CannotCastSkill = 21, //无法释放技能
        DamageImmunity = 22, // 伤害免疫，在命中流程中的伤害治疗结算之前生效，终止本次命中流程结算
        
        // 忽略碰撞，不通过开关Collider完成。通过CC识别Collider的ExcludeLayer是否有 colliderLayer完成
        CollisionIgnore = 23, // 免疫单位的物理碰撞 
        HitIgnore = 24, // 不可命中，在命中流程结算之前生效，对该单位的攻击不会进入目标结算流程(仅免疫DamageBoxType==Attack类型的)
        HurtIgnore = 25, // 不可受击（跳过命中流程中的削韧和受击）
        LockIgnore = 26, // 不可锁定，索敌模块忽略此目标
        CoreDamageImmunity = 27, // 芯核伤害免疫，在命中流程中的护盾虚弱结算流程之前生效
        TractionImmunity = 28, // 免疫牵引       
        AttackIgnore = 29, // 免疫攻击.
        DebuffImmunity = 30, // 免疫debuff
        RecoverIgnore = 31, //禁止生命回复
        CannotEnterMove = 32, //无法进入移动态
        MissileBlastIgnore = 33, //子弹命中此单位不会进入爆炸
        
        // 忽略逻辑检测，通过设置设置ExcludeLayer，使得角色上的碰撞器不会触发trigger，从而不会触发逻辑检测
        // 如果不是通过Trigger实现的逻辑检测，例如光环是通过物理检测接口做的，
        // 则需要逻辑自己筛选掉Collider：ExcludeLayer包含Trigger层的
        LogicTestIgnore = 34, // 忽略单位的的逻辑检测，例如Trigger，光环
    }

    public enum BuffTag
    {
        Buff, // 增益buff
        Debuff, // 减益buff
        Function, //功能buff
    }

    [Flags]
    public enum BuffTagFlag
    {
        Buff = 1 << BuffTag.Buff,
        Debuff = 1 << BuffTag.Debuff,
        Function = 1 << BuffTag.Function,
    }

    public enum CtrlInterruptType
    {
        Locomotion,
        Timeline,
        Num, //最大数
    }

    public enum CanInterruptType
    {
        None,
        Can,
        Cannot,
    }

    /// <summary>
    /// 技能类型
    /// </summary>
    public enum SkillType
    {
        Attack = 0,
        Fill = 1,
        Active = 2,
        Passive = 3,
        Coop = 4,
        Support = 5,
        Dodge = 6,
        Ultra = 7,
        Gemcore = 8,
        ScorePhase = 9,
        Card = 10,
        AttackHeavy = 11, // 重击技能类型
        None = 12, //空技能类型
        MaleActive = 13,  // 协助技
        EXMaleActive = 14,  // 强化协助技
        Num = 15, // 数量
    }

    // 技能类型Flag, 为了提高多选计算效率
    [Flags]
    public enum SkillTypeFlag
    {
        Attack = 1 << SkillType.Attack,
        Fill = 1 << SkillType.Fill,
        Active = 1 << SkillType.Active,
        Passive = 1 << SkillType.Passive,
        Coop = 1 << SkillType.Coop,
        Support = 1 << SkillType.Support,
        Dodge = 1 << SkillType.Dodge,
        Ultra = 1 << SkillType.Ultra,
        Gemcore = 1 << SkillType.Gemcore,
        ScorePhase = 1 << SkillType.ScorePhase,
        Card = 1 << SkillType.Card,
        AttackHeavy = 1 << SkillType.AttackHeavy,
        None = 1 << SkillType.None,
        MaleActive = 1 << SkillType.MaleActive,
        EXMaleActive = 1 << SkillType.EXMaleActive,
    }

    /// <summary>
    /// 伤害技能类型，用于伤害公式计算
    /// 前面的值与SkillType保持一致
    /// 后续可在SkillType基础上新增新的伤害技能类型，建议中间空出区间
    /// </summary>
    public enum DamageSkillType
    {
        Attack = SkillType.Attack,
        Fill = SkillType.Fill,
        Active = SkillType.Active,
        Passive = SkillType.Passive,
        Coop = SkillType.Coop,
        Support = SkillType.Support,
        Dodge = SkillType.Dodge,
        Ultra = SkillType.Ultra,
        Gemcore = SkillType.Gemcore,
        ScorePhase = SkillType.ScorePhase,
        Card = SkillType.Card,
        AttackHeavy = SkillType.AttackHeavy,
        None = SkillType.None,
        MaleActive = SkillType.MaleActive,
        EXMaleActive = SkillType.EXMaleActive,
    }

    /// <summary>
    /// The character collision behavior.
    /// </summary>
    [Flags]
    public enum CollisionBehavior
    {
        Default = 0,

        /// <summary>
        /// Determines if the character can walk on the other collider.
        /// </summary>
        Walkable = 1 << 0, // =1  可行走
        NotWalkable = 1 << 1, // =2  不可行走

        /// <summary>
        /// Determines if the character can perch on the other collider.
        /// </summary>
        CanPerchOn = 1 << 2, // 4   可悬停
        CanNotPerchOn = 1 << 3, // 8    不可悬停

        /// <summary>
        /// Defines if the character can step up onto the other collider.
        /// </summary>
        CanStepOn = 1 << 4, //可站立（当不可行走时，可站立）
        CanNotStepOn = 1 << 5, //不可站立

        /// <summary>
        /// Defines if the character can effectively travel with the object it is standing on.
        /// </summary>
        CanRideOn = 1 << 6, //可站立（与站立对象一起移动）
        CanNotRideOn = 1 << 7, //不可站立

        /// <summary>
        /// Defines if the character can filter the collider, when character ignore collision.
        /// 用于配置例如：空气墙，机关等类型的Actor，不可忽略碰撞
        /// </summary>
        CanNotFilterWhenIgnoreCollision = 1 << 8, //不可忽略（当忽略碰撞时）
    }

    /// <summary>
    /// 数值状态枚举
    /// </summary>
    public enum NumericalState
    {
        /// <summary>
        /// 战斗准备状态
        /// </summary>
        Prepare,

        /// <summary>
        /// 战斗中状态
        /// </summary>
        Fighting,
    }

    /// <summary>
    /// 召唤物锁定.
    /// </summary>
    public enum SummonLocked
    {
        None = 0,

        /// <summary> 忽视锁定、命中、伤害 </summary>
        IgnoreLockHitDamage = 1,
    }

    public enum ChooseActorType
    {
        [LabelText("自身")] Self,
        [LabelText("Girl")] Girl,
        [LabelText("Boy")] Boy,
        [LabelText("Girl锁定目标")] GirlLockTarget,
        [LabelText("Boy锁定目标")] BoyLockTarget,
    }

    /// <summary>
    /// 表演模型封装
    /// </summary>
    public class PerformModel
    {
        public GameObject root { get; }
        public GameObject model { get; }
        public X3Character x3Character { get; }

        public GameObject weapon { get; }

        public ModelCfg actorCfg { get; }

        public PlayableAnimator animator { get; }
        private X3PhysicsCloth _physicsCloth;
        private DynamicAnimationGraph _animationGraph;

        public PerformModel(GameObject model, ModelCfg actorCfg)
        {
            this.actorCfg = actorCfg;
            this.model = model;
            this.root = this.model.transform.parent?.gameObject;
            this.root.transform.localPosition = Vector3.zero;
            this.root.transform.localEulerAngles = Vector3.zero;

            this.model.transform.localScale = Vector3.one;
            this.model.transform.localPosition = Vector3.zero;
            this.model.transform.localEulerAngles = Vector3.zero;
            this.weapon = this.model.transform.Find("Weapon")?.gameObject;
            this.animator = this.model.GetComponent<PlayableAnimator>();
            x3Character = model.GetComponent<X3Character>();
            if (x3Character != null)
            {
                _physicsCloth = x3Character.GetSubsystem(ISubsystem.Type.PhysicsCloth) as X3PhysicsCloth;
            }

            _animationGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(model);
            SetVisible(false);
        }

        // 设置显隐
        public void SetVisible(bool visible)
        {
            root.SetVisible(visible);
            if (_physicsCloth != null)
            {
                _physicsCloth.EnabledSelf = visible;
            }

            if (_animationGraph != null)
            {
                _animationGraph.Active = visible;
            }
        }
    }


    /// <summary>
    /// buff 类别
    /// </summary>
    public enum BuffType
    {
        Control = 1,
        Attribute,
        Dot,
        Others
    }

    /// <summary>
    /// buff互斥规则
    /// </summary>
    public enum BuffMutexType
    {
        Replace = 1, // 顶替旧buff
        NotReplace, // 不顶替
        None
    }

    /// <summary>
    /// 读取HitParamConfig表里哪个字段用的枚举
    /// </summary>
    public enum HitParamRatioType
    {
        AttackRatio, // 对应 TargetDamageAtkRatio 字段.
    }

    /// <summary>
    /// debug用，指定隐藏哪个ui的ui分类
    /// </summary>
    public enum DebugUIHideType
    {
        FriendUI,
        EnemyUI,
        OperatingTips,
        JumpWords,
        CommunicateUI,
        OutScreenTipUI
    }

    /// <summary>
    /// 关卡战斗状态
    /// </summary>
    public enum LevelBattleState
    {
        None, // 未进入关卡战斗状态
        Normal, // 普通关卡战斗状态
        Boss, // Boss关卡战斗状态
    }

    [MessagePackObject]
    [Serializable]
    public struct WitchTimeIncludeData
    {
        [LabelText("获取目标时目标类型)")] [ParadoxNotion.Design.Name("获取目标时目标类型")]
        [Key(0)]
        public TargetType targetType;

        [LabelText("创生物是否加入列表")] [ParadoxNotion.Design.Name("创生物是否加入列表")]
        [Key(1)]
        public bool isIncludeSummoned;

        [LabelText("子弹是否加入列表")] [ParadoxNotion.Design.Name("子弹是否加入列表")]
        [Key(2)]
        public bool isIncludeBullets;

        [LabelText("道具是否加入列表")] [ParadoxNotion.Design.Name("道具是否加入列表")]
        [Key(3)]
        public bool isIncludeItems;

        [LabelText("法术场是否加入列表")] [ParadoxNotion.Design.Name("法术场是否加入列表")]
        [Key(4)]
        public bool isIncludeMagicFields;
    }

    /// <summary>
    /// 角色魔女设置
    /// </summary>
    public class ActorWitchTimeSettings : IReset
    {
        public bool syncSelf = true;
        public bool syncCreatures;
        public bool syncBullets;
        public bool syncItems;
        public bool syncMagicFields;

        public bool pauseSoundForSelf;
        public bool pauseSoundForSummon;

        public void CopyFrom(ActorWitchTimeSettings settings)
        {
            syncSelf = settings.syncSelf;
            syncCreatures = settings.syncCreatures;
            syncBullets = settings.syncBullets;
            syncItems = settings.syncItems;
            syncMagicFields = settings.syncMagicFields;
            pauseSoundForSelf = settings.pauseSoundForSelf;
            pauseSoundForSummon = settings.pauseSoundForSummon;
        }

        public void Reset()
        {
            syncSelf = true;
            syncCreatures = false;
            syncBullets = false;
            syncItems = false;
            syncMagicFields = false;
            pauseSoundForSelf = false;
            pauseSoundForSummon = false;
        }
    }

    public enum ActorIDType
    {
        Girl = -1,
        Boy = -2,
    }

    public enum MagicFieldParamType
    {
        /// <summary> 任意法术场 </summary>
        All,

        /// <summary> 法术场ID（蓝图里可以配置ID） </summary>
        MagicFieldID
    }

    /// <summary>
    /// LOD使用枚举
    /// </summary>
    public enum LODUseType
    {
        /// <summary> 都没用, 初始化的默认值 </summary>
        None,

        /// <summary> 只使用了LD </summary>
        LD,

        /// <summary> 只使用了HD </summary>
        HD,

        /// <summary> LD和HD都使用了 </summary>
        LDHD,
    }

    /// <summary>
    /// 属性相关配置查询及消耗时的目标选择
    /// </summary>
    public enum AttrChoseTarget
    {
        Self = 0,
        Girl = 1,
        Boy = 2
    }

    /// <summary>
    /// 事件目标类型
    /// </summary>
    public enum EventTargetType
    {
        Self = 0,
        Girl = 1,
        Boy = 2,
    }

    /// <summary>
    /// 四则运算
    /// </summary>
    public enum Arithmetic
    {
        None = 0,
        Add = 1,
        Sub,
        Mul,
        Divide,
        Set,
    }

    // 男主传送参考目标
    public enum BoyTransportTargetType
    {
        Enemy,
        Girl,
    }

    /// <summary>
    /// 修改值的模式
    /// </summary>
    public enum ModifyMode
    {
        Add,
        Set,
    }

    public enum WeakType
    {
        Light, // 小虚弱
        Heavy, // 大虚弱
        None,
    }

    public enum ActionModuleType
    {
        Default = 0,
        BrokenShirt
    }

    public enum HurtSourceType
    {
        Skill = 0,
        Buff,
        SkillMagicField,
        SkillMissile,
    }

    // 请注意枚举值，使用左移运算，方便支持多个tag
    [Flags]
    public enum BattleResTag
    {
        Default = 1 << 0,
        Analyzed = 1 << 1, // 标记该资源为分析过的资源
        BeforeBrokenShirt = 1 << 2, // 标记爆衣前的资源
        AfterBrokenShirt = 1 << 3, // 标记爆衣后的资源
        PPVTimeline = 1 << 4,
        OriginalSkin = 1 << 5, // 原始皮肤
    }

    /// <summary>
    /// 战斗退出原因
    /// </summary>
    public enum BattleEndReason
    {
        ManualQuit = -1, // 手动退出
        None = 0, // 
        GirlDead = 1, // 女主先死亡
        BoyDead = 2, // 男主死亡
        TimeOut = 3, //超时导致失败
        Technic = 4, // 机制导致失败
    }

    /// <summary>
    /// 模块类型
    /// </summary>
    public enum ModuleType
    {
        DamageBox,
        Missile,
        Buff,
        MagicField,
        Halo,
        Trigger,
        Item,
        Fx,
        Summon,
        ActionModule,
    }

    /// <summary>
    /// 死亡效果类型
    /// </summary>
    public enum DeadEffectType
    {
        Default = 0,
        HurtLie,  // 受击躺死效果
        Special,  // 特制死亡效果
    }

    /// <summary>
    /// 战斗暂停类型
    /// </summary>
    public enum BattleEnabledMask
    {
        UI = 1 << 0,
        LevelFlow = 1 << 1,
        Perform = 1 << 2,
        Debugger = 1 << 3,

        // 请在上方新增类型，并在下方累加
        All = UI | LevelFlow | Perform | Debugger
    }
    
    /// <summary>
    /// 音频暂停类型
    /// </summary>
    public enum EAudioPauseType
    {
        EAll = 0,
        EBattleSfx,//战斗音效
        EBattleAll,//所有战斗音效+语音
	}

    /// <summary>
    /// 战斗PostUpdate事件层
    /// </summary>
    public enum BattlePostUpdateEventLayer
    {
        Anim = 0,
        Weapon = 1,
        Idle = 2,
        Num
    }
    
	/// <summary> 激活信息 </summary>
    public class ActivateInfo : IReset
    {
        public Action createCallback { get; private set; }
        public Action allCreateCallback { get; private set; }
        public List<SpawnPointConfig> spawnPointConfigs { get; private set; } = new List<SpawnPointConfig>(50);
        public void Init(Action createCallback, Action allCreateCallback)
        {
            this.createCallback = createCallback;
            this.allCreateCallback = allCreateCallback;
        }
        public void Reset()
        {
            this.createCallback = null;
            this.allCreateCallback = null;
            this.spawnPointConfigs.Clear();
        }
    }

    public class ActorInfo : IReset
    {
        public enum State
        {
            None,
            Dead,
            Alive,
        }
        
        public int spawnID { get; private set; }
        public int groupID { get; private set; }
        public int cfgID { get; private set; }
        public int deadCount { get; private set; }
        public int aliveCount { get; private set; }
        public CreatureType bornCfgType { get; private set; }
        public State state { get; private set; }
        public ActorType actorType { get; private set; }

        public void Init(int spawnID, int groupID, int cfgID, ActorType actorType, CreatureType? creatureType)
        {
            this.spawnID = spawnID;
            this.groupID = groupID;
            this.cfgID = cfgID;
            this.actorType = actorType;
            if (creatureType != null) this.bornCfgType = creatureType.Value;
        }
        
        public void Reset()
        {
            this.spawnID = 0;
            this.groupID = 0;
            this.cfgID = 0;
            this.state = State.None;
            this.actorType = ActorType.Programmer;
            this.deadCount = 0;
            this.aliveCount = 0;
        }

        public void Born()
        {
            state = State.Alive;
            aliveCount += 1;
        }
        
        public void Dead()
        {
            state = State.Dead;
            deadCount += 1;
        }

        public void Recycle()
        {
            state = State.None;
        }
    }

    public class HurtTryAbnormalArg : ActorMainState.IArg
    {
        public DamageBoxCfg damageBoxCfg { get; set; }
        public float hurtDistance { get; set; }
    }
    
    public enum InterActorState
    {
        Not,//未激活
        Check,//检测中
        Doing,//交互中
        Done,//交互完成
    }
    
    public enum InterActorCheckActorType
    {
        Girl = 1,//女主
        Boy,//男主
        Monster,//怪物
        All,//以上所有
    }

    public enum InterActorCheckType
    {
        DirectConfirm = 1,//走进交互
        UIConfirm,//点击UI交互
    }
    
    public enum InterActorBornState
    {
        Close = 0,//出生关闭
        Open,//出生激活
    }
    
    public enum InterActorAllowRepeat
    {
        Not = 0,//不允许重复
        Allow,//允许重复
    }

    public struct TrackEnableInfo
    {
        public SkillSlotType skillSlotType { get; set; }
        public int skillSlotIndex { get; set; }
        public List<int> tags { get; set; }
        public bool enable { get; set; }
    }
}