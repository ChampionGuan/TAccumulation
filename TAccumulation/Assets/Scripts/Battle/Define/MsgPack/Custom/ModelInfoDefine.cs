using System;
using System.Collections.Generic;
using CollisionQuery;
using EasyCharacterMovement;
using MessagePack;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Battle
{
    [MessagePackObject]
#if UNITY_EDITOR
    [Serializable]
#endif
    public class ModelInfos
    {
        [Key(0)]public Dictionary<string, ModelInfo> infos;

        public ModelInfos()
        {
            infos = new Dictionary<string, ModelInfo>();
        }
    }

    [MessagePackObject]
#if UNITY_EDITOR
    [Serializable]
#endif
    public class ModelInfo
    {
        [Key(0)] public string ID;
        [Key(1)] public ActorBoundingShape characterCtrl;
        [Key(2)] public List<Dummy> dummys;
        [Key(3)] public List<ActorBoundingShape> colliders;
        [Key(4)] public List<ActorBoundingShape> hurtBoxs;
        [Key(5)] public CharacterMoveCfg characterMoveCfg;
        [Key(6)] public Dictionary<string, FxPerformGroup> fxPerformGroups; // 配置组名 ：特效配置组
        [Key(7)] public OcclusionCfg occlusionCfg;
        [Key(8)] public bool isSpecialBody;
        [Key(9)] public string VirtualPath;
        [Key(10)] public ApproachDissolveCfg approachDissolveCfg;
        [Key(11)] public List<LayerMixerBone> layerOverwriteBones;
        [Key(12)] public PathFindCfg pathFindCfg;

        public ModelInfo()
        {
            this.ID = "";
            dummys = new List<Dummy>();
            colliders = new List<ActorBoundingShape>();
            hurtBoxs = new List<ActorBoundingShape>();
            fxPerformGroups = new Dictionary<string, FxPerformGroup>();
            characterMoveCfg = new CharacterMoveCfg();
            occlusionCfg = new OcclusionCfg();
            approachDissolveCfg = new ApproachDissolveCfg();
            layerOverwriteBones = new List<LayerMixerBone>();
            pathFindCfg = new PathFindCfg();
        }

        public ModelInfo(string name)
        {
            this.ID = name;
            dummys = new List<Dummy>();
            colliders = new List<ActorBoundingShape>();
            hurtBoxs = new List<ActorBoundingShape>();
            characterMoveCfg = new CharacterMoveCfg();
            occlusionCfg = new OcclusionCfg();
            approachDissolveCfg = new ApproachDissolveCfg();
            layerOverwriteBones = new List<LayerMixerBone>();
            pathFindCfg = new PathFindCfg();
        }

        public ActorBoundingShape GetShape(string name, bool isCollider)
        {
            List<ActorBoundingShape> list = isCollider ? colliders : hurtBoxs;
            for (int i = 0; i < list.Count; i++)
            {
                if (list[i].name == name)
                {
                    return list[i];
                }
            }
            return null;
        }

        public Dummy GetDummy(string name)
        {
            for (int i = 0; i < dummys.Count; i++)
            {
                if (dummys[i].name == name)
                {
                    return dummys[i];
                }
            }
            return null;
        }
    }

    [Serializable]
    [MessagePackObject]
    public partial class Dummy
    {
        [Key(0)]public string name;
        [Key(1)]public string bonePath;
        [Key(2)]public X3Vector3 localPos;
        [Key(3)]public SyncType syncType;
        [Key(4)] public X3Vector3 localAngle;

        // 逻辑不要使用，仅限与生成MessagePack生成 formatter使用
        public Dummy()
        {
            
        }
    }

    [Serializable]
    [MessagePackObject]
    public class LayerMixerBone
    {
        [Key(0)] public string bonePath;
        [Key(1)] public string newParentBonePaths;

        public LayerMixerBone(string bonePath, string newParentBonePaths)
        {
            this.bonePath = bonePath;
            this.newParentBonePaths = newParentBonePaths;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class ActorBoundingShape:BoundingShape
    {
        [ReadOnly]
        [Key(8)]public string name;
        [ReadOnly]
        [Key(9)]public string dummyName;
        [ReadOnly]
        [Key(10)]public bool isCharacterCtrl;
        // 默认Actor上的Collider， 不可行走，不可站立，不可悬停
        [Tooltip(CharacterMoveConst.CollisionBehaviorTips)]
        [Key(11)]public CollisionBehavior flags = CollisionBehavior.NotWalkable | CollisionBehavior.CanNotStepOn | CollisionBehavior.CanPerchOn;
        [Key(12)] public Direction direction = Direction.Y;

        public ActorBoundingShape()
        {

        }
        
        public ActorBoundingShape(string name, string dummyName, bool isCharacterCtrl=false)
        {
            this.name = name;
            this.dummyName = dummyName;
            this.isCharacterCtrl = isCharacterCtrl;
            this.ShapeType = ShapeType.Capsule;
            this.Height = 2;
            this.Width = 1;
            this.Radius = 1;
            this.Length = 1;
        }
    }
    
    [Serializable]
    [MessagePackObject]
    public class BoundingShape:IReset
    {
        [Key(0)]public ShapeType ShapeType;
        [Key(1)]public float Length; // x 轴 全长, 形状为环形扇形时，表示内径
        [Key(2)]public float Width; // z 轴 全长
        [Key(3)]public float Height; // y 轴 全高度(例如胶囊体高度：包括上，下半圆高度)
        [Key(4)]public float Radius;
        [Key(5)]public float Angle;  // 扇形角度 
        [Key(6)]public X3Vector3 Offset = Vector3.zero;  // 距原点坐标的偏移量
        [Key(7)]public X3Vector3 Rotation = Vector3.zero; // 旋转信息

        public void Reset()
        {
            ShapeType = 0;
            Length = 0;
            Width = 0;
            Height = 0;
            Radius = 0;
            Angle = 0;
            Offset = Vector3.zero;
            Rotation = Vector3.zero;
        }
        
        public void CopyFrom(BoundingShape cfg)
        {
            if (null == cfg) return;
            ShapeType = cfg.ShapeType;
            Length = cfg.Length;
            Width = cfg.Width;
            Height = cfg.Height;
            Radius = cfg.Radius;
            Angle = cfg.Angle;
            Offset = cfg.Offset;
            Rotation = cfg.Rotation;
        }

        public override bool Equals(object obj)
        {
            return this == obj;
        }

        public static bool operator !=(BoundingShape objA, BoundingShape objB)
        {
            return !(objA == objB);
        }

        public static bool operator ==(BoundingShape objA, BoundingShape objB)
        {
            if (objA is null)
            {
                return objB is null;
            }

            if (objB is null)
            {
                return false;
            }
            
            return objA.ShapeType == objB.ShapeType 
                   && objA.Length == objB.Length 
                   && objA.Width == objB.Width 
                   && objA.Height == objB.Height 
                   && objA.Radius == objB.Radius 
                   && objA.Angle == objB.Angle 
                   && objA.Offset == objB.Offset 
                   && objA.Rotation == objB.Rotation;
        }

        /// <summary>
        /// 获取该形状所能产生的最大的半长
        /// </summary>
        /// <returns></returns>
        public float GetShapeMaxHalfValue()
        {
            switch (ShapeType)
            {
                case ShapeType.Capsule:
                    return Height * 0.5f;
                case ShapeType.Sphere:
                case ShapeType.FanColumn:
                    return Radius;
                case ShapeType.Cube:
                    float pow = Mathf.Pow(Length, 2) + Mathf.Pow(Width, 2) + Mathf.Pow(Height, 2);
                    return Mathf.Sqrt(pow) * 0.5f;
                case ShapeType.RingFanColumn:
                    return Radius;
                case ShapeType.Ray:
                    return Length;
                default:
                    LogProxy.LogError("GetShapeMaxHalfValue不支持形状类型" + ShapeType);
                    break;
            }
            return 0;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class FxPerformGroup
    {
        [Key(0)] public string name;
        [Key(1)] public List<FxPerform> fxPerforms;
        [Key(2)] public bool defaultOpen;

        public FxPerformGroup(string name)
        {
            this.name = name;
            this.fxPerforms = new List<FxPerform>();
            defaultOpen = false;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class FxPerform
    {
        [Key(0)] public string dummyName;
        [Key(1)] public string fxPath;
        [Key(2)] public string performName;

        public FxPerform(string name, string path, string performName)
        {
            dummyName = name;
            fxPath = path;
            this.performName = performName;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class CharacterMoveCfg
    {
        [Key(0)]public bool AllowPushCharacters;

        public CharacterMoveCfg()
        {
            AllowPushCharacters = true;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class OcclusionCfg
    {
        [Key(0)] public float delayTime; // 恢复延迟时间
        [Key(1)] public float minAlpha; // 最小透明值
        [Key(2)] public string bonePath; // 轴点
        [Key(3)] public float inRadius; // 包围球内半径
        [Key(4)] public float outRadius; // 包围球外半径
        [Key(5)] public bool isMonster; // 是否是怪物

        public OcclusionCfg()
        {

        }

        public OcclusionCfg (float delayTime, float minAlpha, string bonePath, float inRadius, float outRadius)
        {
            this.delayTime = delayTime;
            this.minAlpha = minAlpha;
            this.bonePath = bonePath;
            this.inRadius = inRadius;
            this.outRadius = outRadius;
            isMonster = true;
        }
    }

    [Serializable]
    [MessagePackObject]
    public class ApproachDissolveCfg
    {
        [Key(0)] public bool isUse = true;
        [Key(1)] public X3Vector3 offset;//TODO 由于策划中途改数据 所以保留到下面数组里..
        [Key(2)] public float radius = 1f;

        [Key(3)] public CapsuleItem[] capsules;

        public ApproachDissolveCfg() 
        {
            capsules = new CapsuleItem[1] 
            { 
                new CapsuleItem() { 
                    radius = radius, offset = offset 
                } 
            };
        }
    }

    [Serializable]
    [MessagePackObject]
    public class CapsuleItem
    {
        [Key(0)] public X3Vector3 offset;
        [Key(1)] public float radius = 1f;
        [Key(2)] public X3Vector3 rotate;
        [Key(3)] public float halfHeight = 0f;
        [Key(4)] public string path = "Roots/Root_M";
    }

    [Serializable]
    [MessagePackObject]
    public class PathFindCfg
    {
        [Key(0)] public bool useCharacterRadius = true;
        [Key(1)] public PathFindShapeType shape;
        [Key(2)] public float radius = 1f;
        [Key(3)] public float length = 1f;
        [Key(4)] public float width = 1f;
        [Key(5)] public X3Vector3 offset;
    }
}