using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("强制重置角色状态\nForceResetActor")]
    public class FAForceResetActor : FlowAction
    {
        private ValueInput<Actor> _viResetActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viResetActor = AddValueInput<Actor>("ResetActor");
        }

        protected override void _Invoke()
        {
            var actor = _viResetActor.GetValue();
            actor.ForceIdle();
        }
    }
}
