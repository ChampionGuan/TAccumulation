using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("检测事件类型")]
    public class CheckEventType : ConditionTask
    {
        [BlackboardOnly] public BBParameter<EventType> valueA = new BBParameter<EventType>();
        public BBParameter<EventType[]> valueB = new BBParameter<EventType[]>();

        protected override string info => valueA + " == " + valueB;

        protected override bool OnCheck()
        {
            return Array.IndexOf(valueB.value, valueA.value) >= 0;
        }
    }
}
