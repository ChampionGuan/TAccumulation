using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("激活关卡Actor被动技能\nAwakenStageActorPassiveSkill")]
    public class FAAwakenStageActor : FlowAction
    {
        public enum AwakenPassiveSkillType
        {
            All,
            SkillID,
        }

        public AwakenPassiveSkillType AwakenType = AwakenPassiveSkillType.All;
        [ShowIf(nameof(AwakenType), 1)]
        public BBParameter<List<int>> SkillIDs = new BBParameter<List<int>>();
        protected override void _Invoke()
        {
            switch (AwakenType)
            {
                case AwakenPassiveSkillType.All:
                    Battle.Instance.actorMgr.stage.skillOwner.CastAllPassiveSkills();
                    break;
                case AwakenPassiveSkillType.SkillID:
                    var skillIDs = SkillIDs.GetValue();
                    foreach (int skillID in skillIDs)
                    {
                        Battle.Instance.actorMgr.stage.skillOwner.CastPassiveSkill(skillID);
                    }
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }
}
