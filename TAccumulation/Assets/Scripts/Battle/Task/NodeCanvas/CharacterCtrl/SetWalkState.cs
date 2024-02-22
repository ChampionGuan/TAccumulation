using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("播放多方向走路动画，\n" +
        "先判断是否动画衔接，" +
        "无[WalkXXXStart] => 衔接播放[WalkXX], 并设置Animator [walkEndConditionName]=false \n" +
        "有[WalkXXXStart] => 衔接播放[WalkXXStart],并设置Animator [walkEndConditionName]=True")]
    public class SetWalkState : CharacterAction
    {
        public float fade;
        public string walkEndConditionName;
        public string[] syneAnim;

        protected LocomotionCtrl ctrl;

        protected override void OnExecute()
        {
            EndAction(true);
            ctrl = _context.locomotionCtrl;

            using (zstring.Block())
            {
                //没有Start动画 播Walk
                zstring moveStartAnim = ctrl.moveAnim + (zstring)"Start";

                //衔接动画 
                if (syneAnim != null)
                {
                    var currentStateInfo = ctrl.GetCurrentAnimatorStateInfo();
                    for (int i = 0; i < syneAnim.Length; i++)
                    {
                        if (currentStateInfo.name == syneAnim[i])
                        {
                            var normalizedTime = currentStateInfo.normalizedTime;
                            if (currentStateInfo.name.Contains("Start") && ctrl.GetAnimatorStateClip(moveStartAnim))
                            {
                                var targetAnimLength = ctrl.context.GetAnimatorStateLength(moveStartAnim);
                                _context.locomotionCtrl.context.PlayAnim(moveStartAnim,
                                    (float) normalizedTime * targetAnimLength, fade);
                                ctrl.context.SetBool(walkEndConditionName, true);
                            }
                            else
                            {
                                if (currentStateInfo.name != ctrl.moveAnim)
                                {
                                    var targetAnimLength = ctrl.context.GetAnimatorStateLength(ctrl.moveAnim);

                                    _context.locomotionCtrl.context.PlayAnim(ctrl.moveAnim,
                                        (float) normalizedTime * targetAnimLength, fade);
                                    ctrl.context.SetBool(walkEndConditionName, false);
                                }
                            }

                            return;
                        }

                    }
                }

                if (ctrl.GetAnimatorStateClip(moveStartAnim))
                {
                    ctrl.PlayAnim(moveStartAnim, fade);
                    ctrl.context.SetBool(walkEndConditionName, true);
                }
                else
                {
                    ctrl.PlayAnim(ctrl.moveAnim, fade);
                    ctrl.context.SetBool(walkEndConditionName, false);
                }
            }
        }
    }
}
