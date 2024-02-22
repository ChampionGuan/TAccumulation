using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("播放出生技能, 如果不存在, 则直接结束")]
    public class CastBornSkill : BattleAction
    {
        protected override void OnExecute()
        {
            var slotId = BattleUtil.GetSlotID(SkillSlotType.Born, 0);
            if (!_actor.skillOwner.HasSkillSlot(slotId))
            {
                EndAction(true);
                return;
            }

            _actor.skillOwner.TryCastSkillBySlot(slotId);
            EndAction(true);
        }
    }
}
