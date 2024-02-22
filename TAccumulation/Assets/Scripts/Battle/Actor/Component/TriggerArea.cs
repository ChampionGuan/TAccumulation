using System;
using System.Collections.Generic;
using CollisionQuery;
using UnityEngine;

namespace X3Battle
{
    public class TriggerArea : ActorComponent
    {
        private X3ActorCollider _x3ActorCollider;
        public X3ActorCollider x3ActorCollider => _x3ActorCollider;

        private Action<CqCollider> _actionOnTriggerEnter;
        private Action<CqCollider> _actionOnTriggerExit;

        public TriggerArea() : base(ActorComponentType.TriggerArea)
        {
            _actionOnTriggerEnter = _OnTriggerEnter;
            _actionOnTriggerExit = _OnTriggerExit;
        }

        public override void OnBorn()
        {
            _x3ActorCollider = actor.collider.GetColliderMono(ColliderType.Trigger);
            _x3ActorCollider.onTriggerEnter += _actionOnTriggerEnter;
            _x3ActorCollider.onTriggerExit += _actionOnTriggerExit;
        }

        public List<Actor> GetInnerActors()
        {
            X3Physics.CollisionTestNoGC(actor.transform.position, Vector3.zero, actor.transform.eulerAngles, _x3ActorCollider.shape, false, X3LayerMask.ColliderTest, out var actors);
            return actors;
        }

        private void _OnTriggerEnter(CqCollider cqCollider)
        {
            var mono = cqCollider.GetComponent<X3ActorCollider>();
            if (mono == null)
                return;
            Actor target = mono.actor;
            var eventData = battle.eventMgr.GetEvent<EventOnTriggerArea>();
            eventData.Init(this.actor, true, target, mono.IsCharacterCtrl);
            this.battle.eventMgr.Dispatch(EventType.OnTriggerArea, eventData);
        }

        private void _OnTriggerExit(CqCollider cqCollider)
        {            
            var mono = cqCollider.GetComponent<X3ActorCollider>();
            if (mono == null)
                return;
            Actor target = mono.actor;
            var eventData = battle.eventMgr.GetEvent<EventOnTriggerArea>();
            eventData.Init(this.actor, false, target, mono.IsCharacterCtrl);
            this.battle.eventMgr.Dispatch(EventType.OnTriggerArea, eventData);
        }

        public override void OnRecycle()
        {
            if (_x3ActorCollider != null)
            {
                _x3ActorCollider.onTriggerEnter -= _actionOnTriggerEnter;
                _x3ActorCollider.onTriggerExit -= _actionOnTriggerExit;
            }

            _x3ActorCollider = null;
        }
    }
}
