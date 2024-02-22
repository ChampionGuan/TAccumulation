using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("判断DamageBoxID\nCompareDamageBoxID")]
    public class FCCompareDamageBoxID : FlowCondition
    {
        public BBParameter<int> damageBoxID = new BBParameter<int>();

        private ValueInput<HitInfo> _viHitInfo;
        private ValueInput<DamageBoxCfg> _viDamageBoxCfg;

        protected override void _OnAddPorts()
        {
            _viHitInfo = AddValueInput<HitInfo>(nameof(HitInfo));
            _viDamageBoxCfg = AddValueInput<DamageBoxCfg>(nameof(DamageBoxCfg));
        }

        protected override bool _IsMeetCondition()
        {
            DamageBoxCfg damageBoxCfg = _viHitInfo?.GetValue()?.damageBoxCfg ?? _viDamageBoxCfg?.GetValue();
            if (damageBoxCfg == null)
            {
                return false;
            }
            
            var id = damageBoxID.GetValue();
            if (damageBoxCfg.ID != id)
            {
                return false;
            }

            return true;
        }
    }
}
