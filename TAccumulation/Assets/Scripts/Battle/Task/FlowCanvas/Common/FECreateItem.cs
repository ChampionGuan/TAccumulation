using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("道具生成事件\nFECreateItem")]
    public class FECreateItem : FlowEvent
    {
        private Action<EventCreateItem> _eventListener;
        private EventCreateItem _eventData;
        
        public FECreateItem()
        {
            _eventListener = _CreateItem;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput("ID", () => _eventData?.itemID ?? 0);
            AddValueOutput("Position", () =>_eventData?.itemActor.transform.position ?? Vector3.zero);
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.CreateItem, _eventListener, "FECreateItem._CreateItem");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.CreateItem, _eventListener);
        }
        
        private void _CreateItem(EventCreateItem data)
        {
            if (_isTriggering || data == null)
            {
                return;
            }
            _eventData = data;
            _Trigger();
            _eventData = null;
        }
    }
}