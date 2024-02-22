using System;
using MessagePack;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class MissileCfg
    {
        // 基本属性
        [Key(0)] public int ID;
        [Key(1)] public string Name;
        [Key(2)] public string Description;
        [Key(3)] public string VirtualPath;

        // 生命周期特效表现
        [Key(4)] public float Duration = 1;  // 生命周期， -1不限制
        [Key(5)] public int FX;  // 表现特效ID
        [Key(6)] public int CollideSceneFX;  // 碰场景特效ID

        // 命中效果
        [Key(7)] public int DamageBox;  // 随子弹飞的打击盒
        [Key(8)] public int MaxCollideNum = 1;  // 最大命中不同单位数量， -1不限制数量，
        
        // 爆炸效果
        [Key(15)] public bool IsBlastEffect;  // 是否有爆炸效果，当true时开启爆炸，特效ID，打击盒、延迟销毁选项
        [Key(16)] public MissileBlastCondition BlastCondition = MissileBlastCondition.CollideActor;  // 爆炸判定条件
        [Key(17)] public int BlastFX;  // 爆炸特效
        [Key(18)] public int BlastDamageBox;  // 爆炸伤害盒
        [Key(19)] public float BlastDelay;  // 爆炸延时
        
        // 生命周期特效表现
        [Key(20)] public bool IgnoreCollideScene;  // 忽略地面碰撞 
        
        // 弹射功能独立参数
        [Key(21)] public bool ricochetActive;  // (独立参数) 是否开启弹射，默认false
        [Key(22)] public int ricochetMissileID;  // （独立参数）弹射的子弹ID
        [Key(23)] public float ricochetRadius = 5f; // （独立参数）弹射索敌半径
       
        // 弹射功能共享参数
        [Key(24)] public bool ricochetAllowRepeat = true;  // (共享参数) 子弹命中A弹射至B后，B能够反向弹给A。
        [Key(25)] public int ricochetMaxNum = 1;  // (共享参数)生成弹射子弹的次数，超过上限不再生成子弹
        [Key(26)] public int ricochetMaxMissilesNum = 5;  // （共享参数）指所有在场某子弹和它弹射弹群的最大数量
        [Key(27)] public FactionRelationship ricochetFactionRelationship = FactionRelationship.Enemy;  //(共享参数) 能够弹射的目标类型

        /// <summary>受击震屏</summary>
        [Key(28)] public string CameraShakePath;
        /// <summary> 震屏调用参数 </summary>
        [Key(29)] public BattleImpulseParameter ImpulseParameter;

        // 飞行音效
        [Key(30)] public string FlyMusic;
        // 命中单位音效
        [Key(31)] public string HitActorMusic;
        // 命中场景音效
        [Key(32)] public string HitSceneMusic;
        // 爆炸音效
        [Key(33)] public string BlastMusic;
        // 跳过飞行特效end阶段
        [Key(34)] public bool NotPlayEndFx = true;
        // 自然消失
        [Key(35)] public int natureDisappearFx = 0;

        [Key(36)] public MissileMotionData MotionData = new MissileMotionData();

        // 是否命中女主假身播放打击特效.
        [Key(37)] public bool IsHitFakebodyPlayEffect = true;
        
        // 爆炸特效开始时间偏移
        [Key(38)] public float BlastFXStartTimeOffset;

        /// <summary> 是否忽略相机碰撞检测 </summary>
        [Key(39)] public bool IgnoreCollideCamera = true;
        
        /// <summary> 是否创建法术场 </summary>
        [Key(40)] public bool isCreateMagicField = false;
        
        /// <summary> 法术场开启条件判定 </summary>
        [Key(41)] public MissileBlastCondition magicFieldBlastCondition = MissileBlastCondition.CollideGround;
        
        /// <summary> 法术场偏移时间 </summary>
        [Key(42)] public float magicFieldOffsetTime;
        
        /// <summary> 法术场配置 </summary>
        [Key(43)] public MagicFieldData magicFieldData = new MagicFieldData();
    }
    
    [Serializable]
    [MessagePackObject]
    public class MagicFieldData
    {
        [Key(0)]
        public int ID;

        //创建参数
        [Key(1)]
        public CreateMagicFieldParam createParam = new CreateMagicFieldParam();
        
        //是否启用验证
        [Key(2)]
        public bool enableValidation;
        
        //是否关联法术场时长
        [Key(3)]
        public bool enableTime;
        
        //取位置参数
        [Key(4)]
        public CoorPoint pointData = new CoorPoint();
                
        //取朝向参数
        [Key(5)]
        public CoorOrientation forwardData = new CoorOrientation();

        //取位置参数2
        [Key(6)]
        public CoorPoint pointData2 = new CoorPoint();
        
        //取位置参数2
        [Key(7)]
        public CoorOrientation forwardData2 = new CoorOrientation();
    }
    // 导弹运动类型
    public enum MissileMotionType
    {
        Line,
        Curve,
        Bezier,
    }
    

    // 导弹碰撞类型
    [Flags]
    public enum MissileBlastCondition
    {
        CollideActor = 1 << 0,  // 碰到单位
        CollideGround = 1 << 1,  // 碰到地面
        LifeOver = 1 << 2,  // 生命结束
        CollideSceneCamera = 1 << 3, // 碰到场景相机
        Other = 1 << 4,  //其它状态
    }

    
    /// <summary> 悬停子弹消亡模式 </summary>
    public enum SuspendDestroyType
    {
        None, // 按照子弹的自身生命周期，不跟随任何其他东西。（现状）
        CoreBreakFull, // 悬停子弹随创建者进入小虚弱时消散
        Death, // 悬停子弹随创建者死亡消散
        CoreBreakFullOrDeath, // 悬停子弹随创建者进入小虚弱或死亡时消散
    }

