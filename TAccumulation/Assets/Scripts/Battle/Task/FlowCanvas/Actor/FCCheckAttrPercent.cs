using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{    
    [Category("X3Battle/Actor/Condition")]
    [Name("检测属性百分比区间\nCheckAttrPercent")]
    [Description("填写值为浮点数，0-1对应0%-100%，例如希望检测区间为20%-80%，则应该填写0.2和0.8")]
    public class FCCheckAttrPercent : FlowCondition
    {
        public BBParameter<InstantAttrType> instantAttrType = new BBParameter<InstantAttrType>();
        public BBParameter<float> minAttrPercent = new BBParameter<float>();
        public BBParameter<float> maxAttrPercent = new BBParameter<float>();

        private ValueInput<Actor> _viSourceActor;

        protected override void _OnAddPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
        }

        protected override bool _IsMeetCondition()
        {
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null)
            {
                _LogError("请联系策划【大头】,【检测属性百分比区间 CheckHpPercent】SourceActor不允许为空.");
                return false;
            }

            if (sourceActor.attributeOwner == null)
            {
                _LogError("请联系策划【大头】,【检测属性百分比区间 CheckHpPercent】SourceActor身上没有AttributeOwner组件.");
                return false;
            }

            var instantAttr = sourceActor.attributeOwner.GetAttr((AttrType)instantAttrType.GetValue()) as InstantAttr;
            if (instantAttr == null)
            {
                _LogError("请联系策划【大头】,【检测属性百分比区间 CheckHpPercent】SourceActor身上AttributeOwner组件没有instantAttrType.GetValue()即时属性.");
                return false;
            }
            
            var curHp = instantAttr.GetValue();
            var maxHp = instantAttr.GetMaxValue();
            
            var minPercent = minAttrPercent.GetValue();
            var maxPercent = maxAttrPercent.GetValue();

            var lowerLimit = minPercent * maxHp;
            var upperLimit = maxPercent * maxHp;

            if (curHp < lowerLimit || curHp > upperLimit)
            {
                return false;
            }

            return true;
        }
    }
}
