using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断BattleHitParamID\nCompareBattleHitParamID")]
    public class FCCompareBattleHitParamID : FlowCondition
    {
        public BBParameter<int> battleHitParamID = new BBParameter<int>();
        private ValueInput<HitInfo> _viHitInfo;

        protected override void _OnAddPorts()
        {
            _viHitInfo = AddValueInput<HitInfo>(nameof(HitInfo));
        }

        protected override bool _IsMeetCondition()
        {
            if (_viHitInfo == null)
                return false;
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
                return false;
            var hitParamID = battleHitParamID.GetValue();
            if (hitInfo.hitParamConfig.HitParamID != hitParamID)
                return false;
            return true;
        }
    }
}
