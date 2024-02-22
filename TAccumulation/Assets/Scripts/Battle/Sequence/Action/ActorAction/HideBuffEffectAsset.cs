using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/隐藏buff特效")]
    [Serializable]
    public class HideBuffEffectAsset : BSActionAsset<ActionHideBuffEffect>
    {
        [LabelText("淡出时间")]
        public float FadeOutTime;

        [LabelText("淡入时间", "!FxAnimFadeIn")]
        public float FadeInTime;
        [LabelText("动画淡入")]
        public bool FxAnimFadeIn = false;
    }

    public class ActionHideBuffEffect :BSAction<HideBuffEffectAsset>
    {
        protected override void _OnEnter()
        {
            var insID = context.actor.insID;
            foreach (var fxID in context.actor.buffOwner.fxPlayedRefCounts.Keys)
            {
                var fxPlayer = context.battle.fxMgr.GetFx(insID, fxID);
                if (fxPlayer != null)
                {
                    fxPlayer.PlayFade(FxPlayer.FadeType.FadeOut, clip.FadeOutTime);
                }
            }
        }

        protected override void _OnExit()
        {
            var insID = context.actor.insID;
            foreach (var fxID in context.actor.buffOwner.fxPlayedRefCounts.Keys)
            {
                var fxPlayer = context.battle.fxMgr.GetFx(insID, fxID);
                if (fxPlayer != null && !fxPlayer.IsDestroy)
                {
                    if (!clip.FxAnimFadeIn)
                        fxPlayer.PlayFade(FxPlayer.FadeType.FadeIn, clip.FadeInTime);
                    else if (fxPlayer.IsRunning)
                        fxPlayer.RePlay();
                }
            }
        }
    }
}
