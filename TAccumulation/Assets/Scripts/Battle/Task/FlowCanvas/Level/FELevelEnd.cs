using System;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Event")]
    [Name("监听关卡胜利结束\nLevelEndVictory")]
    public class FELevelEnd : FlowEvent
    {
        private Action<ECEventDataBase> _actionOnLevelEndEvent;

        public FELevelEnd()
        {
            _actionOnLevelEndEvent = _OnLevelEndEvent;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<ECEventDataBase>(EventType.OnLevelEndFlowStart, _actionOnLevelEndEvent, "FELevelEnd._OnLevelEndEvent");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<ECEventDataBase>(EventType.OnLevelEndFlowStart, _actionOnLevelEndEvent);
        }

        private void _OnLevelEndEvent(ECEventDataBase arg)
        {
            if (_battle.status != BattleRunStatus.Success)
            {
                return;
            }
            _Trigger();
        }
    }
}
