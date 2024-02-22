using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("法术场作用结束\nMagicFieldEnd")]
    public class FEMagicFieldEnd : FlowEvent
    {
        public MagicFieldParamType magicFieldParamType = MagicFieldParamType.MagicFieldID;
        [ShowIf(nameof(magicFieldParamType), (int)MagicFieldParamType.MagicFieldID)]
        public BBParameter<int> magicFieldID = new BBParameter<int>();
        private EventMagicFieldState _eventMagicFieldState;

        private Action<EventMagicFieldState> _actionOnMagicField;

        public FEMagicFieldEnd()
        {
            _actionOnMagicField = _OnMagicField;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput("Master", () => _eventMagicFieldState?.master);
            AddValueOutput("Position", () => _eventMagicFieldState?.actor?.transform?.position ?? Vector3.zero);
        }
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventMagicFieldState>(EventType.MagicFieldStateChange, _actionOnMagicField, "FEMagicFieldEnd._OnMagicField");
        }
        
        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventMagicFieldState>(EventType.MagicFieldStateChange, _actionOnMagicField);
        }

        private void _OnMagicField(EventMagicFieldState eventAttrChange)
        {
            if (_isTriggering || eventAttrChange == null)
                return;

            if (eventAttrChange.state != MagicFieldStateType.End)
                return;
            
            var paramType = magicFieldParamType;
            if (paramType == MagicFieldParamType.MagicFieldID)
            {
                //判断ID是否相等
                if (magicFieldID.GetValue() != eventAttrChange.magicFieldID)
                    return;
            }

            // DONE: 设置参数.
            _eventMagicFieldState = eventAttrChange;
            _Trigger();
            _eventMagicFieldState = null;
        }
    }
}
