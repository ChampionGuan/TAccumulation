using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class DamageBoxCfg
    {
        /// <summary>伤害包围盒编号</summary>
        [Key(0)] public int ID;

        /// <summary> 名字 </summary>
        [Key(1)] public string Name;
        
        /// <summary>挂载类型</summary>
        [Key(2)]
        public MountType MountType;

        /// <summary>持续时间</summary>
        [Key(3)] public float Duration;

        /// <summary>判定模式</summary>
        [Key(4)] public DamageBoxCheckMode CheckMode;

        /// <summary>周期</summary>
        [Key(5)]
        public float Period;

        /// <summary>最大次数</summary>
        [Key(6)]
        public int BoxMaxHit;

        /// <summary>阵营关系筛选</summary>
        [Key(7)] public FactionRelationship[] FactionRelationship;

        /// <summary>伤害ID序号</summary>
        [Key(8)] public int HitParamID;

        /// <summary>伤害数值权重</summary>
        [Key(9)] public int ModifyWeight;

        /// <summary>是否面朝攻击者</summary>
        [Key(10)] public bool HurtFaceToTarget;

        /// <summary>播放受击闪白</summary>
        [Key(11)] public bool PlayHurtFXMat;


        /// <summary>命中特效名称</summary>
        [Key(12)] public int HurtFXID;

        /// <summary>命中特效定帧缩放</summary>
        [Key(13)] public bool FxFreezeFrame;

        /// <summary>命中特效定帧延迟</summary>
        [Key(14)] public float FreezeFrameDelay;

        /// <summary>命中音效名称</summary>
        // [Key(15)] public string HurtSound;

        /// <summary>特效位置随机类型</summary>
        [Key(16)] public BattleFXRandomHurtType RandomHurtFxType;

        /// <summary>特效位置随机半径</summary>
        [Key(17)] public float RandomHurtFxRadius;

        /// <summary>打击定帧时长</summary>
        [Key(19)]
        public float HitScaleDuration;

        /// <summary>受击定帧时长</summary>
        [Key(21)]
        public float HurtScaleDuration;

        /// <summary>受击抖动强度（0,1,2共三挡）</summary>
        [Key(22)]
        public int HurtShakeIndex;

        /// <summary>抖动类型（-1为整体抖动,局部位置从0开始计数)</summary>
        [Key(23)]
        public int HurtShakeType;

        /// <summary>水平后续加速度</summary>
        [Key(24)]
        public float HorizontalAccelerate;

        /// <summary>竖直后续加速度</summary>
        [Key(25)]
        public float VerticalAccelerate;

        /// <summary>削韧值</summary>
        [Key(26)]
        public float ToughnessReduce;
        
        /// <summary>直接获取类型</summary>
        [Key(27)]
        public DirectSelectType DirectSelectType;   
        
        /// <summary> 命中前效果 </summary>
        [Key(28)]
        public AddBuffData[] PreAddBuffDatas;
        
        /// <summary> 命中后效果 </summary>
        [Key(29)]
        public AddBuffData[] AfterAddBuffDatas;
        
        /// <summary> 在AOE碰撞筛选目标里是否包括自己 </summary>
        [Key(30)]
        public bool IsFactionRelationshipSelf;

        /// <summary> 包围盒绑定点 </summary>
        [Key(31)]
        public string DummyName;

        /// <summary> 目标检测类型 即使用那种检测方式: 目前{物理检测, 直接目标获取} </summary>
        [Key(32)]
        public CheckTargetType CheckTargetType;

        /// <summary> 受击类型 </summary>
        [Key(33)]
        public HurtType HurtType;

        /// <summary>
        /// 编辑器用的虚拟目录字段
        /// </summary>
        [Key(34)] public string VirtualPath;

        /// <summary>
        /// 形状拓展数据
        /// </summary>
        [Key(35)] public ShapeBoxInfo ShapeBoxInfo;

        /// <summary>
        /// 伤害包围盒类型
        /// </summary>
        [Key(36)] public DamageBoxType DamageBoxType;

        /// <summary>
        /// 受击特效的位置偏移量（会覆盖特效表的Offset字段）
        /// </summary>
        [Key(37)] public X3Vector3 HurtFxOffsetPos;

        /// <summary>
        /// 受击特效的欧拉角偏移量（会覆盖特效表的Rotation字段）
        /// </summary>
        [Key(38)] public X3Vector3 HurtFxOffsetEuler;

        /// <summary>
        /// 是否使用特效表挂点
        /// </summary>
        [Key(39)] public bool IsFxCfgHangPoint;

        /// <summary>
        /// 命中特效播放速度(最小播放速度)
        /// </summary>
        [Key(40)] public float HurtFxMinSpeed = 1f;

        /// <summary>
        /// 命中特效播放速度(最大播放速度)
        /// </summary>
        [Key(41)] public float HurtFxMaxSpeed = 1f;

        /// <summary>
        /// 世界Y方向位移-时间曲线
        /// </summary>
        [Key(42)] public string HurtCurveVertical;

        /// <summary>
        /// 世界XZ平面方向位移-时间曲线
        /// </summary>
        [Key(43)] public string HurtCurveHorizontal;

        /// <summary>
        /// 命中特效欧拉角随机旋转.
        /// </summary>
        [Key(44)] public X3Vector3 HurtFxRandomEuler;

        /// <summary>
        /// 是否拥有协作者.
        /// </summary>
        [Key(45)] public bool HasAssist;

        /// <summary>
        /// 是否开启连续碰撞, 默认(false)
        /// </summary>
        [Key(46)] public bool IsContinuousMode;

        /// <summary>
        /// 施力方向   (旧攻击方向)
        /// </summary>
        [Key(47)] public ForceDirectionType AddForceDir;

        /// <summary>
        /// 击退距离
        /// </summary>
        [Key(48)] public float HurtBackDis;

        /// <summary>
        /// 横向倍率
        /// </summary>
        [Key(49)] public float CurveVerticalRatio;

        /// <summary>
        /// 纵向倍率
        /// </summary>
        [Key(50)] public float CurveHorizontalRatio;

        /// <summary>
        /// 击倒时长
        /// </summary>
        [Key(51)] public float HurtLayDownTime;
        /// <summary>

        /// <summary> 攻击起始点 </summary>
        [Key(52)] public X3Vector3 AttackStartPoint;

        /// <summary>受击震屏</summary>
        [Key(53)] public string CameraShakePath;
        /// <summary> 震屏调用参数 </summary>
        [Key(54)] public BattleImpulseParameter ImpulseParameter;
        
        /// <summary> 射线穿透单位数量(-1则为无限制) </summary>
        [Key(55)] public int PenetrateUnitNum = -1;
        
        //是否触发援护技能
        [Key(56)] public bool CauseSupport = true;

        /// 攻击武器类型（受击用）
        [Key(57)] public string hurtWeaponType;

        // 命中后效果-牵引数据
        [Key(58)] public TractionData AfterTractionData;

        // 受击方向类型
        [Key(59)] public HurtDirType hurtDirType;

        // 是否显示伤害飘字
        [Key(60)] public bool IsShowFloatWord = true;

        // 击退距离是否随距离衰减
        [Key(61)] public bool DistanceDecrease = false;
        [Key(62)] public float MinHurtBackDistance;
        [Key(63)] public float MaxHurtBackDistance;
        [Key(64)] public float MinDecreaseDistance;
        [Key(65)] public float MaxDecreaseDistance;
        [Key(66)] public HurtShakeDirType HurtShakeDirType;

        // 受击方向
        [Key(67)] public HurtDirection HurtBackDir;

        // 是否显示受击曲线在Editor面板上.
        [Key(68)] public bool IsShowHurtCurveOnEditor;

        //是否使用计算Toughness的叠加动画
        [Key(69)] public bool IsUseCalcToughnessAddAnimHurt = true;
        // 击退方向celue 
        [Key(70)] public HurtBackStrategy HurtBackStrategy;
        // 首次生效delay事件  只在判定模式为periodCount中生效
		[Key(71)] public float FirstDelayTime;
		// 本次受击是否禁用rootmotion
        [Key(72)] public bool ForbidRootMotion;
        //是否触发闪避技能
        [Key(73)] public bool CauseDodge = true;

        // 浮空受击 纵向倍率
        [Key(74)] public float HurtFlyBeHitCurveHorizontalRatio = 1;
        // 浮空受击 横向倍率
        [Key(75)] public float HurtFlyBeHitCurveVerticalRatio = 1;
        // 浮空受击 是否显示曲线
        [Key(76)] public bool IsShowHurtFlyBeHitCurve;
        // 浮空受击 纵向位移-时间曲线
        [Key(77)] public string HurtFlyBeHitCurveHorizontal = "Common__HurtFlyBeHit_Horizontal";
        // 浮空受击 横向位移-时间曲线
        [Key(78)] public string HurtFlyBeHitCurveVertical = "Common__HurtFlyBeHit_Vertical";
        // 是否覆盖阵营
        [Key(79)] public bool IsOverrideFaction;
        // 覆盖后的阵营
        [Key(80)] public FactionType OverrodeFaction = FactionType.Monster;
    }

