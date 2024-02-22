using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Old")]
    [Description("角色状态")]
    public class IsStateTag : BattleCondition
    {
        [Tooltip("此值如果为空，则取自身状态")]
        public BBParameter<Actor> source = new BBParameter<Actor>();

        public BBParameter<ActorStateTagType[]> checkStates = new BBParameter<ActorStateTagType[]>();

        protected override string info
        {
            get { return BattleUtil.GetArrayDesc(checkStates.GetValue()); }
        }

        protected override bool OnCheck()
        {
            var actor = null == source || source.isNoneOrNull ? _actor : source.value;
            foreach (var state in checkStates.GetValue())
            {
                if (actor.stateTag.IsActive(state))
                    return true;
            }

            return false;
        }
    }
}
