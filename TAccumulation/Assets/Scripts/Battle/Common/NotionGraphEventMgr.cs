using System;
using X3.CustomEvent;

namespace X3Battle
{
    public class NotionGraphEventMgr : EventMgr<NotionGraphEventType>
    {
        
    }
    
    public class NotionGraphEventDataBase : IEventData
    {
        public virtual void OnRecycle()
        {
        }
    }
}