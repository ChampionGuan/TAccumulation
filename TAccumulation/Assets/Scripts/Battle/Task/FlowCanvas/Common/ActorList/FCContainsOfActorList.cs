using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition/ActorList")]
    [Name("ActorList操作-contain\nContainsOfActorList")]
    public class FCContainsOfActorList : FlowCondition
    {
        private ValueInput<ActorList> _viActorList;
        private ValueInput<Actor> _viActor;

        protected override void _OnAddPorts()
        {
            _viActorList = AddValueInput<ActorList>("ActorList");
            _viActor = AddValueInput<Actor>("Actor");
        }

        protected override bool _IsMeetCondition()
        {
            var list = _viActorList?.GetValue();
            if (list == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList操作-增加 FAAddToActorList】引脚参数配置错误, 【ActorList】引脚为null!");
                return false;
            }

            var actor = _viActor?.GetValue();
            if (actor == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList操作-增加 FAAddToActorList】引脚参数配置错误, 【Actor】引脚为null!");
                return false;
            }

            bool result = list.Contains(actor);
            if (!result)
            {
                return false;
            }

            return true;
        }
    }
}
