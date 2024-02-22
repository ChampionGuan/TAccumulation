using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置头部旋转")]
    public class SetHeadLookAt : CharacterAction
    {
        [RequiredField]
        [LabelText("是否看向目标")]
        public bool isLookAt = false;
        [LabelText("旋转时间")]
        public BBParameter<float> rotateTime = 0.2f;

        protected override void OnExecute()
        {
            _context.actor.lookAtOwner.UseLookAtStrategy(isLookAt, rotateTime.value);
            EndAction(true);
        }
    }
}
