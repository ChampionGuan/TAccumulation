using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("中断命中流程\nInterruptHitProcess")]
    public class FAInterruptHitProcess : FlowAction
    {
        private ValueInput<DynamicHitInfo> _viDynamicHitInfo;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viDynamicHitInfo = AddValueInput<DynamicHitInfo>(nameof(DynamicHitInfo));
        }

        protected override void _Invoke()
        {
            var hitInfo = _viDynamicHitInfo.GetValue();
            if (hitInfo == null)
                return;
            hitInfo.isInterruptHitProcess = true;
        }
    }
}
