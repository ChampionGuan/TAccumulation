using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("释放技能")]
    public class CastSkill : BattleAction
    {
        public BBParameter<Actor> skillCaster = new BBParameter<Actor>();
        public BBParameter<Actor> skillTarget = new BBParameter<Actor>();
        public BBParameter<SkillSlotType> skillType = new BBParameter<SkillSlotType>();
        public BBParameter<int> skillIndex = new BBParameter<int>();

        /*
        protected override string info => $"释放类型为{skillType.value.ToString()}的第{skillIndex.value}个槽位上的技能";
        */

        protected override void OnExecute()
        {
            var caster = skillCaster.isNoneOrNull ? _actor : skillCaster.value;
            var slotId = caster.skillOwner.GetSlotID(skillType.value, skillIndex.value);
            if (null == slotId)
            {
                EndAction(false);
            }
            else
            {
                int targetID = skillTarget.value != null ? skillTarget.value.insID : 0;
                
                var _cmd = ObjectPoolUtility.GetActorCmd<ActorSkillCommand>();
                _cmd.Init(slotId.Value, targetID);
                
                caster.commander.TryExecute(_cmd);
                EndAction(true);
            }
        }
    }
}
