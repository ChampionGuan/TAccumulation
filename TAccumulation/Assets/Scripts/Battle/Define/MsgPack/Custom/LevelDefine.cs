using System.Collections.Generic;
using System;
#if UNITY_EDITOR
using System.Linq;
#endif  
using MessagePack;
using UnityEngine;
using UnityEngine.Serialization;

//注意 ： 此文件仅限 沧澜 修改，如果修改 请 通知 沧澜

namespace X3Battle
{
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
    public class StageConfig //关卡配置
    {
	    [Key(0)] public int ID;
	    [Key(3)] public CameraConfig[] Cameras;
	    [Key(4)] public PointConfig[] Points;
	    [Key(5)] public SpawnPointConfig[] SpawnPoints;
	    [Key(6)] public MachineConfig[] Machines;
	    [Key(7)] public ObstacleConfig[] Obstacles;
	    [Key(8)] public TriggerAreaConfig[] TriggerAreas;
	    [Key(9)] public InterActorPointConfig[] InterActors;
	    [Key(10)] public StageIdWeight[] GroupTypeWeights;
#if UNITY_EDITOR
	    [IgnoreMember] [NonSerialized]public List<CameraConfig> CameraList;
	    [IgnoreMember] [NonSerialized]public List<PointConfig> PointList;
	    [IgnoreMember] [NonSerialized]public List<SpawnPointConfig> SpawnPointList;
	    [IgnoreMember] [NonSerialized]public List<MachineConfig> MachineList;
	    [IgnoreMember] [NonSerialized]public List<ObstacleConfig> ObstacleList;
	    [IgnoreMember] [NonSerialized]public List<TriggerAreaConfig> TriggerAreaList;
	    [IgnoreMember] [NonSerialized]public List<InterActorPointConfig> InterActorList;
	    [IgnoreMember] [NonSerialized]public List<StageIdWeight> GroupTypeWeightList;
	    [IgnoreMember] [NonSerialized]public string Name;
	    [IgnoreMember] [NonSerialized]public bool NavMeshVisible;
	    [IgnoreMember] [NonSerialized]public bool LastNavMeshVisible;

	    public void ToEditor()
	    {
		    CameraList = Cameras == null ? new List<CameraConfig>() : Cameras.ToList();
		    PointList = Points == null ? new List<PointConfig>() : Points.ToList();
		    SpawnPointList = SpawnPoints == null ? new List<SpawnPointConfig>() : SpawnPoints.ToList();
		    MachineList = Machines == null ? new List<MachineConfig>() : Machines.ToList();
		    ObstacleList = Obstacles == null ? new List<ObstacleConfig>() : Obstacles.ToList();
		    TriggerAreaList = TriggerAreas == null ? new List<TriggerAreaConfig>() : TriggerAreas.ToList();
		    InterActorList = InterActors == null ? new List<InterActorPointConfig>() : InterActors.ToList();
		    GroupTypeWeightList = GroupTypeWeights == null ? new List<StageIdWeight>{new StageIdWeight{ID = 0, Weight = 100}} : GroupTypeWeights.ToList();
		    LastNavMeshVisible = NavMeshVisible = true;
		    for (int i = 0; i < CameraList.Count; i++) { CameraList[i].ToEditor(); }
		    for (int i = 0; i < PointList.Count; i++) { PointList[i].ToEditor(); }
		    for (int i = 0; i < SpawnPointList.Count; i++) { SpawnPointList[i].ToEditor(); }
		    for (int i = 0; i < MachineList.Count; i++) { MachineList[i].ToEditor(); }
		    for (int i = 0; i < ObstacleList.Count; i++) { ObstacleList[i].ToEditor(); }
		    for (int i = 0; i < InterActorList.Count; i++) { InterActorList[i].ToEditor(); }
		    for (int i = 0; i < TriggerAreaList.Count; i++) { TriggerAreaList[i].ToEditor(); }
	    }

