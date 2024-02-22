using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断目标是否持有护盾\nFCHasShield")]
    public class FCHasShield : FlowCondition
    {
        private ValueInput<Actor> _viActor;

        protected override void _OnAddPorts()
        {
            _viActor = AddValueInput<Actor>("Actor");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viActor.GetValue();
            if (actor == null || actor.buffOwner == null)
                return false;
            return actor.attributeOwner.GetAttrValue(AttrType.HpShield) > 0f;
        }
    }
}