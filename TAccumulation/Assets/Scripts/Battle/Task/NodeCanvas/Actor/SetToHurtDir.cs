using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置面朝受击方向")]
    public class SetToHurtDir : CharacterAction
    {
        [ShowIf("enable", 1)]
        public bool useHurtDir = false;
        public bool enable = true;

        protected override void OnExecute()
        {
            if (enable)
            {
                _context.actor.hurt.formerFaceDir = _context.actor.transform.forward;
                if (useHurtDir)
                    _context.actor.transform.SetForward(-_context.actor.hurt.vecHurtDir);
                else
                    _context.actor.transform.SetForward(_context.actor.hurt.vecFaceDir);
            }
            else
            {
                _context.actor.transform.SetForward(_context.actor.hurt.formerFaceDir);
            }
            EndAction(true);
        }
    }
}
