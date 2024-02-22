using PapeGames.X3;

namespace X3Battle.TargetSelect
{
    public class SelectModeBase
    {
        public TargetLockModeType modeType { get; private set; }
        protected TargetSelector _targetSelector;
        protected Actor _actor;
        protected bool _isRunning = false;
        protected Actor _target;

        public SelectModeBase(TargetSelector targetSelector, TargetLockModeType type)
        {
            _targetSelector = targetSelector;
            _actor = targetSelector.actor;
            modeType = type;
            _OnInit();
        }

        // 开始
        public void Start()
        {
            this._isRunning = true;
            this._OnStart();
        }

        // 结束
        public void Stop()
        {
            this._OnStop();
            this._isRunning = false;
            LogProxy.LogFormat("【目标】：{0} 索定模式推出，锁定置空！", _actor.name); 
            this._SetTargetWithEvent(null);
        }

        // 获取目标
        public Actor GetTarget()
        {
            return this._target;
        }

        // 更新
        public void Update()
        {
            if (this._isRunning)
            {
                if (this._target != null && this._target.isDead)
                {
                    LogProxy.LogFormat("【目标】：檢測到{0} 的目標 {1} 死亡，锁定置空！", _actor.name, _target.name); 
                    this._SetTargetWithEvent(null);
                }

                this._OnUpdate();
            }
        }

        // 销毁
        public void Destroy()
        {
            this.Stop();
            this._OnDestroy();
            this._targetSelector = null;
            this._actor = null;
            this._target = null;
        }

        // 技能等开始或结束的时候会调用更新目标
        // data 目前是SkillSelectData
        public void TryUpdateTarget(TargetSelectorUpdateType type, object data)
        {
            this._OnTryUpdateTarget(type, data);
        }

        // -------------------------------------- protected方法 ----------------------------------
        protected void _SetTargetWithEvent(Actor target)
        {
            var name1 = _actor.name;
            var name2 = target == null ? "null" : target.name;
            if (this._target == target)
            {
                LogProxy.LogFormat("【目标】：{0}的锁定目标仍然是{1}，前后没有变化", name1, name2);
                return;
            }
            this._target = target;
            
            LogProxy.LogFormat("【目标】：{0}的锁定目标变化为{1}", name1, name2);
            var eventData = _actor.battle.eventMgr.GetEvent<EventChangeLockTarget>();
            eventData.Init(this._actor, this._target);
            this._actor.battle.eventMgr.Dispatch(EventType.ChangeLockTarget, eventData);
        }

        // ---------------------------------------- 模板方法 ----------------------------------------
        protected virtual void _OnInit()
        {
        }

        protected virtual void _OnStart()
        {
        }

        protected virtual void _OnStop()
        {
        }

        protected virtual void _OnDestroy()
        {
        }

        protected virtual void _OnUpdate()
        {
        }

        // data 目前是SkillSelectData
        protected virtual void _OnTryUpdateTarget(TargetSelectorUpdateType type, object data)
        {
        }
    }
}