using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("获取受击的方向,并播放动画")]
    public class PlayHurtDirectionAnim : CharacterAction
    {
        public string forward;
        public string back;
        public string left;
        public string right;

        protected override void OnExecute()
        {
            switch(_context.actor.hurt.hurtDirection)
            {
                case HurtDirection.Forward:
                    _context.actor.animator.PlayAnim(forward, skipSameState:false);
                    break;
                case HurtDirection.Back:
                    _context.actor.animator.PlayAnim(back, skipSameState: false);
                    break;
                case HurtDirection.Left:
                    _context.actor.animator.PlayAnim(left, skipSameState: false);
                    break;
                case HurtDirection.Right:
                    _context.actor.animator.PlayAnim(right, skipSameState: false);
                    break;
            }
            EndAction(true);
        }
    }
}
