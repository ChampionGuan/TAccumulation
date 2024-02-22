using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;
using UnityEditor;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("播放动画, syneAnim协同动画")]
    public class PlayCharacterCtrlAnim : CharacterAction
    {
        [RequiredField]
        public BBParameter<string> animName = new BBParameter<string>();
        public float fade;
        public bool skipSame = true;
        public string[] syneAnim;

        protected override string info
        {
            get { return $"播放动画:{animName}"; }
        }

        protected override void OnExecute()
        {
            if (syneAnim != null)
            {
                var stateInfo = _context.locomotionCtrl.GetCurrentAnimatorStateInfo();
                for (int i = 0; i < syneAnim.Length; i++)
                {
                    if (stateInfo.name == syneAnim[i])
                    {
                       
                        if (stateInfo.name == animName.value && skipSame)
                        {
                            _context.locomotionCtrl.PlayAnim(animName.value, fade);
                        }
                        else
                        {
                            var normalizedTime = stateInfo.normalizedTime;
                            var targetAnimLength = _context.locomotionCtrl.context.GetAnimatorStateLength(animName.value);
                            _context.locomotionCtrl.context.PlayAnim(animName.value, (float)normalizedTime * targetAnimLength, fade);
                        }
                        EndAction(true);
                        return;
                    }
                }
            }

            if (skipSame)
            {
                _context.locomotionCtrl.PlayAnim(animName.value, fade);                
            }
            else
            {
                _context.locomotionCtrl.context.PlayAnim(animName.value, skipSameState: false, fadeTime: fade);
            }
            EndAction(true);
        }
    }
}
