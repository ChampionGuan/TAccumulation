using System;

namespace X3Battle
{
    /// <summary>
    /// 角色事件管理类
    /// 注意：在角色回收后，会清除此单位的所有回调
    /// </summary>
    public class ActorEventMgr : ActorComponent
    {
        private ECEventMgr _eventMgr;

        public ActorEventMgr() : base(ActorComponentType.EventMgr)
        {
            requiredUpdate = false;
            _eventMgr = new ECEventMgr();
        }

        public override void OnRecycle()
        {
            _eventMgr.Clear();
        }

        public T GetEvent<T>() where T : ECEventDataBase, new()
        {
            return battle.eventMgr.GetEvent<T>();
        }

        public void AddListener<T>(EventType key, Action<T> func, string profileInfo) where T : ECEventDataBase
        {
            _eventMgr.AddListener(key, func, profileInfo);
        }

        public void RemoveListener<T>(EventType key, Action<T> func) where T : ECEventDataBase
        {
            _eventMgr.RemoveListener(key, func);
        }

        public void Dispatch(EventType key, ECEventDataBase arg, bool syncToWorld = true)
        {
            _eventMgr.Dispatch(key, arg, false);
            if (syncToWorld)
            {
                battle.eventMgr.Dispatch(key, arg);
            }
            else
            {
                battle.eventMgr.ReleaseEvent(arg);
            }
        }
    }
}