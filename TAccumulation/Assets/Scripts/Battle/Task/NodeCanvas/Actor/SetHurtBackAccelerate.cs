using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置击退的加速度")]
    public class SetHurtBackAccelerate : CharacterAction
    {
        public float hurtBackAccelerate;
        public float hurtHeightAccelerate;

        protected override void OnExecute()
        {
            _context.actor.hurt.SetHurtBackAccelerate(hurtBackAccelerate, hurtHeightAccelerate);
            EndAction(true);
        }
    }
}
