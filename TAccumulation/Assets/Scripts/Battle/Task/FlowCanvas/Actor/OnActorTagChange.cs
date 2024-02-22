using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Event")]
    [Name("actor状态改变监听器\nOnActorTagChange")]
    public class OnActorTagChange : FlowEvent
    {
        public BBParameter<ChooseActorType> chooseType = new BBParameter<ChooseActorType>();
        public BBParameter<ActorStateTagType> tag = new BBParameter<ActorStateTagType>(ActorStateTagType.None);
        public BBParameter<bool> isActive = new BBParameter<bool>();

        private Action<EventStateTagChange> _actionStateTagChange;

        public OnActorTagChange()
        {
            _actionStateTagChange = OnTagChange;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventStateTagChange>(EventType.StateTagChange, _actionStateTagChange, "OnActorTagChange.OnTagChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventStateTagChange>(EventType.StateTagChange, _actionStateTagChange);
        }

        private void OnTagChange(EventStateTagChange arg)
        {
            if (_isTriggering)
                return;
            var actor = BattleUtil.GetActor(chooseType.value, _actor);
            if (actor == null)
                return;
            if(arg.stateTagType != tag.value)
                return;
            if (arg.active != isActive.value)
                return;
            
            _Trigger();
        }
    }
}
