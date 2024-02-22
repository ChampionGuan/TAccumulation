using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using Unity.Mathematics;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("目标血量阈值触发\nFEHpThreshold")]
    public class FEHpThreshold : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);
        public ECompareOperator Operator;
        public float hpPercent;
        
        private Action<EventAttrChange> _actionHpChange;

        public FEHpThreshold()
        {
            _actionHpChange = _OnHpChange;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventAttrChange>(EventType.AttrChange, _actionHpChange, "FEAttrChange._actionHpChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventAttrChange>(EventType.AttrChange, _actionHpChange);
        }
        private void _OnHpChange(EventAttrChange eventAttrChange)
        {
            if (_isTriggering || eventAttrChange == null)
                return;

            if (!_IsMainObject(EventTarget.GetValue(), eventAttrChange.actor))
                return;

            if (eventAttrChange.type != AttrType.HP)
                return;

            float maxHp = eventAttrChange.actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
            float lastPercent = eventAttrChange.oldValue / maxHp;
            float currentPercent = eventAttrChange.newValue / maxHp;

            switch (Operator)
            {
                case ECompareOperator.EqualTo:
                    if(Math.Abs(lastPercent - hpPercent) < float.Epsilon&&Math.Abs(currentPercent - hpPercent) > float.Epsilon)_Trigger();
                    break;
                case ECompareOperator.NotEqual:
                    if(Math.Abs(lastPercent - hpPercent) > float.Epsilon&&Math.Abs(currentPercent - hpPercent) < float.Epsilon)_Trigger();
                    break;
                case ECompareOperator.GreaterThan:
                    if (lastPercent < hpPercent && currentPercent > hpPercent) _Trigger();
                    break;
                case ECompareOperator.LessThan:
                    if (lastPercent >= hpPercent && currentPercent < hpPercent) _Trigger();
                    break;
                case ECompareOperator.GreaterOrEqualTo:
                    if (lastPercent < hpPercent && currentPercent >= hpPercent) _Trigger();
                    break;
                case ECompareOperator.LessOrEqualTo:
                    if (lastPercent > hpPercent && currentPercent <= hpPercent) _Trigger();
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }
}
