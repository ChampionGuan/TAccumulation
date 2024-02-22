using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Condition")]
    [Name("当前关卡是否通关\nLevelIsPassed")]
    public class FCIsLevelPassed : FlowCondition
    {
        protected override bool _IsMeetCondition()
        {
            return BattleUtil.IsLevelUnLock();
        }
    }
}
