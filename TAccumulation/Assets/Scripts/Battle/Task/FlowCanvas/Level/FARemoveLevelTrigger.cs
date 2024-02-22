using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("移除关卡触发器\nRemoveLevelTrigger")]
    public class FARemoveLevelTrigger : FlowAction
    {
        private ValueInput<int> _viInsId;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viInsId = AddValueInput<int>("InsId");
        }

        protected override void _Invoke()
        {
            Battle.Instance.triggerMgr.RemoveTrigger(_viInsId.GetValue());
        }
    }
}
