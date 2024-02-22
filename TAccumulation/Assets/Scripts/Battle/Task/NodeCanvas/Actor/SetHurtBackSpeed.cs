using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置击退的速度")]
    public class SetHurtBackSpeed : CharacterAction
    {
        public float hurtBackSpeed;
        public float hurtHeightSpeed;
        public bool useConfig;

        protected override void OnExecute()
        {
            if(!useConfig)
                _context.actor.hurt.SetHurtBackSpeed(hurtBackSpeed, hurtHeightSpeed);
            EndAction(true);
        }
    }
}
