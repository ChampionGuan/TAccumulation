using System.Collections;
using System.Collections.Generic;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [System.ComponentModel.Category("X3Battle")]
    [Description("启用击飞,设置降落加速度")]
    public class SetHurtParam : CharacterAction
    {
        public float Resistance = -5000;
        public bool immediately = false;  // 是否立刻下落

        protected override void OnExecute()
        {
            if (immediately)
                _context.actor.hurt.SetHurtBackParam(null, null);
            _context.actor.hurt.SetHeightResistance(Resistance/1000f);
            _context.actor.hurt.StartHurtFly();
            EndAction(true);
        }
    }
}
