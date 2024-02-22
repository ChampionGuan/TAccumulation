using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("NPC Buff监听器\nOnBuffChange")]
    public class OnBuffChange : FlowListener
    {
        [Name("SpawnID")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<int> buffId = new BBParameter<int>();
        public BBParameter<int> buffLayer = new BBParameter<int>();

        private Action<EventBuffChange> _actionOnBuffChange;

        public OnBuffChange()
        {
            _actionOnBuffChange = _OnBuffChange;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange, "OnBuffChange._OnBuffChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange);
        }

        protected void _OnBuffChange(EventBuffChange arg)
        {
            if (IsReachMaxCount())
                return;
            if ((actorId.GetValue() == 0 || arg.buff.owner.actor.spawnID == actorId.GetValue()) &&
                (buffId.GetValue() == 0 || arg.buff.ID == buffId.GetValue()) &&
                (buffLayer.GetValue() == 0 || arg.buff.layer == buffLayer.GetValue()))
            {
                _Trigger();
            }
        }
    }
}
