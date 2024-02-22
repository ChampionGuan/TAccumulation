using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("是否State有Clip")]
    public class IsHaveAnimClip : BattleCondition
    {
        public BBParameter<string[]> stateNames = new BBParameter<string[]>();

        protected override string info
        {
            get
            {
                return "HaveClip:" + BattleUtil.GetArrayDesc(stateNames.GetValue());
            }
        }

        protected override bool OnCheck()
        {
            if (stateNames == null)
                return false;

            foreach (var state in stateNames.value)
            {
                if (_actor.animator.GetAnimatorStateClip(state) == null)
                {
                    return false;
                }
            }

            return true;
        }
    }
}
