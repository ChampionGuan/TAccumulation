using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("停止受击")]
    public class StopHurt : CharacterAction
    {
        protected override void OnExecute()
        {
            _context.actor.hurt.StopHurt();
            EndAction(true);
        }
    }
}
