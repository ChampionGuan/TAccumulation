namespace X3Battle
{
    public class NALevelBeforeEnd: NALevelBeforeActionBase
    {
        protected override void OnExecute()
        {
            // DONE: 设置关卡Actor的位置回到出生点.
            var stageActor = Battle.Instance.actorMgr.stage;
            stageActor.transform.SetPosition(stageActor.bornCfg.Position);
            stageActor.transform.SetForward(stageActor.bornCfg.Forward);

            // 恢复被动技能、开始CD、能量恢复、AI
            foreach (Actor actor in _battle.actorMgr.actors)
            {
                if (!actor.IsRole())
                {
                    continue;
                }
                
                if (!actor.roleBornCfg.AutoStartEnergy)
                {
                    actor.energyOwner.ForbidAllEnergyRecover(false);
                }

                if (!actor.roleBornCfg.AutoCastPassiveSkill)
                {
                    actor.skillOwner.CastAllPassiveSkills();
                }

                if (!actor.roleBornCfg.AutoStartSkillCD)
                {
                    actor.skillOwner.SetSkillStartCD();
                }

                if (!actor.roleBornCfg.AutoStartAI)
                {
                    actor.aiOwner.DisableAI(false, AISwitchType.LevelBefore);
                }
            }
            
            _battle.levelFlow.StartMidFlow();
            EndAction(true);
        }
    }
}
