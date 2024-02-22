using System;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Serializable]
    public class AINotInGlobalCDConditionParams : AIConditionParams<AINotInGlobalCDConditionParams>
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();

        public override void CopyFrom(AINotInGlobalCDConditionParams @params)
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

    public class AINotInGlobalCDConditionGoal : AIConditionGoal<AINotInGlobalCDConditionParams>
    {
        public override bool IsMeet()
        {
            if (parameters.source.isNoneOrNull)
            {
                return true;
            }
            Actor curActor = parameters.source.value;
            if (curActor.aiOwner == null)
            {
                return true;
            }

            return !curActor.aiOwner.IsInGlobalCD();
        }
    }
}
