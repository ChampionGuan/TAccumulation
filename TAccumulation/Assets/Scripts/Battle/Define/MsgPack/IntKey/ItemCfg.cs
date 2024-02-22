using System;
using MessagePack;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class ItemCfg
    {
        [Key(0)] public int ID;
        [Key(1)] public string Name;
        [Key(2)] public string VirtualPath;//
        [Key(3)] public int ItemFxId;//道具特效Id
        [Key(4)] public float LifeTime;//持续时间（Float）
        
        [Key(6)] public bool EnableFly;//启用预出生逻辑
        [Key(7)] public int FlyFxId;//预出生特效Id
        [Key(8)] public ShapeBoxInfo FlyBoxInfo;//预出生地面检测形状参数
        
        [Key(15)] public bool EnableAdsorption;//启用吸附
        [Key(16)] public ShapeBoxInfo AdsorptionBoxInfo;//吸附形状参数
        [Key(17)] public ItemFilterType AdsorptionFilterType = ItemFilterType.Girl;//吸附筛选类型
        
        [Key(21)] public ShapeBoxInfo EffectBoxInfo;//生效形状参数
        [Key(22)] public ItemFilterType EffectFilterType = ItemFilterType.Girl;//生效筛选类型
        [Key(23)] public AddDamageBoxData[] AddDamageBoxDatas;//生效添加伤害盒
        [Key(24)] public AddItemBuffData[] AddBuffDatas;//生效添加Buff
        [Key(25)] public int PickUpFxId;//道具特效Id
        [Key(26)] public bool IsShowArrowIcon;
        [Key(27)] public string IconName;

        [Key(28)] public MissileMotionData FlyMotionData = new MissileMotionData(); // 子弹出生运动模式数据
        [Key(29)] public MissileMotionData AdsorptionMotionData = new MissileMotionData(); // 吸附运动模式数据

        [Key(30)] public float EffectDelayTime; // 延迟生效时间
        [Key(31)] public float AdsorptionDelayTime; // 延迟吸附时间
    }
    
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class AddItemBuffData
    {
        [Key(0)] public int ID;
        [Key(1)] public ItemTargetType TargetType;
        [Key(2)] public bool IsOverrideLayer;//是否覆盖堆叠层数
        [Key(3)] public int Layer;//层数
        [Key(4)] public bool IsOverrideTime;//是否覆盖时长
        [Key(5)] public float Time;//时长
        [Key(6)] public bool IsOverrideLevel;//是否覆盖等级
        [Key(7)] public int Level;//等级
    }
    
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class AddDamageBoxData
    {
        [Key(0)] public int ID;
        [Key(1)] public ItemTargetType TargetType;
    }
    
    // 导弹碰撞类型
    [Flags]
    public enum ItemFilterType
    {
        Girl = 1 << 1,  // 女主
        Boy = 1 << 2,  // 男主
    }
}