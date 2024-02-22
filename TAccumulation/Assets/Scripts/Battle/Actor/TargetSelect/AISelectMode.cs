using System;
using PapeGames.X3;

namespace X3Battle.TargetSelect
{
    // 1.normal更新规则：优先取嘲讽，再取仇恨
    // 2.更新时机：
    //       由仇恨通知过来
    //       嘲讽也要通知过来
    public class AISelectMode : SelectModeBase
    {
        private Actor _fixTarget;
        
        private Action<EventHateActor> _actionOnHateActorChange;
        private Action<EventTauntActor> _actionOnTauntTargetChange;

        public AISelectMode(TargetSelector targetSelector) : base(targetSelector, TargetLockModeType.AI)
        {
            _actionOnHateActorChange = _OnHateActorChange;
            _actionOnTauntTargetChange = _OnTauntTargetChange;
        }

        protected override void _OnStart()
        {
            // 初始使用仇恨目标
            _CalculateTarget();
            _fixTarget = null;
            _actor.eventMgr.AddListener<EventHateActor>(EventType.HateActorChange, _actionOnHateActorChange, "AISelectMode._OnHateActorChange");
            _actor.eventMgr.AddListener<EventTauntActor>(EventType.TauntActorChange, _actionOnTauntTargetChange, "AISelectMode._OnTauntTargetChange");
        }

        protected override void _OnStop()
        {
            _fixTarget = null;
            _actor.eventMgr.RemoveListener<EventHateActor>(EventType.HateActorChange, _actionOnHateActorChange);
            _actor.eventMgr.RemoveListener<EventTauntActor>(EventType.TauntActorChange, _actionOnTauntTargetChange);
        }

        // 锁定系统内部事件
        protected override void _OnTryUpdateTarget(TargetSelectorUpdateType type, object data)
        {
            if (type == TargetSelectorUpdateType.FixTarget)
            {
                _fixTarget = data as Actor;
                var name = _fixTarget?.name ?? "null";
                LogProxy.LogFormat("【目标】：{0} AI锁定模式，外部设置了固定目标 {1}", _actor.name, name);
                _CalculateTarget();
            }
        }
        
        // 重新从各个系统中取目标
        private void _CalculateTarget()
        {
            var name1 = _actor.name;
            var target = _fixTarget;
            if (target != null)
            {
                LogProxy.LogFormat("【目标】：{0} AI锁定模式，设置固定目标 {1}！", name1, _fixTarget.name);
            }
            
            if (target == null)
            {
                LogProxy.LogFormat("【目标】：{0} AI锁定模式，尝试取嘲讽目标！", name1);
                target = _actor.actorTaunt?.tauntTarget;
                if (target == null)
                {
                    target = _actor.actorHate?.hateTarget;
                    LogProxy.LogFormat("【目标】：{0} AI锁定模式，尝试取仇恨目标 (因为无嘲讽目标)", name1);
                }
            }
            _SetTargetWithEvent(target);
        }

        // 仇恨目标改变事件监听
        private void _OnHateActorChange(EventHateActor arg)
        {
            if (arg.actor == _actor)
            {
                var name1 = _actor.name;
                LogProxy.LogFormat("【目标】：{0} AI锁定模式，收到仇恨目标变化，准备更新", name1);
                _CalculateTarget();
            }   
        }

        // 嘲讽目标改变事件监听
        private void _OnTauntTargetChange(EventTauntActor arg)
        {
            if (arg.actor == _actor)
            {
                var name1 = _actor.name;
                LogProxy.LogFormat("【目标】：{0} AI锁定模式，收到被嘲讽目标变化，准备更新", name1);
                _CalculateTarget();
            }
        }
    }
}