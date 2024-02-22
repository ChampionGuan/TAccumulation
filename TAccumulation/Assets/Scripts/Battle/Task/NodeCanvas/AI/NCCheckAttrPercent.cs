using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("AI检测属性百分比区间\nNCCheckAttrPercent")]
    public class NCCheckAttrPercent : BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<InstantAttrType> instantAttrType = new BBParameter<InstantAttrType>();
        [SliderField(0,100)]
        public BBParameter<int> minAttrPercent = new BBParameter<int>();
        [SliderField(0,100)]
        public BBParameter<int> maxAttrPercent = new BBParameter<int>();
        
        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            if (actor == null)
            {
                return false;
            }
            
            var instantAttr = actor.attributeOwner?.GetAttr((AttrType)instantAttrType.GetValue()) as InstantAttr;
            if (instantAttr == null)
            {
                LogProxy.LogError($"【检测属性百分比区间 NCCheckAttrPercent】{actor}身上AttributeOwner组件没有{instantAttrType.GetValue()}即时属性.");
                return false;
            }
            var curValue = instantAttr.GetValue();
            var maxValue = instantAttr.GetMaxValue();
            
            var minPercent = minAttrPercent.GetValue();
            var maxPercent = maxAttrPercent.GetValue();

            var lowerLimit = minPercent * 0.01f * maxValue;
            var upperLimit = maxPercent * 0.01f * maxValue;

            return curValue >= lowerLimit && curValue <= upperLimit;
        }
    }
}
