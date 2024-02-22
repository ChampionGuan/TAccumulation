using System;
using UnityEngine;

namespace X3Battle
{
    public class ActorObstacle : ActorComponent
    {
        private X3ActorCollider _x3ActorCollider;
        private Collider _collider;
        public X3ActorCollider x3ActorCollider => _x3ActorCollider; 
        
        public ActorObstacle() : base(ActorComponentType.Obstacle)
        {
        }

        protected override void OnAwake()
        {
            Transform modelTrans = actor.GetDummy();
            _x3ActorCollider =  BattleUtil.EnsureComponent<X3ActorCollider>(modelTrans.gameObject);
            _x3ActorCollider.Init(actor, ColliderType.Collider, actor.createCfg.Shape);
            
            GameObject cameraObj = new GameObject("cameraObj");
            cameraObj.transform.SetParent(modelTrans);
            cameraObj.layer = LayerMask.NameToLayer("CameraCollider");
            _collider = _InitCollider(cameraObj, actor.createCfg.Shape);
            _collider.enabled = false;
            _x3ActorCollider.tag = ColliderTag.AirWall;
        }
        
        private Collider _InitCollider(GameObject obj, BoundingShape shape)
        {
            X3Physics.CheckShapeValid(shape);
            switch (shape.ShapeType)
            {
                case ShapeType.Capsule:
                    var capsuleCollider = BattleUtil.EnsureComponent<CapsuleCollider>(obj);
                    capsuleCollider.radius = shape.Radius;
                    capsuleCollider.height = shape.Height;
                    return capsuleCollider;
                case ShapeType.Cube:
                    var boxCollider = BattleUtil.EnsureComponent<BoxCollider>(obj);
                    boxCollider.size = new Vector3(shape.Length, shape.Height, shape.Width);
                    return boxCollider;
                case ShapeType.Sphere:
                    var sphereCollider = BattleUtil.EnsureComponent<SphereCollider>(obj);
                    sphereCollider.radius = shape.Radius;
                    return sphereCollider;
                default:
                    PapeGames.X3.LogProxy.LogErrorFormat("Root collider不支持ShapeType:{0},暂时使用BoxCollider代替，请使用合适的类型", type);
                    return BattleUtil.EnsureComponent<BoxCollider>(obj);
            }
        }
        
        public override void OnBorn()
        {
            if (actor.bornCfg is ObstacleBornCfg)
            {
                _x3ActorCollider.flags = (actor.bornCfg as ObstacleBornCfg).ObstacleConfig.Flags;
            }
            Enable(true);
        }

        public void Enable(bool enabled)
        {
            _x3ActorCollider.Enable(enabled);
            _collider.enabled = enabled;
            Physics.SyncTransforms();
        }

        public override void OnRecycle()
        {
            Enable(false);
        }

        protected override void OnDestroy()
        {
            _x3ActorCollider = null;
            _collider = null;
        }
    }
}