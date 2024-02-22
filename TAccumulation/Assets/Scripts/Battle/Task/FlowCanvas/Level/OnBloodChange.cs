using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("NPC血量监听器\nOnBloodChange")]
    public class OnBloodChange : FlowListener
    {
        [Name("SpawnID")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<ECompareOperator> eCompareOperator = new BBParameter<ECompareOperator>();
        public BBParameter<int> curHpPercent = new BBParameter<int>();

        private Action<EventActorHealthChangeForUI> _actionBloodChange;

        public OnBloodChange()
        {
            _actionBloodChange = _BloodChange;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventActorHealthChangeForUI>(EventType.ActorHealthChangeForUI, _actionBloodChange, "OnBloodChange._BloodChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventActorHealthChangeForUI>(EventType.ActorHealthChangeForUI, _actionBloodChange);
        }

        private void _BloodChange(EventActorHealthChangeForUI arg)
        {
            if (IsReachMaxCount())
                return;
            if (arg.actor == null)
                return;
            if (arg.actor.spawnID != actorId.GetValue())
                return;
            var maxHp = arg.actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
            var curHp = arg.actor.attributeOwner.GetAttrValue(AttrType.HP);
            float targetHp = maxHp * curHpPercent.GetValue() / 100f;

            var compareOperator = eCompareOperator.GetValue();
            switch (compareOperator)
            {
                case ECompareOperator.EqualTo:
                    if (curHp != targetHp)
                        return;
                    break;
                case ECompareOperator.NotEqual:
                    if (curHp == targetHp)
                        return;
                    break;
                case ECompareOperator.GreaterThan:
                    if (curHp <= targetHp)
                        return;
                    break;
                case ECompareOperator.LessThan:
                    if (curHp >= targetHp)
                        return;
                    break;
                case ECompareOperator.GreaterOrEqualTo:
                    if (curHp < targetHp)
                        return;
                    break;
                case ECompareOperator.LessOrEqualTo:
                    if (curHp > targetHp)
                        return;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            _Trigger();
        }
    }
}
