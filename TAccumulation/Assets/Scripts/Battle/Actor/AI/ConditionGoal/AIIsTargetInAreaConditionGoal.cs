using System;
using NodeCanvas.Framework;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    [Serializable]
    public class AIIsTargetInAreaConditionParams : AIConditionParams<AIIsTargetInAreaConditionParams>
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<float> rotateAngle = 0;
        public BBParameter<float> fanColumnAngle = 0;
        public BBParameter<float> radius = 0;
        public Actor actor;

        public override void CopyFrom(AIIsTargetInAreaConditionParams @params)
        {
            source.value = @params.source.value;
            target.value = @params.target.value;
            rotateAngle.value = @params.rotateAngle.value;
            fanColumnAngle.value = @params.fanColumnAngle.value;
            radius.value = @params.radius.value;
            actor = @params.actor;
            base.CopyFrom(@params);
        }

        public override void Reset()
        {
            source.value = null;
            target.value = null;
            rotateAngle.value = 0;
            fanColumnAngle.value = 0;
            radius.value = 0;
            actor = null;
            base.Reset();
        }
    }

    public class AIIsTargetInAreaConditionGoal : AIConditionGoal<AIIsTargetInAreaConditionParams>
    {
        public override bool IsMeet()
        {
            if (parameters.target.isNoneOrNull)
            {
                return true;
            }
            Actor curActor = parameters.source.isNoneOrNull ? parameters.actor : parameters.source.value;
            return BattleUtil.IsTargetInFanColumn(curActor, parameters.target.value,
                parameters.rotateAngle.value, parameters.fanColumnAngle.value, parameters.radius.value);
        }
    }
}
