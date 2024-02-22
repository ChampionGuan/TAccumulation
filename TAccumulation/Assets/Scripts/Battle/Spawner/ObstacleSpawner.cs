using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class ObstacleSpawner : ActorSpawner
    {
        private Dictionary<int, ActorCfg> _obstacleCfgs = new Dictionary<int, ActorCfg>();

        public override List<Type> requiredComponents { get; protected set; } = new List<Type>
        {
            typeof(ActorModel),
            typeof(ActorObstacle),
            typeof(ActorEffectPlayer)
        };

        public ObstacleSpawner(Battle battle) : base(battle)
        {
        }

        public override ActorCfg CreateActorCfg(ActorBornCfg bornCfg, int? actorCfgID = null)
        {
            if (null == bornCfg)
            {
                return null;
            }

            if (_obstacleCfgs.TryGetValue(bornCfg.CfgID, out var cfg)) return cfg;

            cfg = new ActorCfg
            {
                ID = bornCfg.CfgID,
                Type = ActorType.Obstacle,
                Name = bornCfg.Name,
            };
            cfg.CommonEffect.AddRange(bornCfg.CommonEffect);

            _obstacleCfgs.Add(cfg.ID, cfg);
            return cfg;
        }

        public override T CreateActorBornCfg<T>(PointBase pointCfg)
        {
            if (!(pointCfg is ObstacleConfig obstacleConfig))
            {
                return null;
            }

            var bornCfg = ObjectPoolUtility.GetActorBornCfg<ObstacleBornCfg>();
            bornCfg.Shape = ObjectPoolUtility.BoundingShapePool.Get();
            bornCfg.Shape.ShapeType = obstacleConfig.ObstacleShape;
            bornCfg.Shape.Length = obstacleConfig.Length;
            bornCfg.Shape.Width = obstacleConfig.Width;
            bornCfg.Shape.Height = obstacleConfig.Height;
            bornCfg.Shape.Radius = obstacleConfig.Radius;

            bornCfg.CfgID = pointCfg.ID;
            bornCfg.SpawnID = obstacleConfig.ID;
            bornCfg.FactionType = FactionType.Machine;
            bornCfg.Position = obstacleConfig.Position;
            bornCfg.Forward = Quaternion.Euler(obstacleConfig.Rotation) * Vector3.forward;
            bornCfg.Name = obstacleConfig.Name;
            bornCfg.LifeTime = obstacleConfig.Duration;
            bornCfg.CommonEffect.Add(obstacleConfig.FxID);
            bornCfg.ObstacleConfig = obstacleConfig;
            return bornCfg as T;
        }
    }
}