using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("Actor是否有某个Skill\nHasSkill")]
    public class FCHasSkill: FlowCondition
    {
        private ValueInput<Actor> _viOwner;
        private ValueInput<int> _viSkillID;

        protected override void _OnAddPorts()
        {
            _viOwner = AddValueInput<Actor>("SkillOwner");
            _viSkillID = AddValueInput<int>("SkillID");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viOwner.GetValue();
            if (actor == null || actor.buffOwner == null)
                return false;
            return actor.skillOwner.GetSlotID(SkillSlotType.SkillID, _viSkillID.GetValue()) != null;
        }
    }
}
