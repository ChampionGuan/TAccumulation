using System;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Serializable]
    public class AIDistanceConditionParams : AIConditionParams<AIDistanceConditionParams>
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<ECompareOperator> operation = ECompareOperator.EqualTo;
        public BBParameter<float> distance = 0;

        public override void CopyFrom(AIDistanceConditionParams @params)
        {
            source.value = @params.source.value;
            target.value = @params.target.value;
            operation.value = @params.operation.value;
            distance.value = @params.distance.value;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            source.value = null;
            target.value = null;
            operation.value = ECompareOperator.EqualTo;
            distance.value = 0;
            base.Reset();
        }
    }

    public class AIDistanceConditionGoal : AIConditionGoal<AIDistanceConditionParams>
    {
        public override bool IsMeet()
        {
            if (parameters.source.isNoneOrNull || parameters.target.isNoneOrNull)
            {
                return true;
            }
            return BattleUtil.CompareActorDistance(parameters.distance.value, parameters.source.value, parameters.target.value, true, true, parameters.operation.value);
        }
    }
}
