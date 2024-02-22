using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Condition")]
    [Name(("IsObstacleInArea"))]
    [Description("阻挡体或者空气墙是否在指定范围内")]
    public class NCIsObstacleInArea : BattleCondition
    {
        public BBIsObstacleInArea isObstacleInArea = new BBIsObstacleInArea();

        protected override bool OnCheck()
        {
            return isObstacleInArea.IsInArea(_actor);
        }
    }
}
