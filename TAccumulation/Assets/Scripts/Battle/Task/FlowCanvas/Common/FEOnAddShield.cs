using System;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("即将添加护盾事件\nFEOnAddShield")]
    public class FEOnAddShield : FlowEvent
    {
        private Action<EventOnAddShield> _eventListener;
        private EventOnAddShield _eventData;
        
        public FEOnAddShield()
        {
            _eventListener = _OnAddShield;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput("Caster", () => _eventData?.caster);
            AddValueOutput("Target", () =>_eventData?.target);
            AddValueOutput("IBuff", () =>_eventData?.castBuff);
            AddValueOutput("护盾Info", () =>_eventData?.addInfo);
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnAddShield, _eventListener, "FEOnAddShield.OnAddShield");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnAddShield, _eventListener);
        }
        
        private void _OnAddShield(EventOnAddShield data)
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