using ParadoxNotion.Design;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置是否使用重力（已经废弃，建议使用SwitchMoveMode）")]
    public class SetUseGravity : CharacterAction
    {
        public bool UseGravity;

        protected override void OnExecute()
        {
            // _context.characterCtrl.SwitchGravity(UseGravity);
            EndAction(true);
        }
    }
}
