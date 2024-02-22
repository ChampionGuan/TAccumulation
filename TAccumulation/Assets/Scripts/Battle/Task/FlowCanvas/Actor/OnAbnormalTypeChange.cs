using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Event")]
    [Name("actor异常状态改变监听器\nOnAbnormalTypeChange")]
    public class OnAbnormalTypeChange : FlowEvent
    {
        public BBParameter<ChooseActorType> chooseType = new BBParameter<ChooseActorType>();
        public BBParameter<ActorAbnormalType> tag = new BBParameter<ActorAbnormalType>(ActorAbnormalType.Weak);
        public BBParameter<bool> isActive = new BBParameter<bool>();

        private Action<EventAbnormalTypeChange> _actionAbnormalTypeChange;

        public OnAbnormalTypeChange()
        {
            _actionAbnormalTypeChange = _OnTagChange;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventAbnormalTypeChange>(EventType.AbnormalTypeChange, _actionAbnormalTypeChange, "OnAbnormalTypeChange._OnTagChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventAbnormalTypeChange>(EventType.AbnormalTypeChange, _actionAbnormalTypeChange);
        }

        private void _OnTagChange(EventAbnormalTypeChange arg)
        {
            if (_isTriggering)
                return;
            var actor = BattleUtil.GetActor(chooseType.value, _actor);
            if (actor == null)
                return;
            if (arg.abnormalType != tag.value)
                return;
            if (arg.active != isActive.value)
                return;
            
            _Trigger();
        }
    }
}
