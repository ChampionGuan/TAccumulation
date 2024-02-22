using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("行为队列是否为空\nIsGoalQueueEmpty")]
    public class FCIsGoalQueueEmpty : FlowCondition
    {
        private ValueInput<Actor> _vAIOwner;

        protected override void _OnAddPorts()
        {
            _vAIOwner = AddValueInput<Actor>("Owner");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _vAIOwner.GetValue();
            if (actor == null || actor.aiOwner == null)
                return true;
            return actor.aiOwner.ActionGoalsIsEmpty();
        }
    }
}
