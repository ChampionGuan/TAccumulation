using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name(("判断actor所属的组\nIsActorInGroup"))]
    public class FCIsActorInGroup: FlowCondition
    {
        public BBParameter<int> groupID = new BBParameter<int>();
        private ValueInput<Actor> _actorIn;
        protected override void _OnAddPorts()
        {
            base._OnAddPorts();
            _actorIn = AddValueInput<Actor>("actor");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _actorIn.value;
            if (actor == null)
            {
                return false;
            }

            if (actor.groupId == groupID.value)
            {
                return true;
            }
            return false;
        }
    }
}
