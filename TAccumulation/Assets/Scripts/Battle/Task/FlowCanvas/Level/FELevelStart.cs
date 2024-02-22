using System;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Event")]
    [Name("监听关卡开始\nLevelStart")]
    public class FELevelStart : FlowEvent
    {
        private Action<ECEventDataBase> _actionOnLevelStartEvent;
        
        public FELevelStart()
        {
            _actionOnLevelStartEvent = _OnLevelStartEvent;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<ECEventDataBase>(EventType.OnLevelStart, _actionOnLevelStartEvent, "FELevelStart._OnLevelStartEvent");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<ECEventDataBase>(EventType.OnLevelStart, _actionOnLevelStartEvent);
        }

        private void _OnLevelStartEvent(ECEventDataBase arg)
        {
            _Trigger();
        }
    }
}
