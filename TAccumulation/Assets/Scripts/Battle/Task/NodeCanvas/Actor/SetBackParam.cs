using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ParadoxNotion.Design;

namespace X3Battle
{
    [System.ComponentModel.Category("X3Battle")]
    [Description("启用击退参数")]
    public class SetBackParam : CharacterAction
    {
        public float hurtBackTime=0.1f;
        public float hurtBackDisRatio = 1.0f;

        protected override void OnExecute()
        {
            _context.actor.hurt.StartHurtBack(hurtBackTime, hurtBackDisRatio);
            EndAction(true);
        }
    }
}
