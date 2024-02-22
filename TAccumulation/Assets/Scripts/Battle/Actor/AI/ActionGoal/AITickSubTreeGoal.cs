using System;
using NodeCanvas.Framework;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class AITickSubTreeGoal : AIActionGoal<AIActionParams>
    {
        protected override bool OnVerifyingConditions(AIConditionPhaseType phaseType)
        {
            switch (phaseType)
            {
                case AIConditionPhaseType.Pending:
                    // 不在Idle态
                    using (ProfilerDefine.AITickSubTreeGoalIsStatePMarker.Auto())
                    {
                        if (!actor.mainState.IsState(ActorMainStateType.Idle))
                        {
                            return false;
                        }
                    }
                    // 移动未结束
                    using (ProfilerDefine.AITickSubTreeGoalIsMoveEndAnimPMarker.Auto())
                    {
                        if (!(actor.locomotion != null && actor.locomotion.IsMoveEndAnim()))
                        {
                            return false;
                        }
                    }
                    // 有指令在运行
                    if (null != actor.commander.currentCmd) return false;
                    break;
            }

            return base.OnVerifyingConditions(phaseType);
        }
    }
}
