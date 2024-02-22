using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("NPC Group数量监听器\nOnGroupNumChange")]
    public class OnGroupNumChange : FlowListener
    {
        public BBParameter<int> groupId = new BBParameter<int>();
        public BBParameter<ECompareOperator> eCompareOperator = new BBParameter<ECompareOperator>();
        public BBParameter<int> groupCount = new BBParameter<int>();

        private Action<EventGroupNumChange> _actionGroupNumChange;

        public OnGroupNumChange()
        {
            _actionGroupNumChange = _GroupNumChange;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventGroupNumChange>(EventType.OnGroupNumChange, _actionGroupNumChange, "OnGroupNumChange._GroupNumChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventGroupNumChange>(EventType.OnGroupNumChange, _actionGroupNumChange);
        }

        private void _GroupNumChange(EventGroupNumChange @event)
        {
            if (IsReachMaxCount())
                return;
            if (@event?.actorGroup == null)
                return;
            if (@event.actorGroup.id != groupId.GetValue())
                return;
            int curNum = @event.curNum;
            int targetNum = groupCount.GetValue();
            var compareOperator = eCompareOperator.GetValue();
            if (!BattleUtil.IsCompareSize(curNum, targetNum, compareOperator))
            {
                return;
            }
            _Trigger();
        }
    }
}
