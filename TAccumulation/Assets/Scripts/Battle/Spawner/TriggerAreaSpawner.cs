using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class TriggerAreaSpawner : ActorSpawner
    {
        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorModel),
            typeof(ColliderBehavior),
            typeof(ActorStateTag),
            typeof(TargetSelector),
            typeof(TriggerArea),
            typeof(ActorEffectPlayer)
        };

        public TriggerAreaSpawner(Battle battle) : base(battle)
        {
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            if (null == bornCfg)
            {
                return null;
            }

            var actorCfg = new ActorCfg
            {
                ID = bornCfg.CfgID,
                Type = ActorType.TriggerArea,
                Name = bornCfg.Name,
            };
            actorCfg.CommonEffect.AddRange(bornCfg.CommonEffect);

            return actorCfg;
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            if (!(pointCfg is TriggerAreaConfig triggerAreaConfig))
            {
                return null;
            }

            var bornCfg = ObjectPoolUtility.GetActorBornCfg<TriggerAreaBornCfg>();
            bornCfg.Shape = ObjectPoolUtility.BoundingShapePool.Get();
            bornCfg.Shape.ShapeType = triggerAreaConfig.TriggerShape == TriggerShape.Sphere ? ShapeType.Sphere : ShapeType.Cube;
            bornCfg.Shape.Length = triggerAreaConfig.Length;
            bornCfg.Shape.Width = triggerAreaConfig.Width;
            bornCfg.Shape.Height = triggerAreaConfig.Height;
            bornCfg.Shape.Radius = triggerAreaConfig.Radius;

            bornCfg.CfgID = pointCfg.ID;
            bornCfg.SpawnID = triggerAreaConfig.ID;
            bornCfg.FactionType = FactionType.Machine;
            bornCfg.Position = triggerAreaConfig.Position;
            bornCfg.Forward = Quaternion.Euler(triggerAreaConfig.Rotation) * Vector3.forward;
            bornCfg.Name = triggerAreaConfig.Name;
            bornCfg.CommonEffect.Add(triggerAreaConfig.FxID);
            bornCfg.AreaCfg = triggerAreaConfig;
            return bornCfg as T;
        }
    }
}
