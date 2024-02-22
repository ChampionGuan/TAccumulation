using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置是否处于倒地")]
    public class SetIsLying : CharacterAction
    {
        public bool isLying;

        protected override void OnExecute()
        {
            _context.actor.hurt.SetIsLying(isLying);
            EndAction(true);
        }
    }
}
