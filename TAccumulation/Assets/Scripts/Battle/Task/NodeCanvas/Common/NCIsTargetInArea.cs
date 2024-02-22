using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Condition")]
    [Name(("IsTargetInArea"))]
    [Description("指定目标是否在指定范围内")]
    public class NCIsTargetInArea : BattleCondition
    {
        public BBIsTargetInArea isTargetInArea = new BBIsTargetInArea();

        protected override bool OnCheck()
        {
            return isTargetInArea.IsInArea(_actor);
        }
    }
}
