using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("Buff结束\nBuffDestroyed")]
    [Description("buff结束事件，结束原因枚举使用Switch Enum进行判断（cover destory：buff冲突处理过程中结束；normal destory：时间结束；others：其他）")]
    public class FEBuffDestroyed : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        private EventBuffChange _eventBuffChange;

        private Action<EventBuffChange> _actionOnBuffChange;

        public FEBuffDestroyed()
        {
            _actionOnBuffChange = _OnBuffChange;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("BuffCaster", () => _eventBuffChange?.caster);
            AddValueOutput<Actor>("BuffTarget", () => _eventBuffChange?.target);
            AddValueOutput<IBuff>("IBuff", () => _eventBuffChange?.buff);
            AddValueOutput<EventBuffChange.DestroyedReason>("DestroyedReason", () => _eventBuffChange?.destroyedReason ?? EventBuffChange.DestroyedReason.None);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange, "FEBuffDestroyed._OnBuffChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffChange, _actionOnBuffChange);
        }

        private void _OnBuffChange(EventBuffChange eventBuffChange)
        {
            if (_isTriggering || eventBuffChange == null || eventBuffChange.buff == null)
                return;

            if (eventBuffChange.type != BuffChangeType.Destroy)
                return;

            if (!_IsMainObject(EventTarget.GetValue(), eventBuffChange.target))
                return;

            _eventBuffChange = eventBuffChange;
            _Trigger();
            _eventBuffChange = null;
        }
    }
}
