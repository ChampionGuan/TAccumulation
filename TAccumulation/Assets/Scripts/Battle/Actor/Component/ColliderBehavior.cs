using System;
using System.Collections.Generic;
using EasyCharacterMovement;
using PapeGames.X3;
using UnityEngine;
using CollisionQuery;

namespace X3Battle
{
    public class ColliderBehavior : ActorComponent
    {
        private CharacterMovement _characterMovement;
        private Dictionary<ColliderType, Dictionary<string, X3ActorCollider>> _allColliders;
        private bool _isColliderActive;
        private ColliderFilterCallback _colliderFilterCallback;
        private CollisionBehaviorCallback _collisionBehaviorCallback;
        private Action<EventStateTagChangeBase> _actionOnCollisionIgnore;
        private Action<EventStateTagChangeBase> _actionOnLogicTestIgnore;

        public Dictionary<ColliderType, Dictionary<string, X3ActorCollider>> colliders => _allColliders;
        public CharacterMovement characterMovement => _characterMovement;

        public bool isColliderActive
        {
            get => _isColliderActive;
            set => SetColliderActive(value, ColliderType.Collider);
        }

        public ColliderBehavior() : base(ActorComponentType.Collider)
        {
            _allColliders = new Dictionary<ColliderType, Dictionary<string, X3ActorCollider>>();
            _isColliderActive = true;
            _colliderFilterCallback = OnFilterWhenIgnoreCollision;
            _collisionBehaviorCallback = OnCollisionBehaviorCallback;
            _actionOnCollisionIgnore = OnCollisionIgnore;
            _actionOnLogicTestIgnore = OnLogicTestIgnore;
        }

        protected override void OnAwake()
        {
            var modelInfo = actor.modelInfo;
            // 初始化CharacterController
            if (modelInfo.characterCtrl != null)
            {
                X3ActorCollider x3ActorCollider = AddCollider(ColliderType.Collider, modelInfo.characterCtrl, modelInfo.characterCtrl.dummyName);
                if (x3ActorCollider.IsCharacterCtrl)
                {
                    // TODO 这里使用Get接口更合适，目前还没该接口
                    _characterMovement = actor.EnsureComponent<CharacterMovement>();
                }

                LogProxy.LogFormat("Actor：{0}添加CharacterMovement组件", actor.config.Name + actor.config.ID);
            }

            // 初始化collider
            foreach (var shape in modelInfo.colliders)
            {
                X3ActorCollider x3ActorCollider = AddCollider(ColliderType.Collider, shape, shape.dummyName);
                // 新版物理需要， 把碰撞器和刚体绑定到一起，用于CC的碰撞检测
                // 其它层的Collider无需碰撞检测，所有也无需绑定刚体
                if (_characterMovement)
                    _characterMovement.rigidActor.AttachCollider(x3ActorCollider.Collider);
            }

            // 初始化hurtBox
            foreach (var shape in modelInfo.hurtBoxs)
            {
                X3ActorCollider x3ActorCollider = AddCollider(ColliderType.HurtBox, shape, shape.dummyName);
                if (_characterMovement)
                    _characterMovement.rigidActor.AttachCollider(x3ActorCollider.Collider);
            }

            if (actor.type == ActorType.TriggerArea && actor.createCfg.Shape != null)
            {
                AddCollider(ColliderType.Trigger, actor.createCfg.Shape, ActorDummyType.Root);
            }

            InitIgnoreCollider();
            if (_characterMovement)
                _characterMovement.collisionBehaviorCallback = _collisionBehaviorCallback;
        }

        protected override void OnDestroy()
        {
            if (_characterMovement)
            {
                _characterMovement.colliderFilterCallback = null;
                _characterMovement.collisionBehaviorCallback = null;
            }

            foreach (var item in _allColliders)
            {
                item.Value.Clear();
            }
        }

        public override void OnBorn()
        {
            SetColliderActive(true, ColliderType.Collider);
            SetColliderActive(true, ColliderType.HurtBox);
            SetColliderActive(true, ColliderType.Trigger);
            actor.eventMgr.AddListener(EventType.CollisionIgnoreStateTagChange, _actionOnCollisionIgnore, "ColliderBehavior.OnCollisionIgnore");
            actor.eventMgr.AddListener(EventType.LogicTestIgnoreStateTagChange, _actionOnLogicTestIgnore, "ColliderBehavior.OnLogicTestIgnore");
        }

        public override void OnDead()
        {
            SetColliderActive(false, ColliderType.HurtBox);
            SetColliderActive(false, ColliderType.Trigger);
        }
        
        public override void OnRecycle()
        {
            actor.eventMgr.RemoveListener(EventType.CollisionIgnoreStateTagChange, _actionOnCollisionIgnore);
            actor.eventMgr.RemoveListener(EventType.LogicTestIgnoreStateTagChange, _actionOnLogicTestIgnore);
            SetColliderActive(false, ColliderType.Collider);
        }

