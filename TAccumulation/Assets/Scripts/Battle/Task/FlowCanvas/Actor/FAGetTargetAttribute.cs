using FlowCanvas;
using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取单位属性\nGetTargetAttribute")]
    public class FAGetTargetAttribute : FlowAction
    {
        public BBParameter<AttrType> attrType = new BBParameter<AttrType>();
        private ValueInput<Actor> _viActor;
        private float _attrResult;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viActor = AddValueInput<Actor>("Actor");
            AddValueOutput<float>("attrResult", () => _attrResult);
        }
        
        protected override void _Invoke()
        {
            _attrResult = 0f;
            var actor = _viActor.GetValue();
            if (actor == null)
            {
                return;
            }
            _attrResult = actor.attributeOwner.GetAttrValue(attrType.value);
        }
    }
}
