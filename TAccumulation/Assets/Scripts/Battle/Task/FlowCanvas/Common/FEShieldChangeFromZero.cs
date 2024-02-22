using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("护盾量从0变为不为0时，触发事件\nShieldChangeFromZero")]
    public class FEShieldChangeFromZero : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private Action<EventShieldChange> _actionShieldChange;
        
        public FEShieldChangeFromZero()
        {
            _actionShieldChange = _ShieldChange;
        }
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.ShieldChange, _actionShieldChange, "FEShieldChangeFromZero._actionShieldChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.ShieldChange, _actionShieldChange);
        }
        
        private void _ShieldChange(EventShieldChange data)
        {
            if (_isTriggering || data == null)
            {
                return;
            }

            if (!(data.oldValue == 0 && data.newValue > 0))
            {
                return;
            }

            if (!_IsMainObject(this.EventTarget.GetValue(), data.actor))
            {
                return;
            }
            
            _Trigger();
        }
    }
}