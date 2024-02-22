using System;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Serializable]
    public class AIWaitCurrActionFinishConditionParams : AIConditionParams<AIWaitCurrActionFinishConditionParams>
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();

        public override void CopyFrom(AIWaitCurrActionFinishConditionParams @params)
        {
            source.value = @params.source.value;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            source.value = null;
            base.Reset();
        }
    }

    public class AIWaitCurrActionFinishConditionGoal : AIConditionGoal<AIWaitCurrActionFinishConditionParams>
    {
        public override bool IsMeet()
        {
            if (parameters.source.isNoneOrNull)
            {
                return true;
            }
            var actor = parameters.source.value;
            return actor.aiOwner != null && !actor.aiOwner.ActionGoalIsExecuting();
        }
    }
}
