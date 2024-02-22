using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("判断是否有锁定目标\nCheckLockTarget"))]
    public class FCCheckLockTarget : FlowCondition
    {
        private ValueInput<Actor> _viActor;

        protected override void _OnAddPorts()
        {
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override bool _IsMeetCondition()
        {
            var target = _viActor?.GetValue();
            if (target == null)
            {
                return false;
            }

            var lockTarget = target.GetTarget(TargetType.Lock);
            if (lockTarget == null)
            {
                return false;
            }

            return true;
        }
    }
}
