using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("是否一定时间内不移动")]
    public class RemainNoMoveWithinTime:BattleCondition
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<float> time = new BBParameter<float>();
        
        protected override bool OnCheck()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;

            return actor.aiOwner != null && actor.aiOwner.noMoveTime >= time.value;
        }
    }
}
