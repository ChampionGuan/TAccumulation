using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("阻挡体或者空气墙是否在指定范围内\nIsObstacleInArea"))]
    [Description("阻挡体或者空气墙是否在指定范围内")]
    public class FCIsObstacleInArea : FlowCondition
    {
        public BBIsObstacleInArea isObstacleInArea = new BBIsObstacleInArea();
        
        protected override bool _IsMeetCondition()
        {
            return isObstacleInArea.IsInArea(_actor);
        }
    }
}
