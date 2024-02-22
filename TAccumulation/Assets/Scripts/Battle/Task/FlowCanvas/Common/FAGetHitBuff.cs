using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取该次Hit的来源Buff\nGetHitBuff")]
    public class FAGetHitBuff : FlowAction
    {
        private ValueInput<HitInfo> _viHitInfo;

        protected override void _OnRegisterPorts()
        {
            _viHitInfo = AddValueInput<HitInfo>(nameof(HitInfo));
            AddValueOutput<IBuff>(nameof(IBuff), _GetIBuff);
        }

        private IBuff _GetIBuff()
        {
            if (_viHitInfo == null)
                return null;
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
                return null;
            if (!(hitInfo.damageExporter is IBuff buff))
                return null;
            return buff;
        }
    }
}
