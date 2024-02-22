using System;
using NodeCanvas.Framework;
using UnityEngine.Profiling;

namespace X3Battle
{
    [Serializable]
    public class AIIsTimerOverConditionParams : AIConditionParams<AIIsTimerOverConditionParams>
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<int> id = 0;

        public override void CopyFrom(AIIsTimerOverConditionParams @params)
        {
            source.value = @params.source.value;
            id.value = @params.id.value;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            source.value = null;
            id.value = 0;
            base.Reset();
        }
    }

    public class AIIsTimerOverConditionGoal : AIConditionGoal<AIIsTimerOverConditionParams>
    {
        public override bool IsMeet()
        {
            if (parameters.source.isNoneOrNull)
            {
                return true;
            }
            Actor curActor = parameters.source.value;
            return curActor.timer.IsTimerOver(parameters.id.value);
        }
    }
}
