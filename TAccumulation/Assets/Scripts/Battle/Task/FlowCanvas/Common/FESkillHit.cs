using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("释放技能命中单位\nSkillHit")]
    public class FESkillHit : FlowEvent
    {
        public enum HitEventType
        {
            AnyTime, // 技能期间，每次技能命中任意单位都触发
            OncePerTarget, // 技能期间，每个目标单位第一次被命中触发
            OnlyOnce, // 技能期间，产生命中只触发一次
        }
        
        public BBParameter<EventTargetType> EventTargetType = new BBParameter<EventTargetType>(X3Battle.EventTargetType.Self);
        public BBParameter<HitEventType> EventHitType = new BBParameter<HitEventType>(HitEventType.AnyTime);
        
        private EventBeforeHit _eventBeforeHit;

        private Action<EventCastSkill> _actionCastSkill;
        private Action<EventEndSkill> _actionEndSkill;
        private Action<EventBeforeHit> _actionBeforeHit;

        private Dictionary<ISkill, HashSet<Actor>> _dictionary = new Dictionary<ISkill, HashSet<Actor>>(5);

        public FESkillHit()
        {
            _actionCastSkill = _OnCastSkill;
            _actionEndSkill = _OnEndSkill;
            _actionBeforeHit = _OnBeforeHit;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("HitCaster", () => _eventBeforeHit?.hitInfo?.damageCaster);
            AddValueOutput<Actor>("HitTarget", () => _eventBeforeHit?.hitInfo?.damageTarget);
            AddValueOutput<ISkill>(nameof(ISkill), () => (_eventBeforeHit?.damageExporter as ISkill)?.GetRootSkill());
            AddValueOutput<HitInfo>(nameof(HitInfo), () => _eventBeforeHit?.hitInfo);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _actionCastSkill, "FESkillHit._OnCastSkill");
            Battle.Instance.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, _actionEndSkill, "FESkillHit._OnEndSkill");
            Battle.Instance.eventMgr.AddListener<EventBeforeHit>(EventType.OnBeforeHit, _actionBeforeHit, "FESkillHit._OnBeforeHit");
        }

        protected override void _UnRegisterEvent()
        {
            // DONE: 防止Hit的时候触发蓝图Disable, 导致没有正确处理该容器.
            foreach (var keyValuePair in _dictionary)
            {
                ObjectPoolUtility.CommonActorHashSet.Release((ResetHashSet<Actor>)keyValuePair.Value);
            }
            _dictionary.Clear();
            
            Battle.Instance.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, _actionCastSkill);
            Battle.Instance.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _actionEndSkill);
            Battle.Instance.eventMgr.RemoveListener<EventBeforeHit>(EventType.OnBeforeHit, _actionBeforeHit);
        }

        private void _OnCastSkill(EventCastSkill arg)
        {
            if (arg?.skill == null)
            {
                return;
            }

            var caster = arg.skill.GetCaster();
            if (!_IsConcernedTarget(caster))
            {
                return;
            }
            
            if (!_dictionary.TryGetValue(arg.skill, out var hashSet))
            {
                hashSet = ObjectPoolUtility.CommonActorHashSet.Get();
                _dictionary.Add(arg.skill, hashSet);
            }
        }

        private void _OnEndSkill(EventEndSkill arg)
        {
            if (arg?.skill == null)
            {
                return;
            }

            var caster = arg.skill.GetCaster();
            if (!_IsConcernedTarget(caster))
            {
                return;
            }
            
            if (!_dictionary.TryGetValue(arg.skill, out var hashSet))
            {
                return;
            }

            ObjectPoolUtility.CommonActorHashSet.Release((ResetHashSet<Actor>)hashSet);
            _dictionary.Remove(arg.skill);
        }

        private void _OnBeforeHit(EventBeforeHit arg)
        {
            if (arg == null)
            {
                return;
            }

            if (!(arg.damageExporter is ISkill skill))
            {
                return;
            }
            
            var caster = skill.GetCaster();
            if (!_IsConcernedTarget(caster))
            {
                return;
            }
            
            if (!_dictionary.TryGetValue(skill, out var hashSet))
            {
                return;
            }

            var target = arg.target;
            var hitEventType = EventHitType.GetValue();
            switch (hitEventType)
            {
                case HitEventType.AnyTime:
                    break;
                case HitEventType.OncePerTarget:
                    if (!hashSet.Add(target))
                    {
                        return;
                    }
                    break;
                case HitEventType.OnlyOnce:
                    if (hashSet.Count > 0)
                    {
                        return;
                    }

                    hashSet.Add(target);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            _eventBeforeHit = arg;
            _Trigger();
            _eventBeforeHit = null;
        }

        /// <summary>
        /// 是否是关注的目标
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        private bool _IsConcernedTarget(Actor target)
        {
            if (target == null)
            {
                return false;
            }

            var eventTargetType = EventTargetType.GetValue();
            switch (eventTargetType)
            {
                case X3Battle.EventTargetType.Self:
                    return target == _actor;
                case X3Battle.EventTargetType.Girl:
                    return target.IsGirl();
                case X3Battle.EventTargetType.Boy:
                    return target.IsBoy();
            }

            return false;
        }
    }
}
