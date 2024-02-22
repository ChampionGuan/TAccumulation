using System;
using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition/ActorList")]
    [Name("ActorList操作-equals\nFCIsEqualTwoActorList")]
    public class FCIsEqualTwoActorList : FlowCondition
    {
        private ValueInput<List<Actor>> _viActorList1;
        private ValueInput<List<Actor>> _viActorList2;

        protected override void _OnAddPorts()
        {
            _viActorList1 = AddValueInput<List<Actor>>("ActorList1");
            _viActorList2 = AddValueInput<List<Actor>>("ActorList2");
        }

        protected override bool _IsMeetCondition()
        {
            var list1 = _viActorList1?.GetValue();
            if (list1 == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList合并 FACombineActorList】引脚【ActorList1】配置错误!");
                return false;
            }

            var list2 = _viActorList2?.GetValue();
            if (list2 == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList合并 FACombineActorList】引脚【ActorList2】配置错误!");
                return false;
            }

            if (list1.Count != list2.Count)
            {
                return false;
            }
            
            for (var i = 0; i < list1.Count; i++)
            {
                var actor = list1[i];
                if (list2.Contains(actor))
                {
                    continue;
                }

                return false;
            }

            return true;
        }
    }
}
