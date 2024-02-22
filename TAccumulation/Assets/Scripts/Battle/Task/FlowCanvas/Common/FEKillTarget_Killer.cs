using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("击杀单位 Event:\nKill")]
    public class FEKillTarget_Killer : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        private EventOnKillTarget _eventOnKillTarget;

        private Action<EventOnKillTarget> _actionOnKillTarget;

        public FEKillTarget_Killer()
        {
            _actionOnKillTarget = _OnKillTarget;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventOnKillTarget>(nameof(EventOnKillTarget), () => _eventOnKillTarget);
            AddValueOutput<HitInfo>(nameof(HitInfo), () => _eventOnKillTarget?.hitInfo);
            AddValueOutput<DamageExporter>("DamageExporter", () => _eventOnKillTarget?.damageExporter);
            AddValueOutput<Actor>("Killer", () => _eventOnKillTarget?.killer);
            AddValueOutput<Actor>("Deader", () => _eventOnKillTarget?.deader);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventOnKillTarget>(EventType.OnKillTarget, _actionOnKillTarget, "FEKillTarget_Killer._OnKillTarget");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventOnKillTarget>(EventType.OnKillTarget, _actionOnKillTarget);
        }

        private void _OnKillTarget(EventOnKillTarget arg)
        {
            if (_isTriggering || arg == null)
                return;
            if (arg.killer == null)
                return;
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.killer))
                return;
            // DONE: 设置参数.
            _eventOnKillTarget = arg;
            _Trigger();
            _eventOnKillTarget = null;
        }
    }
}
