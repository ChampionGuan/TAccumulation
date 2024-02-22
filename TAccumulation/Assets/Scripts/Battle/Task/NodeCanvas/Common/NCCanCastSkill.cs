using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Condition")]
    [Name(("CanCastSkill"))]
    [Description("指定技能释放是否满足指定选项条件")]
    public class NCCanCastSkill : BattleCondition
    {
        public BBCanCastSkill canCastSkill = new BBCanCastSkill();

        protected override bool OnCheck()
        {
            return canCastSkill.CheckCastSkill(_actor);
        }
    }
}
