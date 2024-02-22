using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/Condition")]
    [Name("单位AI是否开启\nAIIsEnable")]
    public class FCAIIsEnabled : FlowCondition
    {
        private ValueInput<Actor> _viSourceActor;

        protected override void _OnAddPorts()
        {
            _viSourceActor = AddValueInput<Actor>("Actor");
        }
        protected override bool _IsMeetCondition()
        {
            var actor = _viSourceActor?.GetValue();
            if (actor == null) return false;
            return actor.aiOwner?.enabled ?? false;
        }
    }
}
