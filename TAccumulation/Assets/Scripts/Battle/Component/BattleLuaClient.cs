using System.Collections.Generic;
using X3.CustomEvent;

namespace X3Battle
{
    /// <summary>
    /// Lua端战斗管理
    /// 创建，驱动，销毁Lua端战斗
    /// </summary>
    public class BattleLuaClient : BattleComponent
    {
        // 通知到lua端的事件
        private List<ECEventDataBase> _listEventData = new List<ECEventDataBase>(5);
        private List<EventType> _listEventType = new List<EventType>(5);

        public IBattleLuaClient client { get; private set; }

        public BattleLuaClient() : base(BattleComponentType.LuaClient)
        {
            requiredAnimationJobRunning = true;
        }

        protected override void OnAwake()
        {
            BattleClient.Instance.onPostPhysicalJobRunning.AddListener(_OnPostLateUpdate);

            client = BattleEnv.LuaBridge.CreateBattle();
            client.Awake();
            battle.eventMgr.AddListener(_OnFireEvent, "LuaClient._OnFireEvent()");
        }

        protected override void OnStart()
        {
            client.Start();
        }

        public override void OnBattleBegin()
        {
            client.OnBattleBegin();
        }

        public override void OnBattleEnd()
        {
            client.OnBattleEnd();
        }

        protected override void OnAnimationJobRunning()
        {
            client.Update();
        }

        protected override void OnDestroy()
        {
            BattleClient.Instance.onPostPhysicalJobRunning.RemoveListener(_OnPostLateUpdate);

            battle.eventMgr.RemoveListener(_OnFireEvent);
            client.OnDestroy();
            BattleEnv.LuaBridge.DestroyBattle();

            client = null;
            entity = null;
        }

        private void _OnFireEvent(EventType eventType, IEventData eventData)
        {
            using (ProfilerDefine.LuaOnFireEvent.Auto())
            {
                var eventArg = eventData as ECEventDataBase;
                if (!BattleUtil.IsSendEventToUI(eventType, eventArg))
                {
                    return;
                }

                // Profiler.BeginSample("BattleLuaEnv._OnFireEvent()");
                // callLua?.FireEvent(type, arg);
                // Profiler.EndSample();
                _AddEventForDelayHandle(eventType, eventArg);
            }
        }

        private void _AddEventForDelayHandle(EventType eventType, ECEventDataBase battleEvent)
        {
            using (ProfilerDefine.LuaAddEventForDelayHandle.Auto())
            {
                _listEventType.Add(eventType);
                _listEventData.Add(battleEvent?.Clone());
            }
        }

        // DONE: 考虑在Update阶段显示技能UI之后接战斗暂停，会导致OnLateUpdate全不走，改用BattleClient层的PostLateUpdate.
        // 当战斗暂停之后，也不会有事件产生，如果有事件产生，理论也要及时响应。
        private void _OnPostLateUpdate()
        {
            using (ProfilerDefine.LuaOnFireEvent.Auto())
            {
                _PushDelayHandleEventsToLua();
            }
        }

        private void _PushDelayHandleEventsToLua()
        {
            if (_listEventType.Count <= 0) return;
            foreach (var eventData in _listEventData)
            {
                if (eventData is ECEventExpendParam eventExpendParam)
                {
                    eventExpendParam.ExpendParamForLua();
                }
            }

            BattleEnv.LuaBridge.FireEventList(_listEventType, _listEventData);
            _ClearEvents();
        }

        private void _ClearEvents()
        {
            foreach (var eventData in _listEventData)
            {
                battle.eventMgr.ReleaseEvent(eventData);
            }

            _listEventData.Clear();
            _listEventType.Clear();
        }
    }
}