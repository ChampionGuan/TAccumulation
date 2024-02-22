using ParadoxNotion.Design;
using System.Collections.Generic;
using EasyCharacterMovement;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("切换移动模式：目前开放 Flying 和 Normal")]
    public class SwitchMoveMode : CharacterAction
    {
        public MovementMode targetMode;

        protected override void OnExecute()
        {
            if (_context.actor != null && _context.actor.transform.characterMove)
            {
                _context.actor.transform.characterMove.SwitchMode(targetMode);
            }
            EndAction(true);
        }
    }
}
