using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("命中流程开始前(攻击方)\nBeforeHit_Hitter")]
    public class FEBeforeHit_Hitter : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        
        public List<DamageBoxType> DamageBoxTypes = new List<DamageBoxType>() { X3Battle.DamageBoxType.Attack };

        private EventBeforeHit _eventBeforeHit;
        private Action<EventBeforeHit> _actionOnBeforeHit;

        public FEBeforeHit_Hitter()
        {
            _actionOnBeforeHit = _OnBeforeHit;
        }

        protected override void _OnAddPorts()
        {
            AddValueOutput<EventBeforeHit>(nameof(EventBeforeHit), () => _eventBeforeHit);
            AddValueOutput<Actor>("HitCaster", () => _eventBeforeHit?.damageExporter?.GetCaster());
            AddValueOutput<Actor>("HitTarget", () => _eventBeforeHit?.target);
            AddValueOutput<HitInfo>("HitInfo", () => _eventBeforeHit?.hitInfo);
            AddValueOutput<DynamicHitInfo>("DynamicHitInfo", () => _eventBeforeHit?.dynamicHitInfo);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBeforeHit>(EventType.OnBeforeHit, _actionOnBeforeHit, "FEBeforeHit_Hitter._OnBeforeHit");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBeforeHit>(EventType.OnBeforeHit, _actionOnBeforeHit);
        }

        private void _OnBeforeHit(EventBeforeHit arg)
        {
            if (_isTriggering || arg == null)
                return;
            // DONE: 主体判断
            if (!_IsMainObject(EventTarget.GetValue(), arg.damageExporter.GetCaster()))
                return;
            // DONE: 伤害包围盒类型判断
            if (!DamageBoxTypes.Contains(arg.damageBoxCfg.DamageBoxType))
            {
                return;
            }
            _eventBeforeHit = arg;
            _Trigger();
            _eventBeforeHit = null;
        }
    }
}
