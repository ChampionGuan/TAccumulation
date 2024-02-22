using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition/ActorList")]
    [Name("判断ActorList是否为空\nIsEmptyActorList")]
    public class FCIsEmptyActorList : FlowCondition
    {
        private ValueInput<ActorList> _viActorList;

        protected override void _OnAddPorts()
        {
            _viActorList = AddValueInput<ActorList>("ActorList");
        }

        protected override bool _IsMeetCondition()
        {
            var list = _viActorList?.GetValue();
            if (list == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【判断ActorList是否为空 FCIsEmptyActorList】引脚参数配置错误, 【ActorList】引脚为null!");
                return true;
            }

            if (list.Count <= 0)
            {
                return true;
            }

            return false;
        }
    }
}
