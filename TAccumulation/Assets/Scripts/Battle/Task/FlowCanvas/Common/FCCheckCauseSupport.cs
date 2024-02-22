using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("检查是否可以触发援护技能\nCheckCauseSupport"))]
    public class FCCheckCauseSupport: FlowCondition
    {
        private ValueInput<HitInfo> _viHitInfo;
        
        protected override void _OnAddPorts()
        {
            _viHitInfo = AddValueInput<HitInfo>("HitInfo");
        }

        protected override bool _IsMeetCondition()
        {
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
                return false;
            return hitInfo.damageBoxCfg.CauseSupport;
        }
    }
}
