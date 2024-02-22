using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("判断信号存在\nHasSignal")]
    public class FCHasSignal : FlowCondition
    {
        private ValueInput<Actor> _viTarget;
        private ValueInput<string> _viSignalKey;

        protected override void _OnAddPorts()
        {
            _viTarget = AddValueInput<Actor>("Target");
            _viSignalKey = AddValueInput<string>("SignalKey");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viTarget.GetValue();
            if (actor == null || actor.signalOwner == null)
                return false;
            string signalKey = _viSignalKey.GetValue();
            if (string.IsNullOrWhiteSpace(signalKey) || string.IsNullOrEmpty(signalKey))
            {
                _LogError("请联系策划【卡宝】, 【判断信号存在 HasSignal】节点 【SignalKey】参数配置不合法");
                return false;
            }

            if (!actor.signalOwner.HasSignal(signalKey))
            {
                return false;
            }

            return true;
        }
    }
}
