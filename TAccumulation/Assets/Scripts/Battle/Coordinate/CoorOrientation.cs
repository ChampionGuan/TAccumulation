using System;
using System.Runtime.Serialization;
using FlowCanvas;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 朝向坐标系类型
    /// </summary>
    public enum OrientationCoorType
    {
        /// <summary> 看向Actor坐标系 </summary>
        LookAtActor,
        /// <summary> 看向点坐标系 </summary>
        LookAtPoint,
        /// <summary> 世界坐标系 </summary>
        WorldCoor,
        /// <summary> Actor的局部坐标系 </summary>
        ActorLocalCoor,
        /// <summary> 两个Actor的连线坐标系 </summary>
        ActorLineCoor,
    }
    
    [MessagePackObject]
    [Serializable]
    public class CoorOrientation
    {
        [LabelText("朝向坐标系类型")]
        [Key(0)]
        public OrientationCoorType orientationCoorType;

        [LabelText("朝向单位类型", showCondition:"enum:orientationCoorType==0")]
        [Key(1)]
        public CoorTargetType targetType1;
        
        [LabelText("    记录ID", showCondition:"enum:orientationCoorType==0", showCondition2:"enum:targetType1==7")]
        [Key(2)]
        public int recordTargetID1;

        [DrawCoorPoint("朝向点数据", showCondition:"enum:orientationCoorType==1")]
        [Key(3)]
        public CoorPoint coorPoint = new CoorPoint();

        [LabelText("Local单位类型", showCondition:"enum:orientationCoorType==3")]
        [Key(4)]
        public CoorTargetType targetType2;
        
        [LabelText("    记录ID", showCondition:"enum:orientationCoorType==3", showCondition2:"enum:targetType2==7")]
        [Key(5)]
        public int recordTargetID2;

        [LabelText("连线起始点单位类型", showCondition:"enum:orientationCoorType==4")]
        [Key(6)]
        public CoorTargetType targetType3;

        [LabelText("    记录ID", showCondition:"enum:orientationCoorType==4", showCondition2:"enum:targetType3==7")]
        [Key(7)]
        public int recordTargetID3;
        
        [LabelText("连线目标点单位类型", showCondition:"enum:orientationCoorType==4")]
        [Key(8)]
        public CoorTargetType targetType4;
        
        [LabelText("    记录ID", showCondition:"enum:orientationCoorType==4", showCondition2:"enum:targetType4==7")]
        [Key(9)]
        public int recordTargetID4;

        [LabelText("Y轴旋转偏移量")]
        [Key(10)]
        public float offsetAngleY;

        [LabelText("旋转偏移量")]
        [Key(11)]
        public X3Vector3 offsetAngle;

        [LabelText("随机旋转偏移量")]
        [Key(12)]
        public X3Vector3 randomAngle;

        [IgnoreMember] [NonSerialized] public ValueInput<Actor> viActor1;
        [IgnoreMember] [NonSerialized] public ValueInput<Actor> viActor2;
    }
}