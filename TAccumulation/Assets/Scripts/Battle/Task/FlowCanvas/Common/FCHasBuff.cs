using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("是否有某个Buff\nHasBuff")]
    public class FCHasBuff : FlowCondition
    {
        private ValueInput<Actor> _viBuffOwner;
        private ValueInput<int> _viBuffID;

        protected override void _OnAddPorts()
        {
            _viBuffOwner = AddValueInput<Actor>("BuffOwner");
            _viBuffID = AddValueInput<int>("BuffID");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viBuffOwner.GetValue();
            if (actor == null || actor.buffOwner == null)
                return false;
            return actor.buffOwner.HasBuff(_viBuffID.GetValue());
        }
    }
}
