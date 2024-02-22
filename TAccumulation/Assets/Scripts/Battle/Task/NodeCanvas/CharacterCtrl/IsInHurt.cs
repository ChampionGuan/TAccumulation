using ParadoxNotion.Design;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("是否处于受击")]
    public class IsInHurt : BattleCondition
    {
        protected override bool OnCheck()
        {
            return _actor.hurt.isHurt;
        }
    }
}

