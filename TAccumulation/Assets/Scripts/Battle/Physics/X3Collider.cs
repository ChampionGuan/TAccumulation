using System;
using CollisionQuery;
using EasyCharacterMovement;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Battle
{
    public class X3Collider : MonoBehaviour
    {
        [Tooltip(CharacterMoveConst.CollisionBehaviorTips),SerializeField]
        protected CollisionBehavior _flags;
        [SerializeField]
        protected ColliderTag _tag;

        //protected Collider _collider;
        //public Collider collider => _collider;

        protected CqCollider _collider;
        public CqCollider Collider => _collider;
        public int IncludeLayerMask => _collider.IncludeLayers;
        public int ExcludeLayerMask => _collider.ExcludeLayers;

        public CollisionBehavior flags
        {
            get => _flags;
            set => _flags = value;
        }
        public ColliderTag tag
        {
            get => _tag;
            set => _tag = value;
        }
        public ColliderType type;

        protected virtual void OnDestroy()
        {
        }
        
        public void OnEnable()
        {
            Enable(true);
        }

        public void OnDisable()
        {
            Enable(false);
        }

        public void Init(CqCollider collider, ColliderType type)
        {
            _collider = collider;
            _flags = CollisionBehavior.Default;
            _tag = ColliderTag.Default;
            InitColliderType(type);
            Enable(true);
            X3Physics.CacheX3Collider(this);
        }

        public void Enable(bool isEnable)
        {
            if (_collider == null)
                return;
            enabled = isEnable;
            _collider.enabled = isEnable;
            if (!isEnable)
            {
                X3Physics.Collision.RemoveCollider(_collider);
            }
            else
            {
                X3Physics.Collision.AddCollider(_collider);
            }
        }
        
        public void IncludeLayers(bool add, int layer)
        {
            if (add)
            {
                int curLayerMask = _collider.IncludeLayers;
                curLayerMask = curLayerMask | 1 << layer;
                _collider.IncludeLayers = curLayerMask;
            }
            else
            {
                int curLayerMask = _collider.IncludeLayers;
                curLayerMask = curLayerMask & ~(1 << layer);
                _collider.IncludeLayers = curLayerMask;
            }
        }
        
        public void ExcludeLayers(bool add, int layer)
        {
            if (add)
            {
                int curLayerMask = _collider.ExcludeLayers;
                curLayerMask = curLayerMask | 1 << layer;
                _collider.ExcludeLayers = curLayerMask;
            }
            else
            {
                int curLayerMask = _collider.ExcludeLayers;
                curLayerMask = curLayerMask & ~(1 << layer);
                _collider.ExcludeLayers = curLayerMask;
            }
        }
        
        protected virtual void InitColliderType(ColliderType type, bool isHaveCharacterMovement = false)
        {
            this.type = type;
            switch (this.type)
            {
                case ColliderType.Collider:
                    gameObject.layer = X3Layer.ActorCollider;
                    break;
                case ColliderType.HurtBox:
                    gameObject.layer = X3Layer.HurtBox;
                    break;
                case ColliderType.Trigger:
                    gameObject.layer = X3Layer.Trigger;
                    _collider.isTrigger = true;
                    break;
                case ColliderType.Ground:
                    gameObject.layer = X3Layer.Ground;
                    break;
                case ColliderType.IgnoreCollision:
                    gameObject.layer = X3Layer.IgnoreCollision;
                    break;
                default:
                    PapeGames.X3.LogProxy.LogErrorFormat("不支持的colliderType:{0}", type);
                    break;
            }

            _collider.Layer = gameObject.layer;
        }
        
       
    }
}