using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("检测血量百分比区间\nCheckHpPercent")]
    [Description("填写值为浮点数，0-1对应0%-100%，例如希望检测区间为20%-80%，则应该填写0.2和0.8")]
    public class FCCheckHpPercent : FlowCondition
    {
        public BBParameter<float> minHpPercent = new BBParameter<float>();
        public BBParameter<float> maxHpPercent = new BBParameter<float>();

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
                _LogError("请联系策划【卡宝】,【检测血量百分比区间 CheckHpPercent】SourceActor不允许为空.");
                return false;
            }

            if (sourceActor.attributeOwner == null)
            {
                _LogError("请联系策划【卡宝】,【检测血量百分比区间 CheckHpPercent】SourceActor身上没有AttributeOwner组件.");
                return false;
            }

            var curHpAttr = sourceActor.attributeOwner.GetAttr(AttrType.HP);
            if (curHpAttr == null)
            {
                _LogError("请联系策划【卡宝】,【检测血量百分比区间 CheckHpPercent】SourceActor身上AttributeOwner组件没有Hp属性.");
                return false;
            }
            
            var maxHpAttr = sourceActor.attributeOwner.GetAttr(AttrType.MaxHP);
            if (maxHpAttr == null)
            {
                _LogError("请联系策划【卡宝】,【检测血量百分比区间 CheckHpPercent】SourceActor身上AttributeOwner组件没有MaxHp属性.");
                return false;
            }

            var curHp = curHpAttr.GetValue();
            var maxHp = maxHpAttr.GetValue();
            
            var minPercent = minHpPercent.GetValue();
            var maxPercent = maxHpPercent.GetValue();

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
