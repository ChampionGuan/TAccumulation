using NodeCanvas.Framework;
using OfficeOpenXml.FormulaParsing.Excel.Functions.Logical;
using ParadoxNotion.Design;
using UnityEngine;
using X3.PlayableAnimator;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("播放动画")]
    public class PlayAnim : BattleAction
    {
        public BBParameter<string> animName = new BBParameter<string>();
        public BBParameter<bool> skipSame = new BBParameter<bool>();
        public BBParameter<bool> waitFinish = new BBParameter<bool>();


        protected override string info => $"Play '{animName.GetValue()}' Anim";

        protected override void OnExecute()
        {
            if (string.IsNullOrEmpty(animName.GetValue()) || null == _actor.animator)
            {
                EndAction(true);
                return;
            }

            _actor.animator.PlayAnim(animName.GetValue(), skipSame.GetValue());
            if (!waitFinish.GetValue())
            {
                EndAction(true);
            }
            else
            {
                if (!_actor.animator.HasState(animName.GetValue()))
                {
                    EndAction(true);
                }

                _actor.animator.onStateNotify.RemoveListener(_OnAnimStateNotify);
                _actor.animator.onStateNotify.AddListener(_OnAnimStateNotify);
            }
        }

        protected void _OnAnimStateNotify(int layerIndex, StateNotifyType notifyType, string name)
        {
            if (notifyType != StateNotifyType.Complete && notifyType != StateNotifyType.Exit || name != animName.GetValue())
            {
                return;
            }

            _actor.animator.onStateNotify.RemoveListener(_OnAnimStateNotify);
            EndAction(true);
        }
    }
}
