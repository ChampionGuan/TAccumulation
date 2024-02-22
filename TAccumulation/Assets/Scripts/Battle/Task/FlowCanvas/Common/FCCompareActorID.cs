using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断ActorID\nCompareActorID")]
    public class FCCompareActorID : FlowCondition
    {
        [Name("CfgID")]
        public BBParameter<int> actorID = new BBParameter<int>();
        private ValueInput<Actor> _viSourceActor;

        protected override void _OnAddPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
        }

        protected override bool _IsMeetCondition()
        {
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null)
                return false;
            var id = actorID.GetValue();
            if (sourceActor.cfgID != id)
                return false;
            return true;
        }
    }
}
