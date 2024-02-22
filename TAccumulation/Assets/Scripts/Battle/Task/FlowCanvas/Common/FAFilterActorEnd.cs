using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("Actor筛选过滤结束\nFilterActorEnd")]
    public class FAFilterActorEnd : FlowAction
    {
        private ValueInput<Actor> _viActor;
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override void _Invoke()
        {
            var actor = _viActor?.GetValue();
            if (actor == null)
            {
                return;
            }
            
            if (!(_context is IGraphActorList graphActorList))
            {
                return;
            }

            graphActorList.actorList?.Add(actor);
        }
    }
}