using PapeGames.X3;

namespace X3Battle.TargetSelect
{
    // 1.Boss选择规则 永久选择Boss怪物
    public class BossSelectMode : SelectModeBase
    {
        public BossSelectMode(TargetSelector targetSelector) : base(targetSelector, TargetLockModeType.Boss)
        {
        }

        protected override void _OnStart()
        {
            _actor.battle.eventMgr.AddListener<EventStateTagChangeBase>(EventType.LockIgnoreStateTagChange, _OnActorStateTagChange, "BossSelectMode._OnActorStateTagChange");
            
            // 初始使用Boss
            var target  = TargetSelectUtil.GetBossTarget();
            if (target == null || target.stateTag.IsActive(ActorStateTagType.LockIgnore))
            {
                return;
            }
            LogProxy.LogFormat("【目标】：{0} Boss锁定模式初始化，锁定！{1}", _actor.name, target.name); 
            _SetTargetWithEvent(target);
        }
        protected override void _OnStop()
        {
            _actor.battle.eventMgr.RemoveListener<EventStateTagChangeBase>(EventType.LockIgnoreStateTagChange, _OnActorStateTagChange);
        }
        // 目标锁定免疫生效，实时脱锁
        private void _OnActorStateTagChange(EventStateTagChangeBase data)
        {
            if (data.actor == _target && data.active)
            {
                var name1 = _actor.name;
                var name2 = _target.name;
                LogProxy.LogFormat("【目标】：{0} Boss锁定模式，锁定目标 {1}, 进入不可锁定状态！", name1, name2);
                _SetTargetWithEvent(null);
            }
        }
        protected override void _OnUpdate()
        {
            if (this._target == null)
            {
                var target  = TargetSelectUtil.GetBossTarget();
                if (target == null)
                    return;
                if(target.stateTag.IsActive(ActorStateTagType.LockIgnore))
                    return;
                var name1 = _actor.name;
                LogProxy.LogFormat("【目标】：{0} Boss锁定模式，锁定！{1}", name1, target.name); 
                this._SetTargetWithEvent(target);
            }
        }
        
        protected override void _OnTryUpdateTarget(TargetSelectorUpdateType type, object data)
        {
            _OnUpdate();
        }
    }
}