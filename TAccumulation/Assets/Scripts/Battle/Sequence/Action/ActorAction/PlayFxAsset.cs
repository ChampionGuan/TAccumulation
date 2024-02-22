using System;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;

namespace X3Battle
{
    [PreviewActionCreator(typeof(PreviewPlayFxAction))]
    [TimelineMenu("角色动作/播放特效")]
    [Serializable]
    public class PlayFxAsset : BSActionAsset<ActionPlayFx>
    {
        [LabelText("特效ID")]
        public int FxID;
    }

    public class ActionPlayFx : BSAction<PlayFxAsset>
    {
        protected override void _OnEnter()
        { 
            context.actor.effectPlayer.PlayFx(clip.FxID);
        }
    }
}