#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class AddBuffData
    {
        [Key(0)] public int ID;
        [Key(1)] public AffectTargetType AffectTargetType;
        [Key(2)] public int BuffLayer;
        [Key(3)] public float BuffTime;
        [Key(4)] public int BuffLevel;
    }

    [Serializable]
    [MessagePackObject]
    public class BattleImpulseParameter//震屏参数
    {
        [Key(0)] public CameraShakeDirType ShakeDirType =  CameraShakeDirType.Local;
        [Key(1)] public float ShakePowerfullRadius = 9999f;
        [Key(2)] public float ShakePowerlessRadius = 0f;
        [Key(3)] public CameraShakeCurveType ShakePowerlessType;
        [Key(4)] public int ShakePriority;
        [Key(5)] public int ShakeChannel = 1;
        [Key(6)] public CameraShakeLayer ShakeLayer = CameraShakeLayer.Short;
        [Key(7)] public bool IsDefaultLayer = true;
        [Key(8)] public bool IsDefaultPriority = true;
    }
    
    /// <summary>
    /// 牵引数据
    /// </summary>
    [Serializable]
    [MessagePackObject]
    public class TractionData
    {
        /// <summary> 牵引曲线枚举 </summary>
        [Key(0)] public TweenEaseType TweenEaseType = TweenEaseType.Liner;
        /// <summary> 牵引时间 </summary>
        [Key(1)] public float Time;
        /// <summary> 牵引目标点偏移 </summary>
        [Key(2)] public X3Vector3 OffsetPos;
    }
}