using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class ItemPointData : ActorPointBase
    {
        public Actor Master { get; set; }
        public DamageExporter damageExporter { get; set; }
        public int Level { get; set; }
        public bool IsShowArrowIcon { get; set; }
    }

    public class CreaturePointData : ActorPointBase
    {
        public Actor Master { get; set; }
        public CreatureType CreatureType { get; set; }
    }

    public class SummonCreaturePointData : CreaturePointData
    {
        public ISkill MasterSkill { get; set; }
        public BattleSummon SummonConfig { get; set; }
    }

    public class StagePointData : ActorPointBase
    {
    }
    
    /// <summary>
    /// 角色创建配置（角色如果复用，此类中数据必须一致）
    /// 与ActorCfg一起作为Actor创建使用
    /// </summary>
    public sealed class ActorCreateCfg
    {
        public bool IsPlayer { get; set; }
        public string FlowName { get; set; }
        public string Material { get; set; }
        public BoundingShape Shape { get; set; }
        public ModelCfg ModelCfg { get; } = new ModelCfg();
        public CreatureType CreatureType { get; set; } = CreatureType.None;
        
        public ActorCreateCfg Copy()
        {
            var createCfg = new ActorCreateCfg
            {
                IsPlayer = IsPlayer,
                FlowName = FlowName,
                Material = Material,
                CreatureType = CreatureType,
            };
            if (null != Shape)
            {
                createCfg.Shape = ObjectPoolUtility.BoundingShapePool.Get();
                createCfg.Shape.CopyFrom(Shape);
            }

            createCfg.ModelCfg.CopyFrom(ModelCfg);
            return createCfg;
        }

        public void Reset()
        {
            if (null != Shape) ObjectPoolUtility.BoundingShapePool.Release(Shape);
            IsPlayer = false;
            FlowName = null;
            Shape = null;
            Material = null;
            CreatureType = CreatureType.None;
            ModelCfg.Reset();
        }

        public override bool Equals(object obj)
        {
            return this == obj;
        }

        public static bool operator !=(ActorCreateCfg objA, ActorCreateCfg objB)
        {
            return !(objA == objB);
        }

        public static bool operator ==(ActorCreateCfg objA, ActorCreateCfg objB)
        {
            if (objA is null)
            {
                return objB is null;
            }

            if (objB is null)
            {
                return false;
            }

            return objA.IsPlayer == objB.IsPlayer 
                   &&  objA.FlowName == objB.FlowName 
                   &&  objA.Material == objB.Material 
                    && objA.CreatureType == objB.CreatureType
                   &&  objA.Shape == objB.Shape 
                   && objA.ModelCfg == objB.ModelCfg;
        }
    }

    public class ActorBornCfg : IReset
    {
        public ActorCreateCfg CreateCfg { get; } = new ActorCreateCfg();
        public ModelCfg ModelInfo => CreateCfg.ModelCfg;
        public BoundingShape Shape { get => CreateCfg.Shape; set => CreateCfg.Shape = value; }
        public CreatureType CreatureType { get => CreateCfg.CreatureType; set => CreateCfg.CreatureType = value; }
        public string Material { set => CreateCfg.Material = value; }
        public string Name { get => ModelInfo.Name; set => ModelInfo.Name = value; }
        public string AnimatorCtrlName { set => ModelInfo.AnimatorCtrlName = value; }
        public List<int> CommonEffect => ModelInfo.CommonEffect;
        
        public int InsID { get; set; }
        public int CfgID { get; set; }
        public int SpawnID { get; set; }
        public int GroupID { get; set; } = -1;
        public int PropertyID { get; set; }
        public int Level { get; set; }
        public float LifeTime { get; set; } = -1;
        public Vector3 Position { get; set; }
        public Vector3 Forward { get; set; }
        public Actor Master { get; set; }
        public Dictionary<AttrType, float> Attrs { get; } = new Dictionary<AttrType, float>(40,new AttrUtil.AttrTypeComparer());
        public FactionType FactionType { get; set; }
        public int SkinID { get; set; }
        public int BornActionModule { get; set; }
        public int DeadActionModule { get; set; }
        public int HurtLieDeadActionModule { get; set; }
        public bool IsShowArrowIcon { get; set; }
        public bool SkipBornActionModule { get; set; }
        /// <summary> 控制出生表演的逻辑
        /// 1. 决定了出生动作模组的镜头播不播放
        /// 2. 决定了出生技能的镜头播不播放
        /// 3. 决定了播放出生动作模组时给表演的角色加不可锁定标签, 给男女主加无敌Buff.
        /// 4. 决定了出生动作模组里的音效是否播放.
        /// 5. 决定了动作模组Action【怪物出生UI和输入处理】的逻辑是否执行.
        /// 6. 决定了动作模组Action【怪物出生时间缩放】的逻辑是否执行.
        /// 7. 决定了动作模组Action【怪物出生TipUI】的逻辑是否执行.
        /// 8. 决定了动作模组Action【出生将Actor传送至关卡位置】的逻辑是否执行.
        /// 9. 决定了动作模组Action【打断音频】的逻辑是否执行.
        /// </summary>
        public bool ControlBornPerform { get; set; }
        /// <summary> 是否随主人一起死亡 </summary>
        public bool DeadWithMaster { get; set; }
        /// <summary> 出生时是否继承主人的仇恨目标</summary>
        public bool InheritHatred { get; set; }
        /// <summary> 出生时要添加的buff </summary>
        public List<BuffData> BuffDatas { get; set; }
        /// <summary> 是否启用被锁定(BattleSummon.EnableBeLocked) </summary>
        public bool EnableBeLocked { get; set; } = true;
        /// <summary> 召唤配置ID </summary>
        public int SummonID { get; set; }

        /// <summary> 实时继承master属性 </summary>
        public bool RealTimeInherit { get; set; } = false;

        public bool IsGirl()
        {
            return TbUtil.GetGirlCfg(CfgID) != null;
        }
        public bool IsBoy()
        {
            return TbUtil.GetBoyCfg(CfgID) != null;
        }

        public virtual void Reset()
        {
            CreateCfg.Reset();
            InsID = 0;
            CfgID = 0;
            SpawnID = 0;
            GroupID = -1;
            PropertyID = 0;
            Level = 0;
            LifeTime = -1;
            Master = null;
            Attrs.Clear();
            SkinID = 0;
            BornActionModule = 0;
            SkipBornActionModule = false;
            DeadActionModule = 0;
            HurtLieDeadActionModule = 0;
            CreatureType = CreatureType.None;
            ControlBornPerform = false;
            DeadWithMaster = true;
            EnableBeLocked = true;
            SummonID = 0;
            RealTimeInherit = false;
        }
    }

    public class RoleBornCfg : ActorBornCfg
    {
        public int SuitID { get => CreateCfg.ModelCfg.SuitID; set => CreateCfg.ModelCfg.SuitID = value; }
        public bool IsPlayer { get => CreateCfg.IsPlayer; set => CreateCfg.IsPlayer = value; }
        public bool IsAIActive { get; set; } = true;
        public ActorAIStatus AIStatus { get; set; }

        public bool MonsterHudControl { get; set; }
        public bool MonsterHudIsTop { get; set; }
        public bool MonsterHudIsHead { get; set; }
        public bool EnableBossCamera { get; set; }

        public Dictionary<int, SkillSlotConfig> SkillSlots { get; set; }
        /// <summary> 出生时, 是否自动释放被动技能 </summary>
        public bool AutoCastPassiveSkill { get; set; } = true;
        public bool AutoStartSkillCD { get; set; } = true;
        public bool AutoStartEnergy { get; set; } = true;
        public bool AutoStartAI { get; set; } = true;
        
        //交互物组件相关
        public InterActorState interActorState { get; set; }//交互物交互状态
        public int InterActorModelCfgId { get; set; }//交互物模型ID
        public string InterActorDesc { get; set; }//交互物描述
        public int InterActorId { get; set; }//关卡编辑器交互物页签ID
        public int InterActorComponentId { get; set; }//交互物组件ID
        public override void Reset()
        {
            base.Reset();
            IsPlayer = false;
            IsAIActive = true;
            AIStatus = ActorAIStatus.None;
            MonsterHudControl = false;
            MonsterHudIsTop = false;
            MonsterHudIsHead = false;
            SkillSlots = null;
            AutoCastPassiveSkill = true;
            AutoStartSkillCD = true;
            AutoStartEnergy = true;
            AutoStartAI = true;
        }
    }

    public class ItemBornCfg : ActorBornCfg
    {
        public DamageExporter damageExporter;
    }

    public class MachineBornCfg : ActorBornCfg
    {
        public string FlowName { get => CreateCfg.FlowName; set => CreateCfg.FlowName = value; }
        public MachineType MachineType;
        public int State;

        public override void Reset()
        {
            base.Reset();
            MachineType = MachineType.None;
            State = 0;
        }
    }

    public class TriggerAreaBornCfg : ActorBornCfg
    {
        public TriggerAreaConfig AreaCfg { get; set; }

        public override void Reset()
        {
            base.Reset();
            AreaCfg = null;
        }
    }

    public class ObstacleBornCfg : ActorBornCfg
    {
        public ObstacleConfig ObstacleConfig { get; set; }

        public override void Reset()
        {
            base.Reset();
            ObstacleConfig = null;
        }
    }

    public class SkillAgentBornCfg : ActorBornCfg
    {
        public DamageExporter MasterExporter { get; set; }
        public float SuspendTime { get; set; }
        public int[] DamageBoxIDs { get; set; }
        public SkillAgentType SubType { get; set; }

        public override void Reset()
        {
            base.Reset();
            MasterExporter = null;
            SuspendTime = 0;
            DamageBoxIDs = null;
        }
    }

    public class StageBornCfg : RoleBornCfg
    {
    }
}