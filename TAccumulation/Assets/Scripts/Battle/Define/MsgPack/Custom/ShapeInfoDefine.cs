using System;
using MessagePack;

namespace X3Battle
{
    [Serializable]
    [MessagePackObject]
    public class ShapeBoxInfo
    {
        /// <summary>
        /// 形状信息
        /// </summary>
        [LabelText("形状数据")]
        [Key(0)] public ShapeInfo ShapeInfo;

        /// <summary>
        /// 跟随模式
        /// </summary>
        [LabelText("跟随模式")]
        [Key(1)] public ShapeBoxFollowMode ShapeBoxFollowMode;

        /// <summary>
        /// 位置偏移
        /// </summary>
        [LabelText("位置偏移")]
        [Key(2)] public X3Vector3 OffsetPos;

        /// <summary>
        /// 角度偏移(欧拉角)
        /// </summary>
        [LabelText("角度偏移(欧拉角)")]
        [Key(4)] public X3Vector3 OffsetEuler;
        
        public ShapeBoxInfo Clone()
        {
            var shapeBoxInfo = new ShapeBoxInfo();
            shapeBoxInfo.ShapeBoxFollowMode = this.ShapeBoxFollowMode;
            shapeBoxInfo.ShapeInfo = this.ShapeInfo.Clone();
            shapeBoxInfo.OffsetPos = this.OffsetPos;
            shapeBoxInfo.OffsetEuler = this.OffsetEuler;
            return shapeBoxInfo;
        }
    }
    
    [Serializable]
    [MessagePackObject]
    public class ShapeInfo
    {
        [LabelText("形状类型")]
        [Key(0)]
        public ShapeType ShapeType = ShapeType.Capsule;

        /// <summary>
        /// 胶囊体形状数据
        /// </summary>
        [LabelText("胶囊体的形状数据", showCondition:"enum:ShapeType==0")]
        [Key(1)] public CapsuleShapeInfo CapsuleShapeInfo;

        /// <summary>
        /// 立方体的形状数据
        /// </summary>
        [LabelText("立方体的形状数据", showCondition:"enum:ShapeType==1")]
        [Key(2)] public CubeShapeInfo CubeShapeInfo;

        /// <summary>
        /// 球体的形状数据
        /// </summary>
        [LabelText("球体的形状数据", showCondition:"enum:ShapeType==3")]
        [Key(3)] public SphereShapeInfo SphereShapeInfo;

        /// <summary>
        /// 扇形柱体的形状数据
        /// </summary>
        [LabelText("扇形柱体的形状数据", showCondition:"enum:ShapeType==2")]
        [Key(4)] public FanColumnShapeInfo FanColumnShapeInfo;
        
        [LabelText("射线的形状数据", showCondition:"enum:ShapeType==4")]
        [Key(5)] public RayShapeInfo RayShapeInfo;

        [LabelText("环扇形的形状数据", showCondition: "enum:ShapeType==5")] 
        [Key(6)] public RingShapeInfo RingShapeInfo;
        
        /// <summary>
        /// 用于Debug的信息.
        /// </summary>
        [IgnoreMember]
        public string DebugInfo { get; private set; }

        [System.Diagnostics.Conditional(PapeGames.X3.LogProxy.DEBUG_LOG)]
        public void SetDebugInfo(string str, params object[] args)
        {
            this.DebugInfo = string.Format(str, args);
        }

