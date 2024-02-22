using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Name(("技能能量是否为满"))]
    [Description("技能能量是否为满,技能能量挂在女主身上")]
    public class IsSkillEnergyFull:BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();

        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            return actor.attributeOwner.GetAttrValue(AttrType.SkillEnergy) >=
                   actor.attributeOwner.GetAttrValue(AttrType.SkillEnergyMax);
        }
    }
}
