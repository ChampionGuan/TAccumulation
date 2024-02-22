using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/Condition")]
    [Name("判断目标是否处于QTE激活状态\nIsInQTEActive")]
    public class FCIsInQTEActive : FlowCondition
    {
        private ValueInput<Actor> _viActor;

        protected override void _OnAddPorts()
        {
            _viActor = AddValueInput<Actor>("Actor");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viActor?.GetValue();
            if (actor == null) return false;
            return actor.skillOwner?.qteController?.isActive ?? false;
        }
    }
}