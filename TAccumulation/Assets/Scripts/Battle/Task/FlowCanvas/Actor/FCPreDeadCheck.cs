using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("死亡预判断\nPreDeadCheck")]
    public class FCPreDeadCheck : FlowCondition
    {
        private ValueInput<EventPrevDamage> _viEventPrevDamage;
        private ValueInput<Actor> _viBeHitActor;

        protected override void _OnAddPorts()
        {
            _viEventPrevDamage = AddValueInput<EventPrevDamage>(nameof(EventPrevDamage));
            _viBeHitActor = AddValueInput<Actor>("BeHitActor");
        }

        protected override bool _IsMeetCondition()
        {
            var eventPrevDamage = _viEventPrevDamage.GetValue();
            var target = _viBeHitActor.GetValue();
            
            var damageInfo = ObjectPoolUtility.DamageInfoPool.Get();
            _battle.damageProcess.PreCalDamage(damageInfo, eventPrevDamage.damageExporter, eventPrevDamage.target, eventPrevDamage.hitParamConfig, eventPrevDamage.damageProportion, eventPrevDamage.isCritical, (DamageType)eventPrevDamage.hitParamConfig.TargetDamageType, eventPrevDamage.dynamicHitInfo.attrModifies, true, eventPrevDamage.damageRandomValue);

            // DONE: 死亡预判断.
            var curHp = target.attributeOwner.GetAttrValue(AttrType.HP);
            var realDamage = damageInfo.realDamage;
            
            ObjectPoolUtility.DamageInfoPool.Release(damageInfo);
            return curHp <= realDamage;
        }
    }
}
