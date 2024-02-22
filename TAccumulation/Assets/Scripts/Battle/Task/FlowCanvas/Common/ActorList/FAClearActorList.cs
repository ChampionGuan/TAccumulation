using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action/ActorList")]
    [Name("ActorList操作-清空\nFAClearActorList")]
    public class FAClearActorList : FlowAction
    {
        private ValueInput<ActorList> _viActorList;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viActorList = AddValueInput<ActorList>("ActorList");
        }

        protected override void _Invoke()
        {
            var list = _viActorList?.GetValue();
            if (list == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList操作-清空 FAClearActorList】引脚参数配置错误, 【ActorList】引脚为null!");
                return;
            }
            
            list.Clear();
        }
    }
}
