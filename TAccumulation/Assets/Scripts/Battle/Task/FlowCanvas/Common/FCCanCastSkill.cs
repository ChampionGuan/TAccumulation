using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("指定技能释放是否满足指定选项条件\nCanCastSkill"))]
    [Description("指定技能释放是否满足指定选项条件")]
    public class FCCanCastSkill: FlowCondition
    {
        public BBCanCastSkill canCastSkill = new BBCanCastSkill();
        
        protected override bool _IsMeetCondition()
        {
            return canCastSkill.CheckCastSkill(_actor);
        }
    }
}