/// <summary>
    /// 曲线导弹跟踪方式
    /// </summary>
    public enum MissileCurveTraceMode
    {
        /// <summary> 子弹不追踪任何目标，但具有轴向加速度 </summary>
        None,
        /// <summary> 子弹追踪锁定的目标直到命中或子弹自然销毁 </summary>
        Target,
        /// <summary> 子弹记录并追踪发射时目标所在的位置 </summary>
        OriginPosition,
        /// <summary> 抛物线模式追踪 </summary>
        Parabola,
    }
    
    // 子弹锁定挂点类型
    public enum MissileLockPointType
    {
        Defualt,//默认挂点
        Render_Point_Pivot,//渲染中心挂点
        Render_Point_Root,//渲染底部挂点
        Render_Point_Top//渲染顶部挂点
    }

    // 曲线
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class MissileCurveData
    {
        [Key(1)]
        public MissileCurveTraceMode MissileCurveTraceMode; // 曲线导弹跟踪方式

        [Key(2)]
        public float AngleSpeed; // 角速度
        
        [Key(3)]
        public float AngleAcceleration; // 角加速度

        [Key(4)]
        public float AngleLimitSpeed; // 极限角速度(最大角速度限制)

        [Key(5)]
        public float GravitationalAcceleration; // 重力加速度 (策划需求配置正数)

        [Key(6)]
        public float ParabolaYSpeed; // 抛物线y轴朝上的速度, 仅能配置>0的数.
        
        [Key(7)]
        public X3Vector3 AxialAcceleration; // 轴向加速度
        
        [Key(8)]
        public bool EnableLimitMaxDistance; // 是否开启极限距离限制
        
        [Key(9)]
        public float LimitMaxDistance; // 极限距离
        
        [Key(10)]
        public bool EnableLimitMaxAngle; // 是否开启极限角度限制
        
        [Key(11)]
        public float LimitMaxAngle; // 极限角度(单帧最大旋转角度限制)
        
        [Key(12)]
        public bool EnableCollisionBeforeReaching = true; // 到达目标点前是否产生碰撞. (默认为true)

        [Key(13)]
        public X3Vector3 HitPointOffset; // 命中挂点偏移 

        [Key(14)]
        public float ParabolaDefaultDistance; // 抛物线默认(保底)距离 

        [Key(15)]
        public float TrackTime = -1f; // 追踪时间. (当子弹追踪超过此时间后, 以当时的朝向进行直线运动)
        [Key(16)]
        public bool IsUseWorldAcc = false;//是否使用世界坐标系的加速度 只在curve - none 模式下生效
        //弹跳效果
        [Key(17)] public JumpMotionData JumpMotionData = new JumpMotionData();
    }

    // 贝塞尔子弹
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class MissileBezierData
    {
        [Key(0)]public X3Vector3 ControlOffset1;
        [Key(1)]public X3Vector3 ControlOffset2;
        [Key(2)]public X3Vector3 EndOffset;
        [Key(3)]public MissileBezierEndType EndType;
        [Key(4)]public X3Vector3 HitPointOffset; // 命中挂点偏移 
    }
    
    // 贝塞尔子弹目标位置类型
    public enum MissileBezierEndType
    {
        Offset = 0,  // 相对坐标
        Target = 1,  // 技能目标
    }

#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class MissileMotionData
    {
        // 运动速度
        [Key(0)] public float InitialSpeed;  // 初速度（不能配置负数）
        [Key(1)] public float Accelerate;  // 加速度
        [Key(2)] public float MaxSpeed = -1;  // 最大速度（不能配置负数）

        // 运动类型
        [Key(3)] public MissileMotionType MotionType;  // 运动类型
        [Key(4)] public MissileCurveData CurveData = new MissileCurveData();  // 曲线数据
        [Key(5)] public MissileBezierData BezierData = new MissileBezierData();  // 贝塞尔数据

        // 碰到空气墙怎么处理
        [Key(6)] public AirWallCollisionType AirWallCollisionType = AirWallCollisionType.None;

        // 重力加速度 当AirWallCollisionType == AirWallCollisionType.Fall 时读取生效.
        [Key(7)] public float GravitationalAcceleration;
        /// 圆形修正比例
        [Key(8)] public float SphereMoveScale;
        /// <summary>
        /// 锁定目标挂点
        /// </summary>
        [Key(9)] public MissileLockPointType LockPointType = MissileLockPointType.Defualt;
    }
#if UNITY_EDITOR
    [Serializable]
#endif
    //弹跳效果
    [MessagePackObject]
    public class JumpMotionData
    {
        //弹跳次数
        [Key(0)] public int JumpNum;
        //弹跳结束后是否销毁
        [Key(1)] public bool JumpEndDisappear = true;
        //弹跳Y轴速度衰减
        [Key(2)] public float JumpYReduce;
        //弹跳Z轴速度衰减
        [Key(3)] public float JumZXReduce;
        //弹跳速度衰减
        [Key(4)] public float JumReduce;
    }
    /// <summary>
    /// 扇形形状暂不支持.
    /// </summary>
    public enum AirWallCollisionType
    {
        /// <summary> 不处理 </summary>
        None,
        
        /// <summary> 原地下落  </summary>
        Fall,
        
        /// <summary> 反弹 </summary>
        Ricochet,
    }
}