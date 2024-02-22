using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("是否处于破盾状态\nIsWeak"))]
    [Description("返回传入Actor的破盾状态bool")]
    public class FCIsWeak : FlowCondition
    {
        private ValueInput<Actor> _viSourceActor;
        protected override void _OnAddPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
        }

        protected override bool _IsMeetCondition()
        {
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null)
            {
                _LogError("请联系策划【路浩】,【是否处于破盾状态 FCIsWeak】SourceActor不允许为空.");
                return false;
            }
            return sourceActor.actorWeak.weak;
        }
    }
}
