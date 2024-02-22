using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("属性变更监听器\nOnAttrChange")]
    public class OnAttrChange : FlowListener
    {
        [Name("ActorId Girl=-1, Boy=-2")]
        public BBParameter<int> ActorID = new BBParameter<int>();
        public BBParameter<int> AttrID = new BBParameter<int>();
        public BBParameter<ECompareOperator> Comparison = new BBParameter<ECompareOperator>(ECompareOperator.EqualTo);
        public BBParameter<float> TargetValue = new BBParameter<float>();
        private EventAttrChange _eventAttrChange;
        private Action<EventAttrChange> _actionAttrChange;

        public OnAttrChange()
        {
            _actionAttrChange = _OnAttrChange;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventAttrChange>(EventType.AttrChange, _actionAttrChange, "OnAttrChange._OnAttrChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventAttrChange>(EventType.AttrChange, _actionAttrChange);
        }

        private void _OnAttrChange(EventAttrChange eventAttrChange)
        {
            if (IsReachMaxCount())
            {
                return;
            }

            if (eventAttrChange?.actor == null)
            {
                return;
            }
            
            // DONE: 不是关注的角色跳过.
            int actorTypeId = ActorID.GetValue();
            var target = BattleUtil.GetActorByIDType(actorTypeId);
            if (eventAttrChange.actor != target)
            {
                return;
            }

            // DONE: 不是关注的属性跳过.
            var attrID = AttrID.GetValue();
            if ((int)eventAttrChange.type != attrID)
            {
                return;
            }

            // DONE: 比较大小条件, 不满足则跳过.
            var targetValue = TargetValue.GetValue();
            var comparison = Comparison.GetValue();
            if (!BattleUtil.IsCompareSize(eventAttrChange.newValue, targetValue, comparison))
            {
                return;
            }

            _eventAttrChange = eventAttrChange;
            _Trigger();
            _eventAttrChange = null;
        }
    }
}
