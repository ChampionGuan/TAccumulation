using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("造成伤害|补充条件1（范围判断）\nGenDamage")]
    public class FCGenDamage : FlowCondition
    {
        public BBParameter<float> range = new BBParameter<float>();
        public BBParameter<ECompareOperator> rangeOperator = new BBParameter<ECompareOperator>();
        public BBParameter<float> damage = new BBParameter<float>();
        public BBParameter<ECompareOperator> damageOperator = new BBParameter<ECompareOperator>();

        private ValueInput<EventExportDamage> _viEventExportDamage;

        protected override void _OnAddPorts()
        {
            _viEventExportDamage = AddValueInput<EventExportDamage>(nameof(EventExportDamage));
        }

        protected override bool _IsMeetCondition()
        {
            // DONE: 获取事件数据.
            var eventExportDamage = _viEventExportDamage.GetValue();
            if (eventExportDamage == null)
                return false;
            if (eventExportDamage.exporter == null)
                return false;

            // DONE: 判断该次事件是否是伤害事件.
            if (eventExportDamage.damageType != DamageType.Sub)
                return false;

            // DONE: 比较造成的总伤害量
            var totalDamage = eventExportDamage.totalDamage;
            var refDamage = damage.GetValue();
            var refDamageOperator = damageOperator.GetValue();
            if (!BattleUtil.IsCompareSize(totalDamage, refDamage, refDamageOperator))
            {
                return false;
            }

            // DONE: 只要有个一目标的距离符合, 则满足条件.
            var attacker = eventExportDamage.exporter.GetCaster();
            var compareOperator = rangeOperator.GetValue();
            var rangeValue = range.GetValue();
            
            var target = eventExportDamage.damageInfo.actor;
            float distance = (attacker.transform.position - target.transform.position).magnitude;
            if (!BattleUtil.IsCompareSize(distance, rangeValue, compareOperator))
            {
                return false;
            }

            return true;
        }
    }
}
