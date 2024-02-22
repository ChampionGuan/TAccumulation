using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Function")]
    [Name("获取Actor目标\nGetActorTarget")]
    public class FAGetActorTarget : FlowAction
    {
        public BBParameter<TargetType> TargetType = new BBParameter<TargetType>(X3Battle.TargetType.Skill);
        private ValueInput<Actor> _viActor;

        private Actor _target;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viActor = AddValueInput<Actor>("Actor");
            AddValueOutput<Actor>("Target", () => _target);
        }

        protected override void _Invoke()
        {
            _target = null;
            var actor = _viActor.GetValue();
            if (actor == null)
                return;
            _target = actor.GetTarget(TargetType.GetValue());
        }
    }
}
