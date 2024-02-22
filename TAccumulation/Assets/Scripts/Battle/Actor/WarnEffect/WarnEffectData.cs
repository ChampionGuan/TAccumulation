using System;
using UnityEngine;

namespace X3Battle
{
    public enum WarnEffectType
    {
        /// <summary> 闪光 </summary>
        Shine,

        /// <summary> 射线 </summary>
        Ray,

        /// <summary> 圆形 </summary>
        Circle,

        /// <summary> 扇形 </summary>
        Sector,

        /// <summary> 矩形 </summary>
        Rectangle,

        /// <summary> 锁定 </summary>
        Lock
    }

    [Serializable]
    public class ShineWarnData
    {
    }

    [Serializable]
    public class RayWarnData
    {
        [LabelText("", showCondition: "false")]
        public float duration;
        public Vector3 offsetPos;
        public Vector3 angle;
    }

    [Serializable]
    public class CircleWarnData
    {
        public float radius = 3f;

        [LabelText("", showCondition: "false")]
        public float duration;

        public Vector3 offsetPos;
    }

    [Serializable]
    public class SectorWarnData
    {
        public float radius = 3f;

        [LabelText("", showCondition: "false")]
        public float duration;

        public Vector3 offsetPos;
        public float eulerAngleY;
        public float centralAngle = 30f;
    }

    [Serializable]
    public class RectangleWarnData
    {
        public float length = 3f;
        public float width = 3f;

        [LabelText("", showCondition: "false")]
        public float duration;

        public Vector3 offsetPos;
        public float eulerAngleY;
    }

    [Serializable]
    public class WarnEffectData
    {
        public int fxID
        {
            get
            {
                switch (warnEffectType)
                {
                    case WarnEffectType.Shine:
                        return 91;
                    case WarnEffectType.Ray:
                        return 93;
                    case WarnEffectType.Circle:
                        return 94;
                    case WarnEffectType.Sector:
                        return 95;
                    case WarnEffectType.Rectangle:
                        return 96;
                    case WarnEffectType.Lock:
                        return 97;
                    default:
                        throw new ArgumentOutOfRangeException();
                }
            }
        }

        [LabelText("预警特效类型枚举")] public WarnEffectType warnEffectType = WarnEffectType.Shine;

        [LabelText("闪光预警特效数据", showCondition: "false")]
        public ShineWarnData shineWarnData;

        [LabelText("射线预警特效数据", showCondition: "enum:warnEffectType==1")]
        public RayWarnData rayWarnData;

        [LabelText("圆形预警特效数据", showCondition: "enum:warnEffectType==2")]
        public CircleWarnData circleWarnData;

        [LabelText("扇形预警特效数据", showCondition: "enum:warnEffectType==3")]
        public SectorWarnData sectorWarnData;

        [LabelText("矩形预警特效数据", showCondition: "enum:warnEffectType==4")]
        public RectangleWarnData rectangleWarnData;

        [LabelText("是否跟随技能目标", showCondition: "enum:warnEffectType==2|3|4")]
        public bool ifFollow;

        [LabelText("跟随时间", showCondition: "ifFollow", showCondition2:"enum:warnEffectType==2|3|4")]
        public float followStopTime;

        [LabelText("目标类型")]
        public TargetType targetType;
    }
}