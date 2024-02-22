using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("指定目标是否在指定范围内\nIsTargetInArea"))]
    [Description("指定目标是否在指定范围内")]
    public class FCIsTargetInArea : FlowCondition
    {
        public BBIsTargetInArea isTargetInArea = new BBIsTargetInArea();
        
        protected override bool _IsMeetCondition()
        {
            return isTargetInArea.IsInArea(_actor);
        }
    }
}
