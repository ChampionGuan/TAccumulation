using System.Collections.Generic;

namespace X3Battle
{
    public class ActorGroup : IReset
    {
        private ActorMgr _actorMgr;
        public int id { get; private set; }
        
        /// <summary> 当前处于组内的actor的insID </summary>
        public List<int> actorIds { get; } = new List<int>();

        public void Init(ActorMgr actorMgr, int id)
        {
            this.id = id; 
            _actorMgr = actorMgr;
        }
        
        public void Reset()
        {
            actorIds.Clear();
            _actorMgr = null;
        }

        public int GetActorCount()
        {
            return actorIds.Count;
        }
        
        public void InsertActorId(int insID)
        {
            int preNum = GetActorCount();
            actorIds.Add(insID);
            
            var eventData = _actorMgr.battle.eventMgr.GetEvent<EventGroupNumChange>();
            eventData.Init(this, preNum, GetActorCount());
            _actorMgr.battle.eventMgr.Dispatch(EventType.OnGroupNumChange, eventData);
        }

        public void RemoveActorId(int insID)
        {
            int preNum = GetActorCount();
            actorIds.Remove(insID);

            var eventData = _actorMgr.battle.eventMgr.GetEvent<EventGroupNumChange>();
            eventData.Init(this, preNum, GetActorCount());
            _actorMgr.battle.eventMgr.Dispatch(EventType.OnGroupNumChange, eventData);          
        }
    }
}
