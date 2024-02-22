using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public class ActorStateTag : ActorComponent
    {
        private readonly Dictionary<ActorStateTagType, EventType> StateTag2EventType = new Dictionary<ActorStateTagType, EventType>
        {
            { ActorStateTagType.CannotMove, EventType.CannotMoveStateTagChange },
            { ActorStateTagType.CannotCastSkill, EventType.CannotCastSkillStateTagChange },
            { ActorStateTagType.DamageImmunity, EventType.DamageImmunityStateTagChange },
            { ActorStateTagType.CollisionIgnore, EventType.CollisionIgnoreStateTagChange },
            { ActorStateTagType.HitIgnore, EventType.HitIgnoreStateTagChange },
            { ActorStateTagType.HurtIgnore, EventType.HurtIgnoreStateTagChange },
            { ActorStateTagType.LockIgnore, EventType.LockIgnoreStateTagChange },
            { ActorStateTagType.CoreDamageImmunity, EventType.CoreDamageImmunityStateTagChange },
            { ActorStateTagType.TractionImmunity, EventType.TractionImmunityStateTagChange },
            { ActorStateTagType.AttackIgnore, EventType.AttackIgnoreStateTagChange },
            { ActorStateTagType.DebuffImmunity, EventType.DebuffImmunityStateTagChange },
            { ActorStateTagType.RecoverIgnore, EventType.RecoverIgnoreStateTagChange },
            { ActorStateTagType.CannotEnterMove, EventType.CannotEnterMoveStateTagChange },
            { ActorStateTagType.MissileBlastIgnore, EventType.MissileBlastIgnoreStateTagChange },
            { ActorStateTagType.LogicTestIgnore, EventType.LogicTestIgnoreStateTagChange },
        };

        private Dictionary<ActorStateTagType, int> _tags;

        public ActorStateTag() : base(ActorComponentType.StateTag)
        {
            _tags = new Dictionary<ActorStateTagType, int>();
        }

        public override void OnRecycle()
        {
            ReleaseAllTag();
        }

        public bool IsActive(ActorStateTagType tag)
        {
            _tags.TryGetValue(tag, out var num);
            return num > 0;
        }

        public void AcquireTag(ActorStateTagType tag)
        {
            if (tag == ActorStateTagType.None)
            {
                return;
            }

            PapeGames.X3.LogProxy.Log($"actor = {actor.name} 添加标签，tag = {tag} ！");
            _tags.TryGetValue(tag, out var num);
            var contains = num > 0;
            _tags[tag] = num + 1;

            if (contains || null == actor.eventMgr)
            {
                return;
            }

            _DispatchEvent(tag, true);
        }

        public void ReleaseTag(ActorStateTagType tag)
        {
            _tags.TryGetValue(tag, out var num);
            var newNum = num - 1;
            _tags[tag] = newNum >= 0 ? newNum : 0;
            if (newNum > 0 || null == actor.eventMgr)
            {
                return;
            }

            _DispatchEvent(tag, false);
        }

        public void ReleaseAllTag()
        {
            if (actor.eventMgr != null)
            {
                foreach (var iter in _tags)
                {
                    if (iter.Value > 0)
                    {
                        _DispatchEvent(iter.Key, false);
                    }
                }
            }

            _tags.Clear();
        }

        private void _DispatchEvent(ActorStateTagType tag, bool isActive)
        {
            var eventData = actor.eventMgr.GetEvent<EventStateTagChange>();
            eventData.Init(actor, tag, isActive);
            actor.eventMgr.Dispatch(EventType.StateTagChange, eventData);

            if (!StateTag2EventType.TryGetValue(tag, out var eventType))
            {
                LogProxy.LogWarning($"[ActorStateTag._DispatchEvent()]有未注册的StateTag事件，请注意检查！Tag:{tag}");
                return;
            }

            var eventData2 = actor.eventMgr.GetEvent<EventStateTagChangeBase>();
            eventData2.Init(actor, isActive);
            actor.eventMgr.Dispatch(eventType, eventData2);
        }
    }
}