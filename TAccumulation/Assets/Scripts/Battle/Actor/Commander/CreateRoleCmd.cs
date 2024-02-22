using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class CreateRoleCmd : ActorCmd
    {
        [Key(0)] public int actorId;
        [Key(1)] public int suitId;
        [Key(2)] public bool ai;
        [Key(3)] public Vector3 position;
        [Key(4)] public FactionType factionType;
        [Key(5)] public int spawnID;
        [Key(6)] public bool bornProcess;
        [Key(7)] public bool bornCamera;

        public CreateRoleCmd()
        {
        }

        public CreateRoleCmd(int actorId, int suitId, Vector3 position, bool ai, FactionType factionType, int spawnID, bool bornProcess, bool bornCamera)
        {
            this.actorId = actorId;
            this.suitId = suitId;
            this.ai = ai;
            this.position = position;
            this.factionType = factionType;
            this.spawnID = spawnID;
            this.bornProcess = bornProcess;
            this.bornCamera = bornCamera;
        }

        protected override void _OnEnter()
        {
            if (!TbUtil.TryGetCfg(actorId,out ActorCfg roleCfg))
            {
                return;
            }
            bool isExistActor = false;
            foreach (var actor in Battle.Instance.actorMgr.actors)
            {
                if (actor.config.ID == roleCfg.ID)
                {
                    isExistActor = true;
                    break;
                }
            }

            var actorMgr = Battle.Instance.actorMgr;
            
            // var stagePointCfg = actorMgr.stageConfig.Points[0];
            // var stageSpawnPointCfg = actorMgr.stageConfig.SpawnPoints[0];
            ActorPointBase pointCfg = null;
            if (roleCfg.Type == ActorType.Monster)
            {
                pointCfg =  new SpawnPointConfig();
            }
            else
            {
                pointCfg = new PointConfig();
            }


            //赋值指定参数
            pointCfg.ID = spawnID;
            pointCfg.ConfigID = actorId;
            pointCfg.Position = position;
            pointCfg.FactionType = factionType;
            pointCfg.PropertyID = 4;
            
            //调用私有方法获取bornCfg
            ActorBornCfg bornCfg = null;
            var methodInfo = actorMgr.GetType().GetMethod("_CreateBornCfg",
                System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance, null,
                System.Reflection.CallingConventions.Any, new Type[] { typeof(ActorType), typeof(PointBase) }, null);
            if (methodInfo != null)
            {
                methodInfo = methodInfo.MakeGenericMethod(typeof(ActorBornCfg));
                bornCfg = methodInfo.Invoke(actorMgr, new object[2] { roleCfg.Type, pointCfg }) as ActorBornCfg;
            }

            bornCfg.SkipBornActionModule = !bornProcess;
            bornCfg.ControlBornPerform = bornCamera;
            
            //目前直接用女主的数值，因为gm指令创建的怪没有配数值
            RoleBornCfg roleBornCfg = actorMgr.player.roleBornCfg;
            if (roleBornCfg == null)
            {
                return;
            }
            foreach (var attr in roleBornCfg.Attrs)
            {
                if (!bornCfg.Attrs.ContainsKey(attr.Key))
                {
                    bornCfg.Attrs.Add(attr.Key, attr.Value);
                }
            }
            //策划临时要求设置的属性
            bornCfg.Attrs[AttrType.ShieldRecoverTime] = 10f;

            Actor targetActor = Battle.Instance.actorMgr.CreateActor(roleCfg.Type,bornCfg);
            targetActor.aiOwner?.DisableAI(!ai, AISwitchType.Debug);
            targetActor.aiOwner?.SetIsStrategy(ai);
            // if (!ai)
            // {
            //     targetActor.commander?.ClearMoveCmd();
            // }
        }
    }
}