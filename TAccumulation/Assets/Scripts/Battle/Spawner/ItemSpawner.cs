using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class ItemSpawner : ActorSpawner
    {
        private Dictionary<int, ActorCfg> _itemCfgs = new Dictionary<int, ActorCfg>();

        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorModel),
            typeof(AttributeOwner),
            typeof(ActorSequencePlayer),
            typeof(SkillOwner),
            typeof(ActorItem),
            typeof(ActorEffectPlayer)
        };

        public ItemSpawner(Battle battle) : base(battle)
        {
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            if (null == bornCfg)
            {
                return null;
            }

            if (_itemCfgs.TryGetValue(bornCfg.CfgID, out var actorCfg))
            {
                return actorCfg;
            }
            ItemCfg itemCfg = TbUtil.GetCfg<ItemCfg>(bornCfg.CfgID);
            actorCfg = new ActorCfg
            {
                ID = bornCfg.CfgID,
                Type = ActorType.Item,
                Name = bornCfg.Name,
                IconName = itemCfg.IconName,
            };
            _itemCfgs.Add(actorCfg.ID, actorCfg);
            return actorCfg;
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            if (!(pointCfg is ItemPointData itemPointData))
            {
                return null;
            }

            var bornCfg = ObjectPoolUtility.GetActorBornCfg<ItemBornCfg>();
            bornCfg.Name = itemPointData.Name;
            bornCfg.Master = itemPointData.Master;
            bornCfg.damageExporter = itemPointData.damageExporter;
            bornCfg.FactionType = itemPointData.FactionType;
            bornCfg.Level = itemPointData.Level;
            bornCfg.CfgID = itemPointData.ConfigID;
            bornCfg.SpawnID = itemPointData.ID;
            bornCfg.Position = itemPointData.Position;
            bornCfg.Forward = Quaternion.Euler(itemPointData.Rotation) * Vector3.forward;
            bornCfg.SkinID = bornCfg.Master.bornCfg.SkinID;
            bornCfg.IsShowArrowIcon = itemPointData.IsShowArrowIcon;
            return bornCfg as T;
        }
    }
}
