using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action/ActorList")]
    [Name("ActorList批量添加\nCombineActorList")]
    [Description("在list1中增加list2，返回list1")]
    public class FACombineActorList : FlowAction
    {
        private ValueInput<ActorList> _viActorList1;
        private ValueInput<ActorList> _viActorList2;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viActorList1 = AddValueInput<ActorList>("list1");
            _viActorList2 = AddValueInput<ActorList>("list2");
            AddValueOutput("ActorList", () => _viActorList1?.GetValue());
        }

        protected override void _Invoke()
        {
            var list1 = _viActorList1?.GetValue();
            if (list1 == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList合并 FACombineActorList】引脚【list1】配置错误!");
                return; 
            }

            var list2 = _viActorList2?.GetValue();
            if (list2 == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList合并 FACombineActorList】引脚【list2】配置错误!");
                return;
            }

            for (int i = 0; i < list2.Count; i++)
            {
                var actor = list2[i];
                if (list1.Contains(actor))
                {
                    continue;
                }

                list1.Add(actor);
            }
        }
    }
}