        public ShapeInfo Clone()
        {
            ShapeInfo shapeInfo = new ShapeInfo();
            shapeInfo.ShapeType = this.ShapeType;
            
            switch (this.ShapeType)
            {
                case ShapeType.Capsule:
                    if (this.CapsuleShapeInfo != null)
                    {
                        shapeInfo.CapsuleShapeInfo = this.CapsuleShapeInfo.Clone();
                    }
                    break;
                case ShapeType.Cube:
                    if (this.CubeShapeInfo != null)
                    {
                        shapeInfo.CubeShapeInfo = this.CubeShapeInfo.Clone();
                    }
                    break;
                case ShapeType.FanColumn:
                    if (this.FanColumnShapeInfo != null)
                    {
                        shapeInfo.FanColumnShapeInfo = this.FanColumnShapeInfo.Clone();
                    }
                    break;
                case ShapeType.Sphere:
                    if (this.SphereShapeInfo != null)
                    {
                        shapeInfo.SphereShapeInfo = this.SphereShapeInfo.Clone();
                    }
                    break;
                case ShapeType.Ray:
                    if (this.RayShapeInfo != null)
                    {
                        shapeInfo.RayShapeInfo = this.RayShapeInfo.Clone();
                    }
                    break;
                case ShapeType.RingFanColumn:
                    if (this.RingShapeInfo != null)
                    {
                        shapeInfo.RingShapeInfo = this.RingShapeInfo.Clone();
                    }
                    break;
            }
            return shapeInfo;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class CapsuleShapeInfo
    {
        /// <summary>
        /// 胶囊体的半径
        /// </summary>
        [LabelText("胶囊体的半径")]
        [Key(0)] public float Radius;
        

        /// <summary>
        /// 胶囊体的高
        /// </summary>
        [LabelText("胶囊体的高")]
        [Key(1)] public float Height;

        public CapsuleShapeInfo Clone()
        {
            var capsuleShapeInfo = new CapsuleShapeInfo();
            capsuleShapeInfo.Radius = this.Radius;
            capsuleShapeInfo.Height = this.Height;
            return capsuleShapeInfo;
        }
    }
    
    [Serializable]
    [MessagePackObject]
    public class CubeShapeInfo
    {
        /// <summary>
        /// 立方体的长
        /// </summary>
        [LabelText("立方体的长")]
        [Key(0)] public float Length;

        /// <summary>
        /// 立方体的宽
        /// </summary>
        [LabelText("立方体的宽")]
        [Key(1)] public float Width;

        /// <summary>
        /// 立方体的高
        /// </summary>
        [LabelText("立方体的高")]
        [Key(2)] public float Height;

        public CubeShapeInfo Clone()
        {
            CubeShapeInfo cubeShapeInfo = new CubeShapeInfo();
            cubeShapeInfo.Length = this.Length;
            cubeShapeInfo.Width = this.Width;
            cubeShapeInfo.Height = this.Height;
            return cubeShapeInfo;
        }
    }
    
    [Serializable]
    [MessagePackObject]
    public class FanColumnShapeInfo
    {
        /// <summary>
        /// 扇柱体的半径
        /// </summary>
        [LabelText("扇柱体的半径")]
        [Key(0)] public float Radius;

        /// <summary>
        /// 扇柱体的开角
        /// </summary>
        [LabelText("扇柱体的开角")]
        [Key(1)] public float Angle;

        /// <summary>
        /// 扇柱体的高
        /// </summary>
        [LabelText("扇柱体的高")]
        [Key(2)] public float Height;

        public FanColumnShapeInfo Clone()
        {
            FanColumnShapeInfo fanColumnShapeInfo = new FanColumnShapeInfo();
            fanColumnShapeInfo.Radius = this.Radius;
            fanColumnShapeInfo.Angle = this.Angle;
            fanColumnShapeInfo.Height = this.Height;
            return fanColumnShapeInfo;
        }
    }
    
    [Serializable]
    [MessagePackObject]
    public class SphereShapeInfo
    {
        /// <summary>
        /// 球体的半径
        /// </summary>
        [LabelText("球体的半径")]
        [Key(0)] public float Radius;
        
        
        public SphereShapeInfo Clone()
        {
            SphereShapeInfo sphereShapeInfo = new SphereShapeInfo();
            sphereShapeInfo.Radius = this.Radius;
            return sphereShapeInfo;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class RayShapeInfo
    {
        [LabelText("射线长度")]
        [Key(0)]
        public float Length = -1;
        
        public RayShapeInfo Clone()
        {
            RayShapeInfo rayShapeInfo = new RayShapeInfo();
            rayShapeInfo.Length = this.Length;
            return rayShapeInfo;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class RingShapeInfo
    {
        [LabelText("环形内半径")]
        [Key(0)]
        public float InnerRadius;
        
        [LabelText("环形外半径")]
        [Key(1)]
        public float OuterRadius;
        
        [LabelText("环形开角")]
        [Key(2)]
        public float Angle;
        
        [LabelText("环形高度")]
        [Key(3)]
        public float Height;
        
        public RingShapeInfo Clone()
        {
            RingShapeInfo ringShapeInfo = new RingShapeInfo();
            ringShapeInfo.InnerRadius = this.InnerRadius;
            ringShapeInfo.OuterRadius = this.OuterRadius;
            ringShapeInfo.Angle = this.Angle;
            ringShapeInfo.Height = this.Height;
            return ringShapeInfo;
        }
    }
}