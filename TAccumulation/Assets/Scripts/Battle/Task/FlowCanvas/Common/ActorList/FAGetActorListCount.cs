using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action/ActorList")]
    [Name("ActorList操作-返回大小\nFAGetActorListCount")]
    public class FAGetActorListCount : FlowAction
    {
        private ValueInput<ActorList> _viActorList;
        protected override void _OnRegisterPorts()
        {
            _viActorList = AddValueInput<ActorList>("ActorList");
            AddValueOutput("Count", () =>
            {
                var list = _viActorList?.GetValue();
                if (list == null)
                {
                    _LogError($"请联系策划【路浩/大头】, 节点【ActorList操作-返回大小 FAGetActorListCount】引脚参数配置错误, 【ActorList】引脚为null!");
                    return 0;
                }
                return list.Count;
            });
        }
    }
}
