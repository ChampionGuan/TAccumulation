using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取Buff层数\nFAGetBuffLayer")]
    public class FAGetBuffLayer : FlowAction
    {
        private ValueInput<IBuff> _buffInput;

        protected override void _OnRegisterPorts()
        {
            _buffInput = AddValueInput<IBuff>(nameof(IBuff));
            AddValueOutput<int>("buff层数", _GetBuffLayer);
        }

        private int _GetBuffLayer()
        {
            if (_buffInput == null)
            {
                _LogError("获取Buff层数节点，传入的buff为空！请联系【蜗牛君】");
                return 0;
            }

            var buff = _buffInput.GetValue();
            if (buff == null)
            {
                _LogError("获取Buff层数节点，传入的buff为空！请联系【蜗牛君】");
                return 0;
            }
            return buff.layer;
        }
    }
}
