using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("检查受击类型条件\nCheckHurtType")]
    public class FCCheckHurtType : FlowCondition
    {
        public BBParameter<HurtTypeFlag> HurtTypeFlag = new BBParameter<HurtTypeFlag>(X3Battle.HurtTypeFlag.LightHurt);
        private ValueInput<HitInfo> _viHitInfo;

        protected override void _OnAddPorts()
        {
            _viHitInfo = AddValueInput<HitInfo>("HitInfo");
        }

        protected override bool _IsMeetCondition()
        {
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
            {
                return false;
            }
            var hurtTypeFlag = HurtTypeFlag.GetValue();
            if (((HurtTypeFlag)(1 << (int)hitInfo.damageBoxCfg.HurtType) & hurtTypeFlag) == 0)
            {
                return false;
            }
            return true;
        }
    }
}
