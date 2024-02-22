using System;
using System.Runtime.Serialization;
using FlowCanvas;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 统一选点坐标模式
    /// </summary>
    public enum CoorPointMode
    {
        /// <summary> 坐标选点模式 </summary>
        CoorPoint,
        /// <summary> 挂点选点模式 </summary>
        HangPoint,
    }
    
    /// <summary>
    /// 坐标系原点类型
    /// </summary>
    public enum CoorOriginType
    {
        /// <summary> 世界坐标系原点 </summary>
        World,
        /// <summary> 单位坐标系原点 </summary>
        Actor,
    }

    /// <summary>
    /// 坐标系朝向类型
    /// </summary>
    public enum CoorOrientationType
    {
        /// <summary> 世界坐标系朝向 </summary>
        World,
        /// <summary> 单位坐标系朝向 </summary>
        Actor, // 如果Actor为空，取Self，如果self都取不到，取001
        /// <summary> 单位连线坐标系朝向 </summary>
        Line, // 如果Actor为空, 取Self, 如果self都取不到, 取001 如果self连线self, 则为self的local.
    }

    /// <summary>
    /// 确定坐标随机偏移类型
    /// </summary>
    public enum CoorPointRandomType
    {
        /// <summary> 不进行随机 </summary>
        None,
        
        /// <summary> XZ平面环形随机 </summary>
        RandomRingXZ,
    }
    
    [Serializable]
    [MessagePackObject]
    public class HangPointData
    {
        [LabelText("挂点名字")]
        [Key(0)]
        public string name;

        [LabelText("挂点偏移")]
        [Key(1)]
        public X3Vector3 offsetPos;
    }
    
    [MessagePackObject]
    [Serializable]
    public class CoorPoint
    {
        [LabelText("统一选点模式")]
        [Key(0)]
        public CoorPointMode coorPointMode = CoorPointMode.CoorPoint;
        
        #region 步骤1: 确定坐标系原点参数.
        
        [LabelText("坐标系原点类型")]
        [Key(1)]
        public CoorOriginType coorOriginType = CoorOriginType.World;
        
        [LabelText("单位坐标系原点目标类型")]
        [Key(2)]
        public CoorTargetType targetType1 = CoorTargetType.Self;
       
        [LabelText("    记录ID")]
        [Key(3)]
        public int recordTargetID1;
        #endregion

        #region 步骤2: 确定坐标系朝向参数.
        
        [LabelText("坐标系朝向类型")]
        [Key(4)]
        public CoorOrientationType coorOrientationType = CoorOrientationType.World;
        
        [LabelText("目标类型")]
        [Key(5)]
        public CoorTargetType targetType2 = CoorTargetType.Self;
        
        [LabelText("    记录ID")]
        [Key(6)]
        public int recordTargetID2;
        
        [LabelText("目标类型")]
        [Key(7)]
        public CoorTargetType targetType3 = CoorTargetType.Self;
        
        [LabelText("    记录ID")]
        [Key(8)]
        public int recordTargetID3;

        #endregion

        #region 步骤3: 确定坐标偏移量参数.

        [LabelText("是否移动才偏移")] 
        [Key(9)]
        public bool isMoveOffset = false;
            
        [LabelText("确定坐标偏移量")]
        [Key(10)]
        public X3Vector3 offsetPos; // 以P0为原点，在步骤2确立的坐标系中加上Position偏移量，获取P1

        #endregion

        #region 步骤4: 确定坐标随机偏移参数.
        
        [LabelText("确定坐标随机偏移类型")]
        [Key(11)]
        public CoorPointRandomType coorPointRandomType = CoorPointRandomType.None;

        [LabelText("随机小圆半径")]
        [Key(12)]
        public float randomMinRadius;

        [LabelText("随机大圆半径")]
        [Key(13)]
        public float randomMaxRadius;
        
        [LabelText("是否进行贴地")]
        [Key(14)]
        public bool isDown = false;
        #endregion
        
        #region 蓝图变量

        [IgnoreMember] [NonSerialized] public ValueInput<Actor> viActor1;
        [IgnoreMember] [NonSerialized] public ValueInput<Actor> viActor2;
        [IgnoreMember] [NonSerialized] public ValueInput<Actor> viActor3;
        [IgnoreMember] [NonSerialized] public ValueInput<Vector3> viOffsetPos;
        #endregion

        [LabelText("挂点数据")]
        [Key(15)]
        public HangPointData hangPointData = new HangPointData();
    }
}