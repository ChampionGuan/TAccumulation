using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("判断血量百分比是否范围内或者范围外")]
    public class HpPercentRange : BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<int> min = new BBParameter<int>();
        public BBParameter<int> max = new BBParameter<int>();
        public BBParameter<bool> invert = new BBParameter<bool>();

        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            float hp = actor.attributeOwner.GetAttrValue(AttrType.HP);
            float maxHp = actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
            int percent = Mathf.RoundToInt(hp * 100 / maxHp);
            return invert.value ? percent < min.value || percent > max.value : percent >= min.value && percent <= max.value;
        }
    }
}
