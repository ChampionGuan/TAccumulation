using System;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作(法术场)/播法术场特效")]
    [Serializable]
    public class MagicFieldFxAsset: BSActionAsset<ActionMagicFieldFx>
    {
        [LabelText("特效ID")]
        public int fxID;

        [LabelText("每次循环重播")]
        public bool loopReplay;
    }

    // 法术场特效：
    public class ActionMagicFieldFx : BSAction<MagicFieldFxAsset>
    {
        protected override void _OnInit()
        {
            allowRecycle = clip.loopReplay;
        }

        protected override void _OnEnter()
        {
            var insID = context.actor.insID;
            if (clip.loopReplay)
            {
                var fxPlayer = X3Battle.Battle.Instance.fxMgr.GetFx(insID, clip.fxID);
                if (fxPlayer == null)
                {
                    fxPlayer = context.actor.effectPlayer.PlayFx(clip.fxID, isBodyFx:true);
                }
                
                if (fxPlayer != null)
                {
                    fxPlayer.Play();
                }  
            }
            else
            {
                context.actor.effectPlayer.PlayFx(clip.fxID, isBodyFx:true);
            }
        }
        
    }
}