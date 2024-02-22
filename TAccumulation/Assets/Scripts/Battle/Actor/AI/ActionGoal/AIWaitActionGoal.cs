using NodeCanvas.Framework;

namespace X3Battle
{
    /// <summary>
    /// 等待行为
    /// 具体见文档：depot/x3/策划文档/战斗/5.系统设计/2.AI规则/AI行为节点整理.xlsx
    /// </summary>
    public class AIWaitActionGoal : AIActionGoal<AIActionParams>
    {
        protected override bool OnVerifyingConditions(AIConditionPhaseType phaseType)
        {
            switch (phaseType)
            {
                case AIConditionPhaseType.Pending:
                    return false;
            }

            return base.OnVerifyingConditions(phaseType);
        }
    }
}
