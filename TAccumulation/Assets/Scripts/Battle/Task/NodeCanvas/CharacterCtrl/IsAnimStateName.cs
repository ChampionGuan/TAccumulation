using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("是否State")]
    public class IsAnimStateName : BattleCondition
    {
        public BBParameter<string[]> stateNames = new BBParameter<string[]>();

        protected override string info
        {
            get
            {
                return "AnimState:" + BattleUtil.GetArrayDesc(stateNames.GetValue());
            }
        }

        protected override bool OnCheck()
        {
            if (stateNames == null)
                return false;
            var curStateName = _actor.animator.GetCurrentAnimatorStateName();
            foreach (var stateName in stateNames.value)
            {
                if (curStateName == stateName)
                {
                    return true;
                }
            }

            return false;
        }
    }
}