        public X3ActorCollider GetColliderMono(ColliderType type, string dummy = ActorDummyType.Root)
        {
            Dictionary<string, X3ActorCollider> dic;
            if (_allColliders.TryGetValue(type, out dic))
            {
                if (_allColliders[type].ContainsKey(dummy))
                {
                    return _allColliders[type][dummy];
                }
            }

            LogProxy.LogWarningFormat("Actor:{0} 骨骼：{1} 没有类型为：{2}的collider", actor.config.Name, dummy, type);
            return null;
        }

        public bool HaveColliderType(ColliderType type)
        {
            if (_allColliders.TryGetValue(type, out var dic))
            {
                return _allColliders[type].Count > 0;
            }
            return false;
        }
        
        // dummy 不传时，会添加到actor根对象上
        public X3ActorCollider AddCollider(ColliderType type, BoundingShape shape, string dummy)
        {
            bool isNeedCreateObj = !dummy.Equals(ActorDummyType.Root);
            Transform bone = actor.GetDummy(dummy);
            X3ActorCollider x3ActorCollider = null;
            if (isNeedCreateObj)
            {
                // 挂点上addChild,在child上重新挂载一个collider
                string name = (shape is ActorBoundingShape) ? (shape as ActorBoundingShape).name : type.ToString();
                GameObject obj = new GameObject(name, typeof(X3ActorCollider));
                obj.transform.SetParent(bone, false);
                obj.transform.localPosition = shape.Offset;
                obj.transform.localEulerAngles = shape.Rotation;
                x3ActorCollider = obj.GetComponent<X3ActorCollider>();
            }
            else
            {
                x3ActorCollider = BattleUtil.EnsureComponent<X3ActorCollider>(bone.gameObject);
            }
            x3ActorCollider.Init(actor, type, shape);
            
            // cache
            if (!_allColliders.TryGetValue(type, out var dic))
            {
                _allColliders[type] = new Dictionary<string, X3ActorCollider>();
            }

            _allColliders[type][dummy] = x3ActorCollider;
            return x3ActorCollider;
        }

        private void SetColliderActive(bool isActive, ColliderType type)
        {
            if (_allColliders.TryGetValue(type, out var colliders))
            {
                foreach (var item in colliders)
                {
                    item.Value.Enable(isActive);
                }
            }

            if (type == ColliderType.Collider)
            {
                _isColliderActive = isActive;
            }
        }

        private void OnCollisionIgnore(EventStateTagChangeBase arg)
        {
            // 忽略碰撞，不通过开关Collider完成。通过CC识别Collider的ExcludeLayer是否有 colliderLayer完成
            if (_allColliders.TryGetValue(ColliderType.Collider, out var colliders))
            {
                foreach (var item in colliders)
                {
                    item.Value.ExcludeLayers(arg.active, X3Layer.ActorCollider);
                }
            }
            if (arg.active)
            {
                if (_characterMovement)
                    _characterMovement.colliderFilterCallback = _colliderFilterCallback;
            }
            else
            {
                if (_characterMovement)
                    _characterMovement.colliderFilterCallback = null;
            }
        }

        private void OnLogicTestIgnore(EventStateTagChangeBase arg)
        {
            // 忽略逻辑检测，通过设置设置ExcludeLayer，使得角色上的碰撞器不会触发trigger，从而不会触发逻辑检测
            if (_allColliders.TryGetValue(ColliderType.Collider, out var colliders))
            {
                foreach (var item in colliders)
                {
                    item.Value.ExcludeLayers(arg.active, X3Layer.Trigger);
                }
            }
        }

        private void InitIgnoreCollider()
        {
            if (_characterMovement == null)
                return;
            if (_allColliders.TryGetValue(ColliderType.Collider, out var colliders))
            {
                foreach (var item in colliders)
                {
                    var colliderMono = item.Value;
                    _characterMovement.IgnoreCollision(colliderMono.Collider);
                }
            }
        }

        private CollisionBehavior OnCollisionBehaviorCallback(CqCollider collider)
        {
            var colliderMono = X3Physics.GetX3Collider(collider);
            if (colliderMono)
            {
                return colliderMono.flags;
            }

            return CollisionBehavior.Default;
        }

        /// <summary>
        /// collider 关闭时，actor移动时需要过滤掉的Collider
        /// 过滤掉所有的Actor身上的Collider
        /// 场景中的静态Collider不过滤
        /// </summary>
        /// <param name="otherCollider">需要识别的Collider</param>
        /// <returns>true:忽略</returns>
        private bool OnFilterWhenIgnoreCollision(CqCollider otherCollider)
        {
            if (ReferenceEquals(otherCollider, null))
                return false;
            var x3Collider = X3Physics.GetX3Collider(otherCollider);
            var actorCollider = x3Collider as X3ActorCollider;
            if (ReferenceEquals(actorCollider, null))
                return false;
            if (X3Physics.IsHaveBehaviourFlag(actorCollider, CollisionBehavior.CanNotFilterWhenIgnoreCollision))
                return false; // 是否配置过不可过滤
            if (!ReferenceEquals(actorCollider.actor, null))
                return true; // 过滤Actor上的Collider
            return false;
        }
    }
}
