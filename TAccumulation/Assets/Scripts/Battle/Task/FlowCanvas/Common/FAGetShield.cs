using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取目标当前护盾总量\nFAGetShield")]
    public class FAGetShield : FlowAction
    {
        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            _viActor = AddValueInput<Actor>("Actor");
            AddValueOutput("HpShieldValue", () =>
            {
                var actor = _viActor?.GetValue();
                if (actor == null)
                {
                    _LogError("引脚【Actor】没有正确赋值.");
                    return 0f;
                }

                return actor.attributeOwner.GetAttrValue(AttrType.HpShield);
            });
        }
    }
}