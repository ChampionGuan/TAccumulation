using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System.Collections.Generic;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("某单位进入受击（被动）\nHurtPositive")]
    public class FEHurtPositive : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public List<HurtType> hurtTypes = new List<HurtType>();
        private OnEventEnterHurt _eventEnterHurt;
        private Action<OnEventEnterHurt> _actionEnterHurt;
        
        public FEHurtPositive()
        {
            _actionEnterHurt = _EnterHurt;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("Caster", () => _eventEnterHurt?.caster);
            AddValueOutput<Actor>("Target", () => _eventEnterHurt?.target);
            AddValueOutput<ISkill>("ISkill", () => _eventEnterHurt?.hitInfo?.damageExporter as ISkill);
            AddValueOutput<HitInfo>("hitInfo", () => _eventEnterHurt?.hitInfo);

        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<OnEventEnterHurt>(EventType.EnterHurt, _actionEnterHurt, "FEHurtPositive._EnterHurt");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<OnEventEnterHurt>(EventType.EnterHurt, _actionEnterHurt);
        }

        private void _EnterHurt(OnEventEnterHurt arg)
        {
            if (_isTriggering || arg == null)
                return;
            if (!hurtTypes.Contains(arg.hitInfo.damageBoxCfg.HurtType))
                return;
            if (!_IsMainObject(this.EventTarget.GetValue(), arg.target))
                return;
            _eventEnterHurt = arg;
            _Trigger();
            _eventEnterHurt = null;
        }
    }
}
