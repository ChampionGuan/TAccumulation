using System;
using CollisionQuery;
using EasyCharacterMovement;
using Framework;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Battle
{
    public class X3ActorCollider : X3Collider
    {
        private bool _isCharacterCtrl;
        public Actor actor;
        public BoundingShape shape;
        public bool IsCharacterCtrl => _isCharacterCtrl;
        public CharacterMovement CharacterMovement => actor.transform.characterMove;

        public Action<CqCollider> onTriggerEnter;
        public Action<CqCollider> onTriggerExit;
        
        protected override void OnDestroy()
        {
            if(_collider != null)
            {
                _collider.TriggerEnterHandle -= OnCqTriggerEnter;
                _collider.TriggerExitHandle -= OnCqTriggerExit;
                X3Physics.Collision.RemoveCollider(_collider);
            }
            X3Physics.UnCacheX3Collider(this);
            ClearAction();
        }
        
        public void Init(Actor actor, ColliderType type, BoundingShape shape)
        {
            this.actor = actor;
            this.shape = shape;
            _collider = InitCollider(gameObject, shape);
            _collider.TriggerEnterHandle += OnCqTriggerEnter;
            _collider.TriggerExitHandle += OnCqTriggerExit;
            _isCharacterCtrl = false;
            _flags = CollisionBehavior.Default;
            if (shape is ActorBoundingShape actorBoundingShape)
            {
                _isCharacterCtrl = actorBoundingShape.isCharacterCtrl;
                _flags = actorBoundingShape.flags;
            }
            InitColliderType(type, _isCharacterCtrl);
            _tag = ColliderTag.Actor;
            Enable(true);
            X3Physics.CacheX3Collider(this);
            ClearAction();
        }
        
        public static CqCollider InitCollider(GameObject obj, BoundingShape shape)
        {
            X3Physics.CheckShapeValid(shape);
            var actorShape = shape as ActorBoundingShape;
            if (actorShape != null && actorShape.isCharacterCtrl)
            {
                var characterMovement = BattleUtil.EnsureComponent<CharacterMovement>(obj);
                var collider = characterMovement.collider;
                X3Physics.Collision.AddCollider(collider);
                characterMovement.radius = shape.Radius;
                characterMovement.height = shape.Height;
                characterMovement.center = shape.Offset;
                characterMovement.direction = actorShape.direction;

                shape.ShapeType = ShapeType.Capsule;
                return collider;
            }
            ShapeType type = shape.ShapeType;
            switch (type)
            {
                case ShapeType.Capsule:
                    var capsuleCollider = BattleUtil.EnsureComponent<CqCapsuleCollider>(obj);
                    capsuleCollider.Radius = shape.Radius;
                    capsuleCollider.Height = shape.Height;
                    X3Physics.Collision.AddCollider(capsuleCollider);
                    return capsuleCollider;
                    break;
                case ShapeType.Cube:
                    var boxCollider = BattleUtil.EnsureComponent<CqBoxCollider>(obj);
                    boxCollider.Size = new Vector3(shape.Length, shape.Height, shape.Width);
                    X3Physics.Collision.AddCollider(boxCollider);
                    return boxCollider;
                    break;
                case ShapeType.Sphere:
                    var sphereCollider = BattleUtil.EnsureComponent<CqSphereCollider>(obj);
                    sphereCollider.Radius = shape.Radius;
                    X3Physics.Collision.AddCollider(sphereCollider);
                    return sphereCollider;
                    break;
                default:
                    boxCollider = BattleUtil.EnsureComponent<CqBoxCollider>(obj);
                    X3Physics.Collision.AddCollider(boxCollider);
                    PapeGames.X3.LogProxy.LogErrorFormat("Root collider不支持ShapeType:{0},暂时使用BoxCollider代替，请使用合适的类型", type);
                    return boxCollider;
            }
        }
        
        private void ClearAction()
        {
            onTriggerEnter = null;
            onTriggerExit = null;
        }
        
        private void TryInvokeAction(Action<CqCollider> action, CqCollider collider)
        {
            if (action == null)
                return;
            action.Invoke(collider);
        }

        public void OnCqTriggerEnter(CqCollider other)
        {
            TryInvokeAction(onTriggerEnter, other);
        }

        private void OnCqTriggerExit(CqCollider other)
        {
            TryInvokeAction(onTriggerExit, other);
        }
    }
}