using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("是否暴击\nIsCrit")]
    public class FCIsCrit : FlowCondition
    {
        private ValueInput<DamageInfo> _viDamageInfo;

        protected override void _OnAddPorts()
        {
            _viDamageInfo = AddValueInput<DamageInfo>("DamageInfo");
        }

        protected override bool _IsMeetCondition()
        {
            var damageInfo = _viDamageInfo.GetValue();
            if (damageInfo == null)
                return false;
            return damageInfo.isCritical;
        }
    }
}