	    public void ToRuntime()
	    {
		    Cameras = CameraList.ToArray();
		    Points = PointList.ToArray();
		    SpawnPoints = SpawnPointList.ToArray();
		    Machines = MachineList.ToArray();
		    Obstacles = ObstacleList.ToArray();
		    TriggerAreas = TriggerAreaList.ToArray();
		    InterActors = InterActorList.ToArray();
		    GroupTypeWeights = GroupTypeWeightList.ToArray();
	    }
#endif
    }
    
#if UNITY_EDITOR
	[Serializable]
#endif
	public abstract class RowBase
	{
		[Key(0)] public int ID;
		[Key(1)] public string Name;
#if UNITY_EDITOR
		[IgnoreMember] [NonSerialized]public GameObject Ins;
		[IgnoreMember] [NonSerialized]public int LastId;
		[IgnoreMember] [NonSerialized]public int ItemId;
		[IgnoreMember] [NonSerialized]public GameObject Actor;

		public int GetId()
		{
			return ID;
		}

		public int GetItemId()
		{
			return ItemId;
		}

		public string GetName()
		{
			return Name;
		}
		
		public virtual void CopyFrom(object other) { }
		public virtual void ToEditor() {LastId = ItemId = ID;}
#endif
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class CameraConfig : RowBase //相机	ID从30001开始35000结束
	{
		[Key(2)] public CameraType CameraType;
		[Key(3)] public CameraFollowType FollowType;
#if UNITY_EDITOR
		[IgnoreMember] [NonSerialized]public Transform Tf;

		public override void CopyFrom(object other)
		{
			if (!(other is CameraConfig))
			{
				return;
			}
			CameraConfig source = other as CameraConfig;
			this.Name = source.Name;
			this.CameraType = source.CameraType;
			this.FollowType = source.FollowType;
			this.Tf = UnityEngine.Object.Instantiate(source.Tf);
		}
#endif
	}
	
#if UNITY_EDITOR
	[Serializable]
#endif
	public abstract class PointBase : RowBase
	{
		[Key(2)] public X3Vector3 Position;
		[Key(3)] public X3Vector3 Rotation;
	}
	
#if UNITY_EDITOR
	[Serializable]
#endif
	public abstract class ActorPointBase : PointBase
	{
		[Key(4)] public int ConfigID;
		[Key(5)] public int PropertyID;
		[Key(6)] public FactionType FactionType;
#if UNITY_EDITOR
		[IgnoreMember][NonSerialized] public bool ConfigIDIsEnum = true;
#endif
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class PointConfig : ActorPointBase //点位/出生点	ID从10001开始15000结束	ConfigID需要外部传入
	{
		[Key(7)] public int GroupID;
		[Key(8)] public PointType PointType = PointType.BornPoint;
		[Key(9)] public RoleType RoleType = RoleType.Girl;

		public PointConfig()
		{
			FactionType = FactionType.Hero;
		}
#if UNITY_EDITOR
		public override void CopyFrom(object other)
		{
			if (!(other is PointConfig))
			{
				return;
			}
			PointConfig source = other as PointConfig;
			this.Name = source.Name;
			this.GroupID = source.GroupID;
			this.Ins = GameObject.Instantiate(source.Ins);
			this.PointType = source.PointType;
			this.RoleType = source.RoleType;
			this.FactionType = source.FactionType;
			this.PropertyID = source.PropertyID;
		}
#endif
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class SpawnPointConfig : ActorPointBase //刷怪点	ID从15001开始20000结束
	{
		[Key(7)] public int GroupID = 1;
		[Key(8)] public ActorAIStatus BehaviorType = ActorAIStatus.Attack;
		[Key(9)] public bool IsStart;
		/// <summary> 是否激活 </summary>
		[Key(10)] public bool IsActive = true;
		/// <summary> 是否启用出生镜头 </summary>
		[Key(11)] public bool EnableBornCamera;
		[Key(12)] public bool HudControl = true;
		[Key(13)] public bool HudIsTop;
		[Key(14)] public bool HudIsHead = true;
		/// <summary> 是否启用Boss镜头 </summary>
		[Key(15)] public bool EnableBossCamera;
		[Key(16)] public bool IsShowArrowIcon;
		
		[Key(17)] public int GroupType;
		[Key(18)] public float RandomRadius;
		[Key(19)] public float RandomAngle;
		public SpawnPointConfig()
		{
			FactionType = FactionType.Monster;
			PropertyID = 4;
		}
#if UNITY_EDITOR
		[NonSerialized] [IgnoreMember] public StageCircleData CircleData = new StageCircleData();
		[NonSerialized] [IgnoreMember] public StageSectorData SectorData = new StageSectorData();

		public override void CopyFrom(object other)
		{
			if (!(other is SpawnPointConfig))
			{
				return;
			}
			SpawnPointConfig source = other as SpawnPointConfig;
			this.Name = source.Name;
			this.GroupType = source.GroupType;
			this.GroupID = source.GroupID;
			this.BehaviorType = source.BehaviorType;
			this.Ins = GameObject.Instantiate(source.Ins);
			this.IsStart = source.IsStart;
			this.IsActive = source.IsActive;
			this.IsShowArrowIcon = source.IsShowArrowIcon;
			this.EnableBornCamera = source.EnableBornCamera;
			this.HudControl = source.HudControl;
			this.HudIsTop = source.HudIsTop;
			this.HudIsHead = source.HudIsHead;
			this.ConfigID = source.ConfigID;
			this.FactionType = source.FactionType;
			this.PropertyID = source.PropertyID;
			this.EnableBossCamera = source.EnableBossCamera;
			this.RandomRadius = source.RandomRadius;
			this.RandomAngle = source.RandomAngle;
		}
#endif
	}
	
	[MessagePackObject]
	[Serializable]
	public class InterActorPointConfig : ActorPointBase //交互物点	ID从35001开始40000结束
	{
		[Key(7)] public int GroupID = 1;
		[Key(8)] public InterActorCreateType CreateType;
		[Key(9)] public bool IsStart;
		[Key(10)] public int Tag;
		[Key(11)] public int MonsterSpawnId;
		[Key(12)] public int ModelCfgId;
#if UNITY_EDITOR
		public override void CopyFrom(object other)
		{
			if (!(other is InterActorPointConfig))
			{
				return;
			}
			InterActorPointConfig source = other as InterActorPointConfig;
			this.Name = source.Name;
			this.GroupID = source.GroupID;
			this.Ins = GameObject.Instantiate(source.Ins);
			this.IsStart = source.IsStart;
			this.Tag = source.Tag;
			this.ConfigID = source.ConfigID;
			this.FactionType = source.FactionType;
			this.CreateType = source.CreateType;
			this.PropertyID = source.PropertyID;
			this.MonsterSpawnId = source.MonsterSpawnId;
			this.ModelCfgId = source.ModelCfgId;
		}
#endif
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class DoorConfig //门
	{
		[Key(0)] public DoorState State;
		[Key(1)] public ObstacleConfig Obstacle;
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class SwitchConfig //开关
	{
		[Key(0)] public SwitchState State;
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class AttackBasicConfig //复杂机关
	{
		[Key(0)] public AttackBasicState State;
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class MachineConfig : ActorPointBase //机关	ID从20001开始25000结束	
	{
		[Key(7)] public int GroupID;
		[Key(8)] public bool IsDisplay;
		[Key(9)] public MachineType MachineType;
		[Key(10)] public DoorConfig Door;
		[Key(11)] public SwitchConfig Switch;
		[Key(12)] public AttackBasicConfig AttackBasic;
		
		public MachineConfig()
		{
			FactionType = FactionType.Machine;
		}
#if UNITY_EDITOR		
		public override void CopyFrom(object other)
		{
			if (other == null || !(other is MachineConfig))
			{
				return;
			}
			MachineConfig source = other as MachineConfig;
			this.Name = source.Name;
			this.GroupID = source.GroupID;
			this.Ins = GameObject.Instantiate(source.Ins);
			this.IsDisplay = source.IsDisplay;
			this.ConfigID = source.ConfigID;
			this.FactionType = source.FactionType;
			this.MachineType = source.MachineType;
			if (source.Door != null)
			{
				this.Door = new DoorConfig();
				this.Door.State = source.Door.State;
				this.Door.Obstacle = new ObstacleConfig();
				this.Door.Obstacle.CopyFrom(source.Door.Obstacle);
			}

			if (source.Switch != null)
			{
				this.Switch = new SwitchConfig();
				this.Switch.State = source.Switch.State;
			}

			if (source.AttackBasic != null)
			{
				this.AttackBasic = new AttackBasicConfig();
				this.AttackBasic.State = source.AttackBasic.State;
				this.PropertyID = source.PropertyID;
			}
		}
#endif
	}
	
	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class ObstacleConfig : PointBase //空气墙或者阻挡体	ID从40001开始45000
	{
		[Key(4)] public bool Active;
		[Key(5)] public ShapeType ObstacleShape = ShapeType.Cube;
		[Key(6)] public float Radius; //半径
		[Key(7)] public float Length;
		[Key(8)] public float Width;
		[Key(9)] public float Height;
		[Key(11)] public int FxID;
		[Key(12)] public float Duration; //-1表示永久
		[Key(13)] public CollisionBehavior Flags = CollisionBehavior.CanNotFilterWhenIgnoreCollision;
		
#if UNITY_EDITOR
		public override void CopyFrom(object other)
		{
			if (!(other is ObstacleConfig))
				return;
			ObstacleConfig source = other as ObstacleConfig;
			this.Name = source.Name;
			this.Position = source.Position;
			this.Rotation = source.Rotation;
			this.Active = source.Active;
			this.ObstacleShape = source.ObstacleShape;
			this.Radius = source.Radius;
			this.Length = source.Length;
			this.Width = source.Width;
			this.Height = source.Height;
			this.FxID = source.FxID;
			this.Duration = source.Duration;
			this.Flags = source.Flags;
		}
#endif
	}

	[MessagePackObject]
#if UNITY_EDITOR
	[Serializable]
#endif
	public class TriggerAreaConfig : PointBase //触发区域	ID从25001开始30000结束
	{
		[Key(4)] public int FxID;
		[Key(5)] public TriggerShape TriggerShape = TriggerShape.Sphere;
		[Key(6)] public float Radius; //半径
		[Key(7)] public float Length;
		[Key(8)] public float Width;
		[Key(9)] public float Height;
#if UNITY_EDITOR
		public override void CopyFrom(object other)
		{
			if (!(other is TriggerAreaConfig))
				return;
			TriggerAreaConfig source = other as TriggerAreaConfig;
			this.Name = source.Name;
			this.Position = source.Position;
			this.Rotation = source.Rotation;
			this.TriggerShape = source.TriggerShape;
			this.Radius = source.Radius;
			this.Length = source.Length;
			this.Width = source.Width;
			this.Height = source.Height;
		}
#endif
	}
	
	[MessagePackObject]
	[Serializable]
	public class StageIdWeight
	{
		[Key(0)]public int ID;
		[Key(1)]public int Weight;
		[IgnoreMember] [NonSerialized] public int TopWeight;
	}
#if UNITY_EDITOR
	public class StageSectorData : StageCircleData
	{
		public Vector3 from;
		public Vector3 to;
		public Vector3 sectorFrom;
		public float angle;
	}

	public class StageCircleData
	{
		public Vector3 center;
		public float radius;
		public Color color;
	}
#endif
}