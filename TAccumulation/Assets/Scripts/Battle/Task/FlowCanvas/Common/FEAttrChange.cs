using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using Unity.Mathematics;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("属性变更事件\nAttrChange")]
    public class FEAttrChange : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public BBParameter<int> AttrID = new BBParameter<int>();
        private EventAttrChange _eventAttrChange;
        public AttrChangeMode changeMode = AttrChangeMode.Any;
        [MinValue(0f)]
        public float minChangeValue = 0f;

        private Action<EventAttrChange> _actionAttrChange;

        public FEAttrChange()
        {
            _actionAttrChange = _OnAttrChange;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("SourceActor", () => _eventAttrChange?.actor);
            AddValueOutput<float>("OldValue", () => _eventAttrChange?.oldValue ?? 0f);
            AddValueOutput<float>("NewValue", () => _eventAttrChange?.newValue ?? 0f);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventAttrChange>(EventType.AttrChange, _actionAttrChange, "FEAttrChange._OnAttrChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventAttrChange>(EventType.AttrChange, _actionAttrChange);
        }

        private void _OnAttrChange(EventAttrChange eventAttrChange)
        {
            if (_isTriggering || eventAttrChange == null)
                return;

            if (!_IsMainObject(EventTarget.GetValue(), eventAttrChange.actor))
                return;

            if (AttrID.GetValue() != (int) eventAttrChange.type)
                return;

            _eventAttrChange = eventAttrChange;
            float delta = eventAttrChange.newValue - eventAttrChange.oldValue;

            switch (changeMode)
            {
                case AttrChangeMode.Add:
                {
                    if (delta >= minChangeValue)
                    {
                        _Trigger();
                    }
                } break;
                case AttrChangeMode.Sub:
                {
                    if (-delta >= minChangeValue)
                    {
                        _Trigger();
                    }
                } break;
                case AttrChangeMode.Any:
                {
                    if (math.abs(delta) >= minChangeValue)
                    {
                        _Trigger();
                    }
                } break;
                default:
                {
                    _LogError("changeMode配置有问题！");
                    _Trigger();
                } break;
            }
        }
    }
}
