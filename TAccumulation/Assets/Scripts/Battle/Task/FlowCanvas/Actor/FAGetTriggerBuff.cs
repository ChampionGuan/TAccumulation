using FlowCanvas;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Function")]
    [Name("获取蓝图来源的IBUFF\nGetTriggerBuff")]
    public class FAGetTriggerBuff : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput<IBuff>("IBuff", () => _source as IBuff);
        }
    }
}