using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle{

	[Category("X3Battle/Actor")]
	[Description("播放死亡技能，如果不存在，则直接结束")]
	public class CastDeadSkill : BattleAction
    {
        [Tooltip("是否跳过该流程")]
        public BBParameter<bool> isSkip = new BBParameter<bool>();

		[Tooltip("是否等待技能结束")]
        public BBParameter<bool> waitFinish = new BBParameter<bool>();
        
        protected override void OnExecute()
        {
            if (isSkip.GetValue())
            {
                EndAction(true);
                return;
            }

            var deadSlotID = BattleUtil.GetSlotID(SkillSlotType.Dead, 0);
            if (!_actor.skillOwner.HasSkillSlot(deadSlotID))
            {
                EndAction();
                return;
            }

            if (!_actor.skillOwner.TryCastSkillBySlot(deadSlotID, safeCheck: false))
            {
                EndAction();
                return;
            }
            
            if (!waitFinish.GetValue())
            {
                EndAction();
                return;
            }
            
            _actor.battle.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, _OnEndSkill, "CastDeadSkill._OnEndSkill");
        }

        private void _OnEndSkill(EventEndSkill arg)
        {
            if (arg.skill.actor != _actor)
            {
                return;
            }
            
            var deadSlotID = BattleUtil.GetSlotID(SkillSlotType.Dead, 0);
            if (arg.skill.slotID != deadSlotID)
            {
                return;
            }
            
            _actor.battle.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _OnEndSkill);
            
            EndAction();
            ForceTick();
        }
    }
}
