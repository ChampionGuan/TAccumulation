using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Event")]
    [Name("单位拾取道具\nPickItem")]
    public class FEPickItem : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventPickItem _eventPickItem;
        private Action<EventPickItem> _actionOnPickItem;

        public FEPickItem()
        {
            _actionOnPickItem = _OnReceiveSignal;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventPickItem>(nameof(EventPickItem), () => _eventPickItem);
            AddValueOutput<Actor>("Picker", () => _eventPickItem?.picker);
            AddValueOutput<Actor>("Item", () => _eventPickItem?.item);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventPickItem>(EventType.OnPickItem, _actionOnPickItem, "FEPickItem._OnReceiveSignal");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventPickItem>(EventType.OnPickItem, _actionOnPickItem);
        }

        private void _OnReceiveSignal(EventPickItem arg)
        {
            if (_isTriggering || arg?.picker == null || arg.item == null)
                return;
            if (!_IsMainObject(EventTarget.GetValue(), arg.picker))
                return;
            _eventPickItem = arg;
            _Trigger();
            _eventPickItem = null;
        }
    }
}
